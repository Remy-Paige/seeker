# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#fix dropdown not working right away
$(document).ready ->
  $('.dropdown-toggle').dropdown()
  console.log 'jfwejf'
  return

$(document).off 'click', '.closer'
$(document).on 'click', '.closer', (e) ->
  e.preventDefault()
  e.stopPropagation()
  $('#flash').empty()
  console.log('flash empty')