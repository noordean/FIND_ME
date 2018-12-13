defmodule FindMeTest do
  use ExUnit.Case
  doctest FindMe

  test "greets the world" do
    assert FindMe.hello() == :world
  end
end
