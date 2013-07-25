class SeriesController < ApplicationController

	def index
		@players = Player.where("disqualification = ? AND name != ? AND name != ?", false, 'NoName', '^Ksa^').order("best_average ASC, average ASC") 

		respond_to do |format|
			format.html # index.html.erb
			format.json { render json: @players }
		end
	end

end
