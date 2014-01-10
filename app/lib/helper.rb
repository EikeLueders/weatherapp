
class Helper
  
  def self.getGeolocation place
    place << ", city"
    
    request = Typhoeus::Request.new(
      "http://nominatim.openstreetmap.org/search/" + CGI::escape(place) + "?addressdetails=1&format=json",
      method: :get,
      headers: { Accept: "application/json" }
    )
    request.run
    
    puts request.response.body
    
    json = JSON.parse(request.response.body)
  end
  
end