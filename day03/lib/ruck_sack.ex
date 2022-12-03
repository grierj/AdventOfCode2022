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
    RuckSack.Score.start_link()

    IO.puts(
      File.read!(Path.expand(Path.join("data", "input.txt")))
      |> String.split("\n")
      |> Enum.reject(fn(x) -> x == "" end)
      |> Enum.map(fn x -> split_lines(x) end)
      |> Enum.map(fn x -> find_common(x) end)
      |> Enum.map(fn x -> get_score(x) end)
      |> IO.inspect()
      |> Enum.sum()
    )
  end

  @doc """
  Given a line, split it in half and return the two halves as a tuple

  ## Examples

      iex> RuckSack.split_lines("abcd")
      {"ab", "cd"}

  """
  def split_lines(line) do
    len = String.length(line)
    IO.inspect(line)
    [
      String.slice(line, 0, div(len, 2)),
      String.slice(line, div(len, 2), len - 1)
    ]
  end

  @doc """
  """
  def find_common(item_pair) do
    MapSet.intersection(
      MapSet.new(String.graphemes(Enum.at(item_pair, 0))),
      MapSet.new(String.graphemes(Enum.at(item_pair, 1)))
    )
  end

  def get_score(item_list) do
    IO.inspect(item_list)
    Enum.map(item_list, fn x -> RuckSack.Score.get_score_for(x) end)
    |> Enum.sum()
  end
end

defmodule RuckSack.Score do
  use Agent

  def start_link() do
    Agent.start_link(fn -> make_score_list() end, name: __MODULE__)
  end

  def make_score_list do
    Enum.into(
      List.zip([
      String.graphemes(List.to_string(Enum.to_list(?a..?z) ++ Enum.to_list(?A..?Z))),
      Enum.to_list(1..52)
    ]), %{})
  end

  def get_score_for(key) do
    IO.inspect(key)
    Agent.get(__MODULE__, &Map.get(&1, key))
  end
end