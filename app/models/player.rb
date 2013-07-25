#coding: utf-8
require 'open-uri'

class Player < ActiveRecord::Base
  	attr_accessible :name, :registration, :disqualification, :rating, :best_average, :games_count

  	has_many :sessions
  	has_many :games, through: :sessions

  	

  	# раз в день (загрузка плееров перед загрузкой игр в 20-30)
	def self.load_from_url (i, z)
  		while i != z
  			url_day = Date.today.prev_day(i).strftime("%Y%m%d")
  			url = "http://a.pqrs.se/tenhou/gamerecords2/l/L2158/#{url_day.to_s}.log"

  			puts day_player_list = open(url).read.split(/L2158 \| (?:[0-9][0-9]:[0-9][0-9]) \| (?:.*－) \|/).join.split(/\r\n/)

  			day_player_list.select do |elem|
  				elem.gsub(/ (.+?)\((?:[+-]?[\d]+)\.0\)/) { 
  					@player = Player.find_by_name($1) || Player.create(:name => $1)
  				}
  			end			
			i -= 1
		end
	end 


	# метод для вьюхи (Серии занятых мест)
	def array_of_places (id)
		player = Player.find_by_id(id)
		array_of_places = []
		player.sessions.each do |session|
			if session.game.day_time.month == DateTime.now.month
				array_of_places << session.place
			end
		end
		array_of_places
	end



	# метод для вьюхи
	def rang (id)
		player = Player.find_by_id(id)

		if player.array_of_places(player.id).count > 19

			player = Player.find_by_id(id)
			if player.best_average <= 1.45
				rang = 'S'
			elsif player.best_average <= 1.95
				rang = 'A'
			elsif player.best_average <= 2.25
				rang = 'B'
			elsif player.best_average <= 2.55
				rang = 'C'
			elsif player.best_average <= 2.95
				rang = 'D'
			else
				rang = 'E'				
			end
		else
			rang = 'NG'
		end

	end

	# метод для вьюхи и модели (среднее)
	def self.average_count
		player = Player.find(:all)
		player.each do |player|
			array_of_places = player.array_of_places(player.id)
			if array_of_places.empty? == false
				array_of_places = player.array_of_places(player.id)
				player.average = (array_of_places.inject(0.0) { |acc, str| acc + str } / array_of_places.size)
				player.save
			end
		end
	end

	# метод для вьюхи и для модели, раз в день, лучшее среднее
	def self.best_average_count
		player = Player.find(:all)
		player.each do |player|

			array_of_places = player.array_of_places(player.id)
			if array_of_places.empty? == false

				if array_of_places.size > 19				
					array_of_averages = []
					i=0
					while i < array_of_places.size-19
						average = array_of_places[i..i+19].inject(0.0) { |res, elem| res+=elem } / 20
						array_of_averages << average
						i+=1
					end
					player.best_average = array_of_averages.min
					player.save
				else
					player.best_average = player.average
					player.save
				end
			end
		end
	end




end
