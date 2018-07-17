defmodule BehaviourTestTest do
  use ExUnit.Case
  doctest BehaviourTest

  test "greets the world" do
    assert BehaviourTest.hello() == :world
  end
end
