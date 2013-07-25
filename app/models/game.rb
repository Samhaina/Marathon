#coding: utf-8
require 'open-uri'

class Game < ActiveRecord::Base
  	attr_accessible :day, :rules, :day_time, :disqualification

  	has_many :sessions
  	has_many :players, through: :sessions

  	# раз в день (загрузка игр после загрузки плееров в 20-30)
  	def self.load_from_url (i, z)
  		while i != z
  			url_day = Date.today.prev_day(i)
  			url_day_for_link = url_day.strftime("%Y%m%d")
			url = "http://a.pqrs.se/tenhou/gamerecords2/l/L2158/#{url_day_for_link.to_s}.log"
			day_games_list = open(url).read.split(/\r\n/)

			day_games_list.select { |elem|

				if elem.match(/四般南喰/)

					elem.gsub(/L2158 \| ([0-9][0-9]:[0-9][0-9]) \| (.*－) \| (.+?)\((?:[+-]?[\d]+)\.0\) (.+?)\((?:[+-]?[\d]+)\.0\) (.+?)\((?:[+-]?[\d]+)\.0\) (.+?)\((?:[+-]?[\d]+)\.0\)/) { 
											
						x = url_day.to_s + " "
						x = x + $1.to_s
						x = x + "+0500"
						x = DateTime.parse(x)
															
						@game = Game.create(
							:day_time => x,
							:rules => $2
						)

						@player = Player.find_by_name($3)
						Session.create(
							:game_id => @game.id,
							:player_id => @player.id,
							:place => 1
							)
					
						@player = Player.find_by_name($4)
						Session.create(
							:game_id => @game.id,
							:player_id => @player.id,
							:place => 2
							)

						@player = Player.find_by_name($5)
						Session.create(
							:game_id => @game.id,
							:player_id => @player.id,
							:place => 3
							)

						@player = Player.find_by_name($6)
						Session.create(
							:game_id => @game.id,
							:player_id => @player.id,
							:place => 4
							)
						
					}
					
				end

			}
			i -= 1
		end
	end 

	# раз в день, в полночь 
	def self.player_rating (i, z)

		while i < z # 505-767

			game = Game.find_by_id(i)

			a = []
			game.players.each { |player| a << player.disqualification }

			if a.include?(true) == false 

				average_table_rating = 0
				sum = 0

				game.players.each { |player| sum += player.rating }

				average_table_rating = sum / 4
					
				game.players.each do |player| # каждый игрок, сыгравший в этой игре

				player.games_count += 1

				if player == Player.find_by_name('NoName')
					player.rating = 1500.00		

				else 
					if player.games_count < 400 
						adjustment = 1 - player.games_count*0.002
					else 
						adjustment = 0.2
					end
					
					pl = Session.where(player_id: player.id, game_id: game.id).first.place
						
					case pl
						when 1 
							base = 30
						when 2
							base = 10
						when 3
							base = -10
						when 4
							base = -30
						end
							
					change = adjustment * (base + (average_table_rating - player.rating)/40)
					player.rating = player.rating + change

					player.save

					end
				end
			end
			i += 1
		end
	end


end
