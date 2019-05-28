public class ClaimsendEmailandGenerate {

public UK_Claims__c objClaim {get;set;}
public String cid {get;set;}
public Boolean result {get;set;}
public Boolean isSellerEldon {get;set;}
public datetime dt {get; set;}
public String offerDate {get; set;}
public Boolean pdf {get;set;}

    public ClaimsendEmailandGenerate(ApexPages.StandardController controller) {
        this.objClaim = (UK_Claims__c)controller.getRecord();
        this.objClaim = [Select id, Salvage_Amount__c, Pdf_Sent__c, Seller__c, Seller__r.Name, Personal_pdf_sent__c, Settlement_pdf_sent__c, Salvage_Settlement_pdf_sent__c, Settlement_with_Retention_pdf_sent__c , Swift_Settlement_Pdf_sent__c, Unable_to_contact_pdf_sent__c, Offer_Accepted_DateTime__c, Title__c, Full_Name__c, Street__c, City__c, State__c, PostCode__c, Copart_Lot_Number__c, Claim_Number__c, VehicleMake__c, Vehicle_Model__c, VRN_Number__c, Less_Excess__c, Value_of_offer_Accepted__c From UK_Claims__c where id=:objClaim.id limit 1];
        
        if(objClaim != null)
        {
            cid = objClaim.id;
            dt = objClaim.Offer_Accepted_DateTime__c;
            if(dt != null)
            offerDate = dt.format('dd/MM/yyyy');
            
            //if(objClaim.Pdf_Sent__c == true)
            //    pdf = true;
            
            if(objClaim.Seller__c != null)
            {
            if(objClaim.Seller__r.Name.contains('Eldon'))
                isSellerEldon = true;
            else
                isSellerEldon = false;
          }      
        }  
        
    }
    
    public PageReference generatePersonalLetter()
    {
        PdfEmailController objPdf = new PdfEmailController();
        result = objPdf.sendPdf(cid, 'UkPersonalPdf');
        if(result == true)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with PDF has sent to and generated in attachments'));
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Some error occured, email not sent.'));    
        string claimURL = '/'+cid+'?inline=0';
        PageReference pr = new PageReference(claimURL);
        return pr;
    }
    
    public PageReference generateSettlementOffer()
    {
        PdfEmailController objPdf = new PdfEmailController();
        result = objPdf.sendPdf(cid, 'UkSettlementOffer');
        if(result == true)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with PDF has sent to and generated in attachments'));
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Some error occured, email not sent.'));    
        string claimURL = '/'+cid+'?inline=0';
        PageReference pr = new PageReference(claimURL);
        return pr;
    }
    
    public PageReference generateSalvageLetter()
    {
        PdfEmailController objPdf = new PdfEmailController();
        result = objPdf.sendPdf(cid, 'UkSalvageSettlement');
        if(result == true)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with PDF has sent to and generated in attachments'));
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Some error occured, email not sent.'));    
        string claimURL = '/'+cid+'?inline=0';
        PageReference pr = new PageReference(claimURL);
        return pr;
    }
    
    public PageReference generateSwiftSettlement()
    {
        PdfEmailController objPdf = new PdfEmailController();
        result = objPdf.sendPdf(cid, 'UkSwiftSettlement');
        if(result == true)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with PDF has sent to and generated in attachments'));
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Some error occured, email not sent.'));    
        string claimURL = '/'+cid+'?inline=0';
        PageReference pr = new PageReference(claimURL);
        return pr;
    }
    
    public PageReference generateRetentionSalvage()
    {
        PdfEmailController objPdf = new PdfEmailController();
        result = objPdf.sendPdf(cid, 'UkRetentionSalvage');
        if(result == true)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with PDF has sent to and generated in attachments'));
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Some error occured, email not sent.'));    
        string claimURL = '/'+cid+'?inline=0';
        PageReference pr = new PageReference(claimURL);
        return pr;
    }
    
    public PageReference generateUnableToLetter()
    {
        PdfEmailController objPdf = new PdfEmailController();
        result = objPdf.sendPdf(cid, 'UK_UnableTo_Valuation');
        if(result == true)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with PDF has sent and generated in attachments'));
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Some error occured, email not sent.'));    
        string claimURL = '/'+cid+'?inline=0';
        PageReference pr = new PageReference(claimURL);
        return pr;
    }
    
    public PageReference generateEldonSettlementOffer()
    {
        PdfEmailController objPdf = new PdfEmailController();
        result = objPdf.sendPdf(cid, 'UK_eldon_Settlement_Offer');
        if(result == true)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with PDF has sent and generated in attachments'));
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Some error occured, email not sent.'));    
        string claimURL = '/'+cid+'?inline=0';
        PageReference pr = new PageReference(claimURL);
        return pr;
    }
    
    public PageReference generateEldonSettlementFinal()
    {
        PdfEmailController objPdf = new PdfEmailController();
        result = objPdf.sendPdf(cid, 'UkSettlementFinalPdf');
        if(result == true)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with PDF has sent and generated in attachments'));
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Some error occured, email not sent.'));    
        string claimURL = '/'+cid+'?inline=0';
        PageReference pr = new PageReference(claimURL);
        return pr;
    }
    
    public PageReference generateEldonSettlementPolicyValue()
    {
        PdfEmailController objPdf = new PdfEmailController();
        result = objPdf.sendPdf(cid, 'UK_Eldon_Settlement_Value_Limit');
        if(result == true)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with PDF has sent and generated in attachments'));
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Some error occured, email not sent.'));    
        string claimURL = '/'+cid+'?inline=0';
        PageReference pr = new PageReference(claimURL);
        return pr;
    }
    
    public PageReference generateEldonUnabletoContact()
    {
        PdfEmailController objPdf = new PdfEmailController();
        result = objPdf.sendPdf(cid, 'UKEldonUnabletoContact');
        if(result == true)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with PDF has sent and generated in attachments'));
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Some error occured, email not sent.'));    
        string claimURL = '/'+cid+'?inline=0';
        PageReference pr = new PageReference(claimURL);
        return pr;
    }
    
    public PageReference generateEldonUnabletoValuation()
    {
        PdfEmailController objPdf = new PdfEmailController();
        result = objPdf.sendPdf(cid, 'UKEldonUnabletoValuation');
        if(result == true)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Email with PDF has sent and generated in attachments'));
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Some error occured, email not sent.'));    
        string claimURL = '/'+cid+'?inline=0';
        PageReference pr = new PageReference(claimURL);
        return pr;
    }
    
    public void updatePdfStatus()
    {
        
        if(objClaim.Pdf_Sent__c == true)
        {
            objClaim.Pdf_Sent__c = false;
            update objClaim;
            pdf = true;
        }
        else
            pdf = false;
        system.debug('*****************'+objClaim.Pdf_Sent__c);
    }
    
}