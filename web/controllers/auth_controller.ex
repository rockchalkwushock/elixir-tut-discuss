defmodule Discuss.AuthController do
  use Discuss.Web, :controller
  plug Ueberauth

  alias Discuss.User

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, %{"provider" => provider}) do
    user_params = %{token: auth.credentials.token, email: auth.info.email, provider: provider }
    changeset = User.changeset(%User{}, user_params)
    signin(conn, changeset)
    # IO.puts "+++++++"
    # # conn.assigns is where I can stash some piece of data/code that I might
    # # need later on.
    # IO.inspect(conn.assigns)
    # # will return a Struct that holds all the user's profile information
    # # i.e. scopes, token, user,
    # IO.puts "+++++++"
    # IO.inspect(params)
    # # will hold a map with the "code"
    # # %{"code" => "5204358723045", "provider" => "github"}
    # IO.puts "+++++++"
  end

  def signout(conn, _params) do
    conn
    |> configure_session(drop: true) # any data tied to the current user clear it all.
    |> redirect(to: topic_path(conn, :index))
  end

  defp signin(conn, changeset) do
    case insert_or_update_user(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome Back")
        |> put_session(:user_id, user.id) # sessions are encrypted by default in `phoenix` so don't sweat it dude!
        |> redirect(to: topic_path(conn, :index))
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error signing in")
        |> redirect(to: topic_path(conn, :index))
    end
  end

  # defp = private module
  # it is not accessible by any other module in my application
  # even if I import or alias into another module.
  defp insert_or_update_user(changeset) do
    # returns the user or nil
    case Repo.get_by(User, email: changeset.changes.email) do
      nil -> Repo.insert(changeset)
      user -> {:ok, user }
    end
  end
end