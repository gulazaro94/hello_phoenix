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
        render "sign_in.html", changeset: changeset
      else
        changeset = User.changeset(%User{})
        render conn, "sign_up.html", changeset: changeset
      end
    else
      changeset = User.changeset(%User{})
      render conn, "sign.html", changeset: changeset
    end
  end

  def sign_up(conn, %{"user" => user_params} = params) do
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

end
