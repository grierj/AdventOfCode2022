defmodule TreeHouse2 do
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
        trees ++ [look_left_right(tree_rows, x, y) * look_up_down(tree_rows, x, y)]
      end)
    end)
    |> Enum.max()
  end

  def look_left_right(tree_rows, x, y) do
    tree_height = get_tree_height(tree_rows, x, y)

    our_row = Enum.at(tree_rows, y)
    left_trees = if x != 0 do
      Enum.reduce_while(Enum.reverse(Enum.slice(our_row, 0..x-1)), 0, fn curr_tree, acc ->
        cond do
          curr_tree < tree_height ->
            {:cont, acc + 1}
          curr_tree >= tree_height ->
            {:halt, acc + 1}
        end
      end)
    else
      0
    end
    right_trees = if x != (length(our_row) - 1) do
      Enum.reduce_while(Enum.slice(our_row, x+1..-1), 0, fn curr_tree, acc ->
        cond do
          curr_tree < tree_height ->
            {:cont, acc + 1}
          curr_tree >= tree_height ->
            {:halt, acc + 1}
        end
      end)
    else
      0
    end
    left_trees * right_trees
  end

  def look_up_down(tree_rows, x, y) do
    tree_height = get_tree_height(tree_rows, x, y)
    up_trees = if y != 0 do
      Enum.reduce_while(Enum.reverse(Enum.slice(tree_rows, 0..y-1)), 0, fn curr_row, acc ->
        curr_tree = Enum.at(curr_row, x)
        cond do
          curr_tree < tree_height ->
            {:cont, acc + 1}
          curr_tree >= tree_height ->
            {:halt, acc + 1}
        end
      end)
    else
      0
    end
    down_trees = if y != length(tree_rows) - 1 do
      Enum.reduce_while(Enum.slice(tree_rows, y+1..-1), 0, fn curr_row, acc ->
        curr_tree = Enum.at(curr_row, x)
        cond do
          curr_tree < tree_height ->
            {:cont, acc + 1}
          curr_tree >= tree_height ->
            {:halt, acc + 1}
        end
      end)
    else
      0
    end
    up_trees * down_trees
  end

  @spec get_tree_height(list(list()), integer, integer) :: any
  def get_tree_height(tree_rows, x, y) do
    Enum.at(tree_rows, y) |> Enum.at(x)
  end
end
