# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# create global object (bad), but required for location

createContainerIn = (element = 'weatherdata_current_data') ->
  $('<div></div>').addClass('container').appendTo($('#' + element))
    
createCurrentDataTemplateIn = (element = 'weatherdata_current_data', label, value, stylesLabel = ['text_xxs','text_lineheight_40','text_float_left','text_margin_right_s'], stylesValue = ['text_s','text_lineheight_40','text_float_left','text_margin_right_l']) ->
  c = $('<div></div>').addClass('container').appendTo($('#' + element))
  if label
    c.append($('<div></div>').addClass(stylesLabel.join(' ')).html(label))
  if value
    c.append($('<div></div>').addClass(stylesValue.join(' ')).html(value))
  c
  
createHourlyForecastDataTemplateIn = (element = 'weatherdata_hourly_data', label, value, stylesLabel = ['text_xxs','text_lineheight_20','text_align_center','fixed_width_100'], stylesValue = ['text_s','text_lineheight_40','text_align_center','fixed_width_100']) ->
  c = $('<div></div>').addClass('container').appendTo($('#' + element))
  if value
    c.append($('<div></div>').addClass(stylesValue.join(' ')).html(value))
  if label
    c.append($('<div></div>').addClass(stylesLabel.join(' ')).html(label))
  c

createDailyForecastDataTemplateIn = (element = 'weatherdata_daily_data', label, value, stylesLabel = ['text_xxs','text_lineheight_40','text_float_left','text_margin_right_s'], stylesValue = ['text_s','text_lineheight_40','text_float_left','text_margin_right_l']) ->
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
  
setupUI = ->
  # load location list from webstorage
  locations = window.Store.get 'locations'
  if locations?
    locations = JSON.parse locations
    for location in locations
      addLocationToUI location
      
initCurrentLocation = (latitude, longitude) ->
  $.get '/utilities/getReverseGeolocation.json?latitude=' + latitude + '&longitude=' + longitude, (address) ->
    location = new Location(0, address.city, address.country, address.lat, address.lon).save()
    addLocationToUI location
    getWeatherForLocation location
    
      
addLocationToUI = (location) ->
  @addHTML = (location) ->
    ($('<div/>').attr('id', 'locationItem_' + location.id).addClass('location')).append($('<span/>').addClass('locationCityName').html(location.city + ', ')).append($('<span/>').html(location.country)).bind 'click', ->
      # console.log $(this).attr('id').split('_')[1]
      $('.selectedLocation').removeClass('selectedLocation').addClass('location');
      $(this).addClass('selectedLocation')
      getWeatherForPlace $(this).attr('id')
      
  if location.id is 0
    l = @addHTML location
    $('#locations').prepend(l)
    $('.selectedLocation').removeClass('selectedLocation').addClass('location');
    l.addClass('selectedLocation')
  else
    $('#locations').append(@addHTML location)
  
getWeatherForPlace = (place) ->
  id = place.split('_')[1]
  if id?
    # location = loadLocation place.split('_')[1]
    location = Location.find id
    getWeatherForLocation location

getWeatherForLocation = (location) ->
  # reset ui
  $('#weatherdata_current_data').empty()
  $('#weatherdata_hourly_data').empty()
  $('#weatherdata_daily_data').empty()

  $.get '/utilities/getWeatherData.json?latitude=' + location.latitude + '&longitude=' + location.longitude, (weather) ->
    console.log weather
    
    currently = weather.currently
    hourly = weather.hourly.data
    daily = weather.daily.data
    
    # CURRENT CONDITIONS
    # create objects
    temp = new Temp(currently.temperature) if currently.temperature?
    temp_feels = new Temp(currently.apparentTemperature) if currently.apparentTemperature?
    humidity = new Humidity(currently.humidity * 100) if currently.humidity?
    pressure = new Pressure(currently.pressure) if currently.pressure?
    wind = new Wind(currently.windSpeed, currently.windBearing) if currently.windSpeed? && currently.windBearing?
    clouds = new Clouds(currently.cloudCover * 100) if currently.cloudCover?
    visibility = new Visibility(currently.visibility) if currently.visibility?
    
    # create templates
    createCurrentDataTemplateIn('weatherdata_current_data', '', temp.to_s(), [], ['text_l','text_lineheight_60','text_float_left','text_margin_right_l'])
    createCurrentDataTemplateIn('weatherdata_current_data', 'feels like', temp_feels.to_s(), ['text_xxs','text_lineheight_60','text_float_left','text_margin_right_s'], ['text_s','text_lineheight_60','text_float_left','text_margin_right_l']) if temp_feels?
    createCurrentDataTemplateIn('weatherdata_current_data', 'pressure', pressure.to_s()) if pressure?
    createCurrentDataTemplateIn('weatherdata_current_data', 'humidity', humidity.to_s()) if humidity?
    createCurrentDataTemplateIn('weatherdata_current_data', 'wind', wind.to_s()) if wind?
    createCurrentDataTemplateIn('weatherdata_current_data', 'clouds', clouds.to_s()) if clouds?
    createCurrentDataTemplateIn('weatherdata_current_data', 'visiblity', visibility.to_s()) if visibility?

    $('<br/>').addClass('container').appendTo($('#weatherdata_current_data'))

    # HOURLY CONITIONS
    for i in [1..12]
      forecast = hourly[i]
      temp = new Temp(forecast.temperature) if forecast.temperature?
      createHourlyForecastDataTemplateIn('weatherdata_hourly_data', moment.unix(forecast.time).format('HH:mm'), temp.to_s())
    
    # DAILY CONITIONS
    for i in [1..5]
      forecast = daily[i]
      minTemp = new Temp(forecast.temperatureMin) if forecast.temperatureMin?
      maxTemp = new Temp(forecast.temperatureMax) if forecast.temperatureMax?
      createDailyForecastDataTemplateIn('weatherdata_daily_data', moment.unix(forecast.time).format('DD.MM'), '', ['text_xs','text_lineheight_40','text_float_left','text_margin_right_l'])
      createDailyForecastDataTemplateIn('weatherdata_daily_data', 'low', minTemp.to_s())
      createDailyForecastDataTemplateIn('weatherdata_daily_data', 'high', maxTemp.to_s())
      $('<br/>').addClass('clear').appendTo($('#weatherdata_daily_data'))
    
      
    flickrTags = []
    if currently.precipType?
      flickrTags.push currently.precipType
    if currently.cloudCover > 0.5
      flickrTags.push 'clouds'
    if currently.cloudCover <= 0.5 and not currently.precipType 
      flickrTags.push 'sun'
    
      
    $('#weatherdata_3h').text(JSON.stringify(weather))
    
    console.log location
    
    args =
      time: currently.time
      tags: flickrTags.join(', ')
      city: location.city
      width: $(window).width()
      height: $(window).height()
    
    $.get '/utilities/getFlickrImages.json?' + objectToString(args), (images) ->
      console.log images
      images.sort -> 0.5 - Math.random()
      $('body#page').css('background-image', "url(" + images[0] + ")")

saveLocation = (location) ->
  data = localStorage.getItem 'locations'
  if data?
    data = JSON.parse data
  else
    data = []
  
  $.get '/dashboard/addLocation.html?' + objectToString(location), (location) ->
    if location.status is 'created'
      l = new Location(location.id, location.city, location.country, location.latitude, location.longitude).save()
      addLocationToUI l
    else if location.status is 'exists'
      $('.selectedLocation').removeClass('selectedLocation').addClass('location');
      $('#locationItem_' + location.id).addClass('selectedLocation')
      getWeatherForPlace $('#locationItem_' + location.id).attr('id')
    else
      console.log 'failed'
      

searchForLocationByName = (name) ->
  if name.length > 0
    $.get '/utilities/getGeolocation.json?place=' + name, (location) ->
      if location isnt null
        l = 
          city: location.address.city
          country: location.address.country
          latitude: location.lat
          longitude: location.lon
          
        saveLocation l
        console.log location
        
        toggleOverlayWithHeight 200

toggleOverlayWithHeight = (height, callback) ->
  $('#overlay').css('height', height)
  $('#overlay').css('top', -height)
  if $('#overlay').attr('visible') is 'false'
    callback()
    $('#overlay').attr 'visible', 'true'
    $('#overlay').transition {y:"+=" + height}, 1000, 'snap', ->
      console.log 1
      
  else
    $('#overlay').attr 'visible', 'false'
    $('#overlay').transition {y:"-=" + height}, 1000, 'snap', ->
      console.log 2

showLocationSearch = ->
  # clear overlay
  $('#overlay').html '<i class="fa fa-spinner fa-3x fa-spin overlaySpinner"></i>'
  
  $.get '/dashboard/searchform.html', (html) ->
    $('#overlay').html ''
    $('#overlay').append(html)
    $('#addLocationButton').bind 'click', ->
      searchForLocationByName($('#locationSearchField').val())
      console.log $('#locationSearchField').val()
    
showUserProfile = ->
  # clear overlay
  $('#overlay').html '<i class="fa fa-spinner fa-3x fa-spin overlaySpinner"></i>'
  
  $.get '/dashboard/profile.html', (html) ->
    $('#overlay').html ''
    $('#overlay').append(html)
    
@changeSetting = (setting, value) ->
  console.log value
  $.get '/user/settings.html?setting=' + setting + "&value=" + value, (status) ->
    console.log status

$ ->
  # setup localstorage data
  window.Store.expire 'locations'
  
  # load user locations
  $.get '/locations.json', (locations) ->
    for location in locations
      console.log location
      new Location(location.id, location.city, location.country, location.latitude, location.longitude).save()
    setupUI()

  # add current location
  geoLocation.get(
    (lat, lon) ->
      initCurrentLocation lat, lon
    ->
      console.log false
  )
  
  $('#showProfileIcon i').bind 'click', ->
    toggleOverlayWithHeight(220, showUserProfile)
    
  $('#addLocationIcon i').bind 'click', ->
    toggleOverlayWithHeight(200, showLocationSearch)
  
#  navigator.geolocation.getCurrentPosition load
  true