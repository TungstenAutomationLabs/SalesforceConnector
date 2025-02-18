/**
 * @description       : 
 * @author            : Unni
 * @group             : 
 * @last modified on  : 01-18-2025
 * @last modified by  : Unni
**/
public with sharing class TACreateJobRequest {
    public String sessionId;
	public ProcessIdentity processIdentity;
	public JobInitialization jobinitialization;

	public class JobInitialization {
		public List<InputVariables> inputVariables;
	    public Object startDate;
	}

    public class ProcessIdentity {
		//public String Id;
		public String Name;
	}

    // public static TACreateJobRequest parse(String json) {
	// 	return (TACreateJobRequest) System.JSON.deserialize(json, TACreateJobRequest.class);
	// }
}