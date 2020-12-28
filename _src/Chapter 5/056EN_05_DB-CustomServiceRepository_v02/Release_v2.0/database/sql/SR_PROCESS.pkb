--[GLOBAL: SIF PACKAGE BODY SR_PROCESS]
--[VERIFY: OWNER: SR TYPE: PACKAGE BODY OBJECT: SR_PROCESS]
CREATE OR REPLACE PACKAGE BODY  CTUSR.SR_PROCESS AS

--*****************************************************************************
--Module      : Generic
--Type        : PL/SQL - Package
--Filename    : $sql/SR_PROCESS.pkb
--Author      : Sergey Popov
--Version     : 0.1
--                     
--
-- Description: Generic object Process for all interchange modules
--              
-- log procedures
-- *****************************************************************************
-------------------------------------------------------------------------------------------------------------------------------
   
-------------------------------------------------------------------------------------------
-- Name              get_processID
-- Created           Sergey Popov
-- Created by        24. January 2012
-- Purpose
--
-- Last changes
--
-------------------------------------------------------------------------------------------
   FUNCTION get_processID (ip_processname IN CTUSR.PROCESS.PROCESS_NAME%TYPE)
      RETURN NUMBER
   IS
      CURSOR process_cur (ip_servicename CTUSR.PROCESS.PROCESS_NAME%TYPE) IS
         SELECT CTUSR.PROCESS.PROCESS_ID
           FROM CTUSR.PROCESS
           WHERE (CTUSR.PROCESS.PROCESS_NAME = ip_processname);
      process_rec       process_cur%ROWTYPE;
      v_processid       NUMBER;
   BEGIN
      OPEN process_cur (ip_processname);
      FETCH process_cur
       INTO process_rec;
      IF process_cur%FOUND
      THEN
         IF process_rec.PROCESS_ID IS NULL
         THEN
            v_processid := -99999;
         ELSE
            v_processid := process_rec.PROCESS_ID;
         END IF;
      END IF;
      CLOSE process_cur;
      RETURN v_processid;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        CLOSE process_cur;
         v_processid := null;
		 msgtype     := 'ERR';
		 msgsrc      := 'SR_PROCESS.get_processID: No process ID found for process name: ' || ip_processname;
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgid,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
         RETURN v_processid;
      WHEN OTHERS
      THEN
        CLOSE process_cur;
         msgtype := 'ERR';
         msgid := SQLCODE;
         msgtext := SQLERRM (msgid);
         msgsrc := 'SR_PROCESS.get_processID';
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgid,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
   END get_processID;  
   
/*****************************************************************************
                               END OF PACKAGE
******************************************************************************/
END SR_PROCESS;
/
--[END]
