import sys
import os.path
import pprint

def writeToFile(f,data):
    columnOrder = ['mstime','type','item','trial','chestNum','locationX','locationY','chosenLocationX','chosenLocationY','recStartLocationX','recStartLocationY','confidence','recFromNearSide','isSerial','reactionTime','rememberBool'];
    strToWrite = ''
    for col in columnOrder:
        # if isinstance(data[col],list):
            # line = '\t'.join(data[col])
        # else:
        line = data[col]
        if col != columnOrder[-1]:
            strToWrite += '%s\t'%(line)
        else:
            strToWrite += '%s\n'%(line)    
    f.write(strToWrite)


def makeEmptyDict(mstime=None,eventType=None,item=None,trial=None,chestNum=None,locationX=None,locationY=None,chosenLocationX=None,chosenLocationY=None,recStartLocationX=None,recStartLocationY=None,confidence=None,recFromNearSide=None,isSerial=None,reactionTime=None,rememberBool=None):
    fields = ['mstime','type','item','trial','chestNum','locationX','locationY','chosenLocationX','chosenLocationY','recStartLocationX','recStartLocationY','confidence','recFromNearSide','isSerial','reactionTime','rememberBool'];
    vals = [mstime,eventType,item,trial,chestNum,locationX,locationY,chosenLocationX,chosenLocationY,recStartLocationX,recStartLocationY,confidence,recFromNearSide,isSerial,reactionTime,rememberBool]
    emptyDict = dict(zip(fields,vals))
    # emptyDict = dict((f, []) for f in fields)
    # emptyDict['mstime'] = mstime
    # emptyDict['type'] = eventType
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
columnOrder = ['mstime','type','item','trial','chestNum','locationX','locationY','chosenLocationX','chosenLocationY','recStartLocationX','recStartLocationY','confidence','recFromNearSide','isSerial','reactionTime','rememberBool'];
outFile.write('\t'.join(columnOrder) + '\n')

# Needed fields
# mstime: double
# type: string ()
# item: string ('',item identity)
# trial: double
# chestNum: double (like serial position)
# location: vector double ([x,y])
# chosenLocation: vector double ([x,y])
# recStartLocation: vector double ([x,y])
# recFromNearSide: bool
# isSerial: bool
# reactionTime: from when the cue comes on?


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
                    # pp.pprint(data)
                    # print 'TRIAL %s SERIAL POS %s ITEM %s X %s Y %s' %(trialNum,serialPos,item,presX,presY)
            
            elif tokens[3] == 'TREASURE_LABEL':
                item = tokens[4]
                treasureInfo[chest]['item'] = item
                # pp.pprint(treasureInfo)
            
            elif tokens[2] == item and tokens[3] == 'SPAWNED':
                mstime = tokens[0]
                data[mstime] = makeEmptyDict(mstime,'CHEST',item,trialNum,serialPos,presX,presY) 
                # pp.pprint(data)
                # print 'TRIAL %s SERIAL POS %s ITEM %s X %s Y %s' %(trialNum,serialPos,item,presX,presY)
        
        ### RECALL INFO ###
        elif phase == 'rec':
            if tokens[2] == 'Trial Event' and tokens[3] == 'RECALL_SPECIAL':
                recPos += 1
                recItem = tokens[4]
                x = None
                y = None
                presX = None
                presY = None
                confidence = 'low'
                recFromNear = None
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
                confidence = 'low'
                if tokens[4] == 'True':
                    confidence = 'high'                  
                key = getPresDictKey(data,recItem,trialNum)          
                data[mstime]['confidence'] = confidence
                data[key]['confidence'] = confidence                                    
                                    
            elif tokens[2] == 'EnvironmentPositionSelector' and tokens[3] == 'CHOSEN_TEST_POSITION':
                x = tokens[4]
                y = tokens[6]
                reactionTime = int(tokens[0]) - int(recStartTime)

            elif tokens[2] == 'EnvironmentPositionSelector' and tokens[3] == 'CORRECT_TEST_POSITION':                
                presX = tokens[4]
                presY = tokens[6]                
                
                data[mstime] = makeEmptyDict(mstime,'REC',recItem,trialNum,'NaN',presX,presY,x,y,playerPosition[0],playerPosition[2],reactionTime=reactionTime,rememberBool=rememberBool) 

                # fill in the presentaiton event with recall info
                # there is probably a more efficient way to do this
                key = getPresDictKey(data,recItem,trialNum)
                data[key]['chosenLocationX'] = x
                data[key]['chosenLocationY'] = y                        
                data[key]['recStartLocationX'] = playerPosition[0]
                data[key]['recStartLocationY'] = playerPosition[2]
                data[key]['reactionTime'] = reactionTime                       
                data[key]['rememberBool'] = rememberBool                                               
                data[mstime]['chestNum'] = data[key]['chestNum']

                
                recFromNear = 0
                if ((presY >= env_center[1] and data[key]['recStartLocationY'] >= env_center[1]) or
                    (presY < env_center[1] and data[key]['recStartLocationY'] < env_center[1])):
                    recFromNear = 1
                data[key]['recFromNearSide'] = recFromNear
                data[mstime]['recFromNearSide'] = recFromNear
                        
                                                
                    
sortedKeys = sorted(data)
for key in sortedKeys:
    # pp.pprint(data[key])
    writeToFile(outFile,data[key])
                # pprint.pprint(makeEmptyDict(mstime,'REC',recItem,trialNum,'NaN',[presX,presY],[x,y]))
                # pp.pprint(makeEmptyDict(mstime,'REC',recItem,trialNum,'NaN',[presX,presY],[x,y],[playerPosition[0],playerPosition[2]]) )
                # print 'TRIAL %s REC POS %s ITEM %s CONFIDENCE %s' %(trialNum,recPos,recItem,confidence)







# for s in inFile.readlines():
#     tokens = s[:-1].split('\t')
#     if len(tokens)>1:
#         if tokens[2] == 'ENV_SIZE':
#             outFile.write('%s\t%s\t%s\t%s\t%s\t%s\n'%(tokens[0],'env_size',tokens[3],tokens[4],tokens[5],tokens[6]))
#
#         elif tokens[2] == 'SESS_START':
#             outFile.write('%s\t%s\t%s\t%s\t%s\n'%(tokens[0],'sess_start',tokens[3],tokens[4],tokens[5]))
#
#         elif tokens[2] == 'TRIAL_INFO':
#             trialNum = tokens[3]
#             trialType = tokens[4]
#             stimTrial = tokens[5]
#             blockNum = tokens[6]
#             startP3 = tokens[7][tokens[7].find('(')+1:tokens[7].find(')')]
#             startP3 = startP3.split(',')
#             startPos = (startP3[0],startP3[1])
#             startHead = tokens[8]
#             obj = tokens[9]
#             objP3 = tokens[10][tokens[10].find('(')+1:tokens[10].find(')')]
#             objP3 = objP3.split(',')
#             objPos = (objP3[0],objP3[1])
#             pairedBlock = tokens[11]
#             writeToFile_trialInfo(outFile,tokens[0],'trial_info',trialNum,blockNum,trialType,stimTrial,startPos[0],startPos[1],startHead,obj,objPos[0],objPos[1],pairedBlock)
#
#         elif tokens[2] == 'TRIAL_START':
#             trial_start_time = tokens[0]
#             outFile.write('%s\t%s\t%s\n'%(trial_start_time,'trial_start',trialNum))
#
#         elif tokens[2] == 'STIM_START':
#             stim_start_time = tokens[0]
#             trialNum = tokens[3]
#             stim_duration = tokens[4]
#             outFile.write('%s\t%s\t%s\n'%(stim_start_time,'stim_start',trialNum))
#
#         elif tokens[2] == 'NAV_START':
#             trialNum = tokens[3]
#             nav_start_time = tokens[0]
#             nav_started = True
#             outFile.write('%s\t%s\t%s\n'%(nav_start_time,'nav_start',trialNum))
#
#         elif tokens[2] == 'SPIN_START':
#             trialNum = tokens[3]
#             outFile.write('%s\t%s\t%s\n'%(tokens[0],'spin_start',trialNum))
#
#         elif tokens[2] == 'AUTO_DRIVE':
#             trialNum = tokens[3]
#             outFile.write('%s\t%s\t%s\n'%(tokens[0],'drive_start',trialNum))
#
#         elif tokens[2] == 'WAIT_AT_OBJ':
#             trialNum = tokens[3]
#             outFile.write('%s\t%s\t%s\n'%(tokens[0],'wait_start',trialNum))
#
#         elif tokens[2] == 'PRE_PAUSE':
#             trialNum = tokens[3]
#             outFile.write('%s\t%s\t%s\n'%(tokens[0],'premove_pause',trialNum))
#
#         elif tokens[2] == 'RESPONSE':
#             respP3 = tokens[4][tokens[4].find('(')+1:tokens[4].find(')')]
#             respP3 = respP3.split(',')
#             respPos = (respP3[0],respP3[1])
#             respHead = tokens[5]
#             respEucErr = tokens[6]
#             outFile.write('%s\t%s\t%s\t%s\t%s\t%s\t%s\n'%(tokens[0],'response',trialNum,respPos[0],respPos[1],respHead,respEucErr))
#
#             trial_started = False
#             nav_started = False
#
#         elif tokens[2] == 'MOVINGOBJECT_LINEARSPEED' and tokens[3] == 'PandaEPL_avatar':
#             speed = float(tokens[4])
#
#         elif tokens[2] == 'CAMERA_POS_HEAD' and nav_started:
#             heading = float(tokens[4])%360.0
#             p3 = tokens[3]
#             coordinates = p3[p3.find('(')+1:p3.find(')')]
#             subTokens = coordinates.split(',')
#             pos = (subTokens[0],subTokens[1])
#             writeToFile(outFile,tokens[0],'move',trialNum,pos[0],pos[1],speed,heading)
#
#
inFile.close()
# outFile.close()
