@RestResource(urlMapping='/BuyTypeServices/*')
Global class BuyTypeServices{

    Global class BuyTypeRequest{
        Global Integer year;
        Global String  make;
        Global String  model;
    }

    Global class BuyTypeResponse{
        Global Integer year;
        Global String  make;
        Global String  model;
        Global String  buyType;
        Global String  Status;
        Global String  errorMessage;
    }

    @HttpGet
    Global static BuyTypeResponse calculateBuyType(){
        BuyTypeResponse buyTypeResponse = new BuyTypeResponse();
        BuyTypeRequest buyTypeRequest = new BuyTypeRequest();
        String year;
        /* START REST Request Parameters */
        if(RestContext.request.params.get('make') <> NULL){
            buyTypeRequest.make = RestContext.request.params.get('make');
        }
        if(RestContext.request.params.get('model') <> NULL){
            buyTypeRequest.model = RestContext.request.params.get('model');
        }
        if(RestContext.request.params.get('year') <> NULL){
            Integer yr;
            try{
                year = RestContext.request.params.get('year');
                yr = Integer.valueof(year);
            } catch(Exception e){System.debug('Exception when converting year to integer e : ' + e.getMessage()); }
            buyTypeRequest.year = yr;
        }        
        /* END REST Request Parameters   */

        if(buyTypeRequest <> null){
            buyTypeResponse.year  = buyTypeRequest.year;
            buyTypeResponse.make  = buyTypeRequest.make;
            buyTypeResponse.model = buyTypeRequest.model;
            String  mk           = (buyTypeRequest.make  <> null) ? buyTypeRequest.make.trim()  : '';
            String  mdl          = (buyTypeRequest.model <> null) ? buyTypeRequest.model.trim() : '';
            String  mkModel      = (mk + '-'+ mdl).trim().toLowerCase(); 
            buyTypeResponse.errorMessage = '';
            buyTypeResponse.buyType   = null;

            /* Retrieves BuyType and adds to makeModelBuyTypeMap */
            if(!(mkModel == null || mkModel == '')){
                list<buyType__c> buyTypeLst = [select isjunk__c,IsAuction__c,AuctionYearFrom__c,GreyYearFrom__c,GreyYearTo__c,Make__c,VehicleModel__c,name,MakeModel__c from BuyType__c where makeModel__c = :mkModel limit 1];
                for(BuyType__c buyType : buyTypeLst){
                    buyTypeResponse.buyType = (buyType.isAuction__c)?'Auction':((buyType.isJunk__c)?'Junk':buyTypeResponse.buyType);
                    if(!(buyType.isAuction__c || buyType.isJunk__c)){
                        Integer greyYearFrom    = 0;
                        Integer greyYearTo      = 0;
                        Integer auctionYearFrom = 0;
                        if(buyTypeRequest.year  == null){
                            buyTypeResponse.errorMessage += 'Invalid year : ' + year + '. \n';
                        }
                        if(buyTypeResponse.errorMessage == null || buyTypeResponse.errorMessage == ''){
                            //try { buyTypeRequest.year = Integer.valueOf(ld.year__c.trim());} catch(Exception e){}
                            try { auctionYearFrom = Integer.valueOf(buyType.AuctionYearFrom__c.trim());} catch(Exception e){}
                    
                            if(buyType.GreyYearFrom__c <> null && buyType.GreyYearTo__c <> null){
                                try { greyYearFrom = Integer.valueOf(buyType.GreyYearFrom__c.trim());} catch(Exception e){}
                                try { greyYearTo   = Integer.valueOf(buyType.GreyYearTo__c.trim());} catch(Exception e){}
                                if(buyTypeRequest.year >= greyYearFrom && buyTypeRequest.year <= greyYearTo){
                                    buyTypeResponse.buyType = 'Grey';
                                }
                                else if(buyType.AuctionYearFrom__c <> null && buyTypeRequest.year >= auctionYearFrom){
                                    buyTypeResponse.buyType = 'Auction';
                                }
                                else{
                                    buyTypeResponse.buyType = 'Junk';
                                }
                            }
                            else if(buyType.AuctionYearFrom__c <> null && buyTypeRequest.year >= auctionYearFrom){
                                buyTypeResponse.buyType = 'Auction';
                            }
                            else{
                                buyTypeResponse.buyType = 'Junk';
                            }
                            system.debug('buyType.GreyYearFrom__c : ' + buyType.GreyYearFrom__c + ' greyYearFrom : ' + greyYearFrom);
                            system.debug('buyType.GreyYearTo__c : ' + buyType.GreyYearTo__c + ' greyYearTo : ' + greyYearTo);
                            system.debug(' buyTypeRequest.year : ' + buyTypeRequest.year);
                            system.debug('buyType.AuctionYearFrom__c : ' + buyType.AuctionYearFrom__c + ' auctionYearFrom : ' + auctionYearFrom);
                        }
                    }
                }
                if(buyTypeLst == null || buyTypeLst.size() == 0){
                    buyTypeResponse.errorMessage += 'Matching buyType not found for make : ' + buyTypeRequest.make + ' model : ' + buyTypeRequest.model + '.\n';
                }
                
                if(buyTypeResponse.buyType == null && buyTypeRequest.year >= 2005)
                    buyTypeResponse.buyType = 'Auction';
            }
            else{
                buyTypeResponse.errorMessage += 'Invalid Request : ' + buyTypeRequest + '. \n';
            }
        }
        else{
            buyTypeResponse.errorMessage += 'Invalid Request : '     + buyTypeRequest + ', \n';
        }
        buyTypeResponse.Status = (buyTypeResponse.errorMessage == null || buyTypeResponse.errorMessage == '')? 
                                    'Success':'Failure';
        
        return buyTypeResponse;
    }
}