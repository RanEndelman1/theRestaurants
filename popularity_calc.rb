require_relative 'browserWrapper'
require_relative 'myFirebase'
require 'active_support/all'
require 'byebug'

def calcultaRestaurantScore(restaurantJson)
  numOfLikesDelta = restaurantJson['numOfLikesDelta'].to_i
  numOfHashtagsDelta = restaurantJson['numOfHashtagsDelta'].to_i
  instagramFollowersDelta = restaurantJson['instagramfollowersDelta'].to_i
  postsInInstagramDelta = restaurantJson['postsininstagram'].to_i
  postsInInstagramDelta + numOfHashtagsDelta * 0.1 + numOfLikesDelta * 0.5 + instagramFollowersDelta * 0.5
end

@firebase = MyFirebase.new()
restaurantsWithScore = {}
restaurantsList = @firebase.getRestaurantsList
restaurantsList.each do |restaurant|
  restaurantJson =  @firebase.getRestaurantJson(restaurant)
  restaurantsWithScore[restaurant] = calcultaRestaurantScore(restaurantJson)
end
@firebase.setRestaurantsRank(restaurantsWithScore.sort_by(&:last).to_h.keys.reverse)
