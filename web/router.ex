defmodule Discuss.Router do
  use Discuss.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Discuss do
    pipe_through :browser # Use the default browser stack

    # get "/", TopicController, :index
    # get "/topics/new", TopicController, :new
    # get "/topics/:id/edit", TopicController, :edit
    # post "/topics", TopicController, :create
    # put "/topics/:id", TopicController, :update
    # delete "/topics/:id", TopicController, :delete

    # "resources" - this will only work if I follow REST conventions to a "t"
    # because of the way we set things up to start at "/"
    # by using this helper "/topics/" will be stripped away from the url
    # i.e. traveling to the edit form will result in a url of
    # localhost:4000/edit
    # Should I say "/topics" on resources goint to
    # the "get" "/" will yield an error because REST conventions are not correct.
    # because we used "topic_path" changing the routing here does not effect the
    # links in the application
    # NOTE when using "resources" I no longer have control over wildcards
    # `phoenix` will assume that I mean :id === %{"id" => topic_id}
    resources "/", TopicController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Discuss do
  #   pipe_through :api
  # end
end
