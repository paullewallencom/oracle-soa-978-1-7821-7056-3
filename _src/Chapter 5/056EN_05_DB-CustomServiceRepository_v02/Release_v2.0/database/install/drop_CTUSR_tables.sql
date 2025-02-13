
ALTER TABLE OBJECT_PARAMETER DROP CONSTRAINT "OBJECT_PARAMETER_PARAMETER_FK"
;

ALTER TABLE OBJECT_PARAMETER DROP CONSTRAINT "OBJECT_PARAMETER_OBJECT_FK"
;

--ALTER TABLE COMPOSITIONTASK_APPEVENT DROP CONSTRAINT "APPEVENT_COMPOSITION_FK"
--;

ALTER TABLE COMPOSITIONTASK_APPEVENT DROP CONSTRAINT "COMPOSITIONTASK_APPEVENT_FK"
;

ALTER TABLE COMPOSITIONTASK_RULES DROP CONSTRAINT "COMPOSITIONTASK_RULES_FK"
;

ALTER TABLE COMPOSITIONTASK_RULES DROP CONSTRAINT "COMPOSITIONTASK_RULES_FK1"
;

ALTER TABLE APPLICATION_ENDPOINT DROP CONSTRAINT "APPLICATION_ENDPOINT_FK"
;

ALTER TABLE APPLICATION_ENDPOINT DROP CONSTRAINT "APPLICATION_ENDPOINT_FK1"
;

ALTER TABLE APPLICATION_ENDPOINT DROP CONSTRAINT "APPLICATION_ENDPOINT_MEP_FK"
;

ALTER TABLE PARAMETER DROP CONSTRAINT "PARAMETER_PK"
;

ALTER TABLE ENDPOINT DROP CONSTRAINT "ENDPOINT_ENDPOINTTYPE_FK"
;

ALTER TABLE ENDPOINT DROP CONSTRAINT "ENDPOINT_PROTOCOL_FK"
;

ALTER TABLE APPLICATION_EVENT DROP CONSTRAINT "APPLICATION_EVENT_EVENT_FK"
;

ALTER TABLE APPLICATION_EVENT DROP CONSTRAINT "APPLICATION_EVENT_FK"
;


ALTER TABLE OBJECT_PARAMETER DROP CONSTRAINT "OBJECT_PARAMETER_PK"
;

ALTER TABLE APPLICATION DROP CONSTRAINT "APPLICATION_BU_LOCATION_FK"
;

ALTER TABLE APPLICATION DROP CONSTRAINT "APPLICATION_GU_LOCATION_FK"
;

ALTER TABLE PROCESS DROP CONSTRAINT "PROCESS_BU_LOCATION_FK"
;

ALTER TABLE PROCESS DROP CONSTRAINT "PROCESS_MEP_FK"
;

ALTER TABLE POLICY DROP CONSTRAINT "POLICY_POLICY_PROVIDER_FK"
;

ALTER TABLE SERVICE DROP CONSTRAINT "SERVICE_SERVICE_ENGINE_FK"
;

ALTER TABLE SERVICE DROP CONSTRAINT "SERVICE_SERVICE_MODEL_FK"
;

ALTER TABLE COMPOSITION DROP CONSTRAINT "COMPOSITION_FK"
;

ALTER TABLE COMPOSITION DROP CONSTRAINT "COMPOSITION_OPERATION_TYPE_FK"
;

ALTER TABLE COMPOSITION DROP CONSTRAINT "COMPOSITION_PROCESS_FK"
;

ALTER TABLE COMPOSITION DROP CONSTRAINT "COMPOSITION_SERVICE_FK"
;

ALTER TABLE PROCESS_PATTERNS DROP CONSTRAINT "PROCESS_PATTERNS_PATTERN_FK"
;

ALTER TABLE PROCESS_PATTERNS DROP CONSTRAINT "PROCESS_PATTERNS_PROCESS_FK"
;

ALTER TABLE RULE DROP CONSTRAINT "RULE_RULESET_FK"
;

ALTER TABLE RULE DROP CONSTRAINT "RULE_RULE_AGGREGATION_FK"
;

ALTER TABLE RULE DROP CONSTRAINT "RULE_RULE_VERIFICATION_FK"
;

ALTER TABLE RULE DROP CONSTRAINT "RULE_SERVICE_FK"
;

ALTER TABLE COMPOSITIONTASK_MESSAGE DROP CONSTRAINT "COMPOSITIONTASK_MESSAGE_FK"
;

ALTER TABLE COMPOSITIONTASK_MESSAGE DROP CONSTRAINT "COMPOSITIONTASK_MESSAGE_FK1"
;

ALTER TABLE MESSAGE DROP CONSTRAINT "MESSAGE_OBJECT_FK"
;

ALTER TABLE PROCESS_POLICY DROP CONSTRAINT "PROCESS_POLICY_POLICY_FK"
;

ALTER TABLE PROCESS_POLICY DROP CONSTRAINT "PROCESS_POLICY_PROCESS_FK"
;

ALTER TABLE RESOLUTION_PROCESS DROP CONSTRAINT "RESOLUTION_PROCESS_PROCES_FK"
;

ALTER TABLE RESOLUTION_PROCESS DROP CONSTRAINT "RESOLUTION_PROCESS_PK"
;

DROP TABLE OBJECT_PARAMETER CASCADE constraints;

DROP TABLE PARAMETER CASCADE constraints;

DROP TABLE ENDPOINT_TYPE CASCADE constraints;

DROP TABLE BU_LOCATION CASCADE constraints;

DROP TABLE COMPOSITIONTASK_APPEVENT CASCADE constraints;

DROP TABLE GU_LOCATION CASCADE constraints;

DROP TABLE SERVICE_MODEL CASCADE constraints;

DROP TABLE COMPOSITIONTASK_RULES CASCADE constraints;

DROP TABLE OPERATION_TYPE CASCADE constraints;

DROP TABLE COMPOSITION_ROLE CASCADE constraints;

DROP TABLE APPLICATION_ENDPOINT CASCADE constraints;

DROP TABLE EVENT CASCADE constraints;

DROP TABLE RULE_AGGREGATION CASCADE constraints;

DROP TABLE ENDPOINT CASCADE constraints;

DROP TABLE APPLICATION_EVENT CASCADE constraints;

DROP TABLE APPLICATION CASCADE constraints;

DROP TABLE PROCESS CASCADE constraints;

DROP TABLE POLICY CASCADE constraints;

DROP TABLE OBJECT CASCADE constraints;

DROP TABLE MEP CASCADE constraints;

DROP TABLE SERVICE_ENGINE CASCADE constraints;

DROP TABLE POLICY_PROVIDER CASCADE constraints;

DROP TABLE PROTOCOL CASCADE constraints;

DROP TABLE SERVICE CASCADE constraints;

DROP TABLE COMPOSITION CASCADE constraints;

DROP TABLE PROCESS_PATTERNS CASCADE constraints;

DROP TABLE RULE CASCADE constraints;

DROP TABLE RULESET CASCADE constraints;

DROP TABLE COMPOSITIONTASK_MESSAGE CASCADE constraints;

DROP TABLE MESSAGE CASCADE constraints;

DROP TABLE RULE_VERIFICATION CASCADE constraints;

DROP TABLE PATTERN CASCADE constraints;

DROP TABLE PROCESS_POLICY CASCADE constraints;

DROP TABLE RESOLUTION_PROCESS CASCADE constraints;

DROP TABLE SR_EVENTPROC_LOG CASCADE constraints;

DROP TABLE SR_MESSAGE_LOG CASCADE constraints;