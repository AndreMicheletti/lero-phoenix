defmodule Lero.Messaging do
  @moduledoc """
  The Messaging context.
  """

  import Ecto.Query, warn: false
  alias Lero.Repo

  alias Lero.Messaging.Conversation
  alias Lero.Messaging.Message
  alias Lero.Accounts
  alias Lero.Utils

  @doc """
  Returns the list of conversations.

  ## Examples

      iex> list_conversations()
      [%Conversation{}, ...]

  """
  def list_conversations do
    Repo.all(Conversation)
  end

  @doc """
  Gets a single conversation.

  Raises `Ecto.NoResultsError` if the Conversation does not exist.

  ## Examples

      iex> get_conversation!(123)
      %Conversation{}

      iex> get_conversation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_conversation!(id), do: Repo.get!(Conversation, id)

  def find_conversation(user_id, target_id) do
    first = Repo.one(from cv in Conversation, where: cv.participants == ^[user_id, target_id])
    if first, do: first, else: Repo.one(from cv in Conversation, where: cv.participants == ^[target_id, user_id])
  end

  def find_or_start_conversation(user_id, target_id) do
    found = find_conversation(user_id, target_id)
    if found do
      found
    else
      {:ok, %Conversation{} = conversation} = start_conversation(user_id, target_id)
      conversation
    end
  end

  def start_conversation(user_id, target_id) do
    if find_conversation(user_id, target_id) do
      {:error, "Conversation already exists"}
    else
      {:ok, %Conversation{} = conversation} = create_conversation(%{title: nil, participants: [user_id, target_id] })
      broadcast_new_conversation(conversation)
      {:ok, conversation}
    end
  end

  def get_conversation_messages(conversation_id) do
    Repo.all(from ms in Message, where: ms.conversation_id == ^conversation_id, order_by: [desc: :inserted_at])
  end

  def get_paginated_conversation_messages(conversation_id, page, offset) do
    get_conversation_messages(conversation_id)
    |> Utils.paginate(page, offset)
  end

  def get_conversation_messages_count(conversation_id) do
    Repo.one(from ms in Message, where: ms.conversation_id == ^conversation_id, select: count(ms.id))
  end

  def get_conversation_title_based_on_user(conversation, user_id) do
    participants = Enum.reject(conversation.participants, fn x -> x == user_id end)
    if length(participants) == 1 do
      Accounts.get_user!(Enum.at(participants, 0)).name
    else
      conversation.title
    end
  end

  @doc """
  Creates a conversation.

  ## Examples

      iex> create_conversation(%{field: value})
      {:ok, %Conversation{}}

      iex> create_conversation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_conversation(attrs \\ %{}) do
    %Conversation{}
    |> Conversation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a conversation.

  ## Examples

      iex> update_conversation(conversation, %{field: new_value})
      {:ok, %Conversation{}}

      iex> update_conversation(conversation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_conversation(%Conversation{} = conversation, attrs) do
    conversation
    |> Conversation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a conversation.

  ## Examples

      iex> delete_conversation(conversation)
      {:ok, %Conversation{}}

      iex> delete_conversation(conversation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_conversation(%Conversation{} = conversation) do
    Repo.delete(conversation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking conversation changes.

  ## Examples

      iex> change_conversation(conversation)
      %Ecto.Changeset{data: %Conversation{}}

  """
  def change_conversation(%Conversation{} = conversation, attrs \\ %{}) do
    Conversation.changeset(conversation, attrs)
  end

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Repo.all(Message)
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  def send_message(sender_id, conversation_id, content) do
    result = create_message(%{user_id: sender_id, conversation_id: conversation_id, content: content})
    broadcast_upd_conversation(conversation_id)
    result
  end

  def send_message_to(sender_id, target_id, content) do
    conversation = find_or_start_conversation(sender_id, target_id)
    send_message(sender_id, conversation.id, content)
  end

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  def broadcast_new_conversation(%Lero.Messaging.Conversation{} = conversation) do
    conversation.participants
      |> Enum.map(fn id ->
        LeroWeb.Endpoint.broadcast!("conversation:lobby", "new_conversation", %{ conversation: serialize_conversation(conversation, id) })
      end)
  end

  def broadcast_new_conversation(conversation_id) when is_number(conversation_id) do
    get_conversation!(conversation_id) |> broadcast_new_conversation()
  end

  def broadcast_upd_conversation(%Lero.Messaging.Conversation{} = conversation) do
    conversation.participants
      |> Enum.map(fn id ->
        LeroWeb.Endpoint.broadcast!("conversation:lobby", "upd_conversation", %{ conversation: serialize_conversation(conversation, id) })
      end)
  end

  def broadcast_upd_conversation(conversation_id) when is_number(conversation_id) do
    get_conversation!(conversation_id) |> broadcast_upd_conversation()
  end

  def serialize_message(message, user_id) do
    %{
      id: message.id,
      content: message.content,
      conversation_id: message.conversation_id,
      direction: (if message.user_id == user_id, do: "out", else: "in"),
      time: message.inserted_at
    }
  end

  def serialize_message(message) do
    %{
      id: message.id,
      user_id: message.user_id,
      content: message.content,
      conversation_id: message.conversation_id,
      time: message.inserted_at
    }
  end

  def serialize_conversation(conversation) do
    %{
      id: conversation.id,
      title: conversation.title,
      participants:
        conversation.participants
          |> Enum.map(fn x -> Accounts.serialize_user(x) end)
    }
  end

  def serialize_conversation(conversation, user_id) do
    title = if conversation.title, do: conversation.title, else: get_conversation_title_based_on_user(conversation, user_id)
    %{
      id: conversation.id,
      title: title,
      userId: user_id,
      participants:
        conversation.participants
          |> Enum.reject(fn x -> x == user_id end)
          |> Enum.map(fn x -> Accounts.serialize_user(x) end)
    }
  end
end
