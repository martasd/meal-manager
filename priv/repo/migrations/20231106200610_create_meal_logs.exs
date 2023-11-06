defmodule MealManager.Repo.Migrations.CreateMealLogs do
  use Ecto.Migration

  def change do
    create table(:meal_logs) do
      add :name, :string
      add :type, :string
      add :date, :date
      add :ingredients, {:array, :string}

      timestamps(type: :utc_datetime_usec)
    end
  end
end
