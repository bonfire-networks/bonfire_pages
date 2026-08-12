defmodule Bonfire.Pages.Test do
  use ExUnit.Case

  # bucket this into the backend CI leg: bare `ExUnit.Case` skips the tag the extension case templates apply, so without it this also runs in the federation job catch-all
  @moduletag :backend

  # TODO
end
