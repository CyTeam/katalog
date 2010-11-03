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

    container.delegate('*', 'click', {href: href}, function(event) {
      // Don't override original link behaviour
      if ($(event.target).parents('a').length == 0) {
        document.location.href = href;
      }
    });
  });
}

