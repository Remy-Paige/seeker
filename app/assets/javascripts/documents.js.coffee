# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#off to only fire event once

counter = 3
field_counter = []
field_counter[0] = 0
field_counter[1] = 0
field_counter[2] = 0
documents_scripts = ->

  #section JS - not search form and untouched
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

  $(document).off 'click', '.delete_section'
  $(document).on 'click', '.delete_section', (e) ->
    e.preventDefault()
    e.stopPropagation()
    $(this).closest('tr').remove()


  $(document).off 'click', '#add_old_search'
  $(document).on 'click', '#add_old_search', (e) ->
    e.preventDefault()
    e.stopPropagation()
    queries = $('.available_queries')
    new_row = '<tr>'
    new_row += '<td width="30%"><select name="query[]">'

    for query in queries
      query = query.value
      new_row += '<option value="' + query + '">' + query + '</option>'

    new_row += '</select></td>'
    new_row += '<td width="70%"><input type="text" name="keyword[]" id="keyword_" style="width:100%"></td>'
    new_row += '<td>&nbsp;<a href="#" class="delete_section">x</a></td>'
    new_row += '</tr>'
    console.log(new_row)
    $('#search_form').append(new_row)


  ##### advanced search #####

  # TODO: make icons look more like buttons?
  # TODO: fix basic search text box width
  # TODO: fix between boxes width
  # TODO/abandoned: fix padding of added filter field
  # TODO: fix length of section number word in select box
  # TODO: add an all box for the 'always there' country and lanague
  # TODO: go over filter and pop up wording



  # TODO: change the filter options avalible for section number - it is a text field

  # TODO: add a 'article' feature that gets all sections from one article
  # TODO: make section number, country and languages be always there
  # TODO: add everything to the 'add filter' dropdown
  # TODO: figure out how to make it easily parasable for ruby when submitted
  # TODO: look into need to mark sections as multiple languages
  # TODO: add report type

  # TODO: all still has an unneccasary X button - and returns 0 keywords




  # TODO: get country/language autocomplete / select boxes (aaa?)
  # TODO: sanity/type checking
  # TODO: document some of this shit so I don't forgget my naming conventions

  # TODO: look into refresh issues - previous value maintained in select




  # add a filter
  $(document).off 'click', '#add_search'
  $(document).on 'click', '#add_search', (e) ->
    e.preventDefault()
    e.stopPropagation()

    new_row =  "<div class='box added_query' id='added_query_" + counter + "' >"

    new_row += "<select class='added_query_select' name='query_type[" + counter +  "][]' id='added_query_select_" + counter + "' >"
    new_row += "<option value='select'>Select filter</option>"
    new_row += "<option value='section number'>Section number</option>"
    new_row += "<option value='language'>Language</option>"
    new_row += "<option value='country'>Country</option>"
    new_row += "<option value='text search'>Text Search</option>"
    new_row += "<option value='year'>Year</option>"
    new_row += "<option value='cycle'>Cycle</option>"
    new_row += "</select>"


    new_row += "</div>"
    new_row += "<div class='box select' id='added_select_" + counter + "' >"

    new_row += "<select class='added_filter_select' name='filter_type[" + counter +  "][]' id='added_filter_select_" + counter + "' >"
    new_row += "</select>"

    new_row += "</div>"
    new_row += "<div class='box added_field' id='added_field_" + counter + "' >"


    new_row += "</div>"
    new_row += "<div class='box added_filter_icons' id='added_filter_icons_" + counter + "' >"

    new_row += "</div>"

    new_row += "<i class='question_icon fas fa-question-circle black' id='question_icon_" + counter + "' ></i>"
    counter = counter + 1
    field_counter.push(0)
    console.log(field_counter)
    console.log(field_counter[counter])
    console.log(new_row)
    $('.sub_grid').append(new_row)

# use this not simply  $('select').change (e) -> to get the dynamically added content
# http://api.jquery.com/on/#direct-and-delegated-events
  # add the correct select options for a filter
  # preserve filter select value on query select change
  $(document.body).off 'change', '.added_query_select'
  $(document.body).on 'change', '.added_query_select', (e) ->
    added_query_select_id = this.id.split('_')
    generic_id = added_query_select_id[-1..][0]
    added_query_select_value = this.value

    country_options = "<option value='only'>only from</option>" +
      "<option value='none of'>from none of</option>" +
      "<option value='one of'>from one of</option>"
    language_options = "<option value='only'>only mentions</option>" +
      "<option value='none of'>mentions none of</option>" +
      "<option value='one of'>mentions one of</option>"
    text_options = "<option value='only'>only contains</option>" +
      "<option value='none of'>contains none of</option>" +
      "<option value='one of'>contains at least one of</option>"
    numeric_options = "<option value='all'>all</option>" +
      "<option value='only'>only</option>" +
      "<option value='less than'>less than</option>" +
      "<option value='greater than'>greater than</option>" +
      "<option value='between'>between</option>"
    section_number_options = "<option value='only'>only</option>" +
      "<option value='none of'>none of</option>" +
      "<option value='one of'>one of</option>"


    option = switch
      when added_query_select_value == 'country' then country_options
      when added_query_select_value == 'language' then language_options
      when added_query_select_value == 'text search' then text_options
      when added_query_select_value == 'section number' then section_number_options
      when added_query_select_value == 'year' then numeric_options
      when added_query_select_value == 'cycle' then numeric_options


    # preserve filter select value on query select change

    numeric_filters = ['all','only','less than','greater than','between']
    logical_filters = ['only','none of','one of']
    numeric_queries = ['Year', 'Cycle']
    logical_queries = ['Section Number','Country', 'Language', 'Text Search']

    filter_select_value = $("#added_filter_select_" + generic_id).val()

    $("#added_filter_select_" + generic_id).empty().append(option);


    #if the old filter select value is the same type as the new query select value can preserve the option
    if numeric_filters.includes(filter_select_value) && numeric_queries.includes(added_query_select_value)
      value = switch
        when filter_select_value == null then $("#added_filter_select_" + generic_id).val(null)
        when filter_select_value == 'all' then $("#added_filter_select_" + generic_id).val('all')
        when filter_select_value == 'only' then $("#added_filter_select_" + generic_id).val('only')
        when filter_select_value == 'less than' then $("#added_filter_select_" + generic_id).val('less than')
        when filter_select_value == 'greater than' then $("#added_filter_select_" + generic_id).val('greater than')
        when filter_select_value == 'between' then $("#added_filter_select_" + generic_id).val('between')
    if logical_filters.includes(filter_select_value) && logical_queries.includes(added_query_select_value)
      value = switch
        when filter_select_value == null then $("#added_filter_select_" + generic_id).val(null)
        when filter_select_value == 'only' then $("#added_filter_select_" + generic_id).val('only')
        when filter_select_value == 'one of' then $("#added_filter_select_" + generic_id).val('one of')
        when filter_select_value == 'none of' then $("#added_filter_select_" + generic_id).val('none of')
    else
      #they don't match
      $("#added_filter_select_" + generic_id).val(null)

    $("#added_filter_select_" + generic_id).change()

  # for logical filters
  # add a plus button on filter option select
  # remove plus button on filter option select
  # remove any minus buttons left over
  # for numeric filters
  # field changes
  $(document.body).off 'change', '.added_filter_select'
  $(document.body).on 'change', '.added_filter_select', (e) ->
    added_filter_select_id = this.id.split('_')
    generic_id = added_filter_select_id[-1..][0]
    added_filter_select_value = this.value
    console.log(added_filter_select_value)

    nothing_row = "<input type='hidden' name='keyword[" + generic_id + "][]' value=''>"
    between_row = "<input type='text' name='keyword[" + generic_id + "][]' class='number'>  -  <input type='text' name='keyword[" + generic_id + "][]' class='number'>"
    only_row = "<input type='text' name='keyword[" + generic_id + "][]' id='keyword_'>"
    plus_button_row = "<input type='text' name='keyword[" + generic_id + "][]' id='keyword_'><i class='fas fa-plus blue plus_icon plus_filter_field' id='plus_filter_field_" + generic_id + "' ></i>"
    delete_button_row = "<i class='fas fa-times red filter_icon delete_filter' id='delete_filter_" + generic_id + "' ></i>"

    field_row = switch
      when added_filter_select_value == null then nothing_row
      when added_filter_select_value == 'all' then nothing_row
      when added_filter_select_value == 'less than' then only_row
      when added_filter_select_value == 'greater than' then only_row
      when added_filter_select_value == 'between' then between_row
      when added_filter_select_value == 'only' then only_row
      when added_filter_select_value == 'none of' then plus_button_row
      when added_filter_select_value == 'one of' then plus_button_row

    filter_row = delete_button_row

    $('#added_field_' + generic_id).empty().append(field_row)
    $("#added_filter_icons_" + generic_id ).empty().append(filter_row)


  #remove a whole filter
  $(document.body).off 'click', '.delete_filter'
  $(document.body).on 'click', '.delete_filter', (e) ->
    delete_filter_id = this.id.split('_')
    generic_id = delete_filter_id[-1..][0]

    $("#added_query_" + generic_id).remove()
    $("#added_select_" + generic_id).remove()
    $("#added_field_" + generic_id).remove()
    $("#added_filter_icons_" + generic_id).empty()
    $("#delete_filter_" + generic_id).remove()
    $("#added_filter_icons_" + generic_id).remove()
    $("#question_icon_" + generic_id).remove()
    #dont do this because of removing an element before the last one
    #counter = counter - 1

  #add a filter field
  $(document.body).off 'click', '.plus_filter_field'
  $(document.body).on 'click', '.plus_filter_field', (e) ->
    plus_filter_field_id = this.id.split('_')

    generic_id = plus_filter_field_id[-1..][0]

    console.log(generic_id)
    console.log(field_counter)
    console.log(field_counter[generic_id])
    #add one to the count of fields here and update array
    number_existing_fields = field_counter[generic_id]
    add_field_number = number_existing_fields + 1
    field_counter[generic_id] = add_field_number

    console.log(field_counter[generic_id])

    #remove the exisitng plus button
    $(this).remove()

    #add field and new plus button
    new_row_added_field =  "<input data-number='" + generic_id + "_" + add_field_number + "' type='text' name='keyword[" + generic_id + "][]' id='keyword_'>"
    new_row_added_field += "<i data='" + add_field_number + "' class='fas fa-plus blue plus_icon plus_filter_field' id='plus_filter_field_" + generic_id + "' ></i>"
    $("#added_field_" + generic_id ).append(new_row_added_field)

    #add new minus button
    new_row = "<i data-number='" + generic_id + "_" + add_field_number + "' class='fas fa-times orange minus_filter_added_field' id='minus_filter_added_field_" + generic_id + "' ></i>"
    $("#added_filter_icons_" + generic_id).append(new_row)

  #remove a filter field
  $(document.body).off 'click', '.minus_filter_added_field'
  $(document.body).on 'click', '.minus_filter_added_field', (e) ->
    minus_filter_added_field_id = this.id.split('_')
    generic_id = minus_filter_added_field_id[-1..][0]

    data_number = $(this).attr("data-number")
    field_number = data_number.split("_")[-1..][0]
    console.log("minus")
    console.log(field_number)
    $("input[data-number='" + generic_id + "_" + field_number + "']").remove()
    $("i[data-number='" + generic_id + "_" + field_number + "']").remove()

  #display appropriate help hint based on form status
  $(document.body).off 'mouseover', '.question_icon'
  $(document.body).on 'mouseover', '.question_icon', (e) ->
    id = this.id
    console.log("hover")
    if id != 'ignore'
      console.log("not ignore")
      question_icon_id = this.id.split('_')
      generic_id = question_icon_id[-1..][0]
      query_select_id = "#added_query_select_" + generic_id
      query_select_value = $(query_select_id).val()
      if query_select_value == 'select'
        console.log("select")
        $(this).attr('title', "please select a field to filter on")
      else
        filter_select_id = "#added_filter_select_" + generic_id
        filter_select_value = $(filter_select_id).val()
        console.log(query_select_value)
        console.log(filter_select_value)

        option = switch
          when query_select_value == 'country' && filter_select_value == 'only' then $(this).attr('title', "This filter will return sections from documents that are released by the country you input")
          when query_select_value == 'country' && filter_select_value == 'none of' then $(this).attr('title', "This filter will return sections from documents that are released by all countries except the ones you input")
          when query_select_value == 'country' && filter_select_value == 'one of' then $(this).attr('title', "This filter will return sections from documents that are released by the countries you input")
          when query_select_value == 'language' && filter_select_value == 'only' then $(this).attr('title', "This filter will return sections that are associated with the language you input. Note that this can be unreliable, you may want to use a text search instead")
          when query_select_value == 'language' && filter_select_value == 'none of' then $(this).attr('title', "This filter will return sections that are associated with all languages except the ones you input. Note that this can be unreliable, you may want to use a text search instead")
          when query_select_value == 'language' && filter_select_value == 'one of' then $(this).attr('title', "This filter will return sections that are associated with the languages you input. Note that this can be unreliable, you may want to use a text search instead")
          when query_select_value == 'text search' && filter_select_value == 'only' then $(this).attr('title', "This filter will search the content of documents and return sections that contain the input string")
          when query_select_value == 'text search' && filter_select_value == 'none of' then $(this).attr('title', "This filter will search the content of documents and return all sections that do not contain any of the input strings listed")
          when query_select_value == 'text search' && filter_select_value == 'one of' then $(this).attr('title', "This filter will search the content of documents and return all sections that contain any of the input strings")


$(document).on "page:change", ->
  documents_scripts()
