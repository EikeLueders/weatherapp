
require 'flickraw'

class UtilitiesController < ApplicationController

	def getFlickrImages
		tags = params[:tags];
		time = params[:time];
		width = params[:width] || 1280;
		height = params[:height] || 800;
		
#		bboxOffset = 2;
		
		#construct bbox
#		bbox = (lat.to_i - bboxOffset).to_s + "," + (lon.to_i - bboxOffset).to_s + "," + (lat.to_i + bboxOffset).to_s + "," + (lon.to_i + bboxOffset).to_s
		
		FlickRaw.api_key = APP_CONFIG["flickrApiKey"]
		FlickRaw.shared_secret = APP_CONFIG["flickrApiSharedSecret"]

    weatherTime = Time.at(time.to_i)
    
    puts weatherTime
    puts weatherTime.month
    
    if (weatherTime.month > 10 || weatherTime.month <= 2) 
      season = "winter"
    elsif (weatherTime.month > 2 && weatherTime.month <= 5)
      season = "spring"
    elsif (weatherTime.month > 5 && weatherTime.month <= 8)
      season = "summer"
    else
      season = "autumn"
    end
		  
		photos = flickr.photos.search(:content_type => 1, :tags => tags + "," + season, :tag_mode => "all", :extras => "url_l,url_o")
		puts "c:" + photos.count.to_s
		
		usable = Array.new;
		
		photos.each do |i|
            
		  if defined?(i.width_l)
        if i.width_l.to_i < width.to_i
          usable << i.url_l;
        elsif defined?(i.width_o) 
          usable << i.url_o;
        end
      elsif defined?(i.width_o)
        usable << i.url_o;
      end   
		end
		  
#    sizes = flickr.photos.getSizes :photo_id => list[Random.rand(0...list.count)].id
		
		respond_to do |format|
			format.json { render json: usable }
   	end
	end
	
	def getWeatherData
		lat = params[:latitude]
		lon = params[:longitude]
		lang = params[:lang] || "en"
		langs = ["en", "ru", "it", "sp", "ua", "de", "pt", "ro", "pl", "fi", "nl", "fr", "bg", "se", "zh_tw", "zh_cn", "tr"]
		
		if (!langs.include?(lang))
		  lang = "en" 
		end
		
		# get weather data
		request = Typhoeus::Request.new(
#			"http://api.openweathermap.org/data/2.5/weather?lat=" + lat.to_s +  "&lon=" + lon.to_s + "&APPID=" + APP_CONFIG['openWeatherApiKey'] + "&lang=" + lang,
      "https://api.forecast.io/forecast/6978b0e0f9492e453f6e6f51ce66b273/" + lat.to_s + "," + lon.to_s + "?units=si",
		  method: :get,
		  headers: { Accept: "application/json" }
		)
		request.run
		
		result = request.response.body
	
		respond_to do |format|
			format.json { render json: result }
   	end
	end
	
	def getReverseGeolocation
    lat = params[:latitude]
    lon = params[:longitude]
    
    request = Typhoeus::Request.new(
      "http://nominatim.openstreetmap.org/reverse?lat=" + lat.to_s + "&lon=" + lon.to_s + "&format=json",
      method: :get,
      headers: { Accept: "application/json" }
    )
    request.run
    
    result = JSON.parse(request.response.body)
    
    result["address"]["lat"] = lat
    result["address"]["lon"] = lon
    
    puts result

    respond_to do |format|
      format.json { render json: result["address"]}
    end
	end
	
	def getGeolocation
    query = params[:place]
    query << ", city"
    
    request = Typhoeus::Request.new(
      "http://nominatim.openstreetmap.org/search/" + CGI::escape(query) + "?addressdetails=1&format=json",
      method: :get,
      headers: { Accept: "application/json" }
    )
    request.run
    
    puts request.response.body
    
    json = JSON.parse(request.response.body)
    
#    puts json

    respond_to do |format|
      format.json { render json: json[0]}
    end
  end
end
