# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).ready ->
    navigator.geolocation.getCurrentPosition applyLocation

	  applyLocation = (location) ->
	      coords = location.coords
	      $.get '/utilities/getWeatherData.json?lat=' + coords.latitude + '&lon=' + coords.longitude, (weather) ->
			      console.log weather
			      $('#weatherdata').text(JSON.stringify(weather));
			      $.get '/utilities/getFlickrImage.json?lat=' + weather.coord.lat + '&lon=' + weather.coord.lon + '&place=' + weather.name + '&tags=' + weather.weather[0].main, (image) ->
				        console.log image
				        $('#weatherimage').html('<img src="' + image[image.length-1].source + '" width=500 />');