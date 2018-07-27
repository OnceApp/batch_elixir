defmodule BatchElixir.ApplicationTest do
  alias BatchElixir.Application, as: App

  use ExUnit.Case

  test "Ensure all required configuration keys are set" do
    Application.put_env(:batch_elixir, :rest_api_key, "test")
    Application.put_env(:batch_elixir, :producer_name, {:global, BatchProducer})
    assert {:ok, pid} = App.start(nil, nil)
    Application.stop(pid)
  end

  test "Should fail if missing required configuration key" do
    Application.put_env(:batch_elixir, :producer_name, {:global, BatchProducer})
    Application.delete_env(:batch_elixir, :rest_api_key)
    assert {:error, {:shutdown, _}} = App.start(nil, nil)
  end
end
