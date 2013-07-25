class CreatePlayers < ActiveRecord::Migration
	def change
		create_table :players do |t|
			t.string :name
			t.boolean :registration, default: false
			t.boolean :disqualification, default: false
			t.float :rating, default: 1500.00
			t.float :temporary_rating, default: 1500.0
			t.float :average, default: 0.0
    		t.float :best_average, default: 0.0
    		t.integer :marks, default: 0
    		t.integer :common_marks, default: 0

			t.timestamps
		end
	end
end
