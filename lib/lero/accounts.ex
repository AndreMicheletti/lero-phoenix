defmodule Lero.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Lero.Repo

  alias Lero.Accounts.User
  alias Lero.Messaging.Conversation

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def authenticate_user(secret_code, plain_password) do
    user = get_user_by_secret_code(secret_code)
    if Bcrypt.verify_pass(plain_password, user.hashed_password) do
      {:ok, user}
    else
      {:error, "password doesn't match"}
    end
  end

  def get_user_by_name(user_name) do
    Repo.one(from us in User, where: us.name == ^user_name)
  end

  def get_user_by_secret_code(secret_code) do
    Repo.one(from us in User, where: us.secret_code == ^secret_code)
  end

  def get_user_conversations(user_id) do
    Repo.all(from cv in Conversation, where: ^user_id in cv.participants)
  end

  def hash_password_attr(attrs) do
    if Map.has_key?(attrs, :password) do
      hashed_password = Bcrypt.hash_pwd_salt(attrs.password)
      Map.merge(attrs, %{hashed_password: hashed_password})
    else
      if Map.has_key?(attrs, "password") do
        hashed_password = Bcrypt.hash_pwd_salt(attrs["password"])
        Map.merge(attrs, %{"hashed_password" => hashed_password})
      else
        attrs
      end
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    merged_map = hash_password_attr(attrs)
    %User{}
    |> User.changeset(merged_map)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    filtered_attrs =
      attrs
      |> hash_password_attr()
      |> Map.delete(:secret_code)
      |> Map.delete("secret_code")
    user
      |> User.changeset(filtered_attrs)
      |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def serialize_user(%Lero.Accounts.User{} = user) do
    %{ id: user.id, name: user.name, secretCode: user.secret_code, description: user.description }
  end

  def serialize_user(user_id) do
    user = get_user!(user_id)
    %{ id: user.id, name: user.name, secretCode: user.secret_code, description: user.description }
  end
end
