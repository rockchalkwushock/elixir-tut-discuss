defmodule Discuss.Topic do
  use Discuss.Web, :model

  # required
  schema "topics" do
    field :title, :string
    belongs_to :user, Discuss.User
    has_many :comments, Discuss.Comment
  end

  # model level validation
  # struct - What the data is?
  # params - What the user wants it to be?
  # cast - produces a changeset
  # changeset - How we are going from what we have to what they want?
  # validator(s) - Check to see if the changeset is valid for what we say the data should look like.
  # Example of how this looks
  # iex(1)> struct = %Discuss.Topic{}
  # %Discuss.Topic{__meta__: #Ecto.Schema.Metadata<:built, "topics">, id: nil,
  # title: nil}
  # iex(2)> params = %{title: "Great JS"}
  # %{title: "Great JS"}
  # iex(3)> Discuss.Topic.changeset(struct, params)
  # #Ecto.Changeset<action: nil, changes: %{title: "Great JS"}, errors: [],
  # data: #Discuss.Topic<>, valid?: true>
  # iex(4)> Discuss.Topic.changeset(struct, %{})
  # #Ecto.Changeset<action: nil, changes: %{},
  # errors: [title: {"can't be blank", [validation: :required]}],
  # data: #Discuss.Topic<>, valid?: false>
  def changeset(struct, params \\ %{}) do # // %{} is setting a default param in Elixir, should we not present any params it will default to an empty map.
    struct
    |> cast(params, [:title])
    |> validate_required([:title])
  end
end