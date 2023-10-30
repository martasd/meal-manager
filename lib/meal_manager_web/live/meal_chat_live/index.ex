defmodule MealManagerWeb.MealChatLive.Index do
  use MealManagerWeb, :live_view

  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatOpenAI
  alias LangChain.Message
  alias LangChain.PromptTemplate
  alias Phoenix.LiveView.AsyncResult
  alias MealManager.Diners
  alias MealManagerWeb.MealChatLive.ChatMessage

  @impl true
  def mount(_params, _session, socket) do
    # Get the hard-coded default diner user
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
            "Hello! I am Jeff the Chef and I'm your personal manager! How can I help you today?"
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
          # |> add_user_message(message.content)
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

  # If this is the FIRST user message, use a prompt template to include some
  # initial hidden instructions. We detect if it's the first by matching on the
  # last_messaging being the "system" message.
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

Do an accountability follow-up with me on my previous workouts. When no previous workout information is available, help me get started.

Today's workout information in JSON format:
<%= @current_workout_json %>

User says:
<%= @user_text %>|)

    updated_chain =
      llm_chain
      |> LLMChain.add_message(
        PromptTemplate.to_message!(current_user_template, %{
          current_user_json: current_user |> Jason.encode!(),
          current_workout_json:
            FitnessLogs.list_fitness_logs(current_user.id, days: 0) |> Jason.encode!(),
          today: today |> Calendar.strftime("%A, %Y-%m-%d"),
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
      # |> LLMChain.add_functions(UpdateCurrentUserFunction.new!())
      |> LLMChain.add_message(Message.new_system!(~S|
        This is a mock prompt.|))

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
