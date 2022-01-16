class PawnPosition
  include ActiveModel::Model

  attr_accessor :x_coordinate, :y_coordinate, :direction, :color,
    :next_x_coordinate, :next_y_coordinate, :is_moved

  DIRECTIONS = [ "NORTH", "EAST", "SOUTH", "WEST" ]
  COLORS = [ "BLACK", "WHITE" ]
  DIRECTION_COORDINATE_MAPPING = {
    "NORTH": { coordinate: "y", movement_type: "+" },
    "EAST": { coordinate: "x", movement_type: "+" },
    "SOUTH": { coordinate: "y", movement_type: "-" },
    "WEST": { coordinate: "x", movement_type: "-" },
  }

  validates :x_coordinate, :y_coordinate,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 7 },
    presence: true
  validates :direction, inclusion: { in: DIRECTIONS }, presence: true
  validates :color, inclusion: { in: COLORS }, presence: true
  validates :next_x_coordinate, :next_y_coordinate,
    numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 7 },
    allow_blank: true

  def report
    "Output: #{x_coordinate},#{y_coordinate},#{direction},#{color}"
  end

  def move(movement = 1)
    return if invalid_movement?(movement)

    new_position =  current_movement_coordinate.send(current_movement_type, movement)
    send("next_#{ current_movement_axis }_coordinate=", new_position)
    if valid?
      send("#{ current_movement_axis }_coordinate=", new_position)
      @is_moved = true
    end
  end

  def change_direction(direction_movement)
    return unless ["RIGHT", "LEFT"].include?(direction_movement)
    direction_movement_operator = (direction_movement == "RIGHT") ? "+" : "-"
    new_direction_index = current_direction_index.send(direction_movement_operator, 1) % 4
    @direction = DIRECTIONS[new_direction_index]
  end

  private

  def invalid_movement?(movement)
    return true if [1, 2].exclude?(movement)
    movement == 2 && @is_moved
  end

  def current_movement_axis
    DIRECTION_COORDINATE_MAPPING[direction.to_sym][:coordinate]
  end

  def current_movement_type
    DIRECTION_COORDINATE_MAPPING[direction.to_sym][:movement_type]
  end

  def current_movement_coordinate
    send("#{ current_movement_axis }_coordinate")
  end

  def current_direction_index
    current_direction_index = DIRECTIONS.find_index(direction)
  end

end
