defmodule StressTest.ProgressBar do
  @format [
    bar_color: IO.ANSI.green_background(),
    blank_color: IO.ANSI.red_background(),
    spinner_color: [IO.ANSI.red(), IO.ANSI.bright()],
    frames: :braille,
    bar: " ",
    blank: " ",
    right: "| "
  ]
  defp set_left_message(message) do
    @format ++
      [
        left: [IO.ANSI.magenta(), "#{message}:", IO.ANSI.reset(), " |"]
      ]
  end

  def render(value, max, message) do
    ProgressBar.render(value, max, set_left_message(message))
  end

  def render_spinner(text, done, func) do
    ProgressBar.render_spinner(
      @format ++ [text: text, done: [IO.ANSI.green(), "✓ ", IO.ANSI.reset(), done]],
      func
    )
  end
end
