class LocationsController < ApplicationController
  
  def get_locations_by_currentuser
    
    locations = view_context.current_user ? view_context.current_user.locations : [] 
    
    respond_to do |format|
      format.json { render json: locations}
    end
  end
  
end
