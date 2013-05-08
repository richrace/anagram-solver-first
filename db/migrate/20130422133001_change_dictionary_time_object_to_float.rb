class ChangeDictionaryTimeObjectToFloat < ActiveRecord::Migration
  def up
    change_column :dictionaries, :time_taken, :float
  end

  def self.down
    change_column :dictionaries, :time_taken, :time
  end
end
