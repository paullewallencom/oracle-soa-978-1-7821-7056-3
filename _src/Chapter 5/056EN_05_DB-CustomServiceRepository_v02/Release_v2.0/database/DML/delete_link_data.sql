--I. Run first
--GU artifacts relations
delete CTUSR.EVENT_MESSAGE;
delete CTUSR.COMPOSITIONTASK_RULES;
delete CTUSR.COMPOSITIONTASK_MESSAGE;
delete CTUSR.COMPOSITIONTASK_APPEVENT;
delete CTUSR.APPLICATION_EVENT;
delete CTUSR.APPLICATION_ENDPOINT;
delete CTUSR.COMPOSITION;
delete CTUSR.EVENT;
delete CTUSR.PROCESS_POLICY;
delete CTUSR.PROCESS_PATTERNS;
delete CTUSR.PROCESS;
delete CTUSR.POLICY;
delete CTUSR.RULE;
delete CTUSR.SERVICE;
commit;
