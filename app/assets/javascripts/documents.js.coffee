# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

section_separation_table = ->
  $(document).off 'click', '#add_section'
  $(document).on 'click', '#add_section', (e) ->
    e.preventDefault()
    e.stopPropagation()
    new_row = '<tr>'
    new_row += '<td><input type="text" name="section_number[]" size="8"/></td>'
    new_row += '<td><input type="text" name="section_name[]" size="40"/></td>'
    new_row += '<td><textarea name="content[]" rows="10" cols="100"/></td>'
    new_row += '<td>'
    new_row += $('.language_list').html()
    new_row += '</td>'
    new_row += '<td><a href="#" class="delete_section" data-confirm="Are you sure? All unsaved changes will be lost">Delete Section</a></td>'
    new_row += '</tr>'
    $('#section_table').append(new_row)
    return

  $(document).off 'click', '.delete_section'
  $(document).on 'click', '.delete_section', (e) ->
    e.preventDefault()
    e.stopPropagation()
    $(this).closest('tr').remove()

$(document).on "page:change", ->
  section_separation_table()
