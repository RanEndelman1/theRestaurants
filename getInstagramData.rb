require_relative 'browserWrapper'
require_relative 'myFirebase'
require 'byebug'
require 'eyes_selenium'
require 'active_support/all'
require 'date'
# require 'instagram'

# Log in to instragram with hardcoed credentials
def logIn
  @browser.goto('https://www.instagram.com/')
  @browser.wait_until { @browser.main.article.present? }
  @browser.click_element(@browser.main.article.a(text: "Log in"))
  @browser.wait_until { @browser.main.article.button(text: "Log in").present? }
  @browser.wait_until { @browser.main.article.input(name: "username").present? }
  @browser.main.article.input(name: "username").send_keys 'therestaurants510@gmail.com'
  @browser.main.article.input(name: "password").send_keys 'finalproject'
  @browser.click_element(@browser.main.article.button(text: "Log in"))
  @browser.wait_until { @browser.div(text: "Connect to Facebook").present? }
end

def getPhotosCountSince(url, days)
  @browser.goto(url)
  @browser.wait_until { @browser.article.present? }
  scrollForMorePics(days)
  picsList = @browser.article.imgs[10..-1]
  calculateNumOfPhotos(picsList, days)
end

# This method scroll for more pics till last pic's days ago is larger than daysAgo
def scrollForMorePics(daysAgo)
  picsList = @browser.article.imgs
  lastPicDaysAgo = openPicAndCheckWeekAgo(picsList.last)
  return if !lastPicDaysAgo
  while lastPicDaysAgo
    @browser.scroll_to_element(@browser.a(text: "About us"))
    picsList = @browser.article.imgs
    lastPicDaysAgo = openPicAndCheckWeekAgo(picsList.last)
  end
end

def openPicAndCheckWeekAgo(pic)
  @browser.click_element(pic)
  @browser.wait_until { @browser.div(class: "_ebcx9").time.present? }
  isConatinAgo = @browser.div(class: "_ebcx9").time.text.downcase.include?("ago")
  @browser.click_element(@browser.button(text: "Close"))
  isConatinAgo
end

def openPicAndGetDaysAgo(pic)
  @browser.click_element(pic)
  @browser.wait_until { @browser.div(class: "_ebcx9").time.present? }
  daysAgo = @browser.div(class: "_ebcx9").time.text.scan(/\d/).join('').to_i
  howLongAgoText = @browser.div(class: "_ebcx9").time.text.downcase
  isConatinAgo = howLongAgoText.include?("ago")
  daysAgo = 0 if howLongAgoText.include?("hours") || howLongAgoText.include?("minutes") || howLongAgoText.include?("just now")
  @browser.click_element(@browser.button(text: "Close"))
  return daysAgo if isConatinAgo
  # Return max int
  1000000
end

def calculateNumOfPhotos(picsList, days)
  counter = 0
  picsList.each do |pic|
    # Sleep to act like a real user
    sleep 1
    daysAgo = openPicAndGetDaysAgo(pic)
    if daysAgo <= days
      counter += 1
    else
      return counter
    end
  end
end

def getHashtagsCount(hashtag)
  @browser.goto('https://www.instagram.com/')
  @browser.wait_until { @browser.body.input(placeholder: "Search").present? }
  @browser.body.input(placeholder: "Search").send_keys "##{hashtag}"
  @browser.wait_until { @browser.body.a(href: /tags/).present? || @browser.body.div(text: "No results found.").present? }
  return 0 if @browser.body.div(text: "No results found.").present?
  @browser.body.a(href: /tags/).text.scan(/\d/).join('').to_i
end

def getFollowersCount(url)
  @browser.goto(url)
  @browser.wait_until { @browser.main.a(text: /followers/).present? }
  @browser.main.a(text: /followers/).text.scan(/\d/).join('').to_i
end

def getRestaurantsList
  @firebase.getRestaurantsList
end

def getRestaurantJson(restaurantName)
  @firebase.getRestaurantJson(restaurantName)
end

@browser = BrowserWrapper.new()
@firebase = MyFirebase.new()
logIn()
restaurantsList = getRestaurantsList
restaurantsList.each do |restaurant|
  restaurantJson = getRestaurantJson(restaurant)
  hashTagCount = getHashtagsCount(restaurantJson['hashtag']) unless restaurantJson['hashtag'] == ""
  numberOfFollowers = getFollowersCount(restaurantJson['instagramPageUrl']) unless restaurantJson['instagramPageUrl'] == ""
  numberOfPhotosSince = getPhotosCountSince(restaurantJson['instagramUrl'], 7)
  puts "numberOfPhotosSince in #{restaurant}: #{numberOfPhotosSince}"
  hashTagCount ||= "0"
  numberOfFollowers ||= "0"
  @firebase.setInstagramData(restaurantJson, restaurant, numberOfFollowers, numberOfPhotosSince, hashTagCount)
end

@browser.close
