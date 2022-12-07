defmodule TuningTrouble do
  @moduledoc """
  Documentation for `TuningTrouble`.

  Given a string of characters, locate the position of the first character
  after a series of 4 characters where none repeat.  Examples:

  - bvwbjplbgvbhsrlpgdmjqwftvncz: first marker after character 5
  - nppdvjthqldpwncqszvftbrmjlhg: first marker after character 6
  - nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg: first marker after character 10
  - zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw: first marker after character 11

  We'll just split our string into graphemes and look back 4 characters for duplicates.

  In part 2 we just set our lookback to be 14 characters instead of 4, the solution remains
  the same, only the config is different
  """

  @doc """
  Run the program

  ```
  $ iex -S mix
  iex> TuningTrouble.run
  4
  :ok
  ```

  """
  def run do
    charlist =
      File.read!(Path.expand(Path.join("data", "input.txt")))
      |> String.graphemes()
      |> Enum.with_index()

    IO.puts(
      Enum.reduce_while(charlist, 0, fn {_, i}, _ ->
        if i > 13 do
          (Enum.slice(charlist, (i - 13)..i)
           |> Enum.map(fn {e, _} -> e end)
           |> list_has_dupes?() && {:cont, 0}) || {:halt, i + 1}
        else
          {:cont, 0}
        end
      end)
    )
  end

  def list_has_dupes?(list) do
    length(list) != length(Enum.uniq(list))
  end
end
