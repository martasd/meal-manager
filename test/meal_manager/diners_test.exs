defmodule MealManager.DinersTest do
  use MealManager.DataCase

  alias MealManager.Diners

  describe "diners" do
    alias MealManager.Diners.Diner

    import MealManager.DinersFixtures

    @invalid_attrs %{name: nil, age: nil, weight: nil}

    test "list_diners/0 returns all diners" do
      diner = diner_fixture()
      assert Diners.list_diners() == [diner]
    end

    test "get_diner!/1 returns the diner with given id" do
      diner = diner_fixture()
      assert Diners.get_diner!(diner.id) == diner
    end

    test "create_diner/1 with valid data creates a diner" do
      valid_attrs = %{name: "some name", age: 42, weight: 42}

      assert {:ok, %Diner{} = diner} = Diners.create_diner(valid_attrs)
      assert diner.name == "some name"
      assert diner.age == 42
      assert diner.weight == 42
    end

    test "create_diner/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Diners.create_diner(@invalid_attrs)
    end

    test "update_diner/2 with valid data updates the diner" do
      diner = diner_fixture()
      update_attrs = %{name: "some updated name", age: 43, weight: 43}

      assert {:ok, %Diner{} = diner} = Diners.update_diner(diner, update_attrs)
      assert diner.name == "some updated name"
      assert diner.age == 43
      assert diner.weight == 43
    end

    test "update_diner/2 with invalid data returns error changeset" do
      diner = diner_fixture()
      assert {:error, %Ecto.Changeset{}} = Diners.update_diner(diner, @invalid_attrs)
      assert diner == Diners.get_diner!(diner.id)
    end

    test "delete_diner/1 deletes the diner" do
      diner = diner_fixture()
      assert {:ok, %Diner{}} = Diners.delete_diner(diner)
      assert_raise Ecto.NoResultsError, fn -> Diners.get_diner!(diner.id) end
    end

    test "change_diner/1 returns a diner changeset" do
      diner = diner_fixture()
      assert %Ecto.Changeset{} = Diners.change_diner(diner)
    end
  end
end
