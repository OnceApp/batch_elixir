defmodule BatchElixir.ApplicationTest do
  alias BatchElixir.Application, as: App

  use ExUnit.Case

  test "Ensure all required configuration keys are set" do
    Application.put_env(:batch_elixir, :rest_api_key, "test")
    assert {:ok, pid} = App.start(nil, nil)
    Application.stop(pid)
  end

  test "Should fail if missing required configuration key" do
    Application.delete_env(:batch_elixir, :rest_api_key)
    assert {:error, {:shutdown, error}} = App.start(nil, nil)
  end
end
