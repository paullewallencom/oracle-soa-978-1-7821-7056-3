--------------------------------------------------------
--  DDL for Package Body SR_ERROR_MANAGER
--------------------------------------------------------
create or replace
PACKAGE BODY       SR_ERROR_MANAGER as

/*+--------------------------------------------------------------------------+*\
  | Name:      delete_error_resolutions                                      |
  | Author:    Marinus Snyman                                                |
  | Created:   01/06/2012                                                    |
  | Updated:                                                                 |
  | Version:   1.0                                                           |
  | Purpose:   Function to delete all error resolutions for a Affiliate      |
  |                                                                          |
  | Revisions:                                                               |
\*+--------------------------------------------------------------------------+*/
procedure delete_error_resolutions(ip_bu_code varchar2)
is

begin

  delete from composition
  where compositionlist_id in(
  select compositionlist_id
  from composition com,
       process pro,
       bu_location bu
  where com.process_id = pro.process_id
    and pro.bu_id = bu.bu_id
    and bu.bu_code = ip_bu_code);

  commit;
  dbms_output.put_line('Error Resolution Actions deleted for : ' || ip_bu_code);


  exception when others then
    dbms_output.put_line('Error deleting Error Resolution Actions for : ' || ip_bu_code || 'Error: ' || sqlerrm);

end delete_error_resolutions;
/*+--------------------------------------------------------------------------+*\
  | Name:      delete_error_resolutions_by_process                           |
  | Author:    Wouter Verheijen                                              |
  | Created:   01/06/2012                                                    |
  | Updated:                                                                 |
  | Version:   1.0                                                           |
  | Purpose:   Function to delete all error resolutions for a Process        |
  |                                                                          |
  | Revisions:                                                               |
\*+--------------------------------------------------------------------------+*/
procedure delete_error_res_by_process(ip_process varchar2)
is

begin

  delete from composition
  where compositionlist_id in(
  select compositionlist_id
  from composition com,
       process pro
  WHERE com.process_id = pro.process_id
    and pro.process_name = ip_process);

  commit;
  dbms_output.put_line('Error Resolution Actions deleted for : ' || ip_process);


  exception when others then
    dbms_output.put_line('Error deleting Error Resolution Actions for : ' || ip_process || 'Error: ' || sqlerrm);

END delete_error_res_by_process;

/*+--------------------------------------------------------------------------+*\
  | Name:      get_process_count                                             |
  | Author:    Marinus Snyman                                                |
  | Created:   30/05/2012                                                    |
  | Updated:                                                                 |
  | Version:   1.0                                                           |
  | Purpose:   Returns a count for the number of processes.                  |
  |                                                                          |
  | Revisions:                                                               |
  |                                                                          |
\*+--------------------------------------------------------------------------+*/
function get_process_count(p_process_name varchar2)
return number
as
  v_process_count number;
begin

   select count(1)
   into v_process_count
   FROM process
   where process_name = p_process_name;

   return v_process_count;

end;
/*+--------------------------------------------------------------------------+*\
  | Name:      insert_error_action                                           |
  | Author:    Marinus Snyman                                                |
  | Created:   27/03/2012                                                    |
  | Updated:   30/05/2012                                                    |
  | Version:   1.0                                                           |
  | Purpose:   API procedure to make it easier for projects to insert error  |
  |            actions / resolutions                                         |
  |                                                                          |
  | Revisions:                                                               |
\*+--------------------------------------------------------------------------+*/
procedure insert_error_action(ip_error_code                in event_message.eventmessage_code%type,
                              ip_retry_count               in number,
                              ip_retry_interval            in number,
                              ip_usecase_name              in process.process_name%type,
                              ip_resolution_process        in process.process_name%type,
                              ip_operation_type            in operation_type.operation%type,
                              ip_error_component_name      in service.task%type,
                              ip_bu_code                   in bu_location.bu_code%type,
                              op_status                    out number,
                              op_message                   out varchar2) as

  --Variables
  v_bu_id                       number;
  v_event_message_id            number;
  v_service_id                  number;
  v_process_id                  number;
  v_resolution_process_id       number;
  v_compositionlist_id          number;
  v_operationtype_id            number;
  v_process_count               number;
  v_resolution_action_count     number;
  v_resolution_process_count    number;

begin

    --Check if resolution action already exists
    select count(1)
    into v_resolution_action_count
    from v_process_and_resolution
    where service_name = ip_error_component_name
    and process_name = ip_usecase_name
    and error_code = ip_error_code
    and retry_count = ip_retry_count
    and affiliate = ip_bu_code;

    if v_resolution_action_count > 0 then
      raise_application_error(-20001, 'Resolution Action already exists');
    end if;

    --Get the bu_id
    begin
      select bu_id
      into v_bu_id
      from bu_location
      where bu_code = ip_bu_code;

      exception when no_data_found then
        --When no bu_location found insert the value
        insert into bu_location (bu_id,bu_code,bu_location)
                         values (bu_location_bu_id_s.nextval, ip_bu_code, ip_bu_code);
      when others then
        raise_application_error(-20001, 'Error in bu_id lookup for: ' || ip_bu_code || ' ' || sqlerrm);
    end;

    --Check if process already exists
    --Add to function
    v_process_count:= get_process_count(ip_usecase_name);

    if v_process_count = 0 then
      --Insert the process.
      begin
        insert into process (process_id,
                             bu_id,
                             mep_id,
                             process_name,
                             process_description,
                             logging_level,
                             sdd_url,
                             proc_custodian,
                             sdd_custodian)
                     values (process_process_id_s.nextval,
                             v_bu_id,
                             1,
                             ip_usecase_name,
                             ip_usecase_name,
                             1,
                             'NA',
                             'NA',
                             'NA');
      exception when others then
        raise_application_error(-20001, 'Could not insert process for usecase : ' || ip_usecase_name || ' ' || sqlerrm);
      end;
    end if;

    --Get the process_id
    v_process_id:= sr_service.get_processid(ip_usecase_name);
    if v_process_id is null then
      raise_application_error(-20001, 'Error in lookup for Process: ' || ip_usecase_name);
    end if;

    --Check if there is a resolution process. Thus a resolution execution plan.
    if ip_resolution_process is not null then
      --if there is a resolution process
      v_resolution_process_count:= get_process_count(ip_resolution_process);

      if v_resolution_process_count = 0 then
        --Insert the process.
        begin
          insert into process (process_id,
                               bu_id,
                               mep_id,
                               process_name,
                               process_description,
                               logging_level,
                               sdd_url,
                               proc_custodian,
                               sdd_custodian)
                       values (process_process_id_s.nextval,
                               v_bu_id,
                               1,
                               ip_resolution_process,
                               ip_resolution_process,
                               1,
                               'NA',
                               'NA',
                               'NA');
        exception when others then
          raise_application_error(-20001, 'Could not insert process for usecase : ' || ip_usecase_name || ' ' || sqlerrm);
        end;
      end if;

      --Get the resolution process_id
      v_resolution_process_id:= sr_service.get_processid(ip_resolution_process);
      if v_resolution_process_id is null then
        raise_application_error(-20001, 'Error in lookup for Process: ' || ip_resolution_process);
      end if;

    end if; -- if ip_resolution_process is not null then

    --Lookup the event message id
    --(Note: To be added to a function)
    begin
      select eventmessage_id
      into v_event_message_id
      from event_message
      where eventmessage_code = ip_error_code;

      exception when no_data_found then
         raise_application_error(-20001, 'No event message found for : ' || ip_error_code || ' ' || sqlerrm);
      when too_many_rows then
          raise_application_error(-20001, 'Multipe event messages found for : ' || ip_error_code || ' ' || sqlerrm);
      when others then
          raise_application_error(-20001, 'Error in finding event message found for : ' || ip_error_code || ' ' || sqlerrm);
    end;

    --Get the service_id
    v_service_id:= sr_service.get_serviceid(ip_error_component_name);
    if v_service_id is null then
      --If service don't exist create.
      --Note: ErrorComponent can be the Error Component, or the TaskName. Mapped from the Step to ErrorComponent in ErrorManager
      insert into service(service_id, servicemodel_id, task, engine_id, service_name, service_description, service_url, service_host)
                  values (service_service_id_s.nextval,7,ip_error_component_name,3,ip_error_component_name,ip_error_component_name,'na','na');
      v_service_id:=service_service_id_s.currval;
    end if;

    --Get the operation type
    --(Note: Shhould be added to function)
    begin
      select operationtype_id
      into v_operationtype_id
      from operation_type
      where operation = ip_operation_type;

      exception when others then
        raise_application_error(-20001, 'Error in lookup for operation type: ' || ip_operation_type);
    end;

    --Get the Composition Id
    begin
      select compositionlist_id
      into v_compositionlist_id
      from composition
      where process_id = v_process_id
        and service_id = v_service_id
        and operationtype_id = v_operationtype_id
        and role_id = 3;
      exception when no_data_found then
        --When composition does not exist, create it and set the id
        insert into composition (compositionlist_id, process_id, service_id, task_order,operationtype_id,role_id)
                         values (composition_complist_id_s.nextval,v_process_id,v_service_id,1,6,3);
        v_compositionlist_id:= composition_complist_id_s.currval;
      when others then
         raise_application_error(-20001, 'Error in lookup for compositionlist');
    end;

    --Insert the event message service
    insert into eventmessage_service (eventmessage_id,
                                      compositionlist_id,
                                      resolution_operationtype_id,
                                      resolution_process_id,
                                      retry_count,
                                      retry_interval)
                              values (v_event_message_id,
                                      v_compositionlist_id,
                                      v_operationtype_id,
                                      v_resolution_process_id,
                                      ip_retry_count,
                                      ip_retry_interval);

    commit;
    op_message:= 'SUCCESS: Added resolution action';
    op_status:= 0; --Success Code
    dbms_output.put_line(op_message);

    exception when others then
      op_message:= 'ERROR: Resolution Action not added. ' || sqlerrm;
      op_status:= -1; --Error
      dbms_output.put_line(op_message);
      rollback;

end insert_error_action;

END sr_error_manager;
/