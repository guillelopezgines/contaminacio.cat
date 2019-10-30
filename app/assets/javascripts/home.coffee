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