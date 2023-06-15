defmodule RevardTest do
  use ExUnit.Case
  doctest Revard

  test "greets the world" do
    assert Revard.hello() == :world
  end
end
