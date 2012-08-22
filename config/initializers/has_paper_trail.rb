# encoding: UTF-8

require 'paper_trail'

PaperTrail::Model::ClassMethods.module_eval do
  def differences(before, after)
    before_object = before.reify
    
    if after
      before_object.attributes.diff(after.attributes).keys.sort.inject([]) do |diffs, k|
        diff = { :attribute => k, :before => before_object[k], :after => after[k] }
        diffs << diff; diffs
      end
    else
      nil
    end
  end
end

PaperTrail::Model::InstanceMethods.module_eval do
  def record_destroy
    if switched_on? and not new_record?
      class_name = self.class.base_class.name
      version = version_class.create merge_metadata(:item_id   => self.id,
                                                    :item_type => class_name,
                                                    :event     => 'destroy',
                                                    :object    => object_to_string(item_before_change),
                                                    :whodunnit => PaperTrail.whodunnit)
      version.update_attribute('nested_model', true) if is_a_nested_model?(class_name)
    end

    send(self.class.versions_association_name).send :load_target
  end

  private

  def is_a_nested_model?(class_name)
    case class_name
      when DossierNumber.to_s
        true
      when Container.to_s
        true
      else
        false
    end
  end
end
