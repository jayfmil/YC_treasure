# YC_treasure

Repository for analyses of the Jacobs lab treasure chest game.

## Basic behavioral analyses

Perform the following steps to run basic analyses:

- Create the parsed log file with `python treasureLogParser.py <logfilename.txt>`. This will create the file `treasure.par`.
- Launch matlab. Create the events structure with `events = createTreasureEvents('treasure.par')`.
- Plot behavioral results with `treasureAnalyses(events)`.

To run the timing analysis:
- Create the timing log file with `python treasureLogParser_timingInfo.py <logfilename.txt>`. This will create the file `treasureTime.par`.
- From matlab, `treasureTimingAnalysis('treasureTime.par')`
