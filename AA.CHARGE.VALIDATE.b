* @ValidationCode : MjotMTkzMTc1MzAzNzpDcDEyNTI6MTQ4ODI1Nzk5MjE0NTp5Z2F5YXRyaTo4OjA6NjIzOi0xOmZhbHNlOk4vQTpERVZfMjAxNzAyLjIwMTcwMTI4LTAxMzk6MzY3OjE4OQ==
* @ValidationInfo : Timestamp         : 28 Feb 2017 10:29:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ygayatri
* @ValidationInfo : Nb tests success  : 8
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : 623
* @ValidationInfo : Coverage          : 189/367 (51.4%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : DEV_201702.20170128-0139

*-----------------------------------------------------------------------------
* <Rating>-193</Rating>
*-----------------------------------------------------------------------------
    $PACKAGE AA.Fees
    SUBROUTINE AA.CHARGE.VALIDATE

*** <region name= PROGRAM DESCRIPTION>
*** 
*
** Provides cross-validation of data entered in a property for the
** arrangement property applications
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= MODIFICATION HISTORY>
***
* Modification History :
*
* 05/06/2006 - EN_10002958
*              New module AA.

* 08/11/06   - EN_10003116
*              Changes to Layout
*
* 23/04/07 - EN_10003333
*            Ref : SAR-2006-06-02-0004
*            Simple Fixed Charges
*
* 26/04/07 - BG_100013715
*            If charge type is not defined but charge amount is defined
*            then throw an error message.
*
* 09/07/07 - EN_10003439
*            Ref : SAR-2006-10-02-0016
*            Charge processing for arrangements
*
* 11/07/07 - BG_100014574
*            Ref : SAR-2006-10-02-0016
*            Bug fix for charge processing
*
* 10/08/07 - BG_100014878
*            Currency is mandatory when amount fields are input
* 01/08/08 - BG_100019420
*            To  allowing zero as charge amount,the mandatory check in the fields
*            FIXED.AMOUNT, CHARGE.RATE and CHG.AMOUNT has been removed.
*
* 10/09/08 - BG_100019881
*            Ref : TTS0803317
*            When charge routine is attached rest of the charge fields should not
*            be mandatory for calculated charge type
*
* 16/10/08 - EN_10003886
*            Ref : SAR-2008-08-29-0003
*            Changes to improve Performance. Routine name changed to new format.
*
* 29/09/09 - EN_10004372
*            Ref : SAR-2008-11-06-0004
*            BALANCE.CALC.TYPE & ACTIVITY.CALC.TYPE field has been removed.
*
* 05/10/10 - Task : 63067
*            Enhancement : 26636
*            Debit interest linked to limit amount
*            First tier amount in interest/charge property record is linked
*            to limit product condition record if left blank
*
* 13/12/10 - Task 113699
*            Debit interest linked to limit amount - Validation level bugs
*
* 13/09/10 - Task 52767
*            Enhancement 26644
*            Added validation for min.chg.waive and min.chg.amount fields.
*
* 08/04/11 - Task 188690
*            Defect 52292
*            Variable TIER.COUNT.USED is initialised.
*
* 30/12/11 - DEFECT_296948 TASK_299434
*            Error for missing charge property in Activity Charges
*
* 26/09/13 - Task : 729076
*            Enhancement : 717657
*            Charge attributes are incorporated as part of AA.Fess componentisation enhancement.
*
* 13/01/14 - Task : 886009
*            Defect : 883548
*            Negotiation rule only applied to arrangement level not product condition level.
*
* 04/12/13 - Task : 722397
*            Enhancement : 713762
*            Added Validations for CANCEL.PERIOD & ACCRUAL.RULE
*
* 24/07/14  - Enhancement : 874402
*             Task : 874408
*             New validations included when Refer Limit is Set to YES.
*
* 01/04/15 - Enhancement : 1221599
*            Task : 1277270
*            New field validations added for islamic enhancement
*
* 10/07/15 - Enhancement :1277980
*            Task:1367030
*            Accounting for Profit Enhancement
*            If INTERNAL.BOOKING is set then CONTRA.TARGET is appended with INT to raise entry on internal account
*
* 16/12/16 - Task : 1955248
*            Def  : 1926838
*            System should raise an error if AccountingAccrueFlag is Accrue and ChargeType is calculated
*
* 21/12/16 - Task : 1961899
*            Def  : 1849829
*            ACCRUAL.RULE should be allowed for Charge with Accrue/Amort option.
*
* 30/01/17 - Enhancement : 1931144
*		   	 Task		 : 1962326
*		     Validations extended for new fields TierSourceType, TierSourceBalance and TierSourceProperty in AA.PRODUCT.DESIGNER.
*		     Validates new field TIER.EXCLUSIVE 		
*            validates TierType and Base Calculation source.   			
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INSERTS>
***
    $USING AA.Limit
    $USING AA.ProductManagement
    $USING AA.ProductFramework
    $USING AA.Framework
    $USING AA.PaymentSchedule
    $USING AA.Accounting
    $USING EB.ErrorProcessing
    $USING EB.Utility
    $USING AA.Fees
    $USING EB.SystemTables

*** </region>
*** <region name= PROCESS LOGIC>
***



    GOSUB INITIALISE
*
    GOSUB PROCESS.CROSSVAL
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INIT>
***
INITIALISE:
    PROPERTY.ID = AA.Framework.getPropertyId()
    EFF.DATE = AA.Framework.getPropEffDate()
    ARR.NO = AA.Framework.getArrId()
    PRODUCT.ID = AA.Framework.getArrProductId()
    TIER.COUNT.USED = ""
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS.CROSSVAL>
PROCESS.CROSSVAL:
***
    IF EB.SystemTables.getMessage() EQ '' THEN     ;* Only during commit...
        BEGIN CASE
            CASE EB.SystemTables.getVFunction() EQ 'D'
                GOSUB DELETE.CROSSVAL
            CASE EB.SystemTables.getVFunction() EQ 'R'
                GOSUB REVERSE.CROSSVAL
            CASE 1      ;* The real crossval...
                GOSUB REAL.CROSSVAL
        END CASE
    END
*
    IF EB.SystemTables.getMessage() EQ 'AUT' OR EB.SystemTables.getMessage() EQ 'VER' THEN  ;* During authorisation and verification...
        GOSUB AUTH.CROSSVAL
    END
*
    IF EB.SystemTables.getMessage() EQ 'ERROR' THEN          ;* During delivery preview and default...

    END
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= REAL CROSSVAL>
***
REAL.CROSSVAL:
*
* Real cross validation goes here....
*
    BEGIN CASE
        CASE AA.Framework.getProductArr() EQ AA.Framework.Product   ;* If its from the designer level

        CASE AA.Framework.getProductArr() EQ AA.Framework.AaArrangement         ;* If its from the arrangement level
            GOSUB ARRANGEMENT.CROSSVAL
    END CASE
*


    GOSUB COMMON.CROSSVAL
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Arrangement Crossvalidations>
*** <desc>Arrangement level cross-validations</desc>
ARRANGEMENT.CROSSVAL:

    AA.Accounting.GetAccountingDetails(ARR.NO, PROPERTY.ID, "", EFF.DATE, R.ACCOUNTING.DETAILS, RETURN.ERROR)

*** Fixed amount should be give when charge type is fixed

    IF EB.SystemTables.getRNew(AA.Fees.Charge.FixedAmount) EQ "" AND EB.SystemTables.getRNew(AA.Fees.Charge.ChargeType) EQ 'FIXED' THEN
        EB.SystemTables.setAf(AA.Fees.Charge.FixedAmount)
        EB.SystemTables.setEtext("AA.CHG.FIX.AMT.MAND.INP")
        EB.ErrorProcessing.StoreEndError()
    END

    IF EB.SystemTables.getRNew(AA.Fees.Charge.ReferLimit) EQ 'YES' THEN
        EB.SystemTables.setAf(AA.Fees.Charge.ReferLimit)
        SOURCE.BALANCE.TYPE = ''
        RET.ERR = ''
        AA.Framework.GetSourceBalanceType(PROPERTY.ID, '', '', SOURCE.BALANCE.TYPE, RET.ERR)
        IF SOURCE.BALANCE.TYPE AND SOURCE.BALANCE.TYPE NE 'DEBIT' THEN
            EB.SystemTables.setEtext('AA.CHG.SOURCE.BALANCE.TYPE.NOT.DEBIT')
            EB.ErrorProcessing.StoreEndError()
        END

*** Input in REFER.LIMIT is allowed only for Accounts Product line. If iput is given for any other product line
*** then raise error message

        PRODUCT.LINE = AA.Framework.getActivityId()<AA.Framework.ActProductLine>

        IF PRODUCT.LINE AND PRODUCT.LINE NE "ACCOUNTS" THEN
            EB.SystemTables.setEtext('AA.INT.INPUT.ALLOWED.ONLY.FOR.ACCOUNTS.PRODUCTS')
            EB.ErrorProcessing.StoreEndError()
        END

        PROPERTY.CLASS = "LIMIT"
        LIMIT.PROPERTY.ID = ''; R.PROPERTY.RECORD = ''; REC.ERR = ''

        AA.ProductFramework.GetPropertyRecord('', ARR.NO, LIMIT.PROPERTY.ID, EFF.DATE, PROPERTY.CLASS, '', R.PROPERTY.RECORD, REC.ERR)
*** If limit condition is not included in the product then raise error message.

        IF NOT(R.PROPERTY.RECORD) THEN
            EB.SystemTables.setEtext('AA.CHG.LIMIT.DEFINATION.MISSING')
            EB.ErrorProcessing.StoreEndError()
        END ELSE
*** If limit record is exist then do validate mandatory limit details
            GOSUB VALIDATE.MANDATORY.LIMIT.DETAILS
        END
    END

    IF EB.SystemTables.getRNew(AA.Fees.Charge.ChargeType) EQ 'CALCULATED' THEN
        PRODUCT.RECORD = AA.Framework.getProductRecord()
        LOCATE PROPERTY.ID IN PRODUCT.RECORD<AA.ProductManagement.ProductDesigner.PrdCalcProperty,1> SETTING CALC.PROP.POS ELSE
        EB.SystemTables.setAf(AA.Fees.Charge.ChargeType)
        EB.SystemTables.setEtext('AA.CHG.CALC.TYPE.MISSING':@FM:PROPERTY.ID)
        EB.ErrorProcessing.StoreEndError()        
        END
        IF R.ACCOUNTING.DETAILS<AA.Framework.AccountingAccrueFlag> EQ 'ACCRUE' AND NOT(EB.SystemTables.getRNew(AA.Fees.Charge.ChargeRoutine)) THEN
            EB.SystemTables.setAf(AA.Fees.Charge.ChargeType)
            EB.SystemTables.setEtext("AA.CHG.CALC.NOT.ALLWD.WEN.ACCTNG.ACCRUE.FLAG.AS.ACCRUE")
            EB.ErrorProcessing.StoreEndError()
        END
        
    END

    ACCOUNTING.PROPERTY.CLASS = "ACCOUNTING"
    R.ACCOUNTING.PROPERTY.RECORD = ''
    ACCOUNTING.PROPERTY.ID = ''
    AA.ProductFramework.GetPropertyRecord('', ARR.NO, ACCOUNTING.PROPERTY.ID, EFF.DATE, ACCOUNTING.PROPERTY.CLASS, "", R.ACCOUNTING.PROPERTY.RECORD, REC.ERR)   ;* Get the record

    IF EB.SystemTables.getRNew(AA.Fees.Charge.CancelPeriod) THEN
        MAT.DATE = AA.Framework.getAccountDetails()<AA.PaymentSchedule.AccountDetails.AdMaturityDate>
        CANCEL.PERIOD = EB.SystemTables.getRNew(AA.Fees.Charge.CancelPeriod)
        START.DATE = AA.Framework.getRArrangement()<AA.Framework.Arrangement.ArrStartDate>
        EB.Utility.CalendarDay (START.DATE,'+',CANCEL.PERIOD)
        IF MAT.DATE AND (CANCEL.PERIOD GT MAT.DATE) THEN
            EB.SystemTables.setAf(AA.Fees.Charge.CancelPeriod)
            EB.SystemTables.setEtext('AA.CHG.CANCEL.PERIOD.SHOULD.BE.LESS.THAN.MATURITY.DATE')
            EB.ErrorProcessing.StoreEndError()
        END
        IF (PROPERTY.ID MATCHES R.ACCOUNTING.PROPERTY.RECORD<AA.Accounting.Accounting.AcpProperty>) OR ("CHARGE" MATCHES R.ACCOUNTING.PROPERTY.RECORD<AA.Accounting.Accounting.AcpPropertyClass>) ELSE
            EB.SystemTables.setAf(AA.Fees.Charge.CancelPeriod)
            EB.SystemTables.setEtext("AA.CHG.ACCRUAL.RULE.ALLOWED.ONLY.FOR.AMORT.PROPERTY")
            EB.ErrorProcessing.StoreEndError()
        END
    END
    IF EB.SystemTables.getRNew(AA.Fees.Charge.AccrualRule) THEN
        IF (PROPERTY.ID MATCHES R.ACCOUNTING.PROPERTY.RECORD<AA.Accounting.Accounting.AcpProperty>) OR ("CHARGE" MATCHES R.ACCOUNTING.PROPERTY.RECORD<AA.Accounting.Accounting.AcpPropertyClass>) ELSE
            EB.SystemTables.setAf(AA.Fees.Charge.AccrualRule)
            EB.SystemTables.setEtext("AA.CHG.ACCRUAL.RULE.ALLOWED.ONLY.FOR.AMORT.PROPERTY")
            EB.ErrorProcessing.StoreEndError() 
        END
        GOSUB GET.PROPERTY.RECORD 
        IF NOT(R.ACCOUNTING.DETAILS<AA.Framework.AccountingAccrueFlag> MATCHES 'ACCRUE':@VM: 'AMORT') AND NOT('REBATE.UNAMORTISED' MATCHES R.PROPERTY<AA.ProductFramework.Property.PropPropertyType>) THEN
            EB.SystemTables.setAf(AA.Fees.Charge.AccrualRule)
            EB.SystemTables.setEtext("AA.CHG.ACCRUAL.RULE.ALLOWED.FR.ACCRUE.OR.AMORT")
            EB.ErrorProcessing.StoreEndError()
        END 
        END 

    IF EB.SystemTables.getRNew(AA.Fees.Charge.InternalBooking) EQ "YES" THEN
        IF R.ACCOUNTING.DETAILS<AA.Framework.AccountingIntBookingCm> EQ "" OR R.ACCOUNTING.DETAILS<AA.Framework.AccountingIntAdjustcm> EQ "" OR R.ACCOUNTING.DETAILS<AA.Framework.AccountingIntBookingPm> EQ "" OR R.ACCOUNTING.DETAILS<AA.Framework.AccountingIntBookingPy> EQ "" OR R.ACCOUNTING.DETAILS<AA.Framework.AccountingIntWaivingCm> EQ "" THEN
            EB.SystemTables.setAf(AA.Fees.Charge.InternalBooking)
            EB.SystemTables.setEtext("AA.CHG.INTERNAL.BOOKING.NOT.SET")
            EB.ErrorProcessing.StoreEndError()
        END
    END
    
    GOSUB VALIDATE.TIER.TYPE     ;* Validate Tier Type 

    GOSUB CHECK.SOURCE.BASE.TYPE ;* Checks that the source base type is not PERIOD 
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Validate Mandatory Limit Details>
*** <desc>Limit validation when Refer Limit Set</desc>
VALIDATE.MANDATORY.LIMIT.DETAILS:

** Check below mandatory details when REFER.LIMIT is set as Y
* 1. Single Limit Should be set as Y
* 2. Limit Reference Should not be Null
* 3. Serial No should not be Null

    IF R.PROPERTY.RECORD<AA.Limit.Limit.LimSingleLimit> NE 'Y' THEN
        EB.SystemTables.setEtext('AA.CHG.SINGLE.LIMIT.SHD.BE.SET.WHEN.REFER.LIMIT.SET')
        EB.ErrorProcessing.StoreEndError()
    END

    IF NOT(R.PROPERTY.RECORD<AA.Limit.Limit.LimLimitReference>) THEN
        EB.SystemTables.setEtext('AA.CHG.LIMIT.REFERENCE.MANDATORY.WHEN.REFER.LIMIT.SET')
        EB.ErrorProcessing.StoreEndError()
    END

    IF NOT(R.PROPERTY.RECORD<AA.Limit.Limit.LimLimitSerial>) THEN
        EB.SystemTables.setEtext('AA.CHG.SERIAL.NO.MANDATORY.WHEN.REFER.LIMIT.SET')
        EB.ErrorProcessing.StoreEndError()
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= COMMON CROSSVAL>
***
COMMON.CROSSVAL:

*
* Common cross-validations for product and arrangement
*
    EB.SystemTables.setAf(AA.Fees.Charge.Currency)

    IF NOT(EB.SystemTables.getRNew(AA.Fees.Charge.Currency)) THEN
        GOSUB CHECK.AMOUNT.FIELDS
    END

    BEGIN CASE
        CASE EB.SystemTables.getRNew(AA.Fees.Charge.ChargeType) = 'FIXED'
            GOSUB VALIDATE.FIXED.CHARGE.TYPE          ;* Validation when defined charge type is fixed

        CASE EB.SystemTables.getRNew(AA.Fees.Charge.ChargeType) = 'CALCULATED'
            GOSUB VALIDATE.CALCULATED.CHARGE.TYPE     ;* Validation when defined charge type is caluclated

        CASE 1
            GOSUB VALIDATE.CHARGE.TYPE      ;* Validation for charge type is null

    END CASE

    GOSUB VALIDATE.UPTO.FIELDS ;* Validates Upto fields TierAmount,TierCount and TierTerm

    GOSUB VALIDATE.TIER.EXCLUSIVE ;* validates the TierExclusive Field   
    
    GOSUB VALIDATE.TIER.TERM      ;* validates TierTerm field
    
    GOSUB CHECK.TYPE.REBATE   ;* Validation For Cancel Period & Accrual Type


    RETURN

*** </region>
*-----------------------------------------------------------------------------
*** <region name= DELETE.CROSSVAL>
DELETE.CROSSVAL:
***
    BEGIN CASE
        CASE AA.Framework.getProductArr() EQ AA.Framework.Product   ;* If its from the designer level

        CASE AA.Framework.getProductArr() EQ AA.Framework.AaArrangement         ;* If its from the arrangement level

    END CASE
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= REVERSE.CROSSVAL>
REVERSE.CROSSVAL:
***
    BEGIN CASE
        CASE AA.Framework.getProductArr() EQ AA.Framework.Product   ;* If its from the designer level

        CASE AA.Framework.getProductArr() EQ AA.Framework.AaArrangement         ;* If its from the arrangement level

    END CASE
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= AUTH.CROSSVAL>
AUTH.CROSSVAL:
***
    BEGIN CASE
        CASE AA.Framework.getProductArr() EQ AA.Framework.Product   ;* If its from the designer level

        CASE AA.Framework.getProductArr() EQ AA.Framework.AaArrangement         ;* If its from the arrangement level

    END CASE
*
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Charge Error>
*** <desc> </desc>
CHARGE.ERROR:

    EB.SystemTables.setEtext('AA.CHG.INPUT.NOT.ALLOWED')
    EB.ErrorProcessing.StoreEndError()

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Validate fixed charge type>
*** <desc> </desc>
VALIDATE.FIXED.CHARGE.TYPE:

*** For fixed charge type the entire TIER.GROUPS related fields should be blank

    FOR I = AA.Fees.Charge.CalcThreshold TO AA.Fees.Charge.MinChgWaive
        EB.SystemTables.setAf(I)
        tmp.AF = EB.SystemTables.getAf()
        IF EB.SystemTables.getRNew(tmp.AF) THEN
            EB.SystemTables.setAf(tmp.AF)
            EB.SystemTables.setEtext('AA.CHG.NULL.FIELD.IF.CHG.TYPE')
            EB.ErrorProcessing.StoreEndError()
        END
    NEXT I

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Validate Calculated charge type>
*** <desc> </desc>
VALIDATE.CALCULATED.CHARGE.TYPE:

*** Fixed amount should not be input for calculated charge type
    IF EB.SystemTables.getRNew(AA.Fees.Charge.FixedAmount) NE "" THEN
        EB.SystemTables.setAf(AA.Fees.Charge.FixedAmount)
        EB.SystemTables.setEtext('AA.CHG.INP.ONLY.WHEN.CHG.TYPE.FIXED')
        EB.ErrorProcessing.StoreEndError()
    END

*** Charge Waive allowed only if minimum charge amount exist.
    IF EB.SystemTables.getRNew(AA.Fees.Charge.MinChgWaive) AND NOT(EB.SystemTables.getRNew(AA.Fees.Charge.MinChgAmount)) THEN
        EB.SystemTables.setAf(AA.Fees.Charge.MinChgAmount)
        EB.SystemTables.setEtext('AA.CHG.INP.ALLOW.ONLY.IF.MIN.CHG.AMT')
        EB.ErrorProcessing.StoreEndError()
    END

    IF EB.SystemTables.getRNew(AA.Fees.Charge.ChargeRoutine) THEN
        * When charge routine is defined for calculated charge type
        * the fields FIXED.AMOUNT to TIER.AMOUNT should not be input

        FOR K = AA.Fees.Charge.FixedAmount TO AA.Fees.Charge.CalcThreshold
            EB.SystemTables.setAf(K)
            tmp.AF = EB.SystemTables.getAf()
            IF EB.SystemTables.getRNew(tmp.AF) THEN
                EB.SystemTables.setAf(tmp.AF)
                EB.SystemTables.setEtext('AA.CHG.INP.NOT.ALLOW.CHG.TYPE')
                EB.ErrorProcessing.StoreEndError()
            END
        NEXT K

        FOR I = AA.Fees.Charge.TierGroups TO AA.Fees.Charge.RoundingRule
            EB.SystemTables.setAf(I)
            tmp.AF = EB.SystemTables.getAf()
            IF EB.SystemTables.getRNew(tmp.AF) THEN
                EB.SystemTables.setAf(tmp.AF)
                EB.SystemTables.setEtext('AA.CHG.INP.NOT.ALLOW.CHG.TYPE')
                EB.ErrorProcessing.StoreEndError()
            END
        NEXT I

        FOR M = AA.Fees.Charge.CalcTierType TO AA.Fees.Charge.TierAmount
            EB.SystemTables.setAf(M)
            tmp.AF = EB.SystemTables.getAf()
            IF EB.SystemTables.getRNew(tmp.AF) THEN
                EB.SystemTables.setAf(tmp.AF)
                EB.SystemTables.setEtext('AA.CHG.INP.NOT.ALLOW.CHG.TYPE')
                EB.ErrorProcessing.StoreEndError()
            END
        NEXT M

    END ELSE

        * When charge routine is not defined the other charge fields are mandatory

*** Tier groups are mandatory input

        IF NOT(EB.SystemTables.getRNew(AA.Fees.Charge.TierGroups)) THEN
            EB.SystemTables.setAf(AA.Fees.Charge.TierGroups)
            EB.SystemTables.setEtext('AA.CHG.INP.MAND.WHEN.CHG.TYPE.CAL')
            EB.ErrorProcessing.StoreEndError()
        END

        GOSUB VALIDATE.TIER.GROUP       ;* Validate the entire tier related set

    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name = Validate charge type>
VALIDATE.CHARGE.TYPE:

***Charge type should be mandatory when fixed amount is defined

    IF EB.SystemTables.getRNew(AA.Fees.Charge.FixedAmount) NE "" THEN
        EB.SystemTables.setAf(AA.Fees.Charge.ChargeType)
        EB.SystemTables.setEtext("AA.CHG.CHG.TYPE.MAND.INP")
        EB.ErrorProcessing.StoreEndError()
    END

**charge type should be give when  TIER GROUPS and charge caluclate routine are defined

    FOR L.AF  = AA.Fees.Charge.TierGroups TO AA.Fees.Charge.TierCount
        IF EB.SystemTables.getRNew(L.AF) AND NOT(EB.SystemTables.getRNew(AA.Fees.Charge.ChargeType)) THEN
            EB.SystemTables.setAf(AA.Fees.Charge.ChargeType)
            EB.SystemTables.setEtext("AA.CHG.CHG.TYPE.MAND.INP")
            EB.ErrorProcessing.StoreEndError()
        END
    NEXT L.AF

    RETURN
***</region>
*-----------------------------------------------------------------------------
*** <region name= Validate Tier Set>
*** <desc> </desc>
VALIDATE.TIER.GROUP:

    EB.SystemTables.setAf(AA.Fees.Charge.TierGroups)

    tmp.AF = EB.SystemTables.getAf()
    IF EB.SystemTables.getRNew(AA.Fees.Charge.ReferLimit) = 'YES' AND EB.SystemTables.getRNew(tmp.AF) NE 'BANDS' AND EB.SystemTables.getRNew(tmp.AF) NE 'LEVELS' THEN
        EB.SystemTables.setEtext('AA.ICV.APPLICABLE.FOR.LEVEL.OR.BAND')
        EB.ErrorProcessing.StoreEndError()
    END
    NO.OF.CALC.TIER.TYPE = DCOUNT(EB.SystemTables.getRNew(AA.Fees.Charge.CalcTierType),@VM)

    IF NOT(NO.OF.CALC.TIER.TYPE) THEN
        EB.SystemTables.setAf(AA.Fees.Charge.CalcTierType)
        EB.SystemTables.setEtext('AA.CHG.INP.MAND.WHEN.CHG.TYPE.CAL')
        EB.ErrorProcessing.StoreEndError()
    END

    FOR I = 1 TO NO.OF.CALC.TIER.TYPE
        EB.SystemTables.setAv(I)

*** Calc type and calc tier type is mandatory

        BEGIN CASE
            CASE NOT(EB.SystemTables.getRNew(AA.Fees.Charge.CalcTierType)<1,EB.SystemTables.getAv()>)
                EB.SystemTables.setAf(AA.Fees.Charge.CalcTierType)
                EB.SystemTables.setEtext('AA.CHG.INP.MAND.WHEN.CHG.TYPE.CAL')
                EB.ErrorProcessing.StoreEndError()

            CASE NOT(EB.SystemTables.getRNew(AA.Fees.Charge.CalcType)<1,EB.SystemTables.getAv()>)
                EB.SystemTables.setAf(AA.Fees.Charge.CalcType)
                EB.SystemTables.setEtext('AA.CHG.INP.MAND.WHEN.CHG.TYPE.CAL')
                EB.ErrorProcessing.StoreEndError()

        END CASE

*** If calc type is percentage then charge rate is mandatory and charge amount should not be input
*** If calc type is unit or flat then charge amount is madatory and charge rate should not be input

        BEGIN CASE
            CASE EB.SystemTables.getRNew(AA.Fees.Charge.CalcType)<1,EB.SystemTables.getAv()> EQ "PERCENTAGE"

                IF EB.SystemTables.getRNew(AA.Fees.Charge.ChgAmount)<1,EB.SystemTables.getAv()> THEN
                    EB.SystemTables.setAf(AA.Fees.Charge.ChgAmount)
                    EB.SystemTables.setEtext("AA.CHG.INP.NOT.ALLOWED":@FM:EB.SystemTables.getRNew(AA.Fees.Charge.CalcType)<1,EB.SystemTables.getAv()>)
                    EB.ErrorProcessing.StoreEndError()
                END

            CASE EB.SystemTables.getRNew(AA.Fees.Charge.CalcType)<1,EB.SystemTables.getAv()> EQ "FLAT" OR EB.SystemTables.getRNew(AA.Fees.Charge.CalcType)<1,EB.SystemTables.getAv()> EQ "UNIT"

                IF EB.SystemTables.getRNew(AA.Fees.Charge.ChargeRate)<1,EB.SystemTables.getAv()> THEN
                    EB.SystemTables.setAf(AA.Fees.Charge.ChargeRate)
                    EB.SystemTables.setEtext("AA.CHG.INP.NOT.ALLOWED":@FM:EB.SystemTables.getRNew(AA.Fees.Charge.CalcType)<1,EB.SystemTables.getAv()>)
                    EB.ErrorProcessing.StoreEndError()
                END

        END CASE

*** Tier max chage and tier min charge not allowed for flat type

        IF EB.SystemTables.getRNew(AA.Fees.Charge.CalcType)<1,EB.SystemTables.getAv()> EQ 'FLAT' THEN
            IF EB.SystemTables.getRNew(AA.Fees.Charge.TierMinCharge)<1,EB.SystemTables.getAv()> THEN
                EB.SystemTables.setAf(AA.Fees.Charge.TierMinCharge)
                EB.SystemTables.setEtext('AA.CHG.NULL.FIELD.IF.CALC.TYPE')
                EB.ErrorProcessing.StoreEndError()
            END

            IF EB.SystemTables.getRNew(AA.Fees.Charge.TierMaxCharge)<1,EB.SystemTables.getAv()> THEN
                EB.SystemTables.setAf(AA.Fees.Charge.TierMaxCharge)
                EB.SystemTables.setEtext('AA.CHG.NULL.FIELD.IF.CALC.TYPE')
                EB.ErrorProcessing.StoreEndError()
            END

        END

*** Tier min charge cannot be greater than tier max charges

        IF EB.SystemTables.getRNew(AA.Fees.Charge.TierMaxCharge)<1,EB.SystemTables.getAv()> AND EB.SystemTables.getRNew(AA.Fees.Charge.TierMinCharge)<1,EB.SystemTables.getAv()> AND EB.SystemTables.getRNew(AA.Fees.Charge.TierMinCharge)<1,EB.SystemTables.getAv()> GT EB.SystemTables.getRNew(AA.Fees.Charge.TierMaxCharge)<1,EB.SystemTables.getAv()> THEN
            EB.SystemTables.setAf(AA.Fees.Charge.TierMinCharge)
            EB.SystemTables.setEtext('AA.CHG.MIN.CHARGE.GT.MAX.CHARGE')
            EB.ErrorProcessing.StoreEndError()

        END
    NEXT I

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Check Amount Fields>
*** <desc> </desc>
CHECK.AMOUNT.FIELDS:

    IF EB.SystemTables.getRNew(AA.Fees.Charge.FixedAmount) OR EB.SystemTables.getRNew(AA.Fees.Charge.FreeAmount) OR EB.SystemTables.getRNew(AA.Fees.Charge.ChgAmount) OR EB.SystemTables.getRNew(AA.Fees.Charge.TierAmount) OR EB.SystemTables.getRNew(AA.Fees.Charge.ChargeRoutine) THEN
        EB.SystemTables.setEtext("AA.CHG.CCY.MAND.AMOUNT.INPUT")
        EB.ErrorProcessing.StoreEndError()
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= VALIDATE.UPTO.FIELDS>
*** <desc>Validates Upto fields </desc>
VALIDATE.UPTO.FIELDS:

    TIER.AMOUNT        =       EB.SystemTables.getRNew(AA.Fees.Charge.TierAmount)
    TIER.COUNT         =       EB.SystemTables.getRNew(AA.Fees.Charge.TierCount) 
    TIER.TERM          =       EB.SystemTables.getRNew(AA.Fees.Charge.TierTerm)
    REFER.LIMIT        =       EB.SystemTables.getRNew(AA.Fees.Charge.ReferLimit)
    ERROR.DETAILS      =       ""    
    AA.Fees.ValidateUptoField(TIER.AMOUNT, TIER.COUNT, TIER.TERM, REFER.LIMIT, ERROR.DETAILS)
    GOSUB HANDLE.ERROR  

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= VALIDATE.TIER.EXCLUSIVE>
*** <desc>validates the TierExclusive Field </desc>
VALIDATE.TIER.EXCLUSIVE:
   
    IF EB.SystemTables.getRNew(AA.Fees.Charge.TierExclusive)<1,NO.OF.CALC.TIER.TYPE> THEN
        ERROR.DETAILS<1> = AA.Fees.Charge.TierExclusive 
        ERROR.DETAILS<2> = NO.OF.CALC.TIER.TYPE
        ERROR.DETAILS<3> = 1
        ERROR.DETAILS<4> = "AA.CHG.NO.INPUT.FOR.FINAL.MV"    ;* Leave the final MV blank  
        GOSUB HANDLE.ERROR                                   ;* To populate error details         
    END 
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= VALIDATE.TIER.TERM>
VALIDATE.TIER.TERM:
*** <desc> </desc>

    TIER.GROUPS     =  EB.SystemTables.getRNew(AA.Fees.Charge.TierGroups)
    TIER.TERM       =  EB.SystemTables.getRNew(AA.Fees.Charge.TierTerm)
    CALC.TIER.TYPE  =  EB.SystemTables.getRNew(AA.Fees.Charge.CalcTierType)
    ERROR.DETAILS   =  ""
    AA.Fees.ValidateTierTerm(TIER.GROUPS, CALC.TIER.TYPE, TIER.TERM, ERROR.DETAILS)
    
    IF ERROR.DETAILS THEN
        GOSUB HANDLE.ERROR    
    END
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Check Cancel period & Accrual type Fields>
*** <desc> Check Cancel period & Accrual type Fields </desc>
CHECK.TYPE.REBATE:

    GOSUB GET.PROPERTY.RECORD
    IF R.PROPERTY THEN
         IF EB.SystemTables.getRNew(AA.Fees.Charge.CancelPeriod) NE '' THEN
            FIELD.NAME1  = AA.Fees.Charge.CancelPeriod
            GOSUB RAISE.UNAMORT.ERROR
        END
    END
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Get property record>
*** <desc> Get property record</desc>
GET.PROPERTY.RECORD:

    PROPERTY.NAME = PROPERTY.ID
    IF PROPERTY.NAME NE ''THEN
        AA.Framework.LoadStaticData("F.AA.PROPERTY", PROPERTY.NAME, R.PROPERTY, RET.ERROR)
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Raise Unamort Error>
*** <desc> Raise Unamort Error</desc>
RAISE.UNAMORT.ERROR:

    IF 'REBATE.UNAMORTISED' MATCHES R.PROPERTY<AA.ProductFramework.Property.PropPropertyType> ELSE
        EB.SystemTables.setAf(FIELD.NAME1)
        EB.SystemTables.setEtext('AA-INP.NOT.ALWD.UNMORT')
        EB.ErrorProcessing.StoreEndError()
    END

    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= VALIDATE.TIER.TYPE>
*** <desc>Validates Tier Type </desc>
VALIDATE.TIER.TYPE:

    TIER.TYPE     =  EB.SystemTables.getRNew(AA.Fees.Charge.CalcTierType)  ;* stores TierType
    ERROR.DETAILS  =  ""                                                   ;* stores error  
    AA.Fees.ValidateTierType(PROPERTY.ID, PRODUCT.ID, "", PRODUCT.RECORD, TIER.TYPE, ERROR.DETAILS) ;* Checks that BAND tiertype is not set for property having Tier source 
    GOSUB HANDLE.ERROR ;* To populate error details 
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= CHECK.SOURCE.BASE.TYPE>
*** <desc>Checks that the source base type is not PERIOD </desc>
CHECK.SOURCE.BASE.TYPE:

    SOURCE.BASE.TYPE = ""  ;* stores Base Calculation Type
    ERROR.DETAILS     = "" ;* stores error
    AA.Framework.GetSourceBaseType(PROPERTY.ID, PRODUCT.ID, "", PRODUCT.RECORD, "", SOURCE.BASE.TYPE, ERROR.DETAILS) ;* returns Base calculation type for the property

    IF SOURCE.BASE.TYPE EQ "PERIOD" THEN    ;* Oops! Base Calculation Type is PERIOD.Send error 
        ERROR.DETAILS<1> = AA.Fees.Charge.ChargeType   ;* setting field marker for error
        ERROR.DETAILS<2> = 1                           ;* setting value marker for errror  
        ERROR.DETAILS<4> = "AA.RTN.PERIOD.NOT.ALLOWED" ;* setting error message
        GOSUB HANDLE.ERROR
    END
    
    RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= HandleError>
*** <desc> </desc>
HANDLE.ERROR:

    TOT.ERROR.COUNT = DCOUNT(ERROR.DETAILS<1>, @VM)
    FOR AF.CNT = 1 TO TOT.ERROR.COUNT
        EB.SystemTables.setAf(ERROR.DETAILS<1, AF.CNT>)
        EB.SystemTables.setAv(ERROR.DETAILS<2, AF.CNT>)
        EB.SystemTables.setAs(ERROR.DETAILS<3, AF.CNT>)
        ErrorMessage = CHANGE(ERROR.DETAILS<4, AF.CNT>,@SM,@FM)       
        EB.SystemTables.setEtext(ErrorMessage)
        EB.ErrorProcessing.StoreEndError()
    NEXT AF.CNT

    RETURN
*** </region>
*-----------------------------------------------------------------------------

    END




