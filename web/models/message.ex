defmodule HelloPhoenix.Message do
  use HelloPhoenix.Web, :model

  schema "messages" do
    field :message, :string

    belongs_to :user, HelloPhoenix.User

    timestamps
  end

  @required_fields ~w(message user_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def includes_user(query) do
    from q in query, preload: [:user]
  end

  def most_recent(query, limit) do
    from q in query, limit: ^limit, order_by: [desc: q.id]
  end
end
