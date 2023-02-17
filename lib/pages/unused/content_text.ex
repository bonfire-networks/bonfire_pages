# defmodule Bonfire.Pages.Text do
#   use Pointers.Mixin,
#     otp_app: :bonfire_pages,
#     source: "bonfire_pages_text"

#   alias __MODULE__
#   alias Pointers.Changesets

#   mixin_schema do
#     field(:markdown, :string)
#     field(:html, :string)
#   end

#   def changeset(content_text \\ %Text{}, attrs, opts \\ []),
#     do: Changesets.auto(content_text, attrs, opts, [])
# end

# defmodule Bonfire.Pages.Text.Migration do
#   use Ecto.Migration
#   import Pointers.Migration
#   alias Bonfire.Pages.Text

#   def migrate_content_text(dir \\ direction())

#   def migrate_content_text(:up) do
#     create_mixin_table(Text) do
#       add(:markdown, :text)
#       add(:html, :text)
#     end
#   end

#   def migrate_content_text(:down) do
#     drop_mixin_table(Text)
#   end
# end
