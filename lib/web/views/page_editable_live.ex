defmodule Bonfire.Pages.Web.PageEditableLive do
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

  defp mounted(params, _session, socket) do
    {:ok,
     assign(
       socket,
       page: "edit_page",
       page_title: l("Edit Page"),
       create_object_type: :section,
       smart_input_prompt: l("Add a section"),
       context_id: e(params, "id", nil),
       object: nil,
       without_sidebar: true,
       hide_smart_input: true,
       without_header: true
     )}
  end

  def do_handle_params(%{"id" => id} = params, _url, socket) do
    # TODO: query pointer instead to support non-Page pages? Bonfire.Common.Pointers.one(id: id)
    with {:ok, object} <-
           Bonfire.Pages.get(id)
           |> debug()
           |> repo().maybe_preload(ranked: [item: [:post_content]])
           |> debug() do
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

  def handle_params(params, uri, socket) do
    # poor man's hook I guess
    with {_, socket} <-
           Bonfire.UI.Common.LiveHandlers.handle_params(params, uri, socket) do
      undead_params(socket, fn ->
        do_handle_params(params, uri, socket)
      end)
    end
  end

  def handle_event(
        "dropped",
        %{
          "dragged_id" => "section:" <> dragged_id,
          "dropped_index" => dropped_index
        } = params,
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

  def handle_event(
        "dropped",
        %{
          "dragged_id" => "section:" <> dragged_id,
          # "dragged_from_id" => previous_bin,
          # "dropped_to_id" => new_bin,
          "dropped_index" => dropped_index
        } = params,
        socket
      ) do
    debug(dragged_id: dragged_id)
    # debug(previous_bin: previous_bin)
    # debug(new_bin: new_bin)
    debug(dropped_index: dropped_index)

    # TODO: for add/removing sections to the page

    # add the bin as a tag (and remove the previous one)
    # if previous_bin != new_bin do
    #   existing_tags = e(socket.assigns, :all_cards, dragged_id, :tags, [])

    #   new_tags =
    #     [e(socket.assigns, :task_tag_id, nil), new_bin] ++
    #       Enum.reject(existing_tags, &(&1.id == previous_bin))

    #   # debug(new_tags, "new_tags")
    #   # ValueFlows.Util.try_tag_thing(current_user_required(socket), dragged_id, new_tags)
    # end

    # save the order
    Bonfire.Pages.Sections.put_in_page(
      dragged_id,
      e(socket.assigns, :object, :id, nil),
      dropped_index
    )

    {:noreply, socket}
  end

  def handle_event(action, attrs, socket),
    do:
      Bonfire.UI.Common.LiveHandlers.handle_event(
        action,
        attrs,
        socket,
        __MODULE__
      )

  def handle_info(info, socket),
    do: Bonfire.UI.Common.LiveHandlers.handle_info(info, socket, __MODULE__)
end
