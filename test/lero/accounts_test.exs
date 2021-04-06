defmodule Lero.AccountsTest do
  use Lero.DataCase

  alias Lero.Accounts

  describe "users" do
    alias Lero.Accounts.User

    @valid_attrs %{name: "some name", description: "some description", secret_code: "123"}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} = Accounts.create_user(attrs)
      user
    end

    test "create_user/1 with unique secret_code creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.name == "some name"
      assert user.description == "some description"
      assert user.secret_code == "123"
    end

    test "create_user/1 with duplicate secret_code doesn't create a user" do
      user_fixture(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(%{name: "other name", description: "other description", secret_code: "123"})
    end
  end
end
