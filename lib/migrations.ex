defmodule Bonfire.Pages.Migrations do
  @moduledoc false
  use Ecto.Migration
  # import Needle.Migration

  def ms(:up) do
    quote do
      require Bonfire.Pages.Section.Migration
      require Bonfire.Pages.Page.Migration

      Bonfire.Pages.Section.Migration.migrate_section()
      Bonfire.Pages.Page.Migration.migrate_page()
    end
  end

  def ms(:down) do
    quote do
      require Bonfire.Pages.Page.Migration
      require Bonfire.Pages.Section.Migration

      Bonfire.Pages.Page.Migration.migrate_page()
      Bonfire.Pages.Section.Migration.migrate_section()
    end
  end

  defmacro migrate_pages() do
    quote do
      if Ecto.Migration.direction() == :up,
        do: unquote(ms(:up)),
        else: unquote(ms(:down))
    end
  end

  defmacro migrate_pages(dir), do: ms(dir)
end
