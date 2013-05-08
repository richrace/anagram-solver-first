class CreatePreviousSearches < ActiveRecord::Migration
  def change
    create_table :previous_searches do |t|
      t.integer :dictionary_id
      t.text :result
      t.time :time_taken
      t.string :wanted_anagram

      t.timestamps
    end
  end
end
