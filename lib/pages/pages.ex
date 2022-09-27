defmodule Bonfire.Pages do
  use Bonfire.Common.Utils
  use Bonfire.Common.Repo

  alias Bonfire.Pages.Page
  alias Bonfire.Epics.Epic

  def create(options \\ []) do
    run_epic(:create, options)
  end

  def query(filters, _opts \\ []) do
    Page
    |> query_filter(filters)
    |> join_preload([:post_content])
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
    |> Bonfire.Common.Repo.many_paginated(opts[:paginate])
  end

  def run_epic(type, options, module \\ __MODULE__, on \\ :page) do
    options = Keyword.merge(options, crash: true, debug: true, verbose: false)

    epic =
      Epic.from_config!(module, type)
      |> Epic.assign(:options, options)
      |> Epic.run()

    if epic.errors == [], do: {:ok, epic.assigns[on]}, else: {:error, epic}
  end
end
