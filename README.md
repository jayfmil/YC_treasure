# YC_treasure

Repository for analyses of the Jacobs lab treasure chest game.

## Basic behavioral analyses

Perform the following steps to run basic analyses:

- Create the parsed log file with `python treasureLogParser.py <logfilename.txt>`. This will create the file `treasure.par`.
- Launch matlab. Create the events structure with `events = createTreasureEvents('treasure.par',saveDir)`, where saveDir is the directory where the events structure will be saved.
- Plot behavioral results with `treasureAnalyses(events,saveDir)`, where saveDir is the directory where subject data will be saved and the report made.
- Create a group average report with `treasureAnalyses_group(resDir,saveDir)`, where resDir is the location where subject data was saved from the previous step. This assumed you have run the `treasureAnalyses` for all subjects.

To run the timing analysis:
- Create the timing log file with `python treasureLogParser_timingInfo.py <logfilename.txt>`. This will create the file `treasureTime.par`.
- From matlab, `treasureTimingAnalysis('treasureTime.par')`
