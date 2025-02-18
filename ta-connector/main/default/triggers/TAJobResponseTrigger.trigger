/**
 * @description       : 
 * @author            : Unni
 * @group             : 
 * @last modified on  : 01-15-2025
 * @last modified by  : Unni
**/
trigger TAJobResponseTrigger on JobResponse__e (after insert) {
    TAJobResponseHelper.processJobResponse(Trigger.new);
}
