// Dossier Form
// ============
function submitDossierForm() {
  $('form.dossier').submit();
}

function addContainerSuggestionBehaviour() {
  if(typeof type_codes != 'undefined'){
    $('.container_type_code_auto_completion').autocomplete({
      source: type_codes
    });
  }
  if(typeof location_codes != 'undefined'){
    $('.container_location_code_auto_completion').autocomplete({
      source: location_codes
    });
  }
}

function addAutoAddNewContainer() {
  var container = $('.container:last');
  var period_input = 'td.container_period input[type=text]';
  var code_input = 'td.type_code input[type=text]';
  var location_input = 'td.location_code input[type=text]';

  container.find(period_input).keyup(function(){
    var text = $(this).val();

    if(text.match(/\d{4}\s?-\s?\d{4}/)){
      $('#add_record_link').trigger('click');
      var yearRegex = /\d{4}\s?-\s?(\d{4})/;
      var new_container = $('.container:last');
      yearRegex.exec(text);
      var year = parseInt(RegExp.$1) + 1;

      new_container.find(period_input).val(year + ' -');
      container.find(code_input).val('DA');
      new_container.find(code_input).val('DH');
      new_container.find(location_input).val(container.find(location_input).val());
      container.find(location_input).val('UG')
      $(this).unbind('keyup', addAutoAddNewContainer());
      addContainerSuggestionBehaviour();
    }
  });
}

function addSyncFirstContainerYear() {
  var year = $('#dossier_first_document_year');

  year.live('blur', function() {
    var first_container = $('#container-list .container:first');
    var period = first_container.find('.container_period input');

    if (period.val() == '') {
      period.val(year.val() + ' -');
    }
  });
}

function addRelationAutoCompletionBehaviour() {
  var text_area = $('#dossier_relation_list');
  var add_relation_input = $('#dossier_add_relation');
  add_relation_input.autocomplete({
    source: function( request, response ) {
      $.ajax({
        url: '/dossiers/search.json',
        dataType: 'json',
        data: {
          page:     1,
          per_page: 10,
          search: {
            text:    request.term
          }
        },
        success: function( data ) {
          response( $.map( data, function( object ) {
            // Accept both Topic and Dossier objects
            var item = object['topic'] || object['dossier'];
            if (item) {
              return {
                label: item['title'],
                value: item['title']
              }
            }
          }));
        }
      });
    },
    minLength: 2,
    select: function(event, ui) {
      var value = ui.item.value;
      var text = text_area.val();

      text_area.val(text + "\n" + value);
      text_area.elastic();
    },
    close: function() {
      add_relation_input.val('').focus();
    }
  });
}

function hideUnlessNewRecord(container) {
 container.find('.container_period').hide();
 container.find('.type_code').hide();
 container.find('.location_code').hide();
 container.prepend('<td class="flash" colspan="3"><input value="Dieser Eintrag wird beim Speichern gelöscht." style="border:solid white;color:red;font-weight:bold;width:100%;" /></td>');
 container.show();
}

function showUnlessNewRecord(container) {
 container.find('.container_period').show();
 container.find('.type_code').show();
 container.find('.location_code').show();
 container.find('.flash').remove();
 container.show();
}
// Edit Reports
// ============
function addEditReportBehaviour() {
  $('#edit_report_header :input, :input.dossier_numbers_year').change(function(){
    var url = 'http://' + window.location.host + window.location.pathname;
    var params = $.param($('#edit_report_header :input, :input.dossier_numbers_year, #search_text').serializeArray());

    window.location.replace(url + '?' + params);
  });
}

function addUpdateDossierNumberBehaviour() {
  var inputs = $('#edit_report input.number');

  inputs.focusout(function(){
    updateNumberAmount(this);
  });

  inputs.keydown(function(event) {
    if(event.keyCode == 13) {
      updateNumberAmount(this);
    }
  });
}

function updateNumberAmount(e){
  var number_id = $(e).data('number_id');
  var dossier_id = $(e).data('dossier_id');
  var year = $(e).data('year');
  var amount = $(e).val();

  if (number_id) {
    $.ajax({
      url: '/dossier_numbers/'+ number_id,
      type: 'PUT',
      data: {
        amount: amount
      }
    });
  } else if (year) {
    $.ajax({
      url: '/dossier_numbers.json',
      type: 'POST',
      dataType: 'json',
      data: {
        dossier_number: {
          amount:     amount,
          from_year:  year,
          to_year:    year,
          dossier_id: dossier_id
        }
      },
      success: function(id){
        $(e).data('number_id', id)
      }
    });
  }
}

// Changelog
function showVersionsBehaviour(){
  $('a#show-unchanged').click(function(){
    $('.unchanged').toggle();
  });
}


function addEditToolTipBehaviour() {
  $('[title!=""]').each(function(){
    var target = $(this);

    if(target.attr('data-parent')) {
      var haha = target.attr('data-parent');

      target = $(this).parents(haha);
      target.attr('title', $(this).attr('title'));
    }

    target.qtip({
      show: {
        solo: true
      },
      style: {
        name: 'blue',
        tip: true,
        width: 200,
        background: '#E5E8E9',
        color: '#00669C',
        border: {
          color: '#00669C'
        }
      },
      position: {
        corner: {
          target: 'topRight',
          tooltip: 'bottomLeft'
        }
      }
    });
  });
}

// Search
// ======
function addSearchSuggestionBehaviour() {
  var input = $('#search_text');
  // Drop out if no such input box
  if (input.length == 0) return;

  function split( val ) {
    return val.split( / \s*/ );
  }
  function extractLast( term ) {
    return split( term ).pop();
  }

  input.attr('autocomplete', 'false');

  input.autocomplete({
    source: function( request, response ) {
      $.ajax({
        url: '/keywords/suggestions.json',
        dataType: 'json',
        data: {
          query:    request.term
        },
        success: function( data ) {
          response( $.map( data, function( object ) {
            var item = object['keyword'];
            return {
              label: item['name'],
              count: item['count']
            }
          }));
          $('.ui-autocomplete').highlight(extractLast(request.term), 'match');
        }
      });
    },
    search: function() {
      // custom minLength
      var term = extractLast( this.value );
      if ( (this.value.length < 2) || (term.length < 1) ) {
        return false;
      }
    },
    focus: function( event, ui ) {
      // input.val( ui.item.label + " ");
      return false;
    },
    select: function( event, ui ) {
      input.val( ui.item.label + " ");
      return false;
    }
  }).data("autocomplete")._renderItem = function( ul, item) {
    return $( "<li></li>" )
        .data( "item.autocomplete", item )
        .append(
          "<a>" + item.label + "<i style='float: right'>(" + item.count + ")</i></a>"
        )
        .appendTo( ul );
  };
  input.keydown(function(event) {
    if(event.keyCode == 13) {
      $(this).parent('form').submit();
    }
  })
}


// Reports
// =======
function addReportColumnMultiselectBehaviour() {
  $.extend($.ui.multiselect.locale, {
    addAll:'Alle hinzufügen',
    removeAll:'Alle entfernen',
    itemsCount:'Spalten ausgewählt'
  });

  $('#report_columns').multiselect();
}

function previewReport() {
  var preview = $('#report-preview');
  var form = $('form.report');
  var action = '/reports/preview';

  $.get(action, form.serializeArray(), function(data){
    preview.html(data);
  });
}

function informUserAboutBigPDF(amount){
  if(amount < 100){
    return true;
  }else{
    return confirm("Sie sind dran ein grosses PDF zugenerieren.\nDies wird einige Zeit in Anspruchen nehmen können.\nMöchten Sie dies wirklich tun?")
  }
}

// Shows the key words in the dossier view.
function showKeyWords() {
  $('#show-key-words-link').hide();
  $('#hide-key-words-link').show();
  $('span.keywords').show();
  $.post('/user_session.json');
}

// Hides the key words in the dossier view.
function hideKeyWords() {
  $('#hide-key-words-link').hide();
  $('#show-key-words-link').show();
  $('span.keywords').hide();
  $.post('/user_session.json?hide_keywords=true');
}

// Adds the CSRF token to all ajax calls.
function addCsrfTokenToAjaxCalls(){
  var csrf_token = $('meta[name=csrf-token]').attr('content');

  $("body").bind("ajaxSend", function(elm, xhr, s){
     if (s.type == "POST") {
        xhr.setRequestHeader('X-CSRF-Token', csrf_token);
     }
  });
}

// Adds the js behaviour to the main navigation for a faster navigation trough the menu.
function addMainNavigationBehaviour() {
  $('#mainmenu a').click(function(e){
    // Unselect old item
    $('#mainmenu .selected').removeClass('selected');
    // Select new item
    $(this).parents('li').addClass('selected');
  });
}
