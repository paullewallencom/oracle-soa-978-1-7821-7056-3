--[GLOBAL: SIF PACKAGE BODY SR_MESSAGE]
--[VERIFY: OWNER: SR TYPE: PACKAGE BODY OBJECT: SR_MESSAGE]
CREATE OR REPLACE PACKAGE BODY CTUSR.SR_MESSAGE AS
--*****************************************************************************
--Module      : Generic
--Type        : PL/SQL - Package
--Filename    : $sql/SR_MESSAGE.pkb
--Author      : Sergey Popov
--Version     : 0.1
--                     
--
-- Description: Generic object Message for all interchange modules
--              
-- log procedures
-- *****************************************************************************
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Name              get_msgfilename
-- Created           Sergey Popov
-- Created by        24. January 2012
-- Purpose
--
-- Last changes
--
-------------------------------------------------------------------------------------------
   FUNCTION get_msgfilename (ip_msgid IN CTUSR.MESSAGE.MESSAGE_ID%TYPE)
      RETURN VARCHAR2
   IS
      CURSOR msgfilename_cur (msgid CTUSR.MESSAGE.MESSAGE_ID%TYPE) IS
         SELECT CTUSR.MESSAGE.MESSAGE_FILENAME,
                CTUSR.MESSAGE.MESSAGE_FILETYPE
           FROM CTUSR.MESSAGE
           WHERE (RTRIM(LTRIM (CTUSR.MESSAGE.MESSAGE_ID)) = RTRIM (LTRIM (msgid)));
      msgfilename_rec   msgfilename_cur%ROWTYPE;
      msgfilename       VARCHAR2 (4000 CHAR)         := 'NA';
   BEGIN
      OPEN msgfilename_cur (ip_msgid);
      FETCH msgfilename_cur
       INTO msgfilename_rec;
      IF msgfilename_cur%FOUND
      THEN
         IF msgfilename_rec.MESSAGE_FILENAME IS NULL
         THEN
            msgfilename := 'NA';
         ELSE
            msgfilename := msgfilename_rec.MESSAGE_FILENAME||'.'||msgfilename_rec.MESSAGE_FILETYPE;
         END IF;
      END IF;
      CLOSE msgfilename_cur;
      RETURN msgfilename;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        CLOSE msgfilename_cur;
         msgfilename := 'NA';
         RETURN msgfilename;
      WHEN OTHERS
      THEN
        CLOSE msgfilename_cur;
         msgtype := 'ERR';
         msgid := SQLCODE;
         msgtext := SQLERRM (msgid);
         msgsrc := 'SR_MESSAGE.get_msgfilename';
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgid,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
   END get_msgfilename;
   
/*   -------------------------------------------------------------------------------------------
-- Name              get_msgparser
-- Created           Sergey Popov
-- Created by        24. January 2012
-- Purpose
--
-- Last changes
--SELECT CTUSR.MESSAGE.msg_task_parse, xxcu_intf_routine.routine
  FROM CTUSR.MESSAGE, xxcu_intf_routine
 WHERE ((xxcu_intf_routine.routine_id = CTUSR.MESSAGE.msg_task_parse))
-------------------------------------------------------------------------------------------*/
FUNCTION get_msgparser (ip_msgid IN CTUSR.MESSAGE.MESSAGE_ID%TYPE)
      RETURN VARCHAR2
   IS
      CURSOR msgparser_cur (msg_id CTUSR.MESSAGE.MESSAGE_ID%TYPE)
      IS
		SELECT svc.service_id, 
			   svc.service_name,
               svc.service_url,
               svc.service_host
		FROM 
			CTUSR.SERVICE svc,
			CTUSR.SERVICE_MODEL svm,
			CTUSR.COMPOSITION com,
			CTUSR.OPERATION_TYPE cot,
			CTUSR.COMPOSITION_ROLE cor,
			CTUSR.COMPOSITIONTASK_MESSAGE ctm,
			CTUSR.MESSAGE msg
		WHERE ((svc.servicemodel_id = svm.servicemodel_id)
		AND (com.service_id         = svc.service_id)
		AND (com.role_id            = cor.role_id)
		AND (com.operationtype_id   = cot.operationtype_id)
		AND (com.compositionlist_id = ctm.compositionlist_id)
		AND (ctm.message_id         = msg.message_id)
        AND (msg.MESSAGE_ID         = ip_msgid));
     
 	 msgparser_rec   msgparser_cur%ROWTYPE;
     v_msgparser     VARCHAR2 (400 CHAR) := NULL;
 
   BEGIN
      OPEN msgparser_cur (ip_msgid);
      FETCH msgparser_cur
       INTO msgparser_rec;
      IF msgparser_cur%FOUND
      THEN
         IF msgparser_rec.service_url IS NULL
         THEN
            v_msgparser := NULL;
         ELSE
            v_msgparser := msgparser_rec.service_url;
         END IF;
      END IF;
      CLOSE msgparser_cur;
      RETURN v_msgparser;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         v_msgparser := NULL;
         RETURN v_msgparser;
      WHEN OTHERS
      THEN
         msgtype := 'ERR';
         msgid := SQLCODE;
         msgtext := SQLERRM (msgid);
         msgsrc := 'SR_MESSAGE.get_msgparser';
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgid,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
   END get_msgparser;
-------------------------------------------------------------------------------------------
-- Name              get_msgidbyfilename
-- Created           Sergey Popov
-- Created by        24. January 2012
-- Purpose
--
-- Last changes
--
-------------------------------------------------------------------------------------------
FUNCTION get_msgidbyfilename(ip_msgfile IN CTUSR.MESSAGE.MESSAGE_FILENAME%TYPE)
      RETURN VARCHAR2
   IS
      CURSOR msgidbyfilename_cur (ip_msgfile CTUSR.MESSAGE.MESSAGE_FILENAME%TYPE)
      IS
         SELECT CTUSR.MESSAGE.MESSAGE_ID
           FROM CTUSR.MESSAGE
          WHERE ((CTUSR.MESSAGE.MESSAGE_FILENAME = ip_msgfile));
      msgidbyfilename_rec   msgidbyfilename_cur%ROWTYPE;
      v_msgid               CTUSR.MESSAGE.MESSAGE_ID%TYPE;
   BEGIN
      OPEN msgidbyfilename_cur (ip_msgfile);
      FETCH msgidbyfilename_cur
       INTO msgidbyfilename_rec;
      IF msgidbyfilename_cur%FOUND
      THEN
         IF msgidbyfilename_rec.MESSAGE_ID IS NULL
         THEN
            v_msgid := NULL;
         ELSE
            v_msgid := msgidbyfilename_rec.MESSAGE_ID;
         END IF;
      END IF;
      CLOSE msgidbyfilename_cur;
      RETURN v_msgid;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        CLOSE msgidbyfilename_cur;
         v_msgid := NULL;
         RETURN v_msgid;
      WHEN OTHERS
      THEN
        CLOSE msgidbyfilename_cur;
         msgtype := 'ERR';
         msgid := SQLCODE;
         msgtext := SQLERRM (msgid);
         msgsrc := 'SR_MESSAGE.get_msgidbyfilename';
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgid,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
   END get_msgidbyfilename; 
   
-------------------------------------------------------------------------------------------
-- Name              get_msgidbyroot
-- Created           Sergey Popov
-- Created by        24. January 2012
-- Purpose
--
-- Last changes
--
-------------------------------------------------------------------------------------------
FUNCTION get_msgidbyroot(ip_msgroot IN CTUSR.MESSAGE.MESSAGE_ROOT%TYPE)
      RETURN VARCHAR2
   IS
      CURSOR msgidbyroot_cur (ip_msgroot CTUSR.MESSAGE.MESSAGE_ROOT%TYPE)
      IS
         SELECT CTUSR.MESSAGE.MESSAGE_ID
           FROM CTUSR.MESSAGE
          WHERE ((CTUSR.MESSAGE.MESSAGE_ROOT = ip_msgroot));
      msgidbyroot_rec       msgidbyroot_cur%ROWTYPE;
      v_msgid               CTUSR.MESSAGE.MESSAGE_ID%TYPE;
   BEGIN
      OPEN msgidbyroot_cur (ip_msgroot);
      FETCH msgidbyroot_cur
       INTO msgidbyroot_rec;
      IF msgidbyroot_cur%FOUND
      THEN
         IF msgidbyroot_rec.MESSAGE_ID IS NULL
         THEN
            v_msgid := NULL;
         ELSE
            v_msgid := msgidbyroot_rec.MESSAGE_ID;
         END IF;
      END IF;
      CLOSE msgidbyroot_cur;
      RETURN v_msgid;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        CLOSE msgidbyroot_cur;
         v_msgid := NULL;
         RETURN v_msgid;
      WHEN OTHERS
      THEN
        CLOSE msgidbyroot_cur;
         msgtype := 'ERR';
         msgid := SQLCODE;
         msgtext := SQLERRM (msgid);
         msgsrc := 'SR_MESSAGE.get_msgidbyroot';
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgid,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
   END get_msgidbyroot; 
-------------------------------------------------------------------------------------------
-- Name              get_msgheader
-- Created           Sergey Popov
-- Created by        24. January 2012
-- Purpose
--
-- Last changes
--
-------------------------------------------------------------------------------------------
FUNCTION get_msgheader (ip_msgid IN CTUSR.MESSAGE.MESSAGE_ID%TYPE)
      RETURN VARCHAR2
   IS
      CURSOR msgheader_cur (msgid CTUSR.MESSAGE.MESSAGE_ID%TYPE) IS
         SELECT CTUSR.MESSAGE.MESSAGE_ROOT
           FROM CTUSR.MESSAGE
          WHERE ((RTRIM (LTRIM (CTUSR.MESSAGE.MESSAGE_ID)) = RTRIM (LTRIM (ip_msgid))));
      msgheader_rec   msgheader_cur%ROWTYPE;
      msgheader       VARCHAR2 (4000 CHAR) := 'ROWSET';
   BEGIN
      OPEN msgheader_cur (ip_msgid);
      FETCH msgheader_cur
       INTO msgheader_rec;
      IF msgheader_cur%FOUND
      THEN
         IF msgheader_rec.MESSAGE_ROOT IS NULL
         THEN
            msgheader := 'ROWSET';
         ELSE
            msgheader := msgheader_rec.MESSAGE_ROOT;
         END IF;
      END IF;
      CLOSE msgheader_cur;
      RETURN msgheader;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         msgheader := 'ROWSET';
         RETURN msgheader;
      WHEN OTHERS
      THEN
         msgtype := 'ERR';
         msgid := SQLCODE;
         msgtext := SQLERRM (msgid);
         msgsrc := 'SR_MESSAGE.get_MsgHeader';
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgid,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
   END get_msgheader;
   
-------------------------------------------------------------------------------------------
-- Name              get_msgfooter
-- Created           Sergey Popov
-- Created by        24. January 2012
-- Purpose
--
-- Last changes
--
-------------------------------------------------------------------------------------------
   FUNCTION get_msgfooter (ip_msgid IN CTUSR.MESSAGE.MESSAGE_ID%TYPE)
      RETURN VARCHAR2
   IS
      CURSOR msgfooter_cur (ip_msgid CTUSR.MESSAGE.MESSAGE_ID%TYPE)
      IS
         SELECT CTUSR.MESSAGE.MESSAGE_ROOT
           FROM CTUSR.MESSAGE
          WHERE ((CTUSR.MESSAGE.MESSAGE_ID = ip_msgid));
      msgfooter_rec   msgfooter_cur%ROWTYPE;
      msgfooter       VARCHAR2 (4000 CHAR)         := 'ROWSET';
   BEGIN
      OPEN msgfooter_cur (ip_msgid);
      FETCH msgfooter_cur
       INTO msgfooter_rec;
      IF msgfooter_cur%FOUND
      THEN
         IF msgfooter_rec.MESSAGE_ROOT IS NULL
         THEN
            msgfooter := 'ROWSET';
    	    msgtext := 'Message Root/Footer not found for message ID:'|| ip_msgid;
            CTUSR.SR_COMMON_LOG.msglog ('WARN',
   	                               msgtext,
   				       ip_msgid, 
   				       usermsg,
   				       msgsrc,
   				       msgjobid);
         ELSE
            msgfooter := msgfooter_rec.MESSAGE_ROOT;
         END IF;
      END IF;
      CLOSE msgfooter_cur;
      RETURN msgfooter;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         msgfooter := 'ROWSET';
         RETURN msgfooter;
      WHEN OTHERS
      THEN
         msgtype := 'ERR';
         msgid := SQLCODE;
         msgtext := SQLERRM (msgid);
         msgsrc := 'SR_MESSAGE.get_MsgFooter';
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgid,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
   END get_msgfooter;
   
-------------------------------------------------------------------------------------------
-- Name              get_msgdef
-- Created           Sergey Popov
-- Created by        24. January 2012
-- Purpose
--
-- Last changes
--
-------------------------------------------------------------------------------------------
   PROCEDURE get_msgdef (ip_msgid      IN  CTUSR.MESSAGE.MESSAGE_ID%TYPE, 
                         ip_jobid      IN  VARCHAR2 DEFAULT NULL,
			             op_msgdef_rec OUT msgdef_rec
		        )
   IS
      v_trpartnerid        VARCHAR2 (20 CHAR);
      v_trpartnercode      VARCHAR2 (20 CHAR);
      v_compoundfilename   VARCHAR2(200 CHAR);
	  msginfo_rec          msgconstrroutine_cur%ROWTYPE;
   BEGIN
   
   
    OPEN msgconstrroutine_cur (ip_msgid);
      FETCH msgconstrroutine_cur        INTO msginfo_rec;
      IF msgconstrroutine_cur%FOUND   THEN
	  
	   msgsrc := 'SR_MESSAGE.get_msgdef';
       msgtext := 'Assigning obtained message particulars for Msg ID=:'||ip_msgid;
       CTUSR.SR_COMMON_LOG.msglog ('INFO',
                               msgtext,
                               ip_msgid,
                               usermsg,
                               msgsrc,
                               msgjobid
                              );	
	  
		op_msgdef_rec.gv_msg_id             :=   msginfo_rec.MESSAGE_ID;
		op_msgdef_rec.gv_msg_description    :=   msginfo_rec.MESSAGE_DESCRIPTION;
		op_msgdef_rec.gv_msg_object         :=   msginfo_rec.OBJECT_ID;
		op_msgdef_rec.gv_msg_name           :=   msginfo_rec.MESSAGE_NAME;
		op_msgdef_rec.gv_msg_xsdurl         :=   msginfo_rec.XSD_URL;
		op_msgdef_rec.gv_msg_version        :=   msginfo_rec.VERSION;
		op_msgdef_rec.gv_msg_provider       :=   null;
		op_msgdef_rec.gv_msg_receiver       :=   null;
		op_msgdef_rec.gv_msg_file           :=   msginfo_rec.MESSAGE_FILENAME;
		op_msgdef_rec.gv_msg_filetype       :=   msginfo_rec.MESSAGE_FILETYPE;
		op_msgdef_rec.gv_msg_boxref         :=   null;
		op_msgdef_rec.gv_msg_boxin          :=   null;
		op_msgdef_rec.gv_msg_boxout         :=   null;
		op_msgdef_rec.gv_msg_taskid         :=   msginfo_rec.TASK;
		op_msgdef_rec.gv_msg_headerversion  :=   msginfo_rec.HEADER_VERSION;
	
      END IF;
      CLOSE msgconstrroutine_cur;
 

 
   EXCEPTION
      WHEN OTHERS
      THEN
         msgtype := 'ERR';
         msgid := SQLCODE;
         msgtext := SQLERRM (msgid);
         msgsrc := 'SR_MESSAGE.get_msgdef. Error during obtaining message particulars for msg_id='|| ip_msgid;
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgid,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
   END get_msgdef;
      

-------------------------------------------------------------------------------------------
-- Name              get_message
-- Created           Sergey Popov
-- Created by        24. January 2012
-- Purpose
--
-- Last changes
--
-------------------------------------------------------------------------------------------
   FUNCTION get_msgxmlfilename (ip_msgid  IN CTUSR.MESSAGE.MESSAGE_ID%TYPE, 
                                jobid     IN VARCHAR2)
      RETURN VARCHAR2
   IS
      xmloutfilename   VARCHAR2 (400 CHAR) := 'NewFile.xml';
	  v_msgdef_rec     SR_MESSAGE.msgdef_rec;
   BEGIN
         get_msgdef(ip_msgid      => ip_msgid,
		            ip_jobid      => jobid,
		            op_msgdef_rec => v_msgdef_rec
		           );
         xmloutfilename :=
               v_msgdef_rec.gv_msg_file || '-' || jobid || '.'
               || v_msgdef_rec.gv_msg_filetype;
      RETURN xmloutfilename;
   EXCEPTION
      WHEN OTHERS
      THEN
         msgtype := 'ERR';
         msgid := SQLCODE;
         msgtext := SQLERRM (msgid);
         msgsrc := 'SR_MESSAGE.get_msgxmlfilename';
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgid,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
   END get_msgxmlfilename;


/*****************************************************************************
                               END OF PACKAGE
******************************************************************************/
END SR_MESSAGE;
--[END]
/

