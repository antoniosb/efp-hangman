defmodule Hangman.Game do
  @moduledoc """
    The implementation of the Hangman game API
  """
  defstruct(
    turns_left: 7,
    game_state: :initializing,
    letters: []
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
    %Hangman.Game{
      letters: Dictionary.random_word() |> String.codepoints()
    }
  end

  def make_move(game = %{game_state: state}, _guess) when state in [:won, :lost] do
    {game, tally(game)}
  end

  def tally(game) do
    123
  end
end
