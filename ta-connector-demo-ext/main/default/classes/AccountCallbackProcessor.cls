/**
 * @description       : 
 * @author            : Unni
 * @group             : 
 * @last modified on  : 02-14-2025
 * @last modified by  : Unni
**/
Global class AccountCallbackProcessor implements TACallbackProcessor {
    global void execute(String message) {
       System.debug(message);
        // Parse the JSON string into a Map
        Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(message);
        Account acc = new Account();
        Map<String, Object> personalInfo = (Map<String, Object>) jsonData.get('personal_info');
        Map<String, Object> address = (Map<String, Object>) personalInfo.get('address');
        Map<String, Object> bankAccountInfo = (Map<String, Object>) jsonData.get('bank_account_info');
        Map<String, Object> contactDetails = (Map<String, Object>) personalInfo.get('contact_details');

        acc.Name = (String) personalInfo.get('first_name') + ' ' + (String) personalInfo.get('last_name');
        acc.Type = (String) bankAccountInfo.get('account_type');
        acc.BillingStreet = (String) address.get('street');
        acc.BillingCity = (String) address.get('city');
        acc.BillingState = (String) address.get('state');
        acc.BillingPostalCode = (String) address.get('postal_code');
        acc.BillingCountry = (String) address.get('country');
        acc.AnnualRevenue = (Decimal) bankAccountInfo.get('initial_deposit');
        insert acc;
         // Create a new Contact object
         Contact con = new Contact();
        con.FirstName = (String) personalInfo.get('first_name');
        con.LastName = (String) personalInfo.get('last_name');
        con.Phone = (String) contactDetails.get('phone_number');
        con.Email = (String) contactDetails.get('email');
        con.AccountId = acc.Id;

        // Insert the Contact record
        insert con;
    }
}