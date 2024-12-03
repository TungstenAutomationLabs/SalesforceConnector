/**
 * @description       : 
 * @author            : Unni
 * @group             : 
 * @last modified on  : 12-04-2024
 * @last modified by  : Unni
**/
public with sharing class TACreateJobWithDocRequest {
    
    public String sessionId;
	public ProcessIdentity processIdentity;
	public JobWithDocsInitialization jobWithDocsInitialization;

	public class JobWithDocsInitialization {
		public List<InputVariables> InputVariables;
	    public Object StartDate;
		//public Boolean StoreFolderAndDocuments;
		public List<RuntimeDocumentCollection> RuntimeDocumentCollection;
	}


	public class RuntimeDocumentCollection {
		public Blob Base64Data;
		// public Object Data;
		// public List<DocumentGroup> DocumentGroup;
		// public String DocumentName;
		// public String DocumentTypeId;
		// public List<FieldsToReturn> FieldsToReturn;
		// public String FilePath;
		// public String FolderId;
		// public String FolderTypeId;
		// public String MimeType;
		// public List<PageDataList> PageDataList;
		// public Boolean ReturnAllFields;
		// public Boolean ReturnFullTextOcr;
		// public String RuntimeFields;
	}

	public class ProcessIdentity {
		//public String Id;
		public String Name;
	}

    public class DocumentGroup {
	}

    public class FieldsToReturn {
	}

    public class PageDataList {
	}
    public static TACreateJobWithDocRequest parse(String json) {
		return (TACreateJobWithDocRequest) System.JSON.deserialize(json, TACreateJobWithDocRequest.class);
	}
}