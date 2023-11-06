defmodule MealManager.MealLogsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MealManager.MealLogs` context.
  """

  @doc """
  Generate a meal_log.
  """
  def meal_log_fixture(attrs \\ %{}) do
    {:ok, meal_log} =
      attrs
      |> Enum.into(%{
        date: ~D[2023-11-05],
        ingredients: ["option1", "option2"],
        name: "some name",
        type: :breakfast
      })
      |> MealManager.MealLogs.create_meal_log()

    meal_log
  end
end
