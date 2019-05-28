/****************************************************************************************
 * Name    : BuyTypeEventsHandler
 * Author  : Developer 
 * Date    : Oct 24, 2016 
 * Purpose : BuyTypeEventsHandler: Helper class BuyType Trigger Events

 * ---------------------------------------------------------------------------
 * MODIFICATION HISTORY:
 * DATE             AUTHOR                              DESCRIPTION
 * ---------------------------------------------------------------------------
 * 10/24/2016       Developer                             Created: Update BuyType.MakeModel
*/
public class BuyTypeEventsHandler extends TriggerHandler {
    public  static  boolean suppress_BeforeEvents   =   false;
    public  static  boolean suppress_AfterEvents    =   false;

    public override void beforeInsert(){
        /* START logic to update BuyType MakeModel */
        updateBuyTypeMakeModel();
        /* END logic to updateBuyType MakeModel */
    }

    public override void beforeUpdate(){
        /* START logic to update BuyType MakeModel */
        updateBuyTypeMakeModel();
        /* END logic to updateBuyType MakeModel */      
    }

    public override void beforeDelete(){
    }

    public override void afterInsert(){
    }

    public override void afterUpdate(){
    }
    
    /*
        Logic to update BuyType Make Model
    */
    public void updateBuyTypeMakeModel(){
        list<BuyType__c> buyTypeLst = new list<BuyType__c>();
        map<id,Vehicle_Model__c> vehModelMap = new map<id,Vehicle_Model__c>();
        set<String> vehModelIdSet = new set<String>();
        for(BuyType__c buyType : (list<BuyType__c>) Trigger.new){
            if(Trigger.oldMap == null || 
                ( buyType.Make__c <> ((BuyType__c) Trigger.oldMap.get(buyType.id)).Make__c ||
                  buyType.VehicleModel__c <> ((BuyType__c) Trigger.oldMap.get(buyType.id)).VehicleModel__c)){
                vehModelIdSet.add(buyType.VehicleModel__c);
                buyTypeLst.add(buyType);
            }
        }
        if(vehModelIdSet <> null && vehModelIdSet.size()>0){
            vehModelMap = new map<id,Vehicle_Model__c>([Select id, name from Vehicle_Model__c where id in :vehModelIdSet]);
        }
        for(BuyType__c buyType : buyTypeLst){
            String make = (buyType.Make__c <> null)? buyType.Make__c:'';
            String model = (buyType.VehicleModel__c <> null && vehModelMap.containskey(buyType.VehicleModel__c))?vehModelMap.get(buyType.VehicleModel__c).name:'';
            buyType.makeModel__c = make + '-'+ model;
        }
    }
}