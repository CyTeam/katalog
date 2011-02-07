module SphinxAdminsHelper
  def add_new_link
    link_to_function image_tag('icons/add.png', :title => t('crud.new', :model => '')), :id => 'add_record_link' do |page|
      record = render(:partial => 'sphinx_admins/form', :locals => {:form => SphinxAdmin.new})
      page << %{
var new_record_id = new Date().getTime();
var content = "#{ escape_javascript record }";
content = content.replace(/\\[\\d+\\]/g, "[" + new_record_id + "]");
content = content.replace(/_\\d+_/g, "_" + new_record_id + "_");
$('#sphinx_admins').append(content);
}
    end
  end
end
