require 'watir'

class BrowserWrapper < Watir::Browser
  def initialize(browser = nil)
    browser ||= set_browser
    @retries_count = 0
    while @retries_count <= 3 do
      begin
        super(browser)
        Watir.default_timeout = 60
        return
        rescue Net::ReadTimeout
          puts "retry connection #" + @retries_count.to_s
          puts "wait 15 seconds for retry"
          sleep 15
          @retries_count += 1
      end
    end
  end
end

public

def set_browser
    if (RUBY_PLATFORM =~ /mingw32/)
      :ie
    elsif (ENV['browser'] == "firefox")
      :firefox
    else
      :chrome
    end
  end

def element_present_and_enabled(element, should_scroll)
  wait_for_element_present(element)
  wait_for_element_enabled(element)
  scroll_to_element(element) if should_scroll
end

def wait_for_element_present(element)
  wait_until { element.present? }
  element
end

def wait_for_element_enabled(element)
  sleep 0.2
  if element.singleton_class.method_defined? :disabled
    wait_until { element.enabled? }
  end
  element
end

def scroll_to_element(element)
  execute_script('arguments[0].scrollIntoView()', element)
rescue Selenium::WebDriver::Error::JavascriptError => e
  puts "Couldn't scroll to #{element.inspect}\nError: #{e}"
end

def loading_element_dissapeared(element)
  wait_until { !element.present? } if wait_without_timeout(element, 10)
end

def click_element(element, should_scroll = true, &block)
  element_present_and_enabled(element, should_scroll)
  element.click
  block_given? ? verify_click(element, &block) : return
rescue Selenium::WebDriver::Error::UnknownError, Selenium::WebDriver::Error::ElementNotVisibleError
  element.fire_event "onclick"
  block_given? ? verify_click(element, &block) : return
end

def send_text(element, text, should_scroll = true, clear = true)
  text = text.to_s
  success = rescue_retry do
    element_present_and_enabled(element, should_scroll)
    element.to_subtype.clear if clear
    click_element(element)
    element.send_keys(text)
    written_text = element.value
    if text == ''
      text == written_text && text == read_text(element)
    else
      text == written_text || text == read_text(element)
    end
  end
  raise "Failed to enter text into element!" unless success
end

def read_text(element, should_scroll = false)
    element_present_and_enabled(element, should_scroll)
    element.text
end

def rescue_retry(retries = 3)
    retries.times do |index|
      begin
        return true if yield
        sleep 10
      rescue => e
        raise e if index == retries - 1
      end
    end
    false
end