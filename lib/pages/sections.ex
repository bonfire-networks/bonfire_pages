defmodule Bonfire.Pages.Sections do
  use Bonfire.Common.Utils
  use Bonfire.Common.Repo

  alias Bonfire.Pages.Section

  def query(filters, _opts \\ []) do
    Section
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

  def upsert(options \\ []) do
    Bonfire.Pages.run_epic(:upsert, options ++ [do_not_strip_html: true], __MODULE__, :section)
  end

  def put_in_page(section_id, page_id, position \\ nil) do
    cs =
      Bonfire.Data.Assort.Ranked.changeset(%{
        item_id: section_id,
        scope_id: page_id,
        rank_set: position
      })
      |> Ecto.Changeset.unique_constraint([:item_id, :scope_id],
        name: :bonfire_data_ranked_unique_per_scope
      )
      |> dump()

    with {:ok, update} <- Bonfire.Common.Repo.insert(cs) do
      {:ok, update}
    else
      # poor man's upsert
      %Ecto.Changeset{valid?: false} -> Bonfire.Common.Repo.update(cs)
      e -> error(e)
    end
  end

  # defp upsert_attempt(cs, position) do
  #   cs
  #   |> Bonfire.Common.Repo.upsert([rank: e(cs, :changes, :rank_set, nil) || position], [
  #     :item_id,
  #     :scope_id
  #   ])
  # end

  def remove_from_page(section_id, page_id) do
    query =
      from(p in Bonfire.Data.Assort.Ranked,
        where:
          p.item_id == ^section_id and
            p.scope_id == ^page_id
      )

    with {1, update} <- Bonfire.Common.Repo.delete_all(query) do
      {:ok, update}
    end
  end
end
