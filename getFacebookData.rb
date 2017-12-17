require_relative 'browserWrapper'
require_relative 'myFirebase'
require 'byebug'
require 'eyes_selenium'
require 'active_support/all'

def signIn(email, password)
  @browser.goto('https://www.facebook.com')
  @browser.send_text(@browser.div(id: "pagelet_bluebar").input(id: "email"), email)
  @browser.send_text(@browser.div(id: "pagelet_bluebar").input(id: "pass"), password)
  @browser.click_element(@browser.div(id: "pagelet_bluebar").input(value: "Log In"))
end

def extractNumberOfVisitors(url)
  @browser.goto(url)
  @browser.wait_until { @browser.div(id: "root").span(text: "Total Visits").parent.present? }
  parentDiv = @browser.div(id: "root").span(text: "Total Visits").parent
  parentDiv.div.text.scan(/\d/).join('').to_i
end

def extractNumberOfLikes(url)
  @browser.goto(url)
  @browser.wait_until { @browser.div(id: "content_container").span(text: "Community").present? }
  @browser.div(id: "content_container").span(text: "Community").parent.parent.div(text: /people like this/).text.scan(/\d/).join('').to_i
end

def updateNumOfLikes(restaurantsName)
  restaurantJson = getRestaurantJson(restaurantsName)
  url = restaurantJson['url']
  numOfLikes = extractNumberOfLikes(url)
  numOfLikesDelta = (numOfLikes.to_i - restaurantJson['numOfLikes'].to_i).to_s
  @firebase.updateNumOfLikes(restaurantsName, restaurantJson, numOfLikes, numOfLikesDelta)
end

def getRestaurantJson(restaurantName)
  @firebase.getRestaurantJson(restaurantName)
end

def getRestaurantsList
  @firebase.getRestaurantsList
end

@firebase = MyFirebase.new()
@browser = BrowserWrapper.new()
signIn('therestaurants510@gmail.com', 'finalproject')
restaurantsList = getRestaurantsList
restaurantsList.each do |restaurant|
  updateNumOfLikes(restaurant)
end
@browser.close


