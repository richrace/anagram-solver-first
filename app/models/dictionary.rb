class Dictionary < ActiveRecord::Base
  attr_accessible :grouped, :original, :time_taken, :filename
  serialize :grouped
  serialize :original
  has_many :previous_searches, :dependent => :destroy

  validates :grouped, :presence => true
  validates :original, :presence => true
  validates :time_taken, :presence => true
  validates :filename, :presence => true

  def make_anagram_list
    write_attribute :grouped, original.group_by {|word| word.chars.sort} if original
  end

  def find_anagrams(input_word) 
    if grouped
      grouped[input_word.downcase.chars.sort] || []
    else 
      []
    end
  end

  def parse_file?(file)
      return false unless file
      file_content = File.open(file.tempfile.path, "r") { |file_obj| file_obj.readlines }
      file_content.each do | file_line |         
        return false if file_line.split(' ').length > 1
        file_line.downcase!
        file_line.chomp!
      end
      write_attribute :original, file_content   
      write_attribute :filename, file.original_filename   
      make_anagram_list
      return true
    end
end
