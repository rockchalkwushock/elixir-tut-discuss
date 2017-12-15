defmodule Discuss.TopicController do
  use Discuss.Web, :controller

  alias Discuss.Topic

  plug Discuss.Plugs.RequireAuth when action in [:new, :create, :edit, :update, :delete]
  plug :check_topic_owner when action in [:update, :edit, :delete]

  def index(conn, _params) do
    topics = Repo.all(Topic) # tells Ecto grab 'all' from tabel 'topics'
    render conn, "index.html", topics: topics
  end

  def create(conn, %{"topic" => topic}) do
    #
    changeset = conn.assigns.user
      |> build_assoc(:topics)
      |> Topic.changeset(topic)

    case Repo.insert(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Created") # how to display message one time to the user.
        |> redirect(to: topic_path(conn, :index)) # redirect to the topic_path & call the :index function
      {:error, changeset} ->
        render conn, "new.html", changeset: changeset
    end

    # SUCCESS
    # [info] Sent 200 in 396µs
    # [info] POST /topics
    # [debug] Processing by Discuss.TopicController.create/2
    #   Parameters: %{"_csrf_token" => "NWM2Ow4fEQMvHnUrNCYUYQUNLUkLAAAAT3EwmUhEEZ7rApC+hkJxMQ==", "_utf8" => "✓", "topic" => %{"title" => "hello"}}
    #   Pipelines: [:browser]
    # [debug] QUERY OK db=421.6ms
    # INSERT INTO "topics" ("title") VALUES ($1) RETURNING "id" ["hello"]
    # %Discuss.Topic{__meta__: #Ecto.Schema.Metadata<:loaded, "topics">, id: 1,
    # title: "hello"}
    # [info] Sent 500 in 458ms

    # ERROR
    # [info] POST /topics
    # [debug] Processing by Discuss.TopicController.create/2
    # Parameters: %{"_csrf_token" => "NWM2Ow4fEQMvHnUrNCYUYQUNLUkLAAAAT3EwmUhEEZ7rApC+hkJxMQ==", "_utf8" => "✓", "topic" => %{"title" => ""}}
    # Pipelines: [:browser]
    # #Ecto.Changeset<action: :insert, changes: %{},
    # errors: [title: {"can't be blank", [validation: :required]}],
    # data: #Discuss.Topic<>, valid?: false>
    # [info] Sent 500 in 7ms

    # %{"_csrf_token" => "SmA4Ig4FOhdBdhprITgxIQY3MkUTNgAA+0KnmOCQ+2X2TnfkkQUtUg==","_utf8" => "✓", "topic" => %{"title" => "asdf"}}
    # must utilize Pattern Matching to access "topic" => %{"title" => ""}
    # Example
    # iex(1)> params = %{"topic" => "asdf"}
    # iex(2)> %{"topic" => string} = params
    # iex(3)> string
    # "asdf"

    # mix phoenix.routes = all routes available in app
    # page_path   GET   /           Discuss.PageController :index
    # topic_path  GET   /topics/new Discuss.TopicController :new
    # topic_path  POST  /topics     Discuss.TopicController :create
  end

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{}, %{})
    # Remember this is really
    # render(conn, "new.html", [changeset: changeset])
    # third arg is a keyword list
    render conn, "new.html", changeset: changeset
  end

  def edit(conn, %{"id" => topic_id}) do
    topic = Repo.get(Topic, topic_id) # Go to the table "topics" & look for the given "id"
    changeset = Topic.changeset(topic)

    render conn, "edit.html", changeset: changeset, topic: topic
  end

  def update(conn, %{"id" => topic_id, "topic" => topic}) do
    old_topic = Repo.get(Topic, topic_id)
    changeset = Topic.changeset(old_topic, topic)
    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:info, "Topic Updated")
        |> redirect(to: topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "edit.html", changeset: changeset, topic: old_topic
    end
  end

  def delete(conn, %{"id" => topic_id}) do
    Repo.get!(Topic, topic_id) |> Repo.delete!

    conn
    |> put_flash(:info, "Topic Deleted")
    |> redirect(to: topic_path(conn, :index))
  end

  # this is a plug function so _params is not the params
  # that you think it is!
  def check_topic_owner(conn, _params) do
    %{params: %{"id" => topic_id}} = conn
    if Repo.get(Topic, topic_id).user_id == conn.assigns.user.id do
      conn
    else
      conn
      |> put_flash(:error, "You cannot edit that!")
      |> redirect(to: topic_path(conn, :index))
      |> halt()
    end
  end
end