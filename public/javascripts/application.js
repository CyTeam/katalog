// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
document.observe("dom:loaded", function() {
  elements = $$("tr[data-href]");
  elements.each(function(element) {
    element.style.cursor = "pointer";
  });
  
  $(document.body).observe("click", function(event) {
    var link = event.findElement("a");
    if (link) {
      return true;
    };
    
    var element = event.findElement("tr[data-href]");
    if (element) {
      var href = element.readAttribute('data-href');
      document.location.href=href;

      event.stop();
      return false;
    }
  });
});
