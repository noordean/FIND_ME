defmodule FindMe.CLI do
  @default_count 5

  @moduledoc """
  Handle the command line parsing and the dispatch to
  various functions that end up generating a table
  that displays our results
  """
  def run(argv) do
    parse_args(argv)
  end

  @doc """
  `argv` can be -h or --help, which returns :help.
  Otherwise it is a github project-name, search-query and count(optionally).
  Return a tuple of `{ project, query, count }`, or `:help` if help was given.
  """
  def parse_args(argv) do
    parse = OptionParser.parse(argv, switches: [ help: :boolean],
      aliases: [ h: :help ])
    case parse do
      { [ help: true ], _, _ } -> :help
      { _, [ project, query, count ], _ } -> { project, query, String.to_integer(count) }
      { _, [ project, query ], _ } -> { project, query, @default_count }
      _ -> :help
    end
  end
end
