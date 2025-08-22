defmodule App.Videos.Video do
  use Ecto.Schema
  import Ecto.Changeset

  schema "videos" do
    field :url, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:url])
    |> validate_required([:url])
  end
end
