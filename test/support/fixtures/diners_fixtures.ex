defmodule MealManager.DinersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MealManager.Diners` context.
  """

  @doc """
  Generate a diner.
  """
  def diner_fixture(attrs \\ %{}) do
    {:ok, diner} =
      attrs
      |> Enum.into(%{
        age: 42,
        name: "some name",
        weight: 42
      })
      |> MealManager.Diners.create_diner()

    diner
  end
end
