require 'firebase'

class MyFirebase
  def initialize
    firebaseUrl = 'https://therestaurants-b2734.firebaseio.com/'
    firebaseSecret = 'VKPl5O5ztiVFYuPKDAxHkOdTEEsehuRyaB69STAC'
    @dataBase = Firebase::Client.new(firebaseUrl, firebaseSecret)
  end

  def updateNumOfLikes(restaurantsName, restaurantJson, currNumOfLikes, numOfLikesDelta)
  url = restaurantJson['url']
  instagramfollowers = restaurantJson['instagramfollowers']
  instagramUrl = restaurantJson['instagramUrl']
  postsininstagram = restaurantJson['postsininstagram']
  instagramPageUrl = restaurantJson['instagramPageUrl']
  hashtag = restaurantJson['hashtag']
  instagramfollowersDelta = restaurantJson['instagramfollowersDelta']
  numOfHashtagsDelta = restaurantJson['numOfHashtagsDelta']
  numOfHashtags = restaurantJson['numOfHashtags']
  response = @dataBase.set("restaurantslist/#{restaurantsName}",
    { :name => restaurantsName, :url => url, :numOfLikes => currNumOfLikes.to_s, :instagramfollowers => instagramfollowers,
      :postsininstagram => postsininstagram, :instagramUrl => instagramUrl, :instagramPageUrl => instagramPageUrl,
      :hashtag => hashtag, :numOfHashtags => numOfHashtags.to_s, :numOfHashtagsDelta => numOfHashtagsDelta,
      :instagramfollowersDelta => instagramfollowersDelta, :numOfLikesDelta => numOfLikesDelta.to_s
      })
  end

  def getRestaurantJson(restaurantName)
    restaurantsList = @dataBase.get("restaurantslist")
    parsed = JSON.parse(restaurantsList.raw_body)
    restaurantsJson = parsed.values
    restaurantsJson.each do |restaurantJson|
      return restaurantJson if restaurantJson["name"] == restaurantName
    end
  end

  def getRestaurantsList
    restaurantsList = @dataBase.get("restaurantslist")
    JSON.parse(restaurantsList.raw_body).keys
  end

  def setInstagramData(restaurantJson, restaurantsName, numOfFollowers, numOfPosts, numOfHashtags)
    url = restaurantJson['url']
    instagramUrl = restaurantJson['instagramUrl']
    numOfLikes = restaurantJson['numOfLikes']
    instagramPageUrl = restaurantJson['instagramPageUrl']
    hashtag = restaurantJson['hashtag']
    numOfLikesDelta = restaurantJson['numOfLikesDelta']
    numberOfFollowersDelta = (numOfFollowers.to_i - restaurantJson['instagramfollowers'].to_i).to_s
    hashTagCountDelta = (numOfHashtags.to_i - restaurantJson['numOfHashtags'].to_i).to_s
    response = @dataBase.set("restaurantslist/#{restaurantsName}",
    { :name => restaurantsName, :url => url, :numOfLikes => numOfLikes, :instagramfollowers => numOfFollowers.to_s,
      :postsininstagram => numOfPosts.to_s, :instagramUrl => instagramUrl, :numOfHashtags => numOfHashtags.to_s,
      :instagramPageUrl => instagramPageUrl, :hashtag => hashtag, :numOfHashtagsDelta => hashTagCountDelta,
      :instagramfollowersDelta => numberOfFollowersDelta, :numOfLikesDelta => numOfLikesDelta.to_s
      })
  end
end
