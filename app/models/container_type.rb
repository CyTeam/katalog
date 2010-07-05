class ContainerType < ActiveRecord::Base
  def to_s
    "#{title} (#{code})"
  end
end
