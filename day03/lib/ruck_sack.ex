defmodule RuckSack do
  @moduledoc """
  Documentation for `RuckSack`.

  Givent `data/input.txt` take the contents, line by line and:
  - split them in half (they will be different lengths)
  - find any shared items (represented by the same letter, case-sensitive)
  - score the shared items based on a-zA-Z translating to 1-52
  - sum all the scores from every line
  """

  @doc """
  Run the program

  ## Examples

      iex> RuckSack.run()
      :integer()

  """
  def run do
    File.read!(Path.expand(Path.join("data","input.txt")))
    |> String.split("\n")
    |> Enum.map(fn(x) -> split_lines(x) end)

    0
  end

  @doc """
  Given a line, split it in half and return the two halves as a tuple

  ## Examples

      iex> RuckSack.split_lines("abcd")
      {"ab", "cd"}

  """
  def split_lines(line) do
    len = String.length(line)
    {
      String.slice(line, 0, div(len, 2)),
      String.slice(line, div(len, 2), len - 1)
    }
  end

  @doc """
  """
  def find_common(item_pair) do
    MapSet.intersection(
      MapSet.new(String.graphemes(elem(item_pair, 0)))
      MapSet.new(String.graphemes(elem(item_pair, 1)))
    )
  end

  def gen_score(item_list) do

  end
end
