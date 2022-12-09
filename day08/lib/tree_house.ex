defmodule TreeHouse do
  @moduledoc """
  Documentation for `TreeHouse`.

  https://adventofcode.com/2022/day/8

  Find the number of visible trees from the outside perimiter of the "forest"
  represented by the input.txt file.  The number represents a single tree and its height.
  It must be taller than all the trees in front of it to be seen.

  Visible trees will be calculated from all edges of the "forest"
  """

  def run do
    tree_rows =
      File.read!(Path.expand(Path.join("data", "input.txt")))
      |> String.split("\n")
      |> Enum.reject(fn x -> x == "" end)
      |> Enum.map(fn x -> String.graphemes(x) end)
      |> Enum.map(fn outer -> Enum.map(outer, fn inner -> String.to_integer(inner) end) end)

    vmax = length(tree_rows) - 1
    hmax = length(List.first(tree_rows)) - 1

    Enum.reduce(0..hmax, [], fn x, acc ->
      Enum.reduce(0..vmax, acc, fn y, trees ->
        if visible_from_left(tree_rows, x, y) ||
             visible_from_right(tree_rows, x, y) ||
             visible_from_top(tree_rows, x, y) ||
             visible_from_bottom(tree_rows, x, y)  do
          trees ++ [{x, y}]
        else
          trees
        end
      end)
    end)
    |> Enum.uniq()
    |> length()
  end

  @spec visible_from_left(list, non_neg_integer(), non_neg_integer()) :: boolean()
  def visible_from_left(tree_rows, x, y) do
    if x == 0 do
      IO.inspect({x, y}, label: "left edge")
      true
    else
      tree_height = get_tree_height(tree_rows, x, y)

      Enum.reduce(Enum.slice(Enum.at(tree_rows, y), 0..x - 1), true, fn curr_tree, acc ->
        if curr_tree >= tree_height do
          false
        else
          acc
        end
      end)
    end
  end

  @spec visible_from_right(list, non_neg_integer(), non_neg_integer()) :: boolean()
  def visible_from_right(tree_rows, x, y) do
    if x == length(Enum.at(tree_rows, y)) - 1 do
      IO.inspect({x, y}, label: "right edge")
      true
    else
      tree_height = get_tree_height(tree_rows, x, y)

      Enum.reduce(Enum.reverse(Enum.slice(Enum.at(tree_rows, y), x + 1..-1)), true, fn curr_tree, acc ->
        if curr_tree >= tree_height do
          false
        else
          acc
        end
      end)
    end
  end

  @spec visible_from_top(list, non_neg_integer(), non_neg_integer()) :: boolean()
  def visible_from_top(tree_rows, x, y) do
    if y == 0 do
      IO.inspect({x, y}, label: "top edge")
      true
    else
      tree_height = get_tree_height(tree_rows, x, y)

      Enum.reduce(Enum.slice(tree_rows, 0..y-1), true, fn row, acc ->
        if Enum.at(row, x) >= tree_height do
          false
        else
          acc
        end
      end)
    end
  end

  @spec visible_from_bottom(list, non_neg_integer(), non_neg_integer()) :: boolean()
  def visible_from_bottom(tree_rows, x, y) do
    if y == length(tree_rows) - 1 do
      IO.inspect({x, y}, label: "bottom edge")
      true
    else
      tree_height = get_tree_height(tree_rows, x, y)

      Enum.reduce(Enum.reverse(Enum.slice(tree_rows, y+1..-1)), true, fn row, acc ->
        if Enum.at(row, x) >= tree_height do
          false
        else
          acc
        end
      end)
    end
  end

  @spec get_tree_height(list(list()), integer, integer) :: any
  def get_tree_height(tree_rows, x, y) do
    Enum.at(tree_rows, y) |> Enum.at(x)
  end
end
