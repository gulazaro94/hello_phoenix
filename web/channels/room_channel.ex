defmodule HelloPhoenix.RoomChannel do
  use Phoenix.Channel
  alias HelloPhoenix.Message
  alias HelloPhoenix.User
  alias HelloPhoenix.Repo

  def join("rooms:lobby", %{"token" => token}, socket) do
    case Phoenix.Token.verify(socket, "user", token, max_age: 1209600) do
      {:ok, user_id} ->
        user = Repo.get!(User, user_id)
        socket = assign(socket, :user_id, user.id)
        {:ok, socket}
      {:error, _} ->
        {:error, "unauthorized"}
    end
  end

  def join("rooms:" <> _private_room_id, params, _socket) do
    {:error, "unauthorized"}
  end

  def handle_in("new_message", %{"body" => body}, socket) do
    message = String.strip(body)
    if message != "" do
      changeset = Message.changeset(%Message{}, %{message: message, user_id: socket.assigns.user_id})
      case Repo.insert(changeset) do
        {:ok, changeset} ->
          user = Repo.get(HelloPhoenix.User, changeset.user_id)
          broadcast! socket, "new_message", %{id: changeset.id, message: changeset.message, user_name: user.name, user_id: changeset.user_id}
        _ ->
      end
    end
    {:noreply, socket}
  end
end