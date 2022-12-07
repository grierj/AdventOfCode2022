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
        if i > 3 do
          (Enum.slice(charlist, (i - 3)..i)
           |> Enum.map(fn {e, _} -> e end)
           |> list_has_dupes?() && {:cont, 0}) || {:halt, i + 1}
        else
          {:cont, 0}
        end
      end)
    )
  end

  def list_has_dupes?(list) do
    IO.inspect(list)
    IO.inspect(Enum.uniq(list))
    length(list) != length(Enum.uniq(list))
  end
end
