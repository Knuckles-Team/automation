import cockpit_api
cockpit_client = cockpit_api.Api(api_url="", token=cockpit_token)
collection = cockpit_client.get_collection()
json_data = json.dumps({ "data": collection['entries'] }, indent=4)
# with open("collection_info.json", "w") as outfile:
#     outfile.write(json_data)
cockpit_client.update_collection(json_data)
