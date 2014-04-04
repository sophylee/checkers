# encoding: UTF-8

# Turn-taking is not implemented
## When a piece moves to the end of the board, it becomes a king
## but cannot move like a king. This might have to do with the 
## piece's king status not being updated properly on the dup'd 
## board. 

require "./board.rb"
require "./player.rb"
require './piece.rb'

class Game
  attr_accessor :color

  def initialize
    @board = Board.new(fill_board = true)
    @player1 = Player.new("Player 1", :black)
    @player2 = Player.new("Player 2", :red)
    @color = :red
  end

  def play
    @board.render
    while true
    # until won?(player) # Add won method
      moves = eval(gets.chomp)
      piece_pos = moves.first
      @board.perform_move(moves)
      @board.render
    # end
    end
  end

  def switch_turn
    # Switch @color at the end of each turn
  end

  def won?(player)
    # Count number of opponent's pieces. If it's zero, player has won.
  end
end

Game.new.play