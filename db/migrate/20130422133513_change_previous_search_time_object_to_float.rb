class ChangePreviousSearchTimeObjectToFloat < ActiveRecord::Migration
  def up
    change_column :previous_searches, :time_taken, :float
  end

  def self.down
    change_column :previous_searches, :time_taken, :time
  end
end
