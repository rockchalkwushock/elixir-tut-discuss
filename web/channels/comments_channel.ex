defmodule Discuss.CommentsChannel do
  use Discuss.Web, :channel

  # how to alias multiple modules from the same parent
  alias Discuss.{Topic, Comment}

  # <> in Elixir is like pattern matching for strings
  # literally the everything after : is piped into the
  # topic_id variable.
  def join("comments:" <> topic_id, _params, socket) do
    # When user joins the channel take the topic_id
    # 1. turn it to an integer
    topic_id = String.to_integer(topic_id)
    # 2. fetch the related topic from the database
    # then preload all the given comments for this
    # topic.
    topic = Topic
      |> Repo.get(topic_id)
      |> Repo.preload(comments: [:user])
    # 3. return tuple with success message, map, & socket with topic
    {:ok, %{comments: topic.comments}, assign(socket, :topic, topic)}
  end

  def handle_in(name, %{"content" => content}, socket) do
    topic = socket.assigns.topic
    user_id = socket.assigns.user_id
    changeset = topic
      |>build_assoc(:comments, user_id: user_id)
      |>Comment.changeset(%{content: content})

    case Repo.insert(changeset) do
      {:ok, comment} ->
        # should be 100% succesful
        # if it fails it will log server-side
        # NOT send out an error to all active users.
        broadcast!(socket, "comments:#{socket.assigns.topic.id}:new", %{comment: comment})
        {:reply, :ok, socket}
      {:error, _reason} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end
end