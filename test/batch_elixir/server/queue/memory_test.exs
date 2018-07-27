defmodule BatchElixir.Server.Queue.MemoryTest do
  alias BatchElixir.Server.Queue.Memory
  use ExUnit.Case

  defp assert_down(pid) do
    ref = Process.monitor(pid)
    assert_receive {:DOWN, ^ref, _, _, _}
  end

  setup do
    {:ok, pid} = Memory.start_link()

    on_exit(fn ->
      assert_down(pid)
    end)
  end

  test "Add 5 items to queue" do
    assert 1..5
           |> Enum.map(&Memory.push/1)
           |> Enum.all?(&(:ok == &1))
  end

  test "Removing elements from empty queue" do
    assert [] = Memory.pop()
  end

  test "Removing elements with the default value" do
    1..5 |> Enum.each(&Memory.push/1)

    1..5
    |> Enum.each(fn i ->
      assert [^i] = Memory.pop()
    end)
  end

  test "Removing 3 elements" do
    1..5 |> Enum.each(&Memory.push/1)
    assert [1, 2, 3] = Memory.pop(3)
    assert [4, 5] = Memory.pop(3)
  end

  test "Removing more elements than the queue has" do
    1..5 |> Enum.each(&Memory.push/1)
    assert [1, 2, 3, 4, 5] = Memory.pop(10)
  end
end
