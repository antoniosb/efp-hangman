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

  describe "new_game/1" do
    test "sets the letters as the given word codepoints" do
      game = Game.new_game("little")

      assert game.letters == ["l", "i", "t", "t", "l", "e"]
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

    test "first occurence of letter is not already used" do
      game = Game.new_game()
      {game, _tally} = Game.make_move(game, "x")

      assert game.game_state != :already_used
    end

    test "second occurence of letter is not already used" do
      game = Game.new_game()

      {game, _tally} = Game.make_move(game, "x")
      assert game.game_state != :already_used

      {game, _tally} = Game.make_move(game, "x")
      assert game.game_state == :already_used
    end

    test "a good guess is recognized" do
      game = Game.new_game("wiggle")
      {game, _tally} = Game.make_move(game, "w")
      assert game.game_state == :good_guess
      assert game.turns_left == 7
    end

    test "a guessed word is a won game" do
      game = Game.new_game("wiggle")
      {game, _tally} = Game.make_move(game, "w")
      assert game.game_state == :good_guess
      assert game.turns_left == 7
      {game, _tally} = Game.make_move(game, "i")
      assert game.game_state == :good_guess
      assert game.turns_left == 7
      {game, _tally} = Game.make_move(game, "g")
      assert game.game_state == :good_guess
      assert game.turns_left == 7
      {game, _tally} = Game.make_move(game, "l")
      assert game.game_state == :good_guess
      assert game.turns_left == 7
      {game, _tally} = Game.make_move(game, "e")
      assert game.game_state == :won
      assert game.turns_left == 7
    end

    test "bad guess is recognized" do
      game = Game.new_game("wiggle")
      {game, _tally} = Game.make_move(game, "x")

      assert game.game_state == :bad_guess
      assert game.turns_left == 6
    end

    test "a lost game when there is no turns left" do
      game = Game.new_game("wiggle")
      {game, _tally} = Game.make_move(game, "a")
      assert game.game_state == :bad_guess
      assert game.turns_left == 6
      {game, _tally} = Game.make_move(game, "b")
      assert game.game_state == :bad_guess
      assert game.turns_left == 5
      {game, _tally} = Game.make_move(game, "c")
      assert game.game_state == :bad_guess
      assert game.turns_left == 4
      {game, _tally} = Game.make_move(game, "d")
      assert game.game_state == :bad_guess
      assert game.turns_left == 3
      {game, _tally} = Game.make_move(game, "f")
      assert game.game_state == :bad_guess
      assert game.turns_left == 2
      {game, _tally} = Game.make_move(game, "h")
      assert game.game_state == :bad_guess
      assert game.turns_left == 1
      {game, _tally} = Game.make_move(game, "x")
      assert game.game_state == :lost
      assert game.turns_left == 0
    end
  end
end
