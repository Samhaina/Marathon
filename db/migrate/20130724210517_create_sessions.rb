class CreateSessions < ActiveRecord::Migration
	def change
		create_table :sessions do |t|
			t.integer :game_id
    		t.integer :player_id
    		t.integer :place

      		t.timestamps
		end
	end
end
