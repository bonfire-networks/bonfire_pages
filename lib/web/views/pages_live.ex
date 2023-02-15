defmodule Bonfire.Pages.Web.PagesLive do
  use Bonfire.UI.Common.Web, :surface_live_view
  alias Bonfire.UI.Me.LivePlugs

  declare_extension("Pages",
    icon: "noto:bookmark-tabs"
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
       selected_tab: e(params, "tab", :list),
       page_title: l("Pages"),
       create_object_type: :page,
       smart_input_opts: %{wysiwyg: false, prompt: l("Create a page")},
       pages: nil
     )}
  end

  def do_handle_params(%{"tab" => "nav"} = _params, _uri, socket) do
    {:noreply,
     assign(
       socket,
       selected_tab: :nav,
       pages:
         Bonfire.Social.Pins.list_instance_pins(
           object_type: [Bonfire.Pages.Page],
           current_user: current_user(socket)
         )
        #  |> debug("lnav")
     )}
  end

  def do_handle_params(_params, _uri, socket) do
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

  def do_handle_event(
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

  def handle_params(params, uri, socket),
    do:
      Bonfire.UI.Common.LiveHandlers.handle_params(
        params,
        uri,
        socket,
        __MODULE__
      )

  def handle_info(info, socket),
    do: Bonfire.UI.Common.LiveHandlers.handle_info(info, socket, __MODULE__)

  def handle_event(
        action,
        attrs,
        socket
      ),
      do:
        Bonfire.UI.Common.LiveHandlers.handle_event(
          action,
          attrs,
          socket,
          __MODULE__,
          &do_handle_event/3
        )
end
