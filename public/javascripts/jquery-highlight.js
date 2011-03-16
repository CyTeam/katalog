/*

highlight v3

Highlights arbitrary terms.

<http://johannburkard.de/blog/programming/javascript/highlight-javascript-text-higlighting-jquery-plugin.html>

MIT license.

Johann Burkard
<http://johannburkard.de>
<mailto:jb@eaio.com>

*/

jQuery.fn.highlight = function(pat, className) {
 function innerHighlight(node, pat, className) {
  pat = removeUmlaut(pat);
  className = className || 'highlight';
  var skip = 0;
  if (node.nodeType == 3) {
   var content = removeUmlaut(node.data.toUpperCase());
   var pos = content.indexOf(pat);
   if (pos >= 0) {
    var spannode = document.createElement('span');
    spannode.className = className;
    var middlebit = node.splitText(pos);
    var endbit = middlebit.splitText(pat.length);
    var middleclone = middlebit.cloneNode(true);
    spannode.appendChild(middleclone);
    middlebit.parentNode.replaceChild(spannode, middlebit);
    skip = 1;
   }
  }
  else if (node.nodeType == 1 && node.childNodes && !/(script|style)/i.test(node.tagName)) {
   for (var i = 0; i < node.childNodes.length; ++i) {
    i += innerHighlight(node.childNodes[i], pat, className);
   }
  }
  return skip;
 }
 return this.each(function() {
  innerHighlight(this, pat.toUpperCase(), className);
 });
 function removeUmlaut(text){
   return text.replace(/Ü/g, 'U').replace(/Ä/g, 'A').replace(/Ö/g, 'O');
 }
};

jQuery.fn.removeHighlight = function(className) {
  className = className || 'highlight';
 return this.find("span." + className).each(function() {
  this.parentNode.firstChild.nodeName;
  with (this.parentNode) {
   replaceChild(this.firstChild, this);
   normalize();
  }
 }).end();
};
