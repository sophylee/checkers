require "colorize"

class Board
  attr_accessor :rows
  attr_reader :fill_board

  def initialize(fill_board = true)
    set_board(fill_board)
  end

  def []pos
    row, col = pos
    @rows[row][col]
  end

  def []=(pos, piece)
    raise "Invalid move: That move falls off the board." unless valid_pos?(pos)

    row, col = pos
    @rows[row][col] = piece
  end

  def dup
    dup_board = Board.new(false)
    self.pieces.each do |piece|
      p piece.king, piece.position
      dup_board[piece.position] = Piece.new(piece.color, piece.position, piece.king)
    end
    dup_board
  end

  def perform_move(moves)
    dup_moves = moves.dup
    dup_board = self.dup
    self.render

    until dup_moves.count < 2
      start_pos = dup_moves[0]
      end_pos = dup_moves[1]
      move_diff = start_pos[0] - end_pos[0]
      if move_diff.abs == 1
        raise "Can't slide that many steps" if moves.count > 2
        perform_slide(start_pos, end_pos, dup_board)
        dup_moves.shift
      elsif move_diff.abs == 2
        perform_jump(start_pos, end_pos, dup_board)
        dup_moves.shift
      else
        raise "Can't move that many steps."
      end
    end
    self.perform_move!(moves)
  end

  def perform_move!(moves)
    until moves.count < 2
      start_pos = moves[0]
      end_pos = moves[1]
      move_diff = start_pos[0] - end_pos[0]
      if move_diff.abs == 1
        perform_slide(start_pos, end_pos, self)
        moves.shift
      elsif move_diff.abs == 2
        perform_jump(start_pos, end_pos, self)
        moves.shift
      else
        raise "Can't move that many steps."
      end
    end
  end

  def perform_slide(start_pos, end_pos, board)
    raise "Invalid slide." unless valid_slide?(start_pos, end_pos, board)
    board[end_pos] = board[start_pos] # update the board
    board[start_pos].position = end_pos # change the piece's pos to end pos
    maybe_promote(board[end_pos]) # update the piece to a king if necessary
    board[start_pos] = nil # remove the piece from the start pos
  end

  def perform_jump(start_pos, end_pos, board)
    raise "Invalid jump." unless valid_jump?(start_pos, end_pos, board)
    jumped_pos = start_pos.zip(end_pos).map { |x, y| x - (x - y) / 2 }
    board[end_pos] = board[start_pos] # update the board
    board[start_pos].position = end_pos # change the piece's pos to end pos
    maybe_promote(board[end_pos]) # update the piece to a king if necessary
    board[start_pos] = nil # remove the piece from the start pos
    board[jumped_pos] = nil # remove the attacked piece
  end

  def maybe_promote(piece)
    piece.color == :red ? shore = 0 : 7
    piece.position[0] == shore ? piece.king = true : piece.king = piece.king
  end

  def valid_slide?(start_pos, end_pos, board)
    board[start_pos].color == :red ? valid_dy = -1 : valid_dy = 1
    raise "Cannot move backwards." if board[start_pos].king != true && end_pos[0] - start_pos[0] != valid_dy
    board[end_pos].is_a?(Piece) ? false : true
  end

  def valid_jump?(start_pos, end_pos, board)
    jumped_pos = start_pos.zip(end_pos).map { |x, y| x - (x - y) / 2 }
    if board[jumped_pos].is_a?(Piece) && board[jumped_pos].color != board[start_pos].color
      return true
    else
      false
    end
  end

  def valid_pos?(pos)
    pos.all? { |coord| coord.between?(0, 7) }
  end

  def set_board(fill_board)
    @rows = Array.new(8) { Array.new(8) }
    if fill_board == true
      valid_squares.each do |pos|
        if pos.first <= 2 # Set all black pieces
          self[pos] = Piece.new(:black, pos)
        elsif pos.first >= 5 # Set all red pieces
          self[pos] = Piece.new(:red, pos)
        else
          next # Skip the square if no piece
        end
      end
    end
  end

  def render # Displays the board
    puts "  0  1  2  3  4  5  6  7"
    @rows.each_with_index do |row, row_idx|
      print row_idx
      row.each_with_index do |square, sq_idx|
        if square.nil? && valid_squares.include?([row_idx, sq_idx])
          print "   ".colorize(:black).on_light_white
        elsif square.nil? && !valid_squares.include?([row_idx, sq_idx])
          print "   ".colorize(:black).on_cyan
        else
          print square.render(square.color)
        end
      end
      print row_idx
      print "\n"
    end
    puts "  0  1  2  3  4  5  6  7"
  end

  def pieces
    @rows.flatten.compact
  end

  def valid_squares
    valid_squares = []
    (0..7).each do |row|
      (0..7).each do |col|
        valid_squares << [row, col] if (row + col).even?
      end
    end
    valid_squares
  end

end