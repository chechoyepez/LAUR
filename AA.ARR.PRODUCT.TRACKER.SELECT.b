* @ValidationCode : MjotMTI3MTMyNDY1MDpDcDEyNTI6MTUyNzgyODU5MjUxODpuZGl2eWE6LTE6LTE6MDotMTpmYWxzZTpOL0E6UjE3X1NQMTEuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 01 Jun 2018 10:19:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ndivya
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R17_SP11.0
*-----------------------------------------------------------------------------
* <Rating>-66</Rating>
*-----------------------------------------------------------------------------
$PACKAGE AA.ProductManagement
SUBROUTINE AA.ARR.PRODUCT.TRACKER.SELECT
*
*** <region name= Synopsis of the method>
***
* Program Description
*
* This is a select for tracking the product changes and applying those onto
* the arrangement record. The base file is AA.PRODUCT.TRACKER.CATALOG which holds the
* details of the changes. This selects all arrangements and filters the relevant
* arrangement in RECORD routine
*** </region>

*-----------------------------------------------------------------------------
* @uses I_ARR.PRODUCT.TRACKER.COMMON varibles
* @package retaillending.AA
* @stereotype SelectRoutine
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
* n/a
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
* 31/05/18 - Task    : 2613753
*            Defect  : 2608348
*            When multiple companies share the same DEFAULT.FINAN.MNE, then system should create product id for each company in catalog file.
*            So that the service which runs on each company picks its own file and tracks the arrangements within them.
*
*** </region>
*-----------------------------------------------------------------------------

*** <region name= Insert>
*** <desc> </desc>

    $USING EB.Service
    $USING AA.ProductManagement
    $USING EB.SystemTables
    $USING ST.CompanyCreation

*** </region>

*** <region name= Main processing>
*** <desc> </desc>
*
    IF AA.ProductManagement.getTrackProductList() THEN ;* If the base tracker file is null, there is nothing to do.

        tmp.CONTROL.LIST = EB.Service.getControlList()
        IF NOT(tmp.CONTROL.LIST) THEN
            EB.Service.setControlList(tmp.CONTROL.LIST)
            GOSUB BUILD.CONTROL.LIST        ;* First time - build control list
        END
*
        IF EB.Service.getControlList()<1,1> = 'PROCESS' THEN         ;* First process
            GOSUB BUILD.ARR.LIST  ;* Selects all Arrangement
        END

        IF EB.Service.getControlList()<1,1> = 'CLEAR' THEN
            GOSUB CLEAR.TRACKER.FILE        ;* Job complete. Delete the contents from the base file
        END

    END

*
RETURN
*** </region>

*** <region name= Build the control list>
*** <desc> </desc>
BUILD.CONTROL.LIST:
*
    EB.Service.setControlList('PROCESS':@FM:'CLEAR')

RETURN
*** </region>

*
*-----------------------------------------------------------------------------
*
*** <region name= Select on Arrangement file>
*** <desc> </desc>
BUILD.ARR.LIST:

    CRITERIA = ''   ;* Unconditional select
    CRITERIA<2> = AA.ProductManagement.getFnAaArrangement()
    EB.Service.BatchBuildList(CRITERIA, "")
RETURN

*** </region>

*-----------------------------------------------------------------------------


*** <region name= Clear the contents from base file>
*** <desc> </desc>
CLEAR.TRACKER.FILE:
    
    FIN.MNE = EB.SystemTables.getRCompany(ST.CompanyCreation.Company.EbComFinancialMne) ;* Get the financial company mnemonic
    
    TRACK.LOC = AA.ProductManagement.getTrackProductList()
    
    LOOP
        REMOVE PRODUCT.ID FROM TRACK.LOC SETTING PDT.POS
        
    WHILE PRODUCT.ID
    
        CURR.PROD.MNE = ""
        IF INDEX(PRODUCT.ID,'/',1) THEN
            CURR.PROD.MNE = FIELD(PRODUCT.ID,'/',1,1)        ;* get company mnemonic
        END
    
        IF NOT(CURR.PROD.MNE) OR (CURR.PROD.MNE EQ FIN.MNE) THEN
            AA.ProductManagement.ProductTrackerCatalogue.Delete(PRODUCT.ID)    ;* Delete the content.
        END

    REPEAT

RETURN
*** </region>



END
