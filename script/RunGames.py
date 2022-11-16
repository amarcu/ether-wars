import subprocess
import sys
import requests
import json
import time
import urllib3
import os


urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
# api-endpoint
#URL = "https://webserver.amarcu.dev:3000"
URL = "https://127.0.0.1:3000"
UNRATED_API_ENDPOINT = URL+"/player/unrated"
FIND_API_ENDPOINT = URL+"/player/findGame"
SAVEGAME_API_ENDPOINT = URL+"/player/saveGame"
MARK_PLAYER_API_ENDPOINT = URL+"/player/markRated"

GAME_COUNT = 5
challengeId = 1

def main():
    
    while(True):
        (playerId,byteCode) = findUnrankedPlayer(challengeId)

        if playerId != "":
            data = {
                'playerId': playerId,
                'challengeId':challengeId
            }

            skipMark = True
            for count in range(GAME_COUNT):
                if playGame(data,playerId,byteCode) == True:
                    skipMark = False
                else:
                    print("Game failed")

            if skipMark == False:
                markPlayer(challengeId,playerId)

        time.sleep(10)


def markPlayer(challengeId, playerId):
    data = {
        'playerId': playerId,
        'challengeId':challengeId
    }

    print ("Mark Player " + playerId + " as ranked")
    # sending post request and saving response as response object
    r = requests.post(url = MARK_PLAYER_API_ENDPOINT, data = data,verify=False)
    if r.status_code != 200:
        print("Error marking player as rated "+ r.status_code)
        return
    


def findUnrankedPlayer(challengeId):
    data = {
        'challengeId':challengeId
    }

    # sending post request and saving response as response object
    r = requests.get(url = UNRATED_API_ENDPOINT, data = data,verify=False)
    if r.status_code != 200:
        print("Error retrieving unraked player "+ r.status_code)
        return ("","")


    if r.text == "NO_PLAYER":
        print("No unraked player found ")
        return ("","")

    json_data = r.json()
    playerId = json_data["playerId"]
    byteCode = json_data["byteCode"]

    return (playerId,byteCode)

def playGame(findData, playerId, byteCode):
    r = requests.get(url = FIND_API_ENDPOINT, data = findData,verify=False)
    if r.status_code != 200:
        print("Error retrieving opponent "+ r.status_code)
        return False

    opponent_json_data = r.json()
    opponent_playerId = opponent_json_data["playerId"]
    opponent_byteCode = opponent_json_data["byteCode"]

    if opponent_playerId == 0 or opponent_byteCode == "":
        return False

    print ("Playing game between playerId="+str(playerId)+" and playerId="+str(opponent_playerId))

    result = {
        "a":playerId,
        "b":byteCode,
        "c":opponent_playerId,
        "d":opponent_byteCode,
    }


    #print (str(result))
    f = open("../logs/game_params.txt", "w+")
    f.write(json.dumps(result))
    f.close()

    run_command = "forge script ./TicTacToe.s.sol"

    p = subprocess.Popen(run_command, stdout=subprocess.PIPE, shell=True)

    (output, err) = p.communicate()  

    # wait for end of game 
    p_status = p.wait()

    print("Command output: " + str(output))

    if os.path.isfile("../logs/game.txt") == False:
        return False

    f = open("../logs/game.txt", "r+")
    gameLogRaw = f.read()
    f.close()

    f = open("../logs/winner.txt", "r")
    winner = int(f.read())
    f.close()

    print("winner: " + str(winner))

    gameOutputData = {
        'player1Id':playerId,
        'player2Id':opponent_playerId,
        'challengeId':challengeId,
        'log':gameLogRaw,
        'winner':winner
    }

    r = requests.post(url = SAVEGAME_API_ENDPOINT, data = gameOutputData,verify=False)
    if r.status_code != 200:
        print("Error updating game"+ r.status_code)
        return False

    print("Game succesfully played")
    return True

if __name__=="__main__":
   main()

