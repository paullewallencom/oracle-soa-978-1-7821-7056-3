--[GLOBAL: SIF PACKAGE BODY SR_RULE]
--[VERIFY: OWNER: SR TYPE: PACKAGE BODY OBJECT: SR_RULE]
CREATE OR REPLACE PACKAGE BODY   CTUSR.SR_RULE AS
/* ===============================================
   Package     : SR_RULE
   Description : This package contains functionality for basic Rule filtering.
   Created by  : Sergey Popov
   Created date: 24. January 2012
   Changehistory
   Date         Name               Description
================================================== */
 -------------------------------------------------------------------------------------------
    XML UTILITES
 -------------------------------------------------------------------------------------------

 PROCEDURE freeDocument(doc XDB.DBMS_XMLDOM.DOMDocument) IS
  BEGIN
    XDB.DBMS_XMLDOM.freeDocument(doc);
  END;
 
/*----------------------------------------------------------------------------------------------
-- Name              valueOf
-- Created           SEP
-- Created by        24. January 2012
-- Purpose
-- Last changes
--
----------------------------------------------------------------------------------------------*/
  FUNCTION valueOf (doc       XDB.DBMS_XMLDOM.DOMDocument,
                    Xpath     VARCHAR2,
	  	    normalize BOOLEAN:=FALSE
	  	    )
    RETURN VARCHAR2 IS
  BEGIN
    IF XDB.DBMS_XMLDOM.IsNull(doc) OR Xpath IS NULL THEN RETURN NULL; END IF;
   
    RETURN valueOf(toNode(doc),
	           Xpath,
		   normalize
		  );
  END;
/*----------------------------------------------------------------------------------------------
-- Name              valueOf
-- Created           SEP
-- Created by        24. January 2012
-- Purpose
-- Last changes
--
----------------------------------------------------------------------------------------------*/
  FUNCTION valueOf(doc       VARCHAR2,
                   Xpath     VARCHAR2,
                   normalize BOOLEAN:=FALSE)
    RETURN VARCHAR2 IS
    Xmldoc XDB.DBMS_XMLDOM.DOMDocument;
    retval VARCHAR2(32767 CHAR);
  BEGIN
    IF doc IS NULL OR Xpath IS NULL THEN RETURN NULL; END IF;
    Xmldoc := parse(doc);
    retval := valueOf(Xmldoc , Xpath,normalize);
    SR_RULE.freeDocument(Xmldoc);
    RETURN retval;
  EXCEPTION
    WHEN OTHERS THEN freeDocument(Xmldoc); RAISE;
  END;
/*----------------------------------------------------------------------------------------------
-- Name              valueOf
-- Created           SEP
-- Created by        24. January 2012
-- Purpose
-- Last changes
--
----------------------------------------------------------------------------------------------*/
  FUNCTION valueOf(doc       CLOB,
                   Xpath     VARCHAR2,
                   normalize BOOLEAN:=FALSE)
    RETURN VARCHAR2 IS
    Xmldoc XDB.DBMS_XMLDOM.DOMDocument;
    retval VARCHAR2(32767 CHAR);
  BEGIN
    IF doc IS NULL OR Xpath IS NULL THEN RETURN NULL; END IF;
    Xmldoc := parse(doc);
    retval := valueOf(Xmldoc, Xpath, normalize);
    freeDocument(Xmldoc);
    RETURN retval;
  EXCEPTION
    WHEN OTHERS THEN freeDocument(Xmldoc); RAISE;
  END;

  
/*----------------------------------------------------------------------------------------------
-- Name              test
-- Created           SEP
-- Created by        24. January 2012
-- Purpose
-- Last changes
--
----------------------------------------------------------------------------------------------*/
  FUNCTION test(doc XDB.DBMS_XMLDOM.DOMDocument,Xpath VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN XDB.DBMS_XMLDOM.getLength(selectNodes(doc,'/self::node()['||Xpath||']')) > 0;
  END;
 /*----------------------------------------------------------------------------------------------
-- Name              test
-- Created           SEP
-- Created by        24. January 2012
-- Purpose
-- Last changes
--
----------------------------------------------------------------------------------------------*/
  FUNCTION test(node XDB.DBMS_XMLDOM.DOMNode,Xpath VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    RETURN XDB.DBMS_XMLDOM.getLength(selectNodes(node,'./self::node()['||Xpath||']')) > 0;
  END;
 /*----------------------------------------------------------------------------------------------
-- Name              test
-- Created           SEP
-- Created by        24. January 2012
-- Purpose
-- Last changes
--
----------------------------------------------------------------------------------------------*/
  FUNCTION test(doc VARCHAR2, Xpath VARCHAR2) RETURN BOOLEAN IS
    Xmldoc XDB.DBMS_XMLDOM.DOMDocument;
    retval BOOLEAN;
  BEGIN
    Xmldoc := parse(doc);
    retval := test(Xmldoc,Xpath);
    freeDocument(Xmldoc);
    RETURN retval;
  EXCEPTION
    WHEN OTHERS THEN freeDocument(Xmldoc); RAISE;
  END;
 /*----------------------------------------------------------------------------------------------
-- Name              test
-- Created           SEP
-- Created by        24. January 2012
-- Purpose
-- Last changes
--
----------------------------------------------------------------------------------------------*/
  FUNCTION test(doc CLOB, Xpath VARCHAR2) RETURN BOOLEAN IS
    Xmldoc XDB.DBMS_XMLDOM.DOMDocument;
    retval BOOLEAN;
  BEGIN
    Xmldoc := parse(doc);
    retval := test(Xmldoc,Xpath);
    freeDocument(Xmldoc);
    RETURN retval;
  EXCEPTION
    WHEN OTHERS THEN freeDocument(Xmldoc); RAISE;
  END;
  
-------------------------------------------------------------------------------------------
-- Name              get_idForRuleset
-- Created           Sergey Popov
-- Created by        24. January 2012
-- Purpose
--
-- Last changes
--
-------------------------------------------------------------------------------------------
  FUNCTION get_idForRuleset(ruleset_name VARCHAR2) RETURN NUMBER IS
    theId NUMBER;
  BEGIN
    select rs.ruleset_id
      into theid
      from CTUSR.RULESET rs
     where rs.ruleset_name = ruleset_name;
     return theid;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN NULL;
  END;
 
 -------------------------------------------------------------------------------------------
-- Name              msgvalidate
-- Created           Sergey Popov
-- Created by        24. January 2012
-- Purpose
--
-- Last changes
--
-------------------------------------------------------------------------------------------
  PROCEDURE msgvalidate(doc          IN  XDB.DBMS_XMLDOM.DOMDocument,
                        ruleset_name IN  VARCHAR2,
                        valid        OUT BOOLEAN,
                        errors       OUT VARCHAR2
                        )
  IS
    errcount  NUMBER := 0;
    rulesetId NUMBER := CTUSR.SR_RULE.get_idForRuleSet(ruleset_name);
  BEGIN
    c_msgsrc := 'SR_RULE.msgvalidate';
	
    IF XDB.DBMS_XMLDOM.isNull(doc) THEN
      valid  := FALSE;
      errors := 'Cannot validate. Document is null';
    ELSIF rulesetId IS NULL THEN
      valid  := FALSE;
      errors := 'Cannot validate. Ruleset '||ruleset_name||' does not exist.';
    ELSE
      -- Assume the doc is valid until proven otherwise
      valid := TRUE;
      for currule in (select rule_name, rule_exp
                                      from CTUSR.RULE
                                      where ruleset_id = rulesetid)
	   LOOP
                IF NOT SR_RULE.test(doc,curRule.rule_exp) THEN
                         errcount := errcount + 1;
                         valid := FALSE;
                         IF errcount > 1 THEN
                               errors := errors ||CHR(10);
                        END IF;
                        errors := errors || '('||errcount||') '||CURRULE.RULE_NAME;
               END IF;
      END LOOP;
    END IF;
  END;
 -------------------------------------------------------------------------------------------
-- Name              rulevalidate
-- Created           Sergey Popov
-- Created by        24. January 2012
-- Purpose
--
-- Last changes
--
-------------------------------------------------------------------------------------------
  PROCEDURE rulevalidate(ip_ruleoperation        IN   VARCHAR2,
                         ip_verifoperation       IN   VARCHAR2,
                         ip_msgdata              IN   VARCHAR2,
                         ip_ruledata             IN   VARCHAR2,
                         ip_siftpid              IN   VARCHAR2,
                         op_singletpruledetected OUT  VARCHAR2
                        )
  IS
    v_ruleoperation        VARCHAR2 (20 CHAR);
    v_verifoperation       VARCHAR2 (20 CHAR);
    v_singletpruledetected VARCHAR2 (20 CHAR) :='N';
  BEGIN
     c_msgsrc := 'SR_RULE.rulevalidate';
    
 	 v_verifoperation := ip_verifoperation;
	     IF  ip_verifoperation = '=' then
             IF ip_msgdata = ip_ruledata THEN
                   v_singletpruledetected  :='Y';
              END IF;
         ELSIF  ip_verifoperation = '>' then
             IF ip_msgdata > ip_ruledata THEN
                   v_singletpruledetected  :='Y';
              END IF;
         ELSIF  ip_verifoperation = '<' then
              IF ip_msgdata < ip_ruledata THEN
                   v_singletpruledetected  :='Y';
              END IF;
         ELSIF  ip_verifoperation = 'LIKE' then
              IF ip_msgdata LIKE '%'||ip_ruledata||'%' THEN
                   v_singletpruledetected  :='Y';
              END IF;
         ELSIF  ip_verifoperation = 'ISLENMORE' then
              IF LENGTH(RTRIM(LTRIM(ip_msgdata)))> ip_ruledata THEN
                   v_singletpruledetected  :='Y';
              END IF;
         ELSIF  ip_verifoperation = 'ISLENLESS' then
              IF LENGTH(RTRIM(LTRIM(ip_msgdata)))< ip_ruledata THEN
                   v_singletpruledetected  :='Y';
              END IF;
         ELSIF  ip_verifoperation = 'ISNULL' then
              IF (ip_msgdata is  null) or (LENGTH(RTRIM(LTRIM(ip_msgdata)))=0) THEN
                   v_singletpruledetected  :='Y';
              END IF;
         ELSIF  ip_verifoperation = 'ISNOTNULL' then
              IF (ip_msgdata is not null) or (LENGTH(RTRIM(LTRIM(ip_msgdata)))>0) or (UPPER(RTRIM(LTRIM(ip_msgdata)))<>'NULL')THEN
                   v_singletpruledetected  :='Y';
              END IF;
         ELSIF  ip_verifoperation = '<>' then
              IF (UPPER(RTRIM(LTRIM(ip_msgdata)))<>UPPER(RTRIM(LTRIM(ip_ruledata))))THEN
                   v_singletpruledetected  :='Y';
              END IF;
         end if;
         /* For debug ONLY
         if v_singletpruledetected ='Y' then
                   c_msgtext := 'Event pattern recognised for TP ID: '||ip_xditpid;
                   CTUSR.SR_COMMON_LOG.msglog (c_msgtype,
             	                     c_msgtext,
             						 c_msgid,
             						 c_usermsg,
             						 c_msgsrc,
             						 c_msgjobid);
         end if;
         */
         op_singletpruledetected := v_singletpruledetected;
 EXCEPTION
   WHEN OTHERS THEN
      op_singletpruledetected  :='N';
      c_msgtype := 'ERR';
      c_msgid   := SQLCODE;
      c_msgtext := SQLERRM(c_msgid);
      c_msgsrc  := 'XPATH_DETECT.DetectMsgStatID';
      CTUSR.SR_COMMON_LOG.MSGLOG(c_msgtype,c_msgtext,c_msgid,c_usermsg,c_msgsrc,c_msgjobid);
 END rulevalidate;
 -------------------------------------------------------------------------------------------
-- Name              checkXMLRule
-- Created           Sergey Popov
-- Created by        24. January 2012
-- Purpose
--
-- Last changes
--
-------------------------------------------------------------------------------------------
  PROCEDURE checkXMLRule(ip_xmlDoc          IN   XDB.DBMS_XMLDOM.DOMDocument,
 		                 ip_rulesetname     IN   VARCHAR2,
		                 ip_siftpid         IN   VARCHAR2,
                         op_tpruledetected  OUT  VARCHAR2
                        )
  IS
    nl         XDB.DBMS_XMLDOM.DOMNodeList;
    len        NUMBER;
    inodes     INTEGER;
    v_xpathrule      VARCHAR2 (4000 CHAR);
    v_ruledata       VARCHAR2 (200 CHAR);
    v_msgruledata    VARCHAR2 (200 CHAR);
    v_singletpruledetected VARCHAR2 (1 CHAR) :='N';
    validstatref     BOOLEAN;
    ruleset_rec     ruleset_cur%ROWTYPE;
    v_ruleoperation       VARCHAR2 (20 CHAR);
    v_verifoperation      VARCHAR2 (20 CHAR);
    v_ORrulecounter       PLS_INTEGER  := 0;
    v_ORhitrulecounter    PLS_INTEGER  := 0;
    v_ANDrulecounter      PLS_INTEGER  := 0;
    v_ANDhitrulecounter   PLS_INTEGER  := 0;
    v_rulescounter        PLS_INTEGER  := 0;
  BEGIN
   
  c_msgsrc := 'SR_RULE.checkXMLRule';
	   
  IF XDB.DBMS_XMLDOM.isNull(ip_xmlDoc) THEN
      validstatref  := FALSE;
  ELSE
  IF XDB.DBMS_XMLDOM.isNull(ip_xmlDoc) THEN
      validstatref  := FALSE;
  ELSE
    OPEN ruleset_cur(ip_rulesetname);
    LOOP
     FETCH ruleset_cur INTO ruleset_rec;
	 EXIT WHEN ruleset_cur%NOTFOUND;
                    v_xpathrule := RTRIM(LTRIM(ruleset_rec.rule_exp));
                    v_ruledata  := RTRIM(LTRIM(ruleset_rec.rule_data));
	                v_ruleoperation  := UPPER(RTRIM(LTRIM(ruleset_rec.RULE_AGGREGATION)));
	                v_verifoperation := RTRIM(LTRIM(ruleset_rec.RULE_VERIFICATION));
               /*  --test mode  ONLY
                   c_msgtext := 'Analyzing RuleSet : '|| in_rulesetname
                            || ' for TP ID :  '       || ip_xditpid
                            || '; Using XPATH : '     || v_xpathrule
                            || '; Looking for data : '|| v_ruledata;
                   CTUSR.SR_COMMON_LOG.msglog (c_msgtype,
                             c_msgtext,
                             c_msgid,
                             c_usermsg,
                             c_msgsrc,
                             c_msgjobid);
                   */
                    v_msgruledata := SR_RULE.valueOf(ip_xmlDoc, v_xpathrule);
                    rulevalidate(ip_ruleoperation        => v_ruleoperation,
                                 ip_verifoperation       => v_verifoperation,
                                 ip_msgdata              => v_msgruledata,
                                 ip_ruledata             => v_ruledata,
                                 ip_siftpid              => ip_siftpid,
                                 op_singletpruledetected => v_singletpruledetected
                                );
                  /*  --test mode  ONLY
                   c_msgtext := 'Extracted value : '                  || v_msgruledata
                            || '; Verification operation to apply : ' || v_verifoperation
                            || '; Rule operation : '                  || v_ruleoperation
                            || '; Match Status : '                    || v_singletpruledetected;
                   CTUSR.SR_COMMON_LOG.msglog (c_msgtype,
                             c_msgtext,
                             c_msgid,
                             c_usermsg,
                             c_msgsrc,
                             c_msgjobid);
                   */
                    -- update HIT counters
                    IF v_singletpruledetected ='Y' THEN
                           if v_ruleoperation = 'AND'  then
                              v_ANDhitrulecounter := v_ANDhitrulecounter +1;
                           end if;
                           if v_ruleoperation = 'OR'  then
                              v_ORhitrulecounter := v_ORhitrulecounter +1;
                           end if;
                    END IF;
                   -- update counters
                    v_rulescounter := v_rulescounter + 1;
                    if v_ruleoperation = 'OR'  then
                       v_ORrulecounter := v_ORrulecounter + 1;
                    end if;
                    if v_ruleoperation = 'AND'  then
                       v_ANDrulecounter := v_ANDrulecounter + 1;
                    end if;
    END LOOP;
    CLOSE ruleset_cur;
   END IF;
  END IF;
  if  v_rulescounter = v_ORrulecounter then
      if v_ORhitrulecounter > 0 then
         op_tpruledetected :=	'Y';
      end if;
  else
      if v_ANDrulecounter = v_ANDhitrulecounter then
         op_tpruledetected :=	'Y';
      else
         op_tpruledetected :=	'N';
      end if;
  end if;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      op_tpruledetected  :='N';
      CLOSE ruleset_cur;
   WHEN OTHERS THEN
      op_tpruledetected  :='N';
      CLOSE ruleset_cur;
      c_msgtype := 'ERR';
      c_msgid   := SQLCODE;
      c_msgtext := SQLERRM(c_msgid);
      c_msgsrc  := 'SR_RULE.checkXMLRule';
      CTUSR.SR_COMMON_LOG.MSGLOG(c_msgtype,c_msgtext,c_msgid,c_usermsg,c_msgsrc,c_msgjobid);
 END checkXMLRule;
 -------------------------------------------------------------------------------------------
-- Name              checkProcRule
-- Created           Sergey Popov
-- Created by        24. January 2012
-- Purpose
--
-- Last changes
--
-------------------------------------------------------------------------------------------
  PROCEDURE checkProcRule(ip_objdata                  IN   VARCHAR2,
 		          ip_rulesetid                        IN   CTUSR.RULESET.ruleset_id%TYPE,
		          ip_siftpid                          IN   VARCHAR2,
                  op_tpruledetected                   OUT  VARCHAR2,
				  op_rulemessage                      OUT  VARCHAR2,
				  op_retreferense                     OUT  VARCHAR2
                  )

    IS
    nl                    XDB.DBMS_XMLDOM.DOMNodeList;
    len                   NUMBER;
    inodes                INTEGER;
    v_xpathrule           VARCHAR2 (4000 CHAR);
    v_ruledata            VARCHAR2 (200 CHAR);
    v_msgruledata         VARCHAR2 (200 CHAR);
    v_singletpruledetected VARCHAR2 (1 CHAR) :='N';
    validstatref          BOOLEAN;
    ruleset_rec           ruleset_cur%ROWTYPE;
    v_ruleoperation       VARCHAR2 (20 CHAR);
    v_verifoperation      VARCHAR2 (20 CHAR);
    ret_referense         VARCHAR2 (4000 CHAR);
	v_rulepolicy          VARCHAR2 (4000 CHAR) := 'POLICIES VIOLATED: ' ;
    v_ORrulecounter       PLS_INTEGER  := 0;
    v_ORhitrulecounter    PLS_INTEGER  := 0;
    v_ANDrulecounter      PLS_INTEGER  := 0;
    v_ANDhitrulecounter   PLS_INTEGER  := 0;
    v_rulescounter        PLS_INTEGER  := 0;
  BEGIN
  
  c_msgsrc := 'SR_RULE.checkProcRule';
  
  IF ip_objdata IS NULL THEN
      validstatref  := FALSE;
  ELSE
    OPEN ruleset_cur(ip_rulesetid);
    LOOP
     FETCH ruleset_cur INTO ruleset_rec;
	 EXIT WHEN ruleset_cur%NOTFOUND;
                v_xpathrule := RTRIM(LTRIM(ruleset_rec.SERVICE_URL));
                v_ruledata  := RTRIM(LTRIM(ruleset_rec.rule_data));
	            v_ruleoperation  := UPPER(RTRIM(LTRIM(ruleset_rec.RULE_AGGREGATION)));
	            v_verifoperation := RTRIM(LTRIM(ruleset_rec.RULE_VERIFICATION));
                    c_msgtext := 'Analyzing RuleSet ID: '|| ip_rulesetid
                            || ' for TP ID :  '          || ip_siftpid
                            || '; Using XPATH : '        || v_xpathrule
                            || '; Looking for data : '   || v_ruledata;
               
			    CTUSR.SR_COMMON_LOG.msglog (c_msgtype,
                                                c_msgtext,
                                                c_msgid,
                                                c_usermsg,
                                                c_msgsrc,
                                                c_msgjobid);
  				    ret_referense :=
					SUBSTR(sr_common_dynexec.fncrefexec (oper_in           => ruleset_rec.SERVICE_NAME,
                                                         nargs_in      => 1,
                                                         arg1_in       => ip_objdata,
                                                         arg2_in       => null,
                                                         arg3_in       => null,
                                                         arg4_in       => null,
                                                         arg5_in       => null
                                                        ),1,4000);
                               
                    rulevalidate(ip_ruleoperation        => v_ruleoperation,
                                 ip_verifoperation       => v_verifoperation,
                                 ip_msgdata              => ret_referense,
                                 ip_ruledata             => v_ruledata,
                                 ip_siftpid              => ip_siftpid,
                                 op_singletpruledetected => v_singletpruledetected
                                );
                   
				   c_msgtext := 'Extracted value : '                  || SUBSTR(ret_referense,1,2500)
                            || '; Verification operation to apply : ' || v_verifoperation
                            || '; Rule operation : '                  || v_ruleoperation
                            || '; Match Status : '                    || v_singletpruledetected;
                   CTUSR.SR_COMMON_LOG.msglog (c_msgtype,
                             c_msgtext,
                             c_msgid,
                             c_usermsg,
                             c_msgsrc,
                             c_msgjobid);
                  
				  -- update HIT counters
                    IF v_singletpruledetected ='Y' THEN
                           if v_ruleoperation = 'AND'  then
                              v_ANDhitrulecounter := v_ANDhitrulecounter +1;
                           end if;
                           if v_ruleoperation = 'OR'  then
                              v_ORhitrulecounter := v_ORhitrulecounter +1;
                           end if;
					ELSE 
					-- Rule policy violated. Reporting:
                     v_rulepolicy := v_rulepolicy ||' Policy :' || ruleset_rec.element_description || ', Expected value: ' ||v_verifoperation||' '|| ruleset_rec.RULE_DATA ||', Detected value: '|| nvl(ret_referense, 'Not identified') ||';' ;   					
                    END IF;
                   -- update counters
                    v_rulescounter := v_rulescounter + 1;
                    IF v_ruleoperation = 'OR'  then
                       v_ORrulecounter := v_ORrulecounter + 1;
                    END IF;
                    if v_ruleoperation = 'AND'  then
                       v_ANDrulecounter := v_ANDrulecounter + 1;
                    END IF;
      END LOOP;
    CLOSE ruleset_cur;
   END IF;
   
   op_retreferense := SUBSTR(ret_referense,1,4000);
   
   IF  v_rulescounter = v_ORrulecounter then
      if v_ORhitrulecounter > 0 then
         op_tpruledetected := 'Y';
		 op_rulemessage    := 'Parameter is according to the business rule. Status OK.';
      end if;
   ELSE
      if v_ANDrulecounter = v_ANDhitrulecounter then
         op_tpruledetected := 'Y';
		 op_rulemessage    := 'Parameter is according to the business rule. Status OK.';
      else
         op_tpruledetected := 'N';
		 op_rulemessage    :=  SUBSTR(v_rulepolicy, 1, 3999);
      end if;
  END IF;
 
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      op_tpruledetected  :='N';
      CLOSE ruleset_cur;
   WHEN OTHERS THEN
      op_tpruledetected  :='N';
      CLOSE ruleset_cur;
      c_msgtype := 'ERR';
      c_msgid   := SQLCODE;
      c_msgtext := SQLERRM(c_msgid);
      c_msgsrc  := 'SR_RULE.checkProcRule';
      CTUSR.SR_COMMON_LOG.MSGLOG(c_msgtype,c_msgtext,c_msgid,c_usermsg,c_msgsrc,c_msgjobid);
 END checkProcRule; 
 END SR_RULE;
--[END]
/

