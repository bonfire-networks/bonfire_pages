defmodule Bonfire.Pages.Section do
  use Needle.Virtual,
    otp_app: :bonfire_pages,
    table_id: "3TAT1CC0NTENTSECT10N0NPAGE",
    source: "bonfire_pages_section"

  alias Bonfire.Pages.Section
  alias Needle.Changesets

  virtual_schema do
  end

  def changeset(section \\ %Section{}, params), do: Changesets.cast(section, params, [])
end

defmodule Bonfire.Pages.Section.Migration do
  @moduledoc false
  import Needle.Migration
  alias Bonfire.Pages.Section

  def migrate_section(), do: migrate_virtual(Section)
end
