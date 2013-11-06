# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/



createContainerIn = (element = 'weatherdata_current_data') ->
  $('<div></div>').addClass('container').appendTo($('#' + element))
    
createTemplate = (label, value, stylesLabel = ['text_xxs','text_lineheight_40','text_float_left','text_margin_right_s'], stylesValue = ['text_xs','text_lineheight_40','text_float_left','text_margin_right_l']) ->
  if label
    l = $('<div></div>').addClass(stylesLabel.join(' ')).html(label)
  if value
    v = $('<div></div>').addClass(stylesValue.join(' ')).html(value)
  if l and v then l.add(v) else v
   
  
intToTime = (time) ->
  new Date(time * 1000)  
  
objectToString = (obj, delimiter1 = '=', delimiter2 = '&') ->
  url = []
  for key, value of obj
    url.push key + delimiter1 + value
  url.join(delimiter2)
  
load = (location) ->
  coords = location.coords
  lang = navigator.language || navigator.userLanguage
  args = 
    lat: coords.latitude
    lon: coords.longitude
    lang: lang
    
  $.get '/utilities/getLocationData.json?' + objectToString(args), (address) ->
    $('#locations').prepend(($('<div/>').addClass('selectedLocation')).html(address.city + ', ').append($('<span/>').html(address.country)))
#    $('#country').html(address.country)
    
    $.get '/utilities/getWeatherData.json?' + objectToString(args), (weather) ->
      console.log weather
      
      currently = weather.currently
      hourly = weather.hourly
      
      temp = new Temp(currently.temperature)
      temp_feels = new Temp(currently.apparentTemperature)
      
      humidity = new Humidity(currently.humidity * 100)
      pressure = new Pressure(currently.pressure)
      
      wind = new Wind(currently.windSpeed, currently.windBearing)
      
      clouds = new Clouds(currently.cloudCover * 100)
      
      visibility = new Visibility(currently.visibility)
    
      
      createContainerIn('weatherdata_current_data')
      .append(createTemplate('', temp.to_s(), [], ['text_l','text_lineheight_60','text_float_left','text_margin_right_l']))
      .append(createTemplate('feels like', temp_feels.to_s(), ['text_xxs','text_lineheight_60','text_float_left','text_margin_right_s'], ['text_xs','text_lineheight_60','text_float_left','text_margin_right_l']))
      
      createContainerIn('weatherdata_current_data')
      .append(createTemplate('pressure', pressure.to_s()))
      .append(createTemplate('humidity', humidity.to_s()))
        
      createContainerIn('weatherdata_current_data')
      .append(createTemplate('wind', wind.to_s()))
  
      createContainerIn('weatherdata_current_data')
      .append(createTemplate('clouds', clouds.to_s()))
      .append(createTemplate('visiblity', visibility.to_s()))
      
              
      $('<br/>').addClass('container').appendTo($('#weatherdata_current_data'))
        
      flickrTags = []
      flickrTags.push address.city
      if currently.precipType?
        flickrTags.push currently.precipType
      if currently.cloudCover > 0.5
        flickrTags.push 'clouds'
      else
        flickrTags.push 'sun'
     
      $('#weatherdata_3h').text(JSON.stringify(weather))
      
      args =
        time: currently.time
        tags: flickrTags.join(', ')
      
      $.get '/utilities/getFlickrImage.json?' + objectToString(args), (image) ->
        console.log image
        
        $('#background').html('<img src="' + image[image.length-1].source + '" />')

      
      
$(document).ready ->
  userLang = navigator.language || navigator.userLanguage
  load({coords:{latitude: 65.6141768, longitude: 22.177838599999998}})
#  navigator.geolocation.getCurrentPosition load
  true