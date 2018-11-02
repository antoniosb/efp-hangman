defmodule Hangman do
  @moduledoc """
  The public API for the Hangman Game.
  """
  alias Hangman.Game

  defdelegate new_game(), to: Game
end
