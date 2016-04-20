defmodule HelloPhoenix.UserController do
  use HelloPhoenix.Web, :controller

  alias HelloPhoenix.User
  alias HelloPhoenix.Message

  plug :scrub_params, "user" when action in [:sign_in, :sign_up]

  def sign(conn, params) do
    user = nil
    if username = params["username"] do
      user = Repo.all(from u in User, select: u, where: u.username == ^username) |> List.first

      if user do
        changeset = User.changeset(user)
        render conn, "sign_in.html", changeset: changeset
      else
        changeset = User.changeset(%User{}, %{"username" => username}, false)
        render conn, "sign_up.html", changeset: changeset
      end
    else
      changeset = User.changeset(%User{})
      render conn, "sign.html", changeset: changeset
    end
  end

  def sign_up(conn, %{"user" => user_params} = _params) do
    changeset = User.changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, 'Signed up successfully')
        |> redirect(to: user_path(conn, :sign))
      {:error, changeset} ->
        render conn, "sign_up.html", changeset: changeset
    end
  end

  def sign_in(conn, %{"user" => user_params} = params) do
    user = Repo.all(from w in User, where: w.username == ^user_params["username"]) |> List.first

    if user.password == user_params["password"] do
      conn = put_session(conn, :user_id, user.id)
      redirect(conn, to: user_path(conn, :chat))
    else
      conn
      |> put_flash(:error, "Wrong passoword")
      |> render("sign_in.html", changeset: User.changeset(user))
    end
  end

  def chat(conn, _params) do
    if user_id = get_session(conn, :user_id) do
      messages = Message |> Message.includes_user |> Repo.all(limit: 15)
      render(conn, "chat.html", messages: messages, token: Phoenix.Token.sign(conn, "user", user_id), user_id: user_id)
    else
      conn
      |> put_flash(:error, "You need to be signed in")
      |> redirect(to: user_path(conn, :sign))
    end
  end
end
