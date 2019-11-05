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

  $('[data-action=move][data-latitude][data-longitude][data-index]').on 'click', (e) ->
    e.preventDefault()
    lat = $(this).attr('data-latitude')
    lng = $(this).attr('data-longitude')
    index = $(this).attr('data-index')
    marker = window.markers[index]
    infowindow = marker.infowindow
    window.map.panTo(new google.maps.LatLng(lat, lng))
    window.map.setZoom(15)
    infowindow.open(window.map, marker)
    window.closePreviousInfowindow(infowindow)
    $("html, body").animate({ scrollTop: $("#map").offset().top - 20 }, "slow");

window.initMap = ->
  window.infowindow = false
  window.markers = {}
  bounds = new google.maps.LatLngBounds()
  styledMapType = new google.maps.StyledMapType(
    [
      {
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#f5f5f5"
          }
        ]
      },
      {
        "elementType": "labels",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#f5f5f5"
          }
        ]
      },
      {
        "featureType": "administrative.land_parcel",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "administrative.land_parcel",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#bdbdbd"
          }
        ]
      },
      {
        "featureType": "administrative.neighborhood",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#eeeeee"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels.text",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "poi.business",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#e5e5e5"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#ffffff"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "road.arterial",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#dadada"
          }
        ]
      },
      {
        "featureType": "road.highway",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "featureType": "road.local",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
      },
      {
        "featureType": "transit",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "transit.line",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#e5e5e5"
          }
        ]
      },
      {
        "featureType": "transit.station",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#eeeeee"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#c9c9c9"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
      }
    ],
    {name: 'Styled Map'}
  )
  map = new google.maps.Map(
    document.getElementById('map'), {
      zoom: 13,
      center: {lat: 41.401136, lng: 2.206897},
      zoomControl: true,
      mapTypeControl: false,
      scaleControl: false,
      streetViewControl: false,
      rotateControl: false,
      fullscreenControl: true
    }
  )
  map.mapTypes.set('styled_map', styledMapType)
  map.setMapTypeId('styled_map')
  i = 0
  for school in window.schools
    marker = new google.maps.Marker({
      position: {lat: school.latitude, lng: school.longitude},
      map: map,
      icon: {
        url: "https://www.contaminacio.cat/markers/"+ school.color.replace('#','') + ".png?v=1",
        scaledSize: new google.maps.Size(10, 10)
      }
    })
    marker.infowindow = new google.maps.InfoWindow({
      content: school.info
    })
    marker.addListener 'click', () ->
      self = this
      this.infowindow.open(map, this)
      google.maps.event.addListener this.infowindow,'closeclick', ->
        window.infowindow = false
      window.closePreviousInfowindow(this.infowindow)
      window.timeout = setTimeout ( ->
        self.infowindow.close()
        window.infowindow = false
      ), 5000

    if school.id != 632
      bounds.extend(marker.position)
    window.markers[i] = marker
    i++
  map.fitBounds(bounds)
  setTimeout ( ->
    if map.getZoom() < 13
      map.setZoom(13)
  ), 200
  window.map = map

window.closePreviousInfowindow = (infowindow)->
  if window.infowindow
    window.infowindow.close()
    clearTimeout window.timeout
  window.infowindow = infowindow
  