defmodule Hangman.Game do
  @moduledoc """
    The implementation of the Hangman game API
  """
  defstruct(
    turns_left: 7,
    game_state: :initalizing,
    letters: []
  )

  @doc """
    Returns a struct with the initial game state

    ## Examples:
      iex> Hangman.Game.new_game()
      %Hangman.Game{}
  """
  def new_game do
    %Hangman.Game{
      letters: Dictionary.random_word() |> String.codepoints()
    }
  end
end
