# encoding: UTF-8

class Piece
  attr_accessor :position, :king
  attr_reader :color

  def initialize(color, position, king = false)
    @color = color
    @position = position
  end

  def symbols
    { :black => " ✪ ", :red => " ✪ " }
  end

  def render(color)
    symbols[self.color].colorize(color).on_light_white
  end
end