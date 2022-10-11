defmodule Bonfire.Pages.Web.PagesLive do
  use Bonfire.UI.Common.Web, :surface_live_view
  alias Bonfire.UI.Me.LivePlugs

  declare_extension("Pages",
    icon: "iconoir:multiple-pages-empty"
  )

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

  defp mounted(params, _session, socket) do
    {:ok,
     assign(
       socket,
       page: "pages",
       page_title: l("Pages"),
       create_object_type: :page,
       smart_input_prompt: l("Create a page"),
       pages: Bonfire.Pages.list_paginated() |> debug("lpages")
     )}
  end
end
