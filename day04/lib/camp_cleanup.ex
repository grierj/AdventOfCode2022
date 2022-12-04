defmodule CampCleanup do
  @moduledoc """
  Documentation for `CampCleanup`.

  Given the file `data/input.txt` with range pairs like `1-10,12-30`
  determine which sets of pairs has a range that is wholly contained by the other range

  For this we will
  - read the file
  - determine the start and end of each range
  - generate a MapSet for each pair that contains the range
  - compare each set to the other with `MapSet.subset?()` to see if either is fully contained by the other
  - collect the number of pairs that have full contained subset as one of the pair
  - print out that number of pairs
  """

  def run do
    IO.puts(
      File.read!(Path.expand(Path.join("data", "input.txt")))
      |> String.split("\n")
      |> Enum.reject(fn x -> x == "" end)
      |> Enum.map(fn x -> String.split(x, ",") end)
      |> Enum.map(fn x -> find_subset(x) end)
      |> Enum.sum()
    )
  end

  def find_subset(pair) do
    [first_range, second_range] = Enum.map(pair, fn x -> str_range_to_map_set(x) end)
    cond do
      MapSet.subset?(first_range, second_range) -> 1
      MapSet.subset?(second_range, first_range) -> 1
      true -> 0
    end
  end

  @spec str_range_to_map_set(binary) :: MapSet
  def str_range_to_map_set(string) do
    [range_start, range_end] = String.split(string, "-")
    |> Enum.map(fn x -> String.to_integer(x) end)
    MapSet.new(Range.new(range_start, range_end))
  end

end
