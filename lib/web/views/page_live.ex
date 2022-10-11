defmodule Bonfire.Pages.Web.PageLive do
  use Bonfire.UI.Common.Web, :surface_live_view
  alias Bonfire.UI.Me.LivePlugs

  def mount(params, session, socket) do
    live_plug(params, session, socket, [
      LivePlugs.LoadCurrentAccount,
      LivePlugs.LoadCurrentUser,
      # LivePlugs.LoadCurrentUserCircles,
      Bonfire.UI.Common.LivePlugs.StaticChanged,
      Bonfire.UI.Common.LivePlugs.Csrf,
      Bonfire.UI.Common.LivePlugs.Locale,
      &mounted/3
    ])
  end

  defp mounted(%{"id" => id}, _session, socket) do
    # TODO: query pointer instead to support non-Page pages? Bonfire.Common.Pointers.one(id: id)
    with {:ok, object} <-
           Bonfire.Pages.get(id)
           |> debug()
           |> repo().maybe_preload(ranked: [item: [:post_content]])
           |> debug() do
      {:ok,
       assign(
         socket,
         page: "page",
         page_title: l("Page"),
         context_id: id,
         object: object,
         without_sidebar: true,
         hide_smart_input: true,
         without_header: true
       )}
    end
  end
end
