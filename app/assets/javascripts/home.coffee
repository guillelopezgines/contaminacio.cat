$(document).ready ->

  $('form.pollutant').on 'change', ->
    $(this).submit()

  $('select.district').on 'change', ->
    window.location.href = $(this).val()

  $('select.level').on 'change', ->
    num_params = window.location.href.split('/').length
    if $(this).val().length > 0
      level = "/" + $(this).val()
    else
      level = $(this).val()

    if num_params == 4
      window.location.href = "/escoles" + level
    else if num_params == 5
      switch window.location.href.split('/')[4]
        when 'infantil', 'primaria', 'secundaria', 'batxillerat', 'educacio-especial' then window.location.href = "/escoles" + level
        else window.location.href = "/escoles/" + window.location.href.split('/')[4] + level
    else if num_params == 6
      window.location.href = "/escoles/" + window.location.href.split('/')[4] + level
      

  $('td.button').on 'click', ->
    $('table.schools').addClass('expanded')

window.initMap = ->
  bounds = new google.maps.LatLngBounds()
  map = new google.maps.Map(
    document.getElementById('map'), {
      zoom: 13,
      center: {lat: 41.401136, lng: 2.206897},
      mapTypeId: 'terrain',
      zoomControl: true,
      mapTypeControl: false,
      scaleControl: false,
      streetViewControl: false,
      rotateControl: false,
      fullscreenControl: true
    }
  )
  for school in window.schools
    marker = new google.maps.Marker({
      position: {lat: school.latitude, lng: school.longitude},
      map: map,
      icon: {
        path: google.maps.SymbolPath.CIRCLE,
        scale: 5,
        fillColor: school.color,
        fillOpacity: 1.0,
        strokeWeight: 0,
        strokeColor: "#FFF"
      }
    })
    bounds.extend(marker.position)
  map.fitBounds(bounds)
  setTimeout ( ->
    if map.getZoom() < 13
      map.setZoom(13)
  ), 200
  window.map = map