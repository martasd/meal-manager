defmodule MealManager.Repo.Migrations.AddDinerToMealLogs do
  use Ecto.Migration

  def change do
    alter table(:meal_logs) do
      add :diner_id, references(:diners, on_delete: :delete_all), null: false
    end

    create index(:meal_logs, [:name])
    create index(:meal_logs, [:date])
    create index(:meal_logs, [:diner_id])
  end
end
