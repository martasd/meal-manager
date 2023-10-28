defmodule MealManagerWeb.MealChatLive.Index do
  use MealManagerWeb, :live_view

  alias LangChain.Chains.LLMChain
  alias LangChain.ChatModels.ChatOpenAI
  alias LangChain.Message
  alias Phoenix.LiveView.AsyncResult
  alias MealManager.Diners
  alias MealManagerWeb.MealChatLive.ChatMessage

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      # Get the hard-coded default diner user
      |> assign(:current_user, Diners.get_diner!(1))

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

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp reset_chat_message_form(socket) do
    changeset = ChatMessage.create_changeset(%{})
    assign_form(socket, changeset)
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
end
