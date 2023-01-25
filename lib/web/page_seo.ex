defimpl SEO.Build, for: Bonfire.Pages.Page do
  use SEO.Builder
  use Bonfire.UI.Common
  alias Bonfire.Pages

  def site(page, defaults) do
    SEO.Site.build(
      [
        title: e(page, :post_content, :title, nil),
        description: summary(page)
      ],
      defaults
    )
  end

  # def unfurl(_page) do
  #   SEO.Unfurl.build([])
  # end

  def twitter(page, defaults) do
    SEO.Twitter.build([creator: e(page, :created, :creator, nil)], defaults)
  end

  def open_graph(page, defaults) do
    SEO.OpenGraph.build(
      [
        title: e(page, :post_content, :title, nil),
        type_detail:
          SEO.OpenGraph.Article.build(
            published_time: DatesTimes.date_from_pointer(page),
            creator:
              e(page, :created, :creator, :profile, :name, nil) ||
                e(page, :created, :creator, :character, :username, nil),
            section: "Pages"
            # tag: page.tags
          ),
        # image: put_image(page),
        url: Pages.page_path(page),
        # locale: "en_US",
        type: :article,
        description: summary(page)
      ],
      defaults
    )
  end

  def breadcrumb_list(page, _) do
    SEO.Breadcrumb.List.build([
      [name: "Pages", item: "/pages"],
      [name: e(page, :post_content, :title, nil), item: Pages.page_path(page)]
    ])
  end

  defp summary(page) do
    dump(page)

    Text.truncate(
      Text.text_only(
        templated(
          e(page, :post_content, :summary, nil) || e(page, :post_content, :html_body, nil)
        )
        |> dump
      )
      |> dump,
      300
    )
    |> dump
  end

  # defp put_image(page) do
  #   file = "/images/blog/#{page.id}.png"

  #   exists? =
  #     [Application.app_dir(:my_app), "/priv/static", file]
  #     |> Path.join()
  #     |> File.exists?()

  #   if exists? do
  #     Routes.static_url(@endpoint, file), image_alt: page.title}
  #   else
  #     nil
  #   end
  # end
end
