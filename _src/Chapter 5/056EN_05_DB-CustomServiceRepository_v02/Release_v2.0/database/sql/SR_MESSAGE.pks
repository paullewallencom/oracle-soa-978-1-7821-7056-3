--[GLOBAL: SIF PACKAGESR_MESSAGE]
--[VERIFY: OWNER: SR TYPE: PACKAGE OBJECT:SR_MESSAGE]
create or replace PACKAGE CTUSR.SR_MESSAGE  authid current_user AS
/* ===============================================
   Package     :SR_MESSAGE
   Description : This package contains functionality for Service Inventory access.
   Filename    : $/sql/MESSAGE.pks
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
   msgsrc                   VARCHAR2 (4000 CHAR):= 'MESSAGE';
   msgjobid                 VARCHAR2 (100 CHAR) := -1;
   
   
   gv_MESSAGE_ID              CTUSR.MESSAGE.MESSAGE_ID%type;
   gv_msg_description         CTUSR.MESSAGE.MESSAGE_NAME%type;
   gv_msg_status              VARCHAR2 (100);
   gv_msg_group               VARCHAR2 (100);
   gv_msg_consolidated        VARCHAR2 (1 CHAR)   :='N';
   gv_msg_direction           VARCHAR2 (100);
   gv_msg_code                CTUSR.MESSAGE.MESSAGE_ID%type;
   gv_msg_provider            VARCHAR2 (100);
   gv_msg_receiver            VARCHAR2 (100);
   gv_msg_action              NUMBER;
   gv_msg_file                VARCHAR2 (100 CHAR);
   gv_msg_primemail           VARCHAR2 (400 CHAR);
   gv_msg_loglevel            VARCHAR2 (100 CHAR);
   gv_msg_fnamecomp           VARCHAR2 (1 CHAR);
   gv_msg_filetype            VARCHAR2 (10 CHAR);
   gv_msg_boxref              VARCHAR2 (400 CHAR);
   gv_msg_boxin               VARCHAR2 (200 CHAR);
   gv_msg_boxout              VARCHAR2 (200 CHAR);
   gv_msg_boxarchive          VARCHAR2 (200 CHAR);
   gv_msg_boxpending          VARCHAR2 (200 CHAR);
   gv_msg_urlweb              VARCHAR2 (200 CHAR);
   gv_msg_urlftp              VARCHAR2 (200 CHAR);
   gv_msg_extention           VARCHAR2 (10 CHAR);
   gv_msg_version             CTUSR.MESSAGE.VERSION%type;
   gv_msg_taskid              VARCHAR2 (200 CHAR);
   gv_msg_headerversion       CTUSR.MESSAGE.HEADER_VERSION%type := 0;
   gv_msg_saveasfile          VARCHAR2 (200 CHAR);
   gv_msg_actionparameters    NUMBER;
   gv_msg_acttaskid           NUMBER;
   gv_msg_boxid               NUMBER;
   gv_msg_trpartnerid         VARCHAR2 (200 CHAR);
   gv_msg_urlhttppost         VARCHAR2 (200 CHAR);
   gv_msg_urlhttpget          VARCHAR2 (200 CHAR);
   gv_msg_commtype            VARCHAR2 (200 CHAR);
   gv_msg_schema_loc          CTUSR.MESSAGE.XSD_URL%type;
   gv_msg_xml_root            CTUSR.MESSAGE.MESSAGE_ROOT%type;
   gv_msg_xml_footer          VARCHAR2 (100 CHAR);
   s_stru_id                  VARCHAR2 (100 CHAR);
   s_MESSAGE_ID               VARCHAR2 (100 CHAR);
   s_item_order               VARCHAR2 (100 CHAR);
   s_msg_statement            VARCHAR2 (4000 CHAR);
   s_item_name                VARCHAR2 (100 CHAR);
   s_param_req                VARCHAR2 (1 CHAR);
   s_active                   VARCHAR2 (1 CHAR);
------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                               SR_MESSAGE   
------------------------------------------------------------------------------------------------------------------------------------------------------------
--                                                CURSORS	
------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Name              msgconstrroutine_cur
-- Created           30.01.12
-- Created by        SEP
-- Purpose           getSR_MESSAGE(s) particulars by ID. 
--                   Refactoring required per process/composition role
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
	msg.MESSAGE_FILENAME,
	msg.MESSAGE_FILETYPE,
	msg.MESSAGE_DESCRIPTION,
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
 	
	
   PROCEDURE get_msgdef (ip_msgid      IN  CTUSR.MESSAGE.MESSAGE_ID%TYPE, 
                         ip_jobid      IN  VARCHAR2 DEFAULT NULL,
			             op_msgdef_rec OUT msgdef_rec
		        );	
	
END SR_MESSAGE;
/
--[END]	