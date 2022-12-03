# Part 1
# Technically a 1 liner...

IO.puts(File.read!(Path.expand(Path.join("data","input.txt"))) |> String.split("\n")
|> Enum.chunk_by(fn(x) -> x != "" end)
|> Enum.reject(fn(x) -> x == [""] end)
|> Enum.map(fn(x) -> Enum.map(x, fn(y) -> String.to_integer(y) end) end)
|> Enum.map(fn(x) -> Enum.sum(x) end)
|> Enum.max())

# Part 2
# same as before, but sort, take the last 3 elements and sum
IO.puts(File.read!(Path.expand(Path.join("data","input.txt"))) |> String.split("\n")
|> Enum.chunk_by(fn(x) -> x != "" end)
|> Enum.reject(fn(x) -> x == [""] end)
|> Enum.map(fn(x) -> Enum.map(x, fn(y) -> String.to_integer(y) end) end)
|> Enum.map(fn(x) -> Enum.sum(x) end)
|> Enum.sort()
|> Enum.take(-3)
|> Enum.sum())
