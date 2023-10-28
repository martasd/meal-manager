defmodule MealManager.Repo.Migrations.CreateDiners do
  use Ecto.Migration

  def change do
    create table(:diners) do
      add :name, :string
      add :age, :integer
      add :weight, :integer

      timestamps(type: :utc_datetime_usec)
    end
  end
end
