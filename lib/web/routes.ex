defmodule Bonfire.Pages.Web.Routes do
  defmacro __using__(_) do
    quote do
      # pages anyone can view
      scope "/pages", Bonfire.Pages.Web do
        pipe_through(:browser)

        # live("/", PagesLive)
        live("/:id", PageLive, as: Bonfire.Pages.Page)
        live("/:id/#section-:section_id", PageLive, as: Bonfire.Pages.Section)
      end

      # pages you need an account to view
      scope "/pages", Bonfire.Pages.Web do
        pipe_through(:browser)
        pipe_through(:account_required)
        # live("/", PagesLive)

        live("/", PagesLive)
        live("/edit/:id", EditPageLive)
        live("/edit/:id/section/:section_id", EditPageLive)
      end

      # pages you need a user to view
      scope "/pages", Bonfire.Pages.Web do
        pipe_through(:browser)
        pipe_through(:user_required)
      end
    end
  end
end
