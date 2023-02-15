defmodule Bonfire.Pages.Acts.Section.Upsert do
  @moduledoc """
  Creates a changeset for publishing a section

  Epic Options:
    * `:current_user` - user that will create the section, required.
    * `:section_attrs` (configurable) - attrs to create the section from, required.
    * `:section_id` (configurable) - id to use for the created section (handy for creating
      activitypub objects with an id representing their reported creation time)

  Act Options:
    * `:id` - epic options key to find an id to force override with at, default: `:section_id`
    * `:as` - key to assign changeset to, default: `:section`.
    * `:attrs` - epic options key to find the attributes at, default: `:section_attrs`.
  """

  alias Bonfire.Ecto.Acts.Work
  # alias Bonfire.Epics.Act
  alias Bonfire.Epics.Epic
  alias Bonfire.Pages.Section

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
        as = Keyword.get(act.options, :as) || Keyword.get(act.options, :on, :section)
        attrs_key = Keyword.get(act.options, :attrs, :section_attrs)

        id_key = Keyword.get(act.options, :id, :section_id)
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

        section =
          with _ when is_binary(id) <- true,
               {:ok, section} <- Bonfire.Pages.Sections.get(id) do
            section
          else
            _ ->
              %Section{}
          end

        Section.changeset(section, attrs)
        |> Map.put(:action, :upsert)
        |> maybe_overwrite_id(id)
        |> Epic.assign(epic, as, ...)
        |> Work.add(:section)
    end
  end

  defp maybe_overwrite_id(changeset, nil) do
    changeset
    |> Map.put(:action, :insert)
  end

  defp maybe_overwrite_id(changeset, id),
    do: Changeset.put_change(changeset, :id, id)
end
