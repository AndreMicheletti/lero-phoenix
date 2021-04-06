defmodule Lero.AccountsTest do
  use Lero.DataCase

  alias Lero.Accounts
  alias Lero.Messaging

  describe "users" do
    alias Lero.Accounts.User

    @valid_attrs %{name: "some name", description: "some description", secret_code: "123"}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
          |> Enum.into(@valid_attrs)
          |> Accounts.create_user()
      user
    end

    def conversation_fixture(user1, user2) do
      Messaging.find_or_start_conversation(user1, user2)
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

    test "get_user_conversations/1 returns a empty list of conversations" do
      user = user_fixture(@valid_attrs)
      assert Accounts.get_user_conversations(user.id) == []
    end

    test "get_user_conversations/1 returns a list of two conversations" do
      user1 = user_fixture(%{ secret_code: "1" })
      user2 = user_fixture(%{ secret_code: "2" })
      user3 = user_fixture(%{ secret_code: "3" })

      conversation_fixture(user1.id, user2.id)
      conversation_fixture(user1.id, user3.id)

      assert length(Accounts.get_user_conversations(user1.id)) == 2
      assert length(Accounts.get_user_conversations(user2.id)) == 1
      assert length(Accounts.get_user_conversations(user3.id)) == 1
    end
  end
end
