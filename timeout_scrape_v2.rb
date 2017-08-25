require 'JSON'
require 'csv'
require 'httparty'

first_page_url = "https://www.timeout.com/graffiti/v1/sites/my-kualalumpur/search?page_size=10&page_number=1&facets=false&view=complete&locale=en-GB&sort=relevance&what=((%60node-7083%60)+AND+(%60node-3341%60+OR+%60node-3343%60+OR+%60node-3345%60+OR+%60node-3347%60+OR+%60node-3349%60))"

auth = 'Bearer r1j66MtMTUA0XcAu66Ti5ge2KIdUdj-3lvSmJ40IPgo'

first_page_response = HTTParty.get(first_page_url, headers: {'Authorization' => auth})

first_page_parse = JSON.parse(first_page_response.body)

total_items = first_page_parse["meta"]["total_items"]
fields = ["Name", "Phone", "Address", "Latitude", "Longitude", "Category"]

all_page_url = "https://www.timeout.com/graffiti/v1/sites/my-kualalumpur/search?page_size=#{total_items}&page_number=1&facets=false&view=complete&locale=en-GB&sort=relevance&what=((%60node-7083%60)+AND+(%60node-3341%60+OR+%60node-3343%60+OR+%60node-3345%60+OR+%60node-3347%60+OR+%60node-3349%60))"
all_page_response = HTTParty.get(all_page_url, headers: {'Authorization' => auth})
all_page_parse = JSON.parse(all_page_response.body)

CSV.open('timeout_restaurants.csv', 'w') do |csv|
  csv << fields
  all_page_parse["body"].each do |a|
    restaurant_details = []
    restaurant_details.push(a["name"])
    restaurant_details.push(a["phone"])
    address1 = a["address1"]
    address2 = a["address2"]
    city = a["city"]
    county = a["county"]
    postcode = a["postcode"]
    address = address1.to_s + " " + address2.to_s + " " + postcode.to_s + " " + county.to_s + " " + city.to_s
    restaurant_details.push(address)
    restaurant_details.push(a["latitude"])
    restaurant_details.push(a["longitude"])
    if (a["categorisation"]["secondary"]) != nil
      restaurant_details.push(a["categorisation"]["secondary"]["name"])
    end
    csv << restaurant_details
  end
end
