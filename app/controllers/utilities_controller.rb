
require 'flickraw'

class UtilitiesController < ApplicationController

	def getFlickrImage
		lat = params[:lat]
		lon = params[:lon]
		place = params[:place];
		tags = params[:tags];
		
		bboxOffset = 1;
		
		#construct bbox
		bbox = (lat.to_i - bboxOffset).to_s + "," + (lon.to_i - bboxOffset).to_s + "," + (lat.to_i + bboxOffset).to_s + "," + (lon.to_i + bboxOffset).to_s

		puts bbox
		
		FlickRaw.api_key = APP_CONFIG["flickrApiKey"]
		FlickRaw.shared_secret = APP_CONFIG["flickrApiSharedSecret"]

		list   = flickr.photos.search(:bbox => bbox, :text => place, :tags => tags, :tag_mode => "any", :sort => "date-taken-desc")

		puts list.count

		item   = list[0]
		id     = list[0].id
# 		secret = list[0].secret
# 		info   = flickr.photos.getInfo :photo_id => id, :secret => secret

# 		puts info.title           # => "PICT986"
# 		puts info.dates.taken     # => "2006-07-06 15:16:18"

		sizes    = flickr.photos.getSizes :photo_id => id
		original = sizes.find {|s| s.label == 'Original' }
		#puts original.width       # => "800" -- may fail if they have no original marked image
		
		puts sizes[-1].source
		
		respond_to do |format|
			format.json { render json: sizes }
   	end
	end
	
	def getWeatherData
	
		lat = params[:lat]
		lon = params[:lon]
		
		# get weather data
		request = Typhoeus::Request.new(
			"http://api.openweathermap.org/data/2.5/weather?lat=" + lat.to_s +  "&lon=" + lon.to_s + "&APPID=" + APP_CONFIG['openWeatherApiKey'],
		  method: :get,
		  headers: { Accept: "application/json" }
		)
		request.run

		respond_to do |format|
			format.json { render json: request.response.body }
   	end
	end
	
end
