defmodule Bonfire.Pages.Web.PageLive do
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(%{"id" => id}, _session, socket) do
    # TODO: query pointer instead to support non-Page pages? Bonfire.Common.Needles.one(id: id)
    with {:ok, object} <-
           Bonfire.Pages.get(uid!(id))
           #  |> debug()
           |> repo().maybe_preload(ranked: [item: [:post_content]]) do
      {:ok,
       assign(
         socket,
         page: "page",
         without_secondary_widgets: true,
         without_sidebar: true,
         page_title: e(object, :post_content, :name, nil) || l("Page"),
         context_id: id,
         object: object,
         smart_input_opts: %{inline_only: true},
         nav_header: Bonfire.Pages.Web.PagesHeaderLive
       )
       |> SEO.assign(object)}
    end
  end
end
