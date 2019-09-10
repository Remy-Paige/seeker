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

#fix dropdown not working right away
  $(document).ready ->
    $('.dropdown-toggle').dropdown()
    console.log 'jfwejf'
    return
  #show
  $(document).off 'click', '#sticky'
  $(document).on 'click', '#sticky', (e) ->
    $('html,body').scrollTop(0);
  #search results

  $(document).off 'click', '.more'
  $(document).on 'click', '.more', (e) ->
    more_id = this.id.split('_')

    generic_id = more_id[-1..][0]
    console.log(more_id)
    console.log('#more_'+ generic_id)
    $('#less_'+ generic_id).hide()
    $('#more_'+ generic_id).show()
    return false

  $(document).off 'click', '.less'
  $(document).on 'click', '.less', (e) ->
    less_id = this.id.split('_')
    generic_id = less_id[-1..][0]

    console.log(generic_id)
    $('#more_'+ generic_id).hide()
    $('#less_'+ generic_id).css( "display", "block")
    return false

  #edit_section_separation  JS
  $(document).off 'click', '#add_section'
  $(document).on 'click', '#add_section', (e) ->
    e.preventDefault()
    e.stopPropagation()

    counte = $('.delete_section').length
    new_row =  '<div class=' + counte + '>'
    new_row += 'section number'
    new_row += '<br>'
    new_row += '<input type="text" name="section_number[' + counte + '][]" id="section_number_" />'
    new_row += '<br>'
    new_row += 'section name'
    new_row += '</br>'
    new_row += '<input type="text" name="section_name[' + counte + '][]" id="section_name_" />'
    new_row += '<br>'
    new_row += 'page number'
    new_row += '</br>'
    new_row += '<input type="text" name="page_number[' + counte + '][]" id="page_number_"/>'
    new_row += '</div>'

    new_row += '<div class=' + counte + '>'
    new_row += '<textarea name="content[' + counte + '][]" id="content_" class ="edit_section_box"></textarea>'
    new_row += '</div>'

    new_row += '<div class=' + counte + '>'
    new_row += '<div class="languages" id="langauges_' + counte + '">'


    new_row += '</div>'
    new_row += 'Add Language'
    new_row += '<select id="language_' + counte + '" class = "form-control language">'
    new_row += '<option value=""></option>'
    for language in gon.languages
      new_row += '<option value=' + language.id + '>' + language.name + '</option>'
    new_row += '</select>'
    new_row += '<a class="delete_section" id=' + counte + ' data-confirm="Are you sure? All unsaved changes will be lost" href="#">Delete Section</a>'
    new_row += '</div>'

    console.log(new_row)
    $('#sections_box').append(new_row)
    return false;

  $(document.body).off 'change', '.language'
  $(document.body).on 'change', '.language', (e) ->
#  add a language box to the languages div

    language_select_id = this.id.split('_')
    generic_id = language_select_id[-1..][0]
    language_select_value = this.value

    console.log('id' + generic_id)
    console.log('value' + language_select_value)
    console.log('language' + gon.languages[language_select_value])


    count2 = $('#languages_' + generic_id).find('.language_box').length

    newrow = '<div class="language_box strength_0" id="language_box_' +  generic_id + '_' + count2  + '">'
    newrow += gon.languages[language_select_value-1].name
    newrow += '<input type="hidden" name="language_id[' + generic_id + '][]" id="language_id_' +  generic_id + '_' + count2  + '" value="' + language_select_value + '">'
    newrow += '<input type="hidden" name="strength[' + generic_id + '][]" id="strength_' +  generic_id + '_' + count2  + '" value="0">'
    newrow += '<a class="language_remove fas fa-times" href="#" id="language_remove_' +  generic_id + '_' + count2  + '"title="Confirm that this section does not mention this language"></a>'
    newrow += '</div>'
    $('#languages_' + generic_id).append(newrow)
    return false;


  $(document).off 'click', '.language_confirm_human'
  $(document).on 'click', '.language_confirm_human', (e) ->
    dummy = ''
    language_select_id = this.id.split('_')
    box_id_index = language_select_id.length

    generic_id = language_select_id[box_id_index-2]
    box_id = language_select_id[-1..][0]
    console.log('#language_box_' + generic_id + '_' + box_id)


  #  change the value of the associated strength hidden field and update background colour and remove this element
    $('#strength_' + generic_id + '_' + box_id).attr('value', '0')
    $('#language_box_' + generic_id + '_' + box_id).css("background-color", "#449d44")
    $(this).remove()
    return false

  $(document).off 'click', '.language_remove'
  $(document).on 'click', '.language_remove', (e) ->
#  remove the associated language box
    language_select_id = this.id.split('_')
    console.log(language_select_id)
    box_id_index = language_select_id.length
    generic_id = language_select_id[box_id_index-2]
    box_id = language_select_id[-1..][0]
    console.log('#language_box_' + generic_id + '_' + box_id)

    $('#language_box_' + generic_id + '_' + box_id).remove()
    return false;

  $(document).off 'click', '.delete_section'
  $(document).on 'click', '.delete_section', (e) ->
    e.preventDefault()
    e.stopPropagation()
    id = this.id
    $('.'+id).remove()
    return false;




#    old search
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



  # add a filter
  $(document).off 'click', '#add_search'
  $(document).on 'click', '#add_search', (e) ->
    e.preventDefault()
    e.stopPropagation()

#   | .box .added_query | .box .select         | .box .added_field | .box .added_filter_icons | "<i class='question_icon fas fa-question-circle black' id='question_icon_" + counter + "' ></i>"
#   | #added_query_ID   | #added_select_ID     | #added_field_ID   | #added_filter_icons_ID   |
#   |.added_query_select| .added_filter_select |                   | delete button            |

#    selecting .added_query_select fills values in .added_filter_select
#    selecting .added_filter_select adds a box in .added_field and filter icons
    console.log('add search')
    new_row =  "<div class='box added_query' id='added_query_" + counter + "' >"

    new_row += "<select class='added_query_select form-control' name='query_type[" + counter +  "][]' id='added_query_select_" + counter + "' required >"
    new_row += "<option disabled selected value>Select filter</option>"
    new_row += "<option value='text search'>Text Search</option>"
    new_row += "<option value='article paragraph'>Article</option>"
    new_row += "<option value='section number'>Section number</option>"
    new_row += "<option value='strong_language'>Language - Strong Matching</option>"
    new_row += "<option value='medium_language'>Language - Medium Matching</option>"
    new_row += "<option value='weak_language'>Language - Weak Matching</option>"
    new_row += "<option value='country'>Country</option>"
    new_row += "<option value='report type'>Report Type</option>"
    new_row += "<option value='year'>Year</option>"
    new_row += "<option value='cycle'>Cycle</option>"
    new_row += "</select>"


    new_row += "</div>"
    new_row += "<div class='box select' id='added_select_" + counter + "' >"

    new_row += "<select class='added_filter_select form-control' name='filter_type[" + counter +  "][]' id='added_filter_select_" + counter + "' required>"
    new_row += "</select>"

    new_row += "</div>"
    new_row += "<div class='box added_field' id='added_field_" + counter + "' >"


    new_row += "</div>"
    new_row += "<div class='box added_filter_icons' id='added_filter_icons_" + counter + "' >"


    new_row += "<i class='fas fa-times red filter_icon delete_filter' id='delete_filter_" + counter + "' ></i>"

    new_row += "</div>"

    new_row += "<i class='question_icon fas fa--circle black' id='question_icon_" + counter + "' ></i>"
    counter = counter + 1
    field_counter.push(0)
    console.log(field_counter)
    console.log(field_counter[counter])
    console.log(new_row)
    $('.sub_grid').append(new_row)

  # selecting .added_query_select fills values in .added_filter_select
  # add the correct select options for a filter
  # preserve filter select value on query select change
  $(document.body).off 'change', '.added_query_select'
  $(document.body).on 'change', '.added_query_select', (e) ->


    added_query_select_id = this.id.split('_')
    generic_id = added_query_select_id[-1..][0]
    added_query_select_value = this.value

    country_options =
      "<option value='only'>only from</option>" +
      "<option value='none of'>from none of</option>" +
      "<option value='one of'>from one of</option>"
    language_options =
      "<option value='only'>only mentions</option>" +
      "<option value='none of'>mentions none of</option>" +
      "<option value='one of'>mentions one of</option>"
    text_options =
      "<option value='only'>only contains</option>" +
      "<option value='none of'>contains none of</option>" +
      "<option value='one of'>contains at least one of</option>"
    numeric_options =
      "<option value='all'>all</option>" +
      "<option value='only'>only</option>" +
      "<option value='less than'>less than</option>" +
      "<option value='greater than'>greater than</option>" +
      "<option value='between'>between</option>"
    section_number_options =
      "<option value='only'>only</option>" +
      "<option value='none of'>none of</option>" +
      "<option value='one of'>one of</option>"

#    which set of options to add to the select
    option = switch
      when added_query_select_value == 'country' then country_options
      when added_query_select_value == 'strong_language' then language_options
      when added_query_select_value == 'medium_language' then language_options
      when added_query_select_value == 'weak_language' then language_options
      when added_query_select_value == 'text search' then text_options
      when added_query_select_value == 'article paragraph' then section_number_options
      when added_query_select_value == 'section number' then section_number_options
      when added_query_select_value == 'report type' then section_number_options
      when added_query_select_value == 'year' then numeric_options
      when added_query_select_value == 'cycle' then numeric_options


    # preserve filter select value on query select change

    numeric_filters = ['all','only','less than','greater than','between']
    logical_filters = ['only','none of','one of']
#    used to define field type/plus button behaviour later
    numeric_queries = ['Year', 'Cycle']
    logical_queries = ['Section Number', 'article paragraph', 'report type', 'Country','strong_language', 'medium_language','weak_language', 'Text Search']

    filter_select_value = $("#added_filter_select_" + generic_id).val()

    $("#added_filter_select_" + generic_id).empty().append(option);

    #I'm not sure what this does or if its broken. Removing it give undesirable behaviour, and doesnt affect the first values presisting on reload
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
    #update the values
    $("#added_filter_select_" + generic_id).change()

  # for logical filters
  # add a plus button on filter option select
  # remove plus button on filter option select
  # remove any minus buttons left over
  # for numeric filters
  # field changes
  # when the filter type is selected/changed, add the proper input type
  # this also gets triggered on added_query_select change because it calls change on filter to preserve the filter
  $(document.body).off 'change', '.added_filter_select'
  $(document.body).on 'change', '.added_filter_select', (e) ->
    added_filter_select_id = this.id.split('_')
    generic_id = added_filter_select_id[-1..][0]
    added_filter_select_value = this.value
    console.log(generic_id)
    console.log(added_filter_select_value)
    if generic_id < 3
      added_query_select_value = $('#added_query_'+ generic_id).text().trim()
      console.log(added_query_select_value)
      added_query_select_value = added_query_select_value.substr(0,1).toLowerCase()+added_query_select_value.substr(1);
    else
      added_query_select_value = $('#added_query_select_' + generic_id).val()

    if generic_id == "1"
      added_query_select_value = $('#added_query_select_' + generic_id).val()
      console.log('TYPE ERROR fiusfeiojfwoijf')
      console.log(added_query_select_value)
    else
    console.log(added_query_select_value)
#    apart from text - just #added_query_ID
#    text value cant be grabbed with val, has to be grabbed with the snippet above

    #   | .box .added_query        | .box .select         | .box .added_field | .box .added_filter_icons | "<i class='question_icon fas fa-question-circle black' id='question_icon_" + counter + "' ></i>"
    #   | #added_query_select_ID   | #added_select_ID     | #added_field_ID   | #added_filter_icons_ID   |
    #   |.added_query_select       | .added_filter_select | box! + add buttons| delete button            |

    #    selecting .added_query_select fills values in .added_filter_select
    #    selecting .added_filter_select adds a box in .added_field and filter icons


    #define the input types
    plus_button = "<i class='fas fa-plus blue plus_icon plus_filter_field' id='plus_filter_field_" + generic_id + "' ></i>"
    country_select_row = "<select class='form-control' name='keyword[" + generic_id +  "][]' id='keyword_' >"
    for country in gon.countries
      country_select_row += '<option value=' + country.name.replace(' ', '_').replace(' ', '_') + '>' + country.name + '</option>'
    country_select_row += "</select>"

    plus_country_select_row = country_select_row + plus_button

    report_type_select_row = "<select class='form-control' name='keyword[" + generic_id +  "][]' id='keyword_' >"
    i = 0
    for type in gon.report_types
      report_type_select_row += '<option value=' + i.toString() + '>' + type + '</option>'
      i = i + 1
    report_type_select_row += "</select>"

    plus_report_type_select_row = report_type_select_row + plus_button

    language_select_row = "<select class='form-control' name='keyword[" + generic_id +  "][]' id='keyword_' >"
    for language in gon.languages
#      max three words in language - so replace 2 spaces. change if more words
      language_select_row += '<option value=' + language.name.replace(' ', '_').replace(' ', '_') + '>' + language.name + '</option>'
    language_select_row += "</select>"

    plus_language_select_row = language_select_row + plus_button

    nothing_row = "<input type='hidden' name='keyword[" + generic_id + "][]' value='' required>"
    between_row = "<input type='number' name='keyword[" + generic_id + "][]' class='number' required>  -  <input type='number' name='keyword[" + generic_id + "][]' class='number' required>"
    only_row = "<input type='text' name='keyword[" + generic_id + "][]' id='keyword_' required>"
    only_number_row = "<input type='number' name='keyword[" + generic_id + "][]' id='keyword_' required>"
    plus_button_row = "<input type='text' name='keyword[" + generic_id + "][]' id='keyword_' required><i class='fas fa-plus blue plus_icon plus_filter_field' id='plus_filter_field_" + generic_id + "' ></i>"

    if added_query_select_value == 'country'
      field_row = switch
        when added_filter_select_value == null then nothing_row
        when added_filter_select_value == 'all' then nothing_row
        when added_filter_select_value == 'less than' then only_row
        when added_filter_select_value == 'greater than' then only_row
        when added_filter_select_value == 'between' then between_row
        when added_filter_select_value == 'only' then country_select_row
        when added_filter_select_value == 'none of' then plus_country_select_row
        when added_filter_select_value == 'one of' then plus_country_select_row
    else if added_query_select_value == 'report type'
      field_row = switch
        when added_filter_select_value == null then nothing_row
        when added_filter_select_value == 'all' then nothing_row
        when added_filter_select_value == 'less than' then only_row
        when added_filter_select_value == 'greater than' then only_row
        when added_filter_select_value == 'between' then between_row
        when added_filter_select_value == 'only' then report_type_select_row
        when added_filter_select_value == 'none of' then plus_report_type_select_row
        when added_filter_select_value == 'one of' then plus_report_type_select_row
    else if added_query_select_value == 'weak_language' or added_query_select_value == 'medium_language' or added_query_select_value == 'strong_language'
      field_row = switch
        when added_filter_select_value == null then nothing_row
        when added_filter_select_value == 'all' then nothing_row
        when added_filter_select_value == 'less than' then only_row
        when added_filter_select_value == 'greater than' then only_row
        when added_filter_select_value == 'between' then between_row
        when added_filter_select_value == 'only' then language_select_row
        when added_filter_select_value == 'none of' then plus_language_select_row
        when added_filter_select_value == 'one of' then plus_language_select_row
    else if added_query_select_value == 'year' or added_query_select_value == 'cycle'
      field_row = switch
        when added_filter_select_value == null then nothing_row
        when added_filter_select_value == 'all' then nothing_row
        when added_filter_select_value == 'less than' then only_number_row
        when added_filter_select_value == 'greater than' then only_number_row
        when added_filter_select_value == 'between' then between_row
        when added_filter_select_value == 'only' then only_number_row
    else
    #  text search, section number, article paragraph
      field_row = switch
        when added_filter_select_value == null then nothing_row
        when added_filter_select_value == 'all' then nothing_row
        when added_filter_select_value == 'less than' then only_row
        when added_filter_select_value == 'greater than' then only_row
        when added_filter_select_value == 'between' then between_row
        when added_filter_select_value == 'only' then only_row
        when added_filter_select_value == 'none of' then plus_button_row
        when added_filter_select_value == 'one of' then plus_button_row

    delete_button_row = "<i class='fas fa-times red filter_icon delete_filter' id='delete_filter_" + generic_id + "' ></i>"
    invisible_delete_button_row =  "<i class='fas fa-times filter_icon' style='opacity: 0;' id='delete_filter_" + generic_id + "' ></i>"

    $('#added_field_' + generic_id).empty().append(field_row)

    if generic_id >= 3
      $("#added_filter_icons_" + generic_id ).empty().append(delete_button_row)
    else
      $("#added_filter_icons_" + generic_id ).empty().append(invisible_delete_button_row)


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

#    use the value of
#    #added_query_select_ID

    if generic_id == "0" or generic_id == "2"
      added_query_select_value = $('#added_query_'+ generic_id).text().trim()
      added_query_select_value = added_query_select_value.substr(0,1).toLowerCase()+added_query_select_value.substr(1);
    else
      added_query_select_value = $('#added_query_select_' + generic_id).val()
    console.log('addedqueryselect')
    console.log(generic_id)
    console.log(added_query_select_value)

    generic_input =  "<input data-number='" + generic_id + "_" + add_field_number + "' type='text' name='keyword[" + generic_id + "][]' id='keyword_' required>"
    number_input = "<input data-number='" + generic_id + "_" + add_field_number + "' type='number' name='keyword[" + generic_id + "][]' id='keyword_' required>"

    country_select_row = "<select class='form-control' data-number='" + generic_id + "_" + add_field_number + "' name='keyword[" + generic_id +  "][]' id='keyword_' >"
    for country in gon.countries
      country_select_row += '<option value=' + country.name.replace(' ', '_').replace(' ', '_') + '>' + country.name + '</option>'
    country_select_row += "</select>"

    language_select_row = "<select class='form-control' data-number='" + generic_id + "_" + add_field_number + "' name='keyword[" + generic_id +  "][]' id='keyword_' >"
    for language in gon.languages
      language_select_row += '<option value=' + language.name.replace(' ', '_').replace(' ', '_') + '>' + language.name + '</option>'
    language_select_row += "</select>"

    report_type_select_row = "<select class='form-control' name='keyword[" + generic_id +  "][]' id='keyword_' >"
    i = 0
    for type in gon.report_types
      report_type_select_row += '<option value=' + i.toString() + '>' + type + '</option>'
      i = i + 1
    report_type_select_row += "</select>"

#   capitalisation bugf
    input = switch
      when added_query_select_value == 'country' then country_select_row
      when added_query_select_value == 'report type' then report_type_select_row
      when added_query_select_value == 'strong_language' then language_select_row
      when added_query_select_value == 'medium_language' then language_select_row
      when added_query_select_value == 'weak_language' then language_select_row
      when added_query_select_value == 'text search' then generic_input
      when added_query_select_value == 'article paragraph' then generic_input
      when added_query_select_value == 'section number' then generic_input
      when added_query_select_value == 'section Number' then generic_input
      when added_query_select_value == 'year' then number_input
      when added_query_select_value == 'cycle' then number_input

    #add field
    $("#added_field_" + generic_id ).append(input)

    #add new plus button
    new_row_added_plus_button = "<i data='" + add_field_number + "' class='fas fa-plus blue plus_icon plus_filter_field' id='plus_filter_field_" + generic_id + "' ></i>"
    $("#added_field_" + generic_id ).append(new_row_added_plus_button)
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
    $("select[data-number='" + generic_id + "_" + field_number + "']").remove()
    $("i[data-number='" + generic_id + "_" + field_number + "']").remove()

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
