class @GeoLocationButton extends React.Component

  componentDidMount: ->
    $(document).ready ->
      $('button.location').on 'click', (e) ->
        e.preventDefault()
        navigator.geolocation.getCurrentPosition (position) ->
          $.get '/location', position.coords, (response) ->
            $('#location').val(response.location)
            $('form').submit()

  render: ->
    if navigator.geolocation
      return `<button className="location"><i className="material-icons">my_location</i></button>`
    else
      return null
