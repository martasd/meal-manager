defmodule MealManagerWeb.MealChatLive.UpdateCurrentUserFunction do
  @moduledoc """
  Function tool to modify user's account.

  Defines a function to expose to an LLM and provide the `execute/2` function
  for evaluating it when an LLM executes the function.
  """

  @doc """
  Defines the "update_current_user" function.
  """
  alias LangChain.Function
  alias MealManager.Diners

  @spec new() :: {:ok, Function.t()} | {:error, Ecto.Changeset.t()}
  def new() do
    Function.new(%{
      name: "update_current_user",
      description: "Update one or more fields in user's account.",
      parameters_schema: %{
        type: "object",
        properties: %{
          age: %{
            type: "integer",
            description: "The user's age."
          },
          weight: %{
            type: "integer",
            description: "The user's weight."
          }
        },
        required: []
      },
      function: &execute/2
    })
  end

  @spec new!() :: Function.t() | no_return()
  def new!() do
    case new() do
      {:ok, function} ->
        function

      {:error, changeset} ->
        raise LangChain.LangChainError, changeset
    end
  end

  @doc """
  Performs the function and let's the LiveView know of the change. Returns the result to the LLM.
  """
  @spec execute(args :: %{String.t() => any()}, context :: map()) :: String.t()
  def execute(%{} = args, %{live_view_pid: pid, current_user: user} = _context) do
    # Use the context for the current_user
    case Diners.update_diner(user, args) do
      {:ok, updated_user} ->
        send(pid, {:updated_current_user, updated_user})
        # return text to the LLM letting it know the result of the action
        "success"

      {:error, changeset} ->
        reason = LangChain.Utils.changeset_error_to_string(changeset)
        "ERROR: #{reason}"
    end
  end
end
