# Make acts-as-taggable-on work again with papertrail
# Changed the line with the PATCH statement
module PaperTrail
  module VersionConcern
    extend ::ActiveSupport::Concern
    def reify(options = {})
      return nil if object.nil?

      without_identity_map do
        options[:has_one] = 3 if options[:has_one] == true
        options.reverse_merge! :has_one => false

        attrs = self.class.object_col_is_json? ? object : PaperTrail.serializer.load(object)

        # Normally a polymorphic belongs_to relationship allows us
        # to get the object we belong to by calling, in this case,
        # `item`.  However this returns nil if `item` has been
        # destroyed, and we need to be able to retrieve destroyed
        # objects.
        #
        # In this situation we constantize the `item_type` to get hold of
        # the class...except when the stored object's attributes
        # include a `type` key.  If this is the case, the object
        # we belong to is using single table inheritance and the
        # `item_type` will be the base class, not the actual subclass.
        # If `type` is present but empty, the class is the base class.

        if item && options[:dup] != true
          model = item
          # Look for attributes that exist in the model and not in this version. These attributes should be set to nil.
          (model.attribute_names - attrs.keys).each { |k| attrs[k] = nil }
        else
          inheritance_column_name = item_type.constantize.inheritance_column
          class_name = attrs[inheritance_column_name].blank? ? item_type : attrs[inheritance_column_name]
          klass = class_name.constantize
          model = klass.new
        end

        model.class.unserialize_attributes_for_paper_trail attrs

        # Set all the attributes in this version on the model
        attrs.each do |k, v|
          if model.has_attribute?(k)
            # PATCH use send for keyword_list assignment
            model.send("#{k}=", v)
          else
            logger.warn "Attribute #{k} does not exist on #{item_type} (Version id: #{id})."
          end
        end

        model.send "#{model.class.version_association_name}=", self

        unless options[:has_one] == false
          reify_has_ones model, options[:has_one]
        end

        model
      end
    end
  end
end
