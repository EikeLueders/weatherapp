module UtilitiesHelper
  
def getGeolocationHelper place
  request = Typhoeus::Request.new(
    "http://nominatim.openstreetmap.org/search?city=" + CGI::escape(place) + "&addressdetails=1&format=json",
    method: :get,
    headers: { Accept: "application/json" }
  )
  request.run
  
  puts "#####"
  puts request.response.body
  puts "#####"
  
  json = JSON.parse(request.response.body)
  
  places = []
  
  for place in json
    puts "#######"
    puts place
    puts place["type"]
    puts "#######"
    if place["type"] == "city" || place["type"] == "town"
      return place
    end  
  end
end
  
end
