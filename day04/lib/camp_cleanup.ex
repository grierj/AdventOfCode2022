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

  end
end
