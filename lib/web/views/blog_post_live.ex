defmodule Bonfire.Pages.Web.BlogPostLive do
  use Bonfire.UI.Common.Web, :surface_live_view

  on_mount {LivePlugs, [Bonfire.UI.Me.LivePlugs.LoadCurrentUser]}

  def mount(_params, _session, socket) do
    {:ok,
     assign(
       socket,
       without_secondary_widgets: true,
       # we include it directly instead
       smart_input_opts: %{inline_only: true},
       page: "blog_post",
       page_title: l("Post"),
       nav_header: Bonfire.Pages.Web.PagesHeaderLive,
       main_image: nil,
       media: nil
     )}
  end

  def handle_params(%{"id" => id} = params, url, socket) when is_binary(id) do
    debug(id)

    {:noreply,
     socket
     |> assign(
       post_id: id,
       url: url
       #  reply_to_id: e(params, "reply_to_id", id)
     )
     |> Bonfire.Social.Objects.LiveHandler.load_object_assigns()
     |> assign_new(
       :activity_component_id,
       "blog-" <> (Enums.id(@activity) || Enums.id(@object) || "no-id")
     )
     |> prepare_media()}
  end

  def handle_params(_params, _url, socket) do
    {:noreply,
     socket
     |> redirect_to(path(:write))}
  end

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
end
