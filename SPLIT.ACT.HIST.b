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

    GOSUB INITIALISE
    GOSUB PROCESS
    

RETURN

*-----------------------------------------------------------------------------
PROCESS:
    
    SEQ.NO = 1
    LOOP
        AA.ACT.HIST.ID = ARRANGEMENT.ID : "#" : SEQ.NO
        R.ACT.HIST = ""
        HIST.ERR = ""
        CALL F.READ(FN.AA.ACTIVITY.HISTORY.HIST,AA.ACT.HIST.ID,R.ACT.HIST,F.AA.ACTIVITY.HISTORY.HIST,HIST.ERR)
    WHILE NOT(HIST.ERR)
        EFFECTIVE.DATE = R.ACT.HIST<AA.AH.EFFECTIVE.DATE>
        CNT.EFFECTIVE.DATE = DCOUNT(EFFECTIVE.DATE,@VM)
        
        SEQ.NO++
        ARR.LIST<-1> = AA.ACT.HIST.ID : "*" : CNT.EFFECTIVE.DATE
    REPEAT

    DEBUG

RETURN
*-----------------------------------------------------------------------------
INITIALISE:

    FN.AA.ACTIVITY.HISTORY.HIST = 'F.AA.ACTIVITY.HISTORY.HIST'
    F.AA.ACTIVITY.HISTORY.HIST = ''
    CALL OPF(FN.AA.ACTIVITY.HISTORY.HIST,F.AA.ACTIVITY.HISTORY.HIST)

RETURN

*-----------------------------------------------------------------------------
END
