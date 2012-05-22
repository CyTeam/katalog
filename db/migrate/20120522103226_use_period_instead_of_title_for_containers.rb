class UsePeriodInsteadOfTitleForContainers < ActiveRecord::Migration
  def self.up
    add_column :containers, :period, :string

    PaperTrail.enabled = false
    Container.transaction do
      Container.find_each do |container|
        container.period = container.extract_period(container.title)
        container.save
      end
    end
    PaperTrail.enabled = true

    remove_column :containers, :title
  end

  def self.down
  end
end
