class SphinxAdmin < ActiveRecord::Base

  scope :exceptions, where(:type => 'exceptions')
  scope :word_forms, where(:type => 'word_forms')


end
