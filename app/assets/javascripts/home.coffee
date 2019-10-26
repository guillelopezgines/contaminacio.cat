$(document).ready ->
  $('form.pollutant').on 'change', ->
    $(this).submit()
  $('form.district select').on 'change', ->
    window.location.href = $(this).val()