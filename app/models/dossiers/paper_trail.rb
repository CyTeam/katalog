module Dossiers
  module PaperTrail
    extend ActiveSupport::Concern

    module ClassMethods
      def restore_relations(id)
        related_objects = Version.where(((:item_type >> DossierNumber.to_s) | (:item_type >> Container.to_s)) & (:event >> "destroy")).find(:all, :order => "created_at desc").each {|v| v.reify.dossier_id = id if v.reify }

        related_objects.each do |sub_version|
          sub_object = sub_version.reify
          sub_original = ('destroy'.eql?sub_version.event ? nil : sub_version.item_type.constantize.find(sub_version.item_id))
          if sub_original
            sub_original = sub_object
            sub_original.dossier_id = id
            sub_original.save
          else
            sub_object.dossier_id = id
            sub_object.save
          end
        end
      end
    end
  end
end