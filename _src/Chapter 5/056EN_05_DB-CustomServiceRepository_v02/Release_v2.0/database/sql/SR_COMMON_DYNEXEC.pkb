--[GLOBAL: INTF PACKAGE BODY SR_COMMON_DYNEXEC]
--[VERIFY: OWNER: APPS TYPE: PACKAGE BODY OBJECT: SR_COMMON_DYNEXEC]
CREATE OR REPLACE PACKAGE BODY  CTUSR.SR_COMMON_DYNEXEC  AS
/* ===============================================
   Package     : SR_COMMON_DYNEXEC
   Description : This package contains functionality for Oracle Native Dynamic SQL(NDS).
   Created by  : Sergey Popov
   Created date: 24. January 2012
   Changehistory
   Date         Name               Description
================================================== */
   -------------------------------------------------------------------------------------------
-- Name              PrcStatExec
-- Created           SEP
-- Created by        24. January 2012
-- Purpose
--                   dynamic procedure for executing message construction statements
--                   accepts next parameters. Used by COM + interface
--    mID         - message ID                                         mandatory
--    nargs_in    - number of incoming parameters                      mandatory
--    arg1_in     - USER ID                                            mandatory
--    arg2_in     - key parameter as taken from the trigger reference  mandatory
--    arg3_in     - DB_ACTION     "INSERT"  by default                 optional
--    arg4_in     - DB_TIMESTAMP   SYSDATE by default                  optional
--    arg5_in     - SaveAsFile NULL by default                         optional
--    arg6_in     - optional
--    arg7_in     - optional
--    arg8_in     - optional
--    arg9_in     - optional
   -- Last changes
--
-------------------------------------------------------------------------------------------
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
--   v_status OUT INTEGER           -- new parameter
   )
   IS
      msgid           VARCHAR2 (10 CHAR);
      msg_statement   VARCHAR2 (32767 CHAR);
      retval          VARCHAR2 (32767 CHAR);
      v_status        INTEGER;
   	  v_msgdef_rec    CTUSR.SR_MESSAGE.msgdef_rec;
   BEGIN
      msgid := mid;
      CTUSR.SR_MESSAGE.get_msgdef(ip_msgid      => msgid,
				                  op_msgdef_rec => v_msgdef_rec
				                 );
      IF CTUSR.SR_MESSAGE.gv_msg_action IS NOT NULL
      THEN
         msg_statement := 'BEGIN  ' || CTUSR.SR_MESSAGE.gv_msg_action;
         v_status := 0;
         IF nargs_in = 0
         THEN
            EXECUTE IMMEDIATE msg_statement || '; END;';
         ELSIF nargs_in = 1
         THEN
            EXECUTE IMMEDIATE msg_statement || '(:1); END;'
                        USING arg1_in;
         ELSIF nargs_in = 2
         THEN
            EXECUTE IMMEDIATE msg_statement || '(:1, :2); END;'
                        USING arg1_in, arg2_in;
         ELSIF nargs_in = 3
         THEN
            EXECUTE IMMEDIATE msg_statement || '(:1, :2, :3); END;'
                        USING arg1_in, arg2_in, arg3_in;
         ELSIF nargs_in = 4
         THEN
            EXECUTE IMMEDIATE msg_statement || '(:1, :2, :3, :4); END;'
                        USING arg1_in, arg2_in, arg3_in, arg4_in;
         ELSIF nargs_in = 5
         THEN
            EXECUTE IMMEDIATE msg_statement || '(:1, :2, :3, :4, :5); END;'
                        USING arg1_in, arg2_in, arg3_in, arg4_in, arg5_in;
         ELSIF nargs_in = 6
         THEN
            EXECUTE IMMEDIATE    msg_statement
                              || '(:1, :2, :3, :4, :5, :6); END;'
                        USING arg1_in,
                              arg2_in,
                              arg3_in,
                              arg4_in,
                              arg5_in,
                              arg6_in;
         ELSIF nargs_in = 7
         THEN
            EXECUTE IMMEDIATE    msg_statement
                              || '(:1, :2, :3, :4, :5, :6, :7); END;'
                        USING arg1_in,
                              arg2_in,
                              arg3_in,
                              arg4_in,
                              arg5_in,
                              arg6_in,
                              arg7_in;
         ELSIF nargs_in = 8
         THEN
            EXECUTE IMMEDIATE    msg_statement
                              || '(:1, :2, :3, :4, :5, :6, :7, :8); END;'
                        USING arg1_in,
                              arg2_in,
                              arg3_in,
                              arg4_in,
                              arg5_in,
                              arg6_in,
                              arg7_in,
                              arg8_in;
         ELSIF nargs_in = 9
         THEN
            EXECUTE IMMEDIATE    msg_statement
                              || '(:1, :2, :3, :4, :5, :6, :7, :8, :9); END;'
                        USING arg1_in,
                              arg2_in,
                              arg3_in,
                              arg4_in,
                              arg5_in,
                              arg6_in,
                              arg7_in,
                              arg8_in,
                              arg9_in;
         END IF;
      ELSE
         v_status := -1;
      END IF;
      v_status := 1;                                          -- temp solution
   EXCEPTION
      WHEN OTHERS
      THEN
         v_status := -1;
         msgtype := 'ERR';
         msgcode := SQLCODE;
         msgtext := SQLERRM (msgcode);
         msgsrc :=
               'Fatal Error: SR_COMMON_DYNEXEC.PrcStatExec for MSG ID - '
            || mid
            || '; arg1 - '
            || arg1_in
            || '; arg2 - '
            || arg2_in;
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgcode,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
   END prcstatexec;
-------------------------------------------------------------------------------------------
-- Name              PrcStatExecRet
-- Created           SEP
-- Created by        24. January 2012
-- Purpose
--                   dynamic procedure for executing message construction statements
--                   accepts next parameters.
--    mID         - message ID                                         mandatory
--    nargs_in    - number of incoming parameters                      mandatory
--    arg1_in     - USER ID                                            mandatory
--    arg2_in     - key parameter as taken from the trigger reference  mandatory
--    arg3_in     - DB_ACTION     "INSERT"  by default                 optional
--    arg4_in     - DB_TIMESTAMP   SYSDATE by default                  optional
--    arg5_in     - SaveAsFile NULL by default                         optional
--    arg6_in     - optional
--    arg7_in     - optional
--    arg8_in     - optional
--    arg9_in     - optional
   -- Last changes
--
-------------------------------------------------------------------------------------------
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
   -- RETURN VARCHAR2
   )
   IS
      msgid           VARCHAR2 (10 CHAR);
      msg_statement   VARCHAR2 (4000 CHAR);
      v_status        VARCHAR2 (20 CHAR)   := 0;
      v_jobid         VARCHAR2 (40 CHAR);
      v_sql           VARCHAR2 (400 CHAR);
      strcriteria     VARCHAR2 (400 CHAR);
      retpram_cur     cursor_type;
   	  v_msgdef_rec     CTUSR.SR_MESSAGE.msgdef_rec;
   BEGIN
      msgid := mid;
      CTUSR.SR_MESSAGE.get_msgdef(ip_msgid      => msgid,
					               op_msgdef_rec => v_msgdef_rec
					               );
      IF CTUSR.SR_MESSAGE.gv_msg_action IS NOT NULL
      THEN
         msg_statement := 'BEGIN  ' || CTUSR.SR_MESSAGE.gv_msg_action;
         IF nargs_in = 0
         THEN
            EXECUTE IMMEDIATE msg_statement || '; END;';
         ELSIF nargs_in = 1
         THEN
            EXECUTE IMMEDIATE msg_statement || '(:1, :2, :3); END;'
                        USING arg1_in, OUT v_status, OUT v_jobid;
         ELSIF nargs_in = 2
         THEN
            EXECUTE IMMEDIATE msg_statement || '(:1, :2, :3, :4); END;'
                        USING arg1_in, arg2_in, OUT v_status, OUT v_jobid;
         ELSIF nargs_in = 3
         THEN
            EXECUTE IMMEDIATE msg_statement || '(:1, :2, :3, :4, :5); END;'
                        USING     arg1_in,
                                  arg2_in,
                                  arg3_in,
                              OUT v_status,
                              OUT v_jobid;
         ELSIF nargs_in = 4
         THEN
            EXECUTE IMMEDIATE    msg_statement
                              || '(:1, :2, :3, :4, :5, :6); END;'
                        USING     arg1_in,
                                  arg2_in,
                                  arg3_in,
                                  arg4_in,
                              OUT v_status,
                              OUT v_jobid;
         ELSIF nargs_in = 5
         THEN
            EXECUTE IMMEDIATE    msg_statement
                              || '(:1, :2, :3, :4, :5, :6, :7); END;'
                        USING     arg1_in,
                                  arg2_in,
                                  arg3_in,
                                  arg4_in,
                                  arg5_in,
                              OUT v_status,
                              OUT v_jobid;
         ELSIF nargs_in = 6
         THEN
            EXECUTE IMMEDIATE    msg_statement
                              || '(:1, :2, :3, :4, :5, :6, :7, :8); END;'
                        USING     arg1_in,
                                  arg2_in,
                                  arg3_in,
                                  arg4_in,
                                  arg5_in,
                                  arg6_in,
                              OUT v_status,
                              OUT v_jobid;
         ELSIF nargs_in = 7
         THEN
            EXECUTE IMMEDIATE    msg_statement
                              || '(:1, :2, :3, :4, :5, :6, :7, :8, :9); END;'
                        USING     arg1_in,
                                  arg2_in,
                                  arg3_in,
                                  arg4_in,
                                  arg5_in,
                                  arg6_in,
                                  arg7_in,
                              OUT v_status,
                              OUT v_jobid;
         ELSIF nargs_in = 8
         THEN
            EXECUTE IMMEDIATE    msg_statement
                              || '(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10); END;'
                        USING     arg1_in,
                                  arg2_in,
                                  arg3_in,
                                  arg4_in,
                                  arg5_in,
                                  arg6_in,
                                  arg7_in,
                                  arg8_in,
                              OUT v_status,
                              OUT v_jobid;
         ELSIF nargs_in = 9
         THEN
            EXECUTE IMMEDIATE    msg_statement
                              || '(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11); END;'
                        USING     arg1_in,
                                  arg2_in,
                                  arg3_in,
                                  arg4_in,
                                  arg5_in,
                                  arg6_in,
                                  arg7_in,
                                  arg8_in,
                                  arg9_in,
                              OUT v_status,
                              OUT v_jobid;
         END IF;
      ELSE
         v_status := -1;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         CLOSE retpram_cur;
         v_status := -1;
         msgtype := 'ERR';
         msgcode := SQLCODE;
         msgtext := SQLERRM (msgcode);
         msgsrc :=
               'Fatal Error: SR_COMMON_DYNEXEC.PrcStatExecRet for MSG ID - '
            || mid
            || '; arg1 - '
            || arg1_in
            || '; arg2 - '
            || arg2_in;
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgcode,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
   END prcstatexecret;
-------------------------------------------------------------------------------------------
-- Name              PrcStatExecRetInt
-- Created           SEP
-- Created by        24. January 2012
-- Purpose
--                   dynamic procedure for executing message construction statements
--                   accepts next parameters.
--    msg_statement         - message statement                                        mandatory
--    nargs_in    - number of incoming parameters                                   mandatory
--    arg1_in     - USER ID                                                                                 mandatory
--    arg2_in     - key parameter as taken from the trigger reference  mandatory
--    arg3_in     - DB_ACTION     "INSERT"  by default                            optional
--    arg4_in     - DB_TIMESTAMP   SYSDATE by default                    optional
--    arg5_in     - SaveAsFile NULL by default                                            optional
--    arg6_in     - optional
--    arg7_in     - optional
--    arg8_in     - optional
--    arg9_in     - optional
   -- Last changes
--
-------------------------------------------------------------------------------------------
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
      arg8_in         IN       VARCHAR2 := NULL,
      arg9_in         IN       VARCHAR2 := NULL,
      arg10_in        IN       VARCHAR2 := NULL,
      v_status        OUT      NUMBER
   )
   IS
      msg_stm   VARCHAR2 (4000 CHAR);
   BEGIN
      v_status := -1;
      msg_stm := 'BEGIN ' || msg_statement;
      IF nargs_in = 0
      THEN
         EXECUTE IMMEDIATE msg_stm || '; END;';
      ELSIF nargs_in = 1
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1, :2,); END;'
                     USING arg1_in, OUT v_status;
      ELSIF nargs_in = 2
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1, :2, :3); END;'
                     USING arg1_in, arg2_in, OUT v_status;
      ELSIF nargs_in = 3
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1, :2, :3, :4); END;'
                     USING arg1_in, arg2_in, arg3_in, OUT v_status;
      ELSIF nargs_in = 4
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1, :2, :3, :4, :5); END;'
                     USING arg1_in, arg2_in, arg3_in, arg4_in, OUT v_status;
      ELSIF nargs_in = 5
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1, :2, :3, :4, :5, :6); END;'
                     USING     arg1_in,
                               arg2_in,
                               arg3_in,
                               arg4_in,
                               arg5_in,
                           OUT v_status;
      ELSIF nargs_in = 6
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1, :2, :3, :4, :5, :6, :7); END;'
                     USING     arg1_in,
                               arg2_in,
                               arg3_in,
                               arg4_in,
                               arg5_in,
                               arg6_in,
                           OUT v_status;
      ELSIF nargs_in = 7
      THEN
         EXECUTE IMMEDIATE msg_stm
                           || '(:1, :2, :3, :4, :5, :6, :7, :8); END;'
                     USING     arg1_in,
                               arg2_in,
                               arg3_in,
                               arg4_in,
                               arg5_in,
                               arg6_in,
                               arg7_in,
                           OUT v_status;
      ELSIF nargs_in = 8
      THEN
         EXECUTE IMMEDIATE    msg_stm
                           || '(:1, :2, :3, :4, :5, :6, :7, :8, :9); END;'
                     USING     arg1_in,
                               arg2_in,
                               arg3_in,
                               arg4_in,
                               arg5_in,
                               arg6_in,
                               arg7_in,
                               arg8_in,
                           OUT v_status;
      ELSIF nargs_in = 9
      THEN
         EXECUTE IMMEDIATE    msg_stm
                           || '(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10); END;'
                     USING     arg1_in,
                               arg2_in,
                               arg3_in,
                               arg4_in,
                               arg5_in,
                               arg6_in,
                               arg7_in,
                               arg8_in,
                               arg9_in,
                           OUT v_status;
--   END IF;
      ELSIF nargs_in = 10
      THEN
         EXECUTE IMMEDIATE    msg_stm
                           || '(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11); END;'
                     USING     arg1_in,
                               arg2_in,
                               arg3_in,
                               arg4_in,
                               arg5_in,
                               arg6_in,
                               arg7_in,
                               arg8_in,
                               arg9_in,
                               arg10_in,
                           OUT v_status;
--   END IF;
      ELSE
         v_status := -1;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         v_status := -1;
         msgtype := 'ERR';
         msgcode := SQLCODE;
         msgtext := SQLERRM (msgcode);
         msgsrc :=
               'Fatal Error: SR_COMMON_DYNEXEC.PrcStatExecRetInt for statement - '
            || msg_stm
            || '; arg1 - '
            || arg1_in
            || '; arg2 - '
            || arg2_in;
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgcode,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
   END prcstatexecretint;
-------------------------------------------------------------------------------------------
-- Name              PrcRefExec
-- Created           SEP
-- Created by        24. January 2012
-- Purpose
--                   dynamic procedure for message reference parsing inside XXCU_INTF_EVENT_HANDLER
--                   accepts next parameters.
--    msg_statement - message statement                                  mandatory
--    nargs_in    - number of incoming parameters                      mandatory
--    arg1_in     - USER ID                                            mandatory
--    arg2_in     - key parameter as taken from the trigger reference  mandatory
--    arg3_in     - DB_ACTION     "INSERT"  by default                 optional
--    arg4_in     - DB_TIMESTAMP   SYSDATE by default                  optional
--    arg5_in     - SaveAsFile NULL by default                         optional
--    arg6_in     - optional
--    arg7_in     - optional
--    arg8_in     - optional
--    arg9_in     - optional
-- Last changes
--
-------------------------------------------------------------------------------------------
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
--    v_status OUT INTEGER           -- new parameter
   )
   IS
      msg_stm    VARCHAR2 (32767 CHAR);
      retval     VARCHAR2 (32767 CHAR);
      v_status   INTEGER;
   BEGIN
      v_status := 0;
      msg_stm := 'BEGIN ' || msg_statement;
      IF nargs_in = 0
      THEN
         EXECUTE IMMEDIATE msg_stm || '; END;';
      ELSIF nargs_in = 1
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1); END;'
                     USING arg1_in;
      ELSIF nargs_in = 2
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1, :2); END;'
                     USING arg1_in, arg2_in;
      ELSIF nargs_in = 3
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1, :2, :3); END;'
                     USING arg1_in, arg2_in, arg3_in;
      ELSIF nargs_in = 4
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1, :2, :3, :4); END;'
                     USING arg1_in, arg2_in, arg3_in, arg4_in;
      ELSIF nargs_in = 5
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1, :2, :3, :4, :5); END;'
                     USING arg1_in, arg2_in, arg3_in, arg4_in, arg5_in;
      ELSIF nargs_in = 6
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1, :2, :3, :4, :5, :6); END;'
                     USING arg1_in,
                           arg2_in,
                           arg3_in,
                           arg4_in,
                           arg5_in,
                           arg6_in;
      ELSIF nargs_in = 7
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1, :2, :3, :4, :5, :6, :7); END;'
                     USING arg1_in,
                           arg2_in,
                           arg3_in,
                           arg4_in,
                           arg5_in,
                           arg6_in,
                           arg7_in;
      ELSIF nargs_in = 8
      THEN
         EXECUTE IMMEDIATE msg_stm
                           || '(:1, :2, :3, :4, :5, :6, :7, :8); END;'
                     USING arg1_in,
                           arg2_in,
                           arg3_in,
                           arg4_in,
                           arg5_in,
                           arg6_in,
                           arg7_in,
                           arg8_in;
      ELSIF nargs_in = 9
      THEN
         EXECUTE IMMEDIATE    msg_stm
                           || '(:1, :2, :3, :4, :5, :6, :7, :8, :9); END;'
                     USING arg1_in,
                           arg2_in,
                           arg3_in,
                           arg4_in,
                           arg5_in,
                           arg6_in,
                           arg7_in,
                           arg8_in,
                           arg9_in;
      END IF;
     -- temp solution
      v_status := 1;
   EXCEPTION
      WHEN OTHERS
      THEN
         v_status := -1;
         msgtype := 'ERR';
         msgcode := SQLCODE;
         msgtext := SQLERRM (msgcode);
         msgsrc :=
               'Fatal Error: SR_COMMON_DYNEXEC.PrcRefExec for Process - '
            || msg_statement
            || '; arg1 - '
            || arg1_in
            || '; arg2 - '
            || arg2_in;
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgcode,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
   END prcrefexec;
/*-------------------------------------------------------------------------------------------
-- Name              prcstatexecretLOB
-- Created           SEP
-- Created by        24. January 2012
-- Purpose
--                   dynamic procedure for executing message construction statements
--                   accepts next parameters.
--    msg_statement         - message statement                                     mandatory
--    nargs_in    - number of incoming parameters                                   mandatory
--    arg1_in     - USER ID                                                         mandatory
--    arg2_in     - key parameter as taken from the trigger reference               mandatory
--    arg3_in     - DB_ACTION     "INSERT"  by default                              optional
--    arg4_in     - DB_TIMESTAMP   SYSDATE by default                               optional
--    arg5_in     - SaveAsFile NULL by default                                      optional
--    arg6_in     - optional
--    arg7_in     - optional
--    arg8_in     - optional
--    arg9_in     - optional
-------------------------------------------------------------------------------------------*/
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
      v_result        OUT      NOCOPY   CLOB
   )
   IS
      msg_stm   VARCHAR2 (4000 CHAR);
   BEGIN
      msgtext := 'Dynamic execution of : ' || msg_statement || '; number of parameters: '||nargs_in;
      msg_stm := 'BEGIN ' || msg_statement;
      IF nargs_in = 0
      THEN
         EXECUTE IMMEDIATE msg_stm || '; END;';
      ELSIF nargs_in = 1
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1, :2,); END;'
                     USING arg1_in,  OUT v_result;
      ELSIF nargs_in = 2
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1, :2, :3); END;'
                     USING arg1_in, arg2_in,  OUT v_result;
      ELSIF nargs_in = 3
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1, :2, :3, :4); END;'
                     USING arg1_in, arg2_in, arg3_in,  OUT v_result;
      ELSIF nargs_in = 4
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1, :2, :3, :4, :5); END;'
                     USING arg1_in, arg2_in, arg3_in, arg4_in,  OUT v_result;
      ELSIF nargs_in = 5
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1, :2, :3, :4, :5, :6); END;'
                     USING     arg1_in,
                               arg2_in,
                               arg3_in,
                               arg4_in,
                               arg5_in,
                           OUT v_result;
      ELSIF nargs_in = 6
      THEN
         EXECUTE IMMEDIATE msg_stm || '(:1, :2, :3, :4, :5, :6, :7); END;'
                     USING     arg1_in,
                               arg2_in,
                               arg3_in,
                               arg4_in,
                               arg5_in,
                               arg6_in,
                            OUT v_result;
      ELSIF nargs_in = 7
      THEN
         EXECUTE IMMEDIATE msg_stm
                           || '(:1, :2, :3, :4, :5, :6, :7, :8); END;'
                     USING     arg1_in,
                               arg2_in,
                               arg3_in,
                               arg4_in,
                               arg5_in,
                               arg6_in,
                               arg7_in,
                            OUT v_result;
      ELSIF nargs_in = 8
      THEN
         EXECUTE IMMEDIATE    msg_stm
                           || '(:1, :2, :3, :4, :5, :6, :7, :8, :9); END;'
                     USING     arg1_in,
                               arg2_in,
                               arg3_in,
                               arg4_in,
                               arg5_in,
                               arg6_in,
                               arg7_in,
                               arg8_in,
                            OUT v_result;
      ELSIF nargs_in = 9
      THEN
         EXECUTE IMMEDIATE    msg_stm
                           || '(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10); END;'
                     USING     arg1_in,
                               arg2_in,
                               arg3_in,
                               arg4_in,
                               arg5_in,
                               arg6_in,
                               arg7_in,
                               arg8_in,
                               arg9_in,
                            OUT v_result;
      ELSIF nargs_in = 10
      THEN
         EXECUTE IMMEDIATE    msg_stm
                           || '(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11); END;'
                     USING     arg1_in,
                               arg2_in,
                               arg3_in,
                               arg4_in,
                               arg5_in,
                               arg6_in,
                               arg7_in,
                               arg8_in,
                               arg9_in,
                               arg10_in,
                            OUT v_result;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         msgtype := 'ERR';
         msgcode := SQLCODE;
         msgtext := SQLERRM (msgcode);
         msgsrc :=
               'Fatal Error: SR_COMMON_DYNEXEC.prcstatexecretLOB for statement - '
            || msg_stm
            || '; arg1 - '
            || arg1_in
            || '; arg2 - '
            || arg2_in
            || '; arg3 - '
            || arg3_in
            || '; arg4 - '
            || arg4_in
            || '; arg5 - '
            || arg5_in
            || '; arg6 - '
            || arg6_in
            || '; arg7 - '
            || arg7_in
            || '; arg8 - '
            || arg8_in;
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgcode,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
   END prcstatexecretLOB;
-------------------------------------------------------------------------------------------
-- Name              PrcRefExec
-- Created           SEP
-- Created by        24. January 2012
-- Purpose
--                   dynamic procedure for function execution
--                   accepts next parameters. USER = only EDI
--    oper_in       - function code                                      mandatory
--    nargs_in      - number of incoming parameters                      mandatory
--    arg1_in       - key parameter as taken from the trigger reference  mandatory
--    arg2_in       - DB_ACTION     "INSERT"  by default                 optional
--    arg3_in       - DB_TIMESTAMP   SYSDATE by default                  optional
--    arg4_in       - SaveAsFile NULL by default                         optional
--    arg5_in       - optional
--    arg7_in       - optional
--    arg8_in       - optional
--    arg9_in       - optional
   -- Last changes
--
-------------------------------------------------------------------------------------------
   FUNCTION fncrefexec (
      oper_in    IN   VARCHAR2,
      nargs_in   IN   INTEGER := 0,
      arg1_in    IN   VARCHAR2 := NULL,
      arg2_in    IN   VARCHAR2 := NULL,
      arg3_in    IN   VARCHAR2 := NULL,
      arg4_in    IN   VARCHAR2 := NULL,
      arg5_in    IN   VARCHAR2 := NULL
   )
      RETURN VARCHAR2
   IS
      v_code   VARCHAR2 (32767 CHAR) := 'BEGIN :outcome := ' || oper_in;
      retval   VARCHAR2 (32767 CHAR);
   BEGIN
          msgsrc  := 'SR_COMMON_DYNEXEC.FncRefExec';
          msgtext :=
               'Executing SR_COMMON_DYNEXEC.FncRefExec for function - '
            || oper_in
            || '; Number of arguments - '
            || nargs_in            
            || '; argument - '
            || arg1_in;
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgcode,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
 
      IF nargs_in = 0
      THEN
         EXECUTE IMMEDIATE v_code || '; END;'
                     USING OUT retval;
      ELSIF nargs_in = 1
      THEN
         EXECUTE IMMEDIATE v_code || '(:1); END;'
                     USING OUT retval, arg1_in;
      ELSIF nargs_in = 2
      THEN
         EXECUTE IMMEDIATE v_code || '(:1, :2); END;'
                     USING OUT retval, arg1_in, arg2_in;
      ELSIF nargs_in = 3
      THEN
         EXECUTE IMMEDIATE v_code || '(:1, :2, :3); END;'
                     USING OUT retval, arg1_in, arg2_in, arg3_in;
      ELSIF nargs_in = 4
      THEN
         EXECUTE IMMEDIATE v_code || '(:1, :2, :3, :4); END;'
                     USING OUT retval, arg1_in, arg2_in, arg3_in, arg4_in;
      ELSIF nargs_in = 5
      THEN
         EXECUTE IMMEDIATE v_code || '(:1, :2, :3, :4, :5); END;'
                     USING OUT retval,
                               arg1_in,
                               arg2_in,
                               arg3_in,
                               arg4_in,
                               arg5_in;
      END IF;
      msgtext :=  'SR_COMMON_DYNEXEC.FncRefExec. Return: '|| retval;
      CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgcode,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         msgtype := 'ERR';
         msgcode := SQLCODE;
         msgtext := SQLERRM (msgcode);
         msgsrc :=
               'Fatal Error: SR_COMMON_DYNEXEC.FncRefExec for Process - '
            || oper_in
            || '; arg1 - '
            || arg1_in
            || '; arg2 - '
            || arg2_in;
         CTUSR.SR_COMMON_LOG.msglog (msgtype,
                            msgtext,
                            msgcode,
                            usermsg,
                            msgsrc,
                            msgjobid
                           );
   END fncrefexec;
/*****************************************************************************
                               END OF PACKAGE
******************************************************************************/
END SR_COMMON_DYNEXEC;

--[END]
/

