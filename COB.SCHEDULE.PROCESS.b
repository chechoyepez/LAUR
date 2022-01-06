* @ValidationCode : MjotNjY2MjIxMTUyOkNwMTI1MjoxNDk4NzM3NzczMTk2OkFkbWluaXN0cmF0b3I6LTE6LTE6MDowOmZhbHNlOk4vQTpSMTdfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 29 Jun 2017 17:32:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : Administrator
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R17_AMR.0
*-----------------------------------------------------------------------------
	$PACKAGE Cost.Borrowing
*-----------------------------------------------------------------------------
	SUBROUTINE COB.SCHEDULE.PROCESS
*-----------------------------------------------------------------------------
* Routine Name  : COB.SCHEDULE.PROCESS
* Description   : For cost of borrowing calculation system will trigger this routine,
*                 which must be attached under the activity under API product condition
*                 inorder to trigger ADHOC-COB-DISCLOSURE activity which shall generate
*                 advice to customer. Additionally it will cycle the next date of ADHOC activty
*                 which must be trigger if any given activities are not performed in mean time.
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* SI - 1708118 - Initial creation
* PACS00603190 & PACS00604230 - FSD003 Issues fix.
* PACS00635759 - Fix for the child activity not capturing parent AAA id.
* PACS00643139 - Excluded for the reversal authorisation.
* PACS00717317 - Issue in COB disclosure activity due to infinite looping 
* 166111       - MESSAGE.TYPE_99 CREATED BEFORE DISBURSED LOAN
*-----------------------------------------------------------------------------
    $USING AA.ProductFramework
    $USING AA.Framework
    $USING EB.SystemTables
    $USING Cost.Borrowing
    $USING EB.API
    $USING AA.PaymentSchedule
*-----------------------------------------------------------------------------

    GOSUB INITIALIZE 						;* Initialize process to get values for user variables.
    GOSUB GET.DISCLOSURE.DETAILS 			;* Check whether for given product and product group any records as been provided.
    CALL AA.SET.LOCAL.COMMONS				;*	PACS00603190 & PACS00604230 - FSD003 Issues fix.
	
	IF ARR.ACT.STATUS EQ "UNAUTH" AND ARR.ACT.STATUS.SUB NE "REV" AND ARR.STATUS EQ "CURRENT" THEN		;	* PACS00643139 - Excluded for the reversal authorisation.
		GOSUB GET.NEXT.ACTIVITY.DATE 	;* Based on the loc period, set the next activity date.
	END
	RETURN

*-----------------------------------------------------------------------------

*** <region name= INITIALIZE>
INITIALIZE:

*** <desc>Initialize process to get values for user variables. </desc>
    ARR.ID 				= AA.Framework.getC_aalocarrid() 						;* Arrangement ID
    ARR.PRODUCT.ID 		= AA.Framework.getArrProductId() 						;* Get Product
    ARR.RECORD 			= AA.Framework.Arrangement.Read(ARR.ID, ARR.ERR) 		;* Get Product record
    ARR.PRODUCT.GROUP 	= ARR.RECORD<AA.Framework.Arrangement.ArrProductGroup> 	;* Obtain product group from arrangement id.
    ARR.ACT.STATUS		= AA.Framework.getC_arractivitystatus()["-",1,1] 		;* Get current status of curr activity.
    ARR.ACT.STATUS.SUB	= AA.Framework.getC_arractivitystatus()["-",2,1] 		;* Get current status of curr sub activity.
    ACT.ID 				= AA.Framework.getCurrActivity() 						;* Current Activity
    ACT.EFF.DATE 		= AA.Framework.getActivityEffDate() 					;* Activity effective date
    CURR.ACT.ID 		= AA.Framework.getC_arractivityid() 					;* Current Activity ID.
    TODAY 				= EB.SystemTables.getToday()
    PROP.EFF.DATE 		= AA.Framework.getPropEffDate() 						;* Get Prop effective date.
    FIN.ARRANGEMENT     = AA.Framework.getRArrangement()                      
    ARR.STATUS          = FIN.ARRANGEMENT<AA.Framework.Arrangement.ArrArrStatus>
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GET.DISCLOSURE.DETAILS>
GET.DISCLOSURE.DETAILS:
*** <desc>Check whether for given product and product group any records as been provided. </desc>
*** To check whether the given product is avialable under Disclosure parameter table.

    PRD.REC = Cost.Borrowing.DisclosureParameter.Read(ARR.PRODUCT.ID, ERR.DETS)
    LOC.PERIOD = PRD.REC<Cost.Borrowing.DisclosureParameter.ParameterLocPeriod>
    COB.ACTIVITY = PRD.REC<Cost.Borrowing.DisclosureParameter.ParameterCobActivity>
    Y.OFS.VERSION = PRD.REC<Cost.Borrowing.DisclosureParameter.ParameterAaVersion>
    Y.OFS.SOURCE = PRD.REC<Cost.Borrowing.DisclosureParameter.ParameterOfsSource>
	IS.LOC.PRODUCT = PRD.REC<Cost.Borrowing.DisclosureParameter.ParameterLocProduct>
	
	
*** To check whether the given product group is avialable under Disclosure parameter table.
    IF NOT(PRD.REC) THEN
        PRD.GRP.REC = Cost.Borrowing.DisclosureParameter.Read(ARR.PRODUCT.GROUP, ERR.PG.DETS)
        LOC.PERIOD = PRD.GRP.REC<Cost.Borrowing.DisclosureParameter.ParameterLocPeriod>
	    COB.ACTIVITY = PRD.GRP.REC<Cost.Borrowing.DisclosureParameter.ParameterCobActivity>
	    Y.OFS.VERSION = PRD.GRP.REC<Cost.Borrowing.DisclosureParameter.ParameterAaVersion>
	    Y.OFS.SOURCE = PRD.GRP.REC<Cost.Borrowing.DisclosureParameter.ParameterOfsSource>
		IS.LOC.PRODUCT = PRD.GRP.REC<Cost.Borrowing.DisclosureParameter.ParameterLocProduct>
    END
	
	
*** If both the product and product group is not avialable under Disclosure parameter table, utlize the system record.
    IF NOT(PRD.REC) AND NOT(PRD.GRP.REC) THEN
        SYS.REC = Cost.Borrowing.DisclosureParameter.Read("SYSTEM", SYS.DETS)
        LOC.PERIOD = SYS.REC<Cost.Borrowing.DisclosureParameter.ParameterLocPeriod>
	    COB.ACTIVITY = SYS.REC<Cost.Borrowing.DisclosureParameter.ParameterCobActivity>
	    Y.OFS.VERSION = SYS.REC<Cost.Borrowing.DisclosureParameter.ParameterAaVersion>
	    Y.OFS.SOURCE = SYS.REC<Cost.Borrowing.DisclosureParameter.ParameterOfsSource>
		IS.LOC.PRODUCT = SYS.REC<Cost.Borrowing.DisclosureParameter.ParameterLocProduct>
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= GET.NEXT.ACTIVITY.DATE>
GET.NEXT.ACTIVITY.DATE: 
*** <desc>Based on the loc period, set the next activity date. </desc>

    BEGIN CASE
    
        CASE ACT.ID MATCHES "LENDING-NEW-ARRANGEMENT":@VM:"ADHOC-COB-DISCLOSURE" ;* For NEW arrangement or the if the ADHOC activity is triggered as secondary or manually
            IF IS.LOC.PRODUCT EQ 'YES' THEN
				EFFECTIVE.DATE = ACT.EFF.DATE
				GOSUB SET.ADHOC.ACTIVITY ; *Add the adhoc activity under schedule activity list. ;* System as to amend or create a new item for ADHOC activity under scheduled list.
			END
*** If future dated scenarios skip the process, as the current activity would be already scheduled and same shall be picked during COB of given future date.
*** During that cyclic process ADHOC activity would be triggered.
        CASE (ACT.EFF.DATE GT TODAY) OR (PROP.EFF.DATE GT TODAY)

        CASE ACT.EFF.DATE LE TODAY ;* For Backdated activity need to trigger ADHOC activity for current date.
            
			ProcessType = "APPEND.TO.LIST" ;* kundan - Replaced ofsaddlocalrequest with Secondary activity concept
            Narrative = ''
            AaaRec<AA.Framework.ArrangementActivity.ArrActArrangement>   = AA.Framework.getC_aalocarrid()
            AaaRec<AA.Framework.ArrangementActivity.ArrActEffectiveDate> = AA.Framework.getC_aalocactivityeffdate()
            AaaRec<AA.Framework.ArrangementActivity.ArrActCurrency>      = AA.Framework.getArrCurrency()
            AaaRec<AA.Framework.ArrangementActivity.ArrActActivity>      = COB.ACTIVITY
            AaaRec<AA.Framework.ArrangementActivity.ArrActNarrative>     = AA.Framework.getC_aalocarractivityid()
            AaaRec<AA.Framework.ArrangementActivity.ArrActLinkedActivity>= AA.Framework.getC_aalocarractivityid()          
            AA.Framework.SecondaryActivityManager(ProcessType, AaaRec)
			
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= SET.ADHOC.ACTIVITY>
SET.ADHOC.ACTIVITY:
*** <desc>Add the adhoc activity under schedule activity list. </desc>
    NEW.ACTIVITY.ID = COB.ACTIVITY
    EB.API.Cdt("",EFFECTIVE.DATE, LOC.PERIOD) ;* Calculate the next date of ADHOC activity based on LOC period set under Disclosure Parameter table.
    NEXT.RUN.DATE = EFFECTIVE.DATE
*** If its ADHOC activity then it must be cycled considering last run date as current activity effective date.
	AA.Framework.SetScheduledActivity(ARR.ID, NEW.ACTIVITY.ID, NEXT.RUN.DATE, "AMEND", RetErr)
RETURN
*-----------------------------------------------------------------------------
*** </region>
END
