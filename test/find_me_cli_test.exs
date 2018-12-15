defmodule FindMeCliTest do
  use ExUnit.Case

  import FindMe.CLI, only: [ parse_args: 1 ]

  test ":help returned when --h or --help is parsed" do
    assert FindMe.CLI.parse_args(["--h"]) == :help
    assert FindMe.CLI.parse_args(["--h"]) == :help
  end

  test "tuple returned when project, search and count(optional) are supplied" do
    assert FindMe.CLI.parse_args(["find-me", "elixir", "10"]) == { "find-me", "elixir", 10 }
    assert FindMe.CLI.parse_args(["find-me", "elixir"]) == { "find-me", "elixir", 5 }
  end
end
