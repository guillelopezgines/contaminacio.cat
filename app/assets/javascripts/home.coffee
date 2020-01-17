$(document).ready ->

  window.map = initMap() if $('#map').length

  $('form.pollutant').on 'change', ->
    $(this).submit()

  $('select.year').on 'change', ->
    if $(this).val() == '2018'
      window.location.href = '/escoles/2018'
    else
      window.location.href = '/escoles'

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
      if(window.location.href.split('/')[4] == '2018')
        window.location.href = "/escoles/2018" + level
      else
        switch window.location.href.split('/')[4]
          when 'infantil', 'primaria', 'secundaria', 'batxillerat', 'educacio-especial' then window.location.href = "/escoles" + level
          else window.location.href = "/escoles/" + window.location.href.split('/')[4] + level
    else if num_params == 6
      if(window.location.href.split('/')[4] == '2018')
        switch window.location.href.split('/')[5]
          when 'infantil', 'primaria', 'secundaria', 'batxillerat', 'educacio-especial' then window.location.href = "/escoles/2018" + level
          else window.location.href = "/escoles/2018/" + window.location.href.split('/')[5] + level
      else
        window.location.href = "/escoles/" + window.location.href.split('/')[4] + level
    else if num_params == 7
      window.location.href = "/escoles/2018/" + window.location.href.split('/')[5] + level
      
  $('td.button').on 'click', ->
    $('table.schools').addClass('expanded')

  $('[data-action=move][data-latitude][data-longitude][data-index]').on 'click', (e) ->
    e.preventDefault()
    lat = $(this).attr('data-latitude')
    lng = $(this).attr('data-longitude')
    index = $(this).attr('data-index')
    coordinates = [lng, lat]

    window.map.flyTo({ 
      center: [lng, lat],
      zoom: Math.max(window.map.getZoom(), 16)
    })
    window.popup.remove() if window.popup
    window.popup = new mapboxgl.Popup({
      offset: 8,
      closeButton: false
    })
      .setLngLat(coordinates)
      .setHTML(window.schools[index].info)
      .addTo(window.map);
    $("html, body").animate({ scrollTop: $("#map").offset().top - 20 }, "slow");

window.initMap = ->
  mapboxgl.accessToken = 'pk.eyJ1IjoiZ3VpbGxlbG9wZXpnaW5lcyIsImEiOiJjazVncnMxYmUwYTFjM2xwYmh4ajdiajJsIn0.-3EAGbfQ0UCr3PiBD1CGKA'
  zoom = if window.innerWidth < 400 then 11 else 12
  pitch = 50
  prebearing = -55
  bearing = -45
  bounds = new mapboxgl.LngLatBounds()
  for school in window.schools
    bounds.extend [school.longitude, school.latitude] unless school.id == 632

  map = new mapboxgl.Map({
    container: 'map',
    style: 'mapbox://styles/mapbox/light-v10',
    center: [2.17591, 41.39006],
    zoom: zoom,
    hash: false,
    pitch: pitch,
    bearing: prebearing
  })
    .addControl(new mapboxgl.FullscreenControl())
    .on 'click', 'schools', (e) ->
      coordinates = e.features[0].geometry.coordinates.slice()
      description = e.features[0].properties.description
      while Math.abs(e.lngLat.lng - coordinates[0]) > 180
        coordinates[0] += e.lngLat.lng > coordinates[0] ? 360 : -360
      window.popup = new mapboxgl.Popup({
          offset: 8,
          closeButton: false
        })
        .setLngLat(coordinates)
        .setHTML(description)
        .addTo(map);
      map.flyTo({ 
        center: coordinates,
        zoom: Math.max(window.map.getZoom(), 14)
      })
    .on 'mouseenter', 'schools', ->
      map.getCanvas().style.cursor = 'pointer'
    .on 'mouseleave', 'schools', ->
      map.getCanvas().style.cursor = ''
    .on "load", ->
      for layer in map.getStyle().layers
        if layer.type == "symbol" and layer.layout["text-field"]
          map.addLayer({
            id: "3d-buildings",
            source: "composite",
            "source-layer": "building",
            filter: ["==", "extrude", "true"],
            type: "fill-extrusion",
            minzoom: 15,
            paint: {
              "fill-extrusion-color": "#aaa",
              "fill-extrusion-height": ["interpolate", ["linear"], ["zoom"], 15, 0, 15.05, ["get", "height"]],
              "fill-extrusion-base": ["interpolate", ["linear"], ["zoom"], 15, 0, 15.05, ["get", "min_height"]],
              "fill-extrusion-opacity": 0.6
            }
          }, layer.id)
          break
      features = []
      for school, index in window.schools.slice(0).reverse()
        features.push {
          'type': 'Feature',
          'properties': {
            'description': school.info,
            'color': school.color
          },
          'geometry': {
            'type': 'Point',
            'coordinates': [school.longitude, school.latitude]
          }
        }
      map
        .addSource('schools-source', {
          'type': 'geojson',
          'data': {
            'type': 'FeatureCollection',
            'features': features
          }
        })
        .addLayer({
          'id': 'schools',
          'type': 'circle',
          'source': 'schools-source',
          'paint': {
            'circle-radius': 6,
            'circle-color': ["get", "color"]
          }
        })
    
    if window.district
      if schools.length == 1
        map.fitBounds bounds, {bearing: bearing, zoom: zoom + 2 }
      else
        map.fitBounds bounds
    else
      setTimeout ->
        map.flyTo({
          zoom: zoom + 0.5,
          speed: 0.05,
          bearing: bearing
        }, )
      , 1

    return map
