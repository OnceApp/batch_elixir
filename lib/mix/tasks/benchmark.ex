defmodule Mix.Tasks.Benchmark do
  use Mix.Task
  @shortdoc "Simply runs the Hello.say/0 function"
  def run(param) do
    StressTest.CLI.main(param)
  end
end
