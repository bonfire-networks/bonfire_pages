defmodule Bonfire.Pages.Page do
  use Pointers.Virtual,
    otp_app: :bonfire_pages,
    table_id: "4ASTAT1CPAGEMADE0FSECT10NS",
    source: "bonfire_pages_page"

  alias Bonfire.Pages.Page
  alias Pointers.Changesets

  virtual_schema do
  end

  def changeset(page \\ %Page{}, params), do: Changesets.cast(page, params, [])
end

defmodule Bonfire.Pages.Page.Migration do
  @moduledoc false
  import Pointers.Migration
  alias Bonfire.Pages.Page

  def migrate_page(), do: migrate_virtual(Page)
end
