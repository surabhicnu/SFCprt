global class ClaimCalculatePercentage {
    public UK_Claims__c objClaim{get;set;}
    public string claimid {get; set;}
    public List<UK_Claims__c> lstClaim {get;set;}
    
    public ClaimCalculatePercentage(ApexPages.StandardController stdcontroller) {
        this.objClaim =(UK_Claims__c)stdController.getRecord();
        lstClaim = new List<UK_Claims__c>();
        
            
    }
    
    Webservice static String calculate(String cid)
    {
        String result;
        List<UK_Claims_SalvagePercentage__c> lstcs = new List<UK_Claims_SalvagePercentage__c>();
        
        
        UK_Claims__c updateC = new UK_Claims__c();
         if(cid != null)
         {
            List<UK_Claims__c> lstClaim = [Select id, Salvage_Accepted__c, Value_of_offer_Accepted__c, Seller_Codes__c, Seller__c, Seller__r.Name, Vehicle_Type__c, Category__c, Valuation__c, PAV__c, Salvage__c from UK_Claims__c where id =:cid limit 1];
            if(lstClaim.size() > 0)
                updateC = lstClaim[0];
         } 
         if(updateC.Salvage_Accepted__c == 'Y')  
         {
            if(updateC.Seller__c != null && updateC.Category__c != null && updateC.Value_of_offer_Accepted__c != null)
            {
                lstcs = [Select id, Name, Catagory__c, End_Range__c, Salvage_Percentage__c, Start_Range__c, Vehicle_Type__c from UK_Claims_SalvagePercentage__c where Name =: updateC.Seller__r.Name and Catagory__c =: updateC.Category__c];
                system.debug(' **********'+lstcs);
                if(lstcs.size() > 0)
                {
                    for(UK_Claims_SalvagePercentage__c p: lstcs)
                    {
                       if(p.Start_Range__c <= updateC.Value_of_offer_Accepted__c && (updateC.Value_of_offer_Accepted__c <= p.End_Range__c || p.End_Range__c == 0))
                       {
                           if(updateC.Seller__r.Name == 'Eldon' && (updateC.Vehicle_Type__c == 'C Motorcycle/ATV' || updateC.Vehicle_Type__c == 'B Commercial Under 7.5 Tonnes' || updateC.Vehicle_Type__c == 'V Vehicle Under 7.5 Tonnes'))
                           {    
                               if(updateC.Vehicle_Type__c == 'C Motorcycle/ATV' && p.Vehicle_Type__c == 'Bikes') 
                                   updateC.Salvage__c = p.Salvage_Percentage__c; 
                               if((updateC.Vehicle_Type__c == 'B Commercial Under 7.5 Tonnes' || updateC.Vehicle_Type__c == 'V Vehicle Under 7.5 Tonnes') && p.Vehicle_Type__c == 'Under 7.5') 
                                   updateC.Salvage__c = p.Salvage_Percentage__c;     
                           }
                           else if((updateC.Vehicle_Type__c == p.Vehicle_Type__c) ||
                           			(updateC.Vehicle_Type__c == 'V Vehicle Under 7.5 Tonnes' && 
                           			(p.Vehicle_Type__c == 'Under 7.5' || 
                           			 p.Vehicle_Type__c == '' || 
                           			 p.Vehicle_Type__c == null))){
                               updateC.Salvage__c = p.Salvage_Percentage__c;
                           }
                       }
                       system.debug('updateC.Salvage__c **********'+updateC.Salvage__c );
                    }
                    update updateC;
                }
                
                result = 'Percentage calculated successfully';
            }
            else
                result = 'Please fill all mandatory fields.';
        }
        else
            result = 'Salvage has not been accepted.';
        
        return result;
    }
}