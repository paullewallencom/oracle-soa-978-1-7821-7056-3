create or replace view CTUSR.v_service_inventory_errors_all
as
select co.compositionlist_id,
       co.process_id,
       co.operationtype_id,
	   co.task_order,
       ot.operation,
       pr.process_name,
       pr.process_description,
       pr.bu_id process_bu_id,
       bl.bu_code process_bu_code,
       co.service_id,
       se.service_name,
       se.task service_task,
       es.eventmessage_id,
       em.eventmessage_code,
       em.eventmessage_name,
       es.retry_count,
       es.retry_interval,
       es.resolution_operationtype_id,
       ot2.operation resolution_operation,
       es.resolution_process_id,
       pr2.process_name resolution_process_name
from composition co,
     process pr,
     process pr2,
     bu_location bl,
     service se,
     operation_type ot,
     operation_type ot2,
     eventmessage_service es,
     event_message em
where co.process_id (+) = pr.process_id
      and pr.bu_id = bl.bu_id
      and co.service_id = se.service_id (+)
      and co.operationtype_id = ot.operationtype_id (+)
      and co.compositionlist_id = es.compositionlist_id
      and es.resolution_operationtype_id = ot2.operationtype_id
      and es.resolution_process_id = pr2.process_id (+)
      and es.eventmessage_id = em.eventmessage_id;