require "rails_helper"

RSpec.describe PawnMovementsController, type: :controller do

  def check_bad_request(commands_array, expected_error_message)
    expect { post :create, params: { commands: commands_array.join("\r\n")} }.to raise_error(ActionController::BadRequest, expected_error_message)
  end

  def check_success_response(commands_array, expected_output)
    post :create, params: { commands: commands_array.join("\r\n") }
    expect(response.status).to eq(200)
    expect(assigns(:output)).to eq(expected_output)
  end

  describe "Create" do

    context "Invalid Inputs" do
      context "Empty commands" do
        it "should raise bad request error" do
          check_bad_request([], "Blank Input")
        end
      end

      context "When first command is not PLACE" do
        it "should raise bad request error" do
          check_bad_request(["test"], "Invalid Input: First line should be PLACE")
        end
      end

      context "When first command is not PLACE" do
        it "should raise bad request error" do
          check_bad_request(["PLACE", "test"], "Invalid Input: Last line should be REPORT")
        end
      end

      context "When initial placement coordinates are wrong" do
        context "When coordinates are not numbers" do
          it "should raise bad request error" do
            check_bad_request(["PLACE test", "REPORT"], "Invalid PLACE command - X coordinate is not a number")
            check_bad_request(["PLACE 1,test", "REPORT"], "Invalid PLACE command - Y coordinate is not a number")
          end
        end

        context "When coordinates are out of range" do
          it "should raise bad request error" do
            check_bad_request(["PLACE 8,1", "REPORT"], "Invalid PLACE command - X coordinate must be less than or equal to 7")
            check_bad_request(["PLACE 1,8", "REPORT"], "Invalid PLACE command - Y coordinate must be less than or equal to 7")
          end
        end
      end

      context "When direction is wrong" do
        it "should raise bad request error" do
          check_bad_request(["PLACE 1,1,test", "REPORT"], "Invalid PLACE command - Direction is not included in the list")
        end
      end

      context "When color is wrong" do
        it "should raise bad request error" do
          check_bad_request(["PLACE 1,1,EAST,test", "REPORT"], "Invalid PLACE command - Color is not included in the list")
        end
      end
    end

    context "Valid Inputs" do
      context "MOVE command" do
        context "When initial movement is 1 or 2" do
          it "should return success response with valid output" do
            check_success_response(["PLACE 0,0,NORTH,WHITE", "MOVE", "REPORT"], "Output: 0,1,NORTH,WHITE")
            check_success_response(["PLACE 0,0,NORTH,WHITE", "MOVE 1", "REPORT"], "Output: 0,1,NORTH,WHITE")
            check_success_response(["PLACE 0,0,NORTH,WHITE", "MOVE 2", "REPORT"], "Output: 0,2,NORTH,WHITE")
          end
        end

        context "When second movement is 2" do
          it "should ignore that movement" do
            check_success_response(["PLACE 0,0,NORTH,WHITE", "MOVE", "MOVE 2", "REPORT"], "Output: 0,1,NORTH,WHITE")
          end
        end

        context "When movement is going out of range" do
          it "should ignore that movement" do
            check_success_response(["PLACE 0,0,NORTH,WHITE", "RIGHT", "MOVE 2", "LEFT", "MOVE", "LEFT", "MOVE", "MOVE", "MOVE", "REPORT"], "Output: 0,1,WEST,WHITE")
          end
        end
      end

      context "RIGHT command" do
        it "should stay on same coordinates & return correct direction" do
          check_success_response(["PLACE 0,0,NORTH,WHITE", "RIGHT", "REPORT"], "Output: 0,0,EAST,WHITE")
          check_success_response(["PLACE 0,0,NORTH,WHITE", "RIGHT", "RIGHT", "REPORT"], "Output: 0,0,SOUTH,WHITE")
          check_success_response(["PLACE 0,0,NORTH,WHITE", "RIGHT", "RIGHT", "RIGHT", "REPORT"], "Output: 0,0,WEST,WHITE")
          check_success_response(["PLACE 0,0,NORTH,WHITE", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "REPORT"], "Output: 0,0,NORTH,WHITE")
        end
      end

      context "LEFT command" do
        it "should stay on same coordinates & return correct direction" do
          check_success_response(["PLACE 0,0,NORTH,WHITE", "LEFT", "REPORT"], "Output: 0,0,WEST,WHITE")
          check_success_response(["PLACE 0,0,NORTH,WHITE", "LEFT", "LEFT", "REPORT"], "Output: 0,0,SOUTH,WHITE")
          check_success_response(["PLACE 0,0,NORTH,WHITE", "LEFT", "LEFT", "LEFT", "REPORT"], "Output: 0,0,EAST,WHITE")
          check_success_response(["PLACE 0,0,NORTH,WHITE", "LEFT", "LEFT", "LEFT", "LEFT", "REPORT"], "Output: 0,0,NORTH,WHITE")
        end
      end

      context "Other examples" do
        it "should return success response with valid output" do
          check_success_response(["PLACE 1,2,EAST,BLACK", "MOVE 2", "MOVE 1", "LEFT", "MOVE", "REPORT"], "Output: 4,3,NORTH,BLACK")
        end
      end
    end

  end

end
