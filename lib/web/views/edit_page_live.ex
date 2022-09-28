defmodule Bonfire.Pages.Web.EditPageLive do
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
    # available_sections = Bonfire.Pages.Sections.list_paginated() |> debug("lsections")

    # TODO: query pointer instead to support non-Page pages? Bonfire.Common.Pointers.one(id: id)
    with {:ok, object} <-
           Bonfire.Pages.get(id)
           |> debug()
           |> repo().maybe_preload(ranked: [item: [:post_content]])
           |> debug() do
      {:ok,
       assign(
         socket,
         page: "edit_page",
         page_title: l("Edit Page"),
         create_object_type: :section,
         smart_input_prompt: l("Create a section"),
         context_id: id,
         object: object
       )}
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
    Bonfire.Pages.Sections.put_section_in_page(
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
    Bonfire.Pages.Sections.put_section_in_page(
      dragged_id,
      e(socket.assigns, :object, :id, nil),
      dropped_index
    )

    {:noreply, socket}
  end
end
