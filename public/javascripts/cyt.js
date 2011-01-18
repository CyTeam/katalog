// Autofocus element having attribute data-autofocus
function addAutofocusBehaviour() {
  $('*[data-autofocus=true]').first().focus();
}

// Add datepicker
function addDatePickerBehaviour() {
  $('*[date-picker=true]').each(function(){
    $(this).datepicker({ dateFormat: 'dd.mm.yy' });
  });
}

//
function addSortableBehaviour() {
  $(".sortable").sortable({
    placeholder: 'ui-state-highlight'
  });
  $(".sortable").disableSelection();
}


// Linkify containers having attribute data-href-container
function addLinkifyContainersBehaviour() {
  var elements = $('*[data-href-container]');
  elements.each(function() {
    var element = $(this);
    var container = element.closest(element.data('href-container'));
    container.css('cursor', "pointer");
    var href = element.attr('href');
    element.addClass('linkified_container')

    container.delegate('*', 'click', {href: href}, function(event) {
      // Don't override original link behaviour
      if ($(event.target).parents('a').length == 0) {
        document.location.href = href;
      }
    });
  });
}

// Autogrow
function addAutogrowBehaviour() {
  $(".autogrow").elastic();
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

function addPrintToolTipBehaviour() {

}

function addSearchSuggestionBehaviour() {
  var input = $('#search_text');
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
            item = object.keyword;
            return {
              label: item.name
            }
          }));
        }
      });
    },
    minLength: 2
  });
}
