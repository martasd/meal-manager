defmodule MealManagerWeb.MealChatLive.Index do
  use MealManagerWeb, :live_view

  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatOpenAI
  alias LangChain.Message
  alias LangChain.PromptTemplate
  alias Phoenix.LiveView.AsyncResult
  alias MealManager.Diners
  alias MealManagerWeb.MealChatLive.ChatMessage
  alias MealManagerWeb.MealChatLive.UpdateCurrentUserFunction

  @impl true
  def mount(_params, _session, socket) do
    # Get the hard-coded default diner user (only-user application)
    socket = assign(socket, :current_user, Diners.get_diner!(1))

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    socket =
      socket
      # display a prompt message for the UI that isn't used in the actual
      # conversations
      |> assign(:display_messages, [
        %ChatMessage{
          role: :assistant,
          hidden: false,
          content:
            "Hello! I am Jeff the Chef and I'm your personal meal manager! How can I help you today?"
        }
      ])
      |> reset_chat_message_form()
      |> assign_llm_chain()
      |> assign(:async_result, %AsyncResult{})

    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"chat_message" => params}, socket) do
    changeset =
      params
      |> ChatMessage.create_changeset()
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"chat_message" => params}, socket) do
    socket =
      case ChatMessage.new(params) do
        {:ok, %ChatMessage{} = message} ->
          socket
          |> add_user_message(message.content)
          |> reset_chat_message_form()
          |> run_chain()

        {:error, changeset} ->
          assign_form(socket, changeset)
      end

    {:noreply, socket}
  end

  # Browser hook sent up the user's timezone.
  def handle_event("browser-timezone", %{"timezone" => timezone}, socket) do
    user = socket.assigns.current_user

    socket =
      if timezone != user.timezone do
        {:ok, updated_user} = Diners.update_diner(user, %{timezone: timezone})

        socket
        |> assign(:current_user, updated_user)
      else
        socket
      end

    {:noreply, socket}
  end

  # Apply the delta to the LLMChain. If delta completes the message, display it.
  @impl true
  def handle_info({:chat_response, %LangChain.MessageDelta{} = delta}, socket) do
    updated_chain = LLMChain.apply_delta(socket.assigns.llm_chain, delta)

    # If delta completes the message, display the message.
    socket =
      if updated_chain.delta == nil do
        case updated_chain.last_message do
          %Message{role: role, content: content}
          when role in [:user, :assistant] and is_binary(content) ->
            append_display_message(socket, %ChatMessage{role: role, content: content})

          _message_without_content ->
            socket
        end
      else
        socket
      end

    {:noreply, assign(socket, :llm_chain, updated_chain)}
  end

  def handle_info({:updated_current_user, updated_user}, socket) do
    message = %ChatMessage{
      role: :function_call,
      hidden: false,
      content: "Updated your information."
    }

    socket =
      socket
      |> assign(:current_user, updated_user)
      |> assign(
        :llm_chain,
        LLMChain.update_custom_context(socket.assigns.llm_chain, %{current_user: updated_user})
      )
      |> append_display_message(message)

    {:noreply, socket}
  end

  # Handles async function returning a successful result.
  def handle_async(:running_llm, {:ok, :ok = _success_result}, socket) do
    # Discard the result of the successful async function. We only care about side-effects.
    socket = assign(socket, :async_result, AsyncResult.ok(%AsyncResult{}, :ok))

    {:noreply, socket}
  end

  # Handles async function returning an error as a result
  def handle_async(:running_llm, {:ok, {:error, reason}}, socket) do
    socket =
      socket
      |> put_flash(:error, reason)
      |> assign(:async_result, AsyncResult.failed(%AsyncResult{}, reason))

    {:noreply, socket}
  end

  # Handles async function exploding
  def handle_async(:running_llm, {:exit, reason}, socket) do
    socket =
      socket
      |> put_flash(:error, "Call failed: #{inspect(reason)}")
      |> assign(:async_result, %AsyncResult{})

    {:noreply, socket}
  end

  # If this is the first user message, use a prompt template to include some initial hidden instructions. 
  # Detect if it's the first by matching on the last_message being the "system" message.
  def add_user_message(
        %{assigns: %{llm_chain: %LLMChain{last_message: %Message{role: :system}} = llm_chain}} =
          socket,
        user_text
      )
      when is_binary(user_text) do
    current_user = socket.assigns.current_user
    today = DateTime.now!(current_user.timezone)

    current_user_template = PromptTemplate.from_template!(~S|
Today is <%= @today %>

User's currently known account information in JSON format:
<%= @current_user_json %>

User says:
<%= @user_text %>|)

    updated_chain =
      LLMChain.add_message(
        llm_chain,
        PromptTemplate.to_message!(current_user_template, %{
          current_user_json: current_user |> Jason.encode!(),
          today: Calendar.strftime(today, "%A, %Y-%m-%d"),
          user_text: user_text
        })
      )

    socket
    |> assign(llm_chain: updated_chain)
    # display what the user said, but not what we sent.
    |> append_display_message(%ChatMessage{role: :user, content: user_text})
  end

  # This is NOT the first message. Submit the user's text as-is.
  def add_user_message(socket, user_text) when is_binary(user_text) do
    updated_chain = LLMChain.add_message(socket.assigns.llm_chain, Message.new_user!(user_text))

    socket
    |> assign(llm_chain: updated_chain)
    |> append_display_message(%ChatMessage{role: :user, content: user_text})
  end

  defp append_display_message(socket, %ChatMessage{} = message) do
    assign(socket, :display_messages, socket.assigns.display_messages ++ [message])
  end

  defp reset_chat_message_form(socket) do
    changeset = ChatMessage.create_changeset(%{})
    assign_form(socket, changeset)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp assign_llm_chain(socket) do
    llm_chain =
      LLMChain.new!(%{
        llm:
          ChatOpenAI.new!(%{
            model: "gpt-4",
            temperature: 0,
            request_timeout: 60_000,
            stream: true
          }),
        custom_context: %{
          live_view_pid: self(),
          current_user: socket.assigns.current_user
        },
        verbose: false
      })
      |> LLMChain.add_functions(UpdateCurrentUserFunction.new!())
      |> LLMChain.add_message(Message.new_system!(~S|
You are a helpful European virtual personal chef. Your name is "Jeff". You speak in a natural, casual and conversational tone.
        I am a women living in the Czech Republic who is breastfeeding her newborn child.
        Your objective is to suggest a healthy and nutritionally balanced menu for a day. Do this by:

        - Asking about my personal details: age and weight.
        - Limiting discussions to ONLY discuss food.
        - Recommending breakfast, lunch, and dinner as a daily menu.

        Do not answer questions off the topic of food and food preparation.
        Answer my questions when possible. If you don't know the answer to something, say you don't know; do not make up answers.


Format for the menu:

**Breakfast** - Meal name
- Description: description of the meal
- Ingredients: list of ingredients needed

**Lunch** - Meal name
- Description: description of the meal
- Ingredients: list of ingredients needed

**Dinner** - Meal name
- Description: description of the meal
- Ingredients: list of ingredients needed


|))

    socket
    |> assign(:llm_chain, llm_chain)
  end

  defp run_chain(socket) do
    chain = socket.assigns.llm_chain
    live_view_pid = self()

    callback_fn = fn
      %LangChain.MessageDelta{} = delta ->
        send(live_view_pid, {:chat_response, delta})

      %LangChain.Message{} = _message ->
        # Disregard the full-message callback. We'll only use the delta.
        # send(live_view_pid, {:chat_response, message})
        :ok
    end

    socket
    |> assign(:async_result, AsyncResult.loading())
    |> start_async(:running_llm, fn ->
      case LLMChain.run(chain, while_needs_response: true, callback_fn: callback_fn) do
        # Don't return a large success result. Callbacks return what we want.
        {:ok, _updated_chain, _last_message} ->
          :ok

        {:error, reason} ->
          {:error, reason}
      end
    end)
  end

  defp icon_for_role(assigns) do
    icon_name =
      case assigns.role do
        :assistant ->
          "hero-computer-desktop"

        :function_call ->
          "hero-cog-8-tooth"

        _other ->
          "hero-user"
      end

    assigns = assign(assigns, :icon_name, icon_name)

    ~H"""
    <.icon name={@icon_name} />
    """
  end
end
