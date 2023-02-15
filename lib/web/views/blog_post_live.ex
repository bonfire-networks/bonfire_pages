defmodule Bonfire.Pages.Web.BlogPostLive do
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
       without_widgets: true,
       # we include it directly instead
       smart_input_opts: %{inline_only: true},
       page: "blog_post",
       page_title: l("Post"),
       nav_header: Bonfire.Pages.Web.PagesHeaderLive,
       main_image: nil,
       media: nil
     )}
  end

  def do_handle_params(%{"id" => id} = params, url, socket) when is_binary(id) do
    debug(id)

    {:noreply,
     socket
     |> assign(
       post_id: id,
       url: url,
       reply_to_id: e(params, "reply_to_id", id)
     )
     |> Bonfire.Social.Objects.LiveHandler.load_object_assigns()
     |> prepare_media()}
  end

  def do_handle_params(_params, _url, socket) do
    {:noreply,
     socket
     |> redirect_to(path(:write))}
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

  def do_handle_event(action, attrs, socket),
    do: Bonfire.UI.Common.LiveHandlers.handle_event(action, attrs, socket, __MODULE__)

  def handle_info(info, socket),
    do: Bonfire.UI.Common.LiveHandlers.handle_info(info, socket, __MODULE__)

  def prepare_media(%{assigns: %{activity: %{media: media}} = _assigns} = socket)
      when is_list(media) do
    dump(media)

    {main_image, media} =
      filter_first(media, fn
        %{media_type: "image/" <> _} -> true
        _ -> false
      end)

    socket
    |> assign(
      main_image: main_image,
      media: media
    )
  end

  def prepare_media(socket), do: socket

  def filter_first(list, fun, acc \\ [])

  def filter_first([head | tail], fun, acc) do
    if fun.(head) do
      {head, Enum.reverse(acc) ++ tail}
    else
      filter_first(tail, fun, [head | acc])
    end
  end

  def filter_first([], _fun, acc) do
    {nil, Enum.reverse(acc)}
  end

  # def handle_params(params, uri, socket),
  #   do:
  #     Bonfire.UI.Common.LiveHandlers.handle_params(
  #       params,
  #       uri,
  #       socket,
  #       __MODULE__
  #     )

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

  # def handle_info(info, socket),
  #   do: Bonfire.UI.Common.LiveHandlers.handle_info(info, socket, __MODULE__)
end
