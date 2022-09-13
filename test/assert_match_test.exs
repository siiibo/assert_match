defmodule AssertMatchTest do
  use ExUnit.Case
  doctest AssertMatch

  test "greets the world" do
    assert AssertMatch.hello() == :world
  end
end
