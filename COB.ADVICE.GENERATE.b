* @ValidationCode : MjotNjE1NTk0Mzc5OkNwMTI1MjoxNTU4MDI2NjM1NTY3OmJoYXJhdGhpcmFqYTotMTotMTowOjA6ZmFsc2U6Ti9BOlIxN19BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 16 May 2019 13:10:35
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : bharathiraja
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R17_AMR.0
*---------------------------------------------------------------------------------------------------------------------------------------------
$PACKAGE Cost.Borrowing
*---------------------------------------------------------------------------------------------------------------------------------------------
SUBROUTINE COB.ADVICE.GENERATE(MAT HAND.REC,ERR1.MSG)
*---------------------------------------------------------------------------------------------------------------------------------------------
* Modification History:
*----------------------
* PACS00632635 - Fix for the negative amounts calculated for the total sum.
* PACS00635759 - Fix for the BI index key not passed issue.
* PACS00638242 - Total payment amount that is in XML is not correct
* PACS00643139 - Added logic to consider only ACCOUNT & PRINCIPALINT properties for the payment relates tag mappings.
* PACS00674955 - Need message type 99 to return abbreviated province (eg ON)
* PACS00679380 - Align address fields used in FSD003 output with CAMB address fields
* PACS00675147 - BALANCE tag is not showing correct value for loans which has Change product
* PACS00680196 - Phase1 May Release-Duplicate values are being pulled into XML files
* PACS00695087 - PAYMENTS tag in message 99 should reflect one payment amount only per frequency of payments
* PACS00700319 - Incorrect amounts in Cost Of Borrowing tags
* PACS00695942 - Model Office - L2 CAMB Routines
* PACS00712482 - Address Fields populating incorrectly in COB advice XML
* PACS00713261 - Data tags in COB XML message 99 are not same when numbers are summed from payment schedule
* PACS00740966 - New field introduced to input the Balance Type in DISCLOSURE.PARAMETER and logic changed to get the Principal amount
* PACS00871103 - ARR.GET.BALANCES is used to get the principal amount
* PACS00945928 - BALANCE tag showing incorrect values and next pymt details are wrong in 99 msg
*---------------------------------------------------------------------------------------------------------------------------------------------
* Insert Files:
*--------------
    $USING EB.Template
    $USING EB.SystemTables
    $USING EB.Updates
    $USING AA.Framework
    $USING AA.ProductFramework
    $USING AA.ProductManagement
    $USING AA.Customer
    $USING ST.Customer
    $USING ST.Config
    $USING Cost.Borrowing
    $USING AC.BalanceUpdates
    $USING AA.Interest
    $USING AA.PaymentSchedule
    $USING ST.RateParameters
    $USING AA.TermAmount
    $USING EB.API
    $USING AA.ActivityCharges
    $USING AA.Fees
    $USING AA.ActivityRestriction
    $USING NACUST.Foundation
    $USING DE.Config
    $USING DE.Outward
    $USING ST.CompanyCreation
    $USING Common.RoutinesAndLt
   
*---------------------------------------------------------------------------------------------------------------------------------------------
    GOSUB INITIALIZE                    ;* Intialize the variables that are used across this routine.
    GOSUB CHECK.DISCLOSURE.DETAILS      ;* Read the disclosure parameter table and get the details of given arrangment based on its Product or Product Group.
    GOSUB GET.CUST.CONDITIONS           ;* Get the arrangement customer conditions. if there are multiple customer then obtain the details of each customer.
    GOSUB GET.CUR.BALANCE               ;* Get the outstanding principal amount for the given arrangement.
    GOSUB GET.INTEREST.DETAILS          ;* Get the latest interest record to publish the records needed.
    GOSUB FINAL.PAYMENT.SCHEDULE
    GOSUB GET.TERM.SCHEDULE.DETAILS     ;* Get term and schedule details for given conditions.
    GOSUB GET.CHARGE.DETAILS            ;* Get the charge properties and iterate each to get type of charge they are classified as ACTIVITY.CHARGE/SCHEDULED.CHARGE/BREAK.RULE.CHARGE
    GOSUB COB.CALCULATION               ;* Get the APR value using formula to get the overall rate of interest percent.
    GOSUB FINAL.MAPPING                 ;* Formation of Handoff Record.

RETURN
*---------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= INITIALIZE>
INITIALIZE:
*** <desc>Intialize the variables that are used across this routine. </desc>
    Y.F.FLAG='0'
    Y.ARR.START.DATE1=''
    FREQUENCY = ''
    DUE.AMOUNT.VAL =''
    INT.PROP= ''
    Y.TOT.CAP.AMT= ''
    EXCLUDE.DUE.TYPE =''
    NEXT.PAYMENT.AMT =''
    NEXT.PAYMENT.DATE = ''
    PAY.METHODS = ''
    PROPERTIES  = ''
    AA.PS.DUE.TYPE = ''
    FIRST.PAYMENT = ''
    PAYMENT.SCHEDULE.FREQ = ''
    AVAIL.BAL = 0

    ARR.ID          = AA.Framework.getC_aalocarrid()        ;* Arrangement ID
    ARR.PRD         = AA.Framework.getArrProductId()        ;* Arrangement product
    ARRANGEMENT.REC = AA.Framework.Arrangement.Read(ARR.ID, ERR.DETS) ;* Obtain arrangement record
    ARR.PRD.GRP     = ARRANGEMENT.REC<AA.Framework.Arrangement.ArrProductGroup> ;* Arrangement product group
    ACCOUNT.NO      = AA.Framework.getC_aaloclinkedaccount()          ;* Arrangement account
    EFFECTIVE.DATE  = AA.Framework.getActivityEffDate()     ;* Activity effective date
    Y.TODAY         = EFFECTIVE.DATE
    PRODUCT.RECORD  = AA.Framework.getProductRecord()       ;* Arrangement product record

* Get arrangement customer details
    AA.ProductFramework.GetPropertyRecord("", ARR.ID, "", "", "CUSTOMER", "", CUSTOMER.RECORD, RECORD.ERROR)

* Get arrangement schedule conditions
    AA.ProductFramework.GetPropertyRecord("", ARR.ID, "", "", "PAYMENT.SCHEDULE", "", PS.RECORD, RECORD.ERROR)

* Get arrangement Term conditions
    AA.ProductFramework.GetPropertyRecord("", ARR.ID, "", "", "TERM.AMOUNT", "", TERM.RECORD, RECORD.ERROR)

*** Read arrangement account details, which stores the key values pertain to arrangement.
    ARR.ACCT.DETS   = AA.PaymentSchedule.AccountDetails.Read(ARR.ID, ERR)
    PS.START.DATE   = ARR.ACCT.DETS<AA.PaymentSchedule.AccountDetails.AdPaymentStartDate> ;* Arrangement start date
    ARR.START.DATE  = ARRANGEMENT.REC<AA.Framework.Arrangement.ArrStartDate>
    ARR.RP.END.DATE = ARR.ACCT.DETS<AA.PaymentSchedule.AccountDetails.AdReportEndDate>
    Y.LAST.END.DATE = ARR.ACCT.DETS<AA.PaymentSchedule.AccountDetails.AdLastRenewDate,1>


    LRFAPPLS = 'DE.ADDRESS'
    LRFNAMES = 'ADDRESS':@VM:'CITY':@VM:'ADDR.CNTRY.ID':@VM:'US.STATE'
    FLD.POS  = ''

    EB.Updates.MultiGetLocRef(LRFAPPLS,LRFNAMES,FLD.POS)
    ADDR.POS   =  FLD.POS<1,1>
    CITY.POS    = FLD.POS<1,2>
    CNTRY.POS   = FLD.POS<1,3>
    STATE.POS   = FLD.POS<1,4>

    CHRG.FLAG = 'N'
RETURN
*** </region>

*---------------------------------------------------------------------------------------------------------------------------------------------
FINAL.PAYMENT.SCHEDULE:
*----------------------
    AA.PaymentSchedule.GetBillType("PAYMENT", BillType, ReturnError)

    PAY.BILL.TYPE   = PS.RECORD<AA.PaymentSchedule.PaymentSchedule.PsBillType>
    PAY.PAY.TYPE    = PS.RECORD<AA.PaymentSchedule.PaymentSchedule.PsPaymentType>
    PAY.METHOD.TYPE = PS.RECORD<AA.PaymentSchedule.PaymentSchedule.PsPaymentMethod>
    PAY.PROPERTIES  = PS.RECORD<AA.PaymentSchedule.PaymentSchedule.PsProperty>
    PAY.DUE.FREQ    = PS.RECORD<AA.PaymentSchedule.PaymentSchedule.PsPaymentFreq>
    PAY.START.DATE  = PS.RECORD<AA.PaymentSchedule.PaymentSchedule.PsStartDate>
    PAY.END.DATE    = PS.RECORD<AA.PaymentSchedule.PaymentSchedule.PsEndDate>

RETURN
*----------------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= FINAL.MAPPING>
FINAL.MAPPING:
**** <desc>Formation of Handoff Record. </desc>

    NEXT.PAYMENT.AMT  = Y.NEXT.PAYMENT.AMOUNT
    NEXT.PAYMENT.DATE = Y.NEXT.PAYMENT.DATE
    FREQUENCY         = Y.AA.PAY.FREQ
    FIRST.PAYMENT     = Y.FIRST.PAYMENT.DATE

    HAND.REC(9)<2> = GLCUSTOMER
    HAND.REC(9)<3> = CUSTOMER.ROLE
    HAND.REC(9)<1> = ACCOUNT.NO
    HAND.REC(9)<4> = CUS.NAME
    HAND.REC(9)<5> = STREET
    HAND.REC(9)<6> = ADDRESS
    HAND.REC(9)<7> = CITY
    HAND.REC(9)<8> = STATE.PRO
    HAND.REC(9)<9> = POSTAL.CODE
    HAND.REC(9)<10> = AVAIL.BAL         ;* Current principal amount
    HAND.REC(9)<11> = EFFECTIVE.RATE    ;* actual interest rate
    HAND.REC(9)<12> = RATE.INDEX        ;* If Periodic interest, get the rate index
    HAND.REC(9)<13> = FLOATING.INDEX    ;* If floating interest get floating index
    HAND.REC(9)<14> = DET.INTEREST.1    ;* get the actual interest if periodic or floating else null.
    HAND.REC(9)<15> = MARGIN.OPERAND
    HAND.REC(9)<16> = MARGIN.RATE
    HAND.REC(9)<17> = APR     ;* Actual Annual percent rate
    HAND.REC(9)<18> = TERM    ;* Remaining loan term
    HAND.REC(9)<19> = NEXT.PAYMENT.AMT
    HAND.REC(9)<20> = FREQUENCY         ;* get the payment frequency from PS property.
    HAND.REC(9)<21> = NEXT.PAYMENT.DATE
    HAND.REC(9)<23> = AMORT.TERM        ;* Actual loan term
    HAND.REC(9)<24> = EFFECTIVE.RATE
    HAND.REC(9)<25> = FINAL.PAYMENT.AMT ;* Payment amount on Maturity date.
    HAND.REC(9)<26> = TOTAL.AMOUNT
    HAND.REC(9)<27> = TOT.INT.AMT
    HAND.REC(9)<28> = COB.CHARGE.AMT    ;* charge amounts of those charge categorized as COB fees
    HAND.REC(9)<29> = AVG.OUTSTANDING.AMT         ;* Average princiapl paid
    HAND.REC(9)<30> = OPT.CHARGE.AMT    ;* charge amounts of those charge categorized as OPTIONAL fees
    HAND.REC(9)<31> = COB.CHARGE.AMT    ;* charge amounts of those charge categorized as COB fees
    HAND.REC(9)<32> = PROV.CHARGE.AMT   ;* charge amounts of those charge categorized as PROVINCE fees
    HAND.REC(9)<33> = COUNTRY.VAL       ;* Country.
    HAND.REC(9)<34> = TOWN.CNTRY        ;* Town country value.
    HAND.REC(9)<35> = CHRG    ;* Charge properties attached to the Disclosure parameter
    HAND.REC(9)<36> = CHRG.TRIGGER      ;* Activities that trigger the charges
    HAND.REC(9)<37> = CHARGE.CALC.TYPE  ;* Charge Calc type
    HAND.REC(9)<38> = CHRG.AMT          ;* Charge amount
    HAND.REC(9)<39> = CHRG.RATE         ;* Charge RATE
    HAND.REC(9)<40> = CALC.TIER.TYPE    ;* Calc Tier Type
    HAND.REC(9)<41> = TIER.MIN.CHRG     ;* Tier Min charge
    HAND.REC(9)<42> = TIER.MAX.CHRG     ;* Tier Max charge
    HAND.REC(9)<43> = TIER.AMT          ;* TierAmount
    HAND.REC(9)<44> = FIXED.AMT         ;* Fixed Amount
    HAND.REC(9)<45> = FIRST.PAYMENT

RETURN
*** </region>

*---------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= GET.CUST.CONDITIONS>
GET.CUST.CONDITIONS:
*** <desc>Get the arrangement customer conditions. if there are multiple customer then obtain the details of each customer. </desc>
    GLCUSTOMER      = CUSTOMER.RECORD<AA.Customer.Customer.CusCustomer>
    CUSTOMER.ROLE   = CUSTOMER.RECORD<AA.Customer.Customer.CusCustomerRole>
    CUSTOMER.COUNT  = DCOUNT(GLCUSTOMER, @VM)

*** For an arrangement, there can be multiple customers with different role.
*** Get all customer and display each with the respective roles under the XML.
    CARRIER.HDR = 'PRINT.1'
    CUS.CNT = 1
    LOOP
    WHILE CUS.CNT LE CUSTOMER.COUNT
        CUR.CUSTOMER = GLCUSTOMER<1,CUS.CNT>
        R.CUSTOMER              = ST.Customer.Customer.Read(CUR.CUSTOMER, CUS.ERR)        ;* Read the given customer record
        CUS.COMPANY  = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComCustomerCompany)
        CUST.KEY     = CUS.COMPANY:'.C-':CUR.CUSTOMER:'.': CARRIER.HDR
        R.ADDRESS = DE.Config.Address.Read(CUST.KEY, YERR)
        CUS.NAME<1,CUS.CNT>     = R.CUSTOMER<ST.Customer.Customer.EbCusNameOne>
        STREET<1,CUS.CNT>       = R.ADDRESS<DE.Config.Address.AddStreetAddress>
        ADDRESS<1,CUS.CNT>      = R.ADDRESS<DE.Config.Address.AddLocalRef,ADDR.POS>
        TOWN.CNTRY<1,CUS.CNT>   = R.ADDRESS<DE.Config.Address.AddTownCounty>
        CITY<1,CUS.CNT>         = R.ADDRESS<DE.Config.Address.AddLocalRef,CITY.POS>
        RES.REGION<1,CUS.CNT>   = R.CUSTOMER<ST.Customer.Customer.EbCusResidenceRegion>
        REGION.REC              = ST.Config.Region.Read(RES.REGION, ERROR)      ;* Read the region table to get the region related data.
        REG.NAME<1,CUS.CNT>     = REGION.REC<ST.Config.Region.EbRegRegionName>
        STATE.PRO<1,CUS.CNT>    = R.ADDRESS<DE.Config.Address.AddLocalRef,STATE.POS>
        STATE.REC               = NACUST.Foundation.UsState.Read(STATE.PRO, ERROR)        ;* Read the US.STATE table and get the description value
        STATE.PROV<1,CUS.CNT>   = STATE.REC<NACUST.Foundation.UsState.UsStDescription>
        POSTAL.CODE<1,CUS.CNT>  = R.ADDRESS<DE.Config.Address.AddPostCode>
        COUNTRY<1,CUS.CNT>      = R.ADDRESS<DE.Config.Address.AddLocalRef,CNTRY.POS>
        COUNTRY.NAME            = ST.Config.Country.Read(COUNTRY, ERROR)        ;*read the COUNTRY table and get the description value
        COUNTRY.VAL<1,CUS.CNT>  = COUNTRY.NAME<ST.Config.Country.EbCouCountryName,1>
        CUS.CNT = CUS.CNT + 1
    REPEAT

RETURN
*** </region>

*---------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= CHECK.DISCLOSURE.DETAILS>
CHECK.DISCLOSURE.DETAILS:
    INTEREST.PROPERTY = ''
*** <desc>Read the disclosure parameter table and get the details of given arrangment based on its Product or Product Group. </desc>
    ARR.PRD.REC = Cost.Borrowing.DisclosureParameter.Read(ARR.PRD, Error)       ;* Get product record.
    ARR.GRP.REC = Cost.Borrowing.DisclosureParameter.Read(ARR.PRD.GRP, Error)   ;* Get product group record.

*** Obtain the charges to be collected based on priority AA.PRODUCT>AA.PRODUCTGROUP>SYSTEM
    BEGIN CASE
        CASE ARR.PRD.REC          ;* If arrangement product is available
            COB.CHARGES     = ARR.PRD.REC<Cost.Borrowing.DisclosureParameter.ParameterCobFee>
            PROV.CHARGES    = ARR.PRD.REC<Cost.Borrowing.DisclosureParameter.ParameterProvFee>
            OPT.CHARGES     = ARR.PRD.REC<Cost.Borrowing.DisclosureParameter.ParameterOptService>
            LOC.CHECK       = ARR.PRD.REC<Cost.Borrowing.DisclosureParameter.ParameterLocProduct>
            Y.EXCLUDE.PAY.TYPE    = ARR.PRD.REC<Cost.Borrowing.DisclosureParameter.ParameterExclPayType>       ;* Intpay Type added to check for only one interest payment type to be reported for cost borrowing
            INTEREST.PROPERTY = ARR.PRD.REC<Cost.Borrowing.DisclosureParameter.ParameterLoanIntProp>
            SCHEDULE.RTN = ARR.PRD.REC<Cost.Borrowing.DisclosureParameter.ParameterScheduleRtn>                ;* fetching value from field SCHEDULE.RTN
            PRINCIPAL.BALANCE.TYPE = ARR.PRD.REC<Cost.Borrowing.DisclosureParameter.ParameterPrinBalType>     ;* fetching value from field PRIN.BAL.TYPE
			Y.EXCLUDE.NEXT.PYMT = ARR.PRD.REC<Cost.Borrowing.DisclosureParameter.ParameterExclNextPayment>
            
        CASE ARR.GRP.REC          ;* If arrangement product group is available.
            COB.CHARGES     = ARR.GRP.REC<Cost.Borrowing.DisclosureParameter.ParameterCobFee>
            PROV.CHARGES    = ARR.GRP.REC<Cost.Borrowing.DisclosureParameter.ParameterProvFee>
            OPT.CHARGES     = ARR.GRP.REC<Cost.Borrowing.DisclosureParameter.ParameterOptService>
            LOC.CHECK       = ARR.GRP.REC<Cost.Borrowing.DisclosureParameter.ParameterLocProduct>
            Y.EXCLUDE.PAY.TYPE    = ARR.GRP.REC<Cost.Borrowing.DisclosureParameter.ParameterExclPayType>       ;* Intpay Type added to check for only one interest payment type to be reported for cost borrowing
            INTEREST.PROPERTY = ARR.GRP.REC<Cost.Borrowing.DisclosureParameter.ParameterLoanIntProp>
            SCHEDULE.RTN = ARR.GRP.REC<Cost.Borrowing.DisclosureParameter.ParameterScheduleRtn>                ;* fetching value from field SCHEDULE.RTN
            PRINCIPAL.BALANCE.TYPE = ARR.GRP.REC<Cost.Borrowing.DisclosureParameter.ParameterPrinBalType>     ;* fetching value from field PRIN.BAL.TYPE
			Y.EXCLUDE.NEXT.PYMT = ARR.GRP.REC<Cost.Borrowing.DisclosureParameter.ParameterExclNextPayment>
            
        CASE 1          ;* If none of the above mentioned, get the default values that are present under SYSTEM.

            SYS.REC         = Cost.Borrowing.DisclosureParameter.Read('SYSTEM', Error)
            COB.CHARGES     = SYS.REC<Cost.Borrowing.DisclosureParameter.ParameterCobFee>
            PROV.CHARGES    = SYS.REC<Cost.Borrowing.DisclosureParameter.ParameterProvFee>
            OPT.CHARGES     = SYS.REC<Cost.Borrowing.DisclosureParameter.ParameterOptService>
            LOC.CHECK       = SYS.REC<Cost.Borrowing.DisclosureParameter.ParameterLocProduct>
            Y.EXCLUDE.PAY.TYPE    = SYS.REC<Cost.Borrowing.DisclosureParameter.ParameterExclPayType> ;* Intpay Type added to check for only one interest payment type to be reported for cost borrowing
            INTEREST.PROPERTY = SYS.REC<Cost.Borrowing.DisclosureParameter.ParameterLoanIntProp>
            SCHEDULE.RTN = SYS.REC<Cost.Borrowing.DisclosureParameter.ParameterScheduleRtn>          ;* fetching value from field SCHEDULE.RTN
            PRINCIPAL.BALANCE.TYPE = SYS.REC<Cost.Borrowing.DisclosureParameter.ParameterPrinBalType>     ;* fetching value from field PRIN.BAL.TYPE
			Y.EXCLUDE.NEXT.PYMT = SYS.REC<Cost.Borrowing.DisclosureParameter.ParameterExclNextPayment>
            
    END CASE
    
    
RETURN

*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= GET.CUR.BALANCE>
GET.CUR.BALANCE:
*** <desc>Get the outstanding principal amount for the given arrangement. </desc>
*** Check the account property of the arrangement.
    AA.ProductFramework.GetPropertyName(PRODUCT.RECORD, "ACCOUNT", ACCOUNT.PROPERTY)

** Now get the available balance for the balance type

    ERR.MSG = ''
    BAL.DETAILS = ''          ;* The current balance figure
    DATE.OPTIONS = ""
    DATE.OPTIONS<2> = "ALL"   ;* Include all unauthorised movements
    ACCOUNT.ID = AA.Framework.getLinkedAccount()
*** Use the core API to get the current principal amount as on the activity effective date.
    IF PRINCIPAL.BALANCE.TYPE THEN
           Common.RoutinesAndLt.ArrGetBalances(ARR.ID,PRINCIPAL.BALANCE.TYPE,EFFECTIVE.DATE,BAL.DETAILS,ERR.MSG)
           AVAIL.BAL = ABS(BAL.DETAILS)
    END
RETURN
*** </region>

*---------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= GET.INTEREST.DETAILS>
GET.INTEREST.DETAILS:
    IF INTEREST.PROPERTY NE '' THEN
        AA.ProductFramework.GetPropertyRecord("", ARR.ID, INTEREST.PROPERTY, "", "", "", INTEREST.RECORD, RECORD.ERROR)
    END
    
    AA.ARR.INT.PROPERTY.CLASS='INTEREST'
    
    AA.PRODUCT.RECORD = PRODUCT.RECORD
    AA.ARR.INT.PROPERTY = ''
    
*   CALL AA.GET.PROPERTY.NAME(AA.PRODUCT.RECORD, AA.ARR.INT.PROPERTY.CLASS, AA.ARR.INT.PROPERTY)
    AA.ProductFramework.GetPropertyName(AA.PRODUCT.RECORD, AA.ARR.INT.PROPERTY.CLASS, AA.ARR.INT.PROPERTY)
    
    INTEREST.PROPERTIES = AA.ARR.INT.PROPERTY
    CCY = AA.Framework.getArrCurrency()

    RATE.IND = INTEREST.RECORD<AA.Interest.Interest.IntPeriodicIndex>

    FLOATING.IND = INTEREST.RECORD<AA.Interest.Interest.IntFloatingIndex>

    BEGIN CASE
        CASE RATE.IND
            DET.INTEREST = INTEREST.RECORD<AA.Interest.Interest.IntPeriodicRate>
        CASE FLOATING.IND
            BI.INDEX = FLOATING.IND:CCY:EFFECTIVE.DATE
            BI.INDEX = FIELD(BI.INDEX,'.',1)
            ST.RateParameters.EbGetInterestRate(BI.INDEX, INTEREST.RATE)
            DET.INTEREST = INTEREST.RATE
    END CASE

    RATE.INDEX<1,-1> = RATE.IND
    FLOATING.INDEX<1,-1> = FLOATING.IND
    DET.INTEREST.1<1,-1> = DET.INTEREST
    MARGIN.OPERAND<1,-1> = INTEREST.RECORD<AA.Interest.Interest.IntMarginOper>
    MARGIN.RATE<1,-1> = INTEREST.RECORD<AA.Interest.Interest.IntMarginRate>
    EFFECTIVE.RATE<1,-1> = INTEREST.RECORD<AA.Interest.Interest.IntEffectiveRate>


RETURN

*** </region>

*---------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= GET.TERM.SCHEDULE.DETAILS>
GET.TERM.SCHEDULE.DETAILS:
*** <desc>Get term and schedule details for given conditions. </desc>

* PACS00643139 - Declarign the loop variables as null to avoid reiterating the old values.


    MATURITY.DATE = TERM.RECORD<AA.TermAmount.TermAmount.AmtMaturityDate>       ;* Arrangement Maturity Date
    Y.MATURITY.DATE =MATURITY.DATE
    IF MATURITY.DATE NE ARR.RP.END.DATE THEN
        MATURITY.DATE = ARR.RP.END.DATE
    END
*** Get the total term of the arrangement. Consider amortization period as primanry condition,
*** On non availability of amort period, get actual term from payment schedule.
    AMORT.TERM = PS.RECORD<AA.PaymentSchedule.PaymentSchedule.PsAmortisationTerm>
    IF AMORT.TERM ELSE
        AMORT.TERM = TERM.RECORD<AA.TermAmount.TermAmount.AmtTerm>
    END

    IF AMORT.TERM THEN        ;* To avoid returning 0M for LOC products.
        CALL EB.NO.OF.MONTHS(ARR.START.DATE, Y.MATURITY.DATE, U.NO.OF.MONTHS2)
        AMORT.TERM = U.NO.OF.MONTHS2:'M'
    END
    GOSUB GET.REMAINING.TERM  ;* Calculate based on the maturity date and given date to obtain remianing term

* PACS00643139 - End - Added logic to consider only ACCOUNT & PRINCIPALINT properties for the payment relates tag mappings.

*** Call payment schedule projector to get the property amounts and outstanding balance amount on end of each schedule
    GOSUB BUILD.DATES
    FINAL.PAYMENT.AMT = ABS(FINAL.PAYMENT.AMT)
    GOSUB GET.AVG.BALANCE     ;* Get the entire interest amount paid as well as average amount paid during the life time of arrangement.

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= Build Dates>
*** <desc>Build date for each of the properties</desc>
BUILD.DATES:
*** Call build dates to retrive the next payment date and payment amount.
*** Get the payment schedule property to get the payment amount, dates related.

    START.DATE = ARR.START.DATE
    IF Y.LAST.END.DATE THEN
        Y.AA.ST.DATE = Y.LAST.END.DATE
    END ELSE
        Y.AA.ST.DATE = START.DATE
    END

    Y.FINAL.SCHEDULE.PROJ = Y.AA.ST.DATE:@FM:MATURITY.DATE

    ARR.ID = HAND.REC(2)<AA.Framework.ArrangementActivity.ArrActArrangement>
    LANG.ID = HAND.REC(4)<8>  ;*Need to replace the property names by description in corresp language
    CYCLE.DATE = ''
    DUE.DATES = ''  ;* Holds the list of Schedule due dates
    DUE.TYPES = ''  ;* Holds the list of Payment Types for the above dates
    DUE.TYPE.AMTS = ''        ;* Holds the Payment Type amounts
    DUE.PROPS = ''  ;* Holds the Properties due for the above type
    DUE.PROP.AMTS = ''        ;* Holds the Property Amounts for the Properties above
    DUE.OUTS = ''   ;* Oustanding Bal for the date
    DUE.METHODS = ''
    NO.RESET = ''
    NO.RESET<1> = "YES"
    NO.RESET<3> = 1 ;* Flag to indicate the schdule projector calls from delivery mapping routine for advices

** If Schedule routine is updated in DISCLOSURE.PARAMETER table, then use it for fetching payment schedule, else proceed with existing logic
    IF SCHEDULE.RTN THEN
        CALL @SCHEDULE.RTN(ARR.ID, "", NO.RESET, Y.FINAL.SCHEDULE.PROJ, TOT.PAYMENT, DUE.DATES, "", DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)      ;* Routine to Project complete schedules
    END ELSE
        AA.PaymentSchedule.ScheduleProjector(ARR.ID, "", NO.RESET, Y.FINAL.SCHEDULE.PROJ, TOT.PAYMENT, DUE.DATES, "", DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)
    END

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= GET.REMAINING.TERM>
GET.REMAINING.TERM:
*** <desc>Calculate based on the maturity date and given date to obtain remianing term </desc>
*** Get the remaining term of the contract.

* PACS00643139 - Excluding the TERM & maturity part for the LOC products.
    TERM = ''
    Y.REMAINING.TERM=''
    IF MATURITY.DATE THEN
        EB.API.MatDateEnrichment(MATURITY.DATE, EFFECTIVE.DATE, DIFF)
        DIFF = EREPLACE(DIFF,' ','')
        YEARS = FIELD(DIFF,'Years',1)
        MONTHS = FIELD(DIFF, 'Years',2)
        MONTHS = FIELD(MONTHS,'Months',1)
        IF MONTHS EQ '' THEN
            MONTHS = FIELD(DIFF,'Months',1)
        END
        IF NOT(MONTHS) THEN
            MONTHS = 0
        END

        Y.YR = YEARS * 12
        Y.TOTAL = Y.YR + MONTHS

* PACS00643139 - Express remianing term in terms months.
        TERM = Y.TOTAL
    END



    CALL EB.NO.OF.MONTHS(EFFECTIVE.DATE,MATURITY.DATE,Y.NO.OF.MONTHS)


    Y.REMAINING.TERM = Y.NO.OF.MONTHS/12

RETURN
*** </region>

*---------------------------------------------------------------------------------------------------------------------------------------------

*** <region name= GET.AVG.BALANCE>
GET.AVG.BALANCE:
    Y.NEXT.PAYMENT.DATE =  ''
    Y.NEXT.PAYMENT.AMOUNT= ''
    Y.AA.PAY.FREQ = ''
    Y.FINAL.AA.PROP =''
    Y.FINAL.MAURITY.AMT1 =''
    Y.FINAL.MAURITY.AMT=''

*** <desc>Get the entire interest amount paid as well as average amount paid during the life time of arrangement. </desc>
    Y.AA.PAY.FREQ =''
    MAT.POS = ''
    LOCATE MATURITY.DATE IN DUE.DATES BY "AR" SETTING MAT.POS ELSE
        MAT.POS -= 1
    END
    
    MAT.POS1 = ''
    Y.FINAL.MAT.POS =''
    PAYMENT.END.DATE = ARR.ACCT.DETS<AA.PaymentSchedule.AccountDetails.AdPaymentEndDate>
    LOCATE PAYMENT.END.DATE IN DUE.DATES SETTING MAT.POS1 THEN
        Y.FINAL.MAT.POS = MAT.POS1-1
    END


    DUE.DATE.CNT = DCOUNT(DUE.DATES,@FM)
    DUE.CNT = 1
    LOOP
    WHILE DUE.CNT LE DUE.DATE.CNT
        DUE.DATE.VAL = FIELD(DUE.DATES,@FM,DUE.CNT)
        IF DUE.DATE.VAL LE MATURITY.DATE AND DUE.DATE.VAL GE EFFECTIVE.DATE THEN

            DUE.VAL<-1> = DUE.DATE.VAL
            DUE.OUTS.VAL<-1> = FIELD(DUE.OUTS,@FM,DUE.CNT)
            TOTAL.OUTSTANDING.AMT +=DUE.OUTS<DUE.CNT>
            Y.CAL.FLAG ='1'
            Y.AA.PAYMENT.DATE  = ''
            Y.AA.PAYMENT.AMOUNT = ''
            
            GOSUB VALIDATE.SCHEDULES

            TOT.INT.AMT =  Y.TOT.INT.AMT
            Y.TOT.CAPL.AMT = Y.TOT.CAPITAL.AMT
            TOTAL.AMOUNT.TEST = Y.TOTAL.AMOUNT.TEST
            TOTAL.AMOUNT = Y.TOTAL.AMOUNT
            IF NOT(Y.NEXT.PAYMENT.DATE) THEN
                Y.NEXT.PAYMENT.DATE =  Y.AA.PAYMENT.DATE
                Y.NEXT.PAYMENT.AMOUNT= Y.AA.PAYMENT.AMOUNT
                Y.AA.PAY.FREQ = PAYMENT.SCHEDULE.FREQ
                Y.FINAL.AA.PROP = Y.AA.FINAL.PROPERTY

            END

            IF DUE.CNT EQ MAT.POS THEN

                FINAL.PAYMENT.AMT.CHECK=Y.FINAL.MAURITY.AMT
                
            END
        END ELSE

            IF DUE.DATE.VAL GE Y.AA.ST.DATE AND DUE.DATE.VAL LE EFFECTIVE.DATE THEN

                Y.AA.PAYMENT.DATE  = ''
                Y.AA.PAYMENT.AMOUNT = ''
                IF NOT(Y.FIRST.PAYMENT.DATE) THEN
                    Y.CAL.FLAG = ''
                    GOSUB VALIDATE.SCHEDULES
                    Y.FIRST.PAYMENT.DATE =  Y.AA.PAYMENT.DATE
                    Y.FIRST.PAYMENT.AMOUNT = Y.AA.PAYMENT.AMOUNT
                END
            END
        END
        DUE.CNT +=1
    REPEAT


    IF Y.MATURITY.DATE NE ARR.RP.END.DATE THEN    ; * If loan has change product, maturity date is considered as REPORT.END.DATE in AA.ACCOUNT.DETAILS
        FINAL.PAYMENT.AMT + = DUE.OUTS<MAT.POS>
    END ELSE
		***Outstanding balance i.e. zero to be fetched instead of pending payment amount on maturity date
        FINAL.PAYMENT.AMT = 0
    END

    IF NOT(FINAL.PAYMENT.AMT) AND FINAL.PAYMENT.AMT EQ '' THEN
        FINAL.PAYMENT.AMT += DUE.OUTS<Y.FINAL.MAT.POS>
    END

    FINAL.PAYMENT.AMT = ABS(FINAL.PAYMENT.AMT)

    TOT.SCHEDULE = DCOUNT(DUE.VAL,@FM)

*** To calculate the average balance amount, we must not consider the last payment period.
    LOCATE "0" IN DUE.OUTS.VAL SETTING OUT.POS THEN
        IF OUT.POS GT 1 THEN  ;* To avoid divide by zero exception for the outstanding amount calculation.
            TOT.SCHEDULE = OUT.POS - 1  ;* Not considering the final payment schedule.
        END
    END

    AVG.OUTSTANDING.AMT = DROUND(ABS(TOTAL.OUTSTANDING.AMT/TOT.SCHEDULE),2)

    IF NOT(Y.FIRST.PAYMENT.DATE) THEN
        Y.FIRST.PAYMENT.DATE = Y.NEXT.PAYMENT.DATE
        Y.FIRST.PAYMENT.AMOUNT = Y.NEXT.PAYMENT.AMOUNT

    END

RETURN
*** </region>


VALIDATE.PAY.METHOD:

    Y.PAY.CT ='1'
    Y.PAY.CNT = DCOUNT(Y.DUE.PAY.METHOD,@SM)
    LOOP
    WHILE Y.PAY.CT LE Y.PAY.CNT
        AA.PAY.METHOD = Y.DUE.METHODS<1,Y.DUE.CT,Y.PAY.CT>
        AA.PAY.PROPERTY= Y.DUE.PROPS<1,Y.DUE.CT,Y.PAY.CT>
        AA.PAY.PROPERTY.AMT= Y.DUE.PROPER.AMTS<1,Y.DUE.CT,Y.PAY.CT>
        IF Y.CAL.FLAG THEN
            LOCATE AA.DUE.TYPE IN Y.EXCLUDE.PAY.TYPE<1,1> SETTING Y.EX.POS ELSE
                LOCATE AA.PAY.PROPERTY IN INTEREST.PROPERTIES SETTING Y.AA.INT.POS THEN
                    Y.TOT.INT.AMT +=  AA.PAY.PROPERTY.AMT
                    IF AA.PAY.METHOD EQ 'CAPITALISE' THEN
                        Y.TOT.CAPITAL.AMT += AA.PAY.PROPERTY.AMT
                    END
                END

                Y.TOTAL.AMOUNT.TEST<-1> =  AA.PAY.PROPERTY.AMT
                Y.TOTAL.AMOUNT +=  AA.PAY.PROPERTY.AMT

                IF DUE.CNT EQ MAT.POS THEN
                    Y.FINAL.MAURITY.AMT +=AA.PAY.PROPERTY.AMT
                END

            END
        END
		***New field EXCL.NEXT.PAYMENT added in disclosure param to capture payment types to be ignored while fetching next pymt details
		***Locate the pymt type in above configured field if not matches then proceed else skip below process
        IF AA.PAY.METHOD EQ 'DUE' THEN
			LOCATE AA.DUE.TYPE IN Y.EXCLUDE.NEXT.PYMT<1,1> SETTING EXCL.POS ELSE
				IF PAYMENT.SCHEDULE.FREQ THEN
					Y.AA.PAYMENT.SCHEDULE = PAYMENT.SCHEDULE.FREQ
					Y.AA.FINAL.PROPERTY = Y.AA.PAY.PROP
					Y.AA.PAYMENT.DATE =Y.DUE.DATES
					Y.AA.PAYMENT.AMOUNT+=AA.PAY.PROPERTY.AMT
				END
			END
        END

        Y.PAY.CT = Y.PAY.CT + 1
    REPEAT
RETURN


VALIDATE.SCHEDULES:
    Y.DUE.DATES= DUE.DATE.VAL
    Y.DUE.TYPES = DUE.TYPES<DUE.CNT>
    Y.DUE.METHODS = DUE.METHODS<DUE.CNT>
    Y.DUE.PROPS =  DUE.PROPS<DUE.CNT>
    Y.DUE.PROPER.AMTS =DUE.PROP.AMTS<DUE.CNT>
            
            
    Y.DUE.CT='1'
    Y.DUE.CNT = DCOUNT(Y.DUE.TYPES,@VM)
    LOOP
    WHILE Y.DUE.CT LE Y.DUE.CNT
        AA.DUE.TYPE=Y.DUE.TYPES<1,Y.DUE.CT>

        LOCATE AA.DUE.TYPE IN PAY.PAY.TYPE<1,1> SETTING AA.PS.POS THEN

            PAYMENT.SCHEDULE.FREQ = PAY.DUE.FREQ<1,AA.PS.POS>
            Y.AA.PAY.PROP=PAY.PROPERTIES<1,AA.PS.POS>

            Y.AA.BILL.TYPE =  PAY.BILL.TYPE<1,AA.PS.POS>
            LOCATE Y.AA.BILL.TYPE IN BillType<1,1> SETTING AA.BILL.POS THEN
             
                Y.DUE.PAY.METHOD = Y.DUE.METHODS<1,Y.DUE.CT>
                GOSUB VALIDATE.PAY.METHOD
            END
        END
        Y.DUE.CT = Y.DUE.CT +1
            
    REPEAT
            
RETURN
*---------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= GET.CHARGE.DETAILS>
GET.CHARGE.DETAILS:

*** <desc>Get the charge properties and iterate each to get type of charge they are classified as ACTIVITY.CHARGE/SCHEDULED.CHARGE/BREAK.RULE.CHARGE</desc>
*** Get all charge proepties of the arrangement.
    AA.ProductFramework.GetPropertyName(PRODUCT.RECORD, "CHARGE", CHARGE.PROPERTIES)
*** Get activity charges conditions of the arrangement.
    AA.ProductFramework.GetPropertyRecord('', ARR.ID, "", "", "ACTIVITY.CHARGES", "", ACT.CHARGE.RECORD, RECORD.ERROR)
    ACT.CHARGE.PROPERTIES = ACT.CHARGE.RECORD<AA.ActivityCharges.ActivityCharges.ActChgCharge>      ;* get all properties and its related activities.
    ACT.CHARGE.ACTIVITIES = ACT.CHARGE.RECORD<AA.ActivityCharges.ActivityCharges.ActChgActivityId>

    ACT.CHRG.CNT = DCOUNT(ACT.CHARGE.PROPERTIES,@VM)
    ACT.CHG = 1
    LOOP
    WHILE ACT.CHG LE ACT.CHRG.CNT
        ACT.CHRG = FIELD(ACT.CHARGE.PROPERTIES,@VM,ACT.CHG)
        ACT.CHRG.SM = DCOUNT(ACT.CHRG,@SM)
        CHANGE @SM TO @VM IN ACT.CHRG
        ACT.SM = 1
        LOOP
        WHILE ACT.SM LE ACT.CHRG.SM
            ACT.CHRG.PROP<1,-1> = FIELD(ACT.CHARGE.ACTIVITIES,@VM,ACT.CHG)
            ACT.SM +=1
        REPEAT
        ACT.CHG +=1
    REPEAT
    ACT.CHARGE.ACTIVITIES = ACT.CHRG.PROP

***
    CONVERT @SM TO @VM IN ACT.CHARGE.PROPERTIES
    CONVERT @SM TO @VM IN ACT.CHARGE.ACTIVITIES
*** Get activity restrictions conditions of the arrangemnt
    AA.ProductFramework.GetPropertyRecord('', ARR.ID, "", "", "ACTIVITY.RESTRICTION", "", ACT.RES.RECORD, RECORD.ERROR)
    ACT.RES.PROPERTIES = ACT.RES.RECORD<AA.ActivityRestriction.ActivityRestriction.AcrProperty>
    ACT.RES.ACTIVITIES = ACT.RES.RECORD<AA.ActivityRestriction.ActivityRestriction.AcrActivityId>
*** Get the source balance type and property from product level.
    SOURCE.TYPE = PRODUCT.RECORD<AA.ProductManagement.ProductDesigner.PrdSourceType>
    SOURCE.BAL = PRODUCT.RECORD<AA.ProductManagement.ProductDesigner.PrdSourceBalance>
    SOURCE.PROP = PRODUCT.RECORD<AA.ProductManagement.ProductDesigner.PrdCalcProperty>
    TMP.CHARGE.PROPERIES = CHARGE.PROPERTIES
*** get the charge amount and activity via this charge is calculated and triggered.
*** to get the all charge amount use AA.CHARGE.DETAILS table.
    CONVERT @FM TO @VM IN CHARGE.PROPERTIES
    IF COB.CHARGES THEN
        CHARGE.PROP.DIS.PARAM<1,-1> = COB.CHARGES
    END
    IF PROV.CHARGES THEN
        CHARGE.PROP.DIS.PARAM<1,-1> = PROV.CHARGES
    END
    IF OPT.CHARGES THEN
        CHARGE.PROP.DIS.PARAM<1,-1> = OPT.CHARGES
    END
    
    INT.CHG.CNT = 1
    DCNT.CHARGE.DIS = DCOUNT(CHARGE.PROP.DIS.PARAM,VM)
    LOOP
    WHILE INT.CHG.CNT LE DCNT.CHARGE.DIS
*** Under advice level need to project the activities that induced the charges. Display only its descrptions.
        CHARGE.PROP = CHARGE.PROP.DIS.PARAM<1,INT.CHG.CNT>
        CHARGE.AMTS = ''
        CHARGE.METHODS = ''
        BEGIN CASE
            CASE CHARGE.PROP MATCHES ACT.CHARGE.PROPERTIES      ;* To  get activities related to Activity charge.
                LOCATE CHARGE.PROP IN ACT.CHARGE.PROPERTIES<1,1> SETTING ACT.CHARGE.POS THEN
                    ACTIVITY = ACT.CHARGE.ACTIVITIES<1,ACT.CHARGE.POS>
                    ACTIVITY.REC = AA.ProductFramework.Activity.Read(ACTIVITY, ACT.ERR)
                    CHARGE.PROP.DIS<1,-1> = CHARGE.PROP
                    CHARGE.TRIGGER<1,-1> = ACTIVITY.REC<AA.ProductFramework.Activity.ActDescription>
                END
            CASE CHARGE.PROP MATCHES ACT.RES.PROPERTIES         ;* To get activities related to activity restriction.
                LOCATE CHARGE.PROP IN ACT.RES.PROPERTIES<1,1> SETTING ACT.RES.POS THEN
                    ACTIVITY = ACT.RES.ACTIVITIES<1,ACT.RES.POS>
                    ACTIVITY.REC = AA.ProductFramework.Activity.Read(ACTIVITY, ACT.ERR)
                    CHARGE.PROP.DIS<1,-1> = CHARGE.PROP
                    CHARGE.TRIGGER<1,-1> = ACTIVITY.REC<AA.ProductFramework.Activity.ActDescription>
                END
            CASE CHARGE.PROP MATCHES PROPERTIES       ;* If charge is schedule.
                CHARGE.PROP.DIS<1,-1> = CHARGE.PROP
                CHARGE.TRIGGER<1,-1> = "SCHEDULE-CHARGES"
                LOCATE CHARGE.PROP IN PROPERTIES<1,1> SETTING SCH.POS THEN
                    PAY.METHOD = PAY.METHODS<1,SCH.POS>
                END
        END CASE
*** To calculate the charge amount of each properties.

        CHARGE.ID = ARR.ID:"-":CHARGE.PROP
        CHARGE.DETAIL.REC = AA.ActivityCharges.ChargeDetails.Read(CHARGE.ID, ERR)
        IF NOT(CHARGE.DETAIL.REC) THEN
            GOSUB CHECK.SCHEDULE.CHARGES
        END ELSE
            CHARGE.AMTS = CHARGE.DETAIL.REC<AA.ActivityCharges.ChargeDetails.ChgDetBillAmt>
            CHARGE.METHODS = CHARGE.DETAIL.REC<AA.ActivityCharges.ChargeDetails.ChgDetAppMethod>
        END
        IF CHARGE.AMTS THEN
            CONVERT @SM TO @VM IN CHARGE.AMTS
            CONVERT @SM TO @VM IN CHARGE.METHODS
            GOSUB CALC.CHARGE.AMT       ;* To Iterate the charges per property and project total charges.
        END
        IF CHARGE.PROP MATCHES CHARGE.PROP.DIS THEN
            CHARGE.REC = ''
            AA.ProductFramework.GetPropertyRecord("", ARR.ID, CHARGE.PROP, "", "", "", CHARGE.REC, CHR.ERR)
            CALC.TYPE = CHARGE.REC<AA.Fees.Charge.ChargeType>
            CHARG.AMT = FIELD(CHG.AMT,'.',1)
            IF CHARG.AMT EQ "" THEN
                CHARG.AMT = '0'
            END
            CHG.DECI.AMT = FIELD(CHG.AMT,'.',2)
            IF CHG.DECI.AMT EQ "" THEN
                CHRG.DECI = '00'
            END ELSE
                CHG.DECI.AMT = CHG.DECI.AMT * 10
                CHRG.DECI = DROUND(CHG.DECI.AMT,2)
            END

            CHG.AMT = CHARG.AMT:'.':CHRG.DECI

            IF CHRG.FLAG EQ 'N' THEN
                CHRG = CHARGE.PROP
                CHRG.TRIGGER = ACTIVITY.REC<AA.ProductFramework.Activity.ActDescription>
                CHRG.AMT = CHG.AMT
                FIXED.AMT = CHARGE.REC<AA.Fees.Charge.FixedAmount>
                CHRG.RATE = CHARGE.REC<AA.Fees.Charge.ChargeRate>
                CALC.TIER.TYPE = CHARGE.REC<AA.Fees.Charge.CalcTierType>
                TIER.MIN.CHRG = CHARGE.REC<AA.Fees.Charge.TierMinCharge>
                TIER.MAX.CHRG = CHARGE.REC<AA.Fees.Charge.TierMaxCharge>
                TIER.AMT = CHARGE.REC<AA.Fees.Charge.TierAmount>
**
                IF CALC.TYPE EQ "CALCULATED" THEN
                    CALC.TYPE = CHARGE.REC<AA.Fees.Charge.TierGroups>
                END
                CHARGE.CALC.TYPE<1,-1> = CALC.TYPE
                CHRG.FLAG = 'Y'
            END ELSE
                CHRG :=@VM:CHARGE.PROP
                CHRG.TRIGGER :=@VM:ACTIVITY.REC<AA.ProductFramework.Activity.ActDescription>
                CHG.AMT = CHG.AMT
                CHRG.AMT :=@VM:CHG.AMT
                FIXED.AMT :=@VM:CHARGE.REC<AA.Fees.Charge.FixedAmount>
                CHRG.RATE :=@VM:CHARGE.REC<AA.Fees.Charge.ChargeRate>
                CALC.TIER.TYPE :=@VM:CHARGE.REC<AA.Fees.Charge.CalcTierType>
                TIER.MIN.CHRG :=@VM:CHARGE.REC<AA.Fees.Charge.TierMinCharge>
                TIER.MAX.CHRG :=@VM:CHARGE.REC<AA.Fees.Charge.TierMaxCharge>
                TIER.AMT :=@VM:CHARGE.REC<AA.Fees.Charge.TierAmount>

                IF CALC.TYPE EQ "CALCULATED" THEN
                    CALC.TYPE = CHARGE.REC<AA.Fees.Charge.TierGroups>
                END
                CHARGE.CALC.TYPE:=@VM:CALC.TYPE

            END

            LOCATE CHARGE.PROP IN SOURCE.PROP<1,1> SETTING SRC.POS THEN
                CHARGE.SRC.TYPE = SOURCE.TYPE<1,SRC.POS>
                CHARGE.SRC.BAL = SOURCE.BAL<1,SRC.POS>
            END

        END
    INT.CHG.CNT++
    REPEAT


RETURN
*** </region>

*---------------------------------------------------------------------------------------------------------------------------------------------
***<region name = CHECK.SCHEDULE.CHARGES>
CHECK.SCHEDULE.CHARGES:
***<desc> Get the amounts of charge properties if it of scheduled type.</desc>
*** To Calculate amount of scheduled charges.
    IF CHARGE.PROP MATCHES PROPERTIES THEN

        ActivitityId = ""
        PaymentDate = ""
        DeferDates = ""
        BillDate = ""
        BillType = ""
        PaymentMethod = ""
        BillStatus = PAY.METHOD         ;* Due type charges only!!
        BillSettleStatus = "" ;* Not settled
        BillAgeStatus = ""
        BillNextAgeDate = ""
        RepaymentReference = ""
        BillReferences = ""
        RetError = ""
*** Call get bill API to get the bills related to Capitalise
        AA.PaymentSchedule.GetBill(ARR.ID, ActivityId, PaymentDate, DeferDates, BillDate, BillType, PaymentMethod, BillStatus, BillSettleStatus, BillAgeStatus, BillNextAgeDate, RepaymentReference, BillReferences, RetError)
*** Total Bill ids
        BillIds = BillReferences
*** Loop each bills and get the corresponding bill amounts
        
        INT.BILL.ID.CNT = 1
        DCNT.BILL.ID = DCOUNT(BillIds,VM)
        LOOP
        WHILE INT.BILL.ID.CNT LE DCNT.BILL.ID
            BILL.ID = BillIds<1, INT.BILL.ID.CNT>
            AA.PaymentSchedule.GetBillDetails(ARR.ID, BILL.ID, BILL.DETAILS, RET.ERR)
            BILL.PROPERTY = BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdProperty>
            LOCATE CHARGE.PROP IN BILL.PROPERTY SETTING PROP.POS THEN
                CHARGE.AMTS += BILL.DETAILS<AA.PaymentSchedule.BillDetails.BdOrPrAmt, PROP.POS>
            END
            INT.BILL.ID.CNT++
        REPEAT
        IF PAY.METHOD EQ "CAPITALISE" THEN
            CAPITALISE.AMTS += CHARGE.AMTS        ;* Get the final amount as total capitalised amount for the schedule properties.
        END        
    END

RETURN
*---------------------------------------------------------------------------------------------------------------------------------------------

*** <region name= CALC.CHARGE.AMT>
CALC.CHARGE.AMT:
*** <desc>To Iterate the charges per property and project total charges. </desc>
*** Need to calculate charge amount based on its catergory defined under Disclosue Parameter table.
    CHG.AMT = 0     ;* Intialize charge amount to 0, as amount is calculated under loop.
    
    INT.CHG.AMTS = 1
    DCNT.CHARGE.AMTS = DCOUNT(CHARGE.AMTS,VM)
    LOOP
    WHILE INT.CHG.AMTS LE DCNT.CHARGE.AMTS
        CHARGE.AMT = CHARGE.AMTS<1,INT.CHG.AMTS>
        CUR.CHG.METHOD = CHARGE.METHODS<1,INT.CHG.AMTS>
        IF UPCASE(CUR.CHG.METHOD) EQ "CAPITALISE" THEN
            CAPITALISE.AMTS += CHARGE.AMT
        END
		IF CHARGE.AMT THEN
        	CHG.AMT += CHARGE.AMT
		END
    INT.CHG.AMTS++
    REPEAT

    BEGIN CASE
        CASE CHARGE.PROP MATCHES COB.CHARGES
            COB.CHARGE.AMT += CHG.AMT
        CASE CHARGE.PROP MATCHES PROV.CHARGES
            PROV.CHARGE.AMT += CHG.AMT
        CASE CHARGE.PROP MATCHES OPT.CHARGES
            OPT.CHARGE.AMT += CHG.AMT
    END CASE

RETURN
*** </region>
*---------------------------------------------------------------------------------------------------------------------------------------------
*** <region name= COB.CALCULATION>
COB.CALCULATION:
*** <desc>Get the APR value using formula to get the overall rate of interest percent. </desc>

*** Call Build schedule dates to get the entire schedule counts
*** For LOC categorized arrangement, skip the Annual percent rate calculation
    IF LOC.CHECK THEN
        APR = EFFECTIVE.RATE
        TOTAL.AMOUNT = TOTAL.AMOUNT - CAPITALISE.AMTS - Y.TOT.CAP.AMT ;* PACS00638242

        RETURN
    END
*** Get the entire schedule projection from arrangement start date.
    AA.ProductFramework.GetPropertyName(PRODUCT.RECORD, "PAYMENT.SCHEDULE", PS.PROPERTY)
* Get payment schedule record
    RETURN.IDS = "" ; RET.ERR = "" ; R.PAYMENT.SCHEDULE = "" ; AA.PROPERTY = ""

    PS.DATES = ''   ;* Holds the full payment schedule dates
    PS.ACTUAL.DATES = ''      ;* Holds actual payment schedule dates
    PS.TYPE = ''    ;* payment types
    PS.METHOD = ''  ;* Payment method of each types.
    PS.AMTS = ''    ;* Entire payment amount
    PS.PROPS = ''

    TERM.OF.COB = Y.REMAINING.TERM

    PRINCIPLE = AVG.OUTSTANDING.AMT     ;* deduced by total amount by remaining payment schedules.
*** Average interest must include tot interest amount along with the charge amounts.
    AVG.INT = TOT.INT.AMT + (COB.CHARGE.AMT+PROV.CHARGE.AMT+OPT.CHARGE.AMT)
    AVG.INT = AVG.INT - CAPITALISE.AMTS ;* For Fee calculation caplitalised amounts must be omitted, as they are calculated as part of principal and interest accrual.

    TOTAL.AMOUNT = TOTAL.AMOUNT - Y.TOT.CAP.AMT
*** Formula to calculate
*** APR = C/(P*T) * 100
*** C - Total interest amount along with charges
*** P - Average outstanding principal amount.
*** T - Term calculated from total term and remaining terms from the activity effective date.

    DENOMINATOR = TERM.OF.COB * PRINCIPLE
*** Calculation of COB.
    APR = AVG.INT / DENOMINATOR
    
*** Round off the value with precision 2.
    APR = DROUND((APR * 100),2)

RETURN
*** </region>
END
