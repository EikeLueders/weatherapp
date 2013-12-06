class DashboardController < ApplicationController
  def index
    
  end
  
  def create_location
    @location = Location.new(params[:post])
    @location.save
  end
  
  def show_search_form
    respond_to do |format|
      format.html { render :partial => "searchform" }
    end
  end
  
  def show_user_profile
    respond_to do |format|
      format.html { render :partial => "profile" }
    end
  end


end
