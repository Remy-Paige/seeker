# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/


$(document).off 'click', '.close'
$(document).on 'click', '.close', (e) ->
  e.preventDefault()
  e.stopPropagation()
  $('#flash').empty()
  console.log('flash empty')