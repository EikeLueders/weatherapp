class UserController < ApplicationController
  def update_settings
    if params[:setting] and params[:value]
      
      if params[:setting] == "background"
        user = view_context.current_user
        user.only_locations_backgrounds = params[:value] == 'true' ? true : false
        user.save
        
        render text: "true"
        return
      end
    end
    render text: "false"
  end
end
