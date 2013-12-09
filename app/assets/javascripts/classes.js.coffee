class @Value
  constructor: (@value) ->
    
  to_s: ->
    return @value


class @Temp extends @Value  
  constructor: (value, @format = 'C', @round = 1) ->
      super value

  to_s: ->
    if @format == 'C' 
      return @value.toFixed(@round) + ' &deg;' + @format 
    else
      return (@value * 1.8).toFixed(@round) + ' &deg;' + @format
        
      
class @Pressure extends @Value
  constructor: (value, @format = 'mb', @round = 0) ->
    super value
    
  to_s: ->
    if @format == 'mb' 
      return @value.toFixed(@round) + ' ' + @format 
    else if @format == 'hPa'
      return @value.toFixed(@round) + ' ' + @format
        
      
class @Humidity extends @Value
  constructor: (value, @format = '%', @round = 0) ->
    super value
    
  to_s: ->
    return @value.toFixed(@round) + ' ' + @format 
    

class @Wind extends @Value
  constructor: (value, @value2, @format = 'm/s', @round = 0) ->
    super value
    if @value2 >= 11.25 and @value2 < 33.75
      @from = 'NNE'
    else if @value2 >= 33.75 and @value2 < 56.25
      @from = 'NE'
    else if @value2 >= 56.25 and @value2 < 78.75
      @from = 'ENE'
    else if @value2 >= 78.75 and @value2 < 101.25
      @from = 'E'
    else if @value2 >= 101.25 and @value2 < 123.75
      @from = 'ESE'
    else if @value2 >= 123.75 and @value2 < 146.25
      @from = 'SW'
    else if @value2 >= 146.25 and @value2 < 168.75
      @from = 'SSW'
    else if @value2 >= 168.75 and @value2 < 191.25
      @from = 'S'
    else if @value2 >= 191.25 and @value2 < 213.75
      @from = 'SSW'
    else if @value2 >= 213.75 and @value2 < 236.25
      @from = 'SW'
    else if @value2 >= 236.25 and @value2 < 258.75
      @from = 'WSW'
    else if @value2 >= 258.75 and @value2 < 281.25
      @from = 'W'
    else if @value2 >= 281.25 and @value2 < 303.75
      @from = 'WNW'
    else if @value2 >= 303.75 and @value2 < 326.25
      @from = 'NW'
    else if @value2 >= 326.25 and @value2 < 348.75
      @from = 'NNW'
    else
      @from = 'N'
    
  to_s: ->
    return @value.toFixed(@round) + ' ' + @format + ' from ' + @from
 
    
class @Rain extends @Value
  constructor: (value, @format = 'mm/h', @divisor = 3, @round = 2) ->
    super value
    
  to_s: ->
    return (@value / @divisor).toFixed(@round) + ' ' + @format

        
class @Clouds extends @Value
  constructor: (value, @format = '%', @round = 0) ->
    super value
    
  to_s: ->
    return (@value).toFixed(@round) + ' ' + @format
    
 
class @Visibility extends @Value
  constructor: (value, @format = 'km', @round = 0) ->
    super value
    
  to_s: ->
    return (@value).toFixed(@round) + ' ' + @format
    
    
class @Location 
  constructor: (@id, @city, @country, @latitude, @longitude) ->
    
  save: ->
    try 
      locations = JSON.parse(window.Store.get 'locations')
    catch 
      locations = []
    locations.push this
    window.Store.set 'locations', JSON.stringify locations
    return this
    
  @find: (id) ->
    locations = JSON.parse window.Store.get 'locations'
    for location in locations
      return location if location.id is parseInt id

