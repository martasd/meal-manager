defmodule MealManager.Diners.Diner do
  use Ecto.Schema
  import Ecto.Changeset

  schema "diners" do
    field :name, :string
    field :age, :integer
    field :weight, :integer

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(diner, attrs) do
    diner
    |> cast(attrs, [:name, :age, :weight])
    |> validate_required([])
  end
end
