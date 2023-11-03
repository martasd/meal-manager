defmodule MealManager.Diners.Diner do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:name, :age, :weight, :timezone]}
  schema "diners" do
    field(:name, :string)
    field(:age, :integer)
    field(:weight, :integer)
    field(:timezone, :string)

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(diner, attrs) do
    diner
    |> cast(attrs, [:name, :age, :weight, :timezone])
    |> validate_required([])
  end
end
