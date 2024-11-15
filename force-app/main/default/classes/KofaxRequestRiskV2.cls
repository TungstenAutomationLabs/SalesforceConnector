/**
* @apexClassName      : KofaxRequestRiskV2
* @date               : August 2, 2023
* @description:       : Represents HTTP Request Body for the Kofax Document Risk Score process; Version 2
* @author             : John Hogan, johnejhogan@gmail.com
*/
public class KofaxRequestRiskV2 {

    public String sessionId;
	public ProcessIdentity processIdentity;
	public JobWithDocsInitialization jobWithDocsInitialization;

	public class JobWithDocsInitialization {
		public List<InputVariables> InputVariables;
	    public Object StartDate;
		public Boolean StoreFolderAndDocuments;
		public List<RuntimeDocumentCollection> RuntimeDocumentCollection;
	}

	public class InputVariables {
		public String Id;
		public String Value;
	}

	public class RuntimeDocumentCollection {
		public Blob Base64Data;
		public Object Data;
		public List<DocumentGroup> DocumentGroup;
		public String DocumentName;
		public String DocumentTypeId;
		public List<FieldsToReturn> FieldsToReturn;
		public String FilePath;
		public String FolderId;
		public String FolderTypeId;
		public String MimeType;
		public List<PageDataList> PageDataList;
		public Boolean ReturnAllFields;
		public Boolean ReturnFullTextOcr;
		public String RuntimeFields;
	}

	public class ProcessIdentity {
		public String Id;
		public String Name;
	}

    public class DocumentGroup {
	}

    public class FieldsToReturn {
	}

    public class PageDataList {
	}

	/** 
    * @methodName     : parse
    * @description:   : Deserialize JSON formatted string into a KofaxRequestRisk object
    * @author         : John Hogan

    * @param          : json (String): JSON formatted string to deserialize
    
    * @return         : KofaxRequestRisk: deserialize from JSON response value
    */
	public static KofaxRequestRiskV2 parse(String json) {
		return (KofaxRequestRiskV2) System.JSON.deserialize(json, KofaxRequestRiskV2.class);
	}
}
