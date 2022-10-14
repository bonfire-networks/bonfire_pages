defmodule Bonfire.Pages.Web.Routes do
  defmacro __using__(_) do
    quote do
      # URL alias with slug
      scope "/", Bonfire.Pages.Web do
        pipe_through(:browser)

        live("/:slug/page-:id", PageLive, as: Bonfire.Pages.Page)
        live("/:slug/page-:id/#section-:section_id", PageLive, as: Bonfire.Pages.Section)

        live("/:slug/post-:id", BlogPostLive, as: :blog_post)
      end

      # pages you need an account to view
      scope "/pages", Bonfire.Pages.Web do
        pipe_through(:browser)
        pipe_through(:account_required)
        # live("/", PagesLive)

        live("/", PagesLive)

        live("/edit/:id", EditPageLive)

        live("/editable/:id", PageEditableLive)
        live("/editable/:id/#section-:section_id", PageEditableLive)
      end

      # pages you need a user to view
      scope "/pages", Bonfire.Pages.Web do
        pipe_through(:browser)
        pipe_through(:user_required)

        live("/blog", BlogPostLive)
        live("/post/edit", EditPostLive)
      end

      # pages anyone can view
      scope "/pages", Bonfire.Pages.Web do
        pipe_through(:browser)

        # live("/", PagesLive)
        live("/:id", PageLive, as: Bonfire.Pages.Page)
        live("/:id/#section-:section_id", PageLive, as: Bonfire.Pages.Section)
      end
    end
  end
end
