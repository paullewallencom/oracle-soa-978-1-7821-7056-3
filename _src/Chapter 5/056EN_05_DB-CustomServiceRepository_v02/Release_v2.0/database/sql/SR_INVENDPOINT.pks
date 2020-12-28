--[GLOBAL: INTF PACKAGE SR_INVENDPOINT]
--[VERIFY: OWNER: APPS TYPE: PACKAGE OBJECT: SR_INVENDPOINT]
create or replace PACKAGE  CTUSR.SR_INVENDPOINT  authid current_user AS
/* ===============================================
   Package     : SR_INVENDPOINT
   Description : This package contains functionality for Service Inventory access.
   Filename    : $/sql/SR_INVENDPOINT.pks
   Created date: 24. January 2012
   Author      : Sergey Popov
   Version     : 0.1
   Changehistory
   Date         Name               Description
================================================== */

/* Declare externally visible types, cursor, exception. */
   msgtype                  VARCHAR2 (20 CHAR)  := 'INFO';
   msgtext                  VARCHAR2 (4000 CHAR):= 'Text';
   msgid                    VARCHAR2 (20 CHAR)  := '1';
   usermsg                  VARCHAR2 (20 CHAR)  := '1';
   msgsrc                   VARCHAR2 (4000 CHAR):= 'SR_INVENDPOINT';
   msgjobid                 VARCHAR2 (100 CHAR) := -1;
------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                RULESET   
------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Name              objectrefparser_cur
-- Created           30.01.12
-- Created by        SEP
-- Purpose   get Ruleset for certain Process / Composition
--
-- Last changes
     -- ip_objectkey_name   sif_audit_objectref.objectkey_name%TYPE,  -- like 'PROCESS_ID'  i.e par.PARAMETER_NAME     = 'PROCESS_ID'
     -- ip_object_name      sif_audit_objectref.OBJECT_NAME%TYPE,     
     -- ip_operation        sif_audit_objoperation.OBJREF_ACTION%TYPE -- INSERT, or business operation 
------------------------------------------------------------------------------------------------------------------------------------------------------------
  CURSOR objectrefparser_cur (
      ip_objectkey_name   sifaudit.SIF_EVENT_LOG.OBJECTKEY_NAME%TYPE,
      ip_object_name      sifaudit.SIF_EVENT_LOG.OBJECT_NAME%TYPE,
      ip_operation        sifaudit.SIF_EVENT_LOG.OBJREF_ACTION%TYPE
     ) IS
  SELECT 
    prc.PROCESS_NAME               PROCESS_NAME,
    prc.PROCESS_ID                 PROCESS_ID,
    rst.RULESET_ID                 RULESET_ID,
    rst.RULESET_NAME               RULESET_NAME,
    com.TASK_ORDER                 TASK_ORDER,
    com.OPERATIONTYPE_ID           OPERATIONTYPE_ID,
	msg.MESSAGE_NAME               MESSAGE_NAME,
    com.ROLE_ID                    ROLE_ID,
	opt.OPERATION                  OPERATION,
	cms.MESSAGE_ID                 MESSAGE_ID, 
  	obj.OBJECT_NAME                OBJECT_NAME
  FROM CTUSR.SERVICE svc,
       CTUSR.PROCESS prc,
       CTUSR.RULESET rst,
       CTUSR.COMPOSITION com,
	   CTUSR.OBJECT obj,
	   CTUSR.PARAMETER par,
	   CTUSR.MESSAGE msg,
 	   CTUSR.COMPOSITIONTASK_RULES cor,
	   CTUSR.OPERATION_TYPE opt,
	   CTUSR.COMPOSITIONTASK_MESSAGE cms,
	   CTUSR.OBJECT_PARAMETER opr
  WHERE ( prc.PROCESS_ID       = com.PROCESS_ID
	AND cor.COMPOSITIONLIST_ID = com.COMPOSITIONLIST_ID
	AND cor.RULESET_ID         = rst.RULESET_ID
	AND opt.OPERATIONTYPE_ID   = com.OPERATIONTYPE_ID
	AND svc.SERVICE_ID         = com.SERVICE_ID
	AND msg.OBJECT_ID          = obj.OBJECT_ID
	AND opr.OBJECT_ID          = obj.OBJECT_ID
	AND par.PARAMETER_ID       = opr.PARAMETER_ID
	AND cms.MESSAGE_ID         = msg.MESSAGE_ID
	AND com.TASK_ORDER         = 1
	AND opr.OBJPRIMARY_KEY     ='Y'             
	AND prc.PROCESS_NAME       = ip_object_name
	AND par.PARAMETER_NAME     = ip_objectkey_name
    --AND opt.OPERATION          = ip_operation
	);
	
	
  -----------------------------------------------------------------------------
  -- get Ruleset for  Process / Service
  -----------------------------------------------------------------------------
 
  ------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Name              objectrefruleparser_cur
-- Created           30.01.12
-- Created by        SEP
-- Purpose   get Ruleset for  Process / Service
--
-- Last changes
     -- ip_objectkey_name   sif_audit_objectref.objectkey_name%TYPE,
     -- ip_object_name      sif_audit_objectref.object_name%TYPE,
     -- ip_operation_id     sif_audit_objoperation.operation_id%TYPE
------------------------------------------------------------------------------------------------------------------------------------------------------------
  CURSOR objectrefruleparser_cur (
      ip_objectkey_name   sifaudit.SIF_EVENT_LOG.OBJECTKEY_NAME%TYPE,
      ip_object_name      sifaudit.SIF_EVENT_LOG.OBJECT_NAME%TYPE,
      ip_operation_id     sifaudit.SIF_EVENT_LOG.OBJREF_ACTION%TYPE
     ) IS
 SELECT 
    svc.SERVICE_NAME SERVICE_NAME,
    svc.SERVICE_ID SERVICE_ID,
    prc.PROCESS_NAME PROCESS_NAME,
    prc.PROCESS_ID PROCESS_ID,
    rst.RULESET_ID RULESET_ID,
    rst.RULESET_NAME RULESET_NAME,
    com.TASK_ORDER TASK_ORDER,
    com.OPERATIONTYPE_ID OPERATIONTYPE_ID,
    com.ROLE_ID ROLE_ID,
	opt.OPERATION OPERATION
  FROM CTUSR.SERVICE svc,
       CTUSR.PROCESS prc,
       CTUSR.RULESET rst,
       CTUSR.COMPOSITION com,
 	   CTUSR.COMPOSITIONTASK_RULES cor,
	   CTUSR.OPERATION_TYPE opt
  WHERE (svc.SERVICE_ID = com.SERVICE_ID
	AND prc.PROCESS_ID = com.PROCESS_ID
	AND cor.COMPOSITIONLIST_ID = com.COMPOSITIONLIST_ID
	AND cor.RULESET_ID = rst.RULESET_ID
	AND opt.OPERATIONTYPE_ID  = com.OPERATIONTYPE_ID
	AND com.TASK_ORDER         = 1
	AND prc.PROCESS_NAME       = ip_object_name
	);	
------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                MESSAGE   
------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                CURSORS	
------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Name              msgconstrroutine_cur
-- Created           30.01.12
-- Created by        SEP
-- Purpose           get Message(s) particulars by ID. 
--                   
--
-- Last changes
------------------------------------------------------------------------------------------------------------------------------------------------------------
  CURSOR msgconstrroutine_cur (
           ip_msgid   CTUSR.MESSAGE.MESSAGE_ID%TYPE
     ) IS  
  SELECT 
	msg.MESSAGE_ID,
	msg.OBJECT_ID,
	msg.MESSAGE_NAME,
	msg.MESSAGE_ROOT,
	msg.VERSION,
	msg.XSD_URL,
	msg.MESSAGE_NAMESPACE,
	msg.IMPLEMENTATION,
	msg.HEADER_VERSION,
	obj.OBJECT_NAME,
	ctm.TASKMSG_ID,
	ctm.COMPOSITIONLIST_ID,
	ctm.TRANSFORMATION_TASK,
	ctm.VALIDATION_TASK,
	ctm.SOURCE,
	ctm.TARGET,
	ctm.XSLT_URL,
	com.TASK_ORDER,
	srv.TASK,
	srv.SERVICE_NAME,
	srv.SERVICE_URL,
	srv.SERVICE_HOST,
	prc.PROCESS_NAME,
	sve.ENGINE_TYPE,
	sve.ENGINE_NAME,
	sve.ENGINE_URL,
	svm.SERVICE_MODEL,
	cor.COMPOSITION_ROLE
FROM CTUSR.MESSAGE msg,
     CTUSR.OBJECT obj,
     CTUSR.COMPOSITIONTASK_MESSAGE ctm,
     CTUSR.COMPOSITION com,
     CTUSR.SERVICE srv,
     CTUSR.PROCESS prc,
     CTUSR.SERVICE_ENGINE sve,
     CTUSR.SERVICE_MODEL svm,
     CTUSR.COMPOSITION_ROLE cor
WHERE ( msg.OBJECT_ID  = obj.OBJECT_ID     
  AND   msg.MESSAGE_ID = ctm.MESSAGE_ID
  AND   ctm.COMPOSITIONLIST_ID = com.COMPOSITIONLIST_ID
  AND   com.PROCESS_ID = prc.PROCESS_ID
  AND   com.SERVICE_ID = srv.SERVICE_ID
  AND   srv.ENGINE_ID  = sve.ENGINE_ID
  AND   com.ROLE_ID    = cor.ROLE_ID
  AND   msg.MESSAGE_ID = ip_msgid
  );	
------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                TYPES	
------------------------------------------------------------------------------------------------------------------------------------------------------------
  TYPE msgdef_rec IS RECORD (
   gv_msg_id                  CTUSR.MESSAGE.MESSAGE_ID%type,
   gv_msg_description         CTUSR.MESSAGE.MESSAGE_NAME%type,
   gv_msg_object              VARCHAR2 (100 CHAR),
   gv_msg_name                VARCHAR2 (100 CHAR),
   gv_msg_xsdurl              CTUSR.MESSAGE.MESSAGE_ID%type,
   gv_msg_version             CTUSR.MESSAGE.VERSION%type,
   gv_msg_provider            VARCHAR2 (100 CHAR),
   gv_msg_receiver            VARCHAR2 (100 CHAR),
   gv_msg_file                VARCHAR2 (400 CHAR),
   gv_msg_filetype            VARCHAR2 (100 CHAR),
   gv_msg_boxref              VARCHAR2 (400 CHAR),
   gv_msg_boxin               VARCHAR2 (200 CHAR),
   gv_msg_boxout              VARCHAR2 (200 CHAR),
   gv_msg_taskid              VARCHAR2 (200 CHAR),
   gv_msg_headerversion       CTUSR.MESSAGE.HEADER_VERSION%type ,
   gv_msg_actionparameters    NUMBER,
   gv_msg_boxid               VARCHAR2 (200 CHAR)
   );
 	
	
END SR_INVENDPOINT;
/
--[END]	