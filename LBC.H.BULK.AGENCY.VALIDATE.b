SUBROUTINE LBC.H.BULK.AGENCY.VALIDATE
*-----------------------------------------------------------------------------
* Description       : Bulk agent/agency changes
* Developed By      : Martyna Czwarno
* Stereotype        : Application (Validation routine)
*-----------------------------------------------------------------------------
* Modification History :
* 02/07/2018 - LBC.H.BULK.AGENCY.VALIDATE created
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.LBC.H.BULK.AGENCY
    $INSERT I_F.CUSTOMER
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.AGENT.CUSTOMER
    $INSERT I_F.EB.LOOKUP
*-----------------------------------------------------------------------------
	 GOSUB INITIALISE
    GOSUB CHECK.FIELD.VALIDATION.MAIN

RETURN

*----------------------------------------------------------------------------
CHECK.FIELD.VALIDATION.MAIN:
*----------------------------------------------------------------------------
    
    Y.ARR.FOUND.LIST = ''
    Y.PROD.LINES = ''
	
    GOSUB SET.TOT.AG.CNT
    
    Y.AG.CNT = 1
    LOOP
    WHILE Y.AG.CNT LE Y.AG.TOT.CNT
        GOSUB INIT.AGENT.DATA
        GOSUB CHECK.AGENT.ROLE
        GOSUB CHECK.OLD.AGENT
        GOSUB CHECK.NEW.AGENT
        IF NOT(ETEXT) THEN
            GOSUB SELECT.CUSTOMER
        END
        Y.AG.CNT++
    REPEAT
    R.NEW(LDR.ARR.FOUND.LIST) = Y.ARR.FOUND.LIST
    R.NEW(LDR.PROD.LINE) = Y.PROD.LINES
    R.NEW(LDR.REC.PROCESSED) = 'NO'
    
RETURN

*----------------------------------------------------------------------------
INIT.AGENT.DATA:
*----------------------------------------------------------------------------
    R.EB.LOOKUP = ''
    YERR = ''
    EB.LOOKUP.ID = 'AGENT.ROLE*' : R.NEW(LDR.OLD.AGENT.ROLE)<1,Y.AG.CNT>
    CALL F.READ(FN.EB.LOOKUP,EB.LOOKUP.ID,R.EB.LOOKUP,F.EB.LOOKUP,YERR)
    Y.OLD.ROLE = R.EB.LOOKUP<EB.LU.DESCRIPTION>
    
    R.EB.LOOKUP = ''
    YERR = ''
    EB.LOOKUP.ID = 'AGENT.ROLE*' : R.NEW(LDR.NEW.AGENT.ROLE)<1,Y.AG.CNT>
    CALL F.READ(FN.EB.LOOKUP,EB.LOOKUP.ID,R.EB.LOOKUP,F.EB.LOOKUP,YERR)
    Y.NEW.ROLE = R.EB.LOOKUP<EB.LU.DESCRIPTION>
    
    Y.OLD.AG.ID = R.NEW(LDR.OLD.AGENT.ID)<1,Y.AG.CNT>
    Y.NEW.AG.ID = R.NEW(LDR.NEW.AGENT.ID)<1,Y.AG.CNT>
    
    GOSUB READ.DEALER.REP.NO
    
    Y.OLD.REP.CODE = R.NEW(LDR.OLD.DEALER.REP.CODE)<1,Y.AG.CNT>
    Y.NEW.REP.CODE = R.NEW(LDR.NEW.DEALER.REP.CODE)<1,Y.AG.CNT>
    
    Y.OLD.ARR = R.NEW(LDR.OLD.AGENT.ARR)<1,Y.AG.CNT>
    Y.NEW.ARR = R.NEW(LDR.NEW.AGENT.ARR)<1,Y.AG.CNT>

    R.NEW(LDR.ARR.FOUND.LIST)<1> = ''
    R.NEW(LDR.PROD.LINE)<1> = ''
    
*Counter for found customer arrangements for this agent
    Y.FOUND.ARR.CNT = 1
    
RETURN


*----------------------------------------------------------------------------
CHECK.AGENT.ROLE:
*----------------------------------------------------------------------------

    IF Y.OLD.ROLE NE Y.NEW.ROLE THEN
        ETEXT = 'EB-LBC.PROP.ROLE.AGENT'
        AF = LDR.OLD.AGENT.ROLE
        AV = Y.AG.CNT
        CALL STORE.END.ERROR
        AF = LDR.NEW.AGENT.ROLE
        CALL STORE.END.ERROR
    END

RETURN

*----------------------------------------------------------------------------
CHECK.OLD.AGENT:
*----------------------------------------------------------------------------
    Y.AGENT = "OLD"
    Y.REP.CODE = Y.OLD.REP.CODE
    Y.REP.CODE.READ = Y.OLD.REP.CODE.READ
    GOSUB CHECK.DEALER.REP.CODE
    Y.ARR = Y.OLD.ARR
    Y.AG.ID = Y.OLD.AG.ID
    GOSUB CHECK.DUPL.AGENT.ARR
    GOSUB CHECK.AGENT.ARR
RETURN

*----------------------------------------------------------------------------
CHECK.NEW.AGENT:
*----------------------------------------------------------------------------
    Y.AGENT = "NEW"
    Y.REP.CODE = Y.NEW.REP.CODE
    Y.REP.CODE.READ = Y.NEW.REP.CODE.READ
    GOSUB CHECK.DEALER.REP.CODE
    Y.ARR = Y.NEW.ARR
    Y.AG.ID = Y.NEW.AG.ID
    GOSUB CHECK.DUPL.AGENT.ARR
    GOSUB CHECK.AGENT.ARR
RETURN

*----------------------------------------------------------------------------
CHECK.DEALER.REP.CODE:
*----------------------------------------------------------------------------
    
    IF NOT(Y.REP.CODE) THEN
        IF Y.AGENT EQ "OLD" THEN
            R.NEW(LDR.OLD.DEALER.REP.CODE)<1,Y.AG.CNT> = Y.REP.CODE.READ
        END
        IF Y.AGENT EQ "NEW" THEN
            R.NEW(LDR.NEW.DEALER.REP.CODE)<1,Y.AG.CNT> = Y.REP.CODE.READ
        END
    END ELSE
        IF Y.REP.CODE NE Y.REP.CODE.READ THEN
            ETEXT = 'EB-LBC.DEALER.CODE.NOT.MATCH'
            IF Y.AGENT EQ "NEW" THEN
                AF = LDR.NEW.DEALER.REP.CODE
            END
            IF Y.AGENT EQ "OLD" THEN
                AF = LDR.OLD.DEALER.REP.CODE
            END
            AV = Y.AG.CNT
            CALL STORE.END.ERROR
        END
    END
         
RETURN

*----------------------------------------------------------------------------
CHECK.DUPL.AGENT.ARR:
*----------------------------------------------------------------------------


    IF Y.AGENT EQ "OLD" THEN
        Y.AG.ARR.LIST = R.NEW(LDR.OLD.AGENT.ARR)
    END
    
    IF Y.AGENT EQ "NEW" THEN
        Y.AG.ARR.LIST = R.NEW(LDR.NEW.AGENT.ARR)
    END
    
    Y.CHK = 1
    LOOP
        REMOVE Y.AG.ARR.CHK FROM Y.AG.ARR.LIST SETTING Y.POS
    WHILE Y.AG.ARR.CHK : Y.POS
        IF Y.AG.ARR.CHK EQ Y.ARR AND Y.AG.CNT NE Y.CHK THEN
            ETEXT = 'Duplicate arrangement'
            IF Y.AGENT EQ "NEW" THEN
                AF = LDR.NEW.AGENT.ARR
            END
            IF Y.AGENT EQ "OLD" THEN
                AF = LDR.OLD.AGENT.ARR
            END
            AV = Y.AG.CNT
            CALL STORE.END.ERROR
        END
        Y.CHK++
    REPEAT
        

RETURN

*----------------------------------------------------------------------------
CHECK.AGENT.ARR:
*----------------------------------------------------------------------------
    
	IF Y.ARR THEN
        R.AA.ARRANGEMENT = ''
        YERR = ''
        AA.ARRANGEMENT.ID = Y.ARR
        CALL F.READ(FN.AA.ARRANGEMENT,AA.ARRANGEMENT.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,YERR)
        
        Y.AG.IDS.READ = R.AA.ARRANGEMENT<AA.ARR.CUSTOMER>
        Y.FOUND = 0
        LOOP
            REMOVE Y.AG.ID.READ FROM Y.AG.IDS.READ SETTING Y.POS
        WHILE Y.AG.ID.READ : Y.POS AND NOT(Y.FOUND)
            IF Y.AG.ID.READ EQ Y.AG.ID THEN
                Y.FOUND = 1
            END
        REPEAT
    
        IF NOT(Y.FOUND) THEN
            ETEXT = 'EB-LBC.COMM.ARR.NOT.MATCH'
            IF Y.AGENT EQ "NEW" THEN
                AF = LDR.NEW.AGENT.ARR
            END
            IF Y.AGENT EQ "OLD" THEN
                AF = LDR.OLD.AGENT.ARR
            END
            AV = Y.AG.CNT
            CALL STORE.END.ERROR
        END
        
    END ELSE
        ETEXT = 'EB-LBC.COMM.ARR.MANDATORY'
        IF Y.AGENT EQ "NEW" THEN
            AF = LDR.NEW.AGENT.ARR
        END
        IF Y.AGENT EQ "OLD" THEN
            AF = LDR.OLD.AGENT.ARR
        END
        AV = Y.AG.CNT
        CALL STORE.END.ERROR
    END
        
RETURN

*----------------------------------------------------------------------------
SELECT.CUSTOMER:
*----------------------------------------------------------------------------
    SEL.CMD = 'SELECT ' : FN.AA.AGENT.CUSTOMER : ' WITH @ID LIKE ' : Y.OLD.ARR : '...'
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.REC,SEL.ERR)
    IF SEL.LIST NE '' THEN
        LOOP
            REMOVE Y.AG.CUST.ID FROM SEL.LIST SETTING Y.POS
        WHILE Y.AG.CUST.ID : Y.POS
        
            R.AA.AGENT.CUSTOMER = ''
            YERR = ''
            CALL F.READ(FN.AA.AGENT.CUSTOMER,Y.AG.CUST.ID,R.AA.AGENT.CUSTOMER,F.AA.AGENT.CUSTOMER,YERR)
                       
            Y.ARRS.CNT = DCOUNT(R.AA.AGENT.CUSTOMER<AA.AGCU.ARRANGEMENT>,VM)
            Y.ARR.CNT = 1
            LOOP
            WHILE Y.ARR.CNT LE Y.ARRS.CNT
                Y.CUST.ARR.ID = R.AA.AGENT.CUSTOMER<AA.AGCU.ARRANGEMENT,Y.ARR.CNT>
            
                R.AA.ARRANGEMENT = ''
                YERR = ''
                CALL F.READ(FN.AA.ARRANGEMENT,Y.CUST.ARR.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,YERR)
				
                FIND Y.OLD.AG.ID IN R.AA.ARRANGEMENT<AA.ARR.AGENT.ID> SETTING Y.POS.FM, Y.POS.VM THEN
                    Y.CUST.AG.ARR = R.AA.ARRANGEMENT<AA.ARR.AGENT.ARR.ID,Y.POS.VM>
                    Y.CUST.AG.ARR.ROLE = R.AA.ARRANGEMENT<AA.ARR.AGENT.ROLE,Y.POS.VM>
                    Y.PROD.LINE = R.AA.ARRANGEMENT<AA.ARR.PRODUCT.LINE>
					
					IF Y.OLD.ARR EQ Y.CUST.AG.ARR AND Y.OLD.ROLE EQ Y.CUST.AG.ARR.ROLE THEN
						FIND Y.CUST.ARR.ID IN Y.ARR.FOUND.LIST<1,Y.AG.CNT> SETTING Y.FM, Y.VM, Y.SM ELSE
							Y.ARR.FOUND.LIST<1,Y.AG.CNT,Y.FOUND.ARR.CNT> = Y.CUST.ARR.ID
                            Y.PROD.LINES<1,Y.AG.CNT,Y.FOUND.ARR.CNT> = Y.PROD.LINE
							Y.FOUND.ARR.CNT++
                        END		
						
                    END
   
                END
            
                Y.ARR.CNT++
            REPEAT
        
            
        REPEAT
    
    END
    
RETURN

*----------------------------------------------------------------------------
SET.TOT.AG.CNT:
*----------------------------------------------------------------------------

    Y.OLD.AG.ID.CNT = DCOUNT(R.NEW(LDR.OLD.AGENT.ID),VM)
    Y.NEW.AG.ID.CNT = DCOUNT(R.NEW(LDR.NEW.AGENT.ID),VM)
    
    IF Y.OLD.AG.ID.CNT GT Y.NEW.AG.ID.CNT THEN
        Y.AG.TOT.CNT = Y.OLD.AG.ID.CNT
    END ELSE
        Y.AG.TOT.CNT = Y.NEW.AG.ID.CNT
    END

RETURN
*----------------------------------------------------------------------------
READ.DEALER.REP.NO:
*----------------------------------------------------------------------------
    Y.APPLICATION<1> = "CUSTOMER"
    Y.FIELDS.NAMES.LIST<1, 1> = "L.DEALER.REP.NO"
    CALL MULTI.GET.LOC.REF(Y.APPLICATION, Y.FIELDS.NAMES.LIST, Y.POS)
    Y.REP.CODE.POS = Y.POS<1, 1>
    
    R.CUSTOMER = ''
    YERR = ''
    CALL F.READ(FN.CUSTOMER,Y.OLD.AG.ID,R.CUSTOMER,F.CUSTOMER,YERR)
    Y.OLD.REP.CODE.READ = R.CUSTOMER<EB.CUS.LOCAL.REF,Y.REP.CODE.POS>
    
    R.CUSTOMER = ''
    YERR = ''
    CALL F.READ(FN.CUSTOMER,Y.NEW.AG.ID,R.CUSTOMER,F.CUSTOMER,YERR)
    Y.NEW.REP.CODE.READ = R.CUSTOMER<EB.CUS.LOCAL.REF,Y.REP.CODE.POS>

RETURN

*----------------------------------------------------------------------------
INITIALISE:
*----------------------------------------------------------------------------
    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)
    
    FN.AA.AGENT.CUSTOMER = 'F.AA.AGENT.CUSTOMER'
    F.AA.AGENT.CUSTOMER = ''
    CALL OPF(FN.AA.AGENT.CUSTOMER,F.AA.AGENT.CUSTOMER)
    
    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)
    
    FN.EB.LOOKUP='F.EB.LOOKUP'
    F.EB.LOOKUP=''
    CALL OPF(FN.EB.LOOKUP,F.EB.LOOKUP)
    
RETURN


END
