class AddIndexOnContainers < ActiveRecord::Migration
  def up
    add_index :container_types, :code

    add_index :containers, :dossier_id
    add_index :containers, :container_type_id
  end
end
