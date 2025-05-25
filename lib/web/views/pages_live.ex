defmodule Bonfire.Pages.Web.PagesLive do
  use Bonfire.UI.Common.Web, :surface_live_view

  declare_extension("Pages",
    icon: "dashicons:text-page",
    emoji: "📄",
    description: l("Create and edit simple webpages.")
  )

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(params, _session, socket) do
    {:ok,
     assign(
       socket,
       page: "pages",
       selected_tab: e(params, "tab", :list),
       page_title: l("Pages"),
       create_object_type: :page,
       smart_input_opts: %{wysiwyg: false, prompt: l("Create a page")},
       pages: nil
     )}
  end

  def handle_params(%{"tab" => "nav"} = _params, _uri, socket) do
    {:noreply,
     assign(
       socket,
       selected_tab: :nav,
       pages:
         Bonfire.Social.Pins.list_instance_pins(
           object_types: [Bonfire.Pages.Page],
           current_user: current_user(socket)
         )
       #  |> debug("lnav")
     )}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply,
     assign(
       socket,
       selected_tab: :list,
       pages:
         Bonfire.Pages.list_paginated()
         |> repo().maybe_preload(created: [creator: [:profile]])
         |> debug("lpages")
     )}
  end

  def handle_event(
        "dropped",
        %{
          "dragged_id" => dragged_id,
          "dropped_index" => dropped_index
        } = _params,
        socket
      ) do
    debug(dragged_id: dragged_id)
    debug(dropped_index: dropped_index)

    # TODO: user scope for non admins?
    scope = :instance

    # implementation for ordering
    Bonfire.Social.Pins.rank_pin(dragged_id, scope, dropped_index)

    {:noreply, socket}
  end
end
