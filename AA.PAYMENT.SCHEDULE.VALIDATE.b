* @ValidationCode : MjotMTc3MTA1MDI3OTpDcDEyNTI6MTYzNDc5OTA4MTA5Mjp2LmRlZXBpa2E6NjowOjA6LTE6ZmFsc2U6Ti9BOlIxN19TUDU4LjA6MTY5MTo3Nzg=
* @ValidationInfo : Timestamp         : 21 Oct 2021 12:21:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : v.deepika
* @ValidationInfo : Nb tests success  : 6
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 778/1691 (46.0%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R17_SP58.0
* <Rating>10325</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.PaymentSchedule
SUBROUTINE AA.PAYMENT.SCHEDULE.VALIDATE

*** <region name= PROGRAM DESCRIPTION>
***
*
** Provides cross-validation of data entered in a property for the
** arrangement property applications
*
*** </region>
*-----------------------------------------------------------------------------
*
*** <region name= MODIFICATION HISTORY>
***
* Modification History :
*
* 17/04/08 - BG_100018160
*            Ref : TTS0801286
*            Validations to check whether due freq. is same as payment freq. when
*            there is only one property under a payment type
*
* 25/04/08 - BG_100018260
*            Ref : TTS0801383
*            Duplicate and blank payment types should be allowed
*            for an arrangement
*
* 30/05/08 - BG_100018569
*            Ref : TTS0801382
*            When start date is defined for a payment number of payments should
*            be reduced by 1. This is done to include start date also as a payment
*
* 02/06/08 - BG_100018434
*            Ref : TTS0801814
*            Include an extra argument PAYMENT.METHODS to denote the
*            payment methods for each payment type in the routine
*            AA.BUILD.PAYMENT.SCHEDULE.SCHEDULES
*
* 13/06/08 - BG_100018451
*            Ref : TTS0801642
*            Incorrect validation error is avoided by using TAKEOVER.FLAG
*
* 18/08/08 - BG_100019571
*            Ref : SAR-2008-02-18-0008
*            Removing the call to the Routine AA.GET.BASE.DATE.
*
* 11/09/08 - BG_100019900
*            Ref : TTS0802623
*            Correct the for loop counter in the para CHECK.FULL.SCHEDULES
*
* 16/10/08 - EN_10003886
*            Ref : SAR-2008-08-29-0003
*            Changes to improve Performance. Routine name changed to new format.
*
* 07/11/08 - BG_100020745
*            Ref : TTS0804207
*            Initialised variabe OUTSTANDING.AMOUNT
*
* 26/12/08 - BG_100021149
*            Ref : TTS0707043
*            BASE.DATE field validation is stopped.
*
* 21/02/09 - BG_100022268
*            Check if Simulation record is required.
*
* 02/03/09 - BG_100022332
*            Ref : TTS0906121
*            Check whether Activity defined in ON.MATURITY field belongs to the product.
*
* 11/03/09 - BG_100022607
*            Ref : TTS0803202
*            APPLY.PAYMENT field will accept only LENDING-SETTLE activities.
*
* 29/04/09 - EN_10004061
*            Ref : SAR-2008-09-17-0005
*            Removed the arrangement level dafaulting of DATE.CONVENTION,
*            DATE.ADJUSTMENT and BUS.DAY.CENTRES
*
* 28/05/09 - BG_100023814
*            Ref : TTS0907542
*            typo error - BUS.DAY.CENTRES
*
* 27/05/09 - CI_10063284
*            Don't use R.OLD for validation as it won't have the true value during  R & R
*
* 06/05/09 - EN_10004088
*            Ref : SAR-2008-09-17-0009
*            Payment Type with the field EXTEND.CYCLE as INTEREST must be used only for Interest Property.
*
* 04/07/09 - BG_100024271
*            Ref : TTS0908001, TTS0908262
*            Schedule projection routine is being called from action routine and therefore it is being
*            removed from validate routine.
*            Add an arrgument to AA.GET.CALC.TYPE routine.
*
* 27/05/09 - EN_10004127
*            Ref : SAR-2008-09-17-0004
*            Should allow multiple payment types for Regular Special payment types.
*
* 05/08/09 - CI_10065112
*            Ref : HD0928098
*            New argument added to the AA.GET.TERM.END.DATE routine.
*
* 01/10/09 - BG_100025311
*            Replaced the call to AA.GET.ARRANGEMENT.PRODUCT with AA.GET.ARRANGEMENT.PROPERTIES
*            to get the list arrangement of properties.
*            Ref: HD0935492
*
* 29/10/09 - EN_10004405
*            SAR-2008-11-06-0009
*            Deposits Review SAR
*
* 11/11/09 - EN_10004430
*            Ref : SAR-2008-11-06-0015
*            Validation made for PERIODIC.CHARGES.
*
* 27/11/09 - BG_100025852
*            Ref : TTS090675
*            Should not allow Calculated type Payment types for MAINTAIN payment method
*
* 12/02/09 - Task ID - 21914
*            Defect ID - 21634
*            Variable RET.ERROR is nitialised with null.
* 26/04/10 - Enhancement Id - 19298
*            Task Id - 42379
*            Opening fields MATURITY.DATE/TERM for CALL contracts.
*
* 05/05/10 - Task- 42379
*            For call contracts and for fixed maturity contracts where interest is pending
*            and needs to be collected, it should be possible to define Due frequency,
*            payment frequency etc during Takeover.
*
* 08/06/10 - Defect-52798 Task-56425
*            Allow user to keyin same Start and End Date.
*
* 27/07/10 - Enhancement # 19158
*            Task # 22821
*            The Field Start date and End date has been changed to relative date fields.
*
* 17/08/10 - Defect 72401 // Task 73097
*            Combined bills should be allowed only when all the properties under various payment types of
*            an arrangement belongs to same balance type in AA.SOURCE.CALC.TYPE.
*
* 10/09/10 - Task 85508
*            Defect : 84859
*            Pass Term amount record to AA.DETERMINE.CONTRACT.TYPE.
*
* 25/08/10 - Task : 38558
*            Enhancement : 26802
*            Changes to improve performance.
*
* 06/10/10 - 94930
*            Ref : 94818
*            Default the DUE.FREQ value with PAYMENT.FREQ while triggering of change product activity.
*
* 24/11/10 - Enhancement # 73414
*            Task # 109806
*            New validation added if CALC.TYPE is PROGRESSIVE(Same as CONSTANT type)
*
* 13/12/10 - Task : 117803
*            Ref: 114937
*            Next schedule date should be less than maturity date. Else it won't allow to commit the record
*
* 06/01/11 - Task: 126714
*            Ref: 52292
*            If in SIMULATION.CAPTURE, then payment types are not validated
*
* 12/01/11 - Task: 121524
*            Ref: 114937
*            Error message is raised when term is less than frequency unless it is not simulation capture, current
*            activity is not run after payment end date and not during Take over.
*
* 20/01/11 - Task 132372
*            Ref : 132266
*            Don't call AA.PROCESS.ACCOUNT.DETAILS with INITIALISE process.
*            Use AA$ACCOUNT.DETAILS instead.
*
* 25/01/11 - Task 123404
*            Enhancement 26166
*            Added new arguments to AA.GET.RELATIVE.DATE routine
*
* 08/01/11 - Task : 38575
*            Ref : Enhancement 26768
*            ISSUE.BILL can be set to NO only when BILL.PRODUCED is zero
*
* 21/01/11 - Ref: 56308
*            Task : 77535
*            Enable periodic charges to be capitalised
*
* 21/03/11 - Defect_52292
*            Task _ 176315
*            In Call Contract while running in the simulation runner it will throw error
*            if  we didnt give the Term and maturity date. To avoid this  Common variable
*            aaSimRef used to stop the error.
*
* 29/03/11 - Defect : 137812
*    Task : 181071
*    Due frequency is defaulted from Payment Frequency when only one property under the payment type.
*
* 08/04/11 - Defect 52292
*            Task 188690
*            Variable CNT Initialised.
*
* 15/04/11 - Task : 192499
*            Defect : 191336
*            AA.PAYMENT.SCHEDULE.VALIDATE, we need to raise the error message only when there is a valid TERM.END.DATE.
*
* 03/05/11 - Task :202785
*           Defect : 201165
*           Validation done in such a way if none of  frequency, start date or end date is specified,
*           then system has to throw error message for the payment type.
*
* 27/05/11 - Task : 217894
*            Defect:216499
*            The Zero amount is allowed if the calc type is defined as "ACTUAL" in Payment type.
*
* 31/05/11 - Task 218459
*            Defect 205190
*            Code has been changed if arrangement contain more than 1 payment type and
*            at arrangement level 1st payment type deleted, and the frequency for 1st payment type
*            is given for 2nd payment, it's throwgin error, if we change the payment frequency
*            for 2nd payment type the due frequency defaulted and the error is not throwing.
*            Now it wont defaulted and the error will thrown.
*
* 06/06/11 - Task : 220622
*            Defect : 219866
*            Unable to input zero amount and zero term for TAKEOVER contract.
*
* 27/06/11 - Task 234608
*            Ref : Defect 232221/195426
*            Validate against Payment dates only for new arrangement
*
* 19/07/11 - 246619
*            Defect : 246300
*            System will not throw error message while amending the payment frequency of constant payment type.
*
* 17/05/11 - Task - 271452
*            Defect - 266604 (Ref - 143986)
*            If same payment type having the different payment methods then raise the error message.
*            If same payment payment type/same property/same payment method then check the start/end date, it shouldnt fall in the other set
*
* 04/09/11 - 264997
*            Ref : 251062
*            Due frequency defaults from PaymentFrequency and overwrites product definition
*
* 30/09/11 - Task : 269819
*            Ref : 269292
*            Allow Payment Schedule definition for Takeover contracts. They might still have interest for accruals.
*
* 31/10/11 - Task : 287023
*            Defect: 252901
*            Penalty Interest should be scheduled after the maturity date also if the source balance is available.
*
* 03/11/11 - Task : 302911
*            Ref : Defect 294278
*            Sytem has made to allow interest and charge propety alone in PS record after payment end date.
*
* 03/11/11 - Task - 306448
*            Defect - 299341
*            When payment type and Frequency are modified at the Arrangement level, default DUE frequency
*
* 20/10/11 - Task - 279394
*            Ref : 277482
*            Validation to check, negative interest should not be defined as part of CONSTANT payment types
*            and Payment method should not be the CAPITALISE for the Negative interest property.
*
* 18/11/11 - Task - 312001
*            Defect - 310705
*            Validation of negative interest rate is being done in common crossval. At this poing, since arrangement id
*            is unavailable, MISSING ARRANGEMENT ID error message gets set when setting up product condition for
*            payment schedule itself (AA.PRD.DES.PAYMENT.SCHEDULE).
*
* 01/11/11 - Task 22911
*            Ref : Enhancement 19308
*            BillType soft-coded under AA.BILL.TYPE
*            Only Payment and Expected BillTypes should be allowed
*
* 03/11/11 - 247217
*            Allow PAY method only for CREDIT property.
*
* 01/11/11 - Task 22911
*            Ref : Enhancement 19308
*            BillType soft-coded under AA.BILL.TYPE
*            Only Payment and Expected BillTypes should be allowed
*
* 07/01/12 - Task 335798
*            Ref : Defect 191418
*            Validation error over Payment Schedule with relative date setup at designer level has stopped.
*
*            Only Payment and Expected BillTypes should be allowed.
*
* 17/01/11 - Task : 341133
*            Defect : 333995
*            Error should not be thrown if same payment type defined with different start dates.
*            Removed the validation of comparing START.DATE and END.DATE of different payment types.
*
* 17/02/12 - Task_357622
*     Ref : Defect_355636
*            Sytem has made to allow interest and charge propety alone in PS record after maturity date.
** 25/01/12 - Task 345351
*            Ref : 196006
*            Allow negative rate with Capitalisation
*
* 17/02/12 - Task_357622
*     Ref : Defect_355636
*            Sytem has made to allow interest and charge propety alone in PS record after maturity date.
*
* 29/03/12 - Task : 380837
*            Defect : 359587
*            Default due frequency from payment frequency.
*
* 08/05/12 - Task : 401657
*            Ref : Defect 401565
*            Compilation error due to an additional "END".
*
* 24/05/12 - Task : 410919
*            Ref :  Defect 406607
*            Take over of a matured contract fails with error - "FINAL END DATE GREATER THAN TERM END DATE"
*
* 25/05/12 - Task : 412044
*            Ref : Defect 408941
*            During simulation with start date set as R_MATURITY, system throws error.
*
* 30/04/12 - Task: 398109
*            Defect: 353312
*            Raise Override message when principal outstanding balance becomes zero
*
*
* 28/05/12 - Task : 412444
*            Ref : Defect 407588
*           Capitalisation not allowed after maturity date.
*
*
* 25/06/12 - Task: 428473
*            Ref:  424381
*            When maturity date is less than the frequency defined throw error message.
*
*
* 26/07/12 - Task 452218
*            Ref : Defect 427673
*            For capitalise method, allow end date beyond maturity date.
*
* 14/08/12 - Task : 463545
*            Ref : Defect 461409
*            Set payment frequency as mandatory when Term is present and start date is not inputted.
*
* 06/12/12 - Task : 534728
*            Def  : 529882
*            Allowed the Percentage to be inputted only if CALC.TYPE field of AA.PAYMENT.TYPE file matches "ACTUAL" or "OTHER".
*
* 15/10/12 - Enhancement : 352104 / Task : 395784
*            Automatic Scheduled Disbursements
*     Validations for disbursement type bills
*
* 06/02/12 - Defect : 575787 / Task : 581971
*            Raise an error message for duplicate start dates for disbursement schedule
*
* 09/04/13 - Defect : 639932 / Task : 645107 & 649262
*            Raise an error message when total disbursement amount defined with start date
*            is greater than the commitment amount.
*
* 10/03/13 - Defect :608841 Task : 608843
*            If the Penalty Interest property has "ACCRUAL.BY.BILLS" type set, then it cannot be
*            defined in payment schedule condition.
*
* 16/08/13 - Enhancement : 722373 /Task : 713760
*            Minimum payment Amount
*            Validations for new fields introduced
*
* 14/08/13 - Task : 756499
*            Defect : 754398
*            Validation for disbursement bill type.
*
* 08/08/13 - Task :751621
*            Defect : 749012
*            Include I_F.AA.ACTIVITY.CLASS since we calling AA.VALIDATE.ALLOWED.ACTIVITY with AA.ACC.USED.PROPCLASS,AA.ACC.USED.FIELD fields
*
* 21/08/13 - Defect : 509398 Task :720965
*            New validate has been introduced to stop duplicate payment type
*            different bill produced and same property defined in payment schedule.
*
* 10/12/13  - Enhancement : 713743 / Task : 719998
*             New validations introduced to process Deferment Payment
*
* 17/12/13 - Task : 866700
*    Defect : 863033
*    Conversion of Relative dates must be handled initially.
* 06/11/13 - Task : 828805
*            Defect : 823284
*            If Disbursement type payment percentage is less than 100 then raise override meesage.
*
*
* 26/12/13 - Defect:- 846980
*            Task:- 873142
*            Payment method "PAY" is not allowed for the lending product arrangement which doesnt have negative interest rate setup.
*
* 27/12/13 - Task : 872540
*            Defect : 870774
*            System must throw an override when there is DECREASE/INCREASE term amount is triggered.
*
* 27/12/13 - Task : 874667
*            Defect : 857351
*            Error message has been refined to display the dates.
*            Payment date and term end date validation has been restricted only to account property class.
*
* 10/11/13 - Task   : 806944
*            Defect : 802698
*            Raise Override message when payment schedule's actual amount is less than toatl commitment amount
*
* 10/02/14 - Task : 679832
*        - Def  : 659598
*          - Validations has been added to stop user from entering value in the END.DATE, rather START.DATE without frequncy can be entered
*
* 11/02/14 - Defect : 754096 Task : 911280
*            Product is not changed to call deposit while CHANGE.PRODUCT activity
*
* 26/02/14 - Task   : 925698
*            Defect : 919896
*            For payoff activity no need to check the outstanding balance
*
* 13/03/14 - Task : 940690
*            Defect: 931487
*            System throws "Principal outstanding balance becomes zero on XXXX" override message while doing prepayment.
*
* 23/03/14 - Task : 931571
*            Enhancement : 874095
*            Interest Upfront changes
*
* 22/04/14 - Task: 971843
*            Defect: 954860 & Ref: PACS00354140
*            System validate the actual amount field during the payment schedule product condition creation itself.
*
* 28/04/14 - Task: 983534
*            Defect: 954860 & Ref: PACS00354140
*            System raise ACTUAL.AMT- MANDATORY FOR CALC TYPE error message for calculate payment types.
*
* 27/05/14 - Task :
*            Ref : 976084
*            New argument added to the AA.GET.RELATIVE.DATE routine.
*
* 26/06/14 - Task : 1040041
*            Def  : 1034592
*            Do a summation of TOT.PERCENTAGE from the proper position to avoid the override message during auto disbursement in full
*
* 20/05/14 - Task : 1003629
*            Enh : 713751
*            New arguments added for the calling routines.
*
* 19/08/14 - Task   : 1102406
*            Defect : 1082425
*            Systems fails to throw error if the Payment Frequency is greater is Term Frequency when the disbursement schedule is defined.
*
* 11/11/14 - 1165120
*            Ref: 1165125
*            Ignore charge while deciding on bills combined.
*
* 30/10/14 - Task 1153828
*            Defect 1130107
*            New simulation capture - advance mode validation done from the current interest condition record
*
*
* 14/11/14 - Task: 1169779
*            Defect 1161051
*            System raise an override when the arrangement maturity date falls on a holiday and START.DATE in REPAYMENT.SCHEDULE
*            is defined as R_MATURITY and Date convention given as BACKWARD
*
* 30/12/14 - Task : 1212179 / Defect : 1146895
*            System is allowing overlapping of payment schedule in AA Lending
*
* 01/10/14 - Task : 1129268
*            Def  : 1122559
*            To raise error message when the user try to schedule "CURRENT" and "DEPOSIT.REDEEM" payment type
*
* 27/03/15 - Task : 1250791
*            Enhancement : 1115547
*            New validations introduced for Accelerated payment types.
*
* 09/04/15 - Task    : 1312695
*            Defect  : 1301449
*            Remove the validation for Bills Combined based on source balance and payment indicator
*
* 21/04/15 - Task : 1323851
*            Ref : Defect 1323547
*            Initialize the variable START.DATE.
*
* 12/06/15 - Task : 1376102
*            Def  : 1341465
*            System will not throw any override when the same payment type and property with different start date
*
* 29/06/15 - Enhancement - 1277976
*            Task - 1300622
*            Call new API AA.PAYMENT.SCHEDULE.INTEREST.ROUTINE only at arrangement level.
*
* 22/07/15 - Enhancement - 1277985
*            Task - 1300704
*            PERCENTAGE type related validations introduced
*
* 08/06/15 - Task : 1321246
*            Enhancement : 1276870
*    		 Payment Holiday Definition.
*            To validate the fields HOL.PAYMENT.TYPE, HOL.START.DATE and HOL.NUM.PAYMENTS
*            Also, dedfault HOL.START.DATE to Effective Date in case it is NULL
*
* 27/11/15 - Task : 1546788
*            Defect : 1546604
*            PERCENTAGE is not allowed for MAINTAIN type
*
* 16/10/15 - Enhancement : 1427521
*            Task : 1461080
*    		 Restrict ONLINE.CAPITALISE when ISSUE.BILL is not set to "NO".
*            Restrict PAYMENT.METHOD is not set to "CAPITALISE" for any of the property (do not consider PERIODIC.CHARGES propery).
*
* 07/03/16 - Task : 1655308
*            Defect : 1639999
*            Validate the end date against resolved date instead of relative date
*
* 06/04/16 - Task : 1683566
*            Defect : 1682725
*            Updating validation after adding the TIER.NEGATIVE.RATE field
* 10/11/16 - Task : 1919904
*            Defect : 1911326
*            Principal schedule made due on wrong date.
*
* 08/12/16 - Task : 1948914
*            Defect : 1931466
*            APPLYPAYMENT activity accepts LENDING-CREDIT-ARRANGEMENT
*
* 09/12/16 - Task   : 1949677
*            Defect : 1944426
*            System throws error when future dated change product activity is performed.
*
* 24/04/17 - Task 2102553
*            Ref : Defect 1960220
*            Future dated amendments raise incorrect error messages
*
* 22/12/18 - Task:2472745
*            Defect:2464450
*            Unwanted IO on Interest accruals file for charge / account property.

*
* 17/03/2018 -Task  : 2508202
*            Defect : 2503894
*            Not able to Refund the deposit which created and redeemed on the same Day
*
* 27/01/19 - Task   : 2962556
*            Defect : 2961947
*            PROPERTY.CLASS variable not initialised properly
*
* 18/02/19 - Defect : 2988654
*            Task   : 2995364
*            Allow PAY method in PaymentSchedule for interest property for Lending arrangement
*            when the source type of the property is CREDIT.
*
* 29/04/19 - Task : 3095016
*            Defect : 3094870
*            System would not allow to define LINEAR or CONSTANT payment type to take over call contract
*
* 29/04/19 - Defect : 3101737
*            Task   : 3106141
*            System should validate correctly when there is charge schedule with num Payments setup
*
* 22/05/2019 - Task  : 3142745
*             Defect : 3136199
*             Error message should be raised when we define start date as last payment date
*
* 27/02/20 -  Task : 3611595
*             Def  : 3602489
*             If product A have constant payment type with resetting and Product B have Interest only payment type,
*             during change product Product B condition would be reset and calc amount field should be removed after resetting.
*
*29/06/20 - Task        :4098211
*            Enhancement :3376694
*            RFR related validations introduced for payment schedule
*
*21/10/21 -  Task   : 4622264
*            Defect : 4567168
*            System throws an error message "DUPLICATE PRINCIPALINT PROPERTY ON" while Periodic reset activity is triggerred*
*
*** </region>
*-----------------------------------------------------------------------------
*** <region name= INSERTS>
***

    $USING AA.PaymentSchedule
    $USING AA.TermAmount
    $USING AA.Framework
    $USING AA.Interest
    $USING AA.ProductFramework
    $USING AA.Account
    $USING AC.BalanceUpdates
    $USING EB.Template
    $USING EB.ErrorProcessing
    $USING EB.OverrideProcessing
    $USING EB.SystemTables
    $USING EB.DataAccess
    
*** </region>
*-----------------------------------------------------------------------------

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

    OUTSTANDING.AMOUNT = ""
*
    ALLOWED.PROPERTY.CLASS = "ACCOUNT":@VM:"CHARGE":@VM:"INTEREST":@VM:"PERIODIC.CHARGES"    ;* Valid payment property class
    LINEAR.PROPERTY.CLASS = "ACCOUNT"   ;* Valid linear property class
    VARIABLE.PROPERTY.CLASS = "INTEREST"          ;* Valid variable type property class
    CAPITALISE.PROPERTY.CLASS = "INTEREST":@VM:"CHARGE":@VM:"PERIODIC.CHARGES"    ;* These property classes can be capitalised
    ACCELERATE.PROPERTY.CLASS = "ACCOUNT":@VM:"INTEREST"     ;* Charge property is not allowed as part of Accelerate types

    TERM.AMOUNT.TERM = ""
    FLD.NO = ""

    DIFF.PAYMENT.METHOD = ""

    RET.ERROR = ""  ;* Return error message

* If current activity is NEW, then, get the Published payment schedule record from Cat file
* This will be used when defaulting Due frequency from Payment frequency when a new arrangement is entered
    PAYMENT.SCHEDULE.RECORD = ''
    IF AA.Framework.getProductArr() EQ AA.Framework.AaArrangement AND AA.Framework.getNewArrangement() THEN
        STAGE = AA.Framework.Publish
        PROPERTY.ID = AA.Framework.getPropertyId()
        DATE.TXN = AA.Framework.getPropEffDate()
        tmp.AA$PROPERTY.ID = AA.Framework.getPropertyId()
        AA.ProductFramework.GetPublishedRecord('PROPERTY', STAGE, tmp.AA$PROPERTY.ID, DATE.TXN, PAYMENT.SCHEDULE.RECORD, "")
        AA.Framework.setPropertyId(tmp.AA$PROPERTY.ID)
    END

* Intialise the Take Over Flag

    IF AA.Framework.getRArrangement()<AA.Framework.Arrangement.ArrOrigContractDate> THEN

        TAKEOVER.FLAG  = 1

    END ELSE

        TAKEOVER.FLAG  = ""

    END

    TARGET.CLASS = 'ACCOUNT'
    ARR.NO = AA.Framework.getArrId()
    GOSUB CHECK.SIMULATION.DETAILS
    IF SIM.MODE THEN
        ARR.NO<1,2> = 1
    END
    EFF.DATE = AA.Framework.getActivityEffDate()
    R.ACCOUNT = ""
    Y.ERR = ""
    AA.ProductFramework.GetPropertyRecord("", ARR.NO, "", EFF.DATE, "ACCOUNT", "", R.ACCOUNT, Y.ERR)
    IF NOT(Y.ERR) THEN
        DATE.CONVENTION = R.ACCOUNT<AA.Account.Account.AcDateConvention>
        DATE.ADJUSTMENT = R.ACCOUNT<AA.Account.Account.AcDateAdjustment>
        BUS.DAY.CENTRES = R.ACCOUNT<AA.Account.Account.AcBusDayCentres>
    END
    TERM.AMOUNT.PROPERTY = ''

    ACT.ACTIVITY = AA.Framework.getActivityId()<AA.Framework.ActActivity>

    ArrNoWithCp = ""

    INITIATION.TYPE=""
    INITIATION.TYPE=AA.Framework.getRArrangementActivity()<AA.Framework.ArrangementActivity.ArrActInitiationType,1>    ;*Get activity initiation type
    
    SPL.ACTIVITIES = 'RESET':@VM:'CHANGE.PRODUCT':@VM:'CHANGE.CONDITION':@VM:'CHANGE.VARIATION'
    RFR.PAYMENT.DATES = '' ;* Pass the full schedule payment dates to the RFR validation routine
    

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.ACTUAL.RELATIVE.DATE>
*** <desc>Get the Actual date  from given relative date for the field START.DATE and END.DATE </desc>
GET.ACTUAL.RELATIVE.DATE:

    ACTUAL.END.DATE = ""
    ACTUAL.START.DATE = ""

    START.DATE.COUNT.MV = DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate), @VM)
    CNT = ""
    FOR CNT = 1 TO START.DATE.COUNT.MV

        START.DATE.COUNT.SV = DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1, CNT>, @SM)

        FOR C.NT = 1 TO START.DATE.COUNT.SV

            IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1, CNT, C.NT> THEN
                DATE.FORMAT = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1, CNT, C.NT>
                RETURN.DATE = ""
                AA.Framework.GetRelativeDate(ARR.NO, DATE.FORMAT, "", "", "", "", "", RETURN.DATE, '')
                ACTUAL.START.DATE<1, CNT, C.NT> = RETURN.DATE
            END

        NEXT C.NT

    NEXT CNT

    END.DATE.COUNT.MV = DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsEndDate), @VM)

    FOR CNT = 1 TO END.DATE.COUNT.MV

        END.DATE.COUNT.SV = DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsEndDate)<1, CNT>, @SM)

        FOR C.NT = 1 TO END.DATE.COUNT.SV

            IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsEndDate)<1, CNT, C.NT> THEN
                DATE.FORMAT = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsEndDate)<1, CNT, C.NT>
                RETURN.DATE = ""
                AA.Framework.GetRelativeDate(ARR.NO, DATE.FORMAT, EFF.DATE, "", "", "", "", RETURN.DATE, '')
                ACTUAL.END.DATE<1, CNT, C.NT> = RETURN.DATE
            END

        NEXT C.NT

    NEXT CNT

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS.CROSSVAL>
PROCESS.CROSSVAL:
***
    GOSUB GET.PREVIOUS.PROP.RECORD
    IF EB.SystemTables.getMessage() EQ '' THEN     ;* Only during commit...
        BEGIN CASE
            CASE EB.SystemTables.getVFunction() EQ 'D'
            CASE EB.SystemTables.getVFunction() EQ 'R'
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
            GOSUB DESIGNER.DEFAULTS         ;* Ideally no defaults at the product level
        CASE AA.Framework.getProductArr() EQ AA.Framework.AaArrangement         ;* If its from the arrangement level
            GOSUB ARRANGEMENT.DEFAULTS      ;* Arrangement defaults
    END CASE
*
    GOSUB COMMON.CROSSVAL
*
    BEGIN CASE
        CASE AA.Framework.getProductArr() EQ AA.Framework.Product
            GOSUB DESIGNER.CROSSVAL         ;* Designer specific cross validations
        CASE AA.Framework.getProductArr() EQ AA.Framework.AaArrangement
            GOSUB ARRANGEMENT.CROSSVAL      ;* Arrangement specific cross validations
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.PREVIOUS.PROP.RECORD>
***
GET.PREVIOUS.PROP.RECORD:

    PREVIOUS.PROP.RECORD = ""
    PROPERTY = AA.Framework.getPropertyId()
    PROPERTY.DATE = AA.Framework.getPropEffDate()
    ARR.REF = AA.Framework.getArrId()
    IF SIM.MODE THEN
        ARR.REF<1,2> = 1
    END
    AA.ProductFramework.GetPropertyRecord("", ARR.REF, PROPERTY, PROPERTY.DATE, "", "",PREVIOUS.PROP.RECORD, REC.ERR)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= COMMON.CROSSVAL>
***
COMMON.CROSSVAL:


    GOSUB CHECK.DIRECTION     ;* Direction validations, Field not present now, may be used in future

    GOSUB CHECK.BASE.DATE     ;* Base date - Contract Start, Value Date, Approve Date, Drawdown Date or the actual date

    GOSUB CHECK.AMORT.TERM    ;* Term and Amortisation Term validations

    GOSUB CHECK.RESIDUAL.AMOUNT         ;* Residual amount validations

    GOSUB CHECK.BASE.DATE.KEY ;* Cycling of dates on previous or base date

    CHECK.CALC.TYPES = ""

    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsProperty)
    EB.Template.Dup()        ;* Duplicate and Null values in property not allowed

    GOSUB CHECK.PAYMENT.TYPE.VALIDATIONS          ;* Check Start Date ,End date , No of Payments , Actual Amt , etc

    GOSUB CHECK.RECALC        ;* Check recalculation frequency and recalc base date

    GOSUB CHECK.EVENT.RECALCULATE       ;* Event or "On change of" validations

    GOSUB CHECK.APPLY.PAYMENT ;* Validations for Apply Payment

    GOSUB VALIDATE.DISB.SCH

    GOSUB CHECK.DUPLICATE.PAYMENT.TYPE  ;* New duplicate payment type check introduced

    GOSUB VALIDATE.MINIMUM.PAYMENT.AMOUNT         ;* validation for Minimum Payment Amount

    GOSUB CHECK.ONLINE.CAPITALISE

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= DO.LINEAR.ACTUAL.PAYMENT.CHECK>
*** <desc>Crossval for Linear/Actual payment check</desc>
DO.LINEAR.ACTUAL.PAYMENT.CHECK:

    BEGIN CASE
        CASE SM.COUNT GT 1
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsProperty)
            EB.SystemTables.setEtext("AA.PS.MULT.PROP.NOT.ALLOWED.CALC.TYPE")
            EB.ErrorProcessing.StoreEndError()

        CASE R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> EQ "ACTUAL" AND NOT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage)<1,EB.SystemTables.getAv(),1>) AND PROPERTY.CLASSES EQ "ACCOUNT"
*        ACTUAL.AMT = R.NEW(AA.PS.ACTUAL.AMT)<1,AV>
*        CONVERT VM TO '' IN ACTUAL.AMT
*        IF NOT(ACTUAL.AMT) THEN
*            AF = AA.PS.PERCENTAGE
*            ETEXT = "AA.PS.EITHER.PERC.OR.ACTUAL.AMT.MAND"
*            CALL STORE.END.ERROR
*        END

        CASE EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)<1,EB.SystemTables.getAv()> EQ "CAPITALISE" AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage)<1,EB.SystemTables.getAv(),1>
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPercentage)
            EB.SystemTables.setEtext("AA.PS.PERC.NOT.ALLOWED.FOR.CAP")
            EB.ErrorProcessing.StoreEndError()

        CASE R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> EQ "ACTUAL" AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage)<1,EB.SystemTables.getAv(),1> AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)<1,EB.SystemTables.getAv(),1>
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPercentage)
            EB.SystemTables.setEtext("AA.PS.BOTH.PERC.AND.ACTUAL.NOT.ALLOWED")
            EB.ErrorProcessing.StoreEndError()


        CASE R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> EQ "ACTUAL" AND R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtType> EQ "CALCULATED" AND NOT(PROPERTY.CLASSES MATCHES "ACCOUNT":@VM:"INTEREST")
            BEGIN CASE
                CASE EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage)<1,EB.SystemTables.getAv(),1>
                    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPercentage)
                    EB.SystemTables.setEtext("AA.PS.PERCENTAGE.CALC.FOR.ACCT.PROP.ONLY")
                    EB.ErrorProcessing.StoreEndError()

                CASE NOT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)<1,EB.SystemTables.getAv(),1>) ;* should we need to throw error in this case ?

            END CASE

        CASE EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage)<1,EB.SystemTables.getAv(),1> AND (EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage)<1,EB.SystemTables.getAv(),1> GT 100 OR EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage)<1,EB.SystemTables.getAv(),1> LE 0)
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPercentage)
            EB.SystemTables.setEtext("AA.PS.PERCETAGE.RANGE.1.TO.100")
            EB.ErrorProcessing.StoreEndError()

        CASE EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)<1,EB.SystemTables.getAv()> EQ "MAINTAIN" AND PROPERTY.CLASSES NE "ACCOUNT"
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsProperty)
            EB.SystemTables.setEtext("AA.PS.MAINTAIN.METHOD.FOR.ACCT.PROP.ONLY")
            EB.ErrorProcessing.StoreEndError()

        CASE EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)<1,EB.SystemTables.getAv()> EQ "MAINTAIN" AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage)<1,EB.SystemTables.getAv(),1>
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPercentage)
            EB.SystemTables.setEtext("AA.PS.PERCENTAGE.INVALID.FOR.MAINTAIN")
            EB.ErrorProcessing.StoreEndError()

    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Check Direction>
*** <desc>Not used now</desc>
CHECK.DIRECTION:

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Base Date validation>
***
CHECK.BASE.DATE:

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Amortisation Term validation>
*** <desc>Check if amort term is less contract term</desc>
CHECK.AMORT.TERM:

    PAYMENT.TYPES = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
    PAYMENT.CALC.TYPES = ""

    AA.PaymentSchedule.GetCalcType(PAYMENT.TYPES, PAYMENT.CALC.TYPES, "", "")

** Amortisation term is only valid if CALC.TYPE is "CONSTANT", "LINEAR" , "PROGRESSIVE" or "OTHER"

    LOCATE "CONSTANT" IN PAYMENT.CALC.TYPES<1,1> SETTING CONST.POS ELSE
        CONST.POS = ""
    END

    LOCATE "PROGRESSIVE" IN PAYMENT.CALC.TYPES<1,1> SETTING PROGRESS.POS ELSE
        PROGRESS.POS = ""
    END

    LOCATE "LINEAR" IN PAYMENT.CALC.TYPES<1,1> SETTING LINEAR.POS ELSE
        LINEAR.POS = ""
    END

    LOCATE "OTHER" IN PAYMENT.CALC.TYPES<1,1> SETTING OTHER.POS ELSE
        OTHER.POS = ""
    END

    LOCATE "ACCELERATED" IN PAYMENT.CALC.TYPES<1,1> SETTING ACCELERATE.POS ELSE
        ACCELERATE.POS  = ""
    END

    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsAmortisationTerm)
    IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsAmortisationTerm) THEN
        IF CONST.POS OR LINEAR.POS OR OTHER.POS OR PROGRESS.POS OR ACCELERATE.POS ELSE
            EB.SystemTables.setEtext("AA.PS.AMORTISATION.TERM.NOT.ALLOWED")
            EB.ErrorProcessing.StoreEndError()
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Residual amount validations>
*** <desc>Check if residual amount is greater than contract</desc>
CHECK.RESIDUAL.AMOUNT:

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Base date key validations>
*** <desc>Should be null if date convention is "calendar"</desc>
CHECK.BASE.DATE.KEY:

**    AF = AA.PS.BASE.DATE.KEY
**    IF DATE.CONVENTION AND DATE.CONVENTION MATCHES "FORWARD":VM:"BACKWARD":VM:"FORWARD SAME MONTH" ELSE
**        IF R.NEW(AF) THEN
**            ETEXT = "AA.PS.NOT.ALLOWED.FOR.THIS.DATE.CON"
**            CALL STORE.END.ERROR
**        END
**    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Payment Type validations>
*** <desc>Check for Payment Type , Payment Method , Start Date ,End date , No of Payments , Actual Amt</desc>
CHECK.PAYMENT.TYPE.VALIDATIONS:

    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
    EB.Template.FtNullsChk()

    MV.COUNT = COUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType), @VM) + 1
    FOR AV.LOC = 1 TO MV.COUNT
        EB.SystemTables.setAv(AV.LOC)

        SM.COUNT = ''
        PAYMENT.TYPE = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)<1,EB.SystemTables.getAv()>
        BEGIN CASE
            CASE PAYMENT.TYPE AND TERM.AMOUNT.TERM AND NOT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)<1,EB.SystemTables.getAv()>) AND NOT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv()>) AND NOT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsEndDate)<1,EB.SystemTables.getAv()>)
                EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                EB.SystemTables.setEtext("AA.PS.ATLEAST.ONE.SCHEDULE.IS.MANDATORY")
                EB.ErrorProcessing.StoreEndError()

** Payment Type mandatory when frequency/date is specified
            CASE NOT(PAYMENT.TYPE) AND (EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)<1,EB.SystemTables.getAv()> OR EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)<1,EB.SystemTables.getAv()> OR EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv(),1> OR EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty)<1,EB.SystemTables.getAv(),1>)
                EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                EB.SystemTables.setEtext("AA.PS.PAYMENT.TYPE.MANDATORY")
                EB.ErrorProcessing.StoreEndError()

            CASE PAYMENT.TYPE MATCHES "CURRENT":@VM:"DEPOSIT.REDEEM"       ;* Should not allow the user to schedule CURRENT and DEPOSIT.REDEEM payment type
                EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                EB.SystemTables.setEtext("AA.PS.INVALID.REPAYMENT.TYPE")
                EB.ErrorProcessing.StoreEndError()

            CASE 1
                INPUT.CLASSES = ""
                GOSUB GET.PAYMENT.TYPE      ;*Read Payment Type record
                PROPERTIES = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty)<1,EB.SystemTables.getAv()>        ;* Get the property class
                CONVERT @SM TO @VM IN PROPERTIES        ;* AA.GET.PROOPERTY.CLASS understands only value markers
                PROPERTY.CLASSES = ""
                AA.ProductFramework.GetPropertyClass(PROPERTIES, PROPERTY.CLASSES)
                IF "ACCOUNT" MATCHES PROPERTY.CLASSES  AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsDeferPeriod)<1,EB.SystemTables.getAv()> THEN
                    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsDeferPeriod)
                    EB.SystemTables.setEtext("AA-DEF.NOT.ALLOWED.FOR.AC.PROP");*Defer period should not be defined to account property
                    EB.ErrorProcessing.StoreEndError()
                END
                IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsBillProduced)<1,EB.SystemTables.getAv()> AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsDeferPeriod)<1,EB.SystemTables.getAv()> THEN
                    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsBillProduced)
                    EB.SystemTables.setEtext("AA-BILL.PROD.NOT.ALLOWED.FOR.DEF")
                    EB.ErrorProcessing.StoreEndError()
                END

* For ADVANCE payment type, there should not be any bill produced or defer concept.

                IF R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtPaymentMode> EQ "ADVANCE" AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsBillProduced)<1,EB.SystemTables.getAv()> THEN
                    EB.SystemTables.setEtext("AA-BILL.PROD.NOT.ALLOWED.FOR.ADV.PAY.TYPE")
                    EB.ErrorProcessing.StoreEndError()
                END

                IF R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtPaymentMode> EQ "ADVANCE" AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsDeferPeriod)<1,EB.SystemTables.getAv()> THEN
                    EB.SystemTables.setEtext("AA-AA-DEF.NOT.ALLOWED.FOR.ADV.PAY.TYPE")
                    EB.ErrorProcessing.StoreEndError()
                END

                SM.COUNT = COUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty)<1,EB.SystemTables.getAv()>, @SM) + 1

                IF R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> MATCHES "LINEAR":@VM:"ACTUAL" THEN          ;* Multiple properties not allowed
                    GOSUB DO.LINEAR.ACTUAL.PAYMENT.CHECK
                END
        END CASE

        GOSUB CHECK.SIMILAR.PAYMENT.TYPES

        IF PAYMENT.TYPE THEN

            FOR AS.LOC = 1 TO SM.COUNT
                EB.SystemTables.setAs(AS.LOC)
                GOSUB CHECK.PROPERTY    ;* Property validations
                GOSUB CHECK.FREQUENCY   ;* Check Payment frequency and Due frequency
            NEXT AS.LOC

            GOSUB CHECK.PAYMENT.FREQUENCY

            GOSUB CHECK.PAYMENT.TYPE    ;* Validate payment type

            GOSUB CHECK.PAYMENT.METHOD  ;* Capitalise or Payment

            GOSUB CHECK.ISSUE.BILL      ;* Do not allow NO if Bill days is greater than Zero

            GOSUB CHECK.MANDATORY.PROPERTY

            SM.COUNT = COUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv()>, @SM) + 1
            FOR AS.LOC = 1 TO SM.COUNT
                EB.SystemTables.setAs(AS.LOC)
                IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsEndDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsNumPayments)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> THEN
                    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsEndDate)
                    EB.SystemTables.setEtext("AA.PS.END.DATE.AND.NUM.PAYMT.ALLOWED")
                    EB.ErrorProcessing.StoreEndError()
                END

                IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsNumPayments)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND NOT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)<1,EB.SystemTables.getAv()>) THEN
                    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)
                    EB.SystemTables.setEtext("AA.PS.MANDATORY.FOR.NUM.PAYMENTS")
                    EB.ErrorProcessing.StoreEndError()
                END

                IF R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> EQ "ACTUAL" AND R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtType> EQ "CALCULATED" AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> THEN
                    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)
                    EB.SystemTables.setEtext("AA.PS.NOT.VALID.FOR.PAYMENT.TYPE")
                    EB.ErrorProcessing.StoreEndError()
                END
                IF ACT.ACTIVITY MATCHES SPL.ACTIVITIES THEN ;* Check the calc type
                    GOSUB CHECK.FOR.CALC.PAYMENT.TYPES
                END
            NEXT AS.LOC

            GOSUB CHECK.BILLS ;* Validate Billing informations, Bil type, Bill produced and Bill finalised

        END

    NEXT AV.LOC

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Validate Disbursement bill type>
*** <desc>Do basic validations for disbursement type bills </desc>
VALIDATE.DISB.SCH:

    DISBURSEMENT.AMT = ''
    DISBURSEMENT.PER = ''
    SYSTEM.BILL.TYPE = ''
    ST.DATE.ARR = ''
    TOT.PERCENTAGE = 0
    TOT.DIS.AMT = 0
    GOSUB EXTRACT.DISBURSEMENT.TYPES    ;*Extract details for Disbursement type

* Raise an error message if percentage defined exceeds 100%
    IF DISBURSEMENT.PER AND TOT.PERCENTAGE GT 100 THEN
        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPercentage)
        EB.SystemTables.setEtext('AA.PS.TOT.PERCENT.EXCEEDS')
        EB.ErrorProcessing.StoreEndError()
    END

* Raise override message if percentage defined is less than 100
    IF DISBURSEMENT.PER AND TOT.PERCENTAGE LT 100 AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage)<1,LAST.MV.POS,1> NE '' THEN
        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPercentage)
        EB.SystemTables.setText("AA.PS.PERCETAGE.RANGE.1.TO.100")
        EB.OverrideProcessing.StoreOverride("")
    END

* Default the remaining percentage to last multivalue set if it is left blank

    IF DISBURSEMENT.PER AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage)<1,LAST.MV.POS,1> EQ '' THEN
        tmp=EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage); tmp<1,LAST.MV.POS,1>=100 - TOT.PERCENTAGE; EB.SystemTables.setRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage, tmp)
    END


RETURN
*** </region>
*------------------------------------------------------------------------------
*** <region name= Extract disbursement type details>
*** <desc>Extract disbursement type details </desc>
EXTRACT.DISBURSEMENT.TYPES:

    PT.CNT = COUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType), @VM) + 1
    FOR AV.LOC = 1 TO PT.CNT
        EB.SystemTables.setAv(AV.LOC)

        GOSUB GET.SYS.BILL.TYPE

        IF SYSTEM.BILL.TYPE EQ 'DISBURSEMENT' THEN

            IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)<1,EB.SystemTables.getAv()> EQ "DUE" THEN        ;* For DISBURSEMENT Bill type, don't allow DUE payment method
                EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)
                EB.SystemTables.setEtext("AA.PS.INVALID.PAY.METHOD.FOR.BILL.TYPE")
                EB.ErrorProcessing.StoreEndError()
            END

            IF DISBURSEMENT.AMT THEN    ;** If actual amount defined then multiple payment type are not allowed. Start date should be multivalued
                EB.SystemTables.setAf(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType))
                EB.SystemTables.setEtext('AA.PS.DUPLICATE')
                EB.ErrorProcessing.StoreEndError()
            END

            GOSUB CHECK.OTHER.DISBURSE.DETAILS    ;*Verify/Extract payment type wise details

        END
    NEXT AV.LOC

RETURN
*** </region>
*------------------------------------------------------------------------------
CHECK.OTHER.DISBURSE.DETAILS:

    BEGIN CASE
        CASE EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)<1,EB.SystemTables.getAv(),1>
            DISBURSEMENT.AMT =  1 ;* Actual amount defined
            SM.COUNT = COUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)<1,EB.SystemTables.getAv()>, @SM) + 1
            FOR AS.LOC = 1 TO SM.COUNT
                EB.SystemTables.setAs(AS.LOC)
                IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND NOT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsDueFreq)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>) THEN
                    TOT.DIS.AMT + = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>      ;* Skip for frequency definition
                END
                IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsNumPayments)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> THEN
                    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsNumPayments)
                    EB.SystemTables.setEtext('AA.PS.INP.NOT.ALLOWED.TYPE')
                    EB.ErrorProcessing.StoreEndError()
                END
            NEXT AS.LOC
        CASE EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage)<1,EB.SystemTables.getAv()>
            DISBURSEMENT.PER = 1  ;* Percentage definition
            TOT.PERCENTAGE + = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage)<1,EB.SystemTables.getAv(),1>

            IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)<1,EB.SystemTables.getAv()> THEN
                EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)
                EB.SystemTables.setEtext('AA.PS.INP.NOT.ALLOWED.TYPE')
                EB.ErrorProcessing.StoreEndError()
            END
            LAST.MV.POS = EB.SystemTables.getAv()
    END CASE

    SM.COUNT = COUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv()>, @SM) + 1
    FOR AS.LOC = 1 TO SM.COUNT
        EB.SystemTables.setAs(AS.LOC)
        IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> THEN
            ST.DATE = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>
            LOCATE ST.DATE IN ST.DATE.ARR SETTING X ELSE
                X = 0
            END
* Duplicate start date not allowed if payment type is multivalued.
            IF X THEN
                EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsStartDate)
                EB.SystemTables.setEtext('AA.PS.DUPLICATE')
                EB.ErrorProcessing.StoreEndError()
            END ELSE
                ST.DATE.ARR<-1> = ST.DATE
            END
        END
    NEXT AS.LOC

RETURN
*** </region>
*------------------------------------------------------------------------------

*** <region name= Validate Negative Interest Rates>
*** <desc>Check whether negative Interest defined as part of Annuity payment type </desc>
VALIDATE.NEGATIVE.INTEREST.RATES:

    IF PROPERTY.CLASS EQ "INTEREST" THEN
        INT.RECORD = ""       ;* Interest record
        tmp.AA$ACTIVITY.EFF.DATE = AA.Framework.getActivityEffDate()
        tmp.AA$ARR.ID = AA.Framework.getArrId()
        AA.ProductFramework.GetPropertyRecord("", tmp.AA$ARR.ID, PROPERTY, tmp.AA$ACTIVITY.EFF.DATE, "INTEREST", "", INT.RECORD, RET.ERROR)
        AA.Framework.setArrId(tmp.AA$ARR.ID)
        AA.Framework.setActivityEffDate(tmp.AA$ACTIVITY.EFF.DATE)
        CALC.TYPE   = R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType>
        AA.PaymentSchedule.ValidateNegativeRate(CALC.TYPE, INT.RECORD, RETURN.ERROR)
        GOSUB CHECK.NEGATIVE.PAYMENT.METHOD
    END

RETURN

*------------------------------------------------------------------------------
*** <region name= Check Negative Payment Method>
*** <desc> Check whether the loan without negative interest setup doesnt have the payment method set to "PAY" </desc>
CHECK.NEGATIVE.PAYMENT.METHOD:
    PRODUCT.LINE = AA.Framework.getRArrangement()<AA.Framework.Arrangement.ArrProductLine>  ;* get the product line
    
    ReturnErr = ""  ;* Returns error if any
    AA.Framework.GetSourceBalanceType(PROPERTY, "", "", SOURCE.BALANCE.TYPE, ReturnErr) ;* returns the source balance type of the property

** Raise error if Payment method is PAY for interest property for lending product line when the source type is not credit
    BEGIN CASE
        CASE CURRENT.PAYMENT.METHOD EQ "PAY" AND PRODUCT.LINE EQ "LENDING" AND SOURCE.BALANCE.TYPE NE "CREDIT"
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)
            EB.SystemTables.setEtext("AA.PS.PAY.MTD.PAY.NOT.ALWD.FOR.LENDING")
            EB.ErrorProcessing.StoreEndError()
    END CASE

RETURN

*** </region>
*------------------------------------------------------------------------------
*** <region name= Check Similar Payment Types>
*** <desc>Check the simliar payment types having the different payment methods</desc
CHECK.SIMILAR.PAYMENT.TYPES:

** If same payment type having the different payment methods then throw the error message
** Example
** Payment Type1 = Actual , Payment Method1 = Due
** Payment Type2 = Actual , Payment Method2 = Capitalise
** Raise the error in the above scenario

** Payment Type1 = Linear , Property1 = Account
** Payment Type2 = Linear , Property2 = Account
** Raise the override in the above scenario


    FOR PAY.TYPE = 1 TO MV.COUNT
        IF (EB.SystemTables.getAv() NE PAY.TYPE) AND NOT(DIFF.PAYMENT.METHOD) THEN
            IF (PAYMENT.TYPE EQ EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)<1,PAY.TYPE>) AND (EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)<1,EB.SystemTables.getAv()> NE EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)<1,PAY.TYPE>) THEN
                EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)
                EB.SystemTables.setEtext("AA.PS.DIFF.PAYMENT.MEHTODS.NOT.ALLOWED.SAME.PAYMENT.TYPE")
                DIFF.PAYMENT.METHOD = 1
                EB.ErrorProcessing.StoreEndError()
            END
        END

    NEXT PAY.TYPE

RETURN
*** </region>
*------------------------------------------------------------------------------

*** <region name= CHECK.PAYMENT.FREQUENCY>
*** <desc>Set frequency as mandatory when Term is inputed</desc>
CHECK.PAYMENT.FREQUENCY:
    IF NOT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)<1,EB.SystemTables.getAv()>) AND NOT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv()>) AND TERM.END.DATE THEN
        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)
        EB.SystemTables.setEtext("AA-AA.PS.PAYMENT.FREQUENCY.MANDATORY.WHEN.TERM.INPUT")
        EB.ErrorProcessing.StoreEndError()
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= Payment type validations>
*** <desc>Combination of Linear and Constant or Other is not allowed
***       Multiple dates not allowed for Constant and Linear</desc>
CHECK.PAYMENT.TYPE:

* Validate constant and pro-rata types

    IF R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> MATCHES "CONSTANT":@VM:"LINEAR":@VM:"PROGRESSIVE":@VM:"ACCELERATED":@VM:"PERCENTAGE" THEN

        IF DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv()>, @SM) GT 1 THEN
**            AF = AA.PS.START.DATE
**            ETEXT = "AA.PS.MULTI.NOT.ALLOWED.FOR.CALC.TYPE"
**            CALL STORE.END.ERROR
        END

        LOCATE R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> IN CHECK.CALC.TYPES<1,1> SETTING POS ELSE
            BEGIN CASE
                CASE R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> EQ "CONSTANT"
                    LOCATE "LINEAR" IN CHECK.CALC.TYPES SETTING APOS THEN
                        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                        EB.SystemTables.setEtext("AA.PS.CONSTANT.OR.LINEAR.ALLOWED")
                        EB.ErrorProcessing.StoreEndError()
                    END
                    LOCATE "PROGRESSIVE" IN CHECK.CALC.TYPES SETTING APOS THEN
                        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                        EB.SystemTables.setEtext("AA.PS.CONSTANT.OR.LINEAR.ALLOWED")
                        EB.ErrorProcessing.StoreEndError()
                    END
                    LOCATE "ACCELERATED" IN CHECK.CALC.TYPES SETTING APOS THEN
                        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                        EB.SystemTables.setEtext("AA.PS.CONSTANT.AND.ACCELERATED.NOT.ALLOWED")
                        EB.ErrorProcessing.StoreEndError()
                    END

                CASE R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> EQ "PERCENTAGE"
                    GOSUB PERCENTAGE.TYPE.VALIDATION

                CASE R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> EQ "LINEAR"
                    LOCATE "CONSTANT" IN CHECK.CALC.TYPES SETTING APOS THEN
                        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                        EB.SystemTables.setEtext("AA.PS.CONSTANT.OR.LINEAR.ALLOWED")
                        EB.ErrorProcessing.StoreEndError()
                    END
                    LOCATE "PROGRESSIVE" IN CHECK.CALC.TYPES SETTING APOS THEN
                        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                        EB.SystemTables.setEtext("AA.PS.CONSTANT.OR.LINEAR.ALLOWED")
                        EB.ErrorProcessing.StoreEndError()
                    END
                    LOCATE "ACCELERATED" IN CHECK.CALC.TYPES SETTING APOS THEN
                        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                        EB.SystemTables.setEtext("AA.PS.LINEAR.AND.ACCELERATED.NOT.ALLOWED")
                        EB.ErrorProcessing.StoreEndError()
                    END
                CASE R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> EQ "PROGRESSIVE"     ;* If progressive type then ANNUITY/LINEAR should not be allowed
                    LOCATE "LINEAR" IN CHECK.CALC.TYPES SETTING APOS THEN
                        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                        EB.SystemTables.setEtext("AA.PS.ANNUITY.AND.LINEAR.NOT.ALLOWED")
                        EB.ErrorProcessing.StoreEndError()
                    END
                    LOCATE "CONSTANT" IN CHECK.CALC.TYPES SETTING APOS THEN
                        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                        EB.SystemTables.setEtext("AA.PS.ANNUITY.AND.LINEAR.NOT.ALLOWED")
                        EB.ErrorProcessing.StoreEndError()
                    END
                    LOCATE "ACCELERATED" IN CHECK.CALC.TYPES SETTING APOS THEN
                        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                        EB.SystemTables.setEtext("AA.PS.PROGRESSIVE.AND.ACCELERATED.NOT.ALLOWED")
                        EB.ErrorProcessing.StoreEndError()
                    END
                    IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProgPayPerc)<1,EB.SystemTables.getAv()> EQ "" THEN        ;* If progressive type we should enter the value for PROG.PAY.PERC else it'll throw error
                        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsProgPayPerc)
                        EB.SystemTables.setEtext("AA.PS.PROG.PAY.PERC.MANDATORY")
                        EB.ErrorProcessing.StoreEndError()
                    END
                    IF DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv()>, @SM) GT 1 THEN          ;*For a progressive type the START.DATE and END.DATE should not be enter more than one sub value else it'll throw error
                        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsStartDate)
                        EB.SystemTables.setEtext("AA.PS.MULTI.NOT.ALLOWED.FOR.CALC.TYPE")
                        EB.ErrorProcessing.StoreEndError()
                    END
                    IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)<1,EB.SystemTables.getAv()> THEN       ;* For a progressive type the value for the field ACTUAL.AMT shouldn't be entered.
                        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)
                        EB.SystemTables.setEtext("AA.PS.ACTUAL.AMT.NOT.ALLOWED")
                        EB.ErrorProcessing.StoreEndError()
                    END
                CASE R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> EQ "ACCELERATED"
                    LOCATE "CONSTANT" IN CHECK.CALC.TYPES SETTING APOS THEN
                        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                        EB.SystemTables.setEtext("AA.PS.CONSTANT.AND.ACCELERATED.NOT.ALLOWED")
                        EB.ErrorProcessing.StoreEndError()
                    END
                    LOCATE "PROGRESSIVE" IN CHECK.CALC.TYPES SETTING APOS THEN
                        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                        EB.SystemTables.setEtext("AA.PS.PROGRESSIVE.AND.ACCELERATED.NOT.ALLOWED")
                        EB.ErrorProcessing.StoreEndError()
                    END
                    LOCATE "LINEAR" IN CHECK.CALC.TYPES SETTING APOS THEN
                        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                        EB.SystemTables.setEtext("AA.PS.LINEAR.AND.ACCELERATED.NOT.ALLOWED")
                        EB.ErrorProcessing.StoreEndError()
                    END
            END CASE
            INS R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> BEFORE CHECK.CALC.TYPES<1,POS>
        END
    END

    IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProgPayPerc)<1,EB.SystemTables.getAv()> THEN      ;* If the PROG.PAY.PERC contain a value for payment type except PROGRESSIVE it'll throw error
        IF R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> NE "PROGRESSIVE" THEN
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsProgPayPerc)
            EB.SystemTables.setEtext("AA.PS.CALC.TYPE.PROGRESSIVE")
            EB.ErrorProcessing.StoreEndError()
        END
    END

    IF R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> MATCHES "CONSTANT":@VM:"PROGRESSIVE":@VM:"ACCELERATED":@VM:"PERCENTAGE" THEN
        DUE.PROPERTIES = RAISE(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty)<1,EB.SystemTables.getAv()>)

        DUE.PROPERTIES.CLASS = ""
        AA.ProductFramework.GetPropertyClass(DUE.PROPERTIES, DUE.PROPERTIES.CLASS)

        LOCATE "INTEREST" IN DUE.PROPERTIES.CLASS<1,1> SETTING INT.POS THEN
            INT.PROPERTY = DUE.PROPERTIES<1,INT.POS>
        END

        LOCATE "ACCOUNT" IN DUE.PROPERTIES.CLASS<1,1> SETTING PRIN.POS THEN
            PRIN.PROPERTY = DUE.PROPERTIES<1,PRIN.POS>
        END

** For constant type both interest and term amount should be in the same frequency
** and this should be the same as the payemnt frequency
        IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsDueFreq)<1,EB.SystemTables.getAv(),PRIN.POS> AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsDueFreq)<1,EB.SystemTables.getAv(),INT.POS> THEN
            IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsDueFreq)<1,EB.SystemTables.getAv(),PRIN.POS> NE EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsDueFreq)<1,EB.SystemTables.getAv(),INT.POS> THEN
                EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsDueFreq)
                EB.SystemTables.setAs(PRIN.POS)
                EB.SystemTables.setEtext("AA.PS.INVALID.FREQ.CONSTANT.CALC")
                EB.ErrorProcessing.StoreEndError()
            END
        END

        IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)<1,EB.SystemTables.getAv()> AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsDueFreq)<1,EB.SystemTables.getAv(),PRIN.POS> THEN
            IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)<1,EB.SystemTables.getAv()> NE EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsDueFreq)<1,EB.SystemTables.getAv(),PRIN.POS> THEN
                EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)
                EB.SystemTables.setEtext("AA.PS.INVALID.FREQ.CONSTANT.CALC")
                EB.ErrorProcessing.StoreEndError()
            END
        END
    END

    IF R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> EQ "ACCELERATED" THEN
        PAYMENT.FREQUENCY = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)<1,EB.SystemTables.getAv()>
        ACCELERATE.FREQUENCY = FIELDS(PAYMENT.FREQUENCY, " ", 3, 1)

*** Payment frequency should be either weekly or Bi-weekly for Accelerate payment.

        IF ACCELERATE.FREQUENCY[2,1] EQ "1" OR ACCELERATE.FREQUENCY[2,1] EQ "2" ELSE
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)
            EB.SystemTables.setEtext("AA-PAY.FREQ.SHOULD.WEEKLY.OR.BI.WEEKLY")
            EB.ErrorProcessing.StoreEndError()
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Percentage type validation>
*** <desc>Percentage field mandatory/zero percent not allowed</desc>
PERCENTAGE.TYPE.VALIDATION:

    FOR PERCENT.CNT = 1 TO DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage)<1,EB.SystemTables.getAv()>,@SM)
        IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage)<1,EB.SystemTables.getAv(),PERCENT.CNT> EQ "" THEN          ;*For a percentage type the Percentage should be mandatory
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPercentage)
            EB.SystemTables.setAs(PERCENT.CNT)
            EB.SystemTables.setEtext("AA.PS.PERCENTAGE.MANDATORY")
            EB.ErrorProcessing.StoreEndError()
        END

        IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage)<1,EB.SystemTables.getAv(),PERCENT.CNT> EQ "0" THEN ;* 0% not allowed to input
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPercentage)
            EB.SystemTables.setAs(PERCENT.CNT)
            EB.SystemTables.setEtext("AA.PS.ZERO.PERCENTAGE.NOT.ALLOWED")
            EB.ErrorProcessing.StoreEndError()
        END

        IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)<1,EB.SystemTables.getAv(),PERCENT.CNT> THEN       ;* For a progressive type the value for the field ACTUAL.AMT shouldn't be entered.
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)
            EB.SystemTables.setAs(PERCENT.CNT)
            EB.SystemTables.setEtext("AA.PS.ACTUAL.AMT.NOT.ALLOWED.FOR.PERCENTAGE")
            EB.ErrorProcessing.StoreEndError()
        END
    NEXT PERCENT.CNT
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Payment method validations>
*** <desc>Check if property could be set to "capitalise"</desc>
CHECK.PAYMENT.METHOD:

    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)

    tmp.AF = EB.SystemTables.getAf()
    IF EB.SystemTables.getRNew(tmp.AF)<1,EB.SystemTables.getAv()> EQ "CAPITALISE" THEN
        EB.SystemTables.setAf(tmp.AF)
        CAP.COUNT = DCOUNT(CAPITALISE.PROPERTY.CLASS, @VM)
        CAP.I = 1
        CAP.OK = ""

        LOOP
        UNTIL CAP.OK OR CAP.I GT CAP.COUNT        ;* Until valid capitalisation classes are searched, or property found
            LOCATE CAPITALISE.PROPERTY.CLASS<1,CAP.I> IN PROPERTY.CLASSES<1,1> SETTING CAP.OK ELSE
                CAP.OK = ""
            END
            CAP.I += 1
        REPEAT

        IF NOT(CAP.OK) THEN
            EB.SystemTables.setEtext("AA.PS.CANT.CAPITALISE.PROPERTY")
            EB.ErrorProcessing.StoreEndError()
        END

* Should not allow capitalise for ADVANCE Interest.

        IF R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtPaymentMode> EQ "ADVANCE" THEN
            EB.SystemTables.setEtext("AA.PS.CANT.CAPITALISE.PROPERTY")
            EB.ErrorProcessing.StoreEndError()
        END

* If CALC.TYPE for the payment type is constant, say annuity payment types
* PAYMENT.METHOD cannot be set as CAPITALISE
        IF R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> MATCHES "CONSTANT":@VM:"PROGRESSIVE":@VM:"ACCELERATED":@VM:"PERCENTAGE" THEN
            EB.SystemTables.setEtext("AA.PS.CANT.CAPITALISE.PAYMENT.TYPE")
            EB.ErrorProcessing.StoreEndError()
        END
    END

** For MAINTAIN payment method, don't allow the 'calculated' payment types
    tmp.AF = EB.SystemTables.getAf()
    IF EB.SystemTables.getRNew(tmp.AF)<1,EB.SystemTables.getAv()> EQ "MAINTAIN" AND (R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtType> EQ "CALCULATED" OR R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtPaymentMode> EQ "ADVANCE") THEN
        EB.SystemTables.setAf(tmp.AF)
        EB.SystemTables.setEtext("AA.PS.INVALID.PAYMENT.TYPE.FOR.MAINTAIN")
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Check IssueBill>
*** <desc>Do not allow NO when BILL.PRODUCED is greater than zero </desc>
CHECK.ISSUE.BILL:

    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsIssueBill)

    tmp.AF = EB.SystemTables.getAf()
    IF EB.SystemTables.getRNew(tmp.AF)<1,EB.SystemTables.getAv()> = "NO" THEN
        EB.SystemTables.setAf(tmp.AF)
        IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsBillProduced)<1,EB.SystemTables.getAv()> GT 0 THEN
            EB.SystemTables.setEtext("AA.PS.BILL.PRODUCED.SHOULD.BE.ZERO")
            EB.ErrorProcessing.StoreEndError()
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Property validations>
*** <desc>Check for allowed, mandatory properties, etc</desc>
CHECK.PROPERTY:

    PROPERTY = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>

    IF PROPERTY THEN

        AA.Framework.LoadStaticData('F.AA.PROPERTY', PROPERTY, R.PROPERTY.REC, RET.ERROR)

        PROPERTY.CLASS = PROPERTY.CLASSES<1,EB.SystemTables.getAs()>
        LOCATE PROPERTY.CLASS IN INPUT.CLASSES<1,1> SETTING CLASS.POS ELSE
            INS PROPERTY.CLASS BEFORE INPUT.CLASSES<1,CLASS.POS>
        END

        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsProperty)
        IF PROPERTY.CLASS MATCHES ALLOWED.PROPERTY.CLASS ELSE         ;* Ensure this is allowed for payment
            EB.SystemTables.setEtext("AA.PS.INVALID.PROP.CLASS.FOR.PAYMENT")
            EB.ErrorProcessing.StoreEndError()
        END

        IF PROPERTY.CLASS NE "CHARGE" AND PROPERTY.CLASS NE "INTEREST" AND R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtExtendCycle> THEN      ;*Allow extended cycles only for charge & interest property
            EB.SystemTables.setEtext("AA.PS.EXTEND.CYCLES.NOT.ALLOWED")
            EB.ErrorProcessing.StoreEndError()
        END

        IF PROPERTY.CLASS EQ 'PERIODIC.CHARGES' AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)<1, EB.SystemTables.getAv(), EB.SystemTables.getAs()> THEN
            EB.SystemTables.setEtext("AA.PS.ACTUAL.AMT.NOT.ALLOWED.PER.CHARGE");* EB.ERROR to be released
            EB.ErrorProcessing.StoreEndError()
        END

        GOSUB CHECK.PROPERTY.PAYMENT.TYPE

        IF PROPERTY.CLASS EQ "INTEREST" THEN
            GOSUB CHECK.FOR.ACCRUAL.BY.BILLS      ;*Check accrual by bills setup for the property
        END

        IF AA.Framework.getProductArr() EQ AA.Framework.AaArrangement THEN

            ADVANCE.INT.FLAG = ""
            GOSUB CHECK.ADVANCE.PROPERTY

            IF ADVANCE.INT.FLAG THEN

                IF R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtPaymentMode> EQ "ADVANCE" ELSE
                    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                    EB.SystemTables.setEtext("AA.PS.INVALID.PAYMENT.TYPE.FOR.ADVANCE.PROPERTY")
                    EB.ErrorProcessing.StoreEndError()
                END

            END

            NEW.PROP = ""
            FIND PROPERTY IN EB.SystemTables.getROld(AA.PaymentSchedule.PaymentSchedule.PsProperty) SETTING PROP.POS ELSE
                NEW.PROP = PROPERTY
            END
            IF NEW.PROP THEN
                IF  AA.Framework.getAccountDetails()<AA.PaymentSchedule.AccountDetails.AdPaymentEndDate> AND AA.Framework.getAccountDetails()<AA.PaymentSchedule.AccountDetails.AdPaymentEndDate> LT AA.Framework.getActivityEffDate() THEN
                    IF PROPERTY.CLASS EQ "ACCOUNT" THEN
                        EB.SystemTables.setEtext("AA.PS.PROPERTY.NOT.ALLOW.AFT.MAT")
                        EB.ErrorProcessing.StoreEndError()
                    END ELSE
                        IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)<1,EB.SystemTables.getAv()> EQ "CAPITALISE" THEN
                            EB.SystemTables.setEtext("AA.PS.PROPERTY.NOT.ALLOW.WITH.CAP.MTHD.AFT.MAT")
                            EB.ErrorProcessing.StoreEndError()
                        END
                    END
                END
            END
        END
        IF PROPERTY.CLASS EQ "CHARGE" THEN
            GOSUB CHECK.PROPERTY.PAYMENT.METHOD
        END
    END ELSE
        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsProperty)
        EB.SystemTables.setEtext("AA.PS.MISSING.PROPERTY")
        EB.ErrorProcessing.StoreEndError()
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name=CHECK.PROPERTY.PAYMENT.METHOD>
*** <desc>Do property payment method</desc>
CHECK.PROPERTY.PAYMENT.METHOD:

    LOCATE "CREDIT" IN R.PROPERTY.REC<AA.ProductFramework.Property.PropPropertyType,1> SETTING PR.POS THEN
** If property is CREDIT then method should not be DUE.
        IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)<1,EB.SystemTables.getAv()> EQ "DUE" THEN
            EB.SystemTables.setEtext("AA.PS.CREDIT.PROPERTY.NOT.ALLOWED.FOR.METHOD")
            EB.ErrorProcessing.StoreEndError()
        END

    END ELSE
** Don't allow PAY method if property is not belongs to CREDIT type.
        IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)<1,EB.SystemTables.getAv()> EQ "PAY" THEN
            EB.SystemTables.setEtext("AA.ACT.PAY.ALLOWED.FOR.CREDIT.CHG.ONLY")
            EB.ErrorProcessing.StoreEndError()
        END
    END
RETURN

*** </region>
*-----------------------------------------------------------------------------

*** <region name=CHECK.PROPERTY.PAYMENT.TYPE>
*** <desc>Do property payment types validations</desc>
CHECK.PROPERTY.PAYMENT.TYPE:

    BEGIN CASE
        CASE R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> MATCHES "CONSTANT":@VM:"LINEAR":@VM:"ACCELERATED"  AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPercentage)
            EB.SystemTables.setEtext("AA.PS.PERCENT.INVALID.FOR.PAYMENT.TYPE")
            EB.ErrorProcessing.StoreEndError()

        CASE R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> EQ "LINEAR"
            IF PROPERTY.CLASS MATCHES LINEAR.PROPERTY.CLASS ELSE
                EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsProperty)
                EB.SystemTables.setEtext("AA.PS.INVALID.PROP.CLASS.FOR.CALC.TYPE")
                EB.ErrorProcessing.StoreEndError()
            END

        CASE R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> EQ "ACCELERATED"
            IF PROPERTY.CLASS MATCHES ACCELERATE.PROPERTY.CLASS ELSE
                EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsProperty)
                EB.SystemTables.setEtext("AA.PS.INVALID.PROP.CLASS.FOR.CALC.TYPE")
                EB.ErrorProcessing.StoreEndError()
            END

    END CASE

RETURN
*** </region>

*-----------------------------------------------------------------------------

CHECK.MANDATORY.PROPERTY:

    MAND.CLASS.COUNT = COUNT(R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtMandPropClass>, @VM) + 1

    FOR II = 1 TO MAND.CLASS.COUNT
        IF R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtMandPropClass,II> THEN
            LOCATE R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtMandPropClass,II> IN INPUT.CLASSES<1,1> SETTING POS ELSE  ;* Ensure all mandatory class properties are defined
                EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsProperty)
                EB.SystemTables.setEtext("AA.PS.MISS.MAND.PROP.FOR.CLASS":@FM:R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtMandPropClass,II>)
                EB.ErrorProcessing.StoreEndError()
            END
        END

        IF R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtPaymentMode> EQ "ADVANCE" AND AA.Framework.getProductArr() EQ AA.Framework.AaArrangement THEN
            ACTIVITY.ID = AA.Framework.getActivityId()<AA.Framework.ActActivity>
            BEGIN CASE
                CASE ACTIVITY.ID EQ "NEW"
                    ADVANCE.INT.FLAG = ""
                    ARR.NO = AA.Framework.getArrId()
                    IF SIM.MODE THEN
                        ARR.NO<1,2> = 1
                    END
                    tmp.AA$PROP.EFF.DATE = AA.Framework.getPropEffDate()
                    AA.ProductFramework.GetPropertyRecord("", ARR.NO, PROPERTY, tmp.AA$PROP.EFF.DATE, "INTEREST" ,"", R.INTEREST, RET.ERROR)
                    AA.Framework.setPropEffDate(tmp.AA$PROP.EFF.DATE)
                    IF R.INTEREST<AA.Interest.Interest.IntAccountingMode> NE "ADVANCE" THEN
                        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                        EB.SystemTables.setEtext("AA.PS.PAY.TYPE.VALID.FOR.ADVANCE.PROP")
                        EB.ErrorProcessing.StoreEndError()
                    END
                CASE 1
                    ADVANCE.INT.FLAG = ""
                    GOSUB CHECK.ADVANCE.PROPERTY
                    IF ADVANCE.INT.FLAG ELSE
                        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                        EB.SystemTables.setEtext("AA.PS.PAY.TYPE.VALID.FOR.ADVANCE.PROP")
                        EB.ErrorProcessing.StoreEndError()
                    END
            END CASE
        END
    NEXT II

RETURN
*** </region>
*-----------------------------------------------------------------------------

CHECK.ADVANCE.PROPERTY:

    ADV.PROP.CLASS=PROPERTY.CLASS
    IF NOT(PROPERTY.CLASS) THEN ;*If property class is null, fetch the property class
        AA.ProductFramework.GetPropertyClass(PROPERTY, ADV.PROP.CLASS) ;*Get property class for the property
    END
    IF ADV.PROP.CLASS EQ "INTEREST" THEN ;*CHECK.ADVANCE.INTEREST should be called only for INTEREST property class
        ARR.REF = AA.Framework.getArrId()
        AA.Interest.CheckAdvanceInterest(ARR.REF, PROPERTY, ADVANCE.INT.FLAG)
    END
RETURN
*-----------------------------------------------------------------------------
*** <region name= Payment and due frequency validations>
***
CHECK.FREQUENCY:

* Default the Due frequency from payment schedule

    IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsDueFreq)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> NE EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)<1,EB.SystemTables.getAv()> THEN
        tmp.AV = EB.SystemTables.getAv()
        tmp.AS = EB.SystemTables.getAs()
        tmp=EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsDueFreq); tmp<1,tmp.AV,tmp.AS>=EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)<1,tmp.AV>; EB.SystemTables.setRNew(AA.PaymentSchedule.PaymentSchedule.PsDueFreq, tmp)
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Check Date Changed>
*** <desc> </desc>
START.DATE.VALIDATIONS:

    FLD.NO = AA.PaymentSchedule.PaymentSchedule.PsStartDate
    IF NOT(CONTRACT.TYPE = "CALL" AND AA.Framework.getRArrangement()<AA.Framework.Arrangement.ArrProductLine> = "DEPOSITS") THEN      ;* For call deposit contract type DATE.CHANGED should not be set
        GOSUB CHECK.DATE.CHANGED
    END

    IF DATE.CHANGED THEN
        GOSUB CHECK.START.DATE          ;* Validate start date since date is changed

        IF MATURITY.DATE AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> THEN
            IF ACTUAL.START.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> GT MATURITY.DATE THEN
                EB.SystemTables.setText("AA.START.DATE.GT.TERM.END.DATE")
                EB.OverrideProcessing.StoreOverride("")
            END
        END

    END
    PREVIOUS.START.DATE = ACTUAL.START.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Check Date Changed>
*** <desc> </desc>
END.DATE.VALIDATIONS:

    FLD.NO = AA.PaymentSchedule.PaymentSchedule.PsEndDate
    IF NOT(CONTRACT.TYPE = "CALL" AND AA.Framework.getRArrangement()<AA.Framework.Arrangement.ArrProductLine> = "DEPOSITS") THEN      ;* For call deposit contract type DATE.CHANGED should not be set
        GOSUB CHECK.DATE.CHANGED
    END

    IF DATE.CHANGED THEN
        GOSUB CHECK.END.DATE  ;* Validate end date since date is changed

        IF MATURITY.DATE AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsEndDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> THEN
            IF ACTUAL.END.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> GT MATURITY.DATE THEN
                EB.SystemTables.setText("AA.FINAL.END.DATE.GT.TERM.END.DATE")
                EB.OverrideProcessing.StoreOverride("")
            END
        END

    END

    VALUE.DATE = AA.Framework.getRArrangement()<AA.Framework.Arrangement.ArrStartDate>
    EFFECT.DATE = AA.Framework.getActivityEffDate()
    MATURITY.DATE = AA.Framework.getAccountDetails()<AA.PaymentSchedule.AccountDetails.AdMaturityDate>

*Not able to Refund the deposit which created and redeemed on the same Day
*Validations should be done only for user activity
    IF EFFECT.DATE EQ VALUE.DATE AND ACTUAL.END.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> EQ VALUE.DATE AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)<1,EB.SystemTables.getAv()> AND  ACTUAL.END.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> EQ MATURITY.DATE AND INITIATION.TYPE EQ "USER" THEN
        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsEndDate)
        EB.SystemTables.setEtext("AA.PS.ONLY.START.DATE.ALLOWED")
        EB.ErrorProcessing.StoreEndError()
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Check Date Changed>
*** <desc> </desc>
CHECK.DATE.CHANGED:

    DATE.CHANGED = ''

    IF EB.SystemTables.getRNew(FLD.NO)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> NE EB.SystemTables.getRNewLast(FLD.NO)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND EB.SystemTables.getRNewLast(FLD.NO)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> THEN
        DATE.CHANGED = 1
    END

    IF EB.SystemTables.getRNew(FLD.NO)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> NE PREVIOUS.PROP.RECORD<FLD.NO, EB.SystemTables.getAv(), EB.SystemTables.getAs()> THEN
        DATE.CHANGED = 1
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Start date validations>
*** <desc>Check for ascending order, validate against base date, etc</desc>
CHECK.START.DATE:

    IF NOT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>) AND NOT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsEndDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>) THEN ;* Start date cannot be less than end date
        IF NOT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)<1,EB.SystemTables.getAv()>) THEN
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)
            EB.SystemTables.setEtext("AA.PS.PAYMENT.FREQUENCY.MANDATORY")
            EB.ErrorProcessing.StoreEndError()
        END
    END

    IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND EFF.DATE THEN   ;* Start date cannot be less than id date
        IF ACTUAL.START.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND ACTUAL.START.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> LT EFF.DATE THEN
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsStartDate)
            EB.SystemTables.setEtext("AA.PS.CANNOT.BE.LESS.THAN.REC.DATE")
            EB.ErrorProcessing.StoreEndError()
        END
    END

    IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND PREVIOUS.END.DATE AND EB.SystemTables.getAs() GT 1 THEN  ;* Start date cannot be less than previous end date
        IF ACTUAL.START.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND ACTUAL.START.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> LE PREVIOUS.END.DATE THEN
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsStartDate)
            EB.SystemTables.setEtext("AA.PS.CANT.BE.LT.PREVIOUS.END.DATE")
            EB.ErrorProcessing.StoreEndError()
        END
    END

    IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND PREVIOUS.START.DATE AND EB.SystemTables.getAs() GT 1 THEN          ;* Start date cannot be less than previous start date
        IF ACTUAL.START.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND ACTUAL.START.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> LE PREVIOUS.START.DATE THEN
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsStartDate)
            EB.SystemTables.setEtext("AA.PS.CANT.BE.LT.PREVIOUS.ST.DATE")
            EB.ErrorProcessing.StoreEndError()
        END
    END

** Ideally these should under arrangement validations, but the looping has to be done again
**
    IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND AA.Framework.getRArrangement()<AA.Framework.Arrangement.ArrStartDate> THEN
        IF ACTUAL.START.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND ACTUAL.START.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> LT AA.Framework.getRArrangement()<AA.Framework.Arrangement.ArrStartDate> THEN
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsStartDate)
            EB.SystemTables.setEtext("AA.PS.CANT.BE.LESS.THAN.ARR.START.DATE")
            EB.ErrorProcessing.StoreEndError()
        END
    END

** System should not allow to schedule other than "INTEREST" property.
    IF PROP.CLASS MATCHES "INTEREST":@VM:"CHARGE" AND SM.COUNT EQ "1" ELSE
        IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND MATURITY.DATE THEN
            IF ACTUAL.START.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND ACTUAL.START.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> GT MATURITY.DATE THEN
                EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsStartDate)
                EB.SystemTables.setEtext("AA.PS.SCHED.DATE.GT.TERM.END.DATE":@FM:EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>:@VM:TERM.END.DATE)
                EB.ErrorProcessing.StoreEndError()
            END
        END

    END

** Should not allow to define the start date on scheduled date. Since we may get the wrong amount in bill during repayment
    START.DATE.FORMAT = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>    ;* Get the Startdate defined in Payment schedule condition
    AA.Framework.GetRelativeDate(ARRANGEMENT.ID, START.DATE.FORMAT, "", "", "", "", "",PAYMENT.START.DATE, "")    ;* Returns the date based on date format we are passing
    IF (PAYMENT.START.DATE AND LAST.PAYMENT.DATE) AND (PAYMENT.START.DATE EQ LAST.PAYMENT.DATE) THEN             ;* Throw the error message when Last payment date and Start date is same for the payment type
        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsStartDate)
        EB.SystemTables.setEtext("AA-LAST.PAY.DATE.AND.START.DATE.NOT.SAME")
        EB.ErrorProcessing.StoreEndError()
    END

    PREVIOUS.START.DATE = ACTUAL.START.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= End date validations>
*** <desc>Check against start date, etc</desc>
CHECK.END.DATE:

    IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsEndDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> THEN
        IF ACTUAL.START.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND ACTUAL.END.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND ACTUAL.END.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> LT ACTUAL.START.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> THEN
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsEndDate)
            EB.SystemTables.setEtext("AA.PS.END.DATE.LT.START.DATE")
            EB.ErrorProcessing.StoreEndError()
        END
    END

    IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsEndDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND NOT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)<1,EB.SystemTables.getAv()>) THEN
        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsEndDate)
        EB.SystemTables.setEtext("AA.PS.ONLY.ALLOWED.WITH.PAYMENT.FREQ")
        EB.ErrorProcessing.StoreEndError()
    END

    PREVIOUS.END.DATE = ACTUAL.END.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Num payments validations>
*** <desc>Ensure frequency is defined, validate against end date</desc>
CHECK.NUM.PAYMENTS:

    IF DATE.CONVENTION THEN
        tmp.ETEXT = EB.SystemTables.getEtext()
        IF NOT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsEndDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>) AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsNumPayments)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND NOT(tmp.ETEXT) THEN

            EB.SystemTables.setEtext(tmp.ETEXT)
            BASE.DATE = ACTUAL.START.DATE<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>
            TERM = ""
            FREQUENCY = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)<1,EB.SystemTables.getAv()>
            NUM.PAYMENTS = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsNumPayments)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>


** If any schedule is crossed get the current number of days by using last payment date.
** If my last payment date is less than start date means i have crossed one schedule with current period.
** In that case we needs to get the number of payment by reduced processed payments.
      
            CURRENT.PROPERTY = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>
            IF NOT(AA.Framework.getAccountDetails()) THEN ;* Already loaded in common, use it
                R.ACCOUNT.DETAILS = ""
                AA.PaymentSchedule.ProcessAccountDetails(ARRANGEMENT.ID, "INITIALISE", "", R.ACCOUNT.DETAILS, RET.ERROR)   ;* Just load the record
            END

            LOCATE PAYMENT.TYPE:'-':CURRENT.PROPERTY IN R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdScheduleType,1> SETTING SCH.POS THEN
                AD.NUM.PAYMENTS = R.ACCOUNT.DETAILS<AA.PaymentSchedule.AccountDetails.AdNumPayments,SCH.POS> ;* Get processed number of payments from account details!!
            END
            IF BASE.DATE GE LAST.PAYMENT.DATE THEN ;* Means we are not in the current period?!!
                IF NUM.PAYMENTS AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> THEN
                    NUM.PAYMENTS -= 1       ;* Reduce the number of payments when start date is defined
                END
                NUM.PAYMENTS = NUM.PAYMENTS - NUM.PAST.PAYMENTS
                NUM.PAST.PAYMENTS = NUM.PAYMENTS + 1 ;* This should be useful from the next multivalue set!!
            END ELSE
                NUM.PAST.PAYMENTS = NUM.PAYMENTS
                NUM.PAYMENTS = NUM.PAYMENTS - AD.NUM.PAYMENTS
            END
            GOSUB GET.END.DATE

            PREVIOUS.END.DATE = RETURN.END.DATE

** System should not allow to schedule other than "INTEREST" property.
            IF PROP.CLASS MATCHES "INTEREST":@VM:"CHARGE" AND SM.COUNT EQ "1" ELSE
                IF MATURITY.DATE AND PREVIOUS.END.DATE GT MATURITY.DATE THEN
                    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsNumPayments)
                    EB.SystemTables.setEtext("AA.PS.SCHED.DATE.GT.TERM.END.DATE":@FM:PREVIOUS.END.DATE:@VM:TERM.END.DATE)
                    EB.ErrorProcessing.StoreEndError()
                END
            END
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get end date>
*** <desc>Derive end dates for Amortisation term or number of payments</desc>
GET.END.DATE:

    RETURN.END.DATE = ""
**  BASE.DATE.KEY = R.NEW(AA.PS.BASE.DATE.KEY)

    IF NOT(BASE.DATE) THEN
        BASE.DATE = ""
        BASE.DATE  = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsBaseDate)
    END

    IF BASE.DATE THEN
        AA.TermAmount.GetTermEndDate(TERM, FREQUENCY, NUM.PAYMENTS, DATE.CONVENTION, DATE.ADJUSTMENT, "", BUS.DAY.CENTRES, BASE.DATE, RETURN.END.DATE, "")
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Payment amount validations>
*** <desc>Ensure amount is defined for manual payment type</desc>
CHECK.ACTUAL.AMT:

    IF R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> EQ "ACTUAL" AND (R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtType> EQ "MANUAL") AND (EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> EQ '') THEN
        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)
        EB.SystemTables.setEtext("AA.PS.MANDATORY.FOR.CALC.TYPE")
        EB.ErrorProcessing.StoreEndError()
    END

** Actual amoutn will be allowed only in 1st sub value alone. if user inputted actual amount in mutiple sub values
** then raise error message

    IF R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> EQ "ACCELERATED" THEN
        IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> AND EB.SystemTables.getAs() GE 2 THEN
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)
            EB.SystemTables.setEtext("AA.PS.ACTUAL.AMT.ALLOWD.ONLY.IN.1ST.POSITION")
            EB.ErrorProcessing.StoreEndError()
        END
    END

** Clear calculated values if payment related fields are changed

    RECALCULATION.REQD = ""
    BEGIN CASE
        CASE (EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)<1,EB.SystemTables.getAv()> NE PREVIOUS.PROP.RECORD<AA.PaymentSchedule.PaymentSchedule.PsPaymentType,EB.SystemTables.getAv()>) OR (EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)<1,EB.SystemTables.getAv()> NE EB.SystemTables.getRNewLast(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)<1,EB.SystemTables.getAv()>)
            RECALCULATION.REQD = "1"
        CASE (EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)<1,EB.SystemTables.getAv()> NE PREVIOUS.PROP.RECORD<AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq,EB.SystemTables.getAv()>) OR (EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)<1,EB.SystemTables.getAv()> NE EB.SystemTables.getRNewLast(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)<1,EB.SystemTables.getAv()>)
            RECALCULATION.REQD = "1"
        CASE (EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> NE PREVIOUS.PROP.RECORD<AA.PaymentSchedule.PaymentSchedule.PsProperty,EB.SystemTables.getAv(),EB.SystemTables.getAs()>) OR (EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> NE EB.SystemTables.getRNewLast(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>)
            RECALCULATION.REQD = "1"
        CASE (EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsDueFreq)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> NE PREVIOUS.PROP.RECORD<AA.PaymentSchedule.PaymentSchedule.PsPaymentType,EB.SystemTables.getAv(),EB.SystemTables.getAs()>) OR (EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> NE EB.SystemTables.getRNewLast(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>)
            RECALCULATION.REQD = "1"
        CASE (EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> NE PREVIOUS.PROP.RECORD<AA.PaymentSchedule.PaymentSchedule.PsStartDate,EB.SystemTables.getAv(),EB.SystemTables.getAs()>) OR (EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> NE EB.SystemTables.getRNewLast(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>)
            RECALCULATION.REQD = "1"
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Bill validations>
***
CHECK.BILLS:


    IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsBillType)<1,EB.SystemTables.getAv()> EQ "" AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)<1,EB.SystemTables.getAv()> THEN
        IF AA.Framework.getProductArr() EQ AA.Framework.AaArrangement THEN  ;* Only at arrangement level, ideally should be under Arrangement defaults
            tmp.AV = EB.SystemTables.getAv()
            tmp=EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsBillType); tmp<1,tmp.AV>="PAYMENT"; EB.SystemTables.setRNew(AA.PaymentSchedule.PaymentSchedule.PsBillType, tmp)
        END
    END ELSE
        GOSUB CHECK.BILL.TYPE
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= GET.SYS.BILL.TYPE>
*** <desc>Get system bill type </desc>
GET.SYS.BILL.TYPE:

    BILL.TYPE = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsBillType)<1,EB.SystemTables.getAv()>

    SYSTEM.BILL.TYPE = ""
    AA.PaymentSchedule.GetSysBillType(BILL.TYPE, SYSTEM.BILL.TYPE, RET.ERROR)

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= CHECK.BILL.TYPE>
*** <desc>Validations for bill type </desc>
CHECK.BILL.TYPE:

** Do not allow BillTypes other than EXPECTED or PAYMENT
    GOSUB GET.SYS.BILL.TYPE

    IF SYSTEM.BILL.TYPE MATCHES "PAYMENT":@VM:"EXPECTED":@VM:"DISBURSEMENT" ELSE
        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsBillType)
        EB.SystemTables.setEtext("AA.BM.INVALID.BILL.TYPE")
        EB.ErrorProcessing.StoreEndError()
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= CHECK BILLS COMBINED>
*** <desc>Validations for bills combined </desc>
CHECK.BILLS.COMBINED:

** Default Bills combined option
    IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsBillsCombined) EQ "" AND DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType), @VM) GT 1 THEN        ;* Default value
        IF NOT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsBillsCombined)) THEN
            EB.SystemTables.setRNew(AA.PaymentSchedule.PaymentSchedule.PsBillsCombined, "YES")
        END
    END


RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Recalc validations>
***
CHECK.RECALC:


RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Event related validations>
***
CHECK.EVENT.RECALCULATE:

    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsOnActivity)
    EB.Template.Dup()

    MV.COUNT = COUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsOnActivity), @VM) + 1

    FOR AV.LOC = 1 TO MV.COUNT
        EB.SystemTables.setAv(AV.LOC)
        IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsOnActivity)<1,EB.SystemTables.getAv()> EQ "" AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsRecalculate)<1,EB.SystemTables.getAv()> THEN
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsOnActivity)
            EB.SystemTables.setEtext("AA.PS.CANNOT.BE.NULL")
            EB.ErrorProcessing.StoreEndError()
        END

        IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsRecalculate)<1,EB.SystemTables.getAv()> EQ "" AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsOnActivity)<1,EB.SystemTables.getAv()> THEN
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsRecalculate)
            EB.SystemTables.setEtext("AA.PS.CANNOT.BE.NULL")
            EB.ErrorProcessing.StoreEndError()
        END

    NEXT AV.LOC

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Apply Payment>
*** <desc>Validate Apply Payment</desc>
CHECK.APPLY.PAYMENT:

** Ensure Activity class is set to Apply Payment

    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsApplyPayment)

    tmp.AF = EB.SystemTables.getAf()
    IF EB.SystemTables.getRNew(tmp.AF) THEN
        EB.SystemTables.setAf(tmp.AF)
        ACTIVITY.ID = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsApplyPayment)
        RET.ERROR = ''
        tmp.AF = EB.SystemTables.getAf()
        AA.Framework.ValidateAllowedActivity(ACTIVITY.ID,"PAYMENT.SCHEDULE",tmp.AF,AA.ProductFramework.ActivityClass.AccUsedPropclass,AA.ProductFramework.ActivityClass.AccUsedField,RET.ERROR)
        EB.SystemTables.setAf(tmp.AF)
        IF RET.ERROR THEN
            EB.SystemTables.setEtext(RET.ERROR)
            RET.ERROR = ""
            EB.ErrorProcessing.StoreEndError()
        END
    END


RETURN
*** </region>
*-----------------------------------------------------------------------------


*** <region name= DESIGNER DEFAULTS>
***
DESIGNER.DEFAULTS:

    TERM.END.DATE  = ""

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= DESIGNER CROSSVAL>
***
DESIGNER.CROSSVAL:


RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= ARRANGEMENT DEFAULTS>
***
ARRANGEMENT.DEFAULTS:

** Base date key
**    AF = AA.PS.BASE.DATE.KEY
**    IF DATE.CONVENTION AND DATE.CONVENTION MATCHES "CALENDAR" ELSE
**        IF R.NEW(AF) EQ "" THEN
**            R.NEW(AF) = "BASE"
**        END
**    END

** Payment Method
    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)
    tmp.AF = EB.SystemTables.getAf()
    IF EB.SystemTables.getRNew(tmp.AF) EQ "" THEN
        EB.SystemTables.setAf(tmp.AF)
        EB.SystemTables.setRNew(EB.SystemTables.getAf(), "DUE")
    END

    IF DATE.CONVENTION THEN
        GOSUB GET.TERM.END.DATE         ;* Get maturity date based on TERM
    END

    IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsHolPaymentType) NE '' THEN
        GOSUB DEFAULT.HOLIDAY.START.DATE          ;*To default Holiday Start Date
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Get maturity date>
*** <desc>Get Term end date</desc>
GET.TERM.END.DATE:

    TERM.END.DATE = ""

** Get Term Amount property class record

    PROPERTY.CLASS = "TERM.AMOUNT"
    R.TERM.AMOUNT = ""

    ARR.NO = AA.Framework.getArrId()        ;* Common variables from AA

    TARGET.CLASS = 'TERM.AMOUNT'
    GOSUB CHECK.SIMULATION.DETAILS

    IF SIM.MODE THEN
        ARR.NO<1,2> = 1       ;* Get property record from sim file
    END

    EFF.DATE = AA.Framework.getPropEffDate()

    AA.ProductFramework.GetPropertyRecord('', ARR.NO, '', EFF.DATE, PROPERTY.CLASS, '', R.TERM.AMOUNT, REC.ERR)         ;* Get the term amount record
    TERM.AMOUNT.TERM = R.TERM.AMOUNT<AA.TermAmount.TermAmount.AmtTerm> ;* Arrangement contract term

    IF TERM.AMOUNT.TERM THEN
        TERM.FREQ.TYPE = TERM.AMOUNT.TERM[LEN(TERM.AMOUNT.TERM),1]
        GOSUB CHECK.MATURITY.DATE
    END

RETURN
*-----------------------------------------------------------------------------

*** <region name= Check simulation details>
*** <desc>Check where to look for target record</desc>
CHECK.SIMULATION.DETAILS:

    SIM.MODE = ''

    IF EB.SystemTables.getApplication()[1,6] = 'AA.SIM' THEN

        ARR.NO = AA.Framework.getArrId()    ;* Common variables from AA
        ARR.REC = '' ; RET.ERR = ''
        ARR.REC = AA.Framework.Arrangement.Read(ARR.NO, RET.ERR)
* Before incorporation : CALL F.READ("F.AA.ARRANGEMENT", ARR.NO, ARR.REC, '', RET.ERR)

        IF NOT(RET.ERR) THEN
            AA.SIM.LIVE.CAPTURE = '1'   ;* Its a simulation capture for an existing live arrangement
        END ELSE
            AA.SIM.LIVE.CAPTURE = ''
        END

        IF AA.SIM.LIVE.CAPTURE THEN
            CURR.ACTIVITY = AA.Framework.getCurrActivity()
            TARGET.PROPERTY = ''
            USER.INPUT = ''

            AA.Framework.CheckActivityClass(CURR.ACTIVITY, TARGET.PROPERTY, TARGET.CLASS, USER.INPUT)

            IF USER.INPUT THEN          ;* If that Target property class has been input as part of this arrangement, pick it from SIM, else assume ARR
                SIM.MODE = 1
            END
        END ELSE
            SIM.MODE = 1      ;* In Simulation mode and not live. Should be a NEW capture. All details are in SIM
        END
    END

RETURN

*** </region>
*-----------------------------------------------------------------------------

CHECK.MATURITY.DATE:

    BASE.DATE = ""  ;* Would be set in GET.END.DATE

    FREQUENCY = ""
    NUM.PAYMENTS = ""

    TERM = TERM.AMOUNT.TERM
    GOSUB GET.END.DATE
    TERM.END.DATE = RETURN.END.DATE

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= ARRANGEMENT CROSS VAL>
***
ARRANGEMENT.CROSSVAL:

*Product line specific

    GOSUB GET.ACTUAL.RELATIVE.DATE      ;* Get the Actual date  from given relative date for the field START.DATE and END.DATE

    CONTRACT.TYPE = ""

    AA.TermAmount.DetermineContractType(ARR.REF, EFF.DATE, "", R.TERM.AMOUNT, "", "", "", CONTRACT.TYPE, RET.ERROR)

    AA.PaymentSchedule.PaymentScheduleValidateProductline(AA.Framework.getRArrangement()<AA.Framework.Arrangement.ArrProductLine>)

** Base Date

    GOSUB CHECK.ARR.BASE.DATE
** Residual Amount

    GOSUB CHECK.ARR.RESIDUAL.AMOUNT

** Recalc on actvity

    GOSUB CHECK.ARR.EVENT.RECALCULATE
** check Payment Type

    tmp.aaSimRef = AA.Framework.getAasimref()
    IF NOT(SIM.MODE) AND NOT(tmp.aaSimRef) THEN
        AA.Framework.setAasimref(tmp.aaSimRef)
        GOSUB CHECK.ARR.PAYMENT.TYPE
    END

    COUNT.TYPE = DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType), @VM)
    COUNT.DATE = DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsEndDate)<1,COUNT.TYPE>, @SM)



** For takeover (from legacy systems) arrangements which are matured already, Amortisation term should be null
    IF NOT(TERM.AMOUNT.TERM) AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsAmortisationTerm) AND TAKEOVER.FLAG THEN
        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsAmortisationTerm)
        EB.SystemTables.setEtext("AA.PS.AMORT.NOT.ALLOW.MAT.CONTRACT")
        EB.ErrorProcessing.StoreEndError()
    END

** For call type of  arrangements, Amortisation term should be null
    IF CONTRACT.TYPE EQ "CALL"  AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsAmortisationTerm) AND NOT(TAKEOVER.FLAG) THEN
        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsAmortisationTerm)
        EB.SystemTables.setEtext("AA.PS.AMORT.NOT.ALLOW.CALL.CONTRACT")
        EB.ErrorProcessing.StoreEndError()
    END

** In arrangement level default the Percentage (if not given) for Account property whose payment.type is defined as CALCULATED and ACTUAL
    GOSUB CHECK.DEFAULT.PERCENTAGE

    tmp.ETEXT = EB.SystemTables.getEtext()
    IF NOT(tmp.ETEXT) AND AA.Framework.getProductArr() EQ AA.Framework.AaArrangement AND DATE.CONVENTION THEN ;* If error, no point in building the entire schedules
        EB.SystemTables.setEtext(tmp.ETEXT)
        GOSUB CHECK.FULL.SCHEDULES
        IF NOT(DUP.ERR) THEN
            GOSUB CHECK.DUPLICATE.INTEREST.SCHEDULE
        END
    END

    GOSUB CHECK.PROPERTY.IN.ARRANGEMENT ;* Check property in Arrangement
    GOSUB CHECK.BILLS.COMBINED
    GOSUB CHECK.DISBURSEMENT.SCHEDULE   ;* Check disbursement schedule in Arrangement

    IF ACT.ACTIVITY EQ 'DEFINE.HOLIDAY' THEN
        GOSUB VALIDATE.HOLIDAY.DEFINITION         ;*To validate the Holiday definition of Payment Schedule
    END

    GOSUB CHECK.ADVANCE.SETUP
    
    ERR.TEXT = ""  ;* Initailise to null so we get to know if there is any issue only while checking the error record below
    EB.DataAccess.CacheRead('F.EB.ERROR', "AA-LOOK.BACK.DAY.BETWEEN.1.TO.10", INTEREST.REC, ERR.TEXT)
    IF INTEREST.REC AND NOT(ERR.TEXT) THEN
        ArrProductLine = AA.Framework.getActivityId()<AA.Framework.ActProductLine> ;* Get Product Line from Arrangement level
        IF ArrProductLine EQ 'LENDING' OR ArrProductLine EQ 'DEPOSITS' THEN
            GOSUB PerformRfrValidations ; *To perform RFR rates related validations
        END
    END
    
    

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= CHECK.ADVANCE.SETUP>
*** <desc>Validate advance interest Property </desc>

CHECK.ADVANCE.SETUP:


    PRODUCT.RECORD = AA.Framework.getProductRecord() ;* Product details
    AA.ProductFramework.GetPropertyName(PRODUCT.RECORD, "INTEREST", INT.PROPERTIES) ;* Get Interest property linked with Product
    LOOP
        REMOVE INT.PROP FROM INT.PROPERTIES SETTING INT.POS
    WHILE INT.PROP : INT.POS
        R.ACCRUAL.DETAILS = ""
        AA.Interest.GetInterestAccruals("VAL", ARR.NO, INT.PROP, "", "", R.ACCRUAL.DETAILS, "", "") ;* Read the AA.INTEREST.ACCRUALS record
        IF R.ACCRUAL.DETAILS<AA.Interest.InterestAccruals.IntAccPaymentMode> EQ "ADVANCE" THEN ;* Check it is a advance payment mode.
            FIND INT.PROP IN EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty) SETTING FM.POS, VM.POS, SM.POS ELSE ;* Check interst property defined on payment schedule arrangement conditon level . if not then throw as an error message.
                EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
                EB.SystemTables.setAv("1")
                EB.SystemTables.setAs("1")
                EB.SystemTables.setEtext("AA.PS.ADVANCE.PROPERTY.MANDATORY":@FM:INT.PROP)
                EB.ErrorProcessing.StoreEndError()
            END
        END
    REPEAT

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Duplicate Payment type>
*** <desc>Validate Same payment type date</desc>
CHECK.DUPLICATE.PAYMENT.TYPE:

    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
    PAYMENT.TYPE = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)      ;* Payment schedule values assign to PAYMENT.TYPE
    PROPERTY = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty)    ;* Payment schedule values assign to PROPERTY
    BILL.PRODUCED = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsBillProduced)    ;* Payment schedule values assign to BILL.PRODUCED
    DEFER.PERIOD = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsDeferPeriod)      ;* Payment Schedule values assign to Defer Period.
    RET.ERR=''

    AA.PaymentSchedule.PaymentTypeBillValidate(PAYMENT.TYPE,PROPERTY,BILL.PRODUCED,DEFER.PERIOD,RET.ERR)    ;* Return value from this routine is RET.ERR
    IF RET.ERR THEN
        EB.SystemTables.setEtext(RET.ERR);* Error message is set to error variable
        EB.ErrorProcessing.StoreEndError()
    END

    BILL.PRODUCED.PRD.CHG = ''
    PERIODIC.CHARGE.PROPERTY = ''
    AA.ProductFramework.GetPropertyName('', "PERIODIC.CHARGES", PERIODIC.CHARGE.PROPERTY)
    IF PERIODIC.CHARGE.PROPERTY THEN    ;* This validation is only for Periodic Charge property
        LOOP
            REMOVE PERIODIC.CHG.PROPERTY.ID FROM PERIODIC.CHARGE.PROPERTY SETTING PROP.POS          ;* This is to check the multiple periodic charge properties
        WHILE PERIODIC.CHG.PROPERTY.ID AND BILL.PRODUCED.PRD.CHG EQ ''
            FIND PERIODIC.CHG.PROPERTY.ID IN PROPERTY SETTING FM.POS, VM.POS, SM.POS THEN ;* get the position of periodic charge property '' Loop for each BILL.
                BILL.PRODUCED.PRD.CHG = BILL.PRODUCED<1, VM.POS>      ;*  get the corresponding value for Bill produced of periodic charge
            END
        REPEAT

        IF BILL.PRODUCED.PRD.CHG THEN   ;* raise an override if Bill produced is set for Periodic Charge property
            EB.SystemTables.setText("AA.PS.BILL.PROD.FOR.PERIODIC.CHARGE")
            EB.OverrideProcessing.StoreOverride("")
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Arrangement Base Date>
*** <desc>Validate arrangement base date</desc>
CHECK.ARR.BASE.DATE:

    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsBaseDate)

** Cannot be less than arrangement start date
    IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsBaseDate) THEN      ;* Always a date at arrangement
        IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsBaseDate) LT AA.Framework.getRArrangement()<AA.Framework.Arrangement.ArrStartDate> THEN
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsBaseDate)
            EB.SystemTables.setEtext("AA.PS.CANT.BE.LESS.THAN.ARR.START.DATE")
            EB.ErrorProcessing.StoreEndError()
        END
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Residual amount validations for arrangement>
*** <desc>Check if residual amount is greater than contract</desc>
CHECK.ARR.RESIDUAL.AMOUNT:

** For call type of  arrangements, Residual amount should be null
    IF CONTRACT.TYPE EQ "CALL" AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsResidualAmount) THEN
        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsResidualAmount)
        EB.SystemTables.setEtext("AA.PS.RESIDUAL.NOT.ALLOW.CALL.CONTRACT")
        EB.ErrorProcessing.StoreEndError()
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Event related validations for arrangement>
***
CHECK.ARR.EVENT.RECALCULATE:

    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsOnActivity)
    MV.COUNT = COUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsOnActivity), @VM) + 1

    FOR AV.LOC = 1 TO MV.COUNT
        EB.SystemTables.setAv(AV.LOC)
** For call type of  arrangements, Recalculate as term not allowed
        IF CONTRACT.TYPE EQ "CALL" AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsRecalculate)<1,EB.SystemTables.getAv()> = "TERM" THEN
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsRecalculate)
            EB.SystemTables.setEtext("AA.PS.TERM.RECALC.NOT.ALLOW.CALL.CONTRACT")
            EB.ErrorProcessing.StoreEndError()
        END
    NEXT AV.LOC

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Payment type validations on arrangement>
*** <desc>Combination of Linear and Constant or Other is not allowed for calls
CHECK.ARR.PAYMENT.TYPE:

* Validate constant and linear types
    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)

    MV.COUNT = COUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType), @VM) + 1
    FOR AV.LOC = 1 TO MV.COUNT
        EB.SystemTables.setAv(AV.LOC)
        IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)<1,EB.SystemTables.getAv()> THEN
            R.PAYMENT.TYPE = ""
            PAYMENT.TYPE = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)<1,EB.SystemTables.getAv()>
            R.PAYMENT.TYPE = AA.PaymentSchedule.PaymentType.CacheRead(PAYMENT.TYPE, "")
            IF R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> MATCHES "CONSTANT":@VM:"LINEAR":@VM:"PROGRESSIVE":@VM:"ACCELERATED":@VM:"PERCENTAGE" THEN
                IF CONTRACT.TYPE EQ "CALL" THEN
                    EB.SystemTables.setEtext("AA.PS.CONSTANT.OR.LINEAR.NOT.ON.CALL")
                    EB.ErrorProcessing.StoreEndError()
                END
            END
        END
    NEXT AV.LOC

    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsStartDate)

    FOR AV.LOC = 1 TO MV.COUNT
        EB.SystemTables.setAv(AV.LOC)

        PROP.COUNT = DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,CNT>, @SM)

        FOR AF.LOC = 1 TO PROP.COUNT
            EB.SystemTables.setAf(AF.LOC)
            DATE.FORMAT = FIELDS(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate), "_", 2)
            RELATIVE.OPTION = FIELDS(DATE.FORMAT, " ", 1)

            IF CONTRACT.TYPE EQ "CALL" AND RELATIVE.OPTION EQ "MATURITY" THEN
                EB.SystemTables.setEtext("AA-MATURITY.OPT.NOT.ALLOW.CALL")
                EB.ErrorProcessing.StoreEndError()
            END

        NEXT AF.LOC

    NEXT AV.LOC

    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsEndDate)

    FOR AV.LOC = 1 TO MV.COUNT
        EB.SystemTables.setAv(AV.LOC)

        PROP.COUNT = DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsEndDate)<1,CNT>, @SM)

        FOR AF.LOC = 1 TO PROP.COUNT
            EB.SystemTables.setAf(AF.LOC)
            DATE.FORMAT = FIELDS(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsEndDate), "_", 2)
            RELATIVE.OPTION = FIELDS(DATE.FORMAT, " ", 1)

            IF CONTRACT.TYPE EQ "CALL" AND RELATIVE.OPTION EQ "MATURITY" THEN
                EB.SystemTables.setEtext("AA-MATURITY.OPT.NOT.ALLOW.CALL")
                EB.ErrorProcessing.StoreEndError()
            END

        NEXT AF.LOC

    NEXT AV.LOC




RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name=CHECK.DEFAULT.PERCENTAGE>
*** <desc>Default % as 100 if its not given for Account property in PS</desc>
CHECK.DEFAULT.PERCENTAGE:

* For payment types which are defined as ACTUAL and  CALCULATED, and for Account properties under these payment types
* check for %, if its not given, default it to 100
    EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)
    COUNT.TYPE = DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType), @VM)
    FOR PAY.COUNT  = 1 TO COUNT.TYPE
        PAYMENT.TYPE = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)<1, PAY.COUNT>
        CURRENT.PAYMENT.METHOD = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)<1, PAY.COUNT>
        EB.SystemTables.setAv(PAY.COUNT)
        GOSUB GET.PAYMENT.TYPE          ;*Read Payment Type record
        COUNT.PROPERTY = DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty)<1,PAY.COUNT>, @SM)
        FOR PROP.COUNT = 1 TO COUNT.PROPERTY
            IF R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> EQ "ACTUAL" AND R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtType> EQ "CALCULATED" THEN
                GOSUB DEFAULT.PERCENTAGE
            END
            PROPERTY =  EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty)<1,PAY.COUNT,PROP.COUNT>
            AA.ProductFramework.GetPropertyClass(PROPERTY, PROPERTY.CLASS)
            GOSUB VALIDATE.NEGATIVE.INTEREST.RATES
        NEXT PROP.COUNT
    NEXT PAY.COUNT

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name=DEFAULT.PERCENTAGE>
*** <desc>Default percentage if % not given for Account property alone</desc>
DEFAULT.PERCENTAGE:

    PS.PROPERTY = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty)<1,PAY.COUNT,PROP.COUNT>
    AA.ProductFramework.GetPropertyClass(PS.PROPERTY, PS.PROPERTY.CLASS)
    IF PS.PROPERTY.CLASS EQ "ACCOUNT" AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage)<1,PAY.COUNT,PROP.COUNT> EQ "" AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)<1,PAY.COUNT,1> EQ ""  THEN          ;* is it an Account property, % not given and Actual amount is also not given
        tmp=EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage); tmp<1,PAY.COUNT,PROP.COUNT>="100"; EB.SystemTables.setRNew(AA.PaymentSchedule.PaymentSchedule.PsPercentage, tmp);* default the percentage as 100
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Schedule validations>
***
CHECK.FULL.SCHEDULES:

* Check duplicate schedule definition, duplicates not allowed for Interest
*
    DUP.NOT.ALLOWED = "INTEREST":@VM:"PERIODIC.CHARGES":@VM:"ACCOUNT"

    R.PAYMENT.SCHEDULE = ""
    R.PAYMENT.SCHEDULE = EB.SystemTables.getDynArrayFromRNew()

    SCHEDULE.INFO = ""
    SCHEDULE.INFO<4> = LOWER(R.PAYMENT.SCHEDULE)

    START.DATE = ""
    NO.CYCLES = ""
    END.DATE = ""   ;* The entire list of dates

    PAYMENT.TYPES = ""
    PAYMENT.METHODS = ""
    PAYMENT.DATES = ""
    PAYMENT.AMOUNTS = ""
    PAYMENT.PROPERTIES = ""
    PAYMENT.PERCENTAGES = ""

    AA.PaymentSchedule.BuildPaymentScheduleDates(SCHEDULE.INFO, START.DATE, END.DATE, NO.CYCLES, "", PAYMENT.DATES, "", "", PAYMENT.TYPES, PAYMENT.METHODS, PAYMENT.AMOUNTS, PAYMENT.PROPERTIES, PAYMENT.PERCENTAGES, "", "",PAYMENT.BILL.TYPE, RET.ERROR)
    RFR.PAYMENT.DATES = PAYMENT.DATES
    RFR.PAYMENT.PROPERTIES = PAYMENT.PROPERTIES

    GOSUB CHECK.FINAL.END.DATE          ;* New validation added for the cycled dates

* Loop through the properties and check if they contain any duplicates

    PAYMENT.DATES.COUNT = DCOUNT(PAYMENT.DATES, @FM)
    OVERRIDE.SET = ""
    DUP.ERR = ''
    YI = 1

    LOOP
        PROPERTIES = PAYMENT.PROPERTIES<YI>
    UNTIL YI GT PAYMENT.DATES.COUNT OR EB.SystemTables.getEtext()      ;* Until error message or list is complete
        TYPE.COUNT = DCOUNT(PAYMENT.PROPERTIES<YI>, @VM)     ;* For each payment type, need this to locate the correct position

        DUP.PROPERTIES = ""   ;* Maintain an array for duplicate properties

        FOR TYPE.I = 1 TO TYPE.COUNT
            PROPERTIES = PAYMENT.PROPERTIES<YI,TYPE.I>      ;* Get the properties
            CONVERT @SM TO @VM IN PROPERTIES
            MV.COUNT = DCOUNT(PROPERTIES, @VM)
            FOR MV.I = 1 TO MV.COUNT
            	PROPERTY.CLASSES = ""
                PROPERTY.CLASS = ""
                GOSUB CHECK.DUPLICATE.PROPERTIES  ;* Check for duplicates
            NEXT MV.I
        NEXT TYPE.I
        YI += 1
    REPEAT

    R.PAYMENT.SCHEDULE.REC = EB.SystemTables.getDynArrayFromRNew()
    RESERVED.1 = ''
    RESERVED.3 = ''
    RESERVED.4 = ''
    RESERVED.5 = ''
    RESERVED.6 = ''

    ADDITIONAL.INFO<5> = ARR.NO	;* Preserve the original value that may contain SIM Mode when used to get records

    tmp.ID.NEW = EB.SystemTables.getIdNew()
    AA.PaymentSchedule.PaymentScheduleInterestValidate(tmp.ID.NEW, RESERVED.1, R.PAYMENT.SCHEDULE.REC, RESERVED.3, RESERVED.4, ADDITIONAL.INFO, PAYMENT.DATES, PAYMENT.TYPES, PAYMENT.METHODS, PAYMENT.PROPERTIES, ERROR.DETAILS)
    EB.SystemTables.setIdNew(tmp.ID.NEW)
    IF ERROR.DETAILS THEN
        GOSUB HANDLE.ERROR
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Check Disbursement schedule>
*** <desc>Raise override message if disbursement is scheduled </desc>
CHECK.DISBURSEMENT.SCHEDULE:

    EFFECTIVE.DATE = ''
    DISBURSE.PAYMENT.TYPES = ''
    ACTIVITY.ID = AA.Framework.getActivityId()

    MV.COUNT = DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType), @VM)
    FOR TYPE.COUNT = 1 TO MV.COUNT
        EB.SystemTables.setAv(TYPE.COUNT);*Set the marker against correct multi-value
        GOSUB GET.SYS.BILL.TYPE         ;* Get system bill type
        IF SYSTEM.BILL.TYPE AND SYSTEM.BILL.TYPE EQ 'DISBURSEMENT' THEN
            DISBURSE.PAYMENT.TYPES<1, -1> = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)<1, TYPE.COUNT>
        END
    NEXT TYPE.COUNT

    IF DISBURSE.PAYMENT.TYPES THEN
        START.DATE = ""
        PAYMENT.TYPES = ""
        PAYMENT.METHODS = ""
        PAYMENT.DATES = ""
        PAYMENT.AMOUNTS = ""
        PAYMENT.PROPERTIES = ""
        PAYMENT.PERCENTAGES = ""

        EFFECTIVE.DATE = AA.Framework.getActivityEffDate()

        AA.PaymentSchedule.BuildPaymentScheduleDates(SCHEDULE.INFO, START.DATE, END.DATE, NO.CYCLES, "", PAYMENT.DATES, "", "", DISBURSE.PAYMENT.TYPES, PAYMENT.METHODS, PAYMENT.AMOUNTS, PAYMENT.PROPERTIES, PAYMENT.PERCENTAGES, "", "", "", RET.ERROR)

        IF NOT(TOT.PERCENTAGE) THEN     ;* Only at arrangement level
            GOSUB VALIDATE.DISBURSE.AVAIL.AMOUNT  ;*Check if the scheduled one is less than available amount
        END

        LOCATE EFFECTIVE.DATE IN PAYMENT.DATES<1> BY "AR" SETTING PAY.TYPE.POS.X THEN
        END

        IF EFFECTIVE.DATE LT PAYMENT.DATES<PAY.TYPE.POS.X> THEN
            EB.SystemTables.setText('AA.FUTURE.DISB.SCH.MAY.GET.AFFECT')
            EB.OverrideProcessing.StoreOverride("")
        END
    END

RETURN
*** </region>
*------------------------------------------------------------------------------
*** <region name= Check Duplicate Interest Schedule>
*** <desc>If interest property overlaps, then force start and end date </desc>
CHECK.DUPLICATE.INTEREST.SCHEDULE:
    
    IF PRODUCT.LINE EQ 'LENDING' THEN
        GOSUB CHECK.CHANGE.SCHEDULE ;*Check for change in ps condition
        IF CHANGE.SCHEDULE THEN ;* If there is a chane in ps condition record, then validate it.
            errorDetails = ''
            AA.PaymentSchedule.PaymentScheduleStartEndDateValidate(R.PAYMENT.SCHEDULE, "", "", errorDetails)
            IF errorDetails NE '' THEN
                ERROR.DETAILS = errorDetails
                GOSUB HANDLE.ERROR    ;* To raise errors against the field
            END
        END
    END
 
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Check Change schedule>
*** <desc>Check Change schedule</desc>
CHECK.CHANGE.SCHEDULE:
    
    CHANGE.SCHEDULE = ''
    R.OLD.PAYMENT.SCHEDULE = EB.SystemTables.getDynArrayFromROld()
    
    IF R.OLD.PAYMENT.SCHEDULE THEN
        START.POS = AA.PaymentSchedule.PaymentSchedule.PsPaymentType
        FINAL.POS = AA.PaymentSchedule.PaymentSchedule.PsEndDate
        LOOP
        WHILE START.POS LE FINAL.POS AND NOT(CHANGE.SCHEDULE)
            IF R.OLD.PAYMENT.SCHEDULE<START.POS> NE R.PAYMENT.SCHEDULE<START.POS> THEN     ;* Make sure PS changes was done
                CHANGE.SCHEDULE = 1   ;* Something has got changed, need to validate!!
            END
            START.POS ++
        REPEAT
    END ELSE
        CHANGE.SCHEDULE = 1   ;* It is a new input, needs validation!!
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Validate Disburse amount against available commitment amount>
*** <desc>Validate Disburse amount against available commitment amount</desc>
VALIDATE.DISBURSE.AVAIL.AMOUNT:

    LIFECYCLE.STATUS = 'CUR'
    GOSUB GET.PROPERTY.NAME   ;*Get Term amount property name and required balance type
    GOSUB GET.BALANCE.AMOUNT  ;*Get Balance amount as of current date
    CUR.TERM.AMT = ABS(BAL.DETAILS<AC.BalanceUpdates.AcctActivity.IcActBalance>)         ;*This is CUR<Term Amount>
    SCHEDULED.DISBURSE.AMOUNT = PAYMENT.AMOUNTS

    CONVERT @FM TO @VM IN SCHEDULED.DISBURSE.AMOUNT ;*To facilitate SUM function, keep all with one marker VM. Since no scope to have SM, keep it there
    BEGIN CASE
        CASE SUM(SCHEDULED.DISBURSE.AMOUNT) GT CUR.TERM.AMT     ;*Exceeds the defined amount. Raise override
            EB.SystemTables.setText("AA.PS.AMT.GRT.THAN.COMMT.AMT":@FM:(SUM(SCHEDULED.DISBURSE.AMOUNT)-CUR.TERM.AMT))
            EB.OverrideProcessing.StoreOverride("")
        CASE SUM(SCHEDULED.DISBURSE.AMOUNT) LT CUR.TERM.AMT AND CUR.TERM.AMT        ;*Raise override to indicate full disbursement is not defined
            EB.SystemTables.setText('AA.PS.AMT.LESSER.THAN.COMMT.AMT')
            EB.OverrideProcessing.StoreOverride("")
    END CASE

* Get TERM.AMOUNT property
    BALANCE.TYPE = ''
    LIFECYCLE.STATUS = 'TOT'
    GOSUB GET.PROPERTY.NAME   ;*Get Term amount property name
    GOSUB GET.BALANCE.AMOUNT  ;*Get the TOT balance amount as on effective date
    BALANCE.AMOUNT = ABS(BAL.DETAILS<AC.BalanceUpdates.AcctActivity.IcActBalance>)       ;* Get the current outstanding amount

    IF TOT.DIS.AMT GT BALANCE.AMOUNT AND BALANCE.AMOUNT THEN
        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsActualAmt)
        EB.SystemTables.setEtext('AA.PS.AMT.GREATER.THAN.COMMT.AMT')
        EB.ErrorProcessing.StoreEndError()
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Check Outstanding Balance>
*** <desc>Raise override message if principal outstaning balance is zero</desc>
GET.PROPERTY.NAME:

    AA.ProductFramework.GetPropertyName('', "TERM.AMOUNT", TERM.AMOUNT.PROPERTY)
    BALANCE.TYPE = ""
    IF LIFECYCLE.STATUS THEN
        AA.ProductFramework.PropertyGetBalanceName(ARR.NO, TERM.AMOUNT.PROPERTY, LIFECYCLE.STATUS, "", "", BALANCE.TYPE)
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Check Outstanding Balance>
*** <desc>Raise override message if principal outstaning balance is zero</desc>
GET.BALANCE.AMOUNT:

    BALANCE.AMOUNT = 0
    BAL.DETAILS = ''          ;* The current balance figure
    RET.ERROR = ''
    DATE.OPTIONS = ""
    DATE.OPTIONS<2> = "ALL"   ;* Include all unauth movement
    EFF.DATE = AA.Framework.getActivityEffDate()
    ACCOUNT.ID = AA.Framework.getLinkedAccount()
    AA.Framework.GetPeriodBalances(ACCOUNT.ID, BALANCE.TYPE, DATE.OPTIONS, EFF.DATE, '', "", BAL.DETAILS, RET.ERROR)

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Schedule validations>
*** <desc>Check the next schedule date is LE maturity date</desc>
CHECK.FINAL.END.DATE:

    PAYMENT.END.DATE = ''
    EFFECTIVE.DATE = ''

    PAYMENT.END.DATE = AA.Framework.getAccountDetails()<AA.PaymentSchedule.AccountDetails.AdPaymentEndDate>
    EFFECTIVE.DATE = AA.Framework.getActivityEffDate()
    MATURITY.DATE = AA.Framework.getAccountDetails()<AA.PaymentSchedule.AccountDetails.AdMaturityDate>

    TARGET.CLASS = 'PAYMENT.SCHEDULE'
    GOSUB CHECK.SIMULATION.DETAILS

    BEGIN CASE
        CASE PAYMENT.END.DATE AND EFFECTIVE.DATE GE PAYMENT.END.DATE      ;* Skip error message past payment end date, it can be because of Interest schedule

        CASE SIM.MODE   ;* Skip error during simulation capture, Its ok to catch it during Runner!!!

        CASE TERM.AMOUNT.TERM AND AA.Framework.getNewArrangement() AND NOT(TAKEOVER.FLAG) AND AA.Framework.getRArrangement()<AA.Framework.Arrangement.ArrProductLine> EQ "LENDING"    ;* When maturity date is less than the frequency defined throw error message, Skip for Loan Modelling and dont check this during actual term change itself
            AUTO.DISBURSEMENT = 0
            PAY.TYPE.COUNT = DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType), @VM)
            FOR AV.LOC = 1 TO PAY.TYPE.COUNT UNTIL AUTO.DISBURSEMENT
                EB.SystemTables.setAv(AV.LOC)
                GOSUB GET.SYS.BILL.TYPE
                IF SYSTEM.BILL.TYPE EQ "DISBURSEMENT" THEN      ;* To find if the schedule as disbursement defined or not.
                    AUTO.DISBURSEMENT = 1
                END
            NEXT AV.LOC

            PAYMENT.SCHEDULE = 0
            IF  AUTO.DISBURSEMENT THEN
                DISBURSEMENT.SCHEDULE = 0
            END ELSE
                DISBURSEMENT.SCHEDULE = 1
            END
            PAY.TYPE.POS = 1
            PAY.DATES = PAYMENT.DATES
            PAYMENT.BILL.TYPES = PAYMENT.BILL.TYPE
* We need to throw error if the first schedule of the disbursement and non disbursement type is greater than the maturity date.To achieve this we need to
* loop through the Payment dates and in turn the Bill types to get the first Payment schedule and Disbursement schedule if defined.
            LOOP
                REMOVE PAY.DATE FROM PAY.DATES SETTING PAY.POS
            UNTIL NOT(PAY.DATE) OR (DISBURSEMENT.SCHEDULE AND PAYMENT.SCHEDULE)
                LOOP
* The Payment bill types will be separated by VM if the different schedules falls on the same date. To check each payment schedule we need to loop
* through the payment bill type of each payment date until we find the next FM marker or end of the marker.
                    REMOVE BILL.TYPE FROM PAYMENT.BILL.TYPES SETTING BILL.POS
                    SYSTEM.BILL.TYPE = ""
                    AA.PaymentSchedule.GetSysBillType(BILL.TYPE, SYSTEM.BILL.TYPE, RET.ERROR)
                    IF SYSTEM.BILL.TYPE EQ 'DISBURSEMENT' AND NOT(DISBURSEMENT.SCHEDULE) THEN
                        DISBURSEMENT.SCHEDULE = 1
                        IF PAY.DATE GT MATURITY.DATE THEN
                            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)
                            LOCATE PAYMENT.TYPES<PAY.TYPE.POS,1> IN EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)<1,1> SETTING AV.LOC ELSE          ;* Get the correct position
                                EB.SystemTables.setAv(1)
                            END
                            EB.SystemTables.setAv(AV.LOC)
                            EB.SystemTables.setEtext("AA.PS.FINAL.END.DATE.GT.TERM.END.DATE")
                            EB.ErrorProcessing.StoreEndError()
                        END
                    END
                    IF SYSTEM.BILL.TYPE EQ 'PAYMENT' AND NOT(PAYMENT.SCHEDULE) THEN
                        PAYMENT.SCHEDULE = 1
                        IF PAY.DATE GT MATURITY.DATE THEN
                            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)
                            LOCATE PAYMENT.TYPES<PAY.TYPE.POS,1> IN EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)<1,1> SETTING AV.LOC ELSE          ;* Get the correct position
                                EB.SystemTables.setAv(1)
                            END
                            EB.SystemTables.setAv(AV.LOC)
                            EB.SystemTables.setEtext("AA.PS.FINAL.END.DATE.GT.TERM.END.DATE")
                            EB.ErrorProcessing.StoreEndError()
                        END
                    END
                UNTIL BILL.POS MATCHES "0":@VM:"2"
                REPEAT
                PAY.TYPE.POS += 1
            REPEAT
* There may be the case where no payment schedule is defined or schedules (Linear,Contstant payment types) are defined after the maturity date.
            IF PAYMENT.SCHEDULE EQ '0' THEN
                EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq)
                EB.SystemTables.setAv(1)
                EB.SystemTables.setEtext("AA.PS.FINAL.END.DATE.GT.TERM.END.DATE")
                EB.ErrorProcessing.StoreEndError()
            END
    END CASE

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Schedule property validations>
*** <desc>Check if duplicate interest property is defined</desc>
CHECK.DUPLICATE.PROPERTIES:

    LOCATE PROPERTIES<1,MV.I> IN DUP.PROPERTIES<1> SETTING DUP.POS ELSE         ;* Check the duplicates list
        DUP.POS = 0
    END

    IF DUP.POS THEN ;* We have hit a duplicate

        ADVANCE.INT.FLAG = ""
        PROPERTY = PROPERTIES<1,MV.I>
        GOSUB CHECK.ADVANCE.PROPERTY

        IF NOT(ADVANCE.INT.FLAG) THEN
            AA.ProductFramework.GetPropertyClass(PROPERTIES, PROPERTY.CLASSES)  ;* Get property class for the properties
            IF PROPERTY.CLASSES<1,MV.I> MATCHES DUP.NOT.ALLOWED THEN  ;* Check if duplicate for this class is allowed
                EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsProperty)
                LOCATE PAYMENT.TYPES<YI,TYPE.I> IN EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)<1,1> SETTING AV.LOC ELSE   ;* Get the correct position
                    EB.SystemTables.setAv(1)
                END
                EB.SystemTables.setAv(AV.LOC)
                IF PROPERTY.CLASSES<1,MV.I> NE "ACCOUNT" THEN
                    EB.SystemTables.setEtext("AA.PS.DUP.PROPERTY.DATE.NOT.ALLOWED":@FM:PROPERTIES<1,MV.I>:@VM:OCONV(ICONV(PAYMENT.DATES<YI>,"DE"), "DE"))
                    EB.ErrorProcessing.StoreEndError()
                    IF PROPERTY.CLASSES<1,MV.I> EQ 'INTEREST' THEN
                        DUP.ERR = 1
                    END
                END ELSE
                    IF NOT(OVERRIDE.SET) THEN
                        OVERRIDE.SET = 1
                        EB.SystemTables.setText("AA.PS.PT.TYPE.AND.PROPERTY.REPEAT")
                        EB.OverrideProcessing.StoreOverride("")
                    END
                END
            END
        END
    END ELSE
        DUP.PROPERTIES<-1> = PROPERTIES<1,MV.I>   ;* Not in the list, insert it
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Arrangement property validation>
*** <desc>Checks if the property exist in AA.ARRANGEMENT</desc>
CHECK.PROPERTY.IN.ARRANGEMENT:
* Check each and every property defined in PAYMENT.SCHEDULE, if it exists in the arrangement.

** For takeover (from legacy systems) arrangements which are matured, the fields Payment frequency, Due frequency, Start date, End Date, Num Payments
** should be null

    EFF.DATE = AA.Framework.getPropEffDate()
    ARR.RECORD = AA.Framework.getRArrangement()
    ArrNoWithCp<1> = AA.Framework.getArrId()

    IF ACT.ACTIVITY EQ "CHANGE.PRODUCT" AND EB.SystemTables.getApplication() NE "AA.SIMULATION.CAPTURE" THEN
        ArrNoWithCp<2> = "1"  ;* Set the change.product flag when the activity is change.product
    END
          
    AA.Framework.GetArrangementProperties(ArrNoWithCp, EFF.DATE, ARR.RECORD, PROPERTY.LIST)
    
    MV.COUNT = DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType), @VM)
    FOR AV.LOC = 1 TO MV.COUNT
        EB.SystemTables.setAv(AV.LOC)
        GOSUB PROCESS.PROPERTY.BASED.FIELDS

        PREVIOUS.START.DATE = ""        ;* Last start date in the sub-value
        PREVIOUS.END.DATE = ""          ;* Last ened date in the sub-value

        PAYMENT.TYPE = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType)<1,EB.SystemTables.getAv()>
        GOSUB GET.PAYMENT.TYPE          ;*Read Payment Type record

        SM.COUNT = COUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsStartDate)<1,EB.SystemTables.getAv()>, @SM) + 1
        FOR AS.LOC = 1 TO SM.COUNT
            EB.SystemTables.setAs(AS.LOC)

            PROP.NAME = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>

            AA.ProductFramework.GetPropertyClass(PROP.NAME, PROP.CLASS)
            ARRANGEMENT.ID = AA.Framework.getArrId()    ;* Get the Arrangement Id
            PROCESS.MODE = "CURRENT"
            LAST.PAYMENT.DATE = ""                      ;* Initialse the variable
            AA.PaymentSchedule.GetLastPaymentDate(ARRANGEMENT.ID, PAYMENT.TYPE, PROP.NAME, PROCESS.MODE, LAST.PAYMENT.DATE, "", "", "") ;* Get the last payment date.
            
            GOSUB START.DATE.VALIDATIONS          ;* Start date validations

            GOSUB END.DATE.VALIDATIONS  ;* End date validations

            GOSUB CHECK.NUM.PAYMENTS    ;* Validate number of payments

            GOSUB CHECK.ACTUAL.AMT      ;* Amount validations

        NEXT AS.LOC

    NEXT AV.LOC

    GOSUB CHECK.VALID.ACTIVITY

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name=PROCESS.PROPERTY.BASED.FIELDS>
*** <desc>Process property related Sub value fields</desc>
PROCESS.PROPERTY.BASED.FIELDS:

    SM.COUNT = DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty)<1,EB.SystemTables.getAv()>,@SM)
    FOR AS.LOC = 1 TO SM.COUNT
        EB.SystemTables.setAs(AS.LOC)
        LOCATE EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> IN PROPERTY.LIST<1,1> SETTING ARR.POS ELSE
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsProperty)
            EB.SystemTables.setEtext('AA.PS.PROPERTY.NOT.IN.ARRANGEMENT')
            EB.ErrorProcessing.StoreEndError()
        END


    NEXT AS.LOC

RETURN
*** </region>
*-------------------------------------------------------------------

*** <region name= Check Valid Activity>
*** <desc>Check Activity defined in ON.MATURITY is valid</desc>
CHECK.VALID.ACTIVITY:

    ACT.CNT = 0
    ARR.NO = AA.Framework.getArrId()
    ACTIVITY.LIST = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsOnActivity)
    LOOP
        REMOVE ACTIVITY.ID FROM ACTIVITY.LIST SETTING ACT.POS
    WHILE ACTIVITY.ID
        ACT.CNT + = 1
        VALID.ACTIVITY = ""
        AA.Framework.DetermineValidActivity(ACTIVITY.ID,ARR.NO,PROPERTY.LIST,VALID.ACTIVITY,RET.ERR)
        IF NOT(VALID.ACTIVITY) THEN
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsOnActivity)
            EB.SystemTables.setAv(ACT.CNT)
            EB.SystemTables.setEtext("AA-NOT.A.VALID.ACTIVITY":@FM:ACTIVITY.ID)
            EB.ErrorProcessing.StoreEndError()
        END
    REPEAT

RETURN
*** </region>


*-----------------------------------------------------------------------------
*** <region name= Check Interest Compounding>
*** <desc> </desc>
CHECK.INTEREST.COMPOUNDING:

    INTEREST.PROPERTY = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()>
    AA.ProductFramework.GetPropertyClass(INTEREST.PROPERTY, PROPERTY.CLASS)
    IF PROPERTY.CLASS = "INTEREST" THEN
        tmp.AA$ACTIVITY.EFF.DATE = AA.Framework.getActivityEffDate()
        tmp.AA$ARR.ID = AA.Framework.getArrId()
        AA.ProductFramework.GetPropertyRecord("", tmp.AA$ARR.ID, INTEREST.PROPERTY, tmp.AA$ACTIVITY.EFF.DATE, "INTEREST", "", INT.RECORD, RET.ERROR)
        AA.Framework.setArrId(tmp.AA$ARR.ID)
        AA.Framework.setActivityEffDate(tmp.AA$ACTIVITY.EFF.DATE)
        IF INT.RECORD<AA.Interest.Interest.IntCompoundType> THEN
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsProperty)
            EB.SystemTables.setEtext("AA.PS.ANNUITY.COMPOUND.NOT.ALLOW")
            EB.ErrorProcessing.StoreEndError()
        END
    END

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

*** <region name= GET.PAYMENT.TYPE>
GET.PAYMENT.TYPE:
*** <desc>Read Payment Type record </desc>

    R.PAYMENT.TYPE = ''
    R.PAYMENT.TYPE = AA.PaymentSchedule.PaymentType.CacheRead(PAYMENT.TYPE, "")

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= CHECK.FOR.ACCRUAL.BY.BILLS>
CHECK.FOR.ACCRUAL.BY.BILLS:
*** <desc>Check accrual by bills setup for the property </desc>

    AA.Framework.LoadStaticData('F.AA.PROPERTY', PROPERTY, R.PROPERTY, ERR.PROPERTY)
    LOCATE "ACCRUAL.BY.BILLS" IN R.PROPERTY<AA.ProductFramework.Property.PropPropertyType,1> SETTING POS THEN
        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsProperty)
        EB.SystemTables.setEtext("AA-ACCRUAL.BY.BILLS.NOT.ALLOW")
        EB.ErrorProcessing.StoreEndError()
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
***<region name = Validate Mininum Payment Amount>
***<desc> To validated The fields Minimum Payment Amount & Bill Minimum Payment Amount</desc>
VALIDATE.MINIMUM.PAYMENT.AMOUNT:
*===============================

    AA.PaymentSchedule.MinimumAmountValidate()     ;*call routine to validate newly added fields

RETURN
***</region>
*-----------------------------------------------------------------------------
*** <region name= Check for Online Capitalise>
*** <desc>Check for Online Capitalise</desc>
CHECK.ONLINE.CAPITALISE:

    IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsOnlineCapitalise) EQ "YES" THEN
        LOCATE "CAPITALISE" IN EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)<1, 1> SETTING CAP.POS THEN
            GOSUB ONLINE.CAPITALISE.VALIDATE
        END ELSE
            EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsOnlineCapitalise)
            EB.SystemTables.setEtext("AA.PS.ALLOWED.FOR.CAPITALISE.PAYMENT.METHOD")
            EB.ErrorProcessing.StoreEndError()
        END
    END

RETURN
***</region>
*-----------------------------------------------------------------------------
ONLINE.CAPITALISE.VALIDATE:

    PROCESS.ONLINE.CAP = ''
    PROJ.PAY.CNT = DCOUNT(EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentType), @VM)
    FOR PROJ.CNT = 1 TO PROJ.PAY.CNT
        IF EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod)<1, PROJ.CNT> EQ "CAPITALISE"	THEN	;* proceed further only if "CAPITALIS" payment method
            CAP.PROP = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsProperty)<1, PROJ.CNT>		;* get property
            AA.ProductFramework.GetPropertyClass(CAP.PROP, CAP.PROP.CLS)	;* get property class
            IF CAP.PROP.CLS NE "PERIODIC.CHARGES" THEN
                PROCESS.ONLINE.CAP = 1					;* set the variable when "CAPITALISE" is defined other than PERIODIC.CHARGES property.
            END
            IF PROCESS.ONLINE.CAP AND EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsIssueBill)<1, PROJ.CNT> NE "NO" AND CAP.PROP.CLS NE "PERIODIC.CHARGES" THEN
                EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsIssueBill);* not to throw an error for periodic charges with "CAPITALISE" method and issue bill not set to "NO"
                EB.SystemTables.setEtext("AA.PS.ISSUE.BILL.SHOULD.BE.NO.ONLINE.CAPITALISE")
                EB.ErrorProcessing.StoreEndError()
            END
        END
    NEXT PROJ.CNT

    IF NOT(PROCESS.ONLINE.CAP) THEN
        EB.SystemTables.setAf(AA.PaymentSchedule.PaymentSchedule.PsOnlineCapitalise)
        EB.SystemTables.setEtext("AA.PS.ONLINE.CAP.NOT.ALLOWED.FOR.PC.PROPERTY")
        EB.ErrorProcessing.StoreEndError()
    END

RETURN
***</region>
*-----------------------------------------------------------------------------
*** <region name= HANDLE.ERROR>
*** <desc>Call STORE.END.ERROR</desc>
HANDLE.ERROR:

    FOR AF.CNT = 1 TO DCOUNT(ERROR.DETAILS<1>,@VM)
        EB.SystemTables.setAf(ERROR.DETAILS<1,AF.CNT>)
        EB.SystemTables.setAv(ERROR.DETAILS<2,AF.CNT>)
        EB.SystemTables.setAs(ERROR.DETAILS<3,AF.CNT>)
        EB.SystemTables.setEtext(ERROR.DETAILS<4,AF.CNT>)
        EB.ErrorProcessing.StoreEndError()
    NEXT AF.CNT

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= DEFAULT.HOLIDAY.START.DATE>
DEFAULT.HOLIDAY.START.DATE:
*** <desc>To default Holiday Start Date </desc>

    holPaymentTypes = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsHolPaymentType)
    holStartDates = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsHolStartDate)
    holNumPayments =EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsHolNumPayments)

    noOfHolPayments = DCOUNT(holStartDates, @VM) + 1

    FOR vmCount = 1 TO noOfHolPayments  ;* for each of the holiday payment definition
        IF holStartDates<1,vmCount> EQ '' AND (holPaymentTypes<1,vmCount> NE '' OR holNumPayments<1,vmCount> NE '') THEN          ;* if start date is not defined, default to effective date
            tmp=EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsHolStartDate); tmp<1,vmCount>=AA.Framework.getPropEffDate(); EB.SystemTables.setRNew(AA.PaymentSchedule.PaymentSchedule.PsHolStartDate, tmp)
        END
    NEXT vmCount

RETURN
*** </region>


*-----------------------------------------------------------------------------
*** <region name= VALIDATE.HOLIDAY.DEFINITION>
VALIDATE.HOLIDAY.DEFINITION:
*** <desc>To validate the Holiday definition of Payment Schedule </desc>

    rPaySchedule = EB.SystemTables.getDynArrayFromRNew()

    GOSUB VALIDATE.HOL.PAYMENT.TYPE     ;*To validate the Holiday Payment types defined
    IF errorDetails NE '' THEN
        ERROR.DETAILS = errorDetails
        GOSUB HANDLE.ERROR    ;* To raise errors against the field
    END

    GOSUB VALIDATE.HOLIDAY.START.DATE   ;*To validate the values given in Start Date
    IF errorDetails NE '' THEN
        ERROR.DETAILS = errorDetails
        GOSUB HANDLE.ERROR    ;* To raise errors against the field
    END

    GOSUB VALIDATE.HOLIDAY.NUM.PAYMENTS ;*To validate the number of payments given
    IF errorDetails NE '' THEN
        ERROR.DETAILS = errorDetails
        GOSUB HANDLE.ERROR    ;* To raise errors against the field
    END

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= VALIDATE.HOL.PAYMENT.TYPE>
VALIDATE.HOL.PAYMENT.TYPE:
*** <desc>To validate the Holiday Payment types defined </desc>

    recordId = EB.SystemTables.getIdNew()
    errorDetails = ''
    AA.PaymentSchedule.PaymentScheduleHolPaymentType(recordId, '', rPaySchedule, '', '', '', '', errorDetails)          ;* to validate Holiday Payment Types

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= VALIDATE.HOLIDAY.START.DATE>
VALIDATE.HOLIDAY.START.DATE:
*** <desc>To validate the values given in Start Date </desc>


    recordId = EB.SystemTables.getIdNew()
    effectiveDate = ''
    errorDetails = ''
    rPrevPaySchedule = PREVIOUS.PROP.RECORD
    effectiveDate = AA.Framework.getPropEffDate()
    AA.PaymentSchedule.PaymentScheduleHolidayStartDate(recordId, '', rPaySchedule, rPrevPaySchedule, '', effectiveDate, '', errorDetails)   ;* to validate Holiday Start Date

RETURN
*** </region>


*-----------------------------------------------------------------------------

*** <region name= VALIDATE.HOLIDAY.NUM.PAYMENTS>
VALIDATE.HOLIDAY.NUM.PAYMENTS:
*** <desc>To validate the number of payments given </desc>

    recordId = EB.SystemTables.getIdNew()
    errorDetails = ''
    AA.PaymentSchedule.PaymentScheduleHolNumPayments(recordId, '', rPaySchedule, '', '', '', '', errorDetails)          ;* to validate number of Holiday payments

RETURN
*** </region>

*-----------------------------------------------------------------------------
*** <region name= CHECK.FOR.PAYMENT.TYPES>
*** <desc> Check if calc type varies during change product. If so then delete the calc amount value, if that is updated as part of constant payment type for old product</desc>
CHECK.FOR.CALC.PAYMENT.TYPES:
    
    IF NOT(R.PAYMENT.TYPE<AA.PaymentSchedule.PaymentType.PtCalcType> MATCHES "CONSTANT":@VM:"PROGRESSIVE":@VM:"PERCENTAGE") AND (EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsCalcAmount)<1,EB.SystemTables.getAv(),EB.SystemTables.getAs()> NE "") THEN
        tmp.AV = EB.SystemTables.getAv()
        tmp.AS = EB.SystemTables.getAs()
        tmp = EB.SystemTables.getRNew(AA.PaymentSchedule.PaymentSchedule.PsCalcAmount); tmp<1,tmp.AV,tmp.AS> = "";EB.SystemTables.setRNew(AA.PaymentSchedule.PaymentSchedule.PsCalcAmount,tmp) ;* Clear the calc amount
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PerformRfrValidations>
*** <desc>To perform RFR rates related validations </desc>
PerformRfrValidations:

    PAYMENT.SCHEDULE.REC = ''
    PAYMENT.SCHEDULE.REC = EB.SystemTables.getDynArrayFromRNew()
    AA.PaymentSchedule.PaymentScheduleRfrInterestValidations(PAYMENT.SCHEDULE.REC, SIM.MODE, RFR.PAYMENT.DATES, RFR.PAYMENT.PROPERTIES, RETURN.ERROR)
   
RETURN
*** </region>
*-----------------------------------------------------------------------------
END
