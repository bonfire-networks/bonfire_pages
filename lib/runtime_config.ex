defmodule Bonfire.Pages.RuntimeConfig do
  @behaviour Bonfire.Common.ConfigModule
  def config_module, do: true

  alias Bonfire.Ecto.Acts, as: Ecto

  alias Bonfire.Social.Acts.Activity
  alias Bonfire.Social.Acts.ActivityPub
  alias Bonfire.Social.Acts.Boundaries
  alias Bonfire.Social.Acts.Caretaker
  alias Bonfire.Social.Acts.Creator
  alias Bonfire.Social.Acts.Edges
  alias Bonfire.Social.Acts.Files
  alias Bonfire.Social.Acts.LivePush
  alias Bonfire.Social.Acts.MeiliSearch
  alias Bonfire.Social.Acts.Objects
  alias Bonfire.Social.Acts.PostContents
  alias Bonfire.Social.Acts.Tags
  alias Bonfire.Social.Acts.Threaded
  alias Bonfire.Social.Acts.URLPreviews

  @page_act_opts [on: :page, attrs: :page_attrs]
  @section_act_opts [on: :section, attrs: :section_attrs]

  @doc """
  NOTE: you can override this default config in your app's runtime.exs, by placing similarly-named config keys below the `Bonfire.Common.Config.LoadExtensionsConfig.load_configs` line
  """
  def config do
    import Config

    config :bonfire_pages,
      disabled: false

    config :bonfire_pages, Bonfire.Pages,
      epics: [
        create: [
          # Prep: a little bit of querying and a lot of preparing changesets
          # Create a changeset for insertion
          {Bonfire.Pages.Acts.Page.Create, @page_act_opts},
          # with a sanitised body and tags extracted,
          {PostContents, @page_act_opts},
          # a caretaker,
          {Caretaker, @page_act_opts},
          # and a creator,
          {Creator, @page_act_opts},
          # and possibly fetch contents of URLs,
          {URLPreviews, @page_act_opts},
          # possibly with uploaded files,
          {Files, @page_act_opts},
          # with extracted tags fully hooked up,
          {Tags, @page_act_opts},
          # and the appropriate boundaries established,
          {Boundaries, @page_act_opts},
          # summarised by an activity?
          # {Activity, @page_act_opts},
          # {Feeds,       @page_act_opts}, # appearing in feeds?

          # Now we have a short critical section
          Ecto.Begin,
          # Run our inserts
          Ecto.Work,
          Ecto.Commit,

          # These things are free to happen casually in the background.
          # Publish live feed updates via (in-memory) pubsub?
          # {LivePush, @page_act_opts},
          # Enqueue for indexing by meilisearch
          {MeiliSearch.Queue, @page_act_opts}

          # Oban would rather we put these here than in the transaction
          # above because it knows better than us, obviously.
          # Prepare for federation and do the queue insert (oban).
          # {ActivityPub, @page_act_opts},

          # Once the activity/object exists, we can apply side effects
          # {Bonfire.Social.Acts.CategoriesAutoBoost, @page_act_opts}
        ]
      ]

    config :bonfire_pages, Bonfire.Pages.Sections,
      epics: [
        upsert: [
          # Prep: a little bit of querying and a lot of preparing changesets
          # Create a changeset for insertion
          {Bonfire.Pages.Acts.Section.Upsert, @section_act_opts},
          # with a sanitised body and tags extracted,
          {PostContents, @section_act_opts},
          # a caretaker,
          {Caretaker, @section_act_opts},
          # and a creator,
          {Creator, @section_act_opts},
          # and possibly fetch contents of URLs,
          {URLPreviews, @section_act_opts},
          # possibly with uploaded files,
          {Files, @section_act_opts},
          # with extracted tags fully hooked up,
          {Tags, @section_act_opts},
          # and the appropriate boundaries established,
          {Boundaries, @section_act_opts},
          # summarised by an activity?
          # {Activity, @section_act_opts},
          # {Feeds,       @section_act_opts}, # appearing in feeds?

          # Now we have a short critical section
          Ecto.Begin,
          # Run our inserts
          Ecto.Work,
          Ecto.Commit,

          # These things are free to happen casually in the background.
          # Publish live feed updates via (in-memory) pubsub?
          # {LivePush, @section_act_opts},
          # Enqueue for indexing by meilisearch
          {MeiliSearch.Queue, @section_act_opts}

          # Oban would rather we put these here than in the transaction
          # above because it knows better than us, obviously.
          # Prepare for federation and do the queue insert (oban).
          # {ActivityPub, @section_act_opts},

          # Once the activity/object exists, we can apply side effects
          # {Bonfire.Social.Acts.CategoriesAutoBoost, @section_act_opts}
        ]
      ]
  end
end
