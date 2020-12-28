--[GLOBAL: SIF PACKAGE SR_SERVICE]
--[VERIFY: OWNER: SR TYPE: PACKAGE OBJECT: SR_SERVICE]
CREATE OR REPLACE PACKAGE      CTUSR.SR_SERVICE authid current_user AS
--*****************************************************************************
--Module      : Generic
--Type        : PL/SQL - Package
--Filename    : $sql/SR_SERVICE.pks
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
   msgsrc     VARCHAR2 (2000)  := 'SR_SERVICE';
   msgjobid   VARCHAR2 (100);

------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                CURSORS	
------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Name              service_cur
-- Created           30.01.12
-- Created by        SEP
-- Purpose           get SERVICE(s) particulars by ID. 
--                   Refactoring required per process/composition role
--
-- Last changes
------------------------------------------------------------------------------------------------------------------------------------------------------------
  CURSOR service_cur (
           ip_svcid   CTUSR.SERVICE.SERVICE_ID%TYPE
     ) IS  
  SELECT 
	svc.SERVICE_ID,
	svc.SERVICEMODEL_ID,
	svc.TASK,
	svc.ENGINE_ID,
	svc.SERVICE_NAME,
	svc.SERVICE_DESCRIPTION,
	svc.SERVICE_URL,
	svc.SERVICE_HOST,
	sre.ENGINE_TYPE,
	sre.ENGINE_NAME,
	sre.ENGINE_URL,
	srm.SERVICE_MODEL,
	srm.MODEL_DESCRIPTION
  FROM 
	CTUSR.SERVICE svc,
	CTUSR.SERVICE_ENGINE sre,
	SERVICE_MODEL srm
  WHERE (svc.engine_id = sre.engine_id
  AND   svc.servicemodel_id = srm.servicemodel_id
  AND   svc.SERVICE_ID = ip_svcid
  );	
------------------------------------------------------------------------------------------------------------------------------------------------------------   
   
   
   TYPE sifserviceparam_rec IS RECORD (
        param_id             CTUSR.PARAMETER.PARAMETER_ID%type,
        param_name           CTUSR.PARAMETER.PARAMETER_NAME%type,
        param_type           CTUSR.PARAMETER.PARAMETER_TYPE%type,
        param_desc           CTUSR.PARAMETER.PARAMETER_DESCRIPTION%type
	);
   
   TYPE sifservice_rec IS RECORD (
        routine_id             CTUSR.SERVICE.SERVICE_ID%type,
        routine                CTUSR.SERVICE.SERVICEMODEL_ID%type,
        rouine_definition      CTUSR.SERVICE.TASK%type,
        routine_numpar         CTUSR.SERVICE.ENGINE_ID%type,
        engine                 CTUSR.SERVICE.SERVICE_NAME%type,
        schema                 CTUSR.SERVICE.SERVICE_DESCRIPTION%type,
        object_id              CTUSR.SERVICE.SERVICE_URL%type,
		object_id1              CTUSR.SERVICE.SERVICE_HOST%type,
	    sifserviceparam_list  sifserviceparam_rec
        );
        
		
   FUNCTION get_serviceID (ip_servicename IN CTUSR.SERVICE.TASK%TYPE)
      RETURN NUMBER;

   FUNCTION get_processID (ip_processname IN CTUSR.PROCESS.PROCESS_NAME%TYPE)
      RETURN NUMBER;	  
END SR_SERVICE;
--[END]


/
