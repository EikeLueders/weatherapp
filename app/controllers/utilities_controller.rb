
require 'flickraw'

class UtilitiesController < ApplicationController

	def getFlickrImage
		tags = params[:tags];
		time = params[:time];
		
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
		  
		list   = flickr.photos.search(:content_type => 1, :tags => tags + "," + season, :tag_mode => "all")
		puts "c:" + list.count.to_s

    sizes = flickr.photos.getSizes :photo_id => list[Random.rand(0...list.count)].id
		
		respond_to do |format|
			format.json { render json: sizes }
   	end
	end
	
	def getWeatherData
		lat = params[:lat]
		lon = params[:lon]
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

		respond_to do |format|
			format.json { render json: request.response.body }
   	end
	end
	
	def getLocationData
    lat = params[:lat]
    lon = params[:lon]
    
    request = Typhoeus::Request.new(
      "http://nominatim.openstreetmap.org/reverse?lat=" + lat.to_s + "&lon=" + lon.to_s + "&format=json",
      method: :get,
      headers: { Accept: "application/json" }
    )
    request.run
    
    json = JSON.parse(request.response.body)
    
    puts json

    respond_to do |format|
      format.json { render json: json["address"]}
    end
	end
end
