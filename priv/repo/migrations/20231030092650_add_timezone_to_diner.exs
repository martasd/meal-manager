defmodule MealManager.Repo.Migrations.AddTimezoneToDiner do
  use Ecto.Migration

  def change do
    alter table(:diners) do
      add(:timezone, :string)
    end
  end
end
