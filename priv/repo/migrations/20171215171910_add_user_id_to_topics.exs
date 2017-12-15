defmodule Discuss.Repo.Migrations.AddUserIdToTopics do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      # add a user_id to "topics" with
      # user_id being a reference to the
      # "users" table
      add :user_id, references(:users)
    end
  end
end
