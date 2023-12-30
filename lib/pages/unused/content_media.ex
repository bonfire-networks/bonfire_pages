# defmodule Bonfire.Pages.Media do
#   use Needle.Mixin,
#     otp_app: :bonfire_pages,
#     source: "bonfire_pages_media"

#   alias __MODULE__
#   alias Needle.Changesets

#   mixin_schema do
#     field(:url, :string)
#     field(:media_type, :string)
#     field(:metadata, :string)
#   end

#   def changeset(content_media \\ %Media{}, attrs, opts \\ []),
#     do: Changesets.auto(content_media, attrs, opts, [])
# end

# defmodule Bonfire.Pages.Media.Migration do
#   use Ecto.Migration
#   import Needle.Migration
#   alias Bonfire.Pages.Media

#   def migrate_content_media(dir \\ direction())

#   def migrate_content_media(:up) do
#     create_mixin_table(Media) do
#       add(:url, :text)
#       add(:media_type, :text)
#       add(:metadata, :text)
#     end
#   end

#   def migrate_content_media(:down) do
#     drop_mixin_table(Media)
#   end
# end
