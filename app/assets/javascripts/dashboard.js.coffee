# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# create global object (bad), but required for location

createContainerIn = (element = 'weatherdata_current_data') ->
  $('<div></div>').addClass('container').appendTo($('#' + element))
    
createTemplateIn = (element = 'weatherdata_current_data', label, value, stylesLabel = ['text_xxs','text_lineheight_40','text_float_left','text_margin_right_s'], stylesValue = ['text_s','text_lineheight_40','text_float_left','text_margin_right_l']) ->
  c = $('<div></div>').addClass('container').appendTo($('#' + element))
  if label
    c.append($('<div></div>').addClass(stylesLabel.join(' ')).html(label))
  if value
    c.append($('<div></div>').addClass(stylesValue.join(' ')).html(value))
  c
   
  
intToTime = (time) ->
  new Date(time * 1000)  
  
objectToString = (obj, delimiter1 = '=', delimiter2 = '&') ->
  url = []
  for key, value of obj
    url.push key + delimiter1 + value
  url.join(delimiter2)
  
load = (location) ->
#  lang = navigator.language || navigator.userLanguage
  
  # load location list from webstorage
  locations = localStorage.getItem 'locations'
  if locations?
    locations = JSON.parse locations
    for index, loc of locations
      $('#locations').append(
        ($('<div/>').attr('id', 'locationItem_' + index).addClass('location')).html(loc.city + ', ').append($('<span/>').html(loc.country))
      )
      
  console.log location
  # get location details for current position by reverse geocoding 
  $.get '/utilities/getReverseGeolocation.json?latitude=' + location.coords.latitude + '&longitude=' + location.coords.longitude, (address) ->
    location = 
      city: address.city
      country: address.country
      lat: address.lat
      lon: address.lon
      
    # store current location in webstorage
    localStorage.setItem  'currentLocation',JSON.stringify location
      
    getWeatherForLocation location
    $('#locations').prepend(
      ($('<div/>').attr('id', 'currentLocationItem').addClass('selectedLocation')).html(address.city + ', ').append($('<span/>').html(address.country))
    )

getWeatherForPlace = (place) ->
  if place.split('_')[1]?
    location = loadLocation place.split('_')[1]
  else 
    location = JSON.parse loadLocation 'currentLocation'

  console.log location
#  $.get '/utilities/getGeolocation.json?place=' + place.join(', '), (location) ->
  getWeatherForLocation location

getWeatherForLocation = (location) ->
  # reset ui
  $('#weatherdata_current_data').empty()

  $.get '/utilities/getWeatherData.json?latitude=' + location.lat + '&longitude=' + location.lon, (weather) ->
    console.log weather
    
    currently = weather.currently
    hourly = weather.hourly
    
    # create objects
    temp = new Temp(currently.temperature) if currently.temperature?
    temp_feels = new Temp(currently.apparentTemperature) if currently.apparentTemperature?
    humidity = new Humidity(currently.humidity * 100) if currently.humidity?
    pressure = new Pressure(currently.pressure) if currently.pressure?
    wind = new Wind(currently.windSpeed, currently.windBearing) if currently.windSpeed? && currently.windBearing?
    clouds = new Clouds(currently.cloudCover * 100) if currently.cloudCover?
    visibility = new Visibility(currently.visibility) if currently.visibility?
    
    # create templates
    createTemplateIn('weatherdata_current_data', '', temp.to_s(), [], ['text_l','text_lineheight_60','text_float_left','text_margin_right_l'])
    createTemplateIn('weatherdata_current_data', 'feels like', temp_feels.to_s(), ['text_xxs','text_lineheight_60','text_float_left','text_margin_right_s'], ['text_s','text_lineheight_60','text_float_left','text_margin_right_l']) if temp_feels?
    createTemplateIn('weatherdata_current_data', 'pressure', pressure.to_s()) if pressure?
    createTemplateIn('weatherdata_current_data', 'humidity', humidity.to_s()) if humidity?
    createTemplateIn('weatherdata_current_data', 'wind', wind.to_s()) if wind?
    createTemplateIn('weatherdata_current_data', 'clouds', clouds.to_s()) if clouds?
    createTemplateIn('weatherdata_current_data', 'visiblity', visibility.to_s()) if visibility?

    $('<br/>').addClass('container').appendTo($('#weatherdata_current_data'))
      
    flickrTags = []
    flickrTags.push location.city
    if currently.precipType?
      flickrTags.push currently.precipType
    if currently.cloudCover > 0.5
      flickrTags.push 'clouds'
    if currently.cloudCover <= 0.5 and not currently.precipType 
      flickrTags.push 'sun'
    
      
    $('#weatherdata_3h').text(JSON.stringify(weather))
    
    args =
      time: currently.time
      tags: flickrTags.join(', ')
      width: $(window).width()
      height: $(window).height()
    
    $.get '/utilities/getFlickrImages.json?' + objectToString(args), (images) ->
      console.log images
      
      images.sort -> 0.5 - Math.random()
      
      $('#background').html('<img src="' + images[0] + '" />')

saveLocation = (location) ->
  data = localStorage.getItem 'locations'
  if data?
    data = JSON.parse data
  else
    data = []
  
  data.push location
    
  localStorage.setItem  'locations',JSON.serialize data

loadLocation = (index) ->
  data = localStorage.getItem 'locations'
  if data?
    data = JSON.parse data
  else
    false
  
  data[index]

      
$ ->
  # setup localstorage data
  localStorage.removeItem 'locations'
  locations = [
    {city: "Stockholm", country: "Sweden", lat: 59.3251172, lon: 18.0710935},
    {city: "Berlin", country: "Germany", lat: 52.5170365, lon: 13.3888599}
  ]
  localStorage.setItem 'locations',JSON.stringify locations

  userLang = navigator.language || navigator.userLanguage
  load({coords:{latitude: 65.6141768, longitude: 22.17783859}})
              
  $('#settings').bind 'click', ->
    # show settings
  
  $('.location, .currentLocation').bind 'click', ->
    console.log $(this).attr('id').split('_')[1]
    $('.selectedLocation').removeClass('selectedLocation').addClass('location');
    $(this).addClass('selectedLocation')
    
    getWeatherForPlace $(this).attr('id')
  
#  navigator.geolocation.getCurrentPosition load
  true