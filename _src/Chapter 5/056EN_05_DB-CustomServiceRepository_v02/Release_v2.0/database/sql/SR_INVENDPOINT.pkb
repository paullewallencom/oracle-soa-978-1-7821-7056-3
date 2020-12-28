--[GLOBAL: SIF PACKAGE BODY SR_INVENDPOINT]
--[VERIFY: OWNER: AUDIT TYPE: PACKAGE BODY OBJECT: SR_INVENDPOINT]
CREATE OR REPLACE PACKAGE BODY CTUSR.SR_INVENDPOINT AS
--*****************************************************************************
--Module      : Generic
--Type        : PL/SQL - Package
--Filename    : $sql/SR_INVENDPOINT.pkb
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
   FUNCTION NOP RETURN VARCHAR2
   IS
      v_nop       VARCHAR2 (4000 CHAR)         := 'NA';
   BEGIN
      RETURN v_nop;
   EXCEPTION
      WHEN OTHERS
      THEN
         msgtype := 'ERR';
         msgid := SQLCODE;
         msgtext := SQLERRM (msgid);
         msgsrc := 'SR_INVENDPOINT.NOP';
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgid,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
   END NOP;
/*****************************************************************************
                               END OF PACKAGE
******************************************************************************/
END SR_INVENDPOINT;
--[END]
/

