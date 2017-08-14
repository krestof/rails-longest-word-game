class GameController < ApplicationController

  def guess
    @grid = Array.new(9).map { [*("A".."Z")].sample }
    # session[:grid_attributes] = @grid.attributes
    @time = Time.now
    # flash[:grid] = params[:number]
  end

  def display
    @attempt = params[:answer]
    @grid = params[:grid].split("")
    @start_time = params[:time].to_i
    @end_time = Time.now.to_i
    @result = run_game(@grid, @attempt, @start_time, @end_time)
    @average = average(@result)
  end

  private

  def average(result)
    session[:result] ||= []
    session[:time] ||= []
    session[:result] << result[:score]
    session[:time] << result[:time]
    average = {}
    average[:score] = session[:result].inject(0, :+) / session[:result].size
    average[:time] = session[:time].inject(0, :+) / session[:time].size
    average[:play_count] = session[:result].size
    return average
  end

  def run_game(grid, attempt, start_time, end_time)
    score = 0
    win_score = (100 / (end_time - start_time)) * attempt.length
    message = grid_validation(attempt, grid)
    message == "well done" ? score = win_score : score = 0
    {
      time: end_time - start_time,
      score: score,
      message: message
    }
  end

  def grid_validation(attempt,grid)
    valid_letters = 0
    attempt.upcase.split("").each do |letter|
      if @grid.include? letter
        valid_letters += 1
        @grid.delete(letter)
      end
    end
    valid_letters != attempt.length ? message("grid_false") : api_validation(attempt)
  end

  def api_validation(attempt)
    url = "http://wagon-dictionary.herokuapp.com/#{attempt.downcase}"
    JSON.parse(open(url).read)["found"] ? message(true) : message("api_false")
  end

  def message(validation_result)
    case validation_result
    when "grid_false"
      "not in the grid"
    when "api_false"
      "not an english word"
    else
      "well done"
    end
  end

end
