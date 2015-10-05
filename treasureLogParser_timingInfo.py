import sys
import os.path
import pprint

def writeToFile(f,data):
    columnOrder = ['mstime','type','item','trial','chestNum','locationX','locationY','chosenLocationX','chosenLocationY','recStartLocationX','recStartLocationY','isHighConf','isRecFromNearSide','isSerial','reactionTime','rememberBool'];
    strToWrite = ''
    for col in columnOrder:
        line = data[col]
        if col != columnOrder[-1]:
            strToWrite += '%s\t'%(line)
        else:
            strToWrite += '%s\n'%(line)    
    f.write(strToWrite)


def makeEmptyDict(mstime=None,eventType=None,item=None,trial=None,chestNum=None,locationX=None,locationY=None,chosenLocationX=None,chosenLocationY=None,recStartLocationX=None,recStartLocationY=None,isHighConf=None,isRecFromNearSide=None,isSerial=None,reactionTime=None,rememberBool=None):
    fields = ['mstime','type','item','trial','chestNum','locationX','locationY','chosenLocationX','chosenLocationY','recStartLocationX','recStartLocationY','isHighConf','isRecFromNearSide','isSerial','reactionTime','rememberBool'];
    vals = [mstime,eventType,item,trial,chestNum,locationX,locationY,chosenLocationX,chosenLocationY,recStartLocationX,recStartLocationY,isHighConf,isRecFromNearSide,isSerial,reactionTime,rememberBool]
    emptyDict = dict(zip(fields,vals))
    return emptyDict
    
def getPresDictKey(data,recItem,trialNum):
    for key in data:
        if data[key]['item'] == recItem and data[key]['type'] == 'CHEST' and data[key]['trial'] == trialNum:
            return key


if len(sys.argv) <  2:
    print "Please enter the log file to parse"
    sys.exit()

dir, logFile = os.path.split(sys.argv[1])
if logFile == '':
    logFile = 'log.txt'

inFile = open(os.path.join(dir,logFile), 'r')
outFile = open(os.path.join(dir,"treasure.par"), 'w')
columnOrder = ['mstime','type','item','trial','chestNum','locationX','locationY','chosenLocationX','chosenLocationY','recStartLocationX','recStartLocationY','isHighConf','isRecFromNearSide','isSerial','reactionTime','rememberBool'];
outFile.write('\t'.join(columnOrder) + '\n')


treasureInfo = {}
data = {}
phase = None
env_center = None
pp = pprint.PrettyPrinter(indent=4)

for s in inFile.readlines():
    tokens = s[:-1].split('\t')
    if len(tokens)>1:            
        
        # remove spaces
        # change practice trial numbers
        
        # THE BEGINNING OF A TRIAL
        if tokens[2] == 'Trial Info': 
            trialNum = tokens[4]
            
        # keep a dictionary of treasure chest locations
        if 'TreasureChest' in tokens[2] and tokens[3] == 'POSITION':
            treasureInfo[tokens[2]] = {}
            treasureInfo[tokens[2]]['pos'] = [tokens[4],tokens[6]]
            
        # Need environment center to later figure out if the object is on
        # same half of environment as player
        if tokens[2] == 'Experiment Info' and tokens[3] == 'ENV_CENTER':
            env_center = [tokens[4],tokens[6]]        
        
        # keep track of most current player position
        if tokens[2] == 'Player' and tokens[3] == 'POSITION':
            playerPosition = (tokens[4],tokens[5],tokens[6])

        # KEEP TRACK OF CURRENT EXPIRMENT PHASE
        elif tokens[2] == 'Trial Event':
            if tokens[3] == 'TRIAL_NAVIGATION_STARTED':
                phase = 'nav'
                serialPos = 0
                item = ''
            elif tokens[3] == 'RECALL_PHASE_STARTED':
                phase = 'rec'
                recPos = 0   
                recItem = ''         
            
        ### NAV INFO ###
        if phase == 'nav':
                                      
            if tokens[3] == 'TREASURE_OPEN':
                chest = tokens[2]
                presX = treasureInfo[chest]['pos'][0]
                presY = treasureInfo[chest]['pos'][1]                 
                serialPos += 1
                mstime = tokens[0]
                item = ''
                
                if tokens[5] == 'True':
                    isItemPres = 1
                else:
                    isItemPres = 0
                    data[mstime] = makeEmptyDict(mstime,'CHEST',None,trialNum,serialPos,presX,presY) 
            
            elif tokens[3] == 'TREASURE_LABEL':
                item = tokens[4]
                treasureInfo[chest]['item'] = item
                # pp.pprint(treasureInfo)
            
            elif tokens[2] == item and tokens[3] == 'SPAWNED':
                mstime = tokens[0]
                data[mstime] = makeEmptyDict(mstime,'CHEST',item,trialNum,serialPos,presX,presY) 
        
        ### RECALL INFO ###
        elif phase == 'rec':
            if tokens[2] == 'Trial Event' and tokens[3] == 'RECALL_SPECIAL':
                recPos += 1
                recItem = tokens[4]
                x = None
                y = None
                presX = None
                presY = None
                isHighConf = 'low'
                isRecFromNearSide = None
                recStartTime = tokens[0]
                reactionTime = None
                
            elif tokens[2] == recItem and tokens[3] == 'SPAWNED':
                mstime = tokens[0]                
                
            elif tokens[2] == 'Experiment' and tokens[3] == 'REMEMBER_RESPONSE':
                rememberBool = 0
                if tokens[4]=='True':
                    rememberBool = 1
                    
            elif tokens[2] == 'Experiment' and tokens[3] == 'DOUBLE_DOWN_RESPONSE':   
                print tokens[4]  
                isHighConf = 0
                if tokens[4] == 'True':
                    isHighConf = 1
                key = getPresDictKey(data,recItem,trialNum)          
                data[mstime]['isHighConf'] = isHighConf
                data[key]['isHighConf'] = isHighConf                                    
                                    
            elif tokens[2] == 'EnvironmentPositionSelector' and tokens[3] == 'CHOSEN_TEST_POSITION':
                x = tokens[4]
                y = tokens[6]
                reactionTime = int(tokens[0]) - int(recStartTime)

            elif tokens[2] == 'EnvironmentPositionSelector' and tokens[3] == 'CORRECT_TEST_POSITION':                
                presX = tokens[4]
                presY = tokens[6]                
                
                data[mstime] = makeEmptyDict(mstime,'REC',recItem,trialNum,'NaN',presX,presY,x,y,playerPosition[0],playerPosition[2],reactionTime=reactionTime,rememberBool=rememberBool) 

                # fill in the presentaiton event with recall info
                # there is probably/definitely a more efficient way to do this
                key = getPresDictKey(data,recItem,trialNum)
                data[key]['chosenLocationX'] = x
                data[key]['chosenLocationY'] = y                        
                data[key]['recStartLocationX'] = playerPosition[0]
                data[key]['recStartLocationY'] = playerPosition[2]
                data[key]['reactionTime'] = reactionTime                       
                data[key]['rememberBool'] = rememberBool                                               
                data[mstime]['chestNum'] = data[key]['chestNum']                
                
                # determine if the target location is the same half of the environment
                # as the player test location
                isRecFromNearSide = 0
                if ((presY >= env_center[1] and data[key]['recStartLocationY'] >= env_center[1]) or
                    (presY < env_center[1] and data[key]['recStartLocationY'] < env_center[1])):
                    isRecFromNearSide = 1
                data[key]['isRecFromNearSide'] = isRecFromNearSide
                data[mstime]['isRecFromNearSide'] = isRecFromNearSide
                        
                                                
                    
sortedKeys = sorted(data)
for key in sortedKeys:
    writeToFile(outFile,data[key])

inFile.close()
outFile.close()
