/**
 * @description       : 
 * @author            : Unni
 * @group             : 
 * @last modified on  : 11-28-2024
 * @last modified by  : Unni
**/
global with sharing class TAResponseWrapper {
    @InvocableVariable(label='Job ID' description='Job ID returned by TotalAgility')
    global String jobID;

    @InvocableVariable(label='TotalAgility callout Result' description='Success or Failure')
    global String result;

    @InvocableVariable(label='Result Message' description='Result message from TotalAgility')
    global String resultMessage;
}