defmodule BatchElixir.EnvironmentTest do
  alias BatchElixir.Environment

  use ExUnit.Case

  setup do
    Application.put_env(:batch_elixir, :test, "test")
  end

  test "Getting value from application environment" do
    assert "test" == Environment.get(:test)
    assert nil == Environment.get(:unknown)
  end

  test "Ensure that the key exists and get the value from application environment" do
    assert :ok == Environment.ensure(:test)

    assert {:error, ~s/configuration key "unknown" is not defined/} = Environment.ensure(:unknown)
  end
end
