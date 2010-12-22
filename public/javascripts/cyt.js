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
  $('.container:last input[type=text]:first').keyup(function(){
    var text = $(this).val();
    if(text.match(/\d{4}\s?-\s?\d{4}/)){
      $('#add_record_link').trigger('click');
      $(this).unbind('keyup', addAutoAddNewContainer());
    }
  });
}

function addRelationAutoCompletionBehaviour() {
  $('#insert_relation').click(function(e){
    var id = 'relation_list_auto_completion';
    var link = $('#insert_relation');
    var text_area = $('#dossier_relation_list');
    e.preventDefault();
    text_area.after('<input type="text" value="Um nach einem Querverweis zu suchen. Hier den Suchbegriff eingeben." size="50" id="' + id + '" style="margin-left:25%;width:74%;">');
    link.hide();
    $('#' + id).click(function(){
      var input = $(this);
      input.val('');
      input.autocomplete({
        source: function( request, response ) {
          $.ajax({
            url: '/dossiers.json',
            dataType: 'json',
            data: {
              title:    request.term,
              per_page: 'all'
            },
            success: function( data ) {
              response( $.map( data, function( object ) {
                item = object.topic;
                return {
                  label: item.title,
                  value: item.signature + ': ' + item.title
                }
              }));
            }
          });
        },
        minLength: 2,
        close: function() {
          console.log(input.val());
          var value = input.val();
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
