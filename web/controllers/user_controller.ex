defmodule HelloPhoenix.UserController do
  use HelloPhoenix.Web, :controller

  alias HelloPhoenix.User

  plug :scrub_params, "user" when action in [:sign_in, :sign_up]

  def sign(conn, params) do
    user = nil
    if username = params["username"] do
      user = Repo.all(from u in User, select: u, where: u.username == ^username) |> List.first

      if user do
        changeset = User.changeset(user)
        render conn, "sign_in.html", changeset: changeset
      else
        changeset = User.changeset(%User{})
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
        |> redirect(to: user_path(conn, :sign_up))
      {:error, changeset} ->
        render conn, "sign_up.html", changeset: changeset
    end
  end

  def sign_in(conn, %{"user" => user_params} = params) do
    user = Repo.all(from w in User, where: w.username == ^user_params["username"]) |> List.first

    if user.password == user_params["password"] do

    else
      conn
      |> put_flash(:error, "Wrong passoword")
      |> render("sign_in.html", changeset: User.changeset(user))
    end
  end
end
