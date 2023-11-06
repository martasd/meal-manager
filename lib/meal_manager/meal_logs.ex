defmodule MealManager.MealLogs do
  @moduledoc """
  The MealLogs context.
  """

  import Ecto.Query, warn: false
  alias MealManager.Repo

  alias MealManager.MealLogs.MealLog

  @doc """
  Returns the list of meal_logs.

  ## Examples

      iex> list_meal_logs()
      [%MealLog{}, ...]

  """
  def list_meal_logs do
    Repo.all(MealLog)
  end

  @doc """
  Gets a single meal_log.

  Raises `Ecto.NoResultsError` if the Meal log does not exist.

  ## Examples

      iex> get_meal_log!(123)
      %MealLog{}

      iex> get_meal_log!(456)
      ** (Ecto.NoResultsError)

  """
  def get_meal_log!(id), do: Repo.get!(MealLog, id)

  @doc """
  Creates a meal_log.

  ## Examples

      iex> create_meal_log(%{field: value})
      {:ok, %MealLog{}}

      iex> create_meal_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_meal_log(attrs \\ %{}) do
    %MealLog{}
    |> MealLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a meal_log.

  ## Examples

      iex> update_meal_log(meal_log, %{field: new_value})
      {:ok, %MealLog{}}

      iex> update_meal_log(meal_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_meal_log(%MealLog{} = meal_log, attrs) do
    meal_log
    |> MealLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a meal_log.

  ## Examples

      iex> delete_meal_log(meal_log)
      {:ok, %MealLog{}}

      iex> delete_meal_log(meal_log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_meal_log(%MealLog{} = meal_log) do
    Repo.delete(meal_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking meal_log changes.

  ## Examples

      iex> change_meal_log(meal_log)
      %Ecto.Changeset{data: %MealLog{}}

  """
  def change_meal_log(%MealLog{} = meal_log, attrs \\ %{}) do
    MealLog.changeset(meal_log, attrs)
  end
end
