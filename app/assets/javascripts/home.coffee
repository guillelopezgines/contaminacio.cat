$(document).ready ->

  $('form.pollutant').on 'change', ->
    $(this).submit()

  $('select.district').on 'change', ->
    window.location.href = $(this).val()

  $('select.level').on 'change', ->
    $.post "/escoles", {school_level: $(this).val()}, ->
      window.location.reload()

  $('td.button').on 'click', ->
    $('table.schools').addClass('expanded')