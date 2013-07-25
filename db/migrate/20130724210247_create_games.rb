class CreateGames < ActiveRecord::Migration
	def change
		create_table :games do |t|
			t.datetime :day_time
			t.string :rules
			t.boolean :disqualification, default: false

			t.timestamps
		end
	end
end
