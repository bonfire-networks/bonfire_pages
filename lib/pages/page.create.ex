defmodule Bonfire.Pages.Acts.Page.Create do
  @moduledoc """
  Creates a changeset for publishing a page

  Epic Options:
    * `:current_user` - user that will create the page, required.
    * `:page_attrs` (configurable) - attrs to create the page from, required.
    * `:page_id` (configurable) - id to use for the created page (handy for creating
      activitypub objects with an id representing their reported creation time)

  Act Options:
    * `:id` - epic options key to find an id to force override with at, default: `:page_id`
    * `:as` - key to assign changeset to, default: `:page`.
    * `:attrs` - epic options key to find the attributes at, default: `:page_attrs`.
  """

  alias Bonfire.Ecto.Acts.Work
  # alias Bonfire.Epics.Act
  alias Bonfire.Epics.Epic
  alias Bonfire.Pages.Page

  alias Ecto.Changeset
  use Arrows
  import Bonfire.Epics
  # import Untangle

  # see module documentation
  @doc false
  def run(epic, act) do
    current_user = epic.assigns[:options][:current_user]

    cond do
      epic.errors != [] ->
        maybe_debug(
          epic,
          act,
          length(epic.errors),
          "Skipping due to epic errors"
        )

        epic

      not (is_struct(current_user) or is_binary(current_user)) ->
        maybe_debug(
          epic,
          act,
          current_user,
          "Skipping due to missing current_user"
        )

        epic

      true ->
        as = Keyword.get(act.options, :as) || Keyword.get(act.options, :on, :page)
        attrs_key = Keyword.get(act.options, :attrs, :page_attrs)

        id_key = Keyword.get(act.options, :id, :page_id)
        id = epic.assigns[:options][id_key]

        attrs = Keyword.get(epic.assigns[:options], attrs_key, %{})
        _boundary = epic.assigns[:options][:boundary]

        maybe_debug(
          epic,
          act,
          attrs_key,
          "Assigning changeset to :#{as} using attrs"
        )

        # maybe_debug(epic, act, attrs, "Post attrs")
        if attrs == %{}, do: maybe_debug(act, attrs, "empty attrs")

        Page.changeset(attrs)
        |> Map.put(:action, :insert)
        |> maybe_overwrite_id(id)
        |> Epic.assign(epic, as, ...)
        |> Work.add(:page)
    end
  end

  defp maybe_overwrite_id(changeset, nil), do: changeset

  defp maybe_overwrite_id(changeset, id),
    do: Changeset.put_change(changeset, :id, id)
end
