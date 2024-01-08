defmodule Bonfire.Pages do
  use Bonfire.UI.Common
  use Bonfire.Common.Repo

  alias Bonfire.Pages.Page
  alias Bonfire.Epics.Epic

  def page_path(page, opts \\ [])

  def page_path(%{post_content: %{id: _} = post_content} = _page, opts) do
    page_path(post_content, opts)
  end

  def page_path(%{id: id, name: title} = _post_content, _opts) do
    "/#{slug(title)}/page-#{id}"
  end

  def page_path(%{id: id, post_content: _} = page, opts) do
    page
    |> repo().maybe_preload(:post_content)
    |> e(:post_content, %{id: id})
    |> page_path(opts)
  end

  def page_path(id, opts) when is_binary(id) do
    with {:ok, _page} <- get(id, opts) do
      page_path(opts)
    else
      _ ->
        page_path(%{id: id}, opts)
    end
  end

  # fallback
  def page_path(%{id: id}, _opts) do
    "/pages/#{id}"
  end

  def slug(title) when is_binary(title) do
    SimpleSlug.slugify(title, lowercase?: false, truncate: 30)
  end

  def slug(_), do: "-"

  def summary(page) do
    # dump(page)

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

  def create(options \\ []) do
    # TODO: sanitise HTML to a certain extent depending on is_admin and/or boundaries
    run_epic(:create, options ++ [do_not_strip_html: true])
  end

  def query(filters, _opts \\ []) do
    Page
    |> query_filter(filters)
    |> proload([:post_content])
  end

  def one(filters, opts \\ []) do
    query(filters, opts)
    |> repo().single()
  end

  def get(id, opts \\ []) do
    if is_ulid?(id), do: one([id: id], opts)
  end

  def list_paginated(filters \\ [], opts \\ []) do
    query(filters, opts)
    # return a page of items (reverse chronological) + pagination metadata
    |> repo().many_paginated(opts[:paginate])
  end

  def run_epic(type, options, module \\ __MODULE__, on \\ :page) do
    options = Keyword.merge(options, crash: false, debug: true, verbose: false)

    epic =
      Epic.from_config!(module, type)
      |> Epic.assign(:options, options)
      |> Epic.run()

    if epic.errors == [], do: {:ok, epic.assigns[on]}, else: {:error, epic}
  end
end
