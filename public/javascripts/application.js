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
  var amount = $(e).val();

  $.ajax({
    url: '/dossiers/' + dossier_id + '/dossier_numbers/'+ number_id,
    type: 'PUT',
    data: {
      amount: amount
    }
  });
}

function showVersionsBehaviour(){
  $('a#show-versions').toggle(function(){
    $('#versions-bottom').show();
  }, function(){
    $('#versions-bottom').hide();
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
      var new_container = $('.container:last');
      var d = new Date();

      new_container.find(first_input).val(d.getFullYear() + ' -');
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
    $('#' + id).click(function(){
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
                item = object.dossier;
                return {
                  label: item.title,
                  value: item.signature + ': ' + item.title
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
 $('*[title]').each(function(){
   if($(this).attr('title')!=''){
     $(this).qtip({
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
   }
 });
}

function addSearchSuggestionBehaviour() {
  function split( val ) {
    return val.split( / \s*/ );
  }
  function extractLast( term ) {
    return split( term ).pop();
  }

  var input = $('#search_text');
  input.attr('autocomplete', 'false');
  
  input.autocomplete({
    source: function( request, response ) {
      $.ajax({
        url: '/keywords/suggestions.json',
        dataType: 'json',
        data: {
          query:    extractLast(request.term)
        },
        success: function( data ) {
          response( $.map( data, function( object ) {
            item = object.keyword;
            return {
              label: item.name
            }
          }));
          $('.ui-autocomplete').highlight(extractLast(request.term), 'match');
        }
      });
    },
    search: function() {
      // custom minLength
      var term = extractLast( this.value );
      if ( term.length < 2 ) {
        return false;
      }
    },
    select: function( event, ui ) {
      var terms = split( this.value );
      // remove the current input
      terms.pop();
      // add the selected item
      terms.push( ui.item.value );
      // add placeholder to get the comma-and-space at the end
      terms.push( "" );
      this.value = terms.join( " " );
      return false;
    }
  });

  input.keydown(function(event) {
    if(event.keyCode == 13) {
      $(this).parent('form').submit();
    }
  });
}

function addReportActionsMenuBehaviour() {
  var ul = '#report_actions';

  $(ul).hover(function(){
    $(ul + ' ul').show();
  },function(){
    $(ul + ' ul').hide();
  });
}

function addReportColumnMultiselectBehaviour() {
  $('#report_columns').multiselect({
    width: 410,
    height: 160
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
  addReportActionsMenuBehaviour();
  addReportColumnMultiselectBehaviour();
});
