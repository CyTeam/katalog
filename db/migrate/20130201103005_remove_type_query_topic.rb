class QueryTopic < Dossier
end

class RemoveTypeQueryTopic < ActiveRecord::Migration
  def up
    QueryTopic.destroy_all
  end
end
