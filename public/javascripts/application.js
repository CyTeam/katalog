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

function addUpdateLastContainerTitleOfDossier() {
  var inputs = $('.dossier-last-container-title');

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
  var dossier_id = $(e).attr('data-dossier');
  var number_id = $(e).attr('data-number');
  var year = $(e).attr('data-number-year');
  var amount = $(e).val();

  if(number_id != null){
    $.ajax({
      url: '/dossiers/' + dossier_id + '/dossier_numbers/'+ number_id,
      type: 'PUT',
      data: {
        amount: amount
      }
    });    
  }
  
  if(year != null){
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
        $(e).attr('data-number', id)
      }
    });
  }
}

function showVersionsBehaviour(){
  $('a#show-unchanged').click(function(){
    $('.unchanged').toggle();
  });
}

function addAutoAddNewContainer() {
  var container = $('.container:last');
  var first_input = 'td.container_title input[type=text]';
  var second_input = 'td.type_code input[type=text]';
  var last_input = 'td.location_code input[type=text]';

  container.find(first_input).keyup(function(){
    var text = $(this).val();

    if(text.match(/\d{4}\s?-\s?\d{4}/)){
      $('#add_record_link').trigger('click');
      var yearRegex = /\d{4}\s?-\s?(\d{4})/;
      var new_container = $('.container:last');
      yearRegex.exec(text);
      var year = parseInt(RegExp.$1) + 1;

      new_container.find(first_input).val(year + ' -');
      container.find(second_input).val('DA');
      new_container.find(second_input).val('DH');
      new_container.find(last_input).val(container.find(last_input).val());
      $(this).unbind('keyup', addAutoAddNewContainer());
      addContainerSuggestionBehaviour();
    }
  });
}

function addRelationAutoCompletionBehaviour() {
  var text_area = $('#dossier_relation_list');
  var insert_link = $('#insert_relation');
  text_area.after(insert_link);
  insert_link.click(function(e){
    var id = 'relation_list_auto_completion';
    var link = $('#insert_relation');
    e.preventDefault();
    text_area.after('<input type="text" value="Um nach einem Querverweis zu suchen. Hier den Suchbegriff eingeben." size="50" id="' + id + '" style="margin-left:25%;width:74%;">');
    link.hide();
    $('#' + id).focusin(function(){
      var input = $(this);
      input.val('');
      input.autocomplete({
        source: function( request, response ) {
          $.ajax({
            url: '/dossiers/search.json',
            dataType: 'json',
            data: {
              page:     1,
              per_page: 10,
              query:    request.term
            },
            success: function( data ) {
              response( $.map( data, function( object ) {
                var item = object['dossier'];
                return {
                  label: item['title'],
                  value: item['title']
                }
              }));
            }
          });
        },
        minLength: 2,
        select: function(event, ui) {
          var value = ui.item.value;
          var text = text_area.val();
          
          input.remove();
          link.show();
          text_area.val(text + "\n" + value);
          text_area.elastic();
        }
      });
    });
  });

  if($('#dossier_relation_list').val() == ''){
    $('#insert_relation').trigger('click');
  }
}

function hideUnlessNewRecord(container) {
 container.find('.container_title').hide();
 container.find('.type_code').hide();
 container.find('.location_code').hide();
 container.prepend('<td class="flash" colspan="3"><input value="Dieser Eintrag wird beim Speicher gelöscht." style="border:solid white;color:red;font-weight:bold;" /></td>');
 container.show();
}

function showUnlessNewRecord(container) {
 container.find('.container_title').show();
 container.find('.type_code').show();
 container.find('.location_code').show();
 container.find('.flash').remove();
 container.show();
}

function addEditToolTipBehaviour() {
  if(!$.browser.msie) { // Disabled for IE cause the selector made some problems.
    $('[title!=""]').each(function(){
      var target = $(this);

      if(target.attr('data-parent')) {
        var haha = target.attr('data-parent');

        target = $(this).parents(haha);
        target.attr('title', $(this).attr('title'));
      }

      target.qtip({
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
}

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

function addEditReportBehaviour() {
  $('select.dossier_numbers_year, #dossier_numbers_year_amount').change(function(){
    var url = getEditReportLink()
    window.location.replace(url);
  });
}

function getEditReportLink() {
  var link = 'http://' + window.location.host + window.location.pathname;
  var present_amount = $('select.dossier_numbers_year').lenght;
  var requested_amount = $('#dossier_numbers_year_amount').val();
  var inserted_amount = 0;
  var last_year_link = '';
  
  link += '?search[signature]=' + $.query.get('search[signature]').toString();
  
  $('select.dossier_numbers_year').each(function(){
    if(inserted_amount < requested_amount) {
      last_year_link = '&dossier_numbers[year][]=' + $(this).val();
      link += last_year_link;
      inserted_amount++;
    }
  });
  
  for(var i = inserted_amount; i < requested_amount; i++){
    link += last_year_link;
  }
  
  return link ;
}

function informUserAboutBigPDF(amount){
  if(amount < 100){
    return true;
  }else{
    return confirm("Sie sind dran ein grosses PDF zugenerieren.\nDies wird einige Zeit in Anspruchen nehmen können.\nMöchten Sie dies wirklich tun?")
  }
}

function submitDossierForm() {
  $('form.dossier').submit();
}

function truncateToHighlighted(element) {
  element.find('.keywords > span').each(function() {
    var keyword = $(this);
    if ($(this).find('.match').length == 0) {
      keyword.remove();
    };
  });
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

function addTopicIndexBehaviour() {
  var topic_links = $('#topic_index li a');
  
  topic_links.live('click', function(){
    showSubTopics($(this));
  });
  
  topic_links.live('mouseenter', function() {
    var topic_link = $(this);
    var signature = topic_link.attr('data-signature');
    
    if(!signature.match(/^\d*\.\d*\.\d*$/) && !topic_link.hasClass('children-loaded')) {
      var id = topic_link.attr('data-id');
      
      topic_link.addClass('children-loaded');
      
      $.ajax({
        url: '/topics/' + id + '/sub_topics',
        success: function( data ) {
          $('#topic_index li.active, #topic_index a.active').removeClass('active');
          topic_link.after(data);
          topic_link.parentsUntil('#topic_index').addClass('active');
          topic_link.addClass('active');
        }
      });
    }
    
    if(!signature.match(/^\d*\.\d*\.\d*$/) && topic_link.hasClass('children-loaded')){
      showSubTopics(topic_link);      
    }
  });
}

function showSubTopics(element) {
  $('#topic_index li.active, #topic_index a.active').removeClass('active');
  element.next().show();
  element.addClass('active');
  element.parent('li').addClass('active');
  element.parentsUntil('#topic_index').addClass('active');
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
  $('#mainmenu a').click(function(){
    $(this).next('ul').show();
    $('#mainmenu a, #mainmenu li').removeClass('selected');
    $(this).addClass('selected');
    $(this).parent('li').addClass('selected');
  });
}

$(document).ready(function() {
  addAutofocusBehaviour();
  addLinkifyContainersBehaviour();
  addAutogrowBehaviour();
  addAutoAddNewContainer();
  addRelationAutoCompletionBehaviour();
  addEditToolTipBehaviour();
  addSearchSuggestionBehaviour();
  addContainerSuggestionBehaviour();
  addUpdateLastContainerTitleOfDossier();
  showVersionsBehaviour();
  addReportColumnMultiselectBehaviour();
  addEditReportBehaviour();
  addTopicIndexBehaviour();
  addCsrfTokenToAjaxCalls();
  addMainNavigationBehaviour();
});
