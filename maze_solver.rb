class Maze
  def initialize maze
    @maze = maze
    @start_square = Square.new(find_start_pos, nil, distance_from_end(find_start_pos))
    @open_list = [@start_square]
    @closed_list = []
  end

  def self.from_file(file)
    self.new(File.readlines(file).map { |line| line.chomp.chars })
  end

  def find_start_pos
    find_pos("S")
  end

  def find_end_pos
    find_pos("E")
  end

  def find_pos(chr)
    @maze.each_with_index do |row, row_idx|
      row.each_with_index do |item, col_idx|
        return [row_idx, col_idx] if item == chr
      end
    end
  end

  def display
    @maze.each {|row| puts row.join(" ")}
    puts ""
  end

  def astar
    while true
      @open_list.sort! { |x, y| x.f <=> y.f }
      lowest_f_sq = @open_list[0]
      @closed_list << @open_list.delete(lowest_f_sq) # put start pos in closed list
      # add adjacent pos to open list
      adjacent_positions(lowest_f_sq .pos).each do |pos|
        if is_clear?(pos) && @closed_list.all? { |sq| sq.pos != pos }
          if @open_list.all? { |sq| sq.pos != pos }
            @open_list << Square.new(pos, lowest_f_sq , distance_from_end(pos))
          end
        end
      end

      if @closed_list.any? { |sq| sq.pos == find_end_pos }
        puts "victory"
        break
      elsif @open_list.empty?
        puts "Defeat"
        break
      end
    end

    # display results
    sq = (@closed_list.select {| sq | sq.pos == find_end_pos })[0]
    while sq.parent
      sq = sq.parent
      self[sq.pos] = "X" if sq.parent
    end

    display
  end

  def adjacent_positions(pos)
    [[pos[0] - 1, pos[1]], [pos[0],pos[1] + 1], [pos[0] + 1, pos[1]], [pos[0], pos[1] - 1]]
  end

  def is_clear?(pos)
    self[pos] == " " || self[pos] == "E"
  end

  def [] pos
    row, col = pos
    @maze[row][col]
  end

  def []= pos, mark
    row, col = pos
    @maze[row][col] = mark
  end

  def distance pos_1, pos_2
    ((pos_1[0] - pos_2[0]).abs + (pos_1[1] - pos_2[1]).abs) * 10
  end

  def distance_from_end pos
    distance pos, find_end_pos
  end
end

class Square
  attr_accessor :pos, :parent, :g
  def initialize pos, parent, h
    @pos = pos
    @parent = parent
    unless @parent
      @g = 0
    else
      @g = @parent.g + 10
    end
    @h = h
  end

  def f
    @g + @h
  end
end
