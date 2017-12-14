defmodule Discuss.Repo.Migrations.AddTopics do
  use Ecto.Migration

  def change do
    # creates a tabel called topics
    # with two columns
    # 'id' is a default from postgres
    # 'title' that we expect to be a string
    create table(:topics) do
      add :title, :string
    end
  end
end
