--[GLOBAL: SIF PACKAGE SR_PROCESS]
--[VERIFY: OWNER: SR TYPE: PACKAGE OBJECT: SR_PROCESS]
CREATE OR REPLACE PACKAGE      CTUSR.SR_PROCESS authid current_user AS
--*****************************************************************************
--Module      : Generic
--Type        : PL/SQL - Package
--Filename    : $sql/SR_PROCESS.pks
--Author      : Sergey Popov
--Version     : 0.1
--                     
--
-- Description: Generic object Routine (Task) for all interchange modules
--              
-- log procedures
-- *****************************************************************************
/* Declare externally visible types, cursor, exception. */
   msgtype    VARCHAR2 (20)    := 'INFO';
   msgtext    VARCHAR2 (2000)  := 'Text';
   msgid      VARCHAR2 (20)    := '100';
   usermsg    VARCHAR2 (20)    := '1';
   msgsrc     VARCHAR2 (2000)  := 'SR_PROCESS';
   msgjobid   VARCHAR2 (100);

------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                CURSORS	
------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Name              process_cur
-- Created           30.01.12
-- Created by        SEP
-- Purpose           get PROCESS(s) particulars by Name. 
--                   Refactoring required per process/composition role
--
-- Last changes
------------------------------------------------------------------------------------------------------------------------------------------------------------
  CURSOR process_cur (ip_procname   CTUSR.PROCESS.PROCESS_NAME%TYPE) IS  
  SELECT 
     prc.PROCESS_ID,
     prc.BU_ID,
     prc.MEP_ID,
     prc.PROCESS_NAME,
     prc.PROCESS_DESCRIPTION,
     prc.LOGGING_LEVEL,
     prc.SDD_URL,
     prc.PROC_CUSTODIAN,
     prc.SDD_CUSTODIAN,
     bul.BU_CODE,
     bul.BU_LOCATION,
     mep.MEP_NAME,
     mep.MEP_DESCRIPTION
FROM 
   CTUSR.PROCESS prc,
   CTUSR.MEP mep,
   CTUSR.BU_LOCATION bul
WHERE(    prc.bu_id        = bul.bu_id
   and   prc.mep_id       = mep.mep_id
   and   prc.process_name = ip_procname
  );	
  
  
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Name              proccomposition_cur
-- Created           30.01.12
-- Created by        SEP
-- Purpose           get PROCESS(s) particulars by Name. 
--                   Refactoring required per process/composition role
--
-- Last changes
------------------------------------------------------------------------------------------------------------------------------------------------------------
  CURSOR proccomposition_cur (ip_procname   CTUSR.PROCESS.PROCESS_NAME%TYPE) IS  
  select svc.service_id,
       svc.TASK,
       svc.SERVICEMODEL_ID,
       svc.ENGINE_ID,
       prc.process_name, 
       prc.process_id,
       com.task_order,
       sen.ENGINE_TYPE,
       sen.ENGINE_NAME,
       sen.ENGINE_URL,
       sem.SERVICE_MODEL,
       sem.MODEL_DESCRIPTION,
       bul.BU_CODE,
       bul.BU_LOCATION,
       mep.MEP_NAME,
       mep.MEP_DESCRIPTION
   from service svc,
      process prc,
      composition com,
      SERVICE_ENGINE sen,
      SERVICE_MODEL  sem,
      CTUSR.MEP mep,
      CTUSR.BU_LOCATION bul
  where com.process_id      = prc.process_id 
  and com.service_id      = svc.service_id
  and svc.ENGINE_ID       = sen.ENGINE_ID
  and svc.SERVICEMODEL_ID = sem.SERVICEMODEL_ID
  and prc.bu_id           = bul.bu_id
  and prc.mep_id          = mep.mep_id
  and (prc.process_name   = ip_procname )
  order by com.task_order;
  
------------------------------------------------------------------------------------------------------------------------------------------------------------   
   
   
   TYPE sifservice_rec IS RECORD (
        PROCESS_ID           CTUSR.PROCESS.PROCESS_ID%type,
        BU_ID                CTUSR.PROCESS.BU_ID%type,
        MEP_ID               CTUSR.PROCESS.MEP_ID%type,
        PROCESS_NAME         CTUSR.PROCESS.PROCESS_NAME%type,
        PROCESS_DESCRIPTION  CTUSR.PROCESS.PROCESS_DESCRIPTION%type,
        LOGGING_LEVEL        CTUSR.PROCESS.LOGGING_LEVEL%type,
        SDD_URL              CTUSR.PROCESS.SDD_URL%type,
        PROC_CUSTODIAN       CTUSR.PROCESS.PROC_CUSTODIAN%type,
        SDD_CUSTODIAN        CTUSR.PROCESS.SDD_CUSTODIAN%type,
        BU_CODE              CTUSR.BU_LOCATION.BU_CODE%type,
        BU_LOCATION          CTUSR.BU_LOCATION.BU_LOCATION%type,
        MEP_NAME             CTUSR.MEP.MEP_NAME%type,
        MEP_DESCRIPTION      CTUSR.MEP.MEP_DESCRIPTION%type
        );
		

   FUNCTION get_processID (ip_processname IN CTUSR.PROCESS.PROCESS_NAME%TYPE)
      RETURN NUMBER;	  
END SR_PROCESS;
--[END]


/
