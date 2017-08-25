import requests
import csv

first_page_url = "https://www.timeout.com/graffiti/v1/sites/my-kualalumpur/search?page_size=10&page_number=1&facets=false&view=complete&locale=en-GB&sort=relevance&what=((%60node-7083%60)+AND+(%60node-3341%60+OR+%60node-3343%60+OR+%60node-3345%60+OR+%60node-3347%60+OR+%60node-3349%60))"

auth = 'Bearer r1j66MtMTUA0XcAu66Ti5ge2KIdUdj-3lvSmJ40IPgo'

first_page_response = requests.get(first_page_url, headers= {'Authorization' : auth})
first_page_parse = first_page_response.json()

total_items = first_page_parse["meta"]["total_items"]
fields = ["Name", "Phone", "Address", "Latitude", "Longitude", "Category"]

all_page_url = "https://www.timeout.com/graffiti/v1/sites/my-kualalumpur/search?page_size=" + str(total_items) + "&page_number=1&facets=false&view=complete&locale=en-GB&sort=relevance&what=((%60node-7083%60)+AND+(%60node-3341%60+OR+%60node-3343%60+OR+%60node-3345%60+OR+%60node-3347%60+OR+%60node-3349%60))"

all_page_response = requests.get(all_page_url, headers= {'Authorization' : auth})
all_page_parse = all_page_response.json()

f = open("scraped_restaurants.csv","wb")
writer = csv.writer(f)
writer.writerow(fields)

for restaurant in all_page_parse["body"]:
    restaurant_details = []
    restaurant_details.append(restaurant["name"].encode('utf-8'))
    restaurant_details.append(restaurant.get("phone", ""))
    address1 = restaurant.get("address1","")
    address2 = restaurant.get("address2", "")
    city = restaurant.get("city","")
    county = restaurant.get("county","")
    postcode = restaurant.get("postcode", "")
    address = address1 + " " + address2 + " " + county + " " + postcode + " " + city
    restaurant_details.append(address.encode('utf-8'))
    restaurant_details.append(restaurant.get("latitude",""))
    restaurant_details.append(restaurant.get("longitude",""))
    if restaurant["categorisation"].get("secondary", "") != "":
        restaurant_details.append(restaurant["categorisation"]["secondary"].get("name","").encode('utf-8'))
    print restaurant_details
    writer.writerow(restaurant_details)

f.close()
