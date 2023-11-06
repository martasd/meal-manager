defmodule MealManager.MealLogs.MealLog do
  use Ecto.Schema
  import Ecto.Changeset
  alias MealManager.Diners.Diner

  @derive {Jason.Encoder, only: [:name, :type, :date, :ingredients]}
  schema "meal_logs" do
    field :name, :string
    field :type, Ecto.Enum, values: [:breakfast, :lunch, :dinner]
    field :date, :date
    field :ingredients, {:array, :string}

    timestamps(type: :utc_datetime_usec)

    belongs_to :diner, Diner
  end

  @doc false
  def changeset(meal_log, attrs) do
    meal_log
    |> cast(attrs, [:name, :type, :date, :ingredients])
    |> validate_required([:name, :type, :date])
  end
end
