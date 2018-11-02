defmodule GameTest do
  use ExUnit.Case

  doctest Hangman.Game

  alias Hangman.Game

  describe "new_game/0" do
    setup do
      game = Game.new_game()
      %{game: game}
    end

    test "returns a :turns_left field on the struct", context do
      assert context[:game].turns_left == 7
    end

    test "returns a :game_state field on the struct", context do
      assert context[:game].game_state == :initializing
    end

    test "returns a :letters field on the struct", context do
      assert length(context[:game].letters) > 0
    end

    test "each element of the letters list is a lower-case ASCII character", context do
      Enum.map(context[:game].letters, fn letter ->
        assert letter =~ ~r/[a-z]/
      end)
    end
  end

  describe "make_move/2" do
    test "state isn't changed for :lost or :won game" do
      for state <- [:won, :lost] do
        game =
          Game.new_game()
          |> Map.put(:game_state, state)

        assert {^game, _} = Game.make_move(game, "x")
      end
    end
  end
end
