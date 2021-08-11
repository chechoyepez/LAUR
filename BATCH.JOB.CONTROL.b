* @ValidationCode : MjotMTM3NDg1ODU0MzpDcDEyNTI6MTYwMjQ4OTkxNjEyNzphbWl0aGE6MjowOjA6LTE6ZmFsc2U6Ti9BOlIxN19BTVIuMDoxNTMxOjY2NQ==
* @ValidationInfo : Timestamp         : 03 Dec 2020 13:35:16
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : amitha
* @ValidationInfo : Nb tests success  : 2
* @ValidationInfo : Nb tests failure  : 0
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : 665/1531 (43.4%)
* @ValidationInfo : Strict flag       : false
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R17_SP51.0
*-----------------------------------------------------------------------------
* <Rating>9984</Rating>
*-----------------------------------------------------------------------------
* Version 3 13/06/01  GLOBUS Release No. 200511 03/10/05
*************************************************************************
$PACKAGE EB.Service
SUBROUTINE BATCH.JOB.CONTROL(JOB.INFO)
*************************************************************************
*
* This routine is used to control the process where multiple sessions
* may be used to run this job.
*
* From I_BATCH.FILES common:
* The AGENT.NUMBER is used to determine the portion of the list to process
* and KEYS.PROCESSED is the total number of contracts which were processed.
*-----------------------------------------------------------------------------
* Modifications
*
* 20/04/00 - GB0001096
*            Don't allow the batch routine to corrupt the key that's passed
*
* 12/06/01 - GB0101735
*            In Multi-threaded EOD, record locks for LD
*            and LMM.SCHEDULES.PAST are not released
*            properly. As a result teh EOD gets stuck.
*            This can be fixed by using a RELEASE command after finishing
*            a transaction
*
* 22/01/02 - EN10000402
*            A PRE and POST routine are added to the EOD. They are checked
*            to see if they exist using CHECK.ROUTINE.EXIST.
*
* 09/11/02 - EN_10001339
*            Enable re-start of job after crash and allow .SELECT routines
*            to manage more than one select list - ie replace exisiting
*            control routines with a generic mechanism. Remove pre and post routine support
*            changes to core batch routine for commitment control
*
* 30/10/02 - BG_100002614
*            Spelling mistake while init the variable LISTS.PROCESSED.
*
* 18/11/02 - BG_100002722
*            Enable re-start of job after crash and allow .SELECT routines
*            to manage more than one select list - ie replace exisiting
*            control routines with a generic mechanism. Also update job times
*            here rather than S.BATCH.RUN.
*
* 22/11/02 - BG_100002841
*            Remove CRT for CONTROL.LIST
*
* 1/12/02 -  BG_100002910
*            BATCH.JOB.CONTROL CHANGES
*            CRT IS CHANGED BY CALLING A NEW ROUTINE OCOMO
*
*            Use OCOMO for outputting to the como file and
*            change processing when list reduces to near zero
*            to avoid repetitive selects.
*
* 26/12/02 - BG_100003080(BG_100002910)
*            Correction for new batch changes
*
* 03/01/03 - BG_100003119
*            The varaible RECORD.ROUTINE is assigned to JOB.ROUTINE, if
*            STANDARD.JOB.is set to false.
*
* 08/01/03 - BG_100003135
*            Correction for BG_100003119
*            Execution of COMMAND from PGM.FILE is commented.
*
* 21/02/03 - BG_100003549
*            Batch abruptly stops if USER.FLAGGED.HALT
*
* 10/03/03 - BG_100003752
*            Update BATCH.STATUS record of the current job
*            with "processed" when job is completed
*
* 19/03/03 - BG_100003814
*            Get the current CONTROL.LIST from BATCH.STATUS of the job
*            before processing records in list file.
*
* 23/03/03 - BG_100003837
*            Use of list file FXXX.JOB.LIST.Y where XXX is the company
*            mnemonic and Y the session number.
*
* 07/04/03 - CI_10008062
*            Changes done to support generic list file processing.
*
* 27/05/03 - EN_10001831
*            This is part of the Core Batch changes for Multi-Book Processing
*            Read the contract record and pick up the company code.
*
* 11/06/03 - EN_10001864
*            Populate JOB.TIMES with progress. Throughput figure will now
*            show an incremental count of the keys (contracts not lists)
*            processed while the job is running and it will show the fastest
*            throughput of a SINGLEthread once the job is complete. The
*            former is used to monitor progress while running and the
*            latter is used to compare previous runs - if it is increasing
*            then it indicates a problem (file sizing??:).
*            Also periodically check the next service for this agent and
*            go back to S.JOB.RUN if it changes.
*
* 08/07/03 - BG_100004694
*            Improve the company ID checking for KEY list ID in multi book
*            Takes whole ot part of key to read the record containing the company code
*
* 25/07/03 - BG_100004873
*            Changes done to solve the problem of repgens in jBase
*            due to Transaction Mgmt. Repgens write into a work
*            file, select it and print. Since the work file writes happen
*            into cache - the select does not work on it.
*            So we check if the JOB.NAME is EB.EOD.REPORT.PRINT then
*            do not call EB.TRANS for that job.
*
* 27/08/03 - BG_100005037
*            To get the correct SPF record before calling the main routine
*
* 21/10/03 - BG_100005444
*            Two changes are done under this Change.Document:
*            1. If not of Activation.File always use generic list file.
*            2. Clear the .LIST file before using it.
*
* 09/12/03 - BG_100005787
*            The following changes are done under this CD:
*            1. Re-introduction of changes done under BG_100003814 and
*               CI_10008062.
*            2. We go and select the .LIST file only if the .select
*               routine has selected records and written into the .List file.
*            3. Previously the key(FLAG.ID) to F.BATCH.STATUS was MNEMONIC/JOB.NAME.
*               Now the FLAG.ID is of the format PROCESS.NAME-JOB.NAME
*            4. Changes done to handle CONTRACT$ID of the format "00".
*            5. The process of clearing the .LIST file is altered.
*
* 10/12/03 - BG_100005796
*            The procedure of clearing the .LIST file is reverted to
*            BG_100005444
*
* 08/03/04 - CI_10017904
*            The following two changes have been done:
*            1. The .LIST file is no longer cleared.
*            2. If record locked in the .LIST file and if number of keys less than
*               number of sessions then pause before doing the select again
*
* 08/04/04 - BG_100006511
*            For record routines, do not call EB.TRANS if the PGM.TYPE
*            for the routine has additional info set as ".NTX"
*
* 07/05/04 - CI_10019620
*            When same job.name occurs more than once in a batch record we have
*            problem in getting its position in the batch record. Also we have
*            problem in maintaning the the uniqueness of the FLAG.ID. Changes done
*            to handle this. Now the FLAG.ID is of the format:
*            FLAG.ID = <PROCESS.NAME>-<JOB.NAME>-<POS OF THE JOB IN THE PROCESS>
*            Ref :HD0401950
*
* 10/05/04 - BG_100006900
*            1. Process individual contracts in the list in a transaction unit
*            rather than the entire list record. This allows a more effecient build
*            of the list file (less records) and better control of lock contentions
*            when processing multiple business transactions in a single database
*            transaction.
*            2. Reduce OCOMO output of ControlList - first 50chars
*            3. Move EB.READ.SPF - so that it's invoked only once for a job
*            4. Create an initial list of JobList keys automatically - to avoid selecting
*            the job list file first. When there a N number of misses - then go and
*            select the file.
*            5. Record the number of active agents in the job times record
*            6. Update JOB.PROGRESS (in common) to tell SERVICE.HEARTBEAT where we are
*            1=Processing Contracts
*            2=Selecting Contracts
*            3=Managing Control List
*            4=Selecting list file
*            5=Managing Batch record (in S.JOB.RUN)
*            6=Waiting on list record
*            7=Processing Single threaded
*
* 21/09/04 - CI_10023328
*            1. When checking for the agent status, if it is not running go to PROGRAM.END
*            instead of PROGRAM.ABORT.
*            Ref: HD0480197
*            2. Calculate the OFFSET correctly.
*            3. If KEYS.PROCESSED = -1, then change it to zero before updating JOB.TIMES.
*            4. Lock and delete the F.LOCKING record which holds the name of the .LIST file.
*
* 22/09/04 - BG_100007283
*            Changes done to handle CONTRACT$ID of the format "00"
*
* 23/09/04 - BG_100007289
*            Force heartbeat to record a singlethread job - this will tell the
*            tSM NOT to kill the agent if the heartbeat goes beyond the deathwatch
*            Change the END.GAME to check when the BATCH.STATUS record when the
*            number of keys in the list file reduces to 100. Also check this when
*            the number of keys in MY portion reduces to this figure - in case a thread
*            empties the list file from GT 100 to zero in one go.
*
* 11/10/04 - BG_100007441
*            The Session which allocates the .LIST should not use the run ahead mechanism.
*
* 21/10/04 - CI_10024128
*            Dont Run Ahead if an agent is trying to process the job again
*            in the cycle of run ahead when there is nothing to run ahead
*            Also Introduction of new threshold - JOB.THRESHOLD which will
*            dictate the starting of read to BATCH.STATUS for completion
*            END.GAME.THRESHOLD is now number of sessions  which will
*            be used to run ahead.
*
* 21/12/04 - CI_10025864
*            1. Don't set END.GAME for every extracted portion. Set it only when we
*               are really at the end of the list and no more IDs to process.
*            2. Don't start to sleep as soon as we find a record locked in .LIST file
*               and END.GAME set. Sleep only when there is no more ID left in the .LIST file and can't RUN.AHEAD
*            3. Increase RECORD.MISS by 1, if a ID is locked by another session and moving to next ID
*            4. When unable to lock and read a .LIST file record and waking up from sleep and
*               sucessfully able to lock now, check for the job.status again because the ID might
*               belong to next job.
*
* 05/01/05 -  BG_100007865
*             1. The session which runs the .SELECT routine alone can use MAX.LIST.ID to get the
*             no.of.records in the .LIST file. Other sessions should select the .LIST file to
*             get the no.of.records.
*             2. Incase the record.routine passes an argument back to BJC, we substitue the
*             original Key.Id in LIST.RECORD with the passed argument. Otherwise remove the Key.Id
*             from LIST.RECORD as usual.
*
* 17/02/05 - BG_100008122
*            Assign FN.LIST.NAME with the name of the .LIST file.
*
* 25/07/05 - CI_10030546
*            Activation file processing , Allow SEAT logging at record key level
*
*
* 29/11/05 - EN_10002713
*            1. Distribute the List Records when you get down to the end and there
*               are more than one batch keys in the list record
*            2. Allocate the list file based on availability. Maintain a locking reference
*               keyed on the list file name. Availalble job list will be allocated to a job
*               than based on the current session number
*            3. Tidy up the CHECK.STATUS paragraph.
*
* 12/12/05 - GLOBUS_CI_10037219
*            Changes to multi-book processing to allow for mt.key.file containing a suffix
*
* 30/01/06 - CI_10038508
*            Do not spilt out empty ID.LIST via OCOMO
*            Ref:HD0517254
*
* 01/02/06 - CI_10038624
*            JBASE does not recognize characters like
*            '-','.' etc properly, hence failing in CHECK.COMPANY
*            para, in loading the book in MB environment.
*
* 02/02/06 - BG_100010166
*            Bug fixes for the enhancement - EN_10002713
*
* 15/02/06 - CI_10038991
*            .NOL option to be provided to enable non reporting  of locks
*
* 14/06/06 - CI_10041844
*            SEAT integration in DEV
*
* 25/07/06 - CI_10042787
*            Introduction of new common variable SEAT.SCRIPT to hold the Seat
*            Script details.
*
* 17/08/06 - BG_100011810
*            Changes made for Seat
*
* 25/08/06 - CI_10043592
*            EB.EOD.REPORT.PRINT shall b construed as single threaded and the ports need not
*            be logged off. This ensures that big reports dont get logged off and DEATH.WATCH
*            need not be set too high just because of reporting problems
*
* 12/09/06 - CI_10044016
*            Multi-threaded Job runs only in one session.
*
* 06/12/06 - EN_10003145
*            If DW is installed then go and call DW.PROCESS.TXN to check for DW extracts
*            Ref: SAR-2006-09-19-0007
*
* 19/12/06 - CI_10046224
*            Changes have been made not to update the Seat Results ID with **CONTRACT.ID
*            while updating Seat Results for online jobs.
*
* 02/02/07 - BG_100012866
*            Seat changes done to cater for Single thread jobs furing COB.
*
* 27/03/07 - CI_10048043
*            The Batch job IC.CAPITALISATION takes more
*            than a hour to complete the job.
*
* 22/05/07 - CI_10049235
*            Invoke TEC to store number of transactions processed. Do this during the 'progress'
*            phase when updating job times and at the end of the job passing the difference
*            between Completed & Processed - so that the final update of the TEC matches the actual
*            number of contracts processed. Also clear SYSTEM(1036), the lock collision counter, prior
*            to invoking the record routine - as we don't want to record lock collisions from BJC
*            because its design is based on lock management.
*
* 31/05/07 - BG_100014021
*            Call to ALLOCATE.UNIQUE.TIME is moved to DW.PROCESS.TXN
*
* 01/06/07 - BG_100014041
*            Just dummy flag to enable SEAT for single threaded job
*
* 05/06/07 - BG_100014073
*            Removing the checks to LOCK.STATUS before and after calling SELECT routine
*
* 14/06/07 - CI_10049791
*            job name and process name should be updated even for services.
*
* 25/06/07 - CI_10049975(TTS0753504)/BG_100015170
*            Initialize LIST.OWNER to 0 in the INITIALIASE sec
*
* 24/07/07 - BG_100014498
*            Call to T.SEAT with FINISH option depends on the flag NO.CALL.TO.T.SEAT.FINI.BJC
*
* 10/08/07 - BG_100014805
*            The flag NO.CALL.TO.T.SEAT.FINI.BJC is made as NULL if it is ZERO.
*
* 10/09/07 - CI_10051276
*            AGENT.STATUS field displays RUNNING value in TSA.STATUS even though the agent has
*            been stopped by modifying the SERVICE.CONTROL field to STOP in TSA.SERVICE.
*            HD Ref: HD0714895
*
* 19/09/07 - CI_10051450
*            While running the RUN.CONVERSION service, if any file routine
*            takes more than the time specified in the DEATH.WATCH , tsm logs off the agent.
*
* 11/10/07 - BG_100015396
*            Write the actual no of records to be processed and no of key count processed in
*            CONTROL.LIST<1,4> and CONTROL.LIST<1,5> resp
*
* 18/10/07 - BG_100015483
*            In the CHECK.JOB.STATUS para, just check whether CURRENT.CONTROL.LIST<1,1> is same
*            as CONTROL.LIST<1,1> and not for the entire value.
*
* 31/10/07 - BG_100015423
*            Changes made to stop creating a duplicate SEAT.RESULTS id in Online.
*
* 09/11/07 - CI_10052409
*            tSA COMO-output file remains incomplete without "Agent stopped" and
*            "COMO COMPLETED" messages.
*            HD REF:HD0719734
*
* 21/11/07 - BG_100015760
*            The changes done to avoid T.SEAT call, during script uploading.
*
* 28/11/07 - BG_100016477
*            Changes made to populate the variable SEAT.SCRIPT only when SEAT is used.
*
* 13/03/08 - BG_10017676
*            PROGRESS mispelled as UPDATE.PROGESS.BATCH.STATUS
*
* 14/03/08 - CI_10054170
*            When a multithread job is run as a service with SERVICE.CONTROL set to
*            AUTO,select routine is executed in multiple sessions.
*
* 20/03/08 - CI_10054277
*            TSA.STATUS not changed to "STOPPED" when a NEXT.SERVICE is allocated to
*            a RUNNING agent.
*
* 24/03/08 - CI_10054325
*            Uninitialised variable FN.LIST.FILE.
*
* 24/03/08 - BG_100017812
*            Code added to capture the start and end time of a SERVICE for TV.
*
* 29/04/08 - CI_10055058
*            Added SelectAhead mechanism.
*            Added new field to JobTimes - SelectStart & Highest Response
*
* 21/05/08 - CI_10055510/ BG_100018659
*                 In the paragraph ADVANCE.CONTROL.LIST we should ensure that we also purge
*                 the locking records while setting the batch status as PROCESSED.So that both
*                 processing occur in the same txn boundary.
*                 Ref: HD0723406
*
* 07/06/08 - BG_100019073
*            Bug Fix for SelectAhead changes.
*            Highest response not updated.
*
* 22/07/08 - EN_10003752
*            If .KEY specified then use the key of the ACTIVATION file and not the record content.
*
* 29/07/08 - CI_10056973
*            Cannot run service which has an  activation file associated with it.
*
* 11/09/08 - EN_10003814
*            BATCH.JOB.CONTROL to now update new fields like TXN.MANAGEMENT,BULK.NUMBER
*            READ.WRITE.CACHE etc. added in JOB.TIMES and a new file JOB.TIMES.HISTORY as well.
*            Checks whether the record routine has the Verification mechanism and if so, update
*            a field REC.VER in PGM.FILE.If the WRITE.CACHE is enabled, then the records are
*            retrieved from the cache and written into the disk as we do it in JOUYRNAL.UPDATE.
*
* 19/09/2008 - CI_10057849(Ref: HD0823457)
*                       Don't enable the run ahead option for Online Services
*
* 09/10/2008 - BG_100020327
*              Use the cache only if '.NUC' is set in the PGM.FILE pf the JOB.
*
* 24/10/08 -  CI_10057692
*             Save and restore the variable for Default printer
*             CSS.REF:HD0818388
*
* 24/10/08 - EN_10003892
*            Write Cache needs to be implemented for the entire bulk boundary.
*            Cache need to be cleared at the end of Bulk Boundary
*            REF:SAR-2008-08-29-0004
*
* 05/10/08 - BG_100020679
*            Write Cache Updates need to be done at end of Bulk Boundary
*            REF:SAR-2008-08-29-0004
*
* 29/12/08 - GLOBUS_CI_10059735
*            FLAG.ID locking record is deleted only when its content matches the List Name.
*            HD Ref: HD0830414
*
* 03/02/01 - BG_100021918
*            Job START.TIME is not updated in JOB.TIMES file.
*            REF:TTS0905109
*
* 04/02/09 - BG_100021935
*            All the cob jobs by default would use WRITE.CACHE.The cob jobs would not use
*            WRITE.CACHE only if .NUC(not use cache) is set in the PGM file of the job.
*            Reverting the fix done in the cd BG_100020327.
*
* 04/02/09 - BG_100021934
*            Parameterise updating JOB.TIMES.HISTORY on SEAT
*            TTS Ref : TTS0905476
*
* 05/03/09 - BG_100022484
*            Review time to be taken from TSA.SERVICE if not defined then
*            take it from TSA.PARAMETER.
*
* 03/04/09 - BG_100023113
*            TOTAL.WRITE field in JOB.TIMES and JOB.TIMES.HISTORY is updated.
*
* 15/07/09 - BG_100024502
*            Single threaded jobs not to use WRITE.CACHE as the cache size is exceeded.
*
*
* 16/07/09 - CI_10064570
*            Minimised the locks made on LOCKING files
*            REF:HD0922370
*
* 03/08/09 - BG_100024654
*            TEC$EVENT.ID and TEC$EVENT.HOLD.ID to initialised before call to RECORD routine.
*
* 11/08/09 - BG_100024859
*            List file should be read before doing the Release
*            REF:HD0922370
*
* 11/08/09 - CI_10065282
*            When an agent is waiting for the last record of the job to be processed,
*            COMO is filled up unnecessarily with the message "Available list IDs exhausted"
*            REF : HD0927539
*
* 21/08/09 - CI_10065462
*            ".NTX" jobs not to use WRITE.CACHE as the transaction management is not started
*            here in BJC.
*
* 05/09/09 - CI_10065895
*            When a cob job is run with the 'n' number of agents, the  AGENTS  field in JOB.TIMES
*            is updated with the agent count lesser  than the actual no.of agents
*
* 25/09/09 - CI_10066377
*            SLEEP.TIME is reduced on two occasions ,to trigger the distribution process
*            1)When list file has more than 100 records
*            2)Or when Next control list exits
*            REF:HD0934105
*
* 14/10/09 - BG_100025502
*            Tracing the record details which is locked without either write or delete
*
* 14/11/09 - BG_100025810
*            Variable 'LOCK.FILE' should be initialized before the WRITE.CACHE check.
*
* 20/11/09 - CI_10067709
*            DATA field in one 'SingleThreaded' job  used by next Job's when jobs are
*            defined in same BATCH record.
*            Ref:HD0931434
*
* 27-09-09 - EN_10004373( SAR-2009-03-05-0012)
*                   Use AGENT.NUMBER(I_TSA.COMMON)  instead of SESSION.NO(I_BATCH.FILES)
*                   as SESSION.NO might contain the C$T24.SESSION.NO from here -on , instead of
*                   TSA Agent no.
*
* 05/10/09 - EN_10004366( SAR-2009-03-05-0010)
*            1) Retrive the PGM.FILE information (additional info ,key file , key component) from JOB.INFO
*            rather than reading the PGM.FILE again and finding it .
*            2) If the keys processed is zero and no more items in the control list just update
*            the job times with 'END' part as well during processing KEYS.Need not call ADVANCE.CONTROL,
*            if there are no more items in the CONTROL.LIST.Read the locking record of SEAT.TRACE only if
*            SEAT is on.
*            3) Clear the static cache for each and every job in a batch if CLEAR.STATIC.CACHE field
*            is set to 'YES' in the BATCH record.
*
* 19/10/09 - BG_100025532
*            Change in the logic to determine the HIGHEST.AGENT to be updated in TSA.PARAMETER.
*            NUMBER.OF.SESSIONS is populated in SJR which is the actual no of agents running this
*            service rather than the HIGHEST.AGENT in TSA.PARAMETER.
*
* 04/12/09 - BG_100026069
*            Locking information pertaining to the job are not deleted if there are no records
*            processed by the job.
*
* 12/12/09 - BG_100025612
*            F.DELETE to come under WRITE.CACHE. If WRITE.CACHE is enabled, delete the records
*            from the disk for those present in the cache.
*
* 22/12/09 - BG_100026337/BG_100026447
*            BAM requirements - Include additional details in BATCH.STATUS for service
*            REF: TTS0911143
*
* 21/01/10 - Taskno 14937
*             a) List File need to be checked only when job reaches tail of processing.
*             b) Sleep Time of Agent need to be reduced when CONTROL.LIST is higher.
*             c) Distribution of Ids should also happen when final list is reached by the agent.
*             d) When there is no keys in Job list,List record can be deleted to minimize the Locks on List record.
*             REF:HD0951024,Defect no:11624
*
* 18/02/10 - Task -23195 / Defect - 15746
*            Locking file id containing the list file name information to be read only once
*            per job by an agent
*
* 04/03/10 - Task -23220 / Defect - 26890
*            Activation based services need not wait for the lock on the last id and
*            can continue with the next set of select as there is no dependency to switch
*            to the next job.
*
* 14/04/10 - Task:40455(Defect Ref:24572)
*            Transaction cache should be switched off during the executing of .LOAD and .SELECT routine
*
* 03/06/10 - Task 54532(Defect 52180)
*            BATCH.COMPANY is not loaded properly when BATCH.STATUS record is locked by some other agent
*
* 30/06/10 - Task : 63449 / Defect : 51212
*            When all the list file ids are locked by different agents, Repeated selects are performed
*            by an agent on the list file running a activation based service (SWIFT.OUT).
* 28/06/10 - Task 62301
*            Initialise das common variable "dasMode" before starting the Job
*            Defect: 60440
*
* 09/08/10 - Task : 74946 / Defect : 72282
*            When multiple single threaded jobs are attached in a batch process,
*            there are some single threaded jobs which are run twice and some single threaded
*            jobs are not run at all though the job.status is completed.
*
* 19/08/10 - Task : 77951 / Defect 75169
*            Check for data encryption before writing the data to the disk.
*
* 02/12/10 - Task- 114815 , Defect - 109452
*            If OP.CONSOLE field in SPF contains any values(like ON,TEST,RECORD,PERFORMANE ...) and
*            F.LOCKING record with the id "SEAT.TRACE" contains any process name then
*            update the SEAT.SCRIPT variable for the specific process alone.
*
* 14/12/10 - Task: 119848
*            Dev coding for Put CBE generation hooks into T24
*
* 24/02/11 - Task:160027(Defect:154581)
*            Global release has to be performed after processing every record routine.
*
* 25/02/11 - Task 161058 / Defect 132474
*            COB crash when same JOB.LIST that was used by multi threaded job was reused
*            by single threaded job.
*
* 15/02/11 - Task: 132957
*            Dev coding for JOB.PENDING events generated for jobs that don't run
*
* 6/7/2011 - Defect : 237532 / Task : 240179
*    The AGENTS field in JOB.TIMES file updated with greater value than the actual no.of agents processed
*            the respective job. It should be updated with actual no.of agents involved in completion of the job.
*
* 12/8/2011 - Defect : 257426 / Task : 259984
*    When the AGENT enters in the RUN.AHEAD situation, AGENTS field in JOB.TIMES file updated with greater value than
*            the actual no.of agents processed the respective job. It should be updated with actual no.of agents involved
*            in completion of the job.
*
* 14/11/11 - Defect : 301925/Task : 307714
*            Locking contentions found in the TSA.SERVICE
*
* 15/11/11 - Task: 303355, Enhancement - 239100
*            1. TV.SERVICE.TXN.DETAILS details record has been written for even if ther is no record to process
*               in TV capture environment.
*               Clearing TV Common variables for single threaded service
*
* 22/12/11 - Defect : 328638 / Task : 328630
*            Reverting the changes done in Defect 301925(Task 307714)
*
* 15/02/12 - Defect : 301925/Task :326117
*            Timed out - while waiting for lock F.TSA.SERVICE COB
*
* 23/03/12 - Task : 377062 / Ref Defect : 375825
*            Donot update the JOB.TIMES when the field ADDITIONAL.INFO of PGM.FILE is updated with ".NJT"
*
* 05/04/12 - Task-384607
*            BM events should be triggered only for COB and not for online services.
*
* 05/04/12 - Defect : 377176/Task :384757
*            JOB.TIMES not updated properly when the job does not process any records
*
* 06/04/12 - Task: 383306 / Defect: 371094
*            Avoid unnecessary Writes to LOCKING file.  Let it be done by LIST.OWNER.
*
* 17/08/12 - Task 457720 / Defect 457520
*            Uninitialised variable error encountered for WORST.ELAPSED.TIME.
*            Variable WORST.ELAPSED.TIME has been initialised.
*
* 09/11/12 - Task 515385/ Defect 503469
*            JIMI trace should be switched on before initiating the transaction management in order to support TAFJ Framework
*
* 28/12/12 - Enhancement:506349
*            Integtration framework is enhanced to design and emit events out of TSA Service jobs. This
*            change is to invoke an integration framework exit point handler for a job being processed
*            for each id selected.
*
* 31/01/13 - Task:465509 (Review Splunk App)
*            Logger() is used to update TAF Logs that will be used for Ops Monitoring product.
*            Job Times are logged in T24 as well as written to TAF/logs.
*
* 18/03/13 - Task 624679 / Defect 584568
*            Read DATES record and load TODAY variable every time before executing .RECORD routine for all online services.
*
* 14/01/13 - Task:621042, Defect - 621005
*            Common variable 'ordDetails' need to be cleared properly for every job.
*
* 03/06/13 - Task - 692951 / Defect - 692949
*     For better performance in COB, Removed Unncessary SLEEP conditions
*
* 06/06/13 - Task: 690213 / Defect : 672280
*            Do not preserve R.VERSION for subsequent jobs.  Initialize it every time.
*
* 28/06/13 - Task : 716752 / Defect : 708018
*            Invoke CLEARSELECT every time before building FULL.LIST and avoid memory accumulation.
*
* 14/08/13 - Task : 757098 / Defect : 757090
*            Updates on BATCH.STATUS file related to elapsed time consuming more time and affects the performance of COB.
*
* 19/08/13 - Task : 760399 / Defect : 740699
*            if a particular agent occupies more memory than 30 MB, then logoff.
*
* 22/08/13 - Task :762834 / Defect : 635317
*            The distribution of list records id layout should be changed such that the distributed job
*            list record ids starts from original id and till N-1.
*
* 12/09/13 - Task : 744373 / Defect : 744367
*            Code changed in INITIALISE paragraph, to identify whether the current jobs needs to be traced or not.
*            SEAT.TRACE record in F.LOCKING contains list of jobs which has results defined. The CHECK.SEAT paragraph
*            is removed, as the variable SEAT.TRACE.ON is being set in INITIALISE para.
*
* 26/9/2013 - Defect 740699 / Task 794127
*             1. The agent occupies more memory than 40MB will be logged off if SEAT trace enabled
*             and running in background mode. (changes done for the fix done in task 760399)
*             2. Sleep for 100 milli seconds in case of SEAT during process select.
*
* 29/01/14 - Task :901135 / Defect : 892834
*            When a cob job is run with the 'n' number of agents, the  AGENTS  field in JOB.TIMES
*            is updated with the agent count.
*
* 03/02/14 - Task:642323 (Splunk App) (Additional changes for Task:465509)
*            Added PROCESS.STAGE as part of JOB.INFO record to send the Stage into Logger()
*
* 14/04/14 - Task:964792/Enhancement 955296
*            Prepare IF before calling the record routine so that when IF invoked after record routine
*            has enough information to build events for both current and before image if the transaction
*
* 01/08/14 - Task:1074586 Defect:1070293
*            Select routine is called only once if the control list is marked as emptylist.
*
* 20/08/14 - Task: 1091103 / Defect: 1084723
*            When FULL.LIST is present check F.LOCKING to make sure that the
*            current job list is associated with the current job
*
* 16/09/14 - Task 1115020 / Defect  1096968
*            JOB.POSITION field is introudced to store job postion information in JOB.TIMES
*            More than 10 multi value positions(say 20) are allowed only for
*            .HJTP setup jobs
*
* 09/02/15 - Task 1249305 / Defect  1249304
*            EB.EOD.REPORT.PRINT job and non standard jobs to sleep for 5 seconds during END.GAME.
*            All other jobs to Sleep for 100 milli seconds during END.GAME.
* 23/03/15 - Task 1281694 / Defect 1270935
*            Removed TEC Update on JOB.SELECT and JOB.PROGRESS for better performance.
*
* 29/09/15 - Task: 1486184  / Defect: 1479614
*            Check F.LOCKING regardless of FULL.LIST to make sure that
*            the current job list is associated with the current job
*
* 07/12/16 - Task 1947609 / Defect 1920032
*            The second agent is not pick up any record to process,
*            then it will update wrongly READ.WRITE.CACHE variable in the JOB.TIMES and then resume the 1st agent.
*            It will not acquire the lock and skip the process of updating the JOB.TIMES.
*
* 12/01/17 - Task 1920559 / Defect 1867067
*			  Added a new common variable C$MESSAGE.TOKEN
*
* 19/02/17 - EN 2023440 / Task 2023496
*            Record code coverage , calls and common dump for record routine.
*            Logs are captured either for 'Job.Name-Txn.Id' or 'Job-Name-Script.Id' based on definition in EB.CODE.DIAGNOSTICS table.
*
* 05/01/17 - Task 1950041 / Defect 1964675
*            To use relative position of the agent instead of actual agent number for offset calculation
*
*
* 19/02/17 - EN 2023440 / Task 2043342
*			 Pass ContextId to EB.CODE.DIAGNOSTICS.ACTION for Action 'START'
* 12/04/17 - Task 2086584 / Defect 2085969
*			 Uninitialised variable error corrected
*
* 04/05/17 - Task 2110595 / Defect 2109789
*            TotalKeys variable is properly initialised
*
*
* 16/04/18 - Task 2551717 / Defect 2548652
*            To avoid same job allocationg to different service , TIMESTAMP() value is stored in the CONTROL.LIST
*
* 12/07/18 - Defect: 2672225 / Task: 2675607
*          - Improvement for the LIST.SAMPLE for batch jobs processing.
*          - Activation file name from Pgm record.
*
* 23/12/2019 - Defect 3492935
*              DW.EXPORT.PARAM Setup Causing Performance Issue
*
* 14/02/2020 - Defect 3589705/Task 3589864
*            - If TSA.STATUS is null then agent should Fatal error and it should stop processing with fatal error
*              and check the Read TSA.STATUS record only if agent is present.
*
* 27/06/2019 - Defect 3635068 / Task 3636544
*              System should not build the FULL.LIST if any other agent started has processing the records already
*              JOB.PROGRESS is set to Null in PROGRAM.ABORT for services which are set to AUTO.
*
* 13/04/2020 - Task 3689239
*              Do not logoff tSA port when EB.PRINT job is being executed on the session.
*
* 06/07/20 - Task 3840674 / En 3798636
*            Handling the corrupt records in service
*
* 24/09/20 - Defect - 3981762 / Task - 3987678
*            Invoke DLM api to delete the records in DLM database when record is deleted from LIVE
*
* 22/10/20 - Task: 4037900
*            Force heartbeat to update processing contracts when previous job progress is selecting
*
* 22/10/2020 - SI 3817278/Enhancement 3894821
*              Incremental extraction without duplicates - R17
*
*-----------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BATCH.FILES
    $INSERT I_SEAT.COMMON     ;*CI_10041844 S/E
    $INSERT I_TSA.COMMON      ;* EN_10001864 S/E
    $INSERT I_SHARED.SERVICE.COMMON
    $INSERT I_F.COMPANY
    $INSERT I_F.SPF
    $INSERT I_F.JOB.TIMES
    $INSERT I_F.TSA.STATUS    ;* EN_10001864 S/E
    $INSERT I_F.TSA.PARAMETER ;* EN_10001864 S/E
    $INSERT I_F.PGM.FILE
    $INSERT I_F.VERSION
    $INSERT I_F.DATES         ;* CI_10042787S/E
    $INSERT I_DW.COMMON
    $INSERT I_TV.COMMON       ;* Inserted to get the value of "tvMode" and store the start and end time of a service.
    $INSERT I_IO.EQUATE       ;* Inserted to use the cache variables
    $INSERT I_RC.COMMON
    $INSERT I_F.TSA.SERVICE
    $INSERT I_TEC.COMMON
    $INSERT I_STATIC.CACHE.COMMON
    $INSERT I_DAS.COMMON
    $INSERT I_ENCRYPT.COMMON
    $INSERT I_TV.TRANS.COMMON
    $INSERT I_GTS.COMMON
    $INSERT I_F.TSA.ERROR.LIST
    $INSERT JBC.h
*-----------------------------------------------------------------------------
*

    GOSUB INITIALISE
    BEGIN CASE
        CASE ACTIVATION.FILE      ;* Permanent agent driven from activation file
            GOSUB PROCESS.ACTIVATION        ;* Scan the activation file
        CASE SELECT.AHEAD         ;* We're trying to prepare the job list ahead of schedule
            READ CONTROL.LIST FROM F.BATCH.STATUS,FLAG.ID ELSE  ;* And it's not been prepared yet
                GOSUB PROCESS.SELECT        ;* Build list file
            END
        CASE OTHERWISE
            GOSUB PROCESS.SELECT  ;* Build list file
    END CASE

RETURN
*-----------------------------------------------------------------------------
PROCESS.SELECT:
* Build the list file and process until it's empty


    LOOP
        JOB.PROGRESS = 3      ;* In processing control
        CALL SERVICE.HEARTBEAT          ;* Tell em we're still alive
        MAX.LIST.ID = ''      ;* Will hold the number of IDs in the list file
LOCK.CONTROL.LIST:
        READU CONTROL.LIST FROM F.BATCH.STATUS, FLAG.ID LOCKED        ;* Get hold of the control list
            IF SELECT.AHEAD THEN        ;* Another agent is already performing the SelectAhead
                GOTO PROGRAM.ABORT      ;* Get out of here immediately
            END
            IF R.SPF.SYSTEM<SPF.OP.CONSOLE,1> THEN  ;* if SEAT trace enabled
* 2 seconds sleep is too costly in terms of performance in regression, so changed to 100 milli seconds
                CALL !SLEEP$(100) ;* Wait a couple of milli seconds
            END ELSE   ;* no seat trace enabled
                SLEEP 2 ;* wait a couple of seconds
            END
            CALL SERVICE.HEARTBEAT      ;* We need to keep the tSM informed - otherwise we'll get killed
            GOSUB CHECK.SERVICE         ;*See if we still need to continue with this job
            GOTO LOCK.CONTROL.LIST
        END ELSE    ;* In case we are restarting - wait for lock!!!
            CONTROL.LIST = "" ;* First time through for this job
        END
    UNTIL CONTROL.LIST = PROCESSED      ;* Until everything has been done ; * BG_100003752 S/E
        GOSUB CHK.STILL.HOLD.LIST.FILE  ;* check whether we still hold the list file
        IF CONTROL.LIST = "" THEN       ;* First time through
            GOSUB START.JOB   ;* Init job times
        END
* GET.LIST.FROM.POOL is moved here to make the lock happen only once in LOCKING file.
* All other agents get the list name from LOCKING file just by reading it without doing lock
* Get the list file name once per job
        IF NOT(FN.LIST.NAME) THEN       ;* if the list file name has not been found yet
            GOSUB GET.LIST.FROM.POOL    ;* Get a list file from the pool
        END

        IF CONTROL.LIST<1,2> # PROCESSING AND CONTROL.LIST<1,2> # EMPTYLIST THEN    ;* ie List not built yet and list not marked as emptylist
            JOB.PROGRESS = 2  ;* Selecting contracts
            LAST.CONTACT.TIME = -99     ;*Forces heartbeat
            CALL SERVICE.HEARTBEAT      ;* We're still standing
            GOSUB BUILD.LIST  ;* Call the select routine to build the list
        END ELSE
            WRITE CONTROL.LIST ON F.BATCH.STATUS, FLAG.ID   ;* Write cause we locked it - no need for Trans
        END
        IF SELECT.AHEAD THEN  ;* The list is built - we can't do anymore
            RETURN  ;* This will go straight back to SJR
        END
        CALL OCOMO("Using list file ":FN.LIST.NAME)         ;* List has been built for us
        CALL OCOMO("Control list ":CONTROL.LIST[1,50])      ;* BJC s/e
        JOB.START.TIME = TIME()         ;* If we're the first agent to log our progress then this will be the start time
        IF CONTROL.LIST<1,2> = PROCESSING THEN    ;* This means we're ready to process contracts
            IF JOB.PROGRESS EQ 2 THEN           ;* if previous progress is selecting contracts
                LAST.CONTACT.TIME = -99         ;* force the heartbeat to update as processing
            END
            JOB.PROGRESS = 1  ;* Processing contracts
            CALL SERVICE.HEARTBEAT
            GOSUB PROCESS.LIST          ;* Select the list file and do the work
        END         ;* BG_100005787 e
        JOB.PROGRESS = 3      ;* Back in processing control
        CALL SERVICE.HEARTBEAT
        IF CONTROL.LIST NE PROCESSED THEN         ;* The job has not been marked finished yet
            GOSUB ADVANCE.CONTROL       ;* Go to the next item in the control list (if it's there)
        END ELSE    ;* if there are no keys processed
            GOSUB RELEASE.LIST.FILE     ;* delete the locking information pertaining to the job
        END
    REPEAT

    IF CONTROL.LIST = PROCESSED THEN    ;* We're finished
        RELEASE F.BATCH.STATUS, FLAG.ID ;* Because we locked it at the top of the loop
* GOSUB RELEASE.LIST.FILE         ;* need not be called at the end as allocation is done only after getting the lock and the status is not processed
    END   ;* BG_100003752 Ends

* If job times has not been ended and when JOB.START.TIME is set,then update JOB.TIMES with actual process details of respective jobs.

    IF NOT(JOB.TIMES.END) AND JOB.START.TIME NE '' THEN     ;* job times has not been ended yet.
        CALL EB.TRANS('START',RMSG)
        JOB.OPERATION = 'END ': TIME()  ;* End of job time
        GOSUB UPDATE.JOB.TIMES
        IF CURR.JOB.ELAPSED.TIME NE '' THEN       ;* When Elapsed time is recorded
            GOSUB UPDATE.BATCH.STATUS.SERVICE     ;* Update BATCH.STATUS for service
        END
        CALL EB.TRANS('END',RMSG)
    END

RETURN
*-----------------------------------------------------------------------------
START.JOB:
* This thread has started the job. Update job times....

    CALL OCOMO("Starting job")          ;* BG_100005787 S/E
    CALL EB.TRANS('START',RMSG)
    JOB.OPERATION = 'START ':STIME      ;* Create new job times value for this job
    GOSUB UPDATE.JOB.TIMES    ;* Do it
    CALL EB.TRANS('END',RMSG)

RETURN
*-----------------------------------------------------------------------------
BUILD.LIST:
* Call the select routine and build the list file

    CALL EB.TRANS('START',RMSG)

    KEYS.PROCESSED = -1       ;* Populated by BATCH.BUILD.LIST - initialise to -1 in case the select routine doesn't call BBL
    MAX.LIST.ID = ''          ;* Will hold the number of IDs in the list file
    START.TIME = TIME()       ;* So we can calculate the time taken to do the select

    BEGIN CASE
        CASE STANDARD.JOB         ;* Standard multi-thread jobs have list routines
            CALL OCOMO('Calling..':SELECT.ROUTINE)
            CACHE.OFF = 1         ;*Don't load the cache
            dasMode = dasReturnResults      ;* DAS should return the results in default
            CALL @SELECT.ROUTINE  ;* Select the records to process and updates CONTROL.LIST if we need to call this more than once
            CACHE.OFF = 1         ;* make sure that the cache is turned off
            MAX.LIST.ID = KEYS.PROCESSED<2> ;* Number of IDs in the list file
            KEYS.PROCESSED = KEYS.PROCESSED<1>        ;* Number of contracts to process
            IF KEYS.PROCESSED = -1 THEN     ;*    In case the select routine doesn't call BBL
                KEYS.PROCESSED = 0          ;*    Set KEYS.PROCESSED to 0
            END
            CALL OCOMO('Control list.. ':CONTROL.LIST[1,50])    ;* Just the first 50 chars
        CASE OTHERWISE  ;* Non MT job
            WRITE 'SingleThread' ON F.LIST.NAME, '1'  ;* Just one id on the list file ensures single thread activity only
            KEYS.PROCESSED = 1    ;* As it's single thread we can only record 1 key processed in job times
            MAX.LIST.ID = KEYS.PROCESSED    ;* Number of IDs in the list file
            SELECT.STATEMENT='SingleThread' ;* to indicate single threaded routine in JOB.TIMES
    END CASE

* save the control list value to be updated in JOB.TIMES, since if the current control list
* multivalue is the last one and if its selection returns zero record,we set the CONTROL.LIST
* to 'processed'.
    SAVE.CONTROL.LIST =CONTROL.LIST

    IF KEYS.PROCESSED NE 0 THEN         ;* Returned from BATCH.BUILD.LIST - number of contracts to process
        CONTROL.LIST<1,2> = PROCESSING  ;* Signals that we've finished the building of the list
        CONTROL.LIST<1,3> = MAX.LIST.ID ;* Store so the other threads can see it
        CONTROL.LIST<1,4> = KEYS.PROCESSED        ;* store Number of IDs in the list file
        CONTROL.LIST<1,8> = TIMESTAMP()        ;*Store the timestamp
    END ELSE
        IF CONTROL.LIST<2> = '' THEN    ;* Nothing left in the control list
            CONTROL.LIST = PROCESSED    ;* So signal we've finished to all threads END
        END ELSE    ;* BG_100005787 ends
            CONTROL.LIST<1,2> = EMPTYLIST         ;*Empty list update it as others can get hold and do a sel. again
        END
    END

    END.TIME = TIME()         ;* To calculate the time the select took
    IF END.TIME LT START.TIME THEN      ;* Flipped over midnight
        SELECT.TIME = END.TIME + (24*3600) - START.TIME     ;* 24hours of seconds
    END ELSE
        SELECT.TIME = END.TIME - START.TIME       ;* How long did the select take
    END

    WRITE CONTROL.LIST ON F.BATCH.STATUS, FLAG.ID ;* Start the threads
    JOB.OPERATION = 'KEYS ':KEYS.PROCESSED        ;* Update job times with number of keys to process and the time of the select
    GOSUB UPDATE.JOB.TIMES    ;* Do it
    IF COB.SERVICE THEN       ;*Update the Job only for COB
        GOSUB UPDATE.TEC.JOB.SELECT     ;* Update the JOB.SELECT event only for COB
    END
    CALL EB.TRANS('END',RMSG)

    CALL SERVICE.HEARTBEAT    ;* Tell em we're still alive ; * EN_10001864 s/e

RETURN
*-----------------------------------------------------------------------------
ADVANCE.CONTROL:
* The list is finished - see if there's anything left in control list - if so
* then put it to the top of the list and begin again. If not then set it to
* processed to finish off.

    CALL EB.TRANS('START',RMSG)

    IF BATCH.COMPANY NE ID.COMPANY THEN
        CALL LOAD.COMPANY(BATCH.COMPANY)          ;*In case it had changed in record routine
    END

    READU NEW.CONTROL.LIST FROM F.BATCH.STATUS, FLAG.ID LOCKED
        CALL EB.TRANS("END","")         ;*CI_10044016 S/E
        RETURN      ;*Someone has already done it or doing it now
    END THEN        ;* Ensure we've got control
        IF NEW.CONTROL.LIST = CONTROL.LIST THEN   ;* This is the first thread to get hold of the record after completing the list
            DEL NEW.CONTROL.LIST<1>     ;* Pop from stack
        END
    END
    IF NEW.CONTROL.LIST = '' THEN       ;* We're finished
        NEW.CONTROL.LIST = PROCESSED    ;* Signal this is the end
        READ R.LIST.FILE.NAME FROM F.LOCKING,FLAG.ID THEN   ;* If found
            GOSUB RELEASE.LIST.FILE     ;* Allow the list file to be used by another job
        END
    END
    WRITE NEW.CONTROL.LIST ON F.BATCH.STATUS, FLAG.ID       ;* And store - in case we need to restart
    
    IF NOT(TSA.ERROR.LIST.MISSING) THEN             ;*enable the functionality only if file is present
        READU R.TSA.ERROR.LIST FROM F.TSA.ERROR.LIST, FLAG.ID LOCKED
            NULL            ;*dont wait for the lock
        END THEN          ;*check if there is entry in TSA.ERROR.LIST for the current job
            DELETE F.TSA.ERROR.LIST, FLAG.ID              ;*delete the entry
        END ELSE
            RELEASE F.TSA.ERROR.LIST, FLAG.ID       ;*release the lock when there is no record
        END
    END

    CALL EB.TRANS('END',RMSG) ;* Hence we've done this one and now onto the next (if there is a next)

RETURN
*-----------------------------------------------------------------------------
PROCESS.ACTIVATION:
* The 'job' is driven from an activation file (ie put something in the file and it will process it)
* These job's never really end - they stop and start controlled by the tSM - when the service changes it
* leaves via program.abort

    MAX.LIST.ID = ''          ;* This will force a selection rather than building a list from 1 to MAX.LIST.ID
    LOOP
    
    	CALL EB.TRANS('START',RMSG)
        JOB.OPERATION = 'START ':TIME()      ;* Create new job times value for this job
        GOSUB UPDATE.JOB.TIMES    ;* Do it
        CALL EB.TRANS('END',RMSG)
        JOB.START.TIME = TIME()
                
        GOSUB PROCESS.LIST    ;* Process records on the list file
        GOSUB CHECK.SERVICE   ;* See if we need to shut down
        
        CALL EB.TRANS('START',RMSG)
        JOB.OPERATION = 'END ': TIME()        ;* End of job time
        GOSUB UPDATE.JOB.TIMES      ;* update the writes and include the agent in JOB.TIMES
        CALL EB.TRANS('END',RMSG)
        AcEnd = 1
                
        SLEEP SERVICE.REVIEW.TIME       ;* List file empty sleep and then try again
        CALL SERVICE.HEARTBEAT          ;* Tell the tSM we're ok
    REPEAT

RETURN
*-----------------------------------------------------------------------------
PROCESS.LIST:
* Loop through selecting the list file and processing the contracts

    SEL.CMD = 'SELECT ' : FN.LIST.NAME :' SAMPLE ':LIST.SAMPLE        ;* Make sure we don't end up with a huge list

    FULL.LIST = 'initialise'  ;* This will contain all the keys in the list - initialise means build it first time round
    RECORD.MISS = 0 ;* Count of the number of locks hit or list records missing
    MAX.MISS = 20   ;* Default will be reset to 5% of the number of keys to process
    EOL = 0         ;* Flag to indicate end of the list
    NO.RECORDS.PROCESSED.COUNT = 0      ;* No of time records has not been processed in this lot
   
    IF USE.RELATIVE.DISTRIBUTION THEN						;* Check if relative distribution is enabled
        RelPos= R.TSA.STATUS<TS.TSS.RELATIVE.POSITION>		;* retrieve the position of agent
    END ELSE
        RelPos = AGENT.NUMBER								;* Use actual agent number
    END
    LOOP UNTIL EOL = 1        ;* Until there's nothing left in the list file
        ID.LIST = ''          ;* This holds just the list for this agent
        CALL SERVICE.HEARTBEAT          ;* Tell em we're still alive
        IF FULL.LIST = '' OR FULL.LIST = 'initialise' OR RECORD.MISS GE MAX.MISS THEN     ;* Either we've exhausted this sample or the agents are clashing
* Removed SYSTEM(11) condition to invoke CLEARSELECT every time.
            CLEARSELECT       ;* Make sure there's no active select list when calling the record routine!

            JOB.PROGRESS = 4  ;* Selecting list file
            CALL SERVICE.HEARTBEAT
            GOSUB GET.FULL.LIST         ;* Return with a full list of keys to process
            IF FULL.LIST = '' THEN      ;* No more selected
                EOL = 1       ;* Ok we're done
            END
            RECORD.MISS = 0   ;* Reset ready for next loop
        END
        IF FULL.LIST THEN     ;* Something in the list file
            GOSUB EXTRACT.PORTION       ;* Extract my portion of the list to work on
            GOSUB CHECK.JOB.STATUS      ;* Make sure another thread hasn't finished the job
            IF NOT(EOL) THEN  ;* We're still ok to process - another thread hasn't finished the list
                JOB.PROGRESS = 3        ;* Processing contracts
                CALL SERVICE.HEARTBEAT
                GOSUB PROCESS.PORTION   ;* Process each list key in my portion
*
                IF ACTIVATION.FILE THEN
                    IF NO.RECORDS.PROCESSED THEN  ;* no records has been processed and its an activation file
                        NO.RECORDS.PROCESSED.COUNT += 1     ;* increment the no records processed count
                        IF NO.RECORDS.PROCESSED.COUNT = 2 THEN        ;* if two consecutive runs has processed no records
                            EOL = 1     ;* end the list and sleep for the review time
                        END
                    END ELSE  ;* reset it as we need to sleep for the review time ony if there are two consecutive times records not processed by the agent
                        NO.RECORDS.PROCESSED.COUNT = 0      ;* reset it as there are records processed.
                    END
                END
*
            END
        END
    REPEAT
*
    GOSUB GLOBAL.RELEASE      ;* Make sure there are no locks left lying around from the record routines

RETURN
*-----------------------------------------------------------------------------
GET.FULL.LIST:
* The first time through we can build a list of keys internally as the ID to
* the list file is now wholly numeric. Hence, get the total number of keys - which
* is stored in the CONTROL.LIST<1,3> (from BATCH.BUILD.LIST), and build FULL.LIST
* from 1 to N.
*
    MAX.LIST.ID = CONTROL.LIST<1,3>     ;*Last number written to the list file
    PROCESSED.ANY = CONTROL.LIST<1,5> ;*Records processed in another agents.
    BEGIN CASE
        CASE FULL.LIST = 'initialise' AND MAX.LIST.ID AND NOT(PROCESSED.ANY) ;* First time - build 'manually'
            FULL.LIST = ''        ;* Ready to populate
            FOR LIST.ID = 1 TO MAX.LIST.ID  ;* So for all IDs
                FULL.LIST<-1> = LIST.ID     ;* Build up internal list
            NEXT LIST.ID
            NUMBER.OF.KEYS = MAX.LIST.ID    ;* This is used when extracting my portion
        CASE FULL.LIST = 'initalise'        ;* First time but no MAX.LIST - belt and braces check
            FULL.LIST = ''        ;* Make sure this is empty!
            CALL EB.READLIST(SEL.CMD, FULL.LIST, '', NUMBER.OF.KEYS, '')  ;* Get the list from the list file

        CASE OTHERWISE  ;* Run out of IDs in full list or session other than the one which has run the .SELECT routine - select to make sure we've done all the keys
            FULL.LIST = ''        ;* Make sure this is empty!
            CALL EB.READLIST(SEL.CMD, FULL.LIST, '', NUMBER.OF.KEYS, '')  ;* Get the list from the list file
    END CASE

    IF AcEnd THEN
        TotalKeys = NUMBER.OF.KEYS
        AcEnd = 0
    END ELSE
        TotalKeys += NUMBER.OF.KEYS
    END
	
    MAX.MISS = INT(NUMBER.OF.KEYS*0.005+1)        ;* When we've 'missed' MAX.MISS records whe reading - then come back and select again
    IF MAX.MISS LT 20 THEN
        MAX.MISS = 20         ;* default
    END

RETURN
*-----------------------------------------------------------------------------
PROCESS.PORTION:
* Process each list key in my portion

    IF NOT(CRITICAL.JOB) AND NOT(TSA.ERROR.LIST.MISSING) THEN           ;*check for corrupt records list for a non-critical job
        READ R.TSA.ERROR.LIST FROM F.TSA.ERROR.LIST, FLAG.ID ELSE
            R.TSA.ERROR.LIST = ''       ;*clean up the variable when there is no record
        END
    END

    RECORD.MISS = 0 ;* When we've missed MAX.MISS records - select again
    REMAINING.LIST.KEYS = DCOUNT(ID.LIST,@FM)     ;* Number of list keys in MY portion - check job status when this reduces to LT 20
    LOCK.COUNT = 0  ;*Monitor the number of locks
    END.GAME = 0    ;*Se when all the records are locked
    DISPLAY.MESSAGE = 1       ;* Flag is set to trigger "Available list IDs" message if an agent is waiting for the last record of the job to be processed.
    NO.RECORDS.PROCESSED = 1  ;* Check if atleast one record has been processed..

    LOOP  ;* Process each contract in turn.
    REMOVE LIST.KEY FROM ID.LIST SETTING YDELIM WHILE LIST.KEY:YDELIM AND RECORD.MISS LT MAX.MISS

        REMAINING.LIST.KEYS -=1         ;* Number of keys left in my portion

        LOOP        ;* Loop through each contract in the list record
READ.LOCK.RECORD:
            IF REMAINING.LIST.KEYS LT JOB.THRESHOLD THEN
                GOSUB CHECK.JOB.STATUS  ;* Make sure the job hasn't been finished
                IF EOL THEN   ;* Means another thread has finished the list
                    RETURN    ;* Back to process list
                END
            END ELSE
                IF NOT(ACTIVATION.FILE) AND FULL.LIST EQ "" THEN          ;* Check the list file only when we are at the tail of our processing
                    GOSUB CHK.STILL.HOLD.LIST.FILE    ;* See whether am holding valid list file still
                END
            END
            READU LIST.RECORD FROM F.LIST.NAME, LIST.KEY LOCKED       ;* Record locked so nearing end
                LOCK.COUNT +=1          ;*Number of locks encountered when processing this portion
                IF LOCK.COUNT GE NUMBER.OF.KEYS AND (FULL.LIST EQ "" OR NOT(STANDARD.JOB)) THEN     ;* All list records are locked . wait for lock in case of single threaded job.
                    IF NOT(ACTIVATION.FILE) THEN  ;* END.GAME not required for Activations as there is no dependency to switch to next job and it can continue with the next set of select
                        END.GAME = 1    ;* Ready to sleep
                        IF DISPLAY.MESSAGE THEN   ;*  Available List IDs message is trigerred only once per job and agent.
                            CALL OCOMO('Available list IDs exhausted')
                            DISPLAY.MESSAGE = 0   ;* Reset the flag
                        END
                    END
                END

                BEGIN CASE    ;* When encountering locks - we could be nearing the end of the list
                    CASE END.GAME AND CONTROL.LIST<2> = '' AND NOT(LIST.OWNER) AND RUN.AHEAD  ;* Yes near the end of the list (and there's no more lists to build)
                        JOB.INFO = -1       ;* This is the return argument to S.JOB.RUN - it tells SJR to try and run another job

* When the agent enters in RUN.AHEAD situation, and atleast processed single id then update the 'processname-job'
* in common which will indicates the agent registration pending. This will later used when updating AGENT count in JOB.TIMES.

                        IF LISTS.PROCESSED THEN       ;* Agent processed atleast single id
                            IF AGENT.UPDATE.PENDING.JOBS THEN   ;* Append the common with previous values
                                AGENT.UPDATE.PENDING.JOBS<-1> = PROCESS.NAME:'-':JOB.NAME
                            END ELSE        ;* Value stored at first
                                AGENT.UPDATE.PENDING.JOBS = PROCESS.NAME:'-':JOB.NAME
                            END
                        END

                        CALL OCOMO('Job nearing completion .... Trying to run another job')
                        GOTO PROGRAM.ABORT  ;* Exit immediately
                    CASE END.GAME ;* Nearing  the end of this list - but there's another one to build so don't leave this job (sleep and try again)
                        SLEEP.TIME = 5      ;* sleep for 5 secs and wait on this record - to avoid repetitive selects/reads
                        IF MAX.LIST.ID > 100 OR CONTROL.LIST<2>  THEN     ;* if we have actually written more than 100 records into .LIST file or when next control list exists
* SLEEP.TIME = 1  ;* then sleep for a short time and try to get the record and distribute it
                        END
                        IF (JOB.NAME EQ 'EB.EOD.REPORT.PRINT') OR NOT(STANDARD.JOB) THEN
                            SLEEP SLEEP.TIME    ; * sleep for 5 seconds when the job is EB.EOD.REPORT.PRINT or a single threaded one
                        END ELSE
                            MSLEEP 100 ; * sleep for 100 milli seconds for all other jobs
                        END
                        JOB.PROGRESS = 6    ;* Waiting on list record
                        CALL SERVICE.HEARTBEAT        ;* Tell the tSM we're ok
                        GOSUB CHECK.SERVICE ;*In case we have been told to finish the job
                        JOB.PROGRESS = 3    ;* Reset incase lock becomes free
                        GOTO READ.LOCK.RECORD         ;* Try again
                    CASE OTHERWISE          ;* Just an ordinary clash with another thread
                        RECORD.MISS +=1     ;* Too many of these indicates we might be at the end of the list (ie the other threads have processed the rest)
                        EXIT      ;* Someone else has this list record go onto the next one
                END CASE
            END THEN          ;* We've got it
                IF LIST.RECORD <> '' THEN         ;* BG_100005787 S/E - belt and braces check
*Condition pertaining to the distribution of list records is moved below.
* Check the JOB.STATUS when the list of remaining keys are less than the actual number of session
                    IF END.GAME OR NOT(STANDARD.JOB) OR FULL.LIST = '' OR REMAINING.LIST.KEYS LT (NUMBER.OF.SESSIONS + 1) THEN    ;* If END.GAME is set then check the JOB.STATUS again OR Make sure that the single threaded job has not been completed yet or when nearing end of the list
                        GOSUB CHECK.JOB.STATUS    ;* Make sure that ID belongs to the current Job
                        IF EOL THEN     ;* Means another thread has finished the list
                            RETURN      ;* Back to process list
                        END
                    END
                    IF END.GAME OR (MAX.LIST.ID > 100 AND FULL.LIST EQ "" AND RECORD.MISS) THEN     ;* If END.GAME is set check the JOB.STATUS again or when agent hold final list
                        IF LIST.RECORD<2> THEN    ;*More than one key in the list
                            GOSUB DISTRIBUTE.LIST.RECORDS   ;*Try to split up the list records
                            RETURN      ;*Go back to do another SELECT
                        END
                    END
                    GOSUB PROCESS.RECORD          ;* Do it then and update the list record too
                    NO.RECORDS.PROCESSED = 0      ;* alteast one record has been processed
                END ELSE
                    DELETE F.LIST.NAME,LIST.KEY   ;* Delete the List file so that agent can get the lock
                END
                GOSUB GLOBAL.RELEASE    ;*  GB0101735 in case a record routine leaves a lock
            END ELSE
                RELEASE F.LIST.NAME, LIST.KEY     ;* Release in case somebody else has processed
                RECORD.MISS +=1         ;* Too many of these indicates we might be at the end of the list (ie the other threads have processed the rest)
                EXIT          ;* Record has already been processed - go on to the next list record
            END
        WHILE LIST.RECORD     ;* Any contracts left in here
        REPEAT      ;* Next contract
    REPEAT          ;* Next list record

RETURN
*-----------------------------------------------------------------------------
PROCESS.RECORD:
* Loop through the contract list from the list record and process each contract.
    C$RPT.DEST.PRINTER = SAVE.BATCH.PRINTER       ;*save and restore the vaiable for Default printer
    IF NOT(FORCE.TIMEOUT.LOGOFF)  THEN  ;* Tell the tsa status what we're doing - BUT don't put this in the txn boundary in case the single threader takes too long - you can lock up the tSM ;* CI_10043592 S/E
        JOB.PROGRESS = 7      ;* Single threaded - tells the tSM not to kill me if I take too long
        LAST.CONTACT.TIME = -99         ;* Forces heartbeat to record JOB.PROGRESS
        CALL SERVICE.HEARTBEAT          ;* Update TSA.STATUS
    END
    IF NOT(COB.SERVICE) AND NOT(INDEX(TSA.SERVICE.NAME,'T24.UPGRADE',1)) AND NOT(INDEX(TSA.SERVICE.NAME,'RUN.CONVERSION',1)) THEN ;*If not of COB services ,T24.UPGARDE,RUN.CONVERSION
        GOSUB LOAD.DATES      ;*Read dates record before calling .RECORD for all services
    END
    CONTRACT$ID = ''          ;* Initialise

    IF SEAT.TRACE.ON AND R.TSA.STATUS<TS.TSS.CURRENT.SERVICE> NE 'SEAT.INJECTOR' THEN     ;* We're in tracing mode
        SEAT.DETAILS = ''; SEAT.SCRIPT = ''       ;* It needs to be setup everytime to avoid invoking the wrong tests; *CI_10042787/S ; * BG_100011810S/E
        CALL T.SEAT('ON','')  ;* Start the performance trace (only during COB and for other than SEAT.INJECTOR service) - if allowed to; * CI_10042787/E
    END
*Switch on the JIMI trace before starting txn management
    IF TXN.MGMT THEN          ;* Which is the default
        GOSUB DW.PROCESSING
        CALL EB.TRANS('START',RMSG)     ;* Wrap a transaction around the processing of the contract/bulk contract
    END

    CALL EBSetMessageToken('BATCH.JOB.CONTROL')
   
    ASSIGN 0 TO SYSTEM(1036)  ;* Clear lock collision counter - so the TEC will ignore collisions from BJC
    KEY.TO.PASS = ''          ;* Initialise

    USER.INFO=@USERSTATS      ;* get the current user information
    WRITE.CNT.START=USER.INFO<20>       ;* get the current writes count

*EN_10003752 S
    IF KEYS.ONLY THEN         ;* If this is set on the PGM record then ignore list record just use the key
        CONTRACT.LIST = LIST.KEY
    END ELSE
        CONTRACT.LIST = LIST.RECORD<1>  ;* Take the first field
    END
*EN_10003752 E

    BATCH.THREAD.KEY = LIST.KEY         ;* Store in common - in case of crash
    returnedContractList = ''           ;* initialise before usage
    IF CONTRACT.LIST <> '' THEN         ;* To be sure   ; * BG_100005787 e
        BEGIN CASE
            CASE STANDARD.JOB     ;* Normal MT job
                LOOP REMOVE CONTRACT$ID FROM CONTRACT.LIST SETTING D WHILE CONTRACT$ID <> ''  ;* Handle bulk list of contracts
                    IF SEAT.TRACE.ON THEN   ;*If OP.CONSOLE field in SPF contains any values(ON,TEST,PERFORMANCE,RECORD...) and 'SEAT.TRACE' record in F.LOCKING contains any process name then update the SEAT.SCRIPTS variable for the specific process alone
                        SEAT.SCRIPT<4,-1> = CONTRACT$ID         ;* CI_10042787 S/E; * BG_100011810S/E  populate the variable only when SEAT is used.
                    END
                    KEY.COUNT +=1 ;* Maintain a count of the number of contracts this thread has done
                    TEC$EVENT.ID = ''       ;*initialised for COB events .multi threaded jobs
                    TEC$EVENT.HOLD.ID = ''

                    ContextId = JOB.NAME:'-':CONTRACT$ID ;* Pass context ID as 'Job.Name-Txn.Id' to dump log files
                    CALL EB.CODE.DIAGNOSTICS.ACTION('START',ContextId,'','') ;* Start recording code coverage , calls and common dump based on definition in EB.CODE.DIAGNOSTICS table.

                    IF NOT(CRITICAL.JOB) THEN           ;*check whether the current job is critical
                        contractDets<1> = FLAG.ID
                        contractDets<2> = CONTRACT$ID
                        ASSIGN contractDets TO SYSTEM(5010)     ;*assign current contract details to SYSTEM(5010) only for a non-critical job
                    END
                
                    GOSUB CALL.RECORD.ROUTINE         ;* Process the contract
                    ASSIGN "" TO SYSTEM(5010)         ;* clear value in SYSTEM(5010) after processing

* We keep collecting all the pass back keys for a bulk of items being processed
                    IF KEY.TO.PASS<2> THEN
                        returnedContractList<1,-1> = KEY.TO.PASS<2> ;* This is the list of contracts that we've received
                    END

                    CALL EB.CODE.DIAGNOSTICS.ACTION('STOP',ContextId,'','') ;* Stop and dump code coverage, calls and common dumps


                REPEAT
* Restore this into the KEY.TO.PASS<2>
                IF returnedContractList NE "" THEN
                    KEY.TO.PASS<2> = ""
                    KEY.TO.PASS<2> = returnedContractList  ;* Store the consolidated information as we need to push them all into job.list/queue
                    returnedContractList  = "" ;* Reset it to null
                END
                GOSUB CHECK.CACHE ;* checks whether the record routine used the cache and write cache updates
                GOSUB DW.EXPORT.PROCESS  ; *DW Processing specialy for EXPORT
                CALL CLEAR.CACHE  ;* MAke sure the cache is cleared up at the end of Bulk list
                SET.CACHE=0       ;* cache off
                GOSUB SET.CACHE.VARIABLES   ;* reset the cache varables

            CASE RECORD.ROUTINE[' ',1,1]='EXECUTE'    ;* Something to execute rather than call
                KEY.COUNT +=1     ;* Maintain a count of the number of contracts this thread has done
                ECOMMAND = RECORD.ROUTINE[' ',2,999]  ;* The command to execute
                CALL OCOMO('Executing... ':ECOMMAND)  ;* Tell the como
                EXECUTE ECOMMAND  ;* Do it
            CASE OTHERWISE        ;* Non-Standard single thread job
                KEY.COUNT +=1     ;* Maintain a count of the number of contracts this thread has done
                IF SEAT.TRACE.ON THEN       ;*If OP.CONSOLE field in SPF contains any values(ON,TEST,PERFORMANCE,RECORD...) and 'SEAT.TRACE' record in F.LOCKING contains any process name then update the SEAT.SCRIPTS variable for the specific process alone
                    SEAT.SCRIPT<4,-1> = 1   ;* Just dummy flag to enable SEAT for single threaded job,populate the variable only when SEAT is used.
                END

* Single threaded jobs not to use write cache as the cache size is exceeded in the record routine.

                TEC$EVENT.ID = '' ;*initialised for COB events  .single threaded jobs
                TEC$EVENT.HOLD.ID = ''
                CACHE.OFF = 1     ;* Defaults the F.READ cache to off - the routine can turn it on if it's well behaved
                dasMode = dasReturnResults  ;* DAS should return the results in default
                ordDetails =''    ;* Clear common
                IF tvMode THEN
                    CALL TV.TRANS.GET.START.TIME
                END
                CALL @JOB.ROUTINE ;* SingleThread no arguments ; * BG_100003135
                IF tvMode THEN
                    WRITE.PRESENT = ''      ;* check if any write happens
                    CACHE.COUNT = DCOUNT(FWT,FM)      ;* count the no of records in the cache
                    FOR CNT = 1 TO CACHE.COUNT
                        IF FWF(CNT)[1,1] EQ 'W' THEN  ;* if any write available in cahce then enable WRITE.PRESENT to write a LOG.FILE in capture environment
                            WRITE.PRESENT = 1         ;* say yes for any write otherwsie say it no
                            CNT = CACHE.COUNT         ;* if any write happens then dont loop it again
                        END
                    NEXT CNT
                    IF WRITE.PRESENT THEN   ;* if any write happens then go and write log file for service txns in capture area and update the TV.SERVICE.TXN.DETAILS record for replay area
                        CALL TV.TRANS.GET.END.TIME    ;* get end time
                        CALL TV.TRANS.STORE.PROCESS   ;* write log file
                    END
                    CALL TV.TRANS.COMMON.RESET        ;* reset all the commons once record has been written in log file
                    tvFieldCheck=''         ;* reset the commons, for a manual transaction coming after the service txns this should have to be null
                    tvSplFieldCheck=''      ;* reset the commons, for a manual transaction coming after the service txns this should have have to be null
                END
                GOSUB DW.EXPORT.PROCESS  ; *DW Processing specialy for EXPORT
                CALL CLEAR.CACHE  ;* Make sure the cache is cleared up - if used
                CACHE.OFF = 1     ;* make sure the cache is off

        END CASE
    END

* Get the lock collision count from the SYSTEM(1036) variable
    COLLISION.COUNT += SYSTEM(1036)<1>

    IF STANDARD.JOB AND KEY.TO.PASS<2> THEN       ;* If a standard m/t job and Incase the record.routine has passed back value
        LIST.RECORD<1> = KEY.TO.PASS<2> ;* Substitute the original value in LIST.RECORD
    END ELSE        ;* either a singleThreaded Job or m/t job and record.routine has not passed back anything
        DEL LIST.RECORD<1>    ;* Drop it

* EN_10003752 S
* If this service is marked to work with keys only then do not
* consider the content of the record. Delete it's content all together
        IF KEYS.ONLY THEN
            LIST.RECORD = "";
        END
*EN_10003752 E
    END

    IF LIST.RECORD <> '' THEN ;* Still have contracts left in this list record
        WRITE LIST.RECORD TO F.LIST.NAME, LIST.KEY          ;* Write it back with one contract less
        WRITE.CNT.START+=1    ;* exclude this write operation as we need to get the writes happened in the record routine of the job
    END ELSE        ;* Empty list
        DELETE F.LIST.NAME, LIST.KEY    ;* Signal we've done this list record
    END

    IF TXN.MGMT THEN
        CALL EB.TRANS('END',RMSG)       ;* Commit it
        USER.INFO=@USERSTATS  ;* get the user stats information
        WRITE.CNT.END=USER.INFO<20>     ;* get the writes count now
        GOSUB DW.PROCESSING
    END ELSE
        USER.INFO=@USERSTATS  ;* get the user stats information
        WRITE.CNT.END=USER.INFO<20>     ;* get the writes count now
    END

    ACTUAL.WRITES=WRITE.CNT.END-WRITE.CNT.START   ;* get the no.of. writes done in the record routine of the job.
    TOTAL.WRITES=TOTAL.WRITES+ACTUAL.WRITES       ;* add it to the writes count in the job

    IF SEAT.TRACE.ON AND R.TSA.STATUS<TS.TSS.CURRENT.SERVICE> NE 'SEAT.INJECTOR' THEN     ;* Analyse the trace if we've made one and if service is not SEAT.INJECTOR
        SEAT.DETAILS<1> = JOB.NAME      ;* stores the JOB NAME
        SEAT.DETAILS<7> = JOB.NAME      ;* JOB.NAME - key to F.SEAT for the test routines
        SEAT.DETAILS<2> = PROCESS.NAME  ;* Pass the Process name
        SEAT.DETAILS<5> = SEAT.SCRIPT<3>          ;* The ofs message - that should be stored in the SEAT.RESULTS file
        SEAT.DETAILS<3> = SEAT.SCRIPT<4>          ;* The Id of the transaction current transaction being processed.
        SEAT.DETAILS<6> = SEAT.SCRIPT<6>          ;* Company to which the script to be loaded

        CALL T.SEAT('FINISH',SEAT.DETAILS)        ;* Stop the performance trace definitely - if allowed to (only during COB and service)
    END

    LISTS.PROCESSED +=1       ;* We've done another list
    IF TIME() - STIME GE REVIEW.TIME OR TIME() < STIME THEN ;* Report progress every minute or over midnight EN_10001864 s/e
        STIME = TIME()        ;*Initialise the Start Time
        GOSUB UPDATE.STATUS   ;* Update the como /job times
        LIST.RECORD = ''      ;*Force it to go to the next JOB.LIST record CI_10048043 S/E
        GOSUB CHECK.SERVICE   ;*Check we are still ok to run the agent
    END

RETURN

*-----------------------------------------------------------------------------
LOAD.DATES:
*Read dates record before calling .RECORD for all services

    MATREAD R.DATES FROM F.DATES, ID.COMPANY THEN ;*Read dates record
        TODAY = R.DATES(EB.DAT.TODAY)   ;*Populate TODAY variable
    END

RETURN
*-----------------------------------------------------------------------------
CALL.RECORD.ROUTINE:
* Invoke the record routine passing the contract

    BATCH.THREAD.KEY = LIST.KEY:' ':CONTRACT$ID   ;* Store in common - in case of crash
    KEY.TO.PASS = ''            ;*clear before processing for each record
    KEY.TO.PASS = CONTRACT$ID ;* Copy in case the routine changes it
    
    IF R.TSA.ERROR.LIST THEN            ;*check if TSA.ERROR.LIST record is present
		CALL OCOMO('Tracer Line 1454 R.TSA.ERROR.LIST ':R.TSA.ERROR.LIST)
        READ R.TSA.ERROR.LIST FROM F.TSA.ERROR.LIST, FLAG.ID THEN           ;*read again to get the latest image of record
			CALL OCOMO('Tracer Line 1455 R.TSA.ERROR.LIST ':R.TSA.ERROR.LIST)
			CALL OCOMO('Tracer Line 1455 FLAG.ID ':FLAG.ID)
            LOCATE CONTRACT$ID IN R.TSA.ERROR.LIST<TS.EL.CONTRACT.ID,1> SETTING KEY.POS THEN        ;*locate the current contract id in error list
                SOURCE.INFO<1> = 'BATCH.JOB.CONTROL'
                SOURCE.INFO<2> = PROCESS.NAME:'-':RECORD.ROUTINE            ;*set batch and job name to record in EEE
                SOURCE.INFO<3> = CONTRACT$ID                ;*set current contract id
                SOURCE.INFO<4> = 'Skipping the contract because of no response - ':CONTRACT$ID       ;*set the description that needs to be set in EB.EOD.ERROR
                SOURCE.INFO<9> = 'YES'          ;*set the value in 9th position to YES for FATAL.ERROR to identify that it is a corrupt contract
                CALL FATAL.ERROR(SOURCE.INFO)   ;*call FATAL.ERROR to log the details
                CALL OCOMO('Excluding ':CONTRACT$ID:' from processing because of no response')
                RETURN          ;*return without processing further as it is a corrupt contract
            END
        END
    END
    
    GOSUB CHECK.COMPANY       ;* Read the contract record and pick up the company code - in case we're multi-book

    SET.CACHE=1     ;* cache on
    GOSUB SET.CACHE.VARIABLES ;* set the cache varables
    dasMode = dasReturnResults          ;* DAS should return the results in default
    ordDetails =''  ;* Clear common

    IF tvMode THEN
        CALL TV.TRANS.GET.START.TIME
    END

    GOSUB initialiseIntegrationFrameworkParameter ; *Initialises the parameters used by the IF calls
    GOSUB prepareIntegrationFramework ; *prepares integration framework, if required

    CALL @RECORD.ROUTINE (KEY.TO.PASS)  ;* Do it - MultiThread

    GOSUB invokeIntegrationFramework    ;*Invoke integration framework to generate events for attached flows, if any

    IF tvMode THEN
        CALL TV.TRANS.GET.END.TIME
        CALL TV.TRANS.STORE.PROCESS
        CALL TV.TRANS.COMMON.RESET
    END

    GOSUB CHECK.RECORD.VERIFICATION     ;* check whether the record routine has verification mechanism

    BATCH.THREAD.KEY = ''     ;* Finished contract - clear in case there's a fatal error anywhere else

RETURN
*-----------------------------------------------------------------------------
UPDATE.STATUS:
* Update the como, job times and check that the service hasn't changed
*
    CALL OCOMO(OCONV(TIME(),'MTS'):' Processed ':LISTS.PROCESSED:' lists [':LISTS.PROCESSED-LAST.LIST.COUNT:']')
    LAST.LIST.COUNT = LISTS.PROCESSED

    CALL SERVICE.HEARTBEAT    ;* Tell the tSM we're ok
    JOB.OPERATION = 'PROGRESS'          ;* Tell the job times file how we're doing
    GOSUB UPDATE.JOB.TIMES    ;*Update the job times of our progress so far
    IF COB.SERVICE THEN       ;*Update the Job only for COB
        GOSUB UPDATE.TEC.JOB.PROGRESS   ;* Update the JOB.PROGRESS event only for COB
    END
RETURN

*-----------------------------------------------------------------------------
CHECK.SERVICE:
* Check whether the agent is still active and is scheduled to run the current service
*

    READ R.TSA.STATUS FROM F.TSA.STATUS, AGENT.NUMBER THEN  ;* Check our service hasn't changed
        IF R.TSA.STATUS<TS.TSS.AGENT.STATUS> # 'RUNNING' THEN
            GOTO PROGRAM.END  ;* Agent has been stopped
        END
        IF R.TSA.STATUS<TS.TSS.NEXT.SERVICE> THEN
            IF R.TSA.STATUS<TS.TSS.NEXT.SERVICE> # R.TSA.STATUS<TS.TSS.CURRENT.SERVICE> THEN
                GOTO PROGRAM.END        ;* Get out of here
            END
        END
    END

RETURN
*-----------------------------------------------------------------------------
CHECK.JOB.STATUS:
* Continually check the batch status record for the job (at the end of the list).
* If any thread completes then we need to exit immediately - because
* a) It's quicker and b) we don't want to find we're somehow processing
* list records meant for another job which might just happen.

    IF NOT(ACTIVATION.FILE)  THEN       ;*For Activation jobs there is no control list

        READ CURRENT.CONTROL.LIST FROM F.BATCH.STATUS, FLAG.ID ELSE NULL        ;* Check the job status

        IF CURRENT.CONTROL.LIST=PROCESSED THEN    ;* Finished by another thread

* If the job has been finished by another agent , update the writes happended in this session
* and include the agent in the JOB.TIMES file.

            CALL EB.TRANS('START',RMSG)
            JOB.OPERATION = 'END ': TIME()        ;* End of job time
            GOSUB UPDATE.JOB.TIMES      ;* update the writes and include the agent in JOB.TIMES
            CALL EB.TRANS('END',RMSG)

            CALL OCOMO( 'Job finished by another agent')
            RELEASE ;* Make sure we haven't got any locks
            GOTO PROGRAM.ABORT          ;* Back to S.JOB.RUN immediately - our job is over
        END ELSE     ;* ;* Current agent may be delayed than other agents which are already proceed to next auto run with other job list
            GOSUB CHK.STILL.HOLD.LIST.FILE      ;* See whether am holding valid list file
        END
        IF CURRENT.CONTROL.LIST<1,1> # CONTROL.LIST<1,1> THEN         ;* Means another thread has finished this list and is building the next
            EOL = 1 ;* Flag that we're at the end of this list. This will send control back to 'advance control list'
        END
    END

RETURN
*-----------------------------------------------------------------------------
GLOBAL.RELEASE:
* When returning from the record routine ensure that no locks are left. Ideally
* the record routine should either write or release any locked records. However,
* if it doesn't then the lock table could easily fill up and the job crash.
* Do it after processing every record routine

    RELEASE         ;* Global release incase the record routine left a lock

RETURN
*-----------------------------------------------------------------------------
INITIALISE:



    JOB.NAME = JOB.INFO['_',1,1]        ;* Key to PGM.FILE
    GOSUB CHECK.SEAT.TRACE ;* Check whether the current job needs to be trace. Trace all the contracts in the job. Most important trace only if results are defined for that job
    MAT C$SC = ''   ;* Initialise the shared common area for the job's load & run routines

    Record=''         ;* Initialise variable before use
    Err=''            ;* Initialise variable before use
    saveEtext = ETEXT  ;* Copy the ETEXT variable
    CALL CACHE.READ('F.PGM.FILE','DLM.DELETE.PROCESS', Record, Err)    ;* Check for dependency
    ETEXT = saveEtext    ;*Restore the ETEXT variable
    IF Record THEN
        dlInstalled = ''
        CALL Product.isInSystem('DL', dlInstalled)
    END
    BATCH.THREAD.KEY = ''     ;*Initialise the common variable
    JOB.ROUTINE = JOB.INFO['_',2,1]     ;* Routine to call
    ACTIVATION.FILE = JOB.INFO['_',3,1] ;* If it's a permanent agent (like delivery - it will have it's on list/activation file)
    JOB.POSITION = JOB.INFO["_",4,1]    ;* Position of the job in R.BATCH - needed in case the same job name appears in the batch record
    ADDITIONAL.INFO = JOB.INFO["_",5,1] ;* get the ADDITIONAL.INFO of the job
    KEY.FILE =  JOB.INFO["_",6,1]       ;* get the KEY.FILE of the job
    KEY.COMPONENT =  JOB.INFO["_",7,1]  ;* get the KEY.COMPONENT of the job
    CLEAR.STATIC.CACHE = JOB.INFO["_",8,1]        ;* indicates whether to clear the static cache at the end of each job in thIS BATCH process
    PROCESS.STAGE = JOB.INFO["_",9,1]   ;* Process Stage added for Splunk Logger().
    SELECT.AHEAD = JOB.INFO["_",10,1]    ;* Run the select part only - enables list preparation while another job is running
    SAMPLE.COUNT = JOB.INFO["_",11,1] ;* Fetch the sample count value
    ACTIVATION.FILENAME = JOB.INFO["_",12,1] ;* Fetch the activation file name

    PROCESSING = 'processing' ;* Used for checking state of control list
    PROCESSED = 'processed'
    EMPTYLIST = 'emptylist'   ;* Signals an empty list
    AGENT.UPDATE.PENDING = '' ;* Flag to indicate the agent pending for registration
    NO.RECORDS.PROCESSED = ''

    GOSUB INITIALISE.MULTI.BOOK         ;* Prepare for multi-book processing

    IF JOB.ROUTINE = '' OR JOB.ROUTINE = 'BATCH.JOB.CONTROL' THEN     ;* Identify whether MT job or not
        STANDARD.JOB = 1      ;* Normal mt job
    END ELSE
        STANDARD.JOB = 0      ;* Single thread job
    END

    IF INDEX(ADDITIONAL.INFO,".NUC",1) THEN       ;* check if the job wants to use the cache or not
        USE.CACHE=0 ;* dont'use the cache
    END  ELSE
        USE.CACHE=1 ;* use the cache
    END

    BEGIN CASE
        CASE JOB.NAME = 'EB.EOD.REPORT.PRINT'         ;*  we do not call EB.TRANS, if JOB.NAME is EB.EOD.REPORT.PRINT
            TXN.MGMT = 0          ;* No txn management
            USE.CACHE=0 ;* dont'use the write cache as there is no transaction management
        CASE INDEX(ADDITIONAL.INFO,".NTX",1)          ;* No txn mgmt - R.PGM.FILE read in INITIALISE.MULTI.BOOK
            TXN.MGMT = 0
            USE.CACHE=0 ;* dont'use the write cache for ".NTX" jobs as the transaction mgmt is not started here in BJC
        CASE OTHERWISE
            TXN.MGMT = 1          ;* Default transaction management to be on
    END CASE

    MAT R.VERSION = ''        ;*Initialise
    IF INDEX(ADDITIONAL.INFO,".NOL",1) THEN       ;*If .NOL is set at Version level
        R.VERSION(EB.VER.REPORT.LOCKS) = 'NO'     ;*Set the value as NO so that no reporting is done on locks
    END

*EN_10003752 s
    KEYS.ONLY = 0;
    IF INDEX(ADDITIONAL.INFO,".KEY",1) THEN       ;*If .KEY then just work with keys in the activation file, ignore records.
        KEYS.ONLY = 1;
    END
*EN_10003752 e

    CRITICAL.JOB = 0
    IF INDEX(ADDITIONAL.INFO,".CRITICAL",1) THEN       ;*If .CRITICAL is set in PGM.FILE, then it is a critical job
        CRITICAL.JOB = 1
    END

    SELECT.ROUTINE = JOB.NAME: '.SELECT'
    RECORD.ROUTINE = JOB.NAME
    LOAD.ROUTINE = JOB.NAME: '.LOAD'

    IF STANDARD.JOB THEN      ;* It's ok to call the load routine
        CALL OCOMO('Standard multi-thread job')
        CALL OCOMO('Calling load routine')        ;* Tell 'em in the como
        JOB.PROGRESS = 8      ;* new job progress to identify the load stage in a multithreaded job
        CACHE.OFF = 1         ;*Don't load the cache
        dasMode = dasReturnResults      ;* DAS should return the results in default
        CALL @LOAD.ROUTINE    ;* Load the common area for use by the record routine
        CACHE.OFF = 1         ;* make sure that the cache is turned off
    END ELSE
        CALL OCOMO('Single Thread routine ':RECORD.ROUTINE) ;* BG_100002910 S/E
    END

    FLAG.ID = PROCESS.NAME:'-':RECORD.ROUTINE:'-':JOB.POSITION        ;* BG_100005787 ends

    FN.BATCH.STATUS = 'F.BATCH.STATUS'
    F.BATCH.STATUS = ''
    CALL OPF(FN.BATCH.STATUS, F.BATCH.STATUS)
    BATCH.COMPANY = ID.COMPANY          ;* EN_10001831 store the original company of the Batch job

    LIST.OWNER = 0  ;* To identify the session allocating the .LIST file

    CALL OPF('F.JOB.TIMES',F.JOB.TIMES)
    
    SAVE.ETEXT = ETEXT          ;*save Etext value before clearing the variable
    ETEXT = ''                  ;*clear the value
    EB.ERR.REC = ''             ;*initialise before usage
    ER = ''                     ;*initialise before usage
    CALL CACHE.READ('F.EB.ERROR', 'EB-CHECK.DEP.FATAL.ERROR', EB.ERR.REC, ER)
    FN.TSA.ERROR.LIST = 'F.TSA.ERROR.LIST':@FM:'NO.FATAL.ERROR'
    F.TSA.ERROR.LIST = ''
    CALL OPF(FN.TSA.ERROR.LIST, F.TSA.ERROR.LIST)           ;*open tsa error list file
    R.TSA.ERROR.LIST = ''           ;*initialise before usage
    TSA.ERROR.LIST.MISSING = 0      ;*set the file missing flag to 0 initially
    IF ETEXT OR NOT(EB.ERR.REC) THEN
        TSA.ERROR.LIST.MISSING = 1  ;*set the flag to 1 in case of error
    END
    ETEXT = SAVE.ETEXT      ;*restore the value of Etext

    FN.LIST.NAME = ''         ;*Init the variable as this is now being refered even before allocation
    GOSUB OPEN.LIST.FILE      ;* And open the list file for processing

    R.TSA.STATUS = "" ;* Initialize before usage
    IF AGENT.NUMBER THEN
        READ R.TSA.STATUS FROM F.TSA.STATUS, AGENT.NUMBER ELSE  ;* All from TSA.COMMON - status record used for info for tEC
            R.TSA.STATUS = ""
            TEXT = "UNABLE TO READ TSA.STATUS RECORD"
            CALL FATAL.ERROR("BATCH.JOB.CONTROL")
        END
    END

    READ R.TSA.SERVICE FROM F.TSA.SERVICE, R.TSA.STATUS<TS.TSS.CURRENT.SERVICE> ELSE      ;*get the Service record
        R.TSA.SERVICE = ''
    END
    COB.SERVICE = ''          ;*To identify COB Job
    IF R.TSA.STATUS<TS.TSS.CURRENT.SERVICE> MATCHES "COB":VM:"'COB-'2A7N":VM:"'COB-'1-3N" THEN
        COB.SERVICE = 1       ;*I am a COB service
    END
* Review time defined in TSA.SERVICE takes priority over TSA.PARAMETER
    IF R.TSA.SERVICE<TS.TSM.REVIEW.TIME> NE '' THEN         ;*review time set in TSA.SERVICE
        SERVICE.REVIEW.TIME = R.TSA.SERVICE<TS.TSM.REVIEW.TIME>       ;*take it
    END ELSE
        SERVICE.REVIEW.TIME = R.TSA.PARAMETER<TS.PARM.REVIEW.TIME>    ;*review time defined at TSA.PARAMETER
    END
        
    REVIEW.TIME = 60          ;* Default every minute for JOB.TIMES Update

    LISTS.PROCESSED = 0       ;* Keep a count of lists processed
    LAST.LIST.COUNT = 0       ;* So we can show throughput
    KEYS.PROCESSED = 0        ;* Comes from BATCH.BUILD.LIST via the select routine
    STIME = TIME()  ;* Start of job - select or processing
    KEY.COUNT = 0   ;* Number of individual contracts processed by this thread
    KTIME = TIME()  ;* Used to calculate single thread throughput
    LAST.COMPLETED = 0        ;* Used to calculate current total throughput
    IF ACTIVATION.FILE THEN   ;* Permanent agent
        LIST.SAMPLE = 100     ;* Just take a few
    END ELSE
        LIST.SAMPLE = 100000  ;* COB - take a load
    END
    IF SAMPLE.COUNT THEN
        LIST.SAMPLE = SAMPLE.COUNT ;* If Sample count has value then overwrite this in the LIST.SAMPLE variable
    END
    JOB.THRESHOLD = 100       ;* As a safety measure we check the batch.status for the last 100 record in a extracted portion
    FASTEST.THROUGHPUT =0     ;* Stored in job times - shows fastest throughput/min achieved for the job

    IF LAST.JOB EQ JOB.INFO THEN        ;* If it same job dont try to Run Ahead
        RUN.AHEAD = 0         ;* We've already looked once and there was nothing to do
    END ELSE
        RUN.AHEAD = 1
    END
    LAST.JOB = JOB.INFO       ;* Keep this in common so we know if we've come back from running (or selecting) ahead

    IF R.TSA.STATUS<TS.TSS.CURRENT.SERVICE>[1,3] NE  'COB' THEN       ;* Run ahead available only for COB
        RUN.AHEAD = 0         ;* if it's an Online Service flag RUN.AHEAD to false
    END

    IF CLEAR.STATIC.CACHE EQ 'YES' THEN ;* clear the static cache for each job
        STATIC.INDEX = 0
    END

    SET.COLLECT = 0
    DW$EXTRACT.MODE = 1
    DW.RTN.EXIST = 0 ;* Initializing DW.RTN.EXIST
    IF DW$INSTALLED EQ 'EXPORT' THEN ;* If DW$INSTALLED equals Export, check for the existence of DW.EXPORT.CAPTURE
        PRG.NAME = 'DW.EXPORT.CAPTURE' ;* Setting routine name to DW.EXPORT.CAPTURE
        RETURN.INFO = '' ;* Initializing RETURN.INFO
        CALL CHECK.ROUTINE.EXIST(PRG.NAME,DW.RTN.EXIST,RETURN.INFO) ;* Check for the existence of DW.EXPORT.CAPTURE
    END

    AcEnd = 0   ;* To indicate end of iteration for activation based services
    TotalKeys = 0 ;* To indicate the total number of keys processed for activation services
    FORCE.TIMEOUT.LOGOFF = 1  ;* set the timeout logoff to true
    IF NOT(STANDARD.JOB) OR JOB.NAME = 'EB.EOD.REPORT.PRINT' OR JOB.NAME = 'RUN.CONVERSION' OR JOB.NAME = 'EB.PRINT' THEN    ;* if not a std job or job is report printing or run conversion then
        FORCE.TIMEOUT.LOGOFF = 0        ;* set forced time out logoff to false
    END
    SAVE.BATCH.PRINTER = C$RPT.DEST.PRINTER       ;*save the varaible for Default printer
    BULK.NUMBER=0   ;* intialise the common variable which holds the no.of contracts to be bulked
    SELECT.STATEMENT=''       ;* initialise the common variable which holds the select statement
    SELECTION.MODE=''         ;* initialise the common variable which holds the selection type(ALL,PREDEFINED,CRITERIA,FILTER)
    COLLISION.COUNT=0         ;* Keep a count on the no.of.collisions
    RECORD.VERIFICATION=''    ;* Whether the record routine has the mechanism to process or eliminate keys
    JOB.START.TIME=''         ;* initialise the start time variable
    ROUTINE.USED.CACHE= ''    ;* indicates whether the record routine has actually used the cache or not
    TOTAL.WRITES=0  ;* Keep a count on the no.of writes
    ACTUAL.WRITES=0 ;* no of writes count during each record routine processing
    AGENT.REGISTERED=0        ;* Flag to indicate whether the agent has been registered in the JOB.TIMES file
    LAST.LIST.KEY = ''        ;* last list key id
    JOB.TIMES.END = 0         ;* Flag to indicate whether JOB.TIMES has been ended
    CURR.JOB.ELAPSED.TIME = ''          ;* Holds the  elapsed time of Job

    isIFProductInstalled = "" ;* flag holds whether or not IF is installed; "" -> not yet known
    F.DATES = ''
    CALL OPF("F.DATES", F.DATES)        ;* Open dates record
RETURN
*-----------------------------------------------------------------------------
INITIALISE.MULTI.BOOK:

* read the PGM.FILE record to pick upthe file to read so the correct company can be loaded
*
    CALL OPF("F.PGM.FILE",F.PGM.FILE)   ;* open the PGM file
* code to read the PGM.FILE file is removed as the neccesary KEY.FILE and KEY.COMPONENT of the job
* are passed from S.JOB.RUN.
*
    FN.KEY.FILE = "" ; F.KEY.FILE = ""
*
* BG_10004694 improve key definition for multi book
*
    IF KEY.FILE AND C$MULTI.BOOK THEN
*
* get the standard selection record to pick up the company code
*
        R.STANDARD.SELECTION = ''
        SS.ID = FIELD(KEY.FILE,'$',1)   ;* CI_10037219
        CALL GET.STANDARD.SELECTION.DETS(SS.ID,R.STANDARD.SELECTION)  ;* CI_10037219
        IF R.STANDARD.SELECTION THEN
            IF FN.KEY.FILE[1,2] NE "F." THEN FN.KEY.FILE = "F.":KEY.FILE
            CALL OPF(FN.KEY.FILE,F.KEY.FILE)
            FIELD.NME = "CO.CODE"
            CO.FIELD.NO = ''
            DATA.TYPE = ''
            ERR.MSG = ''
            YYAF = '' ; YYAV = '' ; YYAS = ''
            CALL FIELD.NAMES.TO.NUMBERS(FIELD.NME,R.STANDARD.SELECTION,CO.FIELD.NO,YYAF,YYAV,YYAS,DATA.TYPE,ERR.MSG)
            IF NOT(ERR.MSG) THEN
                R.CO = ""
                FIELD.SPEC = "1X0X>1X0X"          ;* CUSTOMER>SECTOR
                IF MATCHFIELD(CO.FIELD.NO,FIELD.SPEC,1) THEN
                    CO.FLD = "JOIN"
                END ELSE
                    CO.FLD = "DATA"
                    FNO = CO.FIELD.NO[".",1,1]
                    VNO = CO.FIELD.NO[".",2,1] ; IF VNO = "" THEN VNO = 1
                    SNO = CO.FIELD.NO[".",3,1] ; IF SNO = "" THEN SNO = 1
                END
                CALL OPF("F.COMPANY",F.COMPANY)
                IF KEY.COMPONENT THEN
                    KEY.POS.1 = FIELD(KEY.COMPONENT,",",1)
                    KEY.POS.2 = FIELD(KEY.COMPONENT,",",2)
                END ELSE
                    KEY.POS.1 = ""
                    KEY.POS.2 = ""
                END
            END ELSE
                FN.KEY.FILE = ""
            END
        END
    END

RETURN
*-----------------------------------------------------------------------------
EXTRACT.PORTION:
* To avoid each thread processing the same part of the list extract a portion
* based on my session number (1 to NUMBER.OF.SESSIONS)

    IF NOT(NUMBER.OF.SESSIONS) THEN     ;* this would be set in SJR , but not available for some reason then
        NUMBER.OF.SESSIONS = 10         ;* default
    END

* The logic of adding the NUMBER.OF.SESSIONS with AGENT.NUMBER is removed now (when the AGENT.NUMBER is actually greater than the NUMBER.OF.SESSIONS.)


    NUMBER.OF.KEYS = DCOUNT(FULL.LIST,@FM)        ;* Number of keys in the list
    NUMBER.TO.PROCESS = NUMBER.OF.KEYS/(NUMBER.OF.SESSIONS + RelPos)      ;* The total number to process is calculated always with number of keys available in the KEY list by sum of total number of sessiona and the actual agent number
    OFFSET = INT(NUMBER.TO.PROCESS * RelPos)          ;* My portion of the list

    IF NUMBER.OF.KEYS > (NUMBER.OF.SESSIONS + RelPos) THEN      ;* If list is big enough
        ID.LIST = FULL.LIST[@FM,OFFSET,INT(NUMBER.TO.PROCESS)]        ;* Extract it
        FULL.LIST = FULL.LIST[@FM,OFFSET+INT(NUMBER.TO.PROCESS),NUMBER.OF.KEYS]
        IF OFFSET GT 1 THEN   ;* Wasn't the first id in the list
            FULL.LIST:= @FM: FULL.LIST[@FM,1,OFFSET-1]      ;* Reduce the full list accordingly - reverse build to avoid clashes
        END
    END ELSE
        ID.LIST = FULL.LIST   ;* Take the lot - we're too near the end to worry
        FULL.LIST = ''        ;* This will force the select again to make sure we've mopped up all ids
        MAX.MISS = NUMBER.OF.KEYS       ;* Force End Game - when all IDs are locked
    END
 
RETURN
*----------------------------------------------------------------------------------
CHECK.COMPANY:
* How do we easily define the field the company code is in?
* and how can we do this quickly - you're supposed to work that out before you write the code Phil!

    IF FN.KEY.FILE THEN
        CHECK.KEY = KEY.TO.PASS
        IF KEY.POS.1 NE '' THEN
            IF NUM(KEY.POS.1) THEN
                CHECK.KEY = KEY.TO.PASS[KEY.POS.1,KEY.POS.2]
            END ELSE          ;* field type
                CHECK.KEY = FIELD(KEY.TO.PASS,KEY.POS.1,KEY.POS.2,1)
            END
        END
        READ KEY.REC FROM F.KEY.FILE, CHECK.KEY THEN
            IF CO.FLD = "JOIN" THEN
                CALL FIELD.JOIN(KEY.FILE,CHECK.KEY,KEY.REC,CO.FIELD.NO,KEY.COMPANY)
            END ELSE
                KEY.COMPANY = KEY.REC<FNO,VNO,SNO>
            END
            IF KEY.COMPANY NE ID.COMPANY THEN
                READ R.CO FROM F.COMPANY, KEY.COMPANY THEN
                    CALL LOAD.COMPANY(KEY.COMPANY)
                END
            END
        END
    END

RETURN
*----------------------------------------------------------------------------------
UPDATE.JOB.TIMES:
* Update the job times file (used to be done in S.BATCH.RUN). Create a new m/value if we're
* starting the job, maintain the number of keys to be processed and update the end time
* when we're finished. The transaction management occurs aroud this gosub.
*
* Get the selection details and the no.of records bulked.
* Retrieve the common variables BULK.NUMBER,SELECT.STATEMENT,SELECTION.MODE set
* in BATCH.BUILD.LIST and update the fields in JOB.TIMES when JOB.OP ='KEYS'
* For single threaded job,these values would be one set in the initilaisation.
* SELECT.TIME,PROCESSED, and COMPLETED will now be assoc.sub value fields to store
* the information for each control list.
*

    IF INDEX(ADDITIONAL.INFO,".NJT",1) THEN       ;* Do not update JOB.TIMES of a job when the field ADDITIONAL.INFO in PGM.FILE is udpated with ".NJT(No Job Times)"
        RETURN      ;* Just Return without updating JOB.TIMES
    END


    JT.ID = PROCESS.NAME:'-':JOB.NAME   ;* PROCESS.NAME comes from common I_BATCH.FILES
    JOB.OP = JOB.OPERATION[" ",1,1]     ;* What do you want to do
    JOB.VALUE = JOB.OPERATION[" ",2,1]  ;* And what's the value

    IF JOB.OP = 'PROGRESS' THEN         ;* Don't hang on the lock for progress
        READU R.JOB.TIMES FROM F.JOB.TIMES, JT.ID LOCKED    ;* If it's already locked
            RETURN  ;* go straight beck and don't wait
        END ELSE
            RETURN  ;* Can't be null
        END
    END ELSE
        IF JOB.OP = "END" AND FASTEST.THROUGHPUT EQ 0 THEN  ;*Am finishin
            READU R.JOB.TIMES FROM F.JOB.TIMES,JT.ID LOCKED ;*I may not
                RETURN
            END ELSE
                NULL
            END
        END ELSE
            READU R.JOB.TIMES FROM F.JOB.TIMES, JT.ID ELSE  ;* Always wait for a lock
                R.JOB.TIMES = ""
            END
        END
    END

    BEGIN CASE
        CASE JOB.OP = 'START'     ;* Starting the job
            R.JOB.TIMES<EB.JT.JOB> = JOB.NAME
            R.JOB.TIMES<EB.JT.PROGRAM> = 'BATCH.JOB.CONTROL'    ;* This will always be the case now
            R.JOB.TIMES<EB.JT.SERVICE.NAME> = R.TSA.STATUS<TS.TSS.CURRENT.SERVICE>  ;*get the service name

            FOR JIDX = EB.JT.BATCH.DATE TO EB.JT.REC.VERIFY     ;* Push current times down  EN_10001864 s/e
                INS '' BEFORE R.JOB.TIMES<JIDX,1>     ;* New time will be stored in 1
                IF INDEX(ADDITIONAL.INFO,".HJTP",1) THEN        ;* Job times record can have up to 20 Multi values when the ADDITIONAL.INFO in PGM.FILE set with .HJTP for the jobs.
                    DEL R.JOB.TIMES<JIDX,21>    ;* And drop the 21th as we only want to keep the last 20
                END ELSE
                    DEL R.JOB.TIMES<JIDX,11>    ;* And drop the 11th as we only want to keep the last 10
                END
            NEXT JIDX

            R.JOB.TIMES<EB.JT.BATCH.DATE,1> = C$BATCH.START.DATE          ;* From INITIALISATION = bank date
            R.JOB.TIMES<EB.JT.SELECT.START,1> = JOB.VALUE       ;* The time the select part started

            GOSUB CHECK.TXN.MGMT  ;* check if the job is run within the transaction management
            R.JOB.TIMES<EB.JT.LOCK.COLLISION,1> = 0   ;* incase if the keys selected is '0',record routine would not be called so set it to '0' initially.

            R.JOB.TIMES<EB.JT.TOTAL.WRITE,1> = 0      ;* incase if the keys selected is '0'

        CASE JOB.OP = 'KEYS'      ;* Done the select - how many keys (contracts!!) do we have
            IF JOB.VALUE LT 0 THEN JOB.VALUE = 0      ;* KEYS.PROCESSED will be equal -1, if BBL is not called at all

            INS JOB.VALUE BEFORE R.JOB.TIMES<EB.JT.PROCESSED,1,1>         ;* In case the select program has been called more than once(CONTROL.LIST logic),include a subvalue for each control list
            INS SELECT.TIME BEFORE R.JOB.TIMES<EB.JT.SELECT.TIME,1,1>     ;* Store the time taken to do the select
            INS SAVE.CONTROL.LIST<1,1>[1,35] BEFORE R.JOB.TIMES<EB.JT.CONTROL.LIST,1,1>       ;*first 35 caharcters
            INS BULK.NUMBER BEFORE R.JOB.TIMES<EB.JT.BULK.NUMBER,1,1>     ;* update the no.of contracts bulked
            INS SELECTION.MODE BEFORE R.JOB.TIMES<EB.JT.TYPE.OF.SEL,1,1>  ;* update the selection mode
            INS SELECT.STATEMENT BEFORE R.JOB.TIMES<EB.JT.SEL.STATEMENT,1,1>        ;* update the select statement used fo
            INS 0 BEFORE R.JOB.TIMES<EB.JT.COMPLETED,1,1>       ;* no.of contracts completed processing
            IF STANDARD.JOB THEN  ;* do it for multithreaded job.Need not do it for a single threaded job.
                GOSUB CLEAR.SELECTION.VARIABLES       ;* clear the common variables set in BATCH.BUILD.LIST
            END
* If the records selected is zero and if there are no more items to be processed in the CONTROL.LIST ,
* then Update the JOB.TIMES with the end part as well.

            IF JOB.VALUE EQ 0 AND CONTROL.LIST = PROCESSED THEN ;* Zero records selected and no more items to be processed
                IF NOT(JOB.START.TIME) THEN
                    JOB.START.TIME = TIME() ;* job start time
                END
                END.TIME = TIME() ;* end time
                GOSUB STORE.JOB.END.TIME    ;* end the JOB.TIMES
                JOB.TIMES.END = 1 ;* job times ended
            END

        CASE JOB.OP = 'PROGRESS'  ;* Tell em how we're doing so far
            IF R.JOB.TIMES<EB.JT.START.TIME,1> = "" THEN        ;* I'm first so update the start of the job - note the start of the select is held separately
                R.JOB.TIMES<EB.JT.START.TIME,1> = JOB.START.TIME          ;* Recorded when we began really processing
            END

            GOSUB UPDATE.TOTAL.WRITES       ;* update the writes count and lock collision count

            GOSUB CALL.TEC        ;* Tell the TEC ;* Uses KEY.COUNT for the number of contract processed by this agent
            GOSUB STORE.JOB.PROGRESS        ;* Job times progress
            GOSUB UPDATE.PROGESS.BATCH.STATUS         ;* Batch status
            KEY.COUNT = 0         ;* Reset for next.Reset the KEY.COUNT after updating the BATCH.STATUS record
        CASE JOB.OP = 'END' AND R.JOB.TIMES<EB.JT.END.TIME,1> = ""  AND JOB.START.TIME NE ''  ;* And nobody else has done this.The agent trying to end the job first has atleast processed a record or has done the selection of the job
            
            IF ACTIVATION.FILE THEN
                INS TotalKeys BEFORE R.JOB.TIMES<EB.JT.PROCESSED,1,1>
            END
            
            GOSUB UPDATE.TOTAL.WRITES       ;* Very quickly run - didn't get time for update progress.update the writes count and lock collision count
            KEY.COUNT = SUM(R.JOB.TIMES<EB.JT.PROCESSED,1>) - SUM(R.JOB.TIMES<EB.JT.COMPLETED,1>)       ;* Final number of contracts processed
            GOSUB CALL.TEC        ;* Tell the TEC
            END.TIME = JOB.VALUE  ;* Time we've finished
            GOSUB STORE.JOB.END.TIME        ;* Update end time, throughput etc
        CASE JOB.OP = 'END'       ;* But not the first thread to end
* For a multi threaded job,if the agent has not yet been registered in JOB.TIMES and if it has processed
* atleast one id increment the agent count

            LOCATE JT.ID IN AGENT.UPDATE.PENDING.JOBS<1> SETTING APOS THEN          ;* Locate for pending agent registration
                AGENT.UPDATE.PENDING = 1    ;* Flag it, to indicate the agent has to be registered.
                DEL AGENT.UPDATE.PENDING.JOBS<APOS>   ;* delete the pending update from common since agent going to be ended
            END
            IF STANDARD.JOB AND (LISTS.PROCESSED OR AGENT.UPDATE.PENDING) THEN      ;* Agent processed any ids or agent registration pending in case of RUN.AHEAD
                R.JOB.TIMES<EB.JT.AGENTS,1> = FIELD(R.JOB.TIMES<EB.JT.AGENTS,1>, ',', 1) ;* Get the number of agents that processed.
                R.JOB.TIMES<EB.JT.AGENTS,1>+=1        ;* include it now.increment the agent count
            END

            GOSUB UPDATE.TOTAL.WRITES       ;* Very quicky run and other thread has ended the job. update the writes count and lock collision count
            IF FASTEST.THROUGHPUT GT R.JOB.TIMES<EB.JT.FASTEST,1> THEN    ;* contracts per second per thread
                R.JOB.TIMES<EB.JT.FASTEST,1> = FASTEST.THROUGHPUT         ;* Store the fastest single throughput
            END
    END CASE
    R.JOB.TIMES<EB.JT.JOB.POSITION,1> = JOB.POSITION   ;*Store the JOB.POSITION  in job times record
    WRITE R.JOB.TIMES TO F.JOB.TIMES, JT.ID       ;* Save it

* C$USE.T24.LOG is checked and if TAF/logs are enables log message is written.
* Details of JOB.TIMES will be maintained in TAF layer for splunk.

    IF NOT(C$USE.T24.LOG) THEN
        GOSUB UPDATE.TAF.LOG
    END

RETURN

*----------------------------------------------------------------------------------------------------
UPDATE.TAF.LOG:
*Form JOB.TIMES record and send via Logger(). This is done for maintaining JOB.TIMES in Splunk(tOP).
    COB.BATCH.NAME = PROCESS.NAME       ;* Sending PROCESS.NAME as it is for Single Company Installation.

    IF INDEX(PROCESS.NAME,"/",1) THEN
        COB.BATCH.NAME = FIELD(PROCESS.NAME,'/',2)          ;* Get the process name for Logger
    END

    LogJtStr = ''
    LogJtStr ='JT.JOB="':R.JOB.TIMES<EB.JT.JOB,1>
    LogJtStr :='" COMPANY.CODE="':PROCESS.NAME[1,3]
    LogJtStr :='" BATCH_NAME="':COB.BATCH.NAME
    LogJtStr :='" BATCH_STAGE="':PROCESS.STAGE
    LogJtStr :='" BATCH_DATE="':R.JOB.TIMES<EB.JT.BATCH.DATE,1>
    LogJtStr :='" START_TIME="':R.JOB.TIMES<EB.JT.START.TIME,1>
    LogJtStr :='" END_TIME="':R.JOB.TIMES<EB.JT.END.TIME,1>
    LogJtStr :='" ELAPSED_TIME="':R.JOB.TIMES<EB.JT.ELAPSED.TIME,1>
    LogJtStr :='" THROUGHPUT="':R.JOB.TIMES<EB.JT.THROUGHPUT,1>
    LogJtStr :='" FASTEST="':R.JOB.TIMES<EB.JT.FASTEST,1>
    LogJtStr :='" AGENTS="':R.JOB.TIMES<EB.JT.AGENTS,1>
    LogJtStr :='" SELECT_START="':R.JOB.TIMES<EB.JT.SELECT.START,1>
    LogJtStr :='" HIGHEST_RESPONSE="':R.JOB.TIMES<EB.JT.HIGHEST.RESPONSE,1>
    LogJtStr :='" CONTROL_LIST="':R.JOB.TIMES<EB.JT.CONTROL.LIST,1>
    LogJtStr :='" BULK_NUMBER="':R.JOB.TIMES<EB.JT.BULK.NUMBER,1>
    LogJtStr :='" TYPE_OF_SEL="':R.JOB.TIMES<EB.JT.TYPE.OF.SEL,1>
    LogJtStr :='" SEL_STATEMENT="':R.JOB.TIMES<EB.JT.SEL.STATEMENT,1>
    LogJtStr :='" SELECT_TIME="':R.JOB.TIMES<EB.JT.SELECT.TIME,1>
    LogJtStr :='" PROCESSED="':R.JOB.TIMES<EB.JT.PROCESSED,1>
    LogJtStr :='" COMPLETED="':R.JOB.TIMES<EB.JT.COMPLETED,1>
    LogJtStr :='" MANAGEMENT="':R.JOB.TIMES<EB.JT.TXN.MANAGEMENT,1>
    LogJtStr :='" READ_WRITE_CACHE="':R.JOB.TIMES<EB.JT.READ.WRITE.CACHE,1>
    LogJtStr :='" LOCK_COLLISION="':R.JOB.TIMES<EB.JT.LOCK.COLLISION,1>
    LogJtStr :='" TOTAL_WRITE="':R.JOB.TIMES<EB.JT.TOTAL.WRITE,1>
    LogJtStr :='" REC_VERIFY="':R.JOB.TIMES<EB.JT.REC.VERIFY,1>
    LogJtStr :='" SERVICE_NAME="':R.JOB.TIMES<EB.JT.SERVICE.NAME,1>:'"'
    CONVERT VM TO " " IN LogJtStr
    CONVERT SM TO " " IN LogJtStr
    Logger("JOB.TIMES",TAFC_LOG_INFO,LogJtStr)    ;* Write into TAF/logs.

RETURN
*-----------------------------------------------------------------------------
CALL.TEC:
* Tell the TEC how many contract we've processed. The item is TXN.METRIC.
* R.TSA.STATUS is in common - so should be available here - and it's read in BJC as well

    IF KEY.COUNT GT 0 THEN    ;* Just in case
        CALL TEC.RECORD.ACTIVITY('TXN.METRIC',R.TSA.STATUS<TS.TSS.CURRENT.SERVICE>,'',KEY.COUNT)    ;* Tell the TEC how many we've done
        READU R.TSA.SERVICE FROM F.TSA.SERVICE, TSA.SERVICE.NAME LOCKED         ;* Try to Lock
            NULL    ;*lock not attained. Just return
        END THEN
            CALL SERVICE.CONTROL('',KEY.COUNT,'') ;* lock attained.  Update TSA.SERVICE by calling SERVICE.CONTROL
        END
    END
RETURN
*-----------------------------------------------------------------------------
STORE.JOB.PROGRESS:
* Maintain the throughput and key count of the job on JOB.TIMES.

    R.JOB.TIMES<EB.JT.COMPLETED,1,1> += KEY.COUNT ;* Number of contracts processed so far
    ETIME = TIME()-KTIME      ;* Number of seconds since the last time we updated the progress

    IF ETIME > 0 THEN
        IF LAST.COMPLETED THEN          ;* Calculate overall throughput if you have something
            PROCESSED.THIS.SLICE = R.JOB.TIMES<EB.JT.COMPLETED,1,1> - LAST.COMPLETED
            R.JOB.TIMES<EB.JT.THROUGHPUT,1> = INT(PROCESSED.THIS.SLICE / (ETIME/REVIEW.TIME))       ;* Overall throughput
        END
        CURRENT.THROUGHPUT = INT(KEY.COUNT / (ETIME/REVIEW.TIME))     ;* My throughput in minutes
        IF CURRENT.THROUGHPUT > FASTEST.THROUGHPUT THEN     ;* Faster than before
            FASTEST.THROUGHPUT = CURRENT.THROUGHPUT         ;* Save this
        END
        IF KEY.COUNT THEN     ;* Providing we've done something
            MY.AVERAGE.RESPONSE = ETIME/KEY.COUNT ;* Calculate the average response time per transaction
            MY.AVERAGE.RESPONSE = INT(MY.AVERAGE.RESPONSE*1000)/1000  ;* Only to three decimal places
            IF MY.AVERAGE.RESPONSE > R.JOB.TIMES<EB.JT.HIGHEST.RESPONSE,1> THEN ;* Highest so far
                R.JOB.TIMES<EB.JT.HIGHEST.RESPONSE,1> = MY.AVERAGE.RESPONSE     ;* Save it
            END
        END
    END

    KTIME = TIME()  ;* Ready for next time
    LAST.COMPLETED = R.JOB.TIMES<EB.JT.COMPLETED,1,1>       ;* So we can calculate ongoing throughput
    AGENT.LIST = R.JOB.TIMES<EB.JT.AGENTS,1>      ;* List of agents running this job
    CONVERT ',' TO @FM IN AGENT.LIST    ;* So we can locate
    LOCATE AGENT.NUMBER IN AGENT.LIST<1> SETTING APOS THEN  ;* Are we in here?
        AGENT.REGISTERED=1    ;* Agent might have been registered already in JOB.TIMES incase of RUN.AHEAD
    END ELSE
        AGENT.REGISTERED=1    ;* Agent has been registered now in JOB.TIMES
        AGENT.LIST<-1> = AGENT.NUMBER   ;* Add me to the list
        CONVERT @FM TO ',' IN AGENT.LIST          ;* Ready to store back in job times
        R.JOB.TIMES<EB.JT.AGENTS,1> = AGENT.LIST  ;* Store for display whilst running
    END
RETURN
*------------------------------------------------------------------------
UPDATE.BATCH.STATUS.SERVICE:
* Update Batch Status record with latest elapsed time
* R.BATCH.STATUS<4> - list of Jobs required to be monitored
* R.BATCH.STATUS<5> - Holds the list of worst Batch Jobs
* R.BATCH.STATUS<6> - Holds the list of all jobs
* R.BATCH.STATUS<7> - holds the elapsed time of correspondin Job

RETURN ;* Updates for BAM tool is not required anymore as everything can be monitored in JOB.TIMES file.

READU R.BATCH.STATUS.SERVICE FROM F.BATCH.STATUS, SERVICE.NAME LOCKED       ;* Read the BATCH.STATUS,if locked
* Sleeping for 1 second is too heavy.
*SLEEP 1     ;* Sleep before doing next lock
    GOTO UPDATE.BATCH.STATUS.SERVICE          ;* Try to lock again
END ELSE
    NULL        ;* No record
END

LOCATE FLAG.ID IN R.BATCH.STATUS.SERVICE<6,1> SETTING JOB.POS THEN          ;* If it is already recorded
    R.BATCH.STATUS.SERVICE<7,JOB.POS> = CURR.JOB.ELAPSED.TIME     ;* Update the latest elapsed time
END ELSE
    INS FLAG.ID BEFORE R.BATCH.STATUS.SERVICE<6,1>      ;* Add the Job
    INS CURR.JOB.ELAPSED.TIME BEFORE R.BATCH.STATUS.SERVICE<7,1>  ;* Add the elapsed time of Job
END
IF R.BATCH.STATUS.SERVICE<5,10> NE '' THEN    ;* All 10 positions for holding worst jobs are full
    LOCATE FLAG.ID IN R.BATCH.STATUS.SERVICE<6,1> SETTING JOB.FOUND THEN    ;* Search the Job
        JOB.ELAPSED.TIME = R.BATCH.STATUS.SERVICE<7,JOB.FOUND>    ;* get Job elapsed time
        GOSUB COMPARE.JOB.ELAPSED.TIME
    END
END

WRITE R.BATCH.STATUS.SERVICE TO F.BATCH.STATUS, SERVICE.NAME      ;* Update batch status for enquiry

RETURN

*------------------------------------------------------------------------
STORE.JOB.END.TIME:
* We're the first agent to finish the job - Calculate the final throughput, end time etc

    IF R.JOB.TIMES<EB.JT.START.TIME,1> = "" THEN  ;* We've finished before we had a chance to log some progress
        R.JOB.TIMES<EB.JT.START.TIME,1> = JOB.START.TIME    ;* Recorded as we came in
    END

    IF ROUTINE.USED.CACHE OR (NO.RECORDS.PROCESSED AND USE.CACHE) THEN         ;*  the record routine used cache
        R.JOB.TIMES<EB.JT.READ.WRITE.CACHE,1> = 'Y'         ;*   set the READ.WRITE.CACHE field to 'Y'
    END ELSE
        R.JOB.TIMES<EB.JT.READ.WRITE.CACHE,1> = 'N'         ;* set the READ.WRITE.CACHE field to 'N'
    END

    IF RECORD.VERIFICATION THEN         ;* if the job has verification mechanism
        R.PGM.FILE=''         ;* record to hold the PGM.FILE details
        READU R.PGM.FILE FROM F.PGM.FILE,JOB.NAME LOCKED    ;* read and lock the PGM.FILE record.
        END THEN
            R.PGM.FILE<EB.PGM.REC.VERIFY>= 'Y'    ;* set record verification to 'Y'
            WRITE R.PGM.FILE ON F.PGM.FILE,JOB.NAME         ;* write the record back and release the lock as well
        END
        R.JOB.TIMES<EB.JT.REC.VERIFY,1>='Y'
    END ELSE
        R.JOB.TIMES<EB.JT.REC.VERIFY,1>='N'
    END

    START.TIME = R.JOB.TIMES<EB.JT.START.TIME,1>  ;* Time we started
    IF END.TIME LT START.TIME THEN      ;* Must have flipped over midnight
        ELAPSED.TIME = (END.TIME + (24*3600))-START.TIME    ;* Add a day of seconds
    END ELSE
        ELAPSED.TIME = END.TIME - START.TIME      ;* How long the job took
    END

    CONTROL.LIST.COUNT =DCOUNT(R.JOB.TIMES<EB.JT.BULK.NUMBER,1>, SM)  ;* get the count of control lists
* loop through each sub value set

    FOR POS= 1 TO CONTROL.LIST.COUNT
        IF R.JOB.TIMES<EB.JT.COMPLETED,1,POS> > R.JOB.TIMES<EB.JT.PROCESSED,1,POS> THEN   ;* Could be if they've added to the list file while running
            R.JOB.TIMES<EB.JT.PROCESSED,1,POS> = R.JOB.TIMES<EB.JT.COMPLETED,1,POS>       ;* Make sure they're equal
        END ELSE
            R.JOB.TIMES<EB.JT.COMPLETED,1,POS> = R.JOB.TIMES<EB.JT.PROCESSED,1,POS>       ;* Make sure we see all completed
        END
    NEXT
    
    IF ACTIVATION.FILE THEN
        IF R.JOB.TIMES<EB.JT.COMPLETED,1,1> > R.JOB.TIMES<EB.JT.PROCESSED,1,1> THEN   ;* Could be if they've added to the list file while running
            R.JOB.TIMES<EB.JT.PROCESSED,1,1> = R.JOB.TIMES<EB.JT.COMPLETED,1,1>       ;* Make sure they're equal
        END ELSE
            R.JOB.TIMES<EB.JT.COMPLETED,1,1> = R.JOB.TIMES<EB.JT.PROCESSED,1,1>       ;* Make sure we see all completed
        END
    END

    R.JOB.TIMES<EB.JT.END.TIME,1> = END.TIME
    R.JOB.TIMES<EB.JT.ELAPSED.TIME,1> = ELAPSED.TIME + SUM(R.JOB.TIMES<EB.JT.SELECT.TIME,1>)        ;* Measured in seconds and we need to include the select time

    IF ELAPSED.TIME THEN      ;* We took some time
        OVERALL.THROUGHPUT = SUM(R.JOB.TIMES<EB.JT.PROCESSED,1>) / (ELAPSED.TIME/60)      ;* Per minute
    END ELSE
        OVERALL.THROUGHPUT = SUM(R.JOB.TIMES<EB.JT.PROCESSED,1>) * 60 ;* It took no time to do everything
    END

    R.JOB.TIMES<EB.JT.THROUGHPUT,1> = INT(OVERALL.THROUGHPUT)         ;* Per minute
    R.JOB.TIMES<EB.JT.FASTEST,1> = FASTEST.THROUGHPUT       ;* Store the fastest single throughput

* The first agent completing the job process will update AGENT count = 1 here.
* Subsequent agents( if any) completed same job's process will update their entry in JOB.TIMES
* by incrementing AGENT field by 1 at END stage process (Last END case in UPDATE.JOB.TIMES para).

    R.JOB.TIMES<EB.JT.AGENTS,1> = 1     ;* Store the agent as 1 rather than their total count - indicates first agent ending.
    SERVICE.NAME =  R.TSA.STATUS<TS.TSS.CURRENT.SERVICE>    ;* get the current service

    CURR.JOB.ELAPSED.TIME = ELAPSED.TIME          ;* get Elapsed time

RETURN
*-----------------------------------------------------------------------------
COMPARE.JOB.ELAPSED.TIME:
* Find whether Job elapsed time is greater than worst jobs in list.
* Add it when elapsed time is higher

    WORST.JOB.LIST = R.BATCH.STATUS.SERVICE<5>    ;* List of Jobs which has greater elapsed time
    LEAST.JOB.TIME = ''       ;* Variable that hold the job Id which has least elapsed time
    LEAST.JOB.TIME.POS = ''   ;* Variable that hold the Least Job position
    WS.POS = 0      ;* Position of Job to be added
    WORST.ELAPSED.TIME = ''   ;* Initialise the variable

    LOOP
        REMOVE WORST.JOB FROM WORST.JOB.LIST SETTING JOB.POINTER      ;* Loop through all Jobs
    WHILE WORST.JOB ;* for each job
        WS.POS += 1 ;* Increment the position
        LOCATE WORST.JOB IN R.BATCH.STATUS.SERVICE<6,1> SETTING WO.POS THEN     ;* Find the  job

            WORST.ELAPSED.TIME = R.BATCH.STATUS.SERVICE<7,WO.POS>     ;* get the elapsed time of Job

        END
        IF JOB.ELAPSED.TIME > WORST.ELAPSED.TIME THEN       ;* check if the current job elapsed time is greater
            IF LEAST.JOB.TIME AND (LEAST.JOB.TIME GE WORST.ELAPSED.TIME ) THEN  ;* compare the jobs
                LEAST.JOB.TIME = WORST.ELAPSED.TIME         ;* Store the elapsed time
                LEAST.JOB.TIME.POS = WS.POS       ;* Store the position
            END
            IF LEAST.JOB.TIME = '' THEN ;* Least Job is not yet found
                LEAST.JOB.TIME = WORST.ELAPSED.TIME         ;* Store the elapsed time
                LEAST.JOB.TIME.POS = WS.POS       ;* Store the position
            END

        END

    REPEAT

    IF LEAST.JOB.TIME.POS THEN          ;* Least Job time position is found

        DEL R.BATCH.STATUS.SERVICE<5,LEAST.JOB.TIME.POS>    ;* Delete the position
        INS FLAG.ID BEFORE R.BATCH.STATUS.SERVICE<5,LEAST.JOB.TIME.POS>         ;* Include the current job

    END

RETURN
*-----------------------------------------------------------------------------
UPDATE.PROGESS.BATCH.STATUS:
* para to update the key count progress in BATCH.STATUS
* an enquiry could be written on batch.status to show the the no of records selected,
* currently how many processed per control.list
*
    READU R.BATCH.STATUS FROM F.BATCH.STATUS,FLAG.ID LOCKED ;* if locked by some body else
        RETURN      ;* return immediately
    END THEN
        IF CONTROL.LIST<1,1> EQ R.BATCH.STATUS<1,1> THEN    ;*We are in the current control list
            R.BATCH.STATUS<1,5> = R.BATCH.STATUS<1,5> + KEY.COUNT     ;* update the key count processed so far
        END

        WRITE R.BATCH.STATUS ON F.BATCH.STATUS,FLAG.ID      ;* write back the batch status record
    END  ELSE
        RELEASE F.BATCH.STATUS,FLAG.ID  ;* unable to read the record(strange but safe) release the lock
    END

RETURN
*-----------------------------------------------------------------------------

OPEN.LIST.FILE:
* Open the list file which goes with the job or allocate a list file from the pool
* The number of list files in the pool is = number of batch sessions. This allows
* for every session running a non-standard multi-thread job and using a list file
* from the pool. If the pool list file does not exist (ie someone has changed the
* number of sessions) then create it.
* The list file may also be a permanent activation list file.
*
    ETEXT = ''
    IF ACTIVATION.FILE THEN
        BEGIN CASE
            CASE ACTIVATION.FILENAME NE ''
                F.ACTIVATION.FILE = 'F.':ACTIVATION.FILENAME ;* Holds the file name inputted the field ACTIVATION.FILENAME in PGM record
            CASE INDEX(PROCESS.NAME,"/",1)
                F.ACTIVATION.FILE = 'F.':PROCESS.NAME[5,999]:'.LIST'
            CASE 1
                F.ACTIVATION.FILE = 'F.':PROCESS.NAME:'.LIST'
        END CASE
        FN.LIST.NAME = F.ACTIVATION.FILE
        F.LIST.NAME = ''
        CALL OPF(FN.LIST.NAME,F.LIST.NAME)        ;* Open it
    END

    BATCH.LIST.FILE = FN.LIST.NAME      ;* In common for FATAL.ERROR - note: FNNN... full name!

RETURN
*----------------------------------------------------------------------------
GET.LIST.FROM.POOL:
* Allocate the next free list file from the pool OR if one has already been allocated
* to this job the use it.

    READ FN.LIST.NAME FROM F.LOCKING, FLAG.ID THEN          ;* Read first, else then lock and find the free list
        CALL OCOMO("Obtained the Locking with ":FLAG.ID:" and ":FN.LIST.NAME)   ;* Output to como about the data we got
    END ELSE
        CALL EB.TRANS('START','')       ;* Start transaction boundary
        READU FN.LIST.NAME FROM F.LOCKING, FLAG.ID THEN     ;* Wait till i get the lock (Do not introduce LOCKED clause and SLEEP, as by the time i resume from sleep, the job would have completed and FLAG.ID delete and there by i will be allocating the JOB.LIST again)
            CALL OCOMO("Obtained the Locking with ":FLAG.ID:" and ":FN.LIST.NAME)         ;* Output to como about the data we got
            RELEASE F.LOCKING, FLAG.ID  ;* Release it
        END ELSE    ;* I am the first to get lock
            LIST.OWNER = 1    ;* I am allocating the .LIST file
            CALL OCOMO("Allocating List File for ":FLAG.ID)
            CALL GET.FREE.LIST.FILE(FN.LIST.NAME)
            CALL OCOMO("Updating the Locking with ":FLAG.ID:" and ":FN.LIST.NAME)         ;*Output to como about the update
            WRITE FN.LIST.NAME TO F.LOCKING, FLAG.ID        ;* Allocate this file to this job and allow the other threads to pick it up
            WRITE FLAG.ID TO F.LOCKING,FN.LIST.NAME         ;* Maintain another record in LOCKING keyed by the list file to stop other threads from picking it up
        END
        CALL EB.TRANS('END','')         ;*Commit transaction
    END

    FN.LIST.NAME<2> = 'NO.FATAL.ERROR'  ;* Still with the lock on F.LOCKING - try and open it
    CALL OPF(FN.LIST.NAME,F.LIST.NAME)  ;* Open it
    IF ETEXT THEN   ;* It's important that only one thread tries to create the list file
        GOSUB CREATE.LIST.FILE          ;* Need a new one
        CALL OPF(FN.LIST.NAME,F.LIST.NAME)        ;* Open it and fatal if we can't
    END
    BATCH.LIST.FILE = FN.LIST.NAME      ;*Set BATCH.LIST.FILE common for the fatal errors
RETURN
*----------------------------------------------------------------------------
CREATE.LIST.FILE:
* Create the file control record (copy from list number 1) and create the list file
*
    CALL OCOMO('Creating list file ':FN.LIST.NAME)          ;* BG_100002910 S/E
    FILE.TO.CREATE = FIELD(FN.LIST.NAME,'.',2,999)
    READ R.FILE.CONTROL FROM F.FILE.CONTROL, 'JOB.LIST.1' THEN        ;* Copy number 1
        WRITE R.FILE.CONTROL TO F.FILE.CONTROL, FILE.TO.CREATE        ;* The new file
    END
    CALL EBS.CREATE.FILE(FILE.TO.CREATE,'','')    ;* And go ahead and create it

RETURN
*----------------------------------------------------------------------------
RELEASE.LIST.FILE:
* Allow the list file to be used by another thread. Note you may not be alone in
* doing this - so allow for the records to be 'missing'

    READ R.LIST.FILE FROM F.LOCKING,FLAG.ID ELSE  ;*Read and see a valid record exists
        RETURN      ;*Someone has already done no point in doing again
    END

    READU R.LIST.FILE.NAME FROM F.LOCKING,FLAG.ID THEN      ;* If found
        IF R.LIST.FILE.NAME EQ FN.LIST.NAME THEN  ;* To check whether another instance of the job has started with a new list
            DELETE F.LOCKING, FLAG.ID   ;* Clear in case we used a file from the pool
        END ELSE
            RELEASE F.LOCKING, FLAG.ID  ;* Else just release the record
        END
    END ELSE        ;* If some other session has already deleted it
        RELEASE F.LOCKING,FLAG.ID       ;* Just release the record and get out
    END

    READU R.LIST.RECORD FROM F.LOCKING,FN.LIST.NAME THEN    ;*If found
        IF R.LIST.RECORD EQ FLAG.ID THEN          ;*Only if it is for current job
            DELETE F.LOCKING,FN.LIST.NAME         ;*Delete it and make list file available
        END ELSE
            RELEASE F.LOCKING,FN.LIST.NAME        ;*Already allocated to different job should not delete
        END
    END ELSE
        RELEASE F.LOCKING,FN.LIST.NAME  ;*Someone has cleared it already
    END


RETURN
*-----------------------------------------------------------------------------
DISTRIBUTE.LIST.RECORDS:

*In case we are in the last few records, and if the list file contains more than one batch key to process
*split up the list keys. The new key to the list file will be the existing key suffixed with N where N is the nth
*batch key in the existing list record. After forming the new keys the old record will be deleted

    CALL EB.TRANS('START',RMSG)         ;*Start the Transaction
    NO.OF.LIST.KEYS = DCOUNT(LIST.RECORD,FM)      ;*Total ids in this list record
    FOR LIDX = 1 TO NO.OF.LIST.KEYS     ;*Loop through one by one
        IF LIDX = 1 THEN
            WRITE LIST.RECORD<LIDX> ON F.LIST.NAME,LIST.KEY      ;*Write it with the LIST.KEY (overwrite original list record with first distributed id)
        END ELSE
            WRITE LIST.RECORD<LIDX> ON F.LIST.NAME,LIST.KEY:"-":LIDX-1      ;*Write it with the LIST.KEY-Counter
        END
    NEXT LIDX
    CALL EB.TRANS('END',RMSG) ;*Commit the Transacction

RETURN

*************************************************************************
DW.PROCESSING:

* Data Warehousing. Extraction from OLTP database. On every record commit
* we pass on the details on the files updated to check whether we are
* interested in the file update.
*
    IF DW$INSTALLED EQ 'EXTRACT' OR (DW$INSTALLED EQ 'EXPORT' AND NOT(DW.RTN.EXIST)) THEN       ;* if DW Installed is Extract or when DW Installed is export and DW.EXPORT.CAPTURE routine does not exist
        IF SET.COLLECT = 0 THEN
            ASSIGN DW$EXTRACT.MODE TO SYSTEM(1039)
            SET.COLLECT = 1
        END ELSE
            DW.FILE.DETAILS = SYSTEM(1039)        ;* details of all the files updated
            WRK.FILE.ID = FLAG.ID       ;* id for the wrk and activation file
            CALL EB.TRANS('START',RETURN.MSG)     ;* Start a transaction
            CALL DW.PROCESS.TXN(WRK.FILE.ID,DW.FILE.DETAILS,RETURN.VAR)         ;* extract
            CALL EB.TRANS('END',RETURN.MSG)       ;* End transaction
            SEL.COLLECT = 0
        END
    END ELSE
        IF DW$INSTALLED EQ 'EXPORT' AND ADDITIONAL.INFO EQ '.NUC' THEN ;* if additional.info is set to .nuc capture the record using system(1039)
            IF SET.COLLECT = 0 THEN	;* if set collect is zero assign 7 to system(1039) variable to capture the transaction
                ASSIGN 7 TO SYSTEM(1039) ;*assign 7 to system(1039)
                SET.COLLECT = 1 ;*set SET.COLLECT to 1 
            END ELSE
                DW.FILE.DETAILS = SYSTEM(1039) ;* use the system variable to capture the record change when .NUC is used
                BATCH.JOB.CONTROL.FLAG = "BATCH.JOB.CONTROL":@FM:ADDITIONAL.INFO ;*appending additional info for for processing in DW.EXPORT.CAPTURE
                CALL DW.EXPORT.CAPTURE(BATCH.JOB.CONTROL.FLAG) ;*call DW.EXPORT.CATURE to further process the record and update on respective work file
                SET.COLLECT = 0	;*set SET.COLLECT to 0
            END
        END
    END

RETURN
*-----------------------------------------------------------------------------

*
CHK.STILL.HOLD.LIST.FILE:

    IF NOT(FN.LIST.NAME) THEN ;*Nothing has been allocated yet
        RETURN      ;*No need to do the check
    END

    READ THE.LIST.FILE FROM F.LOCKING,FLAG.ID ELSE          ;* get the name of the list file allocated
        THE.LIST.FILE = ''    ;* cannot read, strange but possible
    END

    IF THE.LIST.FILE NE FN.LIST.NAME THEN         ;* if the allocated and the current one are not the same
        RELEASE F.BATCH.STATUS, FLAG.ID ;* Because we locked it at the top of the loop
        CALL OCOMO("List File ":FN.LIST.NAME:" not associated  to this Job Anymore")
        GOTO PROGRAM.ABORT    ;* Back to S.JOB.RUN immediately
    END
RETURN
*---------------------------------------------------------------------------------

PROGRAM.ABORT:
    JOB.PROGRESS = ""  ;* Set this as null as this is going to S.JOB.RUN from BATCH.JOB.CONTROL.
RETURN TO PROGRAM.ABORT
*----------------------------------------------------------------------------------

PROGRAM.END:

    CALL TSA.STATUS.UPDATE('STOPPED')   ;* mark the AGENT as STOPPED
    CRT "Agent stopped"
    GOSUB CLOSE.TAGS          ;* close the service,job and name tags
    EXECUTE 'COMO OFF'        ;* Switch off the COMO when service is stopped

* Only for eld UniVerse releases
    STOP  ;* Cannot continue - do not go back to S.JOB.RUN (otherwise it will think the job has completed successfully)

*-----------------------------------------------------------------------------
*

UPDATE.PROGRESS.BATCH.STATUS:
*
* para to update the key count progress in BATCH.STATUS
* an enquiry could be written on batch.status to show the the no of records selected,
* currently how many processed per control.list
*
    READU R.BATCH.STATUS FROM F.BATCH.STATUS,FLAG.ID LOCKED ;* if locked by some body else
        RETURN      ;* return immediately
    END THEN
        IF CONTROL.LIST<1,1> EQ R.BATCH.STATUS<1,1> THEN    ;*We are in the current control list
            R.BATCH.STATUS<1,5> = R.BATCH.STATUS<1,5> + KEY.COUNT     ;* update the key count processed so far
        END

        WRITE R.BATCH.STATUS ON F.BATCH.STATUS,FLAG.ID      ;* write back the batch status record
    END  ELSE
        RELEASE F.BATCH.STATUS,FLAG.ID  ;* unable to read the record(strange but safe) release the lock
    END

RETURN

*-----------------------------------------------------------------------------
*
UPDATE.TOTAL.WRITES:
* Update the lock collision count,total writes count.

    IF COLLISION.COUNT THEN   ;* lock collision
        R.JOB.TIMES<EB.JT.LOCK.COLLISION,1> += COLLISION.COUNT        ;* add up the lock collision count in the job
        COLLISION.COUNT=0     ;* reset the lock collision count
    END
    IF TOTAL.WRITES THEN      ;* writes happened
        R.JOB.TIMES<EB.JT.TOTAL.WRITE,1>+= TOTAL.WRITES     ;* add up the writes count in the job
        TOTAL.WRITES=0        ;* reset the writes count
    END

RETURN

*-----------------------------------------------------------------------------

CHECK.TXN.MGMT:
*
    IF TXN.MGMT THEN          ;* Check if the job is run with the transaction management
        R.JOB.TIMES<EB.JT.TXN.MANAGEMENT,1>= 'Y'  ;* update the field as 'Y'
    END ELSE
        R.JOB.TIMES<EB.JT.TXN.MANAGEMENT,1>=  'N' ;* update the field as 'N'
    END

RETURN

*-----------------------------------------------------------------------------
*
CHECK.RECORD.VERIFICATION:
*
*See whether the record routine has the verification mechanism .
* For a multithreaded job,if the record routine has got the mechanism to eliminate unnecessary keys,
* then it returns -1(processing) or -2(eliminating).If it does then set the variable
* RECORD.VERIFICATION to 'Y' so that REC.VER field in the PGM.FILE of the JOB is set to 'Y'.

    IF NOT(RECORD.VERIFICATION) AND KEY.TO.PASS<1> MATCHES '-1':VM:'-2' THEN    ;* if -1 or -2 is passed from the record routine and RECORD.VERIFICATION has not been set yet
        RECORD.VERIFICATION='Y'
    END
RETURN

*-----------------------------------------------------------------------------
*
CHECK.CACHE:
* checks whether the record routine has actually used the cache and write cache updates
*
    IF NOT(ROUTINE.USED.CACHE) AND NOT(CACHE.OFF) THEN      ;* the record routine has used the cache.(CACHE.OFF=0)
        ROUTINE.USED.CACHE='Y'
    END

* If the WRITE.CACHE is set , then flush the data from the
* cache variables and write it into the disk as we do it in JOURNAL.UPDATE
    LOCK.FILE  = '' ;* will hold information on the file id which have just been locked without a write or delete
    IF WRITE.CACHE THEN       ;*  WRITE.CACHE set
        GOSUB WRITE.INTO.DISK ;* write into the disk
    END

    IF LIST.KEY = LAST.LIST.KEY ELSE    ;* this is same as last list key then
        LIST.KEY.CNT = 0
        LAST.LIST.KEY = LIST.KEY
    END

    IF LOCK.FILE THEN         ;* if we have anything to be logged on the records which are just locked
        LIST.KEY.CNT +=1
        WRITE LOCK.FILE TO F.LOCKING,'DUMMY.LOCKS-':FLAG.ID:'-':LIST.KEY:'-':LIST.KEY.CNT :'-':@USER.NO:'-':C$BATCH.START.DATE    ;* write them
        LOCK.FILE = ''        ;* clear this variable for recording next log
    END
*
RETURN
*
*-----------------------------------------------------------------------------
*
WRITE.INTO.DISK:
*
* loop through the cache varables and write the records into the disk

    CACHE.COUNT = DCOUNT(FWT,@FM)       ;* Number of records in the cache
    LOCK.CNT  = 0   ;* counter for the above lock file
    deleteFileNames = ''
    deleteFileId = ''

    FOR CIDX = 1 TO CACHE.COUNT         ;* For every record in the cache
        IF FWF(CIDX)[1,1]='W' THEN      ;* Should I write it
            FILE.DETAILS = FWT<CIDX>    ;* Name and ID from cache
            FL = FILE.DETAILS[" ",1,1]  ;* File name
            ID = FILE.DETAILS[" ",2,1]  ;* ID
            RC = FWC(CIDX)    ;* Record to write
            CALL OPF(FL,F.FL) ;* Get file variable
            IF RC EQ 'DELETE' THEN      ;* delete the record
                DELETE F.FL, ID ON ERROR          ;* Delete it
                    TEXT = 'Cannot delete ':ID:' from ':FL  ;* Delete error
                    CALL FATAL.ERROR('BATCH.JOB.CONTROL')
                END
                IF Record THEN
                    LOCATE FL IN deleteFileNames SETTING POS THEN           ;* Check if file name is already populated
                        deleteFileId<POS,-1> = ID           ;* Just append the id against corresponding file position
                    END ELSE
                        deleteFileNames<-1> = FL                ;* File name deleted
                        deleteFileId<-1> = ID                   ;* Id to be deleted
                    END
                END
            END ELSE          ;* write the record
                GOSUB ENCRYPT.FIELDS    ;* check data encryption
                WRITE RC TO F.FL, ID ON ERROR
                    TEXT = 'Cannot write ':ID:' to ':FL     ;* Write error
                    CALL FATAL.ERROR('BATCH.JOB.CONTROL')
                END
            END
        END ELSE
            IF R.SPF.SYSTEM<SPF.OP.CONSOLE,1> MATCHES 'ON':@VM:'PERFORMANCE':@VM:'TEST' AND TRIM(FWF(CIDX)[1,2])='L' THEN         ;* if just locked without either write or delete
                LOCK.CNT +=1  ;* increase the counter by 1
                LOCK.FILE<LOCK.CNT> = FWT<CIDX>:'_':FWF(CIDX)         ;* file name id and operation performed
            END
        END
    NEXT CIDX
    IF deleteFileNames AND dlInstalled AND Record THEN        ;* Check if dl product exists and deleted file name list is available
        R.WORKLOAD.RECORD='' ; READ.FAILED='' ;* Initialise
        CALL CACHE.READ('F.TSA.WORKLOAD.PROFILE','DLM.DELETE.PROCESS',R.WORKLOAD.RECORD,READ.FAILED) ;* Check for workload profile record of DELETE.PROCESS
        IF R.WORKLOAD.RECORD THEN ;* if available
            CALL DLM.PROCESS(deleteFileNames,deleteFileId,'D','','','','')   ;* Invoke the DLM api with file names and record ids
        END
    END
    

RETURN

*-----------------------------------------------------------------------------
*
CLEAR.SELECTION.VARIABLES:
*
* clear the selection and bulking common varables so that it is set correctly for the
* next CONTROL.LIST selection or next job selection

    BULK.NUMBER=0   ;* initilaise the records bulked common variable
    SELECTION.MODE=''         ;* initialise the selection mode variable
    SELECT.STATEMENT=''       ;* initialise the select statement variable

RETURN

*-----------------------------------------------------------------------------
*
SET.CACHE.VARIABLES:
* sets and resets the cache variables

*
* If the job doesn't want to use the cache,set CACHE.OFF=1 and WRITE.CACHE=0 so that a F.WRITE
* and F.MATWRITE would actually write into the disk
* By default, the job would use the cache. set CACHE.OFF= 0 and WRITE.CACHE =1 so that a F.WRITE
* and F.MATWRITE would actually write into the cache and flushed latter.

    BEGIN CASE
        CASE SET.CACHE  ;* set the cache variables
            IF USE.CACHE THEN     ;*  use the cache
                CACHE.OFF=0       ;* turn the cache on
                WRITE.CACHE=1     ;* set the write cache so that F.WRITE and F.MATWRITE would actually write into the cache
            END ELSE
                CACHE.OFF=1       ;* turn the cache off
                WRITE.CACHE =0    ;* turn off the write cache
            END
        CASE OTHERWISE  ;* reset the cache variables
            CACHE.OFF=1 ;* make sure that the cache is turned off
            WRITE.CACHE=0         ;* write cache is turned off as well

    END CASE
RETURN
*-----------------------------------------------------------------------------
*
CLOSE.TAGS:
* close the service,process and job tags

    IF JOB.TAG.OPEN THEN      ;* job tag open
        CRT C$JOB.TAG.C       ;* close the job name tag
    END

    IF PROCESS.TAG.OPEN THEN  ;* process tag open
        CRT C$PROCESS.TAG.C   ;* close the process name tag
    END

    IF SERVICE.TAG.OPEN THEN  ;* if service tag has
        CRT C$SERVICE.TAG.C   ;* close the service
    END

    IF COMO.TAG.OPEN THEN     ;* if COMO Tag is open
        CRT C$COMO.TAG.C      ;* close the como tag
    END

RETURN
*----------------------------------------------------------- -----------------
***<region = ENCRYPT.FIELDS>
ENCRYPT.FIELDS:
***
* if eb encryption param is setup then check whether the current file name is
* one of the encrypted applications, if then call the encrypt routine and
* pass on the record for encrypting the desired fields before writing it to disk.
*
    IF ENC$R.EB.ENC.PARAM THEN          ;* if encryption param set-up
        YNAME.REALLY = FIELD(FL,".",2,99)         ;* Name without the F. prefix
        Y.FILE.NAME = FIELD(YNAME.REALLY,"$",1)
        LOCATE Y.FILE.NAME IN ENC$ENCRYPT.APPL<1,1> SETTING APPL.POS THEN       ;* if file name specified
            ENCRYPT.RTN.NAME = ENC$ENCRYPT.RTN    ;* the encrypt routine name
            R.RECORD = LOWER(RC)        ;* lower the record for EB.API
            ARGUMENTS = FL:FM:ID:FM:R.RECORD      ;* File name, ID and lower'ed Record
            CALL EB.CALL.API(ENCRYPT.RTN.NAME, ARGUMENTS)   ;* call the encryption routine
            R.RECORD =  ARGUMENTS<3>    ;* returned record after encryption
            RC = RAISE(R.RECORD)        ;* raise the record
        END
    END
RETURN
*** </region>

*------------------------------------------------------------------------------

*** <region name= UPDATE.TEC.JOB.SELECT>
UPDATE.TEC.JOB.SELECT:
*** <desc>Update the JOB.SELECT event </desc>

RETURN ;* Not required TEC Update on JOB.SELECT for better performance during EOD.
    
ITEM.ID = "JOB.SELECT"
GOSUB BUILD.MY.KEY
MY.DETAIL = ""
MY.VALUE = KEYS.PROCESSED
CALL TEC.RECORD.ACTIVITY(ITEM.ID, MY.KEY, MY.DETAIL, MY.VALUE)

RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= UPDATE.TEC.JOB.PROGRESS>
UPDATE.TEC.JOB.PROGRESS:
*** <desc>Update the JOB.PROGRESS event </desc>

RETURN ;* Not required TEC Update on JOB.PROGRESS for better performance during EOD.

ITEM.ID = "JOB.PROGRESS"
GOSUB BUILD.MY.KEY
MY.DETAIL = ""
MY.VALUE = KEYS.PROCESSED
CALL TEC.RECORD.ACTIVITY(ITEM.ID, MY.KEY, MY.DETAIL, MY.VALUE)

RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= BUILD.MY.KEY>
BUILD.MY.KEY:
*** <desc>Build MY.KEY </desc>

    MY.KEY = ID.COMPANY : "_" : C$BATCH.START.DATE : "-"
    MY.KEY := PROCESS.NAME : "_" : JOB.INFO["_", 1, 1] : "_" : JOB.INFO["_", 5, 1]        ;* Changed JOB.INFO["_", 4,1] to JOB.INFO["_", 5,1] because PROCESS.STAGE included as 3rd value in Initialise.

RETURN

*** </region>

*-----------------------------------------------------------------------------

*** <region name= invokeIntegrationFramework>
invokeIntegrationFramework:
*** <desc>Invoke integration framework to generate events for attached flows, if any </desc>

    IF isIFProductInstalled EQ "" THEN  ;* need to check whether or not IF is installed
        errorMessage = ""
        CALL IF.CHECK.PRODUCT(isIFProductInstalled, errorMessage)     ;* 0 -> not installed; 1 -> installed
    END

    IF isIFProductInstalled EQ 1 AND flowNames NE "" THEN   ;* IF is installed and flows are attached to this job so invoke IF
        CALL IF.TSA.SERVICE.EXIT.HANDLER(jobBeingProcessed, flowNames, applicationNames, flowMetadataList, flowAttributesList, txnKeyList, oldTxnRecordList)
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= CHECK.SEAT.TRACE>
CHECK.SEAT.TRACE:
*** <desc>Check whether the current job needs to be trace. Trace all the contracts in the job. Most important trace only if results are defined for that job </desc>

    CALL EB.READ.SPF          ;* Get the correct OP.MODE
    SEAT.ON = 0      ;* Variable to indicate whether SEAT is turned ON
    SEAT.TRACE.ON = '' ;* Holds 1, if the current job needs to be traced, else null.
    phantomMode = SYSTEM(25)  ;* To denote whether service is started in phantom or debug mode
    IF NOT(R.SPF.SYSTEM<SPF.OP.CONSOLE,1> MATCHES 'ON':@VM:'PERFORMANCE':@VM:'TEST':@VM:'RECORD' AND phantomMode) THEN   ;* When SEAT trace enabled and phantom mode of processing
        RETURN ;* No Images will be captured, since SEAT is NOT turned on
    END
    CURRENT.MEMORY = SYSTEM(1026) ;* To get the current memory occupied by current running agent.
    MEM.MB = FIELD(CURRENT.MEMORY,',',1)
    IF MEM.MB GT 40 THEN
        CALL TSA.STATUS.UPDATE('STOPPED') ;* I'm screwing something. Let me suicide.
        CALL OCOMO('Agent too heavy')
        CALL OCOMO('Current Memory ':CURRENT.MEMORY)
        STOP
    END
    SEAT.ON = 1 ;* SEAT Enabled.
    seatJobPos = '' ;*
    R.SEAT.TEST = ''          ;* initialise the variable R.SEAT.TEST
    READ R.SEAT.TEST FROM F.LOCKING, 'SEAT.TRACE' THEN  ;* See if we've been asked to trace a particular job/contract
        LOCATE JOB.NAME IN R.SEAT.TEST<1> SETTING seatJobPos THEN
            R.SEAT.TEST = JOB.NAME ;* Assign the job name to R.SEAT.TEST
            SEAT.TRACE.ON = 1 ;* This JOB needs to be traced.
        END
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= initialiseIntegrationFrameworkParameter>
initialiseIntegrationFrameworkParameter:
*** <desc>Initialises the parameters used by the IF calls </desc>
    keyBeingProcessed = KEY.TO.PASS     ;* to pass the key to integration framework
    jobBeingProcessed = JOB.NAME ;* exit point name

    flowNames = "" ;* flow names attached to the exit point (job)
    applicationNames = "" ;* flow source application names
    flowMetadataList = "" ;* flow metadata list to be used for event generation
    flowAttributesList = "" ;* flow attributes list to be used for event generation
    txnKeyList = "" ;* computed txn keys for the transaction records to be used
    oldTxnRecordList = "" ;* before image records list for event generation

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= prepareIntegrationFramework>
prepareIntegrationFramework:
*** <desc>prepares integration framework, if required </desc>

    IF isIFProductInstalled EQ "" THEN  ;* need to check whether or not IF is installed
        errorMessage = ""
        CALL IF.CHECK.PRODUCT(isIFProductInstalled, errorMessage)     ;* 0 -> not installed; 1 -> installed
    END

    IF isIFProductInstalled EQ 1 THEN   ;* IF is installed so invoke IF prebuild
        CALL IF.PREBUILD.TSA.SERVICE.EXIT(jobBeingProcessed, keyBeingProcessed, flowNames, applicationNames, flowMetadataList, flowAttributesList, txnKeyList, oldTxnRecordList)
    END

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= DW.EXPORT.PROCESS>
DW.EXPORT.PROCESS:
*** <desc> DW Processing specialy for EXPORT  </desc>
    IF DW$INSTALLED EQ 'EXPORT' AND (ADDITIONAL.INFO NE '.NUC' AND ADDITIONAL.INFO NE '.NTX') AND DW.RTN.EXIST THEN    ;* if  DW Installed is export and DW.EXPORT.CAPTURE routine exists
        CALL DW.EXPORT.CAPTURE("BATCH.JOB.CONTROL")		;* call DW.EXPORT.CAPTURE to capture the transaction
    END
    
RETURN
*** </region>
*-----------------------------------------------------------------------------
END



