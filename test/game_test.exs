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
  end
end
