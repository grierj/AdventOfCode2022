defmodule SupplyStacks do
  @moduledoc """
  Documentation for `SupplyStacks`.

  Given a series of stacks and a series of commands, move "crates" in the stacks
  based on the commands.  The crates stack on top of each other, so the whole stack
  can be represented by an ordered list, and we'll just add and pop from the end.

  The input.txt file is not well ordered, so we'll have to parse crappy strings
  or convert it to something machine-readable instead of... ascii art... for the
  stacks.  The human readable commands should be parsable though.
  """

  @spec run :: :ok
  def run do
    SupplyStacks.Crates.start_link()
    load_initial_crates()

    File.read!(Path.expand(Path.join("data", "input.txt")))
    |> String.split("\n")
    |> Enum.reject(fn x -> x == "" end)
    |> Enum.map(fn x -> run_instructions(x) end)

    IO.puts(get_stack_tops())
    SupplyStacks.Crates.stop()
    :ok
  end

  def run_instructions(line) do
    [num, from, to] =
      String.split(line)
      |> Enum.reject(fn x -> !String.match?(x, ~r/\d+/) end)
      |> Enum.map(fn x -> String.to_integer(x) end)

    SupplyStacks.Crates.pop_from_stack(from, num)
    |> SupplyStacks.Crates.add_to_stack(to)
  end

  def get_stack_tops() do
    SupplyStacks.Crates.get_all_stacks()
    |> Map.values()
    |> Enum.map(fn x -> List.first(x) end)
  end

  # I don't feel like parsing ascii art, so just put these right in the code.
  def load_initial_crates() do
    SupplyStacks.Crates.add_to_stack(~w(D Z T H), 1)
    SupplyStacks.Crates.add_to_stack(~w(S C G T W R Q), 2)
    SupplyStacks.Crates.add_to_stack(~w(H C R N Q F B P), 3)
    SupplyStacks.Crates.add_to_stack(~w(Z H F N C L), 4)
    SupplyStacks.Crates.add_to_stack(~w(S Q F L G), 5)
    SupplyStacks.Crates.add_to_stack(~w(S C R B Z W P V), 6)
    SupplyStacks.Crates.add_to_stack(~w(J F Z), 7)
    SupplyStacks.Crates.add_to_stack(~w(Q H R Z V L D), 8)
    SupplyStacks.Crates.add_to_stack(~w(D L Z F N G H B), 9)
  end
end

defmodule SupplyStacks.Crates do
  @moduledoc """
  An agent to represent our stacks of crates, we'll use a map of lists
  with each map entry being the stack and the list being the crates in
  the stack.  Elixir prefers to work from the front of a list where
  possible, so the lowest entry will be the highest in the stack
  """
  use Agent

  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def stop() do
    Agent.stop(__MODULE__)
  end

  def get_stack(stack) do
    get_all_stacks()[stack]
  end

  def get_all_stacks() do
    Agent.get(__MODULE__, fn stacks -> stacks end)
  end

  def add_to_stack(crate, stack) when is_list(crate) do
    new_stack = crate ++ get_stack(stack)
    Agent.update(__MODULE__, &Map.put(&1, stack, new_stack))
  end

  def add_to_stack(crate, stack) do
    add_to_stack([crate], stack)
  end

  def pop_from_stack(stack, num) do
    curr_stack = get_stack(stack)
    crates = Enum.take(curr_stack, num)
    Agent.update(__MODULE__, &Map.put(&1, stack, Enum.slice(curr_stack, num..-1)))
    crates
  end
end
