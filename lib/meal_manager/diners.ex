defmodule MealManager.Diners do
  @moduledoc """
  The Diners context.
  """

  import Ecto.Query, warn: false
  alias MealManager.Repo

  alias MealManager.Diners.Diner

  @doc """
  Returns the list of diners.

  ## Examples

      iex> list_diners()
      [%Diner{}, ...]

  """
  def list_diners do
    Repo.all(Diner)
  end

  @doc """
  Gets a single diner.

  Raises `Ecto.NoResultsError` if the Diner does not exist.

  ## Examples

      iex> get_diner!(123)
      %Diner{}

      iex> get_diner!(456)
      ** (Ecto.NoResultsError)

  """
  def get_diner!(id), do: Repo.get!(Diner, id)

  def get_diner(id), do: Repo.get(Diner, id)

  @doc """
  Creates a diner.

  ## Examples

      iex> create_diner(%{field: value})
      {:ok, %Diner{}}

      iex> create_diner(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_diner(attrs \\ %{}) do
    %Diner{}
    |> Diner.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a diner.

  ## Examples

      iex> update_diner(diner, %{field: new_value})
      {:ok, %Diner{}}

      iex> update_diner(diner, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_diner(%Diner{} = diner, attrs) do
    diner
    |> Diner.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a diner.

  ## Examples

      iex> delete_diner(diner)
      {:ok, %Diner{}}

      iex> delete_diner(diner)
      {:error, %Ecto.Changeset{}}

  """
  def delete_diner(%Diner{} = diner) do
    Repo.delete(diner)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking diner changes.

  ## Examples

      iex> change_diner(diner)
      %Ecto.Changeset{data: %Diner{}}

  """
  def change_diner(%Diner{} = diner, attrs \\ %{}) do
    Diner.changeset(diner, attrs)
  end
end
