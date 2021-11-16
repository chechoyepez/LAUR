* @ValidationCode : MjotMzkxOTA1ODM5OkNwMTI1MjoxNTk2NTE4MzMxNzcwOnZpZ25lc2hyYW1lc2g6MTowOjA6LTE6ZmFsc2U6Ti9BOlIxN19BTVIuMDo5ODo3Mw==
* @ValidationInfo : Timestamp         : 04 Aug 2020 10:48:51
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : vigneshramesh
* @ValidationInfo : Nb tests success  : 1
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 73/98 (74.4%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R17_AMR.0
* Version 13 02/06/00  GLOBUS Release No. G10.2.01 25/02/00
*-----------------------------------------------------------------------------
* <Rating>770</Rating>
*-----------------------------------------------------------------------------
$PACKAGE EB.ErrorProcessing
SUBROUTINE STORE.END.ERROR
*
*-----------------------------------------------------------------------
*
* 24/08/91 - HY9100157
*            Make error message translatable.
*
* 24/10/95 - gb9501223
*            Translate after adding field numbers
*
* 23/04/98 - GB9800403
*            Error handling for the composite module manager added.
*
* 04/07/01 - GB0101126
*            Get English Error message from EB.ERROR file
*            ETEXT contains key to EB.ERROR file
*
* 22/04/02 - CI_10001668
*            If GTSACTIVE, then store errors in T.ETEXT.
*
* 26/09/02 - ???????????
*            Save errors in OFS$ETEXT if GTSActive. These are used to build
*            error tables for the browser
*
* 30/07/03 - GLOBUS_CI_10011328
*            Looping problems for versions in classical mode with
*            screen mode set as MULTI fixed by setting the error
*            message for T.ETEXT.
*            REF NO: HD0306169
*
* 04/09/03 - GLOBUS_BG_100005084
*            Store Browser error messages using OS.SET.ERROR.MESSAGE to ensure
*            parameter substitutions and translation is performed.
*
* 11/02/04 - BG_100006184
*            When Browser does a validate it sets STORE.END>ERROR to be
*            "BROWSER.VALIDATE" so that even if there is no error, the processing
*            will stop after crossval. If we find it set, then delete it
*            as it is irrelevant given there is a real error.
*
* 13/02/04 - BG_100006216
*            For the previous change we also need to set T.ETEXT
*
* 03/04/04 - CI_10017801
*            Call OS.SET.ERROR.MESSAGE only for browser.
*
* 29/11/04 - GLOBUS_BG_100007692
*            Set GTSERROR for non-Browser OFS errors.
*
* 16/01/09 - CI_10060073
*            Leading zeros get trimmed for non english users due to ETEXT get
*            cleared while calling TEXT
*            REF:HD0837353
*
* 09/06/10 - Story 47862 / Task 55257
*            SOA framework to handle errors and overrides
*
* 07/08/14 - Defect 953883 / Task 1078235
*			 SOA framework error handling is pushed down so that common variables
*            GTSERROR and END.ERROR will be set and ORM prepares the error response
*
* 18/08/17 - Task 2239646 / Defect 2239256
*            Resource provider should send Error code along with error message
*
* 21/04/20 - Enhancement 3721932  / Task 3726195
*            Store consolidated error ID and message
*
* 13/08/20 -  EN 3206456 / Task 3574158
*              Erasure of Index files via OFS
*-----------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_PERROR.COMMON
    $INSERT I_GTS.COMMON
    $INSERT I_CMM.COMMON
    $INSERT I_F.EB.ERROR      ;* GB0101126
    $INSERT I_F.OFS.SOURCE
    $INSERT I_SOA.COMMON
    $INSERT I_OFS.OVERRIDE.COMMON
*
* Incoming: AF, AV, AS
*           END.ERROR
*           ETEXT
*           LNGG
*           SCREEN.MODE
*
* Outgoing: END.ERROR = 'Y' = problems located
*           = '#' + field.no. + ':' = refers to field.no when
*           a. Multi mode
*           b. Single mode with error of an not defined field
*           (e.g. in connection with used VERSION)
*           ETEXT = default message when Incoming = ""
*           T.ETEXT = modified when Single mode with available Field no.
*
*************************************************************************
* Check whether CZ.IS.ERASURE.RUNNING is avilable or not
DEBUG 
 PRG.NAME = "CZ.IS.ERASURE.RUNNING"
    COMPILED.OR.NOT = ""
    RETURN.INFO = ""
    IS.ERASURE = ""
    SAVE.ETEXT = ETEXT
    CALL CHECK.ROUTINE.EXIST(PRG.NAME,COMPILED.OR.NOT,RETURN.INFO)
    IF COMPILED.OR.NOT THEN
        CALL @PRG.NAME(IS.ERASURE,"","","","")
    END
*------------------
    ETEXT = SAVE.ETEXT
    IF IS.ERASURE THEN  ;* If CZ.IS.ERASURE.RUNNING is running then skiping the STORE.END.ERROR
        ETEXT = ''      ;*clear the value of ETEXT before returning
        RETURN ;*To skip the template level validations if the record is edited in CDP Erasure process
    END

    IF END.ERROR = "BROWSER.VALIDATE" THEN        ;* BG_100006184
        END.ERROR = ''
        T.ETEXT<1> = ''       ;* BG_100006184
    END
	CALL Iris.getIsIris(isIris)
    YERR = ETEXT
    OfsOverrideflag = ''      ;* Initialise variable before use
    IF ('OFS.OVERRIDE' MATCHES OFS$SOURCE.REC<OFS.SRC.ATTRIBUTES>) AND NOT(OFS$SOURCE.REC<OFS.SRC.SOURCE.TYPE> = 'SESSION') THEN  ;* Interested only if the request is not from legacy/UXP browser and specific with this attribute
        SAVE.ETEXT = ETEXT    ;* Copy the ETEXT variable
        CALL CACHE.READ('F.EB.ERROR','EB-OVERRIDE.TRANSACTION.CONTROL.COMP',OfsOverrideflag,'')     ;* Getting error record
        IF OfsOverrideflag NE '' THEN
            OfsOverrideflag = ''        ;* Initialise variable before use
            CALL CACHE.READ('F.EB.ERROR','EB-OVERRIDE.OVERRIDE.PROCESSING.COMP',OfsOverrideflag,'') ;* Getting error record
        END
        IF OfsOverrideflag NE '' THEN
            OfsOverrideflag = ''        ;* Initialise variable before use
            CALL CACHE.READ('F.EB.ERROR','EB-OVERRIDE.INTERFACE.COMP',OfsOverrideflag,'') ;* Getting error record
        END

        ETEXT = SAVE.ETEXT    ;*Restore the ETEXT variable
    END
    IF OfsOverrideflag THEN
        consolidatedErrorPosn = DCOUNT(OFS$CONSOLIDATED.ERROR, @FM) + 1         ;* Count the total number of error in OFS$CONSOLIDATED.ERROR and set position to the next one
        OFS$CONSOLIDATED.ERROR<consolidatedErrorPosn, 1> = YERR<1,1>  ;* Append the ETEXT to OFS$CONSOLIDATED.ERROR
    END
   
    ERR.MESS = ETEXT          ;* GLOBUS_EN_10000012/S
    CALL EB.GET.ERROR.MESSAGE(ERR.MESS)
    ETEXT = ERR.MESS<1>:FM:ERR.MESS<2>  ;* GLOBUS_EN_10000012/E
    P$END.ERROR = END.ERROR
    IF CMM$PARENT.ID <> "" THEN
        MESSAGE = "OUT"
    END
*
* Ask for already defined error message (Multi mode)
*
    IF (SCREEN.MODE = "MULTI" OR CMM$PARENT.ID <> "") AND NOT(GTSACTIVE) THEN   ;* CL_10001668
        IF LEN(END.ERROR) > 1 THEN RETURN
* only 1st error will be stored
    END
*
* translate error message
*
    IF ETEXT = "" THEN ETEXT = "INVALID INPUT"
* default message, should normally not occure
*
* Define Multi + Sub Value to adress Error message
* and check that Field no. is defined for display
*
    YAF = AF ; YAV = AV ; YAS = AS
    BEGIN CASE
        CASE F(YAF)[1,2] <> "XX" ; YAV = "" ; YAS = "" ; YLOC = YAF
        CASE YAF = LOCAL.REF.FIELD
            IF T.LOCREF<YAV>[1,2] = "XX" THEN YLOC = YAF:".":YAV:".":YAS
            ELSE YAS = "" ; YLOC = YAF:".":YAV
        CASE F(YAF)[4,2] = "XX" ; YLOC = YAF:".":YAV:".":YAS
        CASE OTHERWISE ; YAS = "" ; YLOC = YAF:".":YAV
    END CASE
    IF (SCREEN.MODE = "MULTI" OR CMM$PARENT.ID <> "") AND NOT(GTSACTIVE) THEN   ;* CI_10001668
        GOSUB ADD.FIELD.TO.END.ERROR
        LOCATE YLOC IN T.FIELDNO<1> SETTING X THEN NULL     ;* GLOBUS_CI_10011328 - S/E
        IF T.ETEXT<X> = "" THEN T.ETEXT<X> = END.ERROR      ;* GLOBUS_CI_10011328 - S/E
    END ELSE
*
* Handle Single mode Error
*
* TXT will drop any addition fields in the text passed to the routine and only
* return the translated message in field 1
        SAVE.ETEXT = ETEXT
        CALL TXT(SAVE.ETEXT)
        ETEXT = SAVE.ETEXT<1>
*CI_10017801-S
        IF GTSACTIVE THEN
            IF OFS$SOURCE.REC<OFS.SRC.SOURCE.TYPE> EQ 'SESSION' THEN  ;* OFS uses this instead of T.ETEXT to get all errors, not just on screen
                CALL OS.SET.ERROR.MESSAGE( YLOC, ETEXT )    ;* GLOBUS_BG_100005804
            END ELSE
                GTSERROR<1> = ETEXT                         ;* GLOBUS_BG_100007692 S
                GTSERROR<2,-1> = YLOC
                GTSERROR<3,-1> = ETEXT                      ;* GLOBUS_BG_100007692 E
                IF isIris THEN
                    GTSERROR<8,-1> = YERR ;* Set the error code to GTSERROR
                END
                    
            END
        END
*CI_10017801 -E
        IF END.ERROR = "" THEN END.ERROR = "Y"
        LOCATE YLOC IN T.FIELDNO<1> SETTING X THEN
* GLOBUS_EN_10000012/S


            IF INDEX(TTYPE,"GUI",1) THEN
                ERR.MESS<1> = ETEXT
                ERR.MESS<2> = ''
                ERR.MESS = LOWER(ERR.MESS)
            END ELSE
                ERR.MESS = ETEXT
            END

            IF T.ETEXT<X> = "" THEN T.ETEXT<X> = ERR.MESS   ;* GLOBUS_EN_10000012/E
        END ELSE
            GOSUB ADD.FIELD.TO.END.ERROR
            T.ETEXT<X> = END.ERROR      ;* GLOBUS_CI_10011328 - S/E
        END
    END

* only 1st error will be stored
    P$T.ETEXT = T.ETEXT
    P$SPARES(1) = T.FIELDNO
    P$END.ERROR = END.ERROR
    IF SOA$FLAG AND ETEXT AND NOT(GTSACTIVE) THEN
        CALL AddServiceError(YERR)
    END
        
RETURN
*
*-----------------------------------------------------------------------
*
* Add Field number in front of Error message and place as END.ERROR
* and then translate it
*
ADD.FIELD.TO.END.ERROR:
*
    END.ERROR = "& ":ETEXT<1>: @FM: "#":YLOC: @VM: ETEXT<2>
    SAVE.TXT = END.ERROR
    SAVE.ETEXT.MESSAGE = ETEXT  ;* Save ETEXT as it is get cleared in TXT
    CALL TXT(SAVE.TXT)
    ETEXT = SAVE.ETEXT.MESSAGE  ;* Restore ETEXT variable
    END.ERROR = SAVE.TXT

RETURN
*
*************************************************************************
END
