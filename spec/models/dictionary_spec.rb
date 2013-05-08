require 'spec_helper'

describe Dictionary do
  
  describe "#make_anagram_list" do
    
    it "can group a list based on sorted chars" do
      dictionary = Dictionary.new 
      dictionary.original = ["center", "centre", "test", "scream", "creams"]
      dictionary.make_anagram_list
      dictionary.grouped.length.should == 3
    end

    it "won't break when the list is nil" do
      dictionary = Dictionary.new 
      dictionary.original.should be_nil
      dictionary.make_anagram_list
      dictionary.grouped.should be_nil
    end

  end

  describe "#find_anagrams" do

    it "won't break when the anagram list hasn't been created" do
      dictionary = Dictionary.new 
      dictionary.original.should be_nil
      dictionary.make_anagram_list
      dictionary.find_anagrams("center").should == []
    end

    it "will return a found anagram" do
      dictionary = Dictionary.new 
      dictionary.original = ["center", "centre", "test", "scream", "creams"]
      dictionary.make_anagram_list
      dictionary.find_anagrams("center").should == ["center", "centre"]
    end

    it "will return [] when it can't find an anagram" do
      dictionary = Dictionary.new       
      dictionary.original = ["center", "centre", "test", "scream", "creams"]
      dictionary.make_anagram_list
      dictionary.find_anagrams("anagram").should be_empty
    end

  end

  describe "#parse_file?" do

    it "can open file and read it with correct format" do
      file = File.new(Rails.root + "#{Rails.root}/spec/assets/test_dic.txt")  
      uploaded_file = ActionDispatch::Http::UploadedFile.new(:tempfile => file, :filename => File.basename(file)) 

      dictionary = Dictionary.new
      dictionary.parse_file?(uploaded_file)
      dictionary.find_anagrams("center").length.should == 3

      file.close  
    end

    it "won't parse multi word anagrams" do
      file = File.new(Rails.root + "#{Rails.root}/spec/assets/multi_word.txt")  
      uploaded_file = ActionDispatch::Http::UploadedFile.new(:tempfile => file, :filename => File.basename(file)) 

      dictionary = Dictionary.new
      dictionary.parse_file?(uploaded_file)
      dictionary.find_anagrams("center").should be_empty
      dictionary.grouped.should be_nil
      dictionary.filename.should be_nil
      dictionary.original.should be_nil

      file.close  
    end

  end

  describe "#save" do

    it "can not save an invalid Dictionary" do
      dictionary = Dictionary.new
      dictionary.grouped.should be_nil
      dictionary.should_not be_valid
      dictionary.stub(:save).and_return(false) 
    end

    it "can save a valid Dictionary" do
      file = File.new(Rails.root + "#{Rails.root}/spec/assets/test_dic.txt")  
      uploaded_file = ActionDispatch::Http::UploadedFile.new(:tempfile => file, :filename => File.basename(file)) 

      dictionary = Dictionary.new
      dictionary.parse_file?(uploaded_file)
      dictionary.time_taken = Time.now
      dictionary.should be_valid
      dictionary.stub(:save).and_return(true) 
    end

  end

  describe "#delete" do

    it "will delete all previous searches and dictionary is removed" do
      file = File.new(Rails.root + "#{Rails.root}/spec/assets/test_dic.txt")  
      uploaded_file = ActionDispatch::Http::UploadedFile.new(:tempfile => file, :filename => File.basename(file)) 

      dictionary = Dictionary.new
      dictionary.parse_file?(uploaded_file)
      dictionary.time_taken = Time.now
      dictionary.save!

      result = dictionary.find_anagrams("center")

      prev_search = PreviousSearch.new(:dictionary_id => dictionary.id, :result => result, :wanted_anagram => "center", :time_taken => Time.now)
      prev_search.save!

      dictionary.previous_searches.length.should == 1
      prev_search_id = dictionary.previous_searches.first.id
      PreviousSearch.find(prev_search_id).should == prev_search

      dictionary.destroy
      Dictionary.find(:all).should be_empty
      PreviousSearch.find(:all).should be_empty
    end

  end

end
