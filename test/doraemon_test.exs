defmodule DoraemonTest do
  use ExUnit.Case
  doctest Doraemon

  test "greets the world" do
    assert Doraemon.hello() == :world
  end
end
