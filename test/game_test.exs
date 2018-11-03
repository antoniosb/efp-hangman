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

        assert ^game = Game.make_move(game, "x")
      end
    end

    test "first occurence of letter is not already used" do
      game = Game.new_game()
      game = Game.make_move(game, "x")

      assert game.game_state != :already_used
    end

    test "second occurence of letter is not already used" do
      game = Game.new_game()

      game = Game.make_move(game, "x")
      assert game.game_state != :already_used

      game = Game.make_move(game, "x")
      assert game.game_state == :already_used
    end

    test "a good guess is recognized" do
      game = Game.new_game("wiggle")
      game = Game.make_move(game, "w")
      assert game.game_state == :good_guess
      assert game.turns_left == 7
    end

    test "a guessed word is a won game" do
      moves = [
        {"w", :good_guess},
        {"i", :good_guess},
        {"g", :good_guess},
        {"g", :already_used},
        {"l", :good_guess},
        {"e", :won}
      ]

      game = Game.new_game("wiggle")

      reducer = fn {guess, state}, game ->
        game = Game.make_move(game, guess)
        assert game.game_state == state
        game
      end

      Enum.reduce(moves, game, reducer)
    end

    test "bad guess is recognized" do
      game = Game.new_game("wiggle")
      game = Game.make_move(game, "x")

      assert game.game_state == :bad_guess
      assert game.turns_left == 6
    end

    test "a lost game when there is no turns left" do
      moves = [
        {"a", :bad_guess, 6},
        {"b", :bad_guess, 5},
        {"c", :bad_guess, 4},
        {"d", :bad_guess, 3},
        {"f", :bad_guess, 2},
        {"h", :bad_guess, 1},
        {"x", :lost, 0}
      ]

      game = Game.new_game("wiggle")

      reducer = fn {guess, state, turns_left}, game ->
        game = Game.make_move(game, guess)
        assert game.game_state == state
        assert game.turns_left == turns_left
        game
      end

      Enum.reduce(moves, game, reducer)
    end

    test "an invalid guess is recognized" do
      game = Game.new_game()
      game = Game.make_move(game, "1")
      assert game.game_state == :invalid_guess
      assert game.turns_left == 7
      game = Game.make_move(game, "asd")
      assert game.game_state == :invalid_guess
      assert game.turns_left == 7
      game = Game.make_move(game, "A")
      assert game.game_state == :invalid_guess
      assert game.turns_left == 7
    end
  end
end
