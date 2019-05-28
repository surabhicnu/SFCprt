/****************************************************************************************
 * Name    : CDWrapper 
 * Author  : Venkat
 * Date    : Oct 06, 2017 
 * Purpose : Wrapper class for CD Sell for Individual

 * ---------------------------------------------------------------------------
 * MODIFICATION HISTORY:
 * DATE             AUTHOR                              DESCRIPTION
 * ---------------------------------------------------------------------------
 * 10/06/2017       Venkat                               Created
 
*/
Global class CDWrapper{
    Global Class CDCreateLeadRequest{
        public string vehicleYear;
        public string vehicleMake;
        public string vehicleModel;
        public Integer approxMilesRun;
        public string isLoaned;
        public string firstName;
        public string lastName;
        public string phoneNumber;
        public string eMailID;
        public string zipPostalCode;
        public string referralCode;
        public string recordTypeId;
        
        /*
        public string year;
        public string make;
        public string model;
        public Integer miles;
        public string loanOnVehicle;
        //public string firstname;
        //public string lastname;
        //public string phonenumber;
        public string email;
        public string zipcode;
        //public string referralcode;
        */
        public CDCreateLeadRequest(){
	        vehicleYear = null;
	        vehicleMake = null;
	        vehicleModel = null;
	        approxMilesRun = 0;
	        isLoaned  = null;
	        firstName = null;
	        lastName = null;
	        phoneNumber = null;
	        eMailID = null;
	        zipPostalCode = null;
	        referralCode = null;
	        recordTypeId = null;
            /*    	 
            year            = null;
            make            = null;
            model           = null;
            miles           = 0; 
            loanOnVehicle   = null;
            firstname       = null; 
            lastname        = null;
            phonenumber     = null;
            email           = null;
            zipcode         = null;
            referralCode    = null;
            */
        }
    }
    Global Class CDCreateLeadResponse{
        public string leadId;
        public string errorMessage;
        public string status;
        public  CDCreateLeadResponse(){
            leadId         = null;
            errorMessage   = null;
            status         = null; 
        }
    }
}