create or replace view CTUSR.V_PROCESS_AND_RESOLUTION
as
select pr.process_name use_case,
       bl.bu_code affiliate,
       co.process_id,
       co.service_id,
	   co.task_order,
       se.service_name error_component,
       em.eventmessage_code error_code,
       em.eventmessage_name,
       es.retry_count,
       es.retry_interval,
       es.resolution_operationtype_id operationtype_id,
       ot2.operation resolution_action,
       es.resolution_process_id,
       pr2.process_name resolution_name
from composition co,
     process pr,
     process pr2,
     bu_location bl,
     service se,
     operation_type ot2,
     eventmessage_service es,
     event_message em
where co.process_id (+) = pr.process_id
      and pr.bu_id = bl.bu_id
      and co.service_id = se.service_id (+)
      and co.compositionlist_id = es.compositionlist_id
      and es.resolution_operationtype_id = ot2.operationtype_id
      and es.resolution_process_id = pr2.process_id (+)
      and es.eventmessage_id = em.eventmessage_id;