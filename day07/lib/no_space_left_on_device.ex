defmodule DeviceFile do
  defstruct [:name, :size, :directory]
end

defmodule NoSpaceLeftOnDevice do
  @moduledoc """
  Documentation for `NoSpaceLeftOnDevice`.

  I guess we're emulating a shell today.  We need to iterate over a set of commands,
  prefixed with `$ ` and if there's lines after it, parse the output.  We care about
  directory traversal with:

  - cd <dir>
  - cd ..

  We care about diretory listings with:

  - ls

  This might output a directory name or a file with a size as the prefix.  The directory
  has no prefix, so we can identify files with ~r/\A\d+\s+\w+\z/ and the directories with
  ~r/\A\w+\z/

  We'll need to capture and accumulate the size on the files and associate them with the
  diretory they're in.

  All of this needs to be stored in some sort of structure that we can roll up all the sizes
  of the directories to find the sum of all the sizes of the directories *less than 100000*

  Directory sizes include the size of files in it and the size of all files in the directories
  in it and so on.
  """
  alias NoSpaceLeftOnDevice.TotalSize
  alias NoSpaceLeftOnDevice.CWD
  @spec run :: any
  def run do
    CWD.start_link()
    TotalSize.start_link()

    File.read!(Path.expand(Path.join("data", "input.txt")))
    |> collect_files()
    |> collect_dir_sizes()

    IO.puts(TotalSize.get())
  after
    CWD.stop()
    TotalSize.stop()
  end

  def collect_files(commands) do
    cd_regex = ~r/\A\$\s+cd\s+(\S+)\z/
    file_regex = ~r/\A(\d+)\s+(\S+)\z/
    dir_regex = ~r/\Adir\s+(\S+)\z/
    my_dirs = %{:/ => %{files: [], size: 0}}

    String.split(commands, "\n")
    |> Enum.reject(fn x -> x == "" end)
    |> Enum.reject(fn x -> x == "$ ls" end)
    |> Enum.reduce(my_dirs, fn x, acc ->
      cond do
        Regex.match?(cd_regex, x) ->
          [_, cwd] = Regex.run(cd_regex, x)

          CWD.set(cwd)
          acc

        Regex.match?(dir_regex, x) ->
          [_, dir] = Regex.run(dir_regex, x)
          atom_path = path_to_atoms(CWD.get()) ++ [String.to_atom(dir)]

          if !get_in(acc, atom_path) do
            put_in(acc, atom_path, %{files: [], size: 0})
          else
            acc
          end

        Regex.match?(file_regex, x) ->
          [_, filesize, filename] = Regex.run(file_regex, x)
          filesize = String.to_integer(filesize)
          dir_atom_path = path_to_atoms(CWD.get())
          atom_path = dir_atom_path ++ [:files]

          put_in(
            acc,
            atom_path,
            get_in(acc, atom_path) ++
              [%DeviceFile{name: filename, size: filesize, directory: CWD.get()}]
          )
          |> roll_up_size(dir_atom_path, filesize)

        true ->
          IO.inspect(x, label: "Borked on")
          exit("Failed to parse commands")
      end
    end)
  end

  def roll_up_size(dir_list, atom_path, _size) when atom_path == [] do
    dir_list
  end

  def roll_up_size(dir_list, atom_path, size) do
    put_in(
      dir_list,
      atom_path ++ [:size],
      get_in(dir_list, atom_path ++ [:size]) + size
    )
    |> roll_up_size(Enum.slice(atom_path, 0..-2), size)
  end

  def collect_dir_sizes(dirlist, maxsize \\ 100_000) do
    if Map.has_key?(dirlist, :size) && dirlist.size <= maxsize do
      TotalSize.set(dirlist.size)
    end

    dirs = Map.keys(dirlist) |> List.delete(:size) |> List.delete(:files)

    if length(dirs) > 0 do
      for k <- dirs do
        collect_dir_sizes(dirlist[k])
      end
    end
  end

  def path_to_atoms(path) do
    Path.split(path)
    |> Enum.map(fn x -> String.to_atom(x) end)
  end
end

defmodule NoSpaceLeftOnDevice.CWD do
  use Agent

  @spec start_link :: {:error, any} | {:ok, pid}
  def start_link() do
    Agent.start_link(fn -> "/" end, name: __MODULE__)
  end

  @spec stop :: :ok
  def stop() do
    Agent.stop(__MODULE__)
  end

  def set(dir) do
    Agent.update(__MODULE__, fn x -> Path.expand(Path.join(x, dir)) end)
  end

  def get() do
    Agent.get(__MODULE__, fn x -> x end)
  end
end

defmodule NoSpaceLeftOnDevice.TotalSize do
  use Agent

  @spec start_link :: {:error, any} | {:ok, pid}
  def start_link() do
    Agent.start_link(fn -> 0 end, name: __MODULE__)
  end

  @spec stop :: :ok
  def stop() do
    Agent.stop(__MODULE__)
  end

  def set(size) do
    Agent.update(__MODULE__, fn x -> x + size end)
  end

  def get() do
    Agent.get(__MODULE__, fn x -> x end)
  end
end
