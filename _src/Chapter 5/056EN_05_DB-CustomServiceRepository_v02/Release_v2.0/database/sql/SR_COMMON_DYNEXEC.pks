--[GLOBAL: INTF PACKAGE SR_COMMON_DYNEXEC]
--[VERIFY: OWNER: APPS TYPE: PACKAGE OBJECT: SR_COMMON_DYNEXEC]
CREATE OR REPLACE PACKAGE  CTUSR.SR_COMMON_DYNEXEC authid current_user AS
/* ===============================================
   Package     : SR_COMMON_DYNEXEC
   Filename    : $sql/SR_COMMON_DYNEXEC.pkb   
   Description : This package contains functionality for Oracle Native Dynamic SQL(NDS).
   Created by  : Sergey Popov
   Created date: 24. January 2012
   Version     : 0.1
   Changehistory
   Date         Name               Description
================================================== */
--------------------------------------------------------------------
/* Declare externally visible types, cursor, exception. */
   msgtype    VARCHAR2 (20 CHAR)   := 'INFO';
   msgtext    VARCHAR2 (2000 CHAR) := 'Text';
   msgcode    VARCHAR2 (20 CHAR)   := '100';             -- custom internal message
   usermsg    VARCHAR2 (20 CHAR)   := '1';
   msgsrc     VARCHAR2 (400 CHAR)  := 'SR_COMMON_DYNEXEC';
   msgjobid   VARCHAR2 (100 CHAR);
   TYPE cursor_type IS REF CURSOR;
--------------------------------------------------------------------
   PROCEDURE prcstatexec (
      mid        IN   VARCHAR2,
      nargs_in   IN   VARCHAR2 := 0,
      arg1_in    IN   VARCHAR2 := NULL,
      arg2_in    IN   VARCHAR2 := NULL,
      arg3_in    IN   VARCHAR2 := NULL,
      arg4_in    IN   VARCHAR2 := NULL,
      arg5_in    IN   VARCHAR2 := NULL,
      arg6_in    IN   VARCHAR2 := NULL,
      arg7_in    IN   VARCHAR2 := NULL,
      arg8_in    IN   VARCHAR2 := NULL,
      arg9_in    IN   VARCHAR2 := NULL
   );                                                 --, v_status OUT INTEGER
   PROCEDURE prcrefexec (
      msg_statement   IN   VARCHAR2,
      nargs_in        IN   INTEGER := 0,
      arg1_in         IN   VARCHAR2 := NULL,
      arg2_in         IN   VARCHAR2 := NULL,
      arg3_in         IN   VARCHAR2 := NULL,
      arg4_in         IN   VARCHAR2 := NULL,
      arg5_in         IN   VARCHAR2 := NULL,
      arg6_in         IN   VARCHAR2 := NULL,
      arg7_in         IN   VARCHAR2 := NULL,
      arg8_in         IN   VARCHAR2 := NULL,
      arg9_in         IN   VARCHAR2 := NULL
   --   v_status OUT INTEGER           -- new parameter
   );
   PROCEDURE prcstatexecret (
      mid        IN   VARCHAR2,
      nargs_in   IN   VARCHAR2 := 0,
      arg1_in    IN   VARCHAR2 := NULL,
      arg2_in    IN   VARCHAR2 := NULL,
      arg3_in    IN   VARCHAR2 := NULL,
      arg4_in    IN   VARCHAR2 := NULL,
      arg5_in    IN   VARCHAR2 := NULL,
      arg6_in    IN   VARCHAR2 := NULL,
      arg7_in    IN   VARCHAR2 := NULL,
      arg8_in    IN   VARCHAR2 := NULL,
      arg9_in    IN   VARCHAR2 := NULL
   --retpram_cur OUT cursor_type
   );
   PROCEDURE prcstatexecretint (
      msg_statement   IN       VARCHAR2,
      nargs_in        IN       VARCHAR2 := 0,
      arg1_in         IN       VARCHAR2 := NULL,
      arg2_in         IN       VARCHAR2 := NULL,
      arg3_in         IN       VARCHAR2 := NULL,
      arg4_in         IN       VARCHAR2 := NULL,
      arg5_in         IN       VARCHAR2 := NULL,
      arg6_in         IN       VARCHAR2 := NULL,
      arg7_in         IN       VARCHAR2 := NULL,
      arg8_in         IN       VARCHAR2 := NULL,          --- OUT NOCOPY CLOB,
      arg9_in         IN       VARCHAR2 := NULL,
      arg10_in        IN       VARCHAR2 := NULL,
      v_status        OUT      NUMBER
   );
   PROCEDURE prcstatexecretLOB (
      msg_statement   IN       VARCHAR2,
      nargs_in        IN       NUMBER := 0,
      arg1_in         IN       VARCHAR2 := NULL,
      arg2_in         IN       VARCHAR2 := NULL,
      arg3_in         IN       VARCHAR2 := NULL,
      arg4_in         IN       VARCHAR2 := NULL,
      arg5_in         IN       VARCHAR2 := NULL,
      arg6_in         IN       VARCHAR2 := NULL,
      arg7_in         IN       VARCHAR2 := NULL,
      arg8_in         IN       VARCHAR2 := NULL,       
      arg9_in         IN       VARCHAR2 := NULL,
      arg10_in        IN       VARCHAR2 := NULL,
      v_result        OUT      NOCOPY  CLOB
   );
  
  ---------------------------------------------------------------------
   FUNCTION fncrefexec (
      oper_in    IN   VARCHAR2,
      nargs_in   IN   INTEGER := 0,
      arg1_in    IN   VARCHAR2 := NULL,
      arg2_in    IN   VARCHAR2 := NULL,
      arg3_in    IN   VARCHAR2 := NULL,
      arg4_in    IN   VARCHAR2 := NULL,
      arg5_in    IN   VARCHAR2 := NULL
   )
      RETURN VARCHAR2;
---------------------------------------------------------------------
END SR_COMMON_DYNEXEC;
--[END]
/
