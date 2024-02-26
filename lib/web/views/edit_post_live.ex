defmodule Bonfire.Pages.Web.EditPostLive do
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(_params, _session, socket) do
    {:ok,
     assign(
       socket,
       without_secondary_widgets: true,
       smart_input_opts: %{inline_only: true},
       page: "edit_post",
       page_title: l("Edit Post")
     )}
  end
end
