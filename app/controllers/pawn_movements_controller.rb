class PawnMovementsController < ApplicationController
  before_action :parse_commands, only: [:create]

  def new
  end

  def create
    @commands_array.each do |command|
      case command[0]
      when "PLACE"
        x_coordinate = command[1].to_i if command[1].to_i.to_s == command[1]
        y_coordinate = command[2].to_i if command[2].to_i.to_s == command[2]
        @pawn_position = PawnPosition.new(x_coordinate: x_coordinate, y_coordinate: y_coordinate, direction: command[3], color: command[4])
        raise_bad_request("Invalid PLACE command - #{@pawn_position.errors.full_messages.first}") unless @pawn_position.valid?
      when "MOVE"
        movement = command[1].present? ? command[1].to_i : 1
        @pawn_position.move(movement)
      when "LEFT", "RIGHT"
        @pawn_position.change_direction(command[0])
      when "REPORT"
        @output = @pawn_position.report
      end
    end

    render :new
  end

  private

  def parse_commands
    raise_bad_request("Blank Input") if params[:commands].blank?
    @commands_array = params[:commands].split("\r\n").inject([]) do |result, command|
      result << command.split(/ |,/) if command.strip.present?
      result
    end
    raise_bad_request("Blank Input") if @commands_array.blank?
    raise_bad_request("Invalid Input: First line should be PLACE") if @commands_array.first[0] != "PLACE"
    raise_bad_request("Invalid Input: Last line should be REPORT") if @commands_array.last[0] != "REPORT"
  end

  def raise_bad_request(message)
    raise ActionController::BadRequest.new(message)
  end

end
