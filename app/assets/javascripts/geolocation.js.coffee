
@geoLocation = do ->
  geoLocationSupported = do ->
    unless navigator.geolocation then return false else return true
  
  if geoLocationSupported
    {
      get: (success, error) ->
        navigator.geolocation.getCurrentPosition(
          (position) -> 
            success position.coords.latitude, position.coords.longitude,
          ->
            error   
        )
    }
