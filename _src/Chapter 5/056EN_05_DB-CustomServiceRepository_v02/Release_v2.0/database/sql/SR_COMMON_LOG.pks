create or replace PACKAGE  CTUSR.SR_COMMON_LOG authid current_user  AS
/*---------------------------------------------------------------------------------------------------------------------------------
--Module      : Generic
--Type        : PL/SQL - Package
--Filename    : $ sql/SR_COMMON_LOG.pks
--Author      : Sergey Popov
--Version     : 0.1
--                     
--
-- Description: Custom logging and debugging lightweight utility package.
-- This package shall not substitute any standard OFM/CTUSR logging functionality
-- and must be used only during developing and testing stages, when generic logging
-- functionality is not available (like local testing in XE, or testing WS calls).
-- This package shall not be part of production deployment.
--  Use SR_COMMON_LOG in unit test instead
--              
   Changehistory
   Date         Name               Description
-- *****************************************************************************
-------------------------------------------------------------------------------------------------------------------------------*/
--------------------------------------------------------------------
--------------------------------------------------------------------
/* Declare externally visible types, cursor, exception. */
   msgtype   VARCHAR2 (20 CHAR)   := 'ERR';
   msgtext   VARCHAR2 (4000)      := 'Text';
   msgid     VARCHAR2 (20 CHAR)   := '1';
   usermsg   VARCHAR2 (20 CHAR)   := '1';
   msgsrc    VARCHAR2 (4000)      := 'SR_COMMON_LOG';
   msgjobid  VARCHAR2 (20 CHAR)   := '-1';
   
   -- logging report levels
   gc_rlevel_info         constant VARCHAR2(10 CHAR) := 'INFO';
   gc_rlevel_error        constant VARCHAR2(10 CHAR) := 'WARN';
   gc_rlevel_exception    constant VARCHAR2(10 CHAR) := 'ERR';
   gc_def_sender          constant VARCHAR2(100 CHAR) := 'ERR';
   gc_longdatetimeformat  constant VARCHAR2(100 CHAR) := 'DD-MON-YYYY HH24:MI:SS';
               
   -- queue handling levels
   gc_qh_registered       constant number := 1;
   gc_qh_accepted         constant number := 2;
   gc_qh_completed        constant number := 3;   
   gc_qh_error            constant number := 4;   
   gc_qh_cstop            constant number := 5;   
   
   gc_loglevel            constant number := 3;
  
   -- report escalation levels
   gc_qh_errors           constant number := 1;
   gc_qh_errwarn          constant number := 2;
   gc_qh_eventall         constant number := 3;   
   gc_qh_mailevent        constant number := 4;   
   gc_qh_msgevent         constant number := 5;   

   TYPE cursor_type IS REF CURSOR;
-- public cursors
 
   cursor msglogevent_cur (ip_eventid CTUSR.SR_MESSAGE_LOG.entry_id%type)
     is
      select
           entry_id,
           job_id,
           msg_code,
           msg_nativecode,
           msg_source,
           msg_text,
           msg_type,
           timestamp,
           user_id
       from CTUSR.SR_MESSAGE_LOG
       where entry_id = ip_eventid;

   cursor msglogbyjob_cur (ip_jobid CTUSR.SR_MESSAGE_LOG.job_id%type)
     is
      select
           entry_id,
           job_id,
           msg_code,
           msg_nativecode,
           msg_source,
           msg_text,
           msg_type,
           timestamp,
           user_id
       from CTUSR.SR_MESSAGE_LOG
       where job_id = ip_jobid
     order by entry_id;

   cursor jobentryrange_cur (ip_jobid CTUSR.SR_MESSAGE_LOG.job_id%type)
     is   
    select  min(entry_id) as firstentry,
            max(entry_id) as lastentry
       from CTUSR.SR_MESSAGE_LOG
       where job_id = ip_jobid
     order by entry_id;

   cursor msglogbyrange_cur (ip_jobid   CTUSR.SR_MESSAGE_LOG.job_id%type,
                             firstentry number,
                             lastentry  number
                            )
     is
     select
           entry_id,
           job_id,
           msg_code,
           msg_nativecode,
           msg_source,
           msg_text,
           msg_type,
           timestamp,
           user_id
       from CTUSR.SR_MESSAGE_LOG
       where entry_id  between firstentry-20 and lastentry+2
	         and (job_id = ip_jobid 
		      or job_id in (1,-1,9999, 99999)
		     )
     order by entry_id;
   
   
--procedures  
   PROCEDURE msglog (
      msgtype    IN   VARCHAR2 DEFAULT 'INFO',
      msgtext    IN   VARCHAR2 DEFAULT NULL,
      msgcode    IN   VARCHAR2 DEFAULT NULL,
      usermsg    IN   VARCHAR2 DEFAULT NULL,
      msgsrc     IN   VARCHAR2 DEFAULT NULL,
      msgjobid   IN   VARCHAR2 DEFAULT NULL,
      loglvl     IN   VARCHAR2 DEFAULT NULL
   );
--
   PROCEDURE write_event (
      msgtype    IN   VARCHAR2 DEFAULT 'INFO',
      msgtext    IN   VARCHAR2 DEFAULT NULL,
      msgcode    IN   VARCHAR2 DEFAULT NULL,
      usermsg    IN   VARCHAR2 DEFAULT NULL,
      msgsrc     IN   VARCHAR2 DEFAULT NULL,
      msgjobid   IN   VARCHAR2 DEFAULT NULL
   );
   PROCEDURE report_event (
      msgtype    IN   VARCHAR2 DEFAULT 'INFO',
      msgtext    IN   VARCHAR2 DEFAULT NULL,
      msgcode    IN   VARCHAR2 DEFAULT NULL,
      usermsg    IN   VARCHAR2 DEFAULT NULL,
      msgsrc     IN   VARCHAR2 DEFAULT NULL,
      msgjobid   IN   VARCHAR2 DEFAULT NULL
   );
 
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
                        RETURN NUMBER;
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
                        RETURN NUMBER;
  PROCEDURE set_eventjoblogstop (
      ip_status    IN   NUMBER DEFAULT 3,
      ip_job_id    IN   NUMBER
   );
   PROCEDURE callerstackbuffer (lineno OUT INTEGER, object_name OUT VARCHAR2);						
    
      
   PROCEDURE cleareventlog(ip_doffset IN INTEGER);
   PROCEDURE clearjoblog(ip_doffset   IN INTEGER);
         
   
END SR_COMMON_LOG;
--[END]

/