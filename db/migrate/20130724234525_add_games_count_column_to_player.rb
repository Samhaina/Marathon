class AddGamesCountColumnToPlayer < ActiveRecord::Migration
  def change
  	add_column :players, :games_count, :int, default: 0
  end
end
