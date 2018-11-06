defmodule Hangman do
  @moduledoc """
  The public API for the Hangman Game.
  """

  def new_game() do
    Hangman.Server.start_link()
  end

  def make_guess(game_pid, guess) do
    GenServer.call(game_pid, {:make_guess, guess})
  end

  def tally(game_pid) do
    GenServer.call(game_pid, {:tally})
  end
end
