defmodule Hangman.Game do
  @moduledoc """
    The implementation of the Hangman game API
  """
  defstruct(
    turns_left: 7,
    game_state: :initializing,
    letters: [],
    used: MapSet.new()
  )

  @doc """
    Starts a new game using a struct with the initial game state

    ## Examples:
      iex> game = Hangman.Game.new_game()
      iex> game.game_state == :initializing
      true

      iex> game = Hangman.Game.new_game()
      iex> Enum.empty? game.letters
      false
  """
  def new_game do
    new_game(Dictionary.random_word())
  end

  def new_game(word) do
    %Hangman.Game{
      letters: word |> String.codepoints()
    }
  end

  @doc """
    Implementation of the Hangman.make_guess interface
  """
  def make_guess(game, guess) do
    new_game = make_move(game, guess)
    {new_game, tally(new_game)}
  end

  @doc """
  Guess a letter on the given game.

  ## Examples:
  iex> alias Hangman.Game
  iex> game = Game.new_game("foo")
  iex> game = Game.make_move(game, "o")
  iex> tally = Game.tally(game)
  iex> tally.letters
  ["_", "o", "o"]
  """
  def make_move(game = %{game_state: state}, _guess) when state in [:won, :lost], do: game

  # def make_move(game, guess), do: accept_move(game, guess, MapSet.member?(game.used, guess))
  def make_move(game, guess) do
    (is_binary(guess) && guess |> String.codepoints() |> length() == 1 && guess =~ ~r/[a-z]/ &&
       accept_move(game, guess, MapSet.member?(game.used, guess))) ||
      %{game | game_state: :invalid_guess}
  end

  @doc """
    Game state useful for the client

    ## Examples:
    iex> alias Hangman.Game
    iex> game = Game.new_game("foo")
    iex> game = Game.make_move(game, "f")
    iex> game = Game.make_move(game, "x")
    iex> game = Game.make_move(game, "o")
    iex> tally = Game.tally(game)
    iex> tally.game_state
    :won
    iex> tally.turns_left
    6
    iex> tally.letters
    ["f", "o", "o"]
  """
  def tally(game) do
    %{
      game_state: game.game_state,
      turns_left: game.turns_left,
      letters: game.letters |> reveal_guessed(game.used)
    }
  end

  defp accept_move(game, _guess, _already_guessed = true) do
    Map.put(game, :game_state, :already_used)
  end

  defp accept_move(game, guess, _already_guessed) do
    game
    |> Map.put(:used, MapSet.put(game.used, guess))
    |> score_guess(Enum.member?(game.letters, guess))
  end

  defp score_guess(game, _good_guess = true) do
    new_state =
      game.letters
      |> MapSet.new()
      |> MapSet.subset?(game.used)
      |> maybe_won

    Map.put(game, :game_state, new_state)
  end

  defp score_guess(game = %{turns_left: 1}, _not_good_guess) do
    %{game | game_state: :lost, turns_left: 0}
  end

  defp score_guess(game = %{turns_left: turns_left}, _not_good_guess) do
    %{game | game_state: :bad_guess, turns_left: turns_left - 1}
  end

  defp maybe_won(true), do: :won
  defp maybe_won(_), do: :good_guess

  defp reveal_guessed(letters, used) do
    letters
    |> Enum.map(fn letter ->
      reveal_letter(letter, MapSet.member?(used, letter))
    end)
  end

  defp reveal_letter(letter, _in_word = true), do: letter
  defp reveal_letter(_letter, _not_in_word), do: "_"
end
