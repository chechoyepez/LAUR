SUBROUTINE SPLIT.ACT.HIST
*-----------------------------------------------------------------------------
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------

*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ACTIVITY.HISTORY.HIST


    PRINT "Enter the ARRANGEMENT Id : "
    INPUT ARRANGEMENT.ID

    PRINT "Enter the NUMBER OF RECORDS : "
    INPUT NO.RECORDS

    GOSUB OPEN.FILES
    GOSUB INITIALISE
    GOSUB GET.HIST.DATA
    GOSUB PROCESS

RETURN

*-----------------------------------------------------------------------------
GET.HIST.DATA:

* Read records from AA.ACTIVITY.HISTORY.HIST#1 to AA.ACTIVITY.HISTORY.HIST#n
* in order to determine the number of existing EFFECTIVE.DATE mv field values.      

    SEQ.NO = 1
	TOTAL.CNT.EFFECTIVE.DATE = 0
	
    LOOP
        AA.ACT.HIST.ID = ARRANGEMENT.ID : "#" : SEQ.NO
        R.ACT.HIST = ""
        HIST.ERR = ""
        CALL F.READ(FN.AA.ACTIVITY.HISTORY.HIST,AA.ACT.HIST.ID,R.ACT.HIST,F.AA.ACTIVITY.HISTORY.HIST,HIST.ERR)
    WHILE NOT(HIST.ERR)
        EFFECTIVE.DATE = R.ACT.HIST<AA.AH.EFFECTIVE.DATE>
        CNT.EFFECTIVE.DATE = DCOUNT(EFFECTIVE.DATE,@VM)

		FOR Y.I = CNT.EFFECTIVE.DATE TO 1
* Store data in array variable
			ARR.EFFECTIVE.DATE<-1> = R.ACT.HIST<AA.AH.EFFECTIVE.DATE,Y.I>
			ARR.ACTIVITY.REF<-1> = R.ACT.HIST<AA.AH.ACTIVITY.REF,Y.I>
			ARR.ACTIVITY<-1> = R.ACT.HIST<AA.AH.ACTIVITY,Y.I>
			ARR.SYSTEM.DATE<-1> = R.ACT.HIST<AA.AH.SYSTEM.DATE,Y.I>
			ARR.CONTRACT.ID<-1> = R.ACT.HIST<AA.AH.CONTRACT.ID,Y.I>
			ARR.ACTIVITY.AMT<-1> = R.ACT.HIST<AA.AH.ACTIVITY.AMT,Y.I>
			ARR.ACT.STATUS<-1> = R.ACT.HIST<AA.AH.ACT.STATUS,Y.I>
			ARR.AGENT.EVENT.REF<-1> = R.ACT.HIST<AA.AH.AGENT.EVENT.REF,Y.I>
			ARR.AGENT.EVENT.STATUS<-1> = R.ACT.HIST<AA.AH.AGENT.EVENT.STATUS,Y.I> 
			ARR.TRANSACTION.INITIATION<-1> = R.ACT.HIST<AA.AH.TRANSACTION.INITIATION,Y.I>
			ARR.INITIATION<-1> = R.ACT.HIST<AA.AH.INITIATION,Y.I>
		NEXT Y.I
        
		TOTAL.CNT.EFFECTIVE.DATE += CNT.EFFECTIVE.DATE
        SEQ.NO++
        
    REPEAT    

RETURN

*-----------------------------------------------------------------------------
PROCESS:

* If no data found, then return
	IF NOT(ARR.EFFECTIVE.DATE) THEN
		RETURN
	END

* Calculate number of effective date mv for each new data record
	Y.DIVISION = INT(TOTAL.CNT.EFFECTIVE.DATE/NO.RECORDS)

* Sequence ID
	Y.SEQ.ID = 0
	
* New data to be populated
	R.NEW.ARR.ACT.HIST = ''

* Write records into the new set of AA.ACTIVITY.HISTORY.HIST records according to the NO.OF.RECORDS given as parameter
	FOR Y.J = 1 TO TOTAL.CNT.EFFECTIVE.DATE			
		
		INS ARR.EFFECTIVE.DATE<Y.J> BEFORE R.NEW.ARR.ACT.HIST<AA.AH.EFFECTIVE.DATE,1>
		INS ARR.ACTIVITY.REF<Y.J> BEFORE R.NEW.ARR.ACT.HIST<AA.AH.ACTIVITY.REF,1>
		INS ARR.ACTIVITY<Y.J> BEFORE R.NEW.ARR.ACT.HIST<AA.AH.ACTIVITY,1>
		INS ARR.SYSTEM.DATE<Y.J> BEFORE R.NEW.ARR.ACT.HIST<AA.AH.SYSTEM.DATE,1>
		INS ARR.CONTRACT.ID<Y.J> BEFORE R.NEW.ARR.ACT.HIST<AA.AH.CONTRACT.ID,1>
		INS ARR.ACTIVITY.AMT<Y.J> BEFORE R.NEW.ARR.ACT.HIST<AA.AH.ACTIVITY.AMT,1>
		INS ARR.ACT.STATUS<Y.J> BEFORE R.NEW.ARR.ACT.HIST<AA.AH.ACT.STATUS,1>
		INS ARR.AGENT.EVENT.REF<Y.J> BEFORE R.NEW.ARR.ACT.HIST<AA.AH.AGENT.EVENT.REF,1>
		INS ARR.AGENT.EVENT.STATUS<Y.J> BEFORE R.NEW.ARR.ACT.HIST<AA.AH.AGENT.EVENT.STATUS,1>
		INS ARR.TRANSACTION.INITIATION<Y.J> BEFORE R.NEW.ARR.ACT.HIST<AA.AH.TRANSACTION.INITIATION,1>
		INS ARR.INITIATION<Y.J> BEFORE R.NEW.ARR.ACT.HIST<AA.AH.INITIATION,1>
		
		Y.RESIDUAL = MOD(Y.J,Y.DIVISION)
		
		IF Y.RESIDUAL EQ 0 THEN
			Y.SEQ.ID ++
			GOSUB WRITE.HIST.DATA
			R.NEW.ARR.ACT.HIST = ''
		END
	
	NEXT Y.J

RETURN

*-----------------------------------------------------------------------------
WRITE.HIST.DATA:

*Write record in to AA.ACTIVITY.HISTORY.HIST application
	CALL F.WRITE(FN.AA.ACTIVITY.HISTORY.HIST,ARRANGEMENT.ID:"#":Y.SEQ.ID,R.NEW.ARR.ACT.HIST)

RETURN

*-----------------------------------------------------------------------------

INITIALISE:

* Array to hold information about AA.ACTIVITY.HISTORY.HIST records 
	ARR.EFFECTIVE.DATE = ""
    ARR.ACTIVITY.REF = ""
    ARR.ACTIVITY = ""
    ARR.SYSTEM.DATE = ""
    ARR.CONTRACT.ID = ""
    ARR.ACTIVITY.AMT = ""
    ARR.ACT.STATUS = ""
    ARR.AGENT.EVENT.REF = ""
    ARR.AGENT.EVENT.STATUS = ""
    ARR.TRANSACTION.INITIATION = ""
    ARR.INITIATION = ""

RETURN

*-----------------------------------------------------------------------------
OPEN.FILES:

* Open file for AA.ACTIVITY.HISTORY.HIST
    FN.AA.ACTIVITY.HISTORY.HIST = 'F.AA.ACTIVITY.HISTORY.HIST'
    F.AA.ACTIVITY.HISTORY.HIST = ''
    CALL OPF(FN.AA.ACTIVITY.HISTORY.HIST,F.AA.ACTIVITY.HISTORY.HIST)

RETURN

*-----------------------------------------------------------------------------
END
