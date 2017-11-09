class SearchController < ApplicationController

	layout 'wider_page'

	def index
    if request.xhr?
      respond_to do |format|
        format.html
        # format.json { render json: @resource }
        render :layout => false
      end
    end
	end

end
