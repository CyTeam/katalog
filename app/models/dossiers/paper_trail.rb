# encoding: UTF-8

module Dossiers
  module PaperTrail
    extend ActiveSupport::Concern

    module ClassMethods
      def restore_relations(version)
        related_object_ids = version.container_ids.split(',').map(&:to_i) + version.number_ids.split(',').map(&:to_i)

        related_object_ids.each do |id|
          sub_version = Version.find_by_item_id(id)
          sub_object = sub_version.reify
          sub_original = (sub_version.event == 'destroy' ? nil : sub_version.item_type.constantize.find(sub_version.item_id))

          if sub_original
            sub_original = sub_object
            sub_original.dossier_id = version.item_id
            sub_original.save
          else
            sub_object.dossier_id = version.item_id
            sub_object.save
          end
        end
        
        dossier = Dossier.find(version.item_id)
        dossier.keyword_list = version.keywords
        dossier.save!
      end
    end
  end
end
