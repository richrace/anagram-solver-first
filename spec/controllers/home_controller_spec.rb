require 'spec_helper'

describe HomeController do

  describe "GET #index" do

    it "renders :index view" do
      get :index
      response.should render_template "index"
    end

    it "won't get a dictionary if ID not set in session" do
      get :index
      assigns(:dictionary).should be_nil
    end

    it "won't break if session has dictionary ID that isn't in the database" do
      session[:dictionary_id] = 1000;
      lambda { Dictionary.find(session[:dictionary_id]) }.should raise_error

      lambda { get :index }.should_not raise_error
      assigns(:dictionary).should be_nil
    end

    it "will set dictionary if exists in session" do
      file = File.new(Rails.root + "#{Rails.root}/spec/assets/test_dic.txt")  
      uploaded_file = ActionDispatch::Http::UploadedFile.new(:tempfile => file, :filename => File.basename(file)) 

      dictionary = Dictionary.new
      dictionary.parse_file?(uploaded_file)
      dictionary.time_taken = Time.now
      dictionary.save!

      session[:dictionary_id] = dictionary.id

      get :index
      assigns(:dictionary).should_not be_nil
      assigns(:dictionary).should == dictionary
    end  

  end
  
  describe "POST #upload" do

    it "can upload a correct format file" do
      file = File.new(Rails.root + "#{Rails.root}/spec/assets/test_dic.txt")  
      uploaded_file = ActionDispatch::Http::UploadedFile.new(:tempfile => file, :filename => File.basename(file)) 

      post :upload, :file => uploaded_file

      response.should redirect_to root_url
      assigns(:dictionary).should_not be_nil
      assigns(:dictionary).grouped.should_not be_nil
    end

    it "can upload a file and not break when it's wrong format" do
      file = File.new(Rails.root + "#{Rails.root}/spec/assets/multi_word.txt")  
      uploaded_file = ActionDispatch::Http::UploadedFile.new(:tempfile => file, :filename => File.basename(file)) 

      post :upload, :file => uploaded_file

      response.should redirect_to root_url
      assigns(:dictionary).id.should be_nil
    end

    it "will add the dictionary to the database if everything is ok" do
      file = File.new(Rails.root + "#{Rails.root}/spec/assets/test_dic.txt")  
      uploaded_file = ActionDispatch::Http::UploadedFile.new(:tempfile => file, :filename => File.basename(file)) 

      post :upload, :file => uploaded_file

      response.should redirect_to root_url
      assigns(:dictionary).should_not be_nil

      Dictionary.find(assigns(:dictionary).id).should_not be_nil
    end

  end

  describe "POST #search_anagram" do
    before(:each) do
      file = File.new(Rails.root + "#{Rails.root}/spec/assets/test_dic.txt")  
      uploaded_file = ActionDispatch::Http::UploadedFile.new(:tempfile => file, :filename => File.basename(file)) 

      @dictionary = Dictionary.new
      @dictionary.parse_file?(uploaded_file)
      @dictionary.time_taken = Time.now
      @dictionary.save!      
    end

    after(:each) do
      @dictionary.destroy
    end

    it "can find an anagram with a word given and create a search log" do    
      session[:dictionary_id] = @dictionary.id
      post :search_anagram, :wanted_anagram => "center"

      @dictionary.previous_searches.first.wanted_anagram.should == "center"
      @dictionary.previous_searches.first.result.should_not be_empty
      @dictionary.previous_searches.first.result.should == ["center", "centre", "recent"]
    end

    it "will return empty list when no anagram found and will create a search log" do
      session[:dictionary_id] = @dictionary.id
      post :search_anagram, :wanted_anagram => "test"

      @dictionary.previous_searches.first.wanted_anagram.should == "test"
      @dictionary.previous_searches.first.result.should be_empty
    end

    it "won't break when passed no word" do
      session[:dictionary_id] = @dictionary.id
      post :search_anagram, :wanted_anagram => ""

      @dictionary.previous_searches.should be_empty
    end

    it "won't break when no dictionary set in session" do
      session[:dictionary_id] = nil
      lambda { post :search_anagram, :wanted_anagram => "test" }.should_not raise_error
    end

    it "won't break when submitting numbers" do
      session[:dictionary_id] = @dictionary.id
      post :search_anagram, :wanted_anagram => "test123"

      @dictionary.previous_searches.should be_empty
    end

  end

end
