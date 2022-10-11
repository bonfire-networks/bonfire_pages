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

  defp mounted(params, _session, socket) do
    {:ok,
     assign(
       socket,
       page: "edit_page",
       page_title: l("Edit Page"),
       create_object_type: :section,
       smart_input_prompt: l("Add a section"),
       context_id: e(params, "id", nil),
       object: nil
     )}
  end
end
