public class SaidController {

    private static final string BASE_URL = 'https://calendarific.com/api/v2';
    private static final string API_KEY = 'd313ec8075407ffb3751179fcea76e55a84efb92';

    @AuraEnabled
    public static void saveSAId(String payload){
        saidObj payloadObj = (saidObj) JSON.deserialize(payload, saidObj.class);
        try {
            Said__c [] saidOne = [SELECT Id, Search_Count__c From Said__c WHERE Said_Number__c =: payloadObj.saidNumber LIMIT 1];
            if(saidOne.size()>0){
                saidOne[0].Search_Count__c = saidOne[0].Search_Count__c+1;
                update saidOne;
            }else{
                Said__c newSaid = new Said__c (Search_Count__c = 1, Said_Number__c = payloadObj.saidNumber, Gender__c = payloadObj.gender, Citizenship_status__c = payloadObj.citizen);
                insert newSaid;
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<HolidaysWrapper> getSaidDetails(String payload){
        try {
            saidObj payloadObj = (saidObj) JSON.deserialize(payload, saidObj.class);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(BASE_URL+'/holidays?api_key='+API_KEY+'&country=ZA&year='+payloadObj.year);
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String,Object> responseObj = (Map<String,Object>)results.get('response');
            List<Object> holis = (List<Object>) responseObj.get('holidays');
            Map<String, Object> itrHoli = new Map<String, Object> ();
            Map<String, Object> itrDate = new Map<String, Object> ();
            List<HolidaysWrapper> holidayList = new List<HolidaysWrapper>();

            for (Object x : holis) {
                HolidaysWrapper ho = new HolidaysWrapper();
                itrHoli = (Map<String, Object>)x;
                ho.name = (String)itrHoli.get('name');
                ho.description = (String)itrHoli.get('description');
                Map<String,Object> dates = (Map<String,Object>) itrHoli.get('date');
                ho.iso = (String)dates.get('iso');
                System.debug('dates ===>'+ dates);
                holidayList.add(ho);
            }
            system.debug('return value******'+ holidayList);
            return holidayList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }
    
    public class saidObj {
        @AuraEnabled public string year;
        @AuraEnabled public string saidNumber;
        @AuraEnabled public string gender;
        @AuraEnabled public string citizen;
    }

    public class HolidaysWrapper{
        @auraEnabled public String name;
        @auraEnabled public String description;
        @auraEnabled public String iso;
    }
}