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

  defp mounted(_params, _session, socket) do
    {:ok,
     assign(
       socket,
       full_page: true,
       page: "edit_page",
       page_title: l("Edit Page"),
       create_object_type: :section,
       smart_input_prompt: l("Add a section")
     )}
  end

  defp do_handle_params(%{"edit_section" => section_id} = params, _url, socket) do
    debug(section_id)

    with {:ok, section} <- Bonfire.Pages.Sections.get(section_id, socket) do
      socket
      |> assign(
        create_object_type: :section,
        smart_input_prompt: l("Edit section"),
        smart_input_opts: [
          open: true,
          id: ulid(section),
          name: e(section, :post_content, :name, nil),
          text: e(section, :post_content, :html_body, nil)
        ]
      )
    else
      _ ->
        socket
        |> assign_error(l("Could not find the section to edit"))
    end
    |> do_handle_params(Map.drop(params, ["edit_section"]), nil, ...)
  end

  defp do_handle_params(params, _url, socket) do
    id = e(params, "id", nil)
    # TODO: avoid querying twice, in EditPage and PageEditable
    object =
      with {:ok, object} <-
             Bonfire.Pages.get(id)
             |> repo().maybe_preload(ranked: [item: [:post_content]]) do
        object
      else
        _ ->
          id
      end

    {:noreply,
     assign(
       socket,
       context_id: id,
       object: object,
       reload: e(params, "reload", nil)
     )}
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
