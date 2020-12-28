--[GLOBAL: INTF PACKAGE SR_RULE]
--[VERIFY: OWNER: APPS TYPE: PACKAGE OBJECT: SR_RULE]
CREATE OR REPLACE PACKAGE  CTUSR.SR_RULE authid current_user  AS
/* ===============================================
   Package     : SR_RULE
   Description : This package contains functionality for basic Rule filtering.
   Created by  : Sergey Popov
   Created date: 24. January 2012
   Changehistory
   Date         Name               Description
================================================== */
/* Declare externally visible types, cursor, exception. */
   c_msgtype    VARCHAR2 (20 CHAR)    := 'INFO';
   c_msgtext    VARCHAR2 (2000 CHAR)  := 'Text';
   c_msgid      VARCHAR2 (20 CHAR)    := '1';
   c_usermsg    VARCHAR2 (20 CHAR)    := '1';
   c_msgsrc     VARCHAR2 (2000 CHAR)  := 'SR_RULE';
   c_msgjobid   VARCHAR2 (100 CHAR);
   olob         CLOB;
   
 TYPE cursor_type IS REF CURSOR;
   
CURSOR ruleset_cur (ip_rulesetid CTUSR.RULESET.RULESET_ID%TYPE) is
  SELECT 
  rul.RULE_ID,
  rul.SERVICE_ID,
  rul.RULESET_ID,
  rul.RULE_TYPE,
  rul.RULE_NAME,
  rul.RULE_DATA,
  rul.RULE_EXP,
  rul.RULE_SEQUENCE,
  rul.RULEAGGREGATION_ID,
  rul.RULEVERIFICATION_ID,
  rul.RULE_DESCRIPTION,
  rul.POLICY_ID,
  rs.RULESET_NAME,
  rs.RULESET_DESCRIPTION,
  svc.SERVICEMODEL_ID,
  svc.TASK,
  svc.ENGINE_ID,
  svc.SERVICE_NAME,
  svc.SERVICE_DESCRIPTION,
  svc.SERVICE_URL,
  svc.SERVICE_HOST,
  rv.RULE_VERIFICATION,
  ra.RULE_AGGREGATION,
  pol.element_description,
  pol.default_value
FROM 
  CTUSR.SERVICE svc,
  CTUSR.RULE rul,
  CTUSR.RULESET rs,
  CTUSR.RULE_AGGREGATION ra,
  CTUSR.RULE_VERIFICATION rv,
  CTUSR.POLICY pol 
 WHERE ((svc.SERVICE_ID = rul.SERVICE_ID)
 AND (rul.RULESET_ID   = rs.RULESET_ID)
 AND (rul.ruleaggregation_id = ra.ruleaggregation_id)
 AND (rv.ruleverification_id = rul.ruleverification_id)
 AND(rul.policy_id = pol.policy_id)
 AND(UPPER(rul.active) = 'Y')
 AND (rs.RULESET_ID    = ip_rulesetid))
ORDER BY rul.RULE_SEQUENCE asc nulls last;
		 
   TYPE AUDITTPRuleList_rec IS RECORD (
     busevent_name           VARCHAR2(40 CHAR), 
     v_rule                  VARCHAR2(40 CHAR),
     trgobj_data             VARCHAR2(40 CHAR),
     source                  VARCHAR2(40 CHAR),
     procpartn_id            VARCHAR2(40 CHAR),
     trgobjectclass          VARCHAR2(40 CHAR),
     user_id                 VARCHAR2(40 CHAR),
     user_code               VARCHAR2(40 CHAR),
     msg_id                  VARCHAR2(40 CHAR),
     ruleset_name            VARCHAR2(40 CHAR),
     rule_id                 VARCHAR2(40 CHAR),
     ruleset_id              VARCHAR2(40 CHAR),
     rule_name               VARCHAR2(40 CHAR), 
     xpath_rule              VARCHAR2(40 CHAR),
     xpath_data              VARCHAR2(40 CHAR),
     rule_operation          VARCHAR2(40 CHAR), 
     rule_index              VARCHAR2(40 CHAR),
     verification_operation  VARCHAR2(40 CHAR)
     );

	 
 FUNCTION get_idForRuleset(ruleset_name VARCHAR2) RETURN NUMBER;
	 
	 
 PROCEDURE msgvalidate(doc           IN XDB.DBMS_XMLDOM.DOMDocument,
                      ruleset_name  IN VARCHAR2,
                      valid         OUT BOOLEAN,
                      errors        OUT VARCHAR2
                      );
 PROCEDURE checkXMLRule(ip_xmlDoc         IN   XDB.DBMS_XMLDOM.DOMDocument,
			            ip_rulesetname    IN   VARCHAR2,
			            ip_siftpid        IN   VARCHAR2,
                        op_tpruledetected OUT  VARCHAR2 
                        );					  
 
-------------------------------------------------------------------------------------------
 PROCEDURE checkProcRule(ip_objdata                  IN   VARCHAR2,
 		                 ip_rulesetid                IN   CTUSR.RULESET.ruleset_id%TYPE,
		                 ip_siftpid                  IN   VARCHAR2,
                         op_tpruledetected           OUT  VARCHAR2,
				         op_rulemessage              OUT  VARCHAR2,
				         op_retreferense             OUT  VARCHAR2
                         );						 
						 
			 
END SR_RULE;
--[END]
/
