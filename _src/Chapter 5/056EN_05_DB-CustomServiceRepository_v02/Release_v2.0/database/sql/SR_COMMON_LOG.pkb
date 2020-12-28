create or replace PACKAGE BODY  CTUSR.SR_COMMON_LOG  AS
/*---------------------------------------------------------------------------------------------------------------------------------
--Module      : Generic
--Type        : PL/SQL - Package
--Filename    : $sql/CTUSR.SR_COMMON_LOG.pkb
--Author      : Sergey Popov
--Version     : 0.1
--
--
-- Description: Custom logging and debugging lightweight utility package.
-- This package shall not substitute any standard eBusiness logging functionality
-- and must be used only during developing and testing stages, when generic logging
-- functionality is not available (like local testing in XE, or testing WS calls).
-- This package shall not be part of production deployment.
--
   Changehistory
   Date         Name               Description
-- *****************************************************************************
-------------------------------------------------------------------------------------------------------------------------------*/

----------------------------------------------------------------------------------------------
-- Name              write_event
-- Created           SEP
-- Created by       16.November 2012
-- Purpose
--                   Record event into DB message.s event log
-- Last changes
--
----------------------------------------------------------------------------------------------
   PROCEDURE write_event (
      msgtype    IN   VARCHAR2 DEFAULT 'INFO',
      msgtext    IN   VARCHAR2 DEFAULT NULL,
      msgcode    IN   VARCHAR2 DEFAULT NULL,
      usermsg    IN   VARCHAR2 DEFAULT NULL,
      msgsrc     IN   VARCHAR2 DEFAULT NULL,
      msgjobid   IN   VARCHAR2 DEFAULT NULL
   )
   IS
      errdesc        VARCHAR2 (100 CHAR);
      timemsg        DATE           := SYSDATE;
      v_new_msg_id   NUMBER (20)    := 0;
   BEGIN
      INSERT INTO CTUSR.SR_MESSAGE_LOG
                  (msg_code,
                   msg_text,
                   TIMESTAMP,
                   user_id,
                   msg_type,
                   msg_source,
                   job_id
                  )
           VALUES (msgcode,
		   msgtext,
		   timemsg,
		   usermsg,
		   msgtype,
                   msgsrc,
		   msgjobid
                  );
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END write_event;
----------------------------------------------------------------------------------------------
-- Name              write_event
-- Created           SEP
-- Created by       16.November 2012
-- Purpose
--                   Records event into DB message.s event log
--                   Returns event.s log ID for recorded event
-- Last changes
--
----------------------------------------------------------------------------------------------
   PROCEDURE write_event (
      msgtype         IN       VARCHAR2 DEFAULT 'INFO',
      msgtext         IN       VARCHAR2 DEFAULT NULL,
      msgcode         IN       VARCHAR2 DEFAULT NULL,
      usermsg         IN       VARCHAR2 DEFAULT NULL,
      msgsrc          IN       VARCHAR2 DEFAULT NULL,
      msgjobid        IN       VARCHAR2 DEFAULT NULL,
      op_eventid      OUT      NUMBER
   )
   IS
      errdesc        VARCHAR2 (100 CHAR);
      timemsg        DATE           := SYSDATE;
      v_new_msg_id   NUMBER (20)    := 0;
   BEGIN
 INSERT INTO CTUSR.SR_MESSAGE_LOG
                  (msg_code,
                   msg_text,
                   TIMESTAMP,
                   user_id,
                   msg_type,
                   msg_source,
                   job_id
                  )
           VALUES (msgcode,
		   msgtext,
		   timemsg,
		   usermsg,
		   msgtype,
                   msgsrc,
		   msgjobid
                  ) RETURNING  entry_id INTO op_eventid;
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END write_event;
----------------------------------------------------------------------------------------------
-- Name              write_event
-- Created           SEP
-- Created by       16.November 2012
-- Purpose
--                   Email.s recorded event. Mailer shall be defined first.
--
-- Last changes
--
----------------------------------------------------------------------------------------------
   PROCEDURE report_event (
      msgtype    IN   VARCHAR2 DEFAULT 'INFO',
      msgtext    IN   VARCHAR2 DEFAULT NULL,
      msgcode    IN   VARCHAR2 DEFAULT NULL,
      usermsg    IN   VARCHAR2 DEFAULT NULL,
      msgsrc     IN   VARCHAR2 DEFAULT NULL,
      msgjobid   IN   VARCHAR2 DEFAULT NULL
   )
   IS
      v_usermail      VARCHAR2 (100 CHAR);
      v_msgsubj       VARCHAR2 (255 CHAR);
      v_eventreport   VARCHAR2 (4000 CHAR);
      timemsg         DATE            := SYSDATE;
   BEGIN
      v_usermail := gc_def_sender;
      v_msgsubj :=  'SIF Mailer: SIF Interchange status  report generated. Status -'     || msgtype;
      v_eventreport := 'SIF Interchange status report.' || CHR (10);
      v_eventreport := v_eventreport || 'Message ID : '  || msgcode || CHR (10);
      v_eventreport := v_eventreport || 'User code :  '  || usermsg || CHR (10);
      v_eventreport := v_eventreport || 'Events type : ' || msgtype || CHR (10);
      v_eventreport := v_eventreport || 'Events timestamp  : '
         || TO_CHAR (timemsg, gc_longdatetimeformat)
         || CHR (10);
      v_eventreport := v_eventreport || 'Events Source : ' || msgsrc || CHR (10);
      v_eventreport := v_eventreport || 'Events description  : ' || msgtext || CHR (10);

   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END report_event;
/*----------------------------------------------------------------------------------------------
-- Name              msglog
-- Created           SEP
-- Created by       16.November 2012
-- Purpose
         The Main logger.
         Logging levels are:
              1.	Only critical errors
              2.	Critical errors and warnings
              3.	Critical errors, warnings and info
              4.	Same as 3 with e-mail notice
              5.	Same as 3 with Acknowledge message construction
--
-- Last changes
--
----------------------------------------------------------------------------------------------*/
   PROCEDURE msglog (
      msgtype    IN   VARCHAR2 DEFAULT 'INFO',
      msgtext    IN   VARCHAR2 DEFAULT NULL,
      msgcode    IN   VARCHAR2 DEFAULT NULL,
      usermsg    IN   VARCHAR2 DEFAULT NULL,
      msgsrc     IN   VARCHAR2 DEFAULT NULL,
      msgjobid   IN   VARCHAR2 DEFAULT NULL,
      loglvl     IN   VARCHAR2 DEFAULT NULL
   )
   IS
      errdesc        VARCHAR2 (100  CHAR);
      timemsg        DATE           := SYSDATE;
      v_new_msg_id   NUMBER   (20)    := 0;
      logginglevel   VARCHAR2 (1  CHAR);
      v_eventid      NUMBER;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
	  IF loglvl IS NULL
      THEN
         logginglevel := SR_COMMON_LOG.gc_loglevel;
      ELSE
         logginglevel := LTRIM (RTRIM (loglvl));
      END IF;
	  IF logginglevel = '1'
      THEN
         IF LTRIM (RTRIM (msgtype)) = 'ERR'
         THEN
            write_event (msgtype, msgtext, msgcode, usermsg, msgsrc,
                         msgjobid);
         END IF;
      ELSIF logginglevel = '2'
      THEN
         IF LTRIM (RTRIM (msgtype)) <> 'INFO'
         THEN
            write_event (msgtype, msgtext, msgcode, usermsg, msgsrc,
                         msgjobid);
         END IF;
      ELSIF logginglevel = '3'
      THEN
         write_event (msgtype, msgtext, msgcode, usermsg, msgsrc, msgjobid);
      ELSIF logginglevel = '4'
      THEN
         write_event (msgtype, msgtext, msgcode, usermsg, msgsrc, msgjobid);
         --report_event(msgtype, msgtext, msgcode, usermsg, msgsrc, msgjobid);
      ELSIF logginglevel = '5'
      THEN
         write_event (msgtype,
                      msgtext,
                      msgcode,
                      usermsg,
                      msgsrc,
                      msgjobid,
                      v_eventid
                     );
         --report_event(msgtype, msgtext, msgcode, usermsg, msgsrc,msgjobid);
         /*
		 msg_event (msgtype,
                    msgtext,
                    msgcode,
                    usermsg,
                    msgsrc,
                    msgjobid,
                    v_eventid
                   );
        */				   
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END msglog;
/*----------------------------------------------------------------------------------------------
-- Name              set_joblogstart
-- Created           SEP
-- Created by       16.November 2012
-- Purpose  DATE format
    Registers start point for new communication process (Job).
    Returns Job_ID as reference. Oracle sequence in use.
    Can be employed for references unification instead of BPEL  ref IDs.
    Can be splitted in unique regions  in cluster configuration.
--
-- Last changes
--
----------------------------------------------------------------------------------------------*/
   FUNCTION set_joblogstart (
                          ip_event_id         IN   number   DEFAULT 1,
                          ip_started          IN   DATE     DEFAULT NULL,
                          ip_completed        IN   DATE     DEFAULT NULL,
                          ip_status           IN   number   DEFAULT 1,
                          ip_task_id          IN   VARCHAR2 DEFAULT NULL,
                          ip_msg_id           IN   number   DEFAULT 0,
                          ip_source           IN   VARCHAR2 DEFAULT NULL,
                          ip_target_id        IN   number   DEFAULT 0,
                          ip_retry            IN   number   DEFAULT 1,
                          ip_response         IN   VARCHAR2 DEFAULT NULL,
                          ip_paramvalues      IN   VARCHAR2 DEFAULT NULL
                        )
                        RETURN NUMBER
   IS
       newjobid   number;
       v_started  DATE;
       v_completed  DATE;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
	       INSERT INTO CTUSR.SR_EVENTPROC_LOG
		                       (event_id,
					started,
					completed,
					status,
					task_id,
					msg_id,
					source,
					target_id,
					retry,
					response)
                          VALUES
                               (ip_event_id,
				ip_started,
				ip_completed,
				ip_status,
				ip_task_id,
				ip_msg_id,
				ip_source,
				ip_target_id,
				ip_retry,
				ip_response)
             RETURNING
                   job_id INTO newjobid;
      COMMIT;
      -- proceed with parameter string if parameter string is not NULL
      /*
      IF ip_paramvalues IS NOT NULL
      THEN
         Eventhandler.get_jobparameterlist (ip_msgid          => msgcode,
                                            ip_jobid          => newjobid,
                                            ip_valuelist      => ip_paramvalues
                                            );
      END IF;
      */
      RETURN newjobid;
   EXCEPTION
      WHEN OTHERS
      THEN
         msgtype := 'ERR';
         msgid := SQLCODE;
         msgtext := SQLERRM (msgid);
         msgsrc :=
               'CTUSR.SR_COMMON_LOG.set_joblogstart - Unable to register msg Job Start. Current Job ID is '
            || newjobid;
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                                    msgtext,
                                    msgid,
                                    usermsg,
                                    msgsrc,
                                    newjobid);
   END set_joblogstart;
/*----------------------------------------------------------------------------------------------
-- Name              set_eventjoblogstart
-- Created           SEP
-- Created by       16.November 2012
-- Purpose
    Registers start point for new communication process (Job).
    Returns Job_ID as reference. Oracle sequence in use.
    Can be employed for references unification instead of BPEL  ref IDs.
    Can be splitted in unique regions  in cluster configuration.
--
-- Last changes
--
----------------------------------------------------------------------------------------------*/
   FUNCTION set_eventjoblogstart (
                          ip_event_id         IN   number   DEFAULT 1,
						  ip_PARENTJOB_ID     IN   number   DEFAULT -1,
                          ip_started          IN   VARCHAR2 DEFAULT NULL,
                          ip_completed        IN   VARCHAR2 DEFAULT NULL,
                          ip_status           IN   number   DEFAULT 1,
                          ip_task_id          IN   VARCHAR2 DEFAULT NULL,
                          ip_msg_id           IN   number   DEFAULT 0,
						  ip_correlation_id   IN   VARCHAR2 DEFAULT NULL,
						  ip_gu_id            IN   number   DEFAULT 1,
                          ip_source           IN   VARCHAR2 DEFAULT NULL,
						  ip_target_id        IN   number   DEFAULT 0,
                          ip_retry            IN   number   DEFAULT 1,
                          ip_response         IN   VARCHAR2 DEFAULT NULL,
                          ip_paramvalues      IN   VARCHAR2 DEFAULT NULL
                        )
                        RETURN NUMBER
   IS
       newjobid   number;
       v_started  DATE;
       v_completed  DATE;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
    v_started   := NVL(to_date(ip_started, gc_longdatetimeformat), sysdate);
    v_completed := NVL(to_date(ip_completed, gc_longdatetimeformat), sysdate);
	       INSERT INTO CTUSR.SR_EVENTPROC_LOG
		          (event_id,
					PARENT_JOB_ID,
					started,
					completed,
					status,
					task_id,
					msg_id,
					correlation_id,
					gu_id,
					source,
					target_id,
					retry,
					response)
            VALUES
               (ip_event_id,
			    ip_PARENTJOB_ID,
				v_started,
				v_completed,
				ip_status,
				ip_task_id,
				ip_msg_id,
				ip_correlation_id,
				ip_gu_id,
				ip_source,
				ip_target_id,
				ip_retry,
				ip_response)
            RETURNING job_id INTO newjobid;
      COMMIT;
      -- proceed with parameter string if parameter string is not NULL
      /*
      IF ip_paramvalues IS NOT NULL
      THEN
         Eventhandler.get_jobparameterlist (ip_msgid          => msgcode,
                                            ip_jobid          => newjobid,
                                            ip_valuelist      => ip_paramvalues
                                            );
      END IF;
      */
      RETURN newjobid;
   EXCEPTION
      WHEN OTHERS
      THEN
         msgtype := 'ERR';
         msgid := SQLCODE;
         msgtext := SQLERRM (msgid);
         msgsrc :=
               'CTUSR.SR_COMMON_LOG.JobLogStart - Unable to register msg Job Start. Current Job ID is '
            || newjobid;
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                                    msgtext,
                                    msgid,
                                    usermsg,
                                    msgsrc,
                                    newjobid);
   END set_eventjoblogstart;
/*----------------------------------------------------------------------------------------------
-- Name              set_eventjoblogstop
-- Created           SEP
-- Created by       16.November 2012
-- Purpose
    Registers stop point for new communication process (Job).
--
-- Last changes
--
----------------------------------------------------------------------------------------------*/
   PROCEDURE set_eventjoblogstop (
      ip_status    IN   NUMBER DEFAULT 3,
      ip_job_id    IN   NUMBER
   )
   IS
      v_timestamp       DATE           := SYSDATE;
      lineno        VARCHAR2 (20 CHAR);
      object_name   VARCHAR2 (200 CHAR);
   PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      UPDATE CTUSR.SR_EVENTPROC_LOG
         SET SR_EVENTPROC_LOG.status = ip_status,
             CTUSR.SR_EVENTPROC_LOG.completed = v_timestamp
       WHERE CTUSR.SR_EVENTPROC_LOG.job_id = ip_job_id;
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         msgtype := 'ERR';
         msgid := SQLCODE;
         msgtext := SQLERRM (msgid);
 --        callerstackbuffer (lineno, object_name);
         msgsrc := 'CTUSR.SR_MESSAGE_LOG.set_eventjoblogstop - Unable to register msg Job Stop (Status: '||
			   ip_status||' for job_id: '||ip_job_id;
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
									                            msgtext,
									msgid,
									usermsg,
									msgsrc,
                                    ip_job_id
                                    );
   END set_eventjoblogstop;
/*----------------------------------------------------------------------------------------------
-- Name              callerstackbuffer
-- Created           SEP
-- Created by       16.November 2012
-- Purpose
    Stack tracer. For callers history logging.
--
-- Last changes
--
----------------------------------------------------------------------------------------------*/
   PROCEDURE callerstackbuffer (lineno OUT INTEGER, object_name OUT VARCHAR2)
   AS
      buffer   VARCHAR2 (4000  CHAR);
   BEGIN
      buffer := DBMS_UTILITY.format_call_stack;
      -- skip down to caller's caller line
      FOR i IN 1 .. 6
      LOOP
         buffer := SUBSTR (buffer, INSTR (buffer, CHR (10)) + 1);
      END LOOP;
      -- remove any subsequent lines
      buffer := TRIM (SUBSTR (buffer, 1, INSTR (buffer, CHR (10)) - 1));
      -- remove "object handle"
      buffer := TRIM (SUBSTR (buffer, INSTR (buffer, ' ') + 1));
      -- get the "line number"
      lineno := SUBSTR (buffer, 1, INSTR (buffer, ' ') - 1);
      -- get the "object name"
      object_name := TRIM (SUBSTR (buffer, INSTR (buffer, ' ') + 1));
   END callerstackbuffer;
-------------------------------------------------------------------------------------------
-- Name              cleareventlog
-- Created           SEP
-- Created by       16.November 2012
-- Purpose
--
-- Last changes
--
-------------------------------------------------------------------------------------------
   PROCEDURE cleareventlog(ip_doffset IN INTEGER)
   IS
    v_doffset INTEGER :=0;
   BEGIN
      IF  ip_doffset is null THEN
		v_doffset := 0;
	  ELSE
		v_doffset := ip_doffset;
	  END IF;
      DELETE CTUSR.SR_MESSAGE_LOG
      WHERE CTUSR.SR_MESSAGE_LOG.TIMESTAMP < SYSDATE - ip_doffset;
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END cleareventlog;
-------------------------------------------------------------------------------------------
-- Name              clearjoblog
-- Created           SEP
-- Created by       16.November 2012
-- Purpose
--
-- Last changes
--
-------------------------------------------------------------------------------------------
   PROCEDURE clearjoblog(ip_doffset IN INTEGER)
   IS
    v_doffset INTEGER :=0;
   BEGIN
      IF  ip_doffset is null THEN
		v_doffset := 0;
	  ELSE
		v_doffset := ip_doffset;
	  END IF;
	  
	  DELETE CTUSR.SR_EVENTPROC_LOG
      WHERE CTUSR.SR_EVENTPROC_LOG.started < SYSDATE - v_doffset;
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         NULL;
   END clearjoblog;
   
--******************************************************************************
--                               END OF PACKAGE
--******************************************************************************
END SR_COMMON_LOG;
--[END]

/