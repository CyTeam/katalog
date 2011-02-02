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
