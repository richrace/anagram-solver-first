class HomeController < ApplicationController

  def index
    begin
      @dictionary = Dictionary.find(session[:dictionary_id]) if session[:dictionary_id]
    rescue ActiveRecord::RecordNotFound
      @dictionary = nil
    end
  end

  def upload
    start_time = Time.now     
    @dictionary = Dictionary.new
    if @dictionary.parse_file?(params[:file])
    	end_time = Time.now
      @dictionary.time_taken = ((end_time - start_time) * 1000).to_f
      @dictionary.save!
      session[:dictionary_id] = @dictionary.id
    end
  	redirect_to :action => 'index'
  end

  def search_anagram
    if !params[:wanted_anagram].blank? && !(params[:wanted_anagram] =~ /\d/) && session[:dictionary_id]
      @dictionary = Dictionary.find(session[:dictionary_id])
      if @dictionary
        start_time = Time.now
      	anagram_output = @dictionary.find_anagrams(params[:wanted_anagram])
        end_time = Time.now
        prev = PreviousSearch.create(:dictionary_id => @dictionary.id, :result => anagram_output, :wanted_anagram => params[:wanted_anagram], :time_taken => ((end_time - start_time) * 1000).to_f)
      end
    end
  	redirect_to :action => 'index'
  end
    
end
