play_list = File.read!(Path.expand(Path.join("data","input.txt")))
|> String.split("\n")
|> Enum.map(fn(x) -> String.split(x, " ") end)

IO.puts(inspect play_list)

defmodule RockPaperScissors do
    @opp_rock "A"
    @opp_paper "B"
    @opp_scissor "C"
    @me_rock "X"
    @me_paper "Y"
    @me_scissor "Z"
    @points_rock 1
    @points_paper 2
    @points_scissor 3
    @points_win 6
    @points_tie 3
    @points_loss 0

    def points_for_play(play) do
        case play do
            [@opp_rock, x] ->
                case x do
                    @me_rock -> @points_tie + @points_rock
                    @me_paper -> @points_win + @points_paper
                    @me_scissor -> @points_loss + @points_scissor
                end
            [@opp_paper, x] ->
                case x do
                    @me_rock -> @points_loss + @points_rock
                    @me_paper -> @points_tie + @points_paper
                    @me_scissor -> @points_win + @points_scissor
                end
            [@opp_scissor, x] ->
                case x do
                    @me_rock -> @points_win + @points_rock
                    @me_paper -> @points_loss + @points_paper
                    @me_scissor -> @points_tie + @points_scissor
                end
            _ -> 0
        end
    end
end

IO.puts(Enum.map(play_list, fn(x) -> RockPaperScissors.points_for_play(x) end) |> IO.inspect |> Enum.sum())
