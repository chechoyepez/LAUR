* @ValidationCode : MjoyMTE5NTc3NzEyOkNwMTI1MjoxNjE0MzE2OTkzNTQwOnlhZ25hcHJpeWEucmF2aWt1bWFyOi0xOi0xOjA6MTpmYWxzZTpOL0E6UjE3X1NQOC4wOi0xOi0x
* @ValidationInfo : Timestamp         : 26 Feb 2021 10:53:13
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : yagnapriya.ravikumar
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R17_SP8.0

*-----------------------------------------------------------------------------
$PACKAGE AA.ProductManagement
SUBROUTINE AA.ARR.PRODUCT.TRACKER(ARRANGEMENT.ID)
*-----------------------------------------------------------------------------
* <Rating>-194</Rating>

*** <region name= Synopsis of the method>
***
* Program Description
*
* This is a service for tracking the product changes and applying those onto
* the arrangement record. The base file is AA.PRODUCT.TRACKER which holds the
* details of the changes. This method simply uses OFS to apply these changes
* onto the product records.
*** </region>

*-----------------------------------------------------------------------------
* @uses I_AA.APP.COMMON varibles
* @package retaillending.AA
* @stereotype ServiceRoutine
* @link
* @author psankar@temenos.com
*-----------------------------------------------------------------------------
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Arguments>
*** <desc>Input and out arguments required for the sub-routine</desc>
* Arguments
*
* Input
*
* @param     ArrangementId             Arrangement id
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Modification History>
*** <desc>Modifications done in the sub-routine</desc>
* Modification History
*
* 10/06/07 - EN_10003400
*            Ref: SAR-2006-04-22-0001(Chg Product)
*            Service to track Product level changes and apply them onto arrangement
*
* 05/08/08 - CI_10057131
*            New routine AA.GET.ARRANGEMENT.PRODUCT is added to get Product.Id
*
* 16/10/08 - BG_100020293
*            Don't create ARR records for NON.TRACKING property
* 03/09/09 - CI_10065843
*            Ref: HD0930117
*            If the Product condition change date is less than the Arrangement Start Date
*            then set the EFF.DATE as Arrangement Start date.
*
* 21/02/12 - Task : 360087
*            Ref : Defect 357907
*            System should not process for the closed contracts.
*
* 07/11/13 - Task :830227
*            Defect : 749012
*            TO Initialise variable
*
* 30/04/14 - Task : 986225
*            Defect 975416
*            New argument passed has been passed indicate the system to skip or include HLD status
*            while building AAA record
*
* 01/09/14 - Task : 1101453
*            Defect : 1101171
*            When arrangement is in PC then dont trigger any activity on that arrangement.
*
* 08/01/15 - Task   : 1219042
*            Defect : 1216454
*            Don't raise an activity if effective date is null.
*
* 24/12/15 - Task   : 1580865
*            Defect : 1580060
*            Tracker updating for cancelled arrangement.
*
* 03/03/16 - Task   : 1643970
*            Enhancement : 1224667
*            New property class DORMANCY is included
*
* 31/05/18 - Task    : 2613753
*            Defect  : 2608348
*            When multiple companies share the same DEFAULT.FINAN.MNE, then system should create product id for each company in catalog file.
*            So that the service which runs on each company picks its own file and tracks the arrangements within them.
*
* 12/17/18 - Enhancement : 2902256
*            Task        : 2902259
*            When new property is added to the product, then LENDING-UPDATE.PROPERTIES-ARRANGEMENT process will be evaluated
*            based on the new method AA.DETERMINE.UPDATE.PROPERTIES.
*
* 7/3/19  -  Defect : 3024489
*            Task   : 3024509
*            Regression inconsistent issue for Blueshore enhancements
*
* 9/4/19    - Task   : 3075829
*             Defect : 3044673
*             Product line check has been removed, while calling the GetNewPropertiesList routine.
*
* 02/25/21 - Defect : 4126240
*            Task   : 4251046
*            When new property is added to the top paren product, then loop is done to check the newpropertyupdate values.
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Inserts>
*** <desc>File inserts and common variables used in the sub-routine</desc>

    $USING AA.Framework
    $USING AA.ProductManagement
    $USING AA.ProductFramework
    $USING EB.SystemTables
    $USING EB.DataAccess
    $USING EB.Service
    $USING ST.CompanyCreation
    $USING EB.Updates
    $USING AA.ChangeProduct
    $USING EB.API
    
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Main control>
*** <desc>main control logic in the sub-routine</desc>

    GOSUB INITIALISE          ;* Initialise local variables
    
    IF NOT(ARR.STATUS MATCHES 'PENDING.CLOSURE':@VM:'CLOSE':@VM:'CANCELLED') THEN
        GOSUB DO.PROCESS      ;* Do processing
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Initialise>
*** <desc> </desc>
INITIALISE:

    TMP = ARRANGEMENT.ID
    AA.Framework.setArrId(TMP)
    AA.Framework.GetArrangement(ARRANGEMENT.ID, R.AA.ARRANGEMENT, ERR.OUT)
    ARR.START.DATE = R.AA.ARRANGEMENT<AA.Framework.Arrangement.ArrStartDate>
    ARR.CURRENCY = R.AA.ARRANGEMENT<AA.Framework.Arrangement.ArrCurrency>
    PRODUCT.LINE = R.AA.ARRANGEMENT<AA.Framework.Arrangement.ArrProductLine>
    ARR.STATUS = R.AA.ARRANGEMENT<AA.Framework.Arrangement.ArrArrStatus>
    EFF.DATE = ""
    HLD.OPTION = "HLD"        ;* flag to indicate the system to skip or include HLD status while building AAA record
    
    FIN.MNE = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinancialMne) ;* Get the financial company mnemonic
    CHECK.REPEAT = "" ;* dont process the same property repeatedly
    TRACK.NEW.PROPERTIES = AA.ProductManagement.getTrackProductNewProperties() ;*common variable to check for update.properties activity
    PROPERTYFLAG = "" ;* flag to check whether new properties is added or not
    ROUTINE.NAME = "" ;* to check whether routine is exists
    ROUTINE.EXISTS = "" ;* to check whether routine is exists
    DETERMINE.ROUTINE.NAME = ""
    DETERMINE.ROUTINE.EXISTS = ""
    PROPERTIES = ""
    
RETURN
*** </region>

*** <region name= Actual processing with types>
*** <desc> </desc>
DO.PROCESS:

    tmp.AA$TRACK.PRODUCT.LIST = AA.ProductManagement.getTrackProductList()
    NO.PRODUCTS = DCOUNT(tmp.AA$TRACK.PRODUCT.LIST,@FM)          ;* How many products have got affected
    AA.ProductManagement.setTrackProductList(tmp.AA$TRACK.PRODUCT.LIST)
    FOR PCNT = 1 TO NO.PRODUCTS
        
        CURR.PROD.MNE = ""

        CURR.PRODUCT = AA.ProductManagement.getTrackProductList()<PCNT>          ;* Pick products one by one
        IF INDEX(CURR.PRODUCT,'/',1) THEN
            CURR.PROD.MNE = FIELD(CURR.PRODUCT,'/',1,1)        ;* get company mnemonic
            CURR.PRODUCT = FIELD(CURR.PRODUCT,"/",2)
        END

        IF NOT(CURR.PROD.MNE) OR (CURR.PROD.MNE EQ FIN.MNE) THEN ;* Process only the service running company's product id updated in catalog file
        
            R.PRODUCT.TRACKER = RAISE(AA.ProductManagement.getTrackProductRecord()<PCNT>)

            GOSUB PROCESS.CHANGES
        END

    NEXT PCNT

RETURN
*** </region>

*** <region name= Process changes>
*** <desc> </desc>
PROCESS.CHANGES:

    NO.CHANGES = DCOUNT(R.PRODUCT.TRACKER<AA.ProductManagement.ProductTracker.TrackPropertyCcy>,@VM)
    FOR CHG.CNT = 1 TO NO.CHANGES

        PROPERTY.CCY = R.PRODUCT.TRACKER<AA.ProductManagement.ProductTracker.TrackPropertyCcy,CHG.CNT>
        PROPERTY = FIELD(PROPERTY.CCY,AA.Framework.Sep,1)
        CURRENCY = FIELD(PROPERTY.CCY,AA.Framework.Sep,2)
        IF CURRENCY THEN      ;* Is it a currency specific property?
            IF CURRENCY EQ ARR.CURRENCY THEN      ;* Is the change condition currency relevant to the arrangement?
                GOSUB PROCESS.PROPERTY  ;* OK. Process it.
            END ELSE
                LOG.INFO = '' ;* Some currency condition not relevant to the current arr is changed. Just record it.
                LOG.INFO<AA.Framework.DebugLogDetails.DlKeyName,-1> = "CHANGE IGNORED. NOT A ":CURRENCY:" CONTRACT"
                LOG.INFO<AA.Framework.DebugLogDetails.DlKeyValue,-1> = PROPERTY.CCY
                GOSUB LOG.MESSAGE
            END

        END ELSE
            GOSUB PROCESS.PROPERTY      ;* This is a NON ccy property. Process it anyway.
        END
    NEXT CHG.CNT
RETURN
*** </region>
*** <region name= check new property update>
*** <desc> </desc>
CHECK.NEW.PROPERTY.UPDATE.VALUE:
     
    APPLICATION.NAME   = "AA.PRODUCT.MANAGER"
    LOCAL.FIELDS       = "NEW.PROP.UPD"
    LOCAL.FPOS         = "" ;* local field position
    R.PRODUCT.MANAGER  = "" ;* to store the record of the product.manager application
    PROPERTY.UPDATE    = "" ;* if local field value is set to yes
    LOCKING.ID         = "AA.UPDATE.PROPERTIES"
    LOCKING.RECORD     = ""
    PARENT.PRODUCT.ID  = ""
    R.PARENT.PROD.REC  = ""
    LOCKING.RECORD = EB.SystemTables.Locking.CacheRead(LOCKING.ID, "")
    PARENT.PRODUCT.ID  = PRODUCT.ID
    NO.PARENT.PRODUCT.ID = ""
    
    EB.Updates.MultiGetLocRef(APPLICATION.NAME, LOCAL.FIELDS, LOCAL.FPOS) ;* get the position of NewPropertyUpdate field
    

    IF  LOCAL.FPOS THEN ;* if productmanager record of product exists
       
        LOOP  ;* to loop all the ancestor product manager of the child product
        WHILE NOT(PROPERTY.UPDATE) AND NOT(NO.PARENT.PRODUCT.ID) ;* looping is until the  PmNewPropertyUpdate has value and everytime parentproduct id is checked to proceeed the loop.
            R.PRODUCT.MANAGER = AA.ProductManagement.ProductManager.Read(PARENT.PRODUCT.ID, Error)
            PROPERTY.UPDATE = R.PRODUCT.MANAGER<AA.ProductManagement.ProductManager.PmLocalRef , LOCAL.FPOS> ;*Extract newPropertyUpdate value
            IF NOT(R.PRODUCT.MANAGER) OR NOT(PROPERTY.UPDATE) THEN ;* if there is no productmanager record for the currproduct then check for the parent product record
                GOSUB CHECK.FOR.PARENT.PRODUCT.RECORD ;* check NewPropertyUpdate is set in the parent productmanager record.
            END
        REPEAT
    END
   
RETURN
*** </region>
CHECK.FOR.PARENT.PRODUCT.RECORD:
    
    AA.ProductFramework.GetProductPropertyRecord("PRODUCT", AA.Framework.Publish, PARENT.PRODUCT.ID, "", "", "", "", "", PRODUCT.RECORD, ValError)
    PARENT.PRODUCT.ID = PRODUCT.RECORD<AA.ProductManagement.ProductDesigner.PrdParentProduct> ;* get parent product id
    IF PARENT.PRODUCT.ID  THEN ;* if no parentproduct exists
        R.PARENT.PROD.REC = AA.ProductManagement.ProductManager.Read(PARENT.PRODUCT.ID, Error) ;* read parent productmanager record
        PROPERTY.UPDATE = R.PARENT.PROD.REC<AA.ProductManagement.ProductManager.PmLocalRef , LOCAL.FPOS> ;*Extract newPropertyUpdate value from parent product
    END ELSE ;* looping is not done.
        NO.PARENT.PRODUCT.ID = 1
    END
    
RETURN
*** <region name= update properties activity>
*** <desc> </desc>
UPDATE.PROPERTIES.ACTIVITY:
    
    TEMP.PROPERTY    = ""       ;* Initalise the variable
    TEMP.PROPERTY<1> = PROPERTY  ;* Assign the Property value in local variable in 1st position
    EB.ERROR.RECORD = ""
    EB.DataAccess.CacheRead("F.EB.ERROR", "AA-NEW.PROPERTY.UPD.ACCOUNTS", EB.ERROR.RECORD, "") ;* To check framework dependency
    IF EB.ERROR.RECORD THEN
        TEMP.PROPERTY<2> = PRODUCT.LINE ;* Assign the Product line in 2nd position. Since returned properties would depend on the product line
    END
    ROUTINE.NAME = "AA.GET.NEW.PROPERTIES.LIST"
    EB.API.CheckRoutineExist(ROUTINE.NAME, ROUTINE.EXISTS, "") ;* Check if the routine is catalogued
           
    IF ROUTINE.EXISTS THEN
        
        CALL @ROUTINE.NAME(TEMP.PROPERTY, PROPERTY.LIST, PROPERTIES, PROPERTYFLAG) ;* to check whether new properties is added
            
    END
                        
    IF PROPERTYFLAG AND PROPERTY.UPDATE AND LOCKING.RECORD THEN  ;* if there is a change in properties and update the new property condition in existing arrangemnets
                                
        CHECK.REPEAT = 1 ;* it shouldn't process again
                                
        GOSUB PROCESS.CONDITION
                                
    END
 
RETURN
*** </region>

*** <region name= Start processing the property>
*** <desc> </desc>
PROCESS.PROPERTY:

    NO.EFFECTIVE = DCOUNT(R.PRODUCT.TRACKER<AA.ProductManagement.ProductTrackerProof.TrackEffDate,CHG.CNT>,@SM)
    FOR EFF.CNT = 1 TO NO.EFFECTIVE
        EFF.DATE = R.PRODUCT.TRACKER<AA.ProductManagement.ProductTrackerProof.TrackEffDate,CHG.CNT,EFF.CNT>
        IF EFF.DATE THEN        ;* Don't process the activity if effective date is null
* If Product condition change date is less than the arrangement start date then
* set the Effective date as Today.
            IF EFF.DATE LT ARR.START.DATE THEN
                EFF.DATE = ARR.START.DATE
            END
            UPDATE.FLAG = ""
            GOSUB DETERMINE.ARR.PRODUCT     ;* Find the correct product on which the arrangement is running for the eff date
            GOSUB CHECK.NEW.PROPERTY.UPDATE.VALUE ;* check newPropertyUpdate value in the aa.product.manager application
            IF PRODUCT.ID = CURR.PRODUCT THEN         ;* Is this arrangement a likely candidate?
                LOCATE PROPERTY IN PROPERTY.LIST<1,1> SETTING PR.POS THEN
                    LOCATE PROPERTY IN PROPERTIES<1> SETTING NEW.PR.POS ELSE
                        GOSUB PROCESS.CONDITION ;* Process the condition
                    END
                END ELSE
                    IF TRACK.NEW.PROPERTIES EQ 'YES' AND PROPERTY.UPDATE EQ 'YES' AND NOT(CHECK.REPEAT) THEN
                        
                        GOSUB UPDATE.PROPERTIES.ACTIVITY ;* to form update.properties activity for the newly added property in arrangmeents
                    END
                END
            END
        END
    NEXT EFF.CNT
RETURN


*** </region>

*** <region name= Determine arrangement product>
*** <desc> </desc>
DETERMINE.ARR.PRODUCT:

    ARR.ID = ARRANGEMENT.ID
    PRODUCT.ID = ''
    PROPERTY.LIST = ''
    AA.Framework.GetArrangementProduct(ARR.ID,EFF.DATE,R.AA.ARRANGEMENT,PRODUCT.ID,PROPERTY.LIST)

RETURN
*** </region>


*** <region name= Process condition>
*** <desc> </desc>
PROCESS.CONDITION:

    GOSUB DETERMINE.CONDITION ;* Find the condition which the arrangement is following on this effective date

    PRODUCT.CONDITION = FIELD(R.PRODUCT.TRACKER<AA.ProductManagement.ProductTracker.TrackDesignerKey,CHG.CNT,EFF.CNT>,AA.Framework.Sep,1)
    IF PRODUCT.CONDITION THEN ;* If the designer key is present, then a condition has been added/amended
        EFF.PERIOD = R.PRODUCT.TRACKER<AA.ProductManagement.ProductTracker.TrackEffPeriod,CHG.CNT,EFF.CNT>

        IF CONDITION.ID = PRODUCT.CONDITION THEN  ;* Is the changed condition the same as the arrangement run condition
            
            GOSUB CHECK.SCHEDULED.DATE ;* check change product activity is scheduled or not
            GOSUB APPLY.CHANGE          ;* OK. Generate a UPDATE activity for the change
            
        END ELSE
            LOG.INFO = ''     ;* Just update the log with details for analysis
            LOG.INFO<AA.Framework.DebugLogDetails.DlKeyName,-1> = "CHANGE IGNORED. CONDITION CHANGE ON ":PRODUCT.CONDITION:" IRRELEVANT"
            LOG.INFO<AA.Framework.DebugLogDetails.DlKeyValue,-1> = PRODUCT.CONDITION
            GOSUB LOG.MESSAGE
        END

    END ELSE        ;* If the designer key is not present, then it means that this date has been removed. Just apply the change
        GOSUB CHECK.SCHEDULED.DATE ;*check change product activity is scheduled or not
        GOSUB APPLY.CHANGE
    END
RETURN
*** </region>

*** <region name= check scheduled or not>
*** <desc> </desc>
CHECK.SCHEDULED.DATE:
     
    IF PROPERTYFLAG THEN ;* check new property is added
        
        CHANGE.ACTIVITY.ID = ""
        
        AA.Framework.GetArrangementConditions(ARR.ID, "CHANGE.PRODUCT", "", EFF.DATE, "", R.CHANGE.PRODUCT, RETURN.ERROR)
        
        R.CHANGE.PRODUCT = RAISE(R.CHANGE.PRODUCT)
        
        CHANGE.ACTIVITY.ID = R.CHANGE.PRODUCT<AA.ChangeProduct.ChangeProduct.CpChangeActivity> ;* get scheduled activity for the arrangement
        
        IF TRACK.NEW.PROPERTIES EQ 'YES' THEN ;* to check whether common variable is set
            
            DETERMINE.ROUTINE.NAME = "AA.DETERMINE.UPDATE.PROPERTIES"
        
            EB.API.CheckRoutineExist(DETERMINE.ROUTINE.NAME, DETERMINE.ROUTINE.EXISTS, "") ;* Check if the routine is catalogued
        
            IF DETERMINE.ROUTINE.EXISTS THEN
            
                CALL @DETERMINE.ROUTINE.NAME(ARRANGEMENT.ID, CHANGE.ACTIVITY.ID , EFF.DATE , UPDATE.FLAG) ;* check change product activity is scheduled or not
            
            END
        
        END
    END
    
RETURN
*** </region>

*** <region name= Determine the condition.>
*** <desc> </desc>
DETERMINE.CONDITION:

* Some condition might be changed on the product. But we should determine whether
* the change is relevant to the arrangement in question. For example, when a product
* switches from condition 'FIXEDINT' to condition FLOATINGINT in 6M, and the FIXEDINT
* is changed. Even though FIXEDINT is changed, those do not have any relevance for
* arrangement older than 6M. Hence it is determined, whether the change is relevant
* for this arrangement.

    STAGE = AA.Framework.Publish
    PROD.REC = ''
    CURRENT.DATE = EFF.DATE

    AA.Framework.DeterminePropertyCondition(STAGE, PRODUCT.ID, PROD.REC, PROPERTY, ARR.START.DATE, CURRENT.DATE, CONDITION.ID, ARR.LINK.TYPE, ACTUAL.EFFECTIVE)
RETURN
*** </region>



*** <region name= Updation processing>
*** <desc> </desc>
APPLY.CHANGE:

    IF ARR.LINK.TYPE NE 'NON.TRACKING'  OR UPDATE.FLAG THEN ;* if no change.product activity is scheduled then trigger the update.properties activity
        GOSUB GET.PROPERTY.ACTIVITY

        IF EFF.DATE LE EB.SystemTables.getToday() THEN       ;* If the change is backdated/today, process it immediately
            GOSUB GENERATE.NEW.AAA
        END ELSE
            GOSUB UPDATE.SCHEDULED.ACTIVITY       ;* For fwd dated changes, update scheduled activity.

        END
    END
RETURN

*** </region>

*** <region name= Get the activity to be fired.>
*** <desc> </desc>
GET.PROPERTY.ACTIVITY:

* TODO - When the class activities are cleaned up, then everything
* would change to UPDATE and the case structure may not be required.

    AA.ProductFramework.GetPropertyClass(PROPERTY, PROPERTY.CLASS)

    BEGIN CASE

        CASE NOT(UPDATE.FLAG) AND PROPERTY.CLASS MATCHES 'INTEREST':@VM:'PAYMENT.SCHEDULE':@VM:'CHARGE':@VM:'DORMANCY' ;* while adding new charge property , this case is satisfied.so we should check the propertyflag also.
            THIS.ACTIVITY = 'CHANGE'
            
        CASE UPDATE.FLAG ;* if change product is not scheduled
         
            THIS.ACTIVITY= 'UPDATE.PROPERTIES' ;* form the activity
            PROPERTY = 'ARRANGEMENT'
            
        CASE 1
            THIS.ACTIVITY = 'UPDATE'
    END CASE
 
    ACTIVITY.ID = PRODUCT.LINE:AA.Framework.Sep:THIS.ACTIVITY:AA.Framework.Sep:PROPERTY


RETURN
*** </region>

*** <region name= Process backdated/Today's effective immediately.>
*** <desc> </desc>
GENERATE.NEW.AAA:


    GOSUB GET.AAA.ID

    APP.NAME = 'AA.ARRANGEMENT.ACTIVITY'
    VERSION.NAME = ''
    AAA.REC = ''

    AAA.REC = ""
    AAA.REC<AA.Framework.ArrangementActivity.ArrActActivity> = ACTIVITY.ID
    AAA.REC<AA.Framework.ArrangementActivity.ArrActArrangement> = ARRANGEMENT.ID
    AAA.REC<AA.Framework.ArrangementActivity.ArrActEffectiveDate> = EFF.DATE
     
    IF UPDATE.FLAG THEN
        
        AAA.REC<AA.Framework.ArrangementActivity.ArrActInitiationType>= "SYSTEM.CREATED" ;*   ;* it is not a USER triggered activity but has to be treated similar to USER activity for RR.
        
    END
    
    RESPONSE = ''
    GTS.CONTROL = '1'         ;* Put errors in HLD
    NO.AUTH = '0'
    AA.Framework.NewTransaction(APP.NAME, "I", "PROCESS", VERSION.NAME, GTS.CONTROL, NO.AUTH, APP.ID, AAA.REC, HLD.OPTION, RESPONSE)

RETURN
*** </region>


*** <region name= Update future dated changes to Scheduled activity>
*** <desc> </desc>
UPDATE.SCHEDULED.ACTIVITY:

    MODE = 'CYCLE'
    AA.Framework.SetScheduledActivity(ARRANGEMENT.ID, ACTIVITY.ID, EFF.DATE, MODE, RET.ERROR)          ;* Update the COB concat
RETURN
*** </region>

*** <region name= Generate the AAA id>
*** <desc> </desc>
GET.AAA.ID:

    APP.ID = ''
    AA.Framework.GetArrangementActivityId("TRANS", APP.ID)
RETURN
*** </region>


*** <region name= Log the message>
*** <desc> </desc>
LOG.MESSAGE:
*
    LOG.INFO<AA.Framework.DebugLogDetails.DlRoutine> = "AA.ARR.PRODUCT.TRACKER"
    AA.Framework.LogManager("UPDATE", "DEBUG", LOG.INFO, "")
*
RETURN
*
*** </region>
END
