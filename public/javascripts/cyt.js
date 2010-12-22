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