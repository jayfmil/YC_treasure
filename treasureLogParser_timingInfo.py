import sys
import os.path
import pprint

def writeToFile(f,mstime,trialNum,eventType):
    strToWrite = '%s\t%s\t%s\n' %(mstime,trialNum,eventType)
    f.write(strToWrite)

if len(sys.argv) <  2:
    print "Please enter the log file to parse"
    sys.exit()

dir, logFile = os.path.split(sys.argv[1])
if logFile == '':
    logFile = 'log.txt'

inFile = open(os.path.join(dir,logFile), 'r')
outFile = open(os.path.join(dir,"treasureTime.par"), 'w')


# TIME TRIAL EVENT_TYPE
trialNum = 'NaN'

for ind, s in enumerate(inFile.readlines()):
    
    s = s.replace('\r','')
    tokens = s[:-1].split('\t')
        
    if ind == 1:
        outFile.write('%s\tNaN\tSTART\n' %(tokens[0]))
    

    if len(tokens)>1:            
        
        # remove spaces
        # change practice trial numbers
        
        # THE BEGINNING OF A TRIAL
        if tokens[2] == 'Trial Info': 
            trialNum = tokens[4]
            eType = 'trial_start'
            mstime = tokens[0]
            writeToFile(outFile,mstime,trialNum,eType)
                        
        if tokens[2] == 'Trial Event':
            
            eType = None
            mstime = tokens[0]
            if tokens[3] == 'SHOWING_INSTRUCTIONS':
                eType = 'instructions'
            elif tokens[3] == 'FREE_EXPLORATION_STARTED':
                eType = 'free_exploration'
            elif tokens[3] == 'HOMEBASE_TRANSPORT_STARTED':
                eType = 'homebase_transport'
            elif tokens[3] == 'TRIAL_NAVIGATION_STARTED':
                eType = 'trial_nav_start'
            elif tokens[3] == 'TOWER_TRANSPORT_STARTED':
                eType = 'tower_trans_start'
            elif tokens[3] == 'RECALL_PHASE_STARTED':           
                eType = 'rec_start'
            elif tokens[3] == 'RECALL_SPECIAL':                                                                                
                eType = 'rec_item_start'
            elif tokens[3] == 'FEEDBACK_STARTED':                                                                                            
                eType = 'feedback_start'
            elif tokens[3] == 'DISTRACTOR_GAME_STARTED':                                                                                            
                eType = 'distract_start'                
            writeToFile(outFile,mstime,trialNum,eType)
            
        if tokens[3] == 'TREASURE_OPEN':
            mstime = tokens[0]
            if tokens[5] == 'True':
                writeToFile(outFile,mstime,trialNum,'object')
            else:
                writeToFile(outFile,mstime,trialNum,'chest')
            
outFile.write('%s\tNaN\tEND\n' %(tokens[0]))
inFile.close()
outFile.close()
