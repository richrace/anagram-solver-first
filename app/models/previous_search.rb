class PreviousSearch < ActiveRecord::Base
  attr_accessible :dictionary_id, :result, :time_taken, :wanted_anagram
  serialize :result
  belongs_to :dictionary

  validates :dictionary_id, :presence => true
  validates :time_taken, :presence => true
  validates :wanted_anagram, :presence => true
end
