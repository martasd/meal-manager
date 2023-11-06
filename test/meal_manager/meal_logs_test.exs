defmodule MealManager.MealLogsTest do
  use MealManager.DataCase

  alias MealManager.MealLogs

  describe "meal_logs" do
    alias MealManager.MealLogs.MealLog

    import MealManager.MealLogsFixtures

    @invalid_attrs %{name: nil, type: nil, date: nil, ingredients: nil}

    test "list_meal_logs/0 returns all meal_logs" do
      meal_log = meal_log_fixture()
      assert MealLogs.list_meal_logs() == [meal_log]
    end

    test "get_meal_log!/1 returns the meal_log with given id" do
      meal_log = meal_log_fixture()
      assert MealLogs.get_meal_log!(meal_log.id) == meal_log
    end

    test "create_meal_log/1 with valid data creates a meal_log" do
      valid_attrs = %{name: "some name", type: :breakfast, date: ~D[2023-11-05], ingredients: ["option1", "option2"]}

      assert {:ok, %MealLog{} = meal_log} = MealLogs.create_meal_log(valid_attrs)
      assert meal_log.name == "some name"
      assert meal_log.type == :breakfast
      assert meal_log.date == ~D[2023-11-05]
      assert meal_log.ingredients == ["option1", "option2"]
    end

    test "create_meal_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = MealLogs.create_meal_log(@invalid_attrs)
    end

    test "update_meal_log/2 with valid data updates the meal_log" do
      meal_log = meal_log_fixture()
      update_attrs = %{name: "some updated name", type: :lunch, date: ~D[2023-11-06], ingredients: ["option1"]}

      assert {:ok, %MealLog{} = meal_log} = MealLogs.update_meal_log(meal_log, update_attrs)
      assert meal_log.name == "some updated name"
      assert meal_log.type == :lunch
      assert meal_log.date == ~D[2023-11-06]
      assert meal_log.ingredients == ["option1"]
    end

    test "update_meal_log/2 with invalid data returns error changeset" do
      meal_log = meal_log_fixture()
      assert {:error, %Ecto.Changeset{}} = MealLogs.update_meal_log(meal_log, @invalid_attrs)
      assert meal_log == MealLogs.get_meal_log!(meal_log.id)
    end

    test "delete_meal_log/1 deletes the meal_log" do
      meal_log = meal_log_fixture()
      assert {:ok, %MealLog{}} = MealLogs.delete_meal_log(meal_log)
      assert_raise Ecto.NoResultsError, fn -> MealLogs.get_meal_log!(meal_log.id) end
    end

    test "change_meal_log/1 returns a meal_log changeset" do
      meal_log = meal_log_fixture()
      assert %Ecto.Changeset{} = MealLogs.change_meal_log(meal_log)
    end
  end
end
