--[GLOBAL: SIF PACKAGE BODY SR_SERVICE]
--[VERIFY: OWNER: SR TYPE: PACKAGE BODY OBJECT: SR_SERVICE]
CREATE OR REPLACE PACKAGE BODY  CTUSR.SR_SERVICE AS

--*****************************************************************************
--Module      : Generic
--Type        : PL/SQL - Package
--Filename    : $sql/SR_SERVICE.pkb
--Author      : Sergey Popov
--Version     : 0.1
--                     
--
-- Description: Generic object Service for all interchange modules
--              
-- log procedures
-- *****************************************************************************
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-- Name              get_serviceID
-- Created           Sergey Popov
-- Created by        24. January 2012
-- Purpose
--
-- Last changes
--
-------------------------------------------------------------------------------------------
   FUNCTION get_serviceID (ip_servicename IN CTUSR.SERVICE.TASK%TYPE)
      RETURN NUMBER
   IS
      CURSOR service_cur (ip_servicename CTUSR.SERVICE.TASK%TYPE) IS
         SELECT CTUSR.SERVICE.SERVICE_ID
           FROM CTUSR.SERVICE
           WHERE (CTUSR.SERVICE.TASK = ip_servicename);
      service_rec       service_cur%ROWTYPE;
      v_serviceid       NUMBER;
   BEGIN
      OPEN service_cur (ip_servicename);
      FETCH service_cur
       INTO service_rec;
      IF service_cur%FOUND
      THEN
         IF service_rec.SERVICE_ID IS NULL
         THEN
            v_serviceid := -99999;
         ELSE
            v_serviceid := service_rec.SERVICE_ID;
         END IF;
      END IF;
      CLOSE service_cur;
      RETURN v_serviceid;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
        CLOSE service_cur;
         v_serviceid := null;
		 msgtype     := 'ERR';
		 msgsrc      := 'SR_SERVICE.get_serviceID: No service ID found for service name: ' || ip_servicename;
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgid,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
		 
		 
         RETURN v_serviceid;
      WHEN OTHERS
      THEN
        CLOSE service_cur;
         msgtype := 'ERR';
         msgid := SQLCODE;
         msgtext := SQLERRM (msgid);
         msgsrc := 'SR_SERVICE.get_serviceID';
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgid,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
   END get_serviceID;

   
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
		 msgsrc      := 'SR_SERVICE.get_processID: No process ID found for process name: ' || ip_processname;
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
         msgsrc := 'SR_SERVICE.get_processID';
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
END SR_SERVICE;
/
--[END]
