defmodule Bonfire.Data.ContentMedia do
  use Pointers.Mixin,
    otp_app: :bonfire_data_content,
    source: "bonfire_data_content_media"

  alias __MODULE__
  alias Pointers.Changesets

  mixin_schema do
    field(:url, :string)
    field(:media_type, :string)
    field(:metadata, :string)
  end

  def changeset(content_media \\ %ContentMedia{}, attrs, opts \\ []),
    do: Changesets.auto(content_media, attrs, opts, [])
end

defmodule Bonfire.Data.ContentMedia.Migration do
  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.ContentMedia

  def migrate_content_media(dir \\ direction())

  def migrate_content_media(:up) do
    create_mixin_table(ContentMedia) do
      add(:url, :text)
      add(:media_type, :text)
      add(:metadata, :text)
    end
  end

  def migrate_content_media(:down) do
    drop_mixin_table(ContentMedia)
  end
end
