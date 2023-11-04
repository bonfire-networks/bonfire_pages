defimpl SEO.Site.Build, for: Bonfire.Pages.Page do
  use Bonfire.UI.Common
  alias Bonfire.Pages

  def build(page, conn) do
    SEO.Site.build(
      title: e(page, :post_content, :title, nil),
      description: Pages.summary(page)
    )
  end

  # def unfurl(_page) do
  #   SEO.Unfurl.build([])
  # end
end

defimpl SEO.Twitter.Build, for: Bonfire.Pages.Page do
  use Bonfire.UI.Common

  def build(page, conn) do
    SEO.Twitter.build(creator: e(page, :created, :creator, nil))
  end
end

defimpl SEO.OpenGraph.Build, for: Bonfire.Pages.Page do
  use Bonfire.UI.Common
  alias Bonfire.Pages

  def build(page, conn) do
    SEO.OpenGraph.build(
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
      description: Pages.summary(page)
    )
  end
end

defimpl SEO.Breadcrumb.Build, for: Bonfire.Pages.Page do
  use Bonfire.UI.Common
  alias Bonfire.Pages

  def build(page, _) do
    SEO.Breadcrumb.List.build([
      [name: "Pages", item: "/pages"],
      [name: e(page, :post_content, :title, nil), item: Pages.page_path(page)]
    ])
  end
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
