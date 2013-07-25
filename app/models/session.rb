#coding: utf-8
require 'open-uri'

class Session < ActiveRecord::Base
   	attr_accessible :player_id, :game_id, :place
  
  	belongs_to :game
  	belongs_to :player

end
