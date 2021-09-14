**-----------------------------------------------------------------------------
* <Rating>-62</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.AgentCommission
    SUBROUTINE AA.UPDATE.AGENT.COMMISSION(UPDATE.MODE,BILL.TYPE,BILL.DETAILS,BILL.ID)
*** <region name= Program Description>
*** <desc>Purpose of the sub-routine</desc>
* Program Description
*
* Routine to update the AA.AGENT.COMMISSION.DETAILS file during arrangement updation
*
*-----------------------------------------------------------------------------
** @package retaillending.AA
* @stereotype subroutine
* @ author
*-----------------------------------------------------------------------------
* Modification:
*  26/03/2014 - EN_874133
*               Task : 933543
*               Call routine to update agent commission dets table
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING AA.AgentCommission


*
*** </region>
*-----------------------------------------------------------------------------

    GOSUB INITIALISE
    GOSUB CHECK.UPDATION

*
    RETURN
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
INITIALISE:

    F.AA.AGENT.COMMISSION = ''  ; R.AGENT.COMMISSION = ''

    R.AGENT.COMMISSION = AA.AgentCommission.AaAgentCommissionDetails.Read(BILL.ID, ERR.MSG)

    MASTER.ACT.ID = AA.Framework.getAaMasterActivity()<1,2>

    RETURN
*-----------------------------------------------------------------------------
*** <region name= Update Activity>
*** <desc>Process updates </desc>
CHECK.UPDATION:

    BEGIN CASE
        CASE UPDATE.MODE = 'UPDATE' AND BILL.TYPE = 'COMMISSION'
            GOSUB PROCESS.UPDATE.ACTION
        CASE UPDATE.MODE = 'REVERSE' AND BILL.TYPE = 'COMMISSION'
            GOSUB PROCESS.REVERSE.ACTION
    END CASE

    RETURN
*** </region>
*----------------------------------------------------------------------------
*** <region name= Initialise>
*** <desc>Initialise local variables and file variables</desc>
PROCESS.UPDATE.ACTION:

    IF AA.Framework.getAgentCommissionDets()<1> THEN
        R.AGENT.COMMISSION<AA.AgentCommission.AaAgentCommissionDetails.AaAgcomDetArrangement> = AA.Framework.getAgentCommissionDets()<1>
    END ELSE
        RETURN
    END
    IF BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOrTotalAmtLcy> THEN
        R.AGENT.COMMISSION<AA.AgentCommission.AaAgentCommissionDetails.AaAgcomDetAmount> = FMT(BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOrTotalAmtLcy>, "R2")
    END ELSE
        R.AGENT.COMMISSION<AA.AgentCommission.AaAgentCommissionDetails.AaAgcomDetAmount> = FMT(BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOrTotalAmount>, "R2")
    END
    IF AA.Framework.getAgentCommissionDets()<2> THEN
        R.AGENT.COMMISSION<AA.AgentCommission.AaAgentCommissionDetails.AaAgcomDetMarginAmount> = FMT(AA.Framework.getAgentCommissionDets()<2>, "R2")
    END
    IF AA.Framework.getAgentCommissionDets()<3> THEN
        R.AGENT.COMMISSION<AA.AgentCommission.AaAgentCommissionDetails.AaAgcomDetMarginRate> = AA.Framework.getAgentCommissionDets()<3>
    END
    IF AA.Framework.getAgentCommissionDets()<4> THEN
        R.AGENT.COMMISSION<AA.AgentCommission.AaAgentCommissionDetails.AaAgcomDetMarginPercent> = AA.Framework.getAgentCommissionDets()<4>
    END
    IF AA.Framework.getAgentCommissionDets()<5> THEN
        R.AGENT.COMMISSION<AA.AgentCommission.AaAgentCommissionDetails.AaAgcomDetAgentEvent> = AA.Framework.getAgentCommissionDets()<5>
    END
    IF R.AGENT.COMMISSION THEN
        R.AGENT.COMMISSION<AA.AgentCommission.AaAgentCommissionDetails.AaAgcomDetCommissionNature> = 'ONLINE' ;* Always online
        IF FIELD(MASTER.ACT.ID,'*',2) THEN
            R.AGENT.COMMISSION<AA.AgentCommission.AaAgentCommissionDetails.AaAgcomDetAmount> = AA.Framework.getAgentCommissionDets()<6>         ;* Overwrite for schedule
            R.AGENT.COMMISSION<AA.AgentCommission.AaAgentCommissionDetails.AaAgcomDetCommissionNature> = 'SCHEDULED'
        END
        AA.AgentCommission.AaAgentCommissionDetails.Write(BILL.ID, R.AGENT.COMMISSION)         ;* Do write
    END
    AA.Framework.setAgentCommissionDets('');* Clear once its write on the file

    RETURN
*-----------------------------------------------------------------------------
PROCESS.REVERSE.ACTION:

    IF NOT(ERR.MSG) THEN
        AA.AgentCommission.AaAgentCommissionDetails.Delete(BILL.ID)
    END

    RETURN
*-----------------------------------------------------------------------------
    END
