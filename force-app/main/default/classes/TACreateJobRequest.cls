/**
 * @description       : 
 * @author            : Unni
 * @group             : 
 * @last modified on  : 11-30-2024
 * @last modified by  : Unni
**/
public with sharing class TACreateJobRequest {
    public String sessionId;
	public ProcessIdentity processIdentity;
	public JobInitialization jobinitialization;

	public class JobInitialization {
		public List<InputVariables> InputVariables;
	    public Object StartDate;
	}

    public class ProcessIdentity {
		public String Id;
		public String Name;
	}

    public static TACreateJobRequest parse(String json) {
		return (TACreateJobRequest) System.JSON.deserialize(json, TACreateJobRequest.class);
	}
}