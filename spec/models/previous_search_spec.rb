require 'spec_helper'

describe PreviousSearch do

  before(:all) do
    file = File.new(Rails.root + "#{Rails.root}/spec/assets/test_dic.txt")  
    uploaded_file = ActionDispatch::Http::UploadedFile.new(:tempfile => file, :filename => File.basename(file)) 

    @dictionary = Dictionary.new
    @dictionary.parse_file?(uploaded_file)
    @dictionary.time_taken = Time.now
    @dictionary.should be_valid
    @dictionary.save!
  end

  after(:all) do
    @dictionary.destroy
  end
  
  describe "#save" do
    it "can not save an invalid Previous Search" do
      previous = PreviousSearch.new(:dictionary_id => @dictionary.id)
      previous.should_not be_valid
      previous.stub(:save).and_return(false)
    end

    it "can save a valid Previous Search" do
      previous = PreviousSearch.new(
        :dictionary_id => @dictionary.id, 
        :result => ["center", "centre"], 
        :wanted_anagram => "center", 
        :time_taken => Time.now
      )
      previous.should be_valid
      previous.stub(:save).and_return(true)
    end

    it "can save a Previous Search and Dictionary can find it" do
      previous = PreviousSearch.new(
        :dictionary_id => @dictionary.id, 
        :result => ["center", "centre"], 
        :wanted_anagram => "center", 
        :time_taken => Time.now
      )
      previous.should be_valid
      previous.save!

      previous.dictionary.should == @dictionary
    end
  end

end
