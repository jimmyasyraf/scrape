require 'Nokogiri'
require 'JSON'
require 'csv'
require 'watir'
require 'phantomjs'

page = 30
fields = ["Name", "Phone", "Address", "Operating hours", "Latitude", "Longitude", "Category"]

restaurant_details = []


CSV.open('restaurants.csv', 'w') do |csv|
  csv << fields
  url = "https://www.timeout.com/kuala-lumpur/search#/?sort=relevance&categories=node-7083&page_number=#{page}&time_out_ratings=node-3341&time_out_ratings=node-3343&time_out_ratings=node-3345&time_out_ratings=node-3347&time_out_ratings=node-3349&viewstate=list"
  browser_list = Watir::Browser.new(:phantomjs)
  browser_list.goto url
  parse_page = Nokogiri::HTML(browser_list.html)
  parse_page.css('div#main-container').css('main#content').css('.container').css('main#content').css('.container').css('.main_content').css('.search_results').css('li').css('a').map do |a|
    #restaurant_name = a['title']
    #restaurant_array.push(restaurant_name)
    secondUrl = 'https://www.timeout.com' + a['href']
    browser_restaurant = Watir::Browser.new(:phantomjs)
    browser_restaurant.goto secondUrl
    restaurant_parse = Nokogiri::HTML(browser_restaurant.html)
    restaurant_details = []
    restaurant_parse.css('div#main-container').css('main#content').css('.container').css('.listing_details').css('tbody').css('tr').map do |row|
      restaurant_detail = row.css('td').text.gsub("\n","").strip.squeeze(" ")
      if restaurant_detail == 'Visit Website Call Venue' || restaurant_detail == 'Call Venue'
        row.css('td').css('div').css('a').map do |look_for_phone_number|
          restaurant_detail = look_for_phone_number['data-tel']
        end
      end
      if restaurant_detail == ""
        restaurant_detail = "-"
      end
      restaurant_details.push(restaurant_detail)
    end
    map_hash = Hash.new {0}
    restaurant_parse.css('div#main-container').css('main#content').css('.container').css('.venue_map__tile').css('.venue_map').map do |a|
      restaurant_detail = a['data-params']
      map_hash = JSON.parse(restaurant_detail)
    end
    restaurant_details.push(map_hash["lat"])
    restaurant_details.push(map_hash["lng"])
    restaurant_parse.css('div#main-container').css('article').css('header').css('.page_meta_controls').map do |look_for_category|
      restaurant_detail = look_for_category.search('.flag--sub_category').text.gsub(",","").strip
      restaurant_details.push(restaurant_detail)
    end
    puts restaurant_details
    csv << restaurant_details
  end
end
