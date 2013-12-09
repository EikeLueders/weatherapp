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
  
  def add_location_to_user
    @current_user = view_context.current_user
    if @current_user
      if params[:city] and params[:country] and params[:latitude] and params[:longitude]
        
        location = Location.find(:first, :conditions => [ "city = ? and country = ?", params[:city], params[:country]])
        
        if location
          
          locationdata = {
            :status => "exists",
            :id => location.id
          }
          
          render json: locationdata.to_json 
          return
        end
        
        location = Location.new
        location.user = @current_user
        location.city = params[:city]
        location.country = params[:country]
        location.latitude = params[:latitude]
        location.longitude = params[:longitude]
        location.save!
        
        locationdata = {
          :status => "created",
          :id => location.id,
          :city => location.city,
          :country => location.country,
          :latitude => location.latitude,
          :longitude => location.longitude
        }
        
        render json: locationdata.to_json
        return
      else
        locationdata = {
          :status => "failed"
        }
        render json: locationdata.to_json
        return
      end
      locationdata = {
        :status => "failed"
      }
      render json: locationdata.to_json
    end
  end
end
