defmodule Bonfire.Data.ContentText do
  use Pointers.Mixin,
    otp_app: :bonfire_data_content,
    source: "bonfire_data_content_text"

  alias __MODULE__
  alias Pointers.Changesets

  mixin_schema do
    field :markdown, :string
    field :html, :string
  end

  def changeset(content_text \\ %ContentText{}, attrs, opts \\ []),
    do: Changesets.auto(content_text, attrs, opts, [])
end

defmodule Bonfire.Data.ContentText.Migration do
  use Ecto.Migration
  import Pointers.Migration
  alias Bonfire.Data.ContentText

  def migrate_content_text(dir \\ direction())

  def migrate_content_text(:up) do
    create_mixin_table(ContentText) do
      add :markdown, :text
      add :html, :text
    end
  end

  def migrate_content_text(:down) do
    drop_mixin_table(ContentText)
  end
end
