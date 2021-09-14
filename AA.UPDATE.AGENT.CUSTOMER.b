* @ValidationCode : MjotMTM0MTc2NjkwNTpJU08tODg1OS0xOjE1MDkwMjQ5MDM3Njg6cHJha2FzaGdrczo0OjA6MDotMTpmYWxzZTpOL0E6UjE3X1NQMi4wOjEzNTo4Nw==
* @ValidationInfo : Timestamp         : 26 Oct 2017 19:05:03
* @ValidationInfo : Encoding          : ISO-8859-1
* @ValidationInfo : User Name         : prakashgks
* @ValidationInfo : Nb tests success  : 4
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 87/135 (64.4%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R17_SP2.0
*-----------------------------------------------------------------------------
* <Rating>-46</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.AgentCommission
SUBROUTINE AA.UPDATE.AGENT.CUSTOMER(UPDATE.MODE,AGENT.CUSTOMER.ID,R.AGCU.REC)
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
* Routine to update the AA.AGENT.CUSTOMER file during arrangement updation
*
*-----------------------------------------------------------------------------
** @package retaillending.AA
* @stereotype subroutine
* @ author
*-----------------------------------------------------------------------------
* Modification:
*  26/03/2014 - EN_874133
*               Task : 874141
*               Call routine to update agent.customer table
*
* 18/01/17 - Task : 1911040
*            Enhancement : 1911014
*            To locate the agent arrangement id in previous property
*
* 23/10/17 - Defect : 2310274
*            Task   : 2314943
*            For migrated contracts don't update AA.AGENT.CUSTOMER.LIST directly,
*            store the values in AA.AGENT.CUSTOMER.WORK and new service AA.UPDATE.AGENT.CUSTOMER.LIST introduced to update AA.AGENT.CUSTOMER.LIST.
*
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING AA.Framework
    $USING AA.AgentCommission
    $USING EB.DataAccess
    $USING EB.SystemTables


*
*** </region>
*-----------------------------------------------------------------------------
    IF AGENT.CUSTOMER.ID THEN
        GOSUB INITIALISE
        GOSUB CHECK.UPDATION
    END

*
RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
INITIALISE:
    WRITE.FLAG = '' ; F.AA.AGENT.CUSTOMER = '' ; ERR.MSG = '' ; R.AA.AGENT.CUSTOMER = ''  ; PREVIOUS.ID = '' ; R.PREVIOUS.AG.CUSTOMER = '' ; TIME.STAMP = ''

    AA.ARR.ID = AA.Framework.getArrId()
    AA.ARR.EFF.DATE = AA.Framework.getActivityEffDate()

    ActivityId          = AA.Framework.getActivityId()                          ;* Current activity id
    ThisActivity        = ActivityId<AA.Framework.ActActivity>
    SessionNo           = EB.SystemTables.getCTTwoFouSessionNo()        ;* to add session number to work file id.
    
    F.AA.AGENT.CUSTOMER.LIST = '' ; LIST.ERR = ''

    PREVIOUS.PROP.REC = AA.Framework.getPrevPropRec()

    IF NOT(PREVIOUS.PROP.REC) THEN
        OPTION = ''
        ID.COMP = AA.Framework.getArrPcId()
        AA.Framework.GetPreviousPropertyRecord(OPTION, "AGENT.COMMISSION", ID.COMP, AA.ARR.EFF.DATE, PREVIOUS.PROP.REC, RET.ERROR)
    END

    R.AA.AGENT.CUSTOMER = AA.AgentCommission.AaAgentCustomer.ReadU(AGENT.CUSTOMER.ID, ERR.MSG, "")
* Before incorporation : CALL F.READU("F.AA.AGENT.CUSTOMER", AGENT.CUSTOMER.ID, R.AA.AGENT.CUSTOMER, F.AA.AGENT.CUSTOMER, ERR.MSG,"")

    AGENT.LIST.ID = FIELD(AGENT.CUSTOMER.ID,'-',1)
    FIN.CUSTOMER = FIELD(AGENT.CUSTOMER.ID,'-',2)
    LOCATE AGENT.LIST.ID IN PREVIOUS.PROP.REC<AA.AgentCommission.AgentCommission.AgcommAgentArrId,1> SETTING ARR.POS THEN  ;* to locate the agent arrangement id in previous property
        PREVIOUS.ID = PREVIOUS.PROP.REC<AA.AgentCommission.AgentCommission.AgcommAgentArrId,ARR.POS>: '-' : FIN.CUSTOMER
        R.PREVIOUS.AG.CUSTOMER = AA.AgentCommission.AaAgentCustomer.ReadU(PREVIOUS.ID, PRV.MSG, "")
    END
    IF ThisActivity EQ "TAKEOVER" THEN ;* For migrated contracts read the work file
    	TIME.STAMP= EB.SystemTables.getTimeStamp()[1,2]:EB.SystemTables.getTimeStamp()[4,2]:EB.SystemTables.getTimeStamp()[7,2]
        AgentWorkID = AGENT.LIST.ID:AA.Framework.Sep:TIME.STAMP:AA.Framework.Sep:SessionNo
        R.AA.AGENT.CUSTOMER.LIST = AA.AgentCommission.AgentCustomerWork.ReadU(AgentWorkID, LIST.ERR, "")
    END ELSE
        R.AA.AGENT.CUSTOMER.LIST = AA.AgentCommission.AgentCustomerList.ReadU(AGENT.LIST.ID, LIST.ERR, "")
* Before incorporation : CALL F.READU('F.AA.AGENT.CUSTOMER.LIST',AGENT.LIST.ID,R.AA.AGENT.CUSTOMER.LIST, F.AA.AGENT.CUSTOMER.LIST, LIST.ERR, "")
    END
RETURN
*-----------------------------------------------------------------------------
*** <region name= Update Activity>
*** <desc>Process updates </desc>
CHECK.UPDATION:

    BEGIN CASE
        CASE UPDATE.MODE<1> = 'UPDATE'
            GOSUB PROCESS.UPDATE.ACTION
        CASE UPDATE.MODE<1> = 'DELETE'
            GOSUB PROCESS.REVERSE.ACTION
    END CASE

    BEGIN CASE
        CASE UPDATE.MODE<1> = 'UPDATE' AND UPDATE.MODE<2> = 'REMOVE'
            LOCATE R.AGCU.REC<1> IN R.PREVIOUS.AG.CUSTOMER<AA.AgentCommission.AaAgentCustomer.AaAgcuArrangement,1> SETTING PRV.POS THEN
                DEL R.PREVIOUS.AG.CUSTOMER<AA.AgentCommission.AaAgentCustomer.AaAgcuArrangement,PRV.POS>
                DEL R.PREVIOUS.AG.CUSTOMER<AA.AgentCommission.AaAgentCustomer.AaAgcuAccrualId,PRV.POS>
                IF R.PREVIOUS.AG.CUSTOMER THEN
                    AA.AgentCommission.AaAgentCustomer.Write(PREVIOUS.ID, R.PREVIOUS.AG.CUSTOMER)
* Before incorporation : CALL F.WRITE("F.AA.AGENT.CUSTOMER",PREVIOUS.ID,R.PREVIOUS.AG.CUSTOMER)
                END ELSE
                    AA.AgentCommission.AaAgentCustomer.Delete(PREVIOUS.ID)
* Before incorporation : CALL F.DELETE("F.AA.AGENT.CUSTOMER",PREVIOUS.ID)
                END
            END
        CASE UPDATE.MODE<1> = 'DELETE' AND UPDATE.MODE<2> = 'REMOVE'
            LOCATE R.AGCU.REC<1> IN R.PREVIOUS.AG.CUSTOMER<AA.AgentCommission.AaAgentCustomer.AaAgcuArrangement,1> SETTING PRV.POS ELSE
                R.PREVIOUS.AG.CUSTOMER<AA.AgentCommission.AaAgentCustomer.AaAgcuAccrualId,-1> = R.AGCU.REC<1>
                AA.AgentCommission.AaAgentCustomer.Write(PREVIOUS.ID, R.PREVIOUS.AG.CUSTOMER)
* Before incorporation : CALL F.WRITE("F.AA.AGENT.CUSTOMER",PREVIOUS.ID,R.PREVIOUS.AG.CUSTOMER)
            END
    END CASE
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
PROCESS.UPDATE.ACTION:

    IF NOT(ERR.MSG) THEN      ;* Record exists
        LOCATE R.AGCU.REC<1> IN R.AA.AGENT.CUSTOMER<AA.AgentCommission.AaAgentCustomer.AaAgcuArrangement,1> SETTING ARPOS THEN       ;* Locate the arrangement. Should NOT find it!
            IF R.AGCU.REC<2> THEN
                R.AA.AGENT.CUSTOMER<AA.AgentCommission.AaAgentCustomer.AaAgcuAccrualId,ARPOS,-1> = R.AGCU.REC<2>
            END
* Arrangement is present. Just update this new ACCRUAL reference in the list

            WRITE.FLAG = 1    ;* Set flag for write
        END ELSE
            R.AA.AGENT.CUSTOMER<AA.AgentCommission.AaAgentCustomer.AaAgcuArrangement,-1> = R.AGCU.REC<1>
            WRITE.FLAG = 1
        END
    END ELSE
        R.AA.AGENT.CUSTOMER<AA.AgentCommission.AaAgentCustomer.AaAgcuArrangement> = R.AGCU.REC<1>
        WRITE.FLAG = 1
    END

    IF NOT(LIST.ERR) THEN
        LOCATE AGENT.CUSTOMER.ID IN R.AA.AGENT.CUSTOMER.LIST SETTING LIST.POS ELSE
            R.AA.AGENT.CUSTOMER.LIST<-1> = AGENT.CUSTOMER.ID
            LIST.WRITE.FLAG = 1
        END
    END ELSE
        R.AA.AGENT.CUSTOMER.LIST = AGENT.CUSTOMER.ID
        LIST.WRITE.FLAG = 1
    END

    IF WRITE.FLAG = 1 THEN
        GOSUB DO.WRITE        ;* Do write or delete
    END ELSE
        EB.DataAccess.FRelease("F.AA.AGENT.CUSTOMER", AGENT.CUSTOMER.ID, F.AA.AGENT.CUSTOMER)      ;* Remove the lock we have taken incase nothing is written
        EB.DataAccess.FRelease('F.AA.AGENT.CUSTOMER.LIST',AGENT.LIST.ID, F.AA.AGENT.CUSTOMER.LIST)
    END

RETURN
*-----------------------------------------------------------------------------
PROCESS.REVERSE.ACTION:
    IF R.AGCU.REC<1> AND R.AGCU.REC<2> EQ '' THEN
        LOCATE R.AGCU.REC<1> IN R.AA.AGENT.CUSTOMER<AA.AgentCommission.AaAgentCustomer.AaAgcuArrangement,1> SETTING ARPOS THEN       ;* Locate the arrangement. Should find it!
            DEL R.AA.AGENT.CUSTOMER<AA.AgentCommission.AaAgentCustomer.AaAgcuArrangement,ARPOS>        ;* Delete the arrangement from that position
            DEL R.AA.AGENT.CUSTOMER<AA.AgentCommission.AaAgentCustomer.AaAgcuAccrualId,ARPOS>
            IF NOT(R.AA.AGENT.CUSTOMER<AA.AgentCommission.AaAgentCustomer.AaAgcuArrangement,ARPOS>) THEN         ;* is this the only arrangement for this line
* Delete the line MV. We dont need it.
*remove accrual id phase2
            END
            WRITE.FLAG = 1
        END
    END
    IF R.AGCU.REC<1> AND R.AGCU.REC<2> THEN
        LOCATE R.AGCU.REC<1> IN R.AA.AGENT.CUSTOMER<AA.AgentCommission.AaAgentCustomer.AaAgcuArrangement,1> SETTING ARPOS THEN       ;* Locate the arrangement. Should find it!
            ALL.ACCRUAL.ID = R.AA.AGENT.CUSTOMER<AA.AgentCommission.AaAgentCustomer.AaAgcuAccrualId,ARPOS>
            FND.ACC.POS = ''
            LOCATE R.AGCU.REC<2> IN ALL.ACCRUAL.ID<1,1,1> SETTING FND.ACC.POS THEN
                DEL R.AA.AGENT.CUSTOMER<AA.AgentCommission.AaAgentCustomer.AaAgcuAccrualId,ARPOS,FND.ACC.POS>   ;* Delete the accrual id
                IF NOT(R.AA.AGENT.CUSTOMER<AA.AgentCommission.AaAgentCustomer.AaAgcuArrangement,ARPOS>) THEN     ;* is this the only arrangement for this line
**the line MV. We dont need it.
**accrual id phase2
                END
                WRITE.FLAG = 1
            END
        END

    END

    LOCATE AGENT.CUSTOMER.ID IN R.AA.AGENT.CUSTOMER.LIST SETTING LIST.POS THEN
        DEL R.AA.AGENT.CUSTOMER.LIST<LIST.POS>
        LIST.WRITE.FLAG = 1
    END

    IF WRITE.FLAG = 1 THEN
        GOSUB DO.WRITE
    END ELSE
        EB.DataAccess.FRelease("F.AA.AGENT.CUSTOMER", AGENT.CUSTOMER.ID, F.AA.AGENT.CUSTOMER)
        EB.DataAccess.FRelease('F.AA.AGENT.CUSTOMER.LIST',AGENT.LIST.ID, F.AA.AGENT.CUSTOMER.LIST)
    END

RETURN
*-----------------------------------------------------------------------------

DO.WRITE:

    IF R.AA.AGENT.CUSTOMER<AA.AgentCommission.AaAgentCustomer.AaAgcuArrangement> THEN        ;* Normal update
        AA.AgentCommission.AaAgentCustomer.Write(AGENT.CUSTOMER.ID, R.AA.AGENT.CUSTOMER)
* Before incorporation : CALL F.WRITE("F.AA.AGENT.CUSTOMER",AGENT.CUSTOMER.ID,R.AA.AGENT.CUSTOMER)
        IF LIST.WRITE.FLAG THEN
            IF ThisActivity EQ "TAKEOVER" THEN ;* For migrated contracts update work file instead of list file
                AA.AgentCommission.AgentCustomerWork.Write(AgentWorkID, R.AA.AGENT.CUSTOMER.LIST)
            END ELSE
                AA.AgentCommission.AgentCustomerList.Write(AGENT.LIST.ID, R.AA.AGENT.CUSTOMER.LIST)
* Before incorporation : CALL F.WRITE('F.AA.AGENT.CUSTOMER.LIST',AGENT.LIST.ID,R.AA.AGENT.CUSTOMER.LIST)
            END
        END
    END ELSE        ;* If the full line is deleted, the whole record might not be required!
        AA.AgentCommission.AaAgentCustomer.Delete(AGENT.CUSTOMER.ID)
* Before incorporation : CALL F.DELETE("F.AA.AGENT.CUSTOMER",AGENT.CUSTOMER.ID)
    END
    IF R.AA.AGENT.CUSTOMER.LIST ELSE
        AA.AgentCommission.AgentCustomerList.Delete(AGENT.LIST.ID)
* Before incorporation : CALL F.DELETE('F.AA.AGENT.CUSTOMER.LIST',AGENT.LIST.ID)
    END
RETURN
END
