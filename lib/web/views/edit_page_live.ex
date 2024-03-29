defmodule Bonfire.Pages.Web.EditPageLive do
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(_params, _session, socket) do
    {:ok,
     assign(
       socket,
       without_secondary_widgets: true,
       page: "edit_page",
       page_title: l("Edit Page")
     )}
  end

  defp handle_params(%{"edit_section" => section_id} = params, _url, socket) do
    # debug(section_id)

    with {:ok, section} <- Bonfire.Pages.Sections.get(section_id, socket) do
      socket
    else
      _ ->
        socket
        |> assign_error(l("Could not find the section to edit"))
    end
    |> handle_params(Map.drop(params, ["edit_section"]), nil, ...)
  end

  defp handle_params(params, _url, socket) do
    id = e(params, "id", nil)
    # TODO: avoid querying twice? in EditPage and PageEditable
    object =
      with {:ok, object} <-
             Bonfire.Pages.get(id)
             |> repo().maybe_preload(ranked: [item: [:post_content]]) do
        object
      else
        _ ->
          raise Bonfire.Fail, :not_found
      end

    {:noreply,
     assign(
       socket,
       context_id: id,
       object: object,
       page_title: "#{l("Edit Page")}: #{e(object, :post_content, :name, nil)}",
       reload: e(params, "reload", nil)
     )}
  end
end
