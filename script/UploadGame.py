# importing the requests library
import requests

# api-endpoint
API_ENDPOINT = "https://webserver.amarcu.dev:3000/player/match"

data = {
    'playerId':1,
    'challengeId':1,
    'players' : [1,2],
    'log': "test game log 1"
}

# sending post request and saving response as response object
r = requests.post(url = API_ENDPOINT, data = data,verify=False)