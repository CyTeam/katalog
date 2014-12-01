class Version < ActiveRecord::Base
  include PaperTrail::VersionConcern

  def revert
    case event
    when 'create'
      # Do nothing if item already destroyed again
      return unless item

      item.destroy
    when 'update'
      reify.save
    when 'destroy'
      reify.save
    end
  end

  def active_item
    # Take current item or reify latest version
    item || versions.last.reify
  end

  def current_item
    return nil if event == 'destroy'

    if self.next
      self.next.reify
    else
      # Use active item as it should exist
      item
    end
  end

  def previous_item
    case event
    when 'create'
      nil
    when 'update'
      current_item.previous_version
    when 'destroy'
      reify
    end
  end

  def versions
    sibling_versions
  end
end
