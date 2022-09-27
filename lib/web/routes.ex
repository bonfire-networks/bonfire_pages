defmodule Bonfire.Pages.Web.Routes do
  defmacro __using__(_) do
    quote do
      # pages anyone can view
      scope "/pages", Bonfire.Pages.Web do
        pipe_through(:browser)
      end

      # pages you need an account to view
      scope "/pages", Bonfire.Pages.Web do
        pipe_through(:browser)
        pipe_through(:account_required)
        # live("/", PagesLive)

        live("/edit/:id", EditPageLive, as: Bonfire.Pages.Page)
        live("/edit/:id/section/:section_id", EditPageLive)
      end

      # pages anyone can view
      scope "/pages", Bonfire.Pages.Web do
        pipe_through(:browser)
        pipe_through(:user_required)
        live("/", PagesLive)
      end

      # pages anyone can view
      scope "/", Bonfire.Pages.Web do
        pipe_through(:browser)
        pipe_through(:user_required)
        # live("/", PagesLive)
        # live("/:id", PageLive)
        # live("/:id/section/:section_id", PageLive)
      end
    end
  end
end
