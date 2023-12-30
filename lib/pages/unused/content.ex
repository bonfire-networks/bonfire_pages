# defmodule Bonfire.Pages.Content do
#   use Needle.Mixin,
#     otp_app: :bonfire_pages,
#     source: "bonfire_pages"

#   alias __MODULE__
#   alias Needle.Changesets

#   mixin_schema do
#     field(:name, :string)
#     field(:summary, :string)
#   end

#   def changeset(content \\ %Content{}, attrs, opts \\ []),
#     do: Changesets.auto(content, attrs, opts, [])
# end

# defmodule Bonfire.Pages.Content.Migration do
#   use Ecto.Migration
#   import Needle.Migration
#   alias Bonfire.Pages.Content

#   def migrate_content(dir \\ direction())

#   def migrate_content(:up) do
#     create_mixin_table(Content) do
#       add(:name, :text)
#       add(:summary, :text)
#     end
#   end

#   def migrate_content(:down) do
#     drop_mixin_table(Content)
#   end
# end
