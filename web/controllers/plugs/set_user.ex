defmodule Discuss.Plugs.SetUser do
  import Plug.Conn
  import Phoenix.Controller

  alias Discuss.Repo
  alias Discuss.User
  # only runs once upon initialization
  # use this for any heavy computation or data fetching
  # it will run once and then supply whatever I have done
  # to call() as params everytime there after.
  def init(_params) do

  end
  # params is whatever is returned from init()
  def call(conn, _params) do
    user_id = get_session(conn, :user_id)

    # this is like an if block.
    # as soon as it hits a boolean that evaluates
    # as true it runs the corresponding code and
    # exits the block.
    cond do
      user = user_id && Repo.get(User, user_id) ->
        assign(conn, :user, user) # conn.assigns.user => user struct
      true ->
        assign(conn, :user, nil)
    end
  end
end