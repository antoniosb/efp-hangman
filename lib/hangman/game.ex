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
    Returns a struct with the initial game state

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

  def make_move(game = %{game_state: state}, _guess) when state in [:won, :lost] do
    {game, tally(game)}
  end

  def make_move(game, guess) do
    game = accept_move(game, guess, MapSet.member?(game.used, guess))
    {game, tally(game)}
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

  defp score_guess(game, _not_good_guess) do
    game
  end

  defp maybe_won(true), do: :won
  defp maybe_won(_), do: :good_guess

  defp tally(_game) do
    123
  end
end
