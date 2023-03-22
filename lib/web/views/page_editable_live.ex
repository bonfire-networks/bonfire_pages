defmodule Bonfire.Pages.Web.PageEditableLive do
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(params, _session, socket) do
    {:ok,
     assign(
       socket,
       page: "edit_page",
       page_title: l("Edit Page"),
       create_object_type: :section,
       smart_input_opts: %{inline_only: true, prompt: l("Add a section")},
       context_id: e(params, "id", nil),
       object: nil,
       without_sidebar: true,
       nav_header: Bonfire.Pages.Web.PagesHeaderLive
     )}
  end

  def do_handle_params(%{"id" => id} = params, _url, socket) do
    # TODO: query pointer instead to support non-Page pages? Bonfire.Common.Pointers.one(id: id)
    with {:ok, object} <-
           Bonfire.Pages.get(id)
           |> repo().maybe_preload(ranked: [item: [:post_content]]) do
      {:noreply,
       assign(
         socket,
         context_id: id,
         object: object,
         page_title: e(object, :post_content, :name, nil) || l("Edit Page"),
         reload: e(params, "reload", nil)
       )}
    end
  end

  def handle_params(params, uri, socket),
    do:
      Bonfire.UI.Common.LiveHandlers.handle_params(
        params,
        uri,
        socket,
        __MODULE__,
        &do_handle_params/3
      )

  def do_handle_event(
        "dropped",
        %{
          "dragged_id" => "section:" <> dragged_id,
          "dropped_index" => dropped_index
        } = _params,
        socket
      ) do
    debug(dragged_id: dragged_id)
    debug(dropped_index: dropped_index)

    # implementation for bin ordering
    Bonfire.Pages.Sections.put_in_page(
      dragged_id,
      e(socket.assigns, :object, :id, nil),
      dropped_index
    )

    {:noreply, socket}
  end

  # def do_handle_event(
  #       "dropped",
  #       %{
  #         "dragged_id" => "section:" <> dragged_id,
  #         "dragged_from_id" => previous_bin,
  #         "dropped_to_id" => new_bin,
  #         "dropped_index" => dropped_index
  #       } = params,
  #       socket
  #     ) do
  #   debug(dragged_id: dragged_id)
  #   # debug(previous_bin: previous_bin)
  #   # debug(new_bin: new_bin)
  #   debug(dropped_index: dropped_index)

  #   # TODO: for add/removing sections to the page by dragging

  #   # save the order
  #   Bonfire.Pages.Sections.put_in_page(
  #     dragged_id,
  #     e(socket.assigns, :object, :id, nil),
  #     dropped_index
  #   )

  #   {:noreply, socket}
  # end

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

  def handle_info(info, socket),
    do: Bonfire.UI.Common.LiveHandlers.handle_info(info, socket, __MODULE__)
end
