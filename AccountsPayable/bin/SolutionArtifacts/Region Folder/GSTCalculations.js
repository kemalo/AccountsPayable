/*********************************************************************************************************
 *   							(c) Copyright 2011, Kemal Omar, kodeIT Solutions.
 *										www.kodeitsolutions.com.au
 * No unauthorised copying,reproduction, Distibution or replication allowed without prior consent. Any such 
 * activity can result in legal action being taken.
 * 
 * Purpose: this page performs all GST related calculations
 * 
 ********************************************************************************************************/

	/** SetupGSTScenarios-- This function initialises the form wth values from the invoice.
	 * There are number of different scenarios to considers.
	 * 1. GST only. when the GST on the Invoice = max GST that can be accrued on the invoice.
	 *	  GST Scenarios 1,2,4
	 * 2. When invoie GST is less than Max GST and and where this difference is <=$1 ( at the time of writing)
	 *	  This is a GST only scenario -- GST Scenarios 1,2,4
	 * 3. When invoice GST is greater than Max GST and where the difference is <=$1 ( at the time of writing)
	 * 	  This is GST Only Scenario.--GST Scenarios 1,2,4
	 * 4. When  Invoice GST is less than Max GST and the difference is >$1 ( at the time of writing)
	 * 	  This is categorized as mixed supply. GST and NON GST scenarios are active.--GST Scenarios 1,2,3,4
	 * 5. When invoice GST and is more than Max GST and the difference is >$1  at the time of writing)
	 * 	  This is categorized as an error and the invoice is not allowed to proceed.
	 * Note ... the invoice is also not allowed to proceed unless the header values on the invoice total up
	 *  even if the GST is not correct ( within the tolerance levels).
	 */

	 SetupGSTScenarios=function()
	{
		 /*This component now features modifications that include a GST $1 invoice tolerance. 
		  * It allows for differing GST values compared to what is supposed the actual GST value
		  * However this difference is only allowd upto a maximum of a $1.00 AUD/NZD. Also even
		  * though GST is allowed to be different the actual invoice total should still be correct.
		  * This means that in a scenario whenyo have 100.00 ExGST and 9.00 GST then the total 
		  * amount should be 109.00 and not 110.00.
		 */
		var BU = form.getCell("BU");
		var HeaderExGST = parseFloat(roundNumber(form.getCell("HeaderExGST").getValue(),2));
		var HeaderGST = parseFloat(roundNumber(form.getCell("HeaderGST").getValue(),2));
		var HeaderTotal = parseFloat(roundNumber(form.getCell("HeaderTotal").getValue(),2));
		
		
		var Applicable_GST = (GSTPercentage/100);
		var Max_GST=parseFloat(roundNumber((HeaderExGST*Applicable_GST),2)) ;
		var GST_Component_Total=parseFloat(roundNumber(HeaderGST*GST_ATTR_FACTOR,2));
		
		var calculatedTotal=parseFloat(roundNumber((HeaderGST+HeaderExGST),2)); // what the invoice total should be.
		var GSTDifference = parseFloat(roundNumber(HeaderGST-Max_GST, 2));

		//alert(HeaderGST + "::"+ HeaderExGST +"::"+HeaderTotal+"::"+calculatedTotal+"::"+ Max_GST+"::"+ GSTDifference);
		
	
		if(calculatedTotal!=HeaderTotal || calculatedTotal==0)
		{
			if( form.getCell("DocumentType").getValueAsString()==DOC_STANDARD_INVOICE){alert ("There is an error with the Total Payable amount. Please send to Verify to correct Invoice header summary totals.");}
			if( form.getCell("DocumentType").getValueAsString()!=DOC_STANDARD_INVOICE){alert ("There is an error with the Total Payable amount. Please correct Invoice header summary totals.");}
			form.getCell("HeaderTotal").setValue(new Value(0.00));
			return -1;
		}

		/*Non GST - GST3 only
		 * There is no GST on the Invoice. The whole invoice is NON GST based.
		 * i.e. No part of the invoice attracts GST
		 */
		if (HeaderGST==0 && ((form.getCell("F_StepName").getValueAsString()==STEP_PREPARE) ||(form.getCell("F_StepName").getValueAsString()==STEP_VERIFY)||(form.getCell("F_StepName").getValueAsString()==STEP_LAUNCH)))
		{

			//Lock all GSTScenarios but 3
			alert ("GST Scenarios (GST Lines) 1,2 and 4 will be disabled as there is no GST on the invoice. You will only be able to add entries for the non GST component of the invoice -- GST Scenario 3.");
			form.getCell("ScenarioTotal1").setValue(new Value(HeaderTotal));
			enableGST3();
			form.setCurrentPage(form.getPage("GSTScenario3"));
			
		}else
		{
			/* There are GST Scenraios as well*/ 
			enableAllGSTScenarios()	
		}
		
		/* All scenarios could be active (1,2,3,4) or just GST attracting Scenarios. ( 1,2,4)
		 * So let 's determine whether we are in the tolerance range first.
		 * 
		 * If the invoice GST is greater than the maximum tolerance, then stop 
		 * the invoice from being processed. But allow invoice to be corrected
		 * 
		 */ 
		
		if ((GSTDifference>maxInvoiceGSTTolerance) && (GSTDifference>0))
		{
			if(form.getCell("F_StepName").getValueAsString()==STEP_PREPARE && form.getCell("DocumentType").getValueAsString()==DOC_STANDARD_INVOICE)
			{
				alert ("The Invoice GST amount is incorrect. It is greater than the $1.00 tolerance allowed. The invoice will be sent be sent to the Verify queue");
				form.getCell("UserComment").setValueFromString("Incorrect GST header Information. Invoice automatically sent to Verify");
				form.getCell("F_Responses").setValueFromString(ACTION_VERIFY);
				
				complete();
				return -1;
			}else if(((form.getCell("F_StepName").getValueAsString()==STEP_LAUNCH) ||
					(form.getCell("F_StepName").getValueAsString()==STEP_PREPARE)) 
					&& form.getCell("DocumentType").getValueAsString()!=DOC_STANDARD_INVOICE)
			
			// Read STEP_Launch as launch step for Petty Cash and reimbursements forms... Since standard invoices are not launched manually.
			{
				alert ("The Invoice GST amount is incorrect. It is greater than the $1.00 tolerance allowed. Please correct the value before you proceed.");
				form.getCell("HeaderTotal").setValue(new Value(0.00));
				form.getCell("HeaderGST").setValue(new Value(0.00));
				form.getCell("ScenarioTotal1").setValue(new Value(0.00));
			}

			if(form.getCell("F_StepName").getValueAsString()==STEP_VERIFY)
			{
				alert ("The Invoice GST amount is incorrect. Please correct before proceeding.");
				form.getCell("HeaderTotal").setValueFromString("");
				form.getCell("ScenarioTotal1").setValueFromString("");
			}
		}

		/*WITHIN TOLERANCE 
		 * If the GST is < or > than the calculable value but within the invoice gst tolerance.
		 *  this default this as a purely GST 1 scenario. User can always distrib across 
		 * other scenarios later.
		 * So apply the inovice's HeaderExGST value to GST Line 1
		 */ 
		
		if ((Math.abs(GSTDifference)<=maxInvoiceGSTTolerance) && HeaderGST!=0 && GST_Component_Total!=HeaderExGST)
		{
			alert ("GST Scenario 3 will be disabled as there is no NON-GST component on the invoice. The invoice is within a $1.00 tolerance set by the business. Only entries for the GST components of the invoice -- GST Scenario 1,2,4 will be allowed.");
			//Apply ExGST value to Scenario 1 
			form.getCell("ScenarioTotal1").setValue(Value(HeaderExGST));
			disableGST3();
		}
		
		
		/* MIXED SUPPLY
		 * if it is a mixed supply (GST and Non GST)and where invoice GST values are 
		 * less than Max_GST and where the GSTDifference > Invoice GST tolerance value
		*/
	
		if ((HeaderGST<Max_GST) && (GSTDifference<minInvoiceGSTTolerance) && HeaderGST!=0)
		{
			
			if ((Max_GST!=0) &&((form.getCell("F_StepName").getValueAsString()==STEP_PREPARE) ||(form.getCell("F_StepName").getValueAsString()==STEP_VERIFY)||form.getCell("F_StepName").getValueAsString()==STEP_LAUNCH))
			// Read STEP_Launch as launch step for Petty Cash and reimbursements forms... Since invoices are not launched manually.
			{
				if (HeaderGST !=0) // if GST <> zero then say so otherwise it's been said already
				{
					alert ("Please note that all GST Scenarios (1,2,3,4) are applicable to this Invoice.");		
				}
					form.setNotification("Defaulting GST Scenario values...");
				//Add the Attracting GST Component total to scenario 1 ...Scenario defaulting... Note this is ex GST
				form.getCell("ScenarioTotal1").setValue(Value(GST_Component_Total));
				
			// Now add the NON_GST_Component_Total to Scenario 3
				form.setNotification("Defaulting Non-GST Scenario values...");
				NON_GST_Component_Total=HeaderTotal-GST_Component_Total-HeaderGST;
				form.getCell("ScenarioTotal3").setValue(Value(NON_GST_Component_Total));
				
				//Add the non GST Component to scenario 3 ...Non-GST Component = Total - GST Component... So GST Component =
				form.setNotification("");
				
				
			}
		}

		/* GST ONLY
		 * This is not a mixed supply. The whole invoice attracts GST scenarios (1,2,4) only apply to the inovice.
		 * Here the Max_GST = GST on invoice.
		 * 
		*/		

		if (HeaderGST==Max_GST && GST_Component_Total==HeaderExGST &&((form.getCell("F_StepName").getValueAsString()==STEP_PREPARE) ||(form.getCell("F_StepName").getValueAsString()==STEP_VERIFY)||(form.getCell("F_StepName").getValueAsString()==STEP_LAUNCH)))
		{
			alert ("GST Scenario 3  ( GST Line 3) will be disabled as there is no NON-GST component on the invoice. You will only be able to add entries for the GST components of the invoice -- GST Scenario 1,2,4");
			form.getCell("ScenarioTotal1").setValue(Value(GST_Component_Total)); 
			//Lock GSTScenario  3
			disableGST3();
			
		}		
	
	}

	/** this function initiliases some GST percentage number  factors) that 
	 * are required to carry out GST calculations
	 * GSTPercentage - the GST percentage that is relevant to the country of the invoice.
	 * EXGST_FACTOR - Used to calculate the proper GST component of the invoice
	 * GST_ATTR_FACTOR - Used to calculate the Total value of the  Component of the invoice that attracts GST
	 */ 
	function InitialiseGSTValues() 
	{
		getGSTPercentage();
			GSTPercentage = parseFloat(form.findCell("GSTPercentage").getValueAsString());
			EXGST_FACTOR= 100/(100 +GSTPercentage); //Used to calculate the proper GST component of the invoice.
			GST_ATTR_FACTOR=(100/GSTPercentage);
			if (SetupGSTScenarios()==-1)
			{
					return -1;
			}else
			{
				return 0;
			}
	}


	/** This function retrieves the correct GST Percentage of the invoice based on the country of origin of the invoice and the Business Unit that the invoice is applied to.*/ 	
	function getGSTPercentage() 
	{
	
		var myCell = form.findCell("GSTPercentage");
		var myResponse = myCell.doLookup();
		var myDataArray = myResponse.getData();
		var theResponse=myResponse.getType();
		var myData;
		var i;

		if(myDataArray.length!=0)
		{
			myCell.setValue(myDataArray[0].getValue("GSTPercentage"));// There should only be one result for this sort of query anyway
		}else{
			alert("Please ensure that the AP Business Unit is correct. The system cannot locate the correct GST Percentage for the current Vendor");
			form.getCell("BU").setValueFromString("INVLD");
		}
	}

	/**
	 * This function retrieves some default GST Scenario information based on the distribution 
	 * information that is selected by the users
	 * 
	 */ 
	function getGSTScenarioValues()
	{
	//Clear the fields first
		form.getCell("GSTScenario").clear();
		form.getCell("GSTUseID").clear();
		form.getCell("GSTApplicability").clear();
		form.getCell("GSTTaxCDVat").clear();
		form.getCell("GSTTransactionType").clear();
		form.commit()
	

	// Note each table corresponds to a scenario
		for(tableid=1; tableid<=4; tableid++)
		{
			//get the rowcount first to determine if the scenario has any rows... It will qualify ashaving rows if OU field is NOT empty
			var therow=getCurrentFirstEmptyRow("OU",tableid);
			
			
			if (getCurrentFirstEmptyRow("OU",tableid)>0){
				/** Now go and retrieve GST information.
					set the DB Query params
					If it's Scenario 1 then get TransactionType value from Scen1TransactionType otherwise 
					don't worry about transactiontype **/
				
				var valTransType;
				if(tableid===1){
					var transType=form.getCell("Scen" +tableid+"TransactionType");
					form.getCell("DB_GSTTXNType").setValueFromString(form.getCell("Scen" +tableid+"TransactionType").getValueAsString()+"%");
					
					
				}else{
					valTransType="%";
					form.getCell("DB_GSTTXNType").setValueFromString("%");
				}
				/**Now setting other fields**/
				
				form.getCell("DB_GSTScenario").setValueFromString(tableid.toString());

				var mysearchfield=form.getCell("DB_GSTScenario");
				
				/**Now execute the Query**/
				form.commit();
				var myResponse = mysearchfield.doLookup();
				
				var myDataArray = myResponse.getData();
				var theResponse=myResponse.getType();
				var myData;
				var i;
				
				if (myDataArray.length!=0)
				{
					/** Now set the GST Scenario fields of the line item**/
					form.getCell("GSTScenario").setValueFromString(form.getCell("DB_GSTScenario").getValueAsString(),tableid-1);
					form.getCell("GSTUseID").setValue(myDataArray[0].getValue("DB_GSTUseID"),tableid-1);
					form.getCell("GSTApplicability").setValue(myDataArray[0].getValue("DB_GSTApplicability"),tableid-1);
					form.getCell("GSTTaxCDVat").setValue(myDataArray[0].getValue("DB_GSTTaxCDVat"),tableid-1);
					form.getCell("GSTTransactionType").setValue(myDataArray[0].getValue("DB_GSTTXNType"),tableid-1);
					form.commit()
				}				
			}else{  
				//alert("There are no rows in this table" + tableid);
			}
		}
	}

	
/** The following set of functions are used to retrieve data 
 * using xmlHTTP and JSON object model to query GST related Config data 
 * from the APOnline DB
 *  Starts here **/
 
 //Creates and xmlHTTPRequest object that is supported by the browser
function createXMLHttpRequest()
{
  if( typeof XMLHttpRequest == "undefined" ) XMLHttpRequest = function() {
    try { return new ActiveXObject("Msxml2.XMLHTTP.6.0") } catch(e) {}
    try { return new ActiveXObject("Msxml2.XMLHTTP.3.0") } catch(e) {}
    try { return new ActiveXObject("Msxml2.XMLHTTP") } catch(e) {}
    try { return new ActiveXObject("Microsoft.XMLHTTP") } catch(e) {}
    throw new Error( "This browser does not support XMLHttpRequest." )
  };
  return new XMLHttpRequest();
}

//Callack function that retrieves the info from the JSON object
function getToleranceInfoHandler() 
{

  if(AJAX.readyState == AJAX_LOADED && AJAX.status == AJAX_STATUS_SUCCESS) {
      JSON = eval('(' + AJAX.responseText +')');
	  maxInvoiceGSTTolerance = roundNumber(JSON.maxInvoiceGSTTolerance,2);
	  minInvoiceGSTTolerance =roundNumber(JSON.minInvoiceGSTTolerance,2);
	  minGSTLineDiff=roundNumber(JSON.minGSTLineDiff,2);
	  maxGSTLineDiff=roundNumber(JSON.maxGSTLineDiff,2);
	 //alert (minInvoiceGSTTolerance + " : " + maxInvoiceGSTTolerance + " : " + minGSTLineDiff + " : " + maxGSTLineDiff);
  }else if (AJAX.readyState == AJAX_LOADED && AJAX.status != AJAX_STATUS_SUCCESS) {
    alert('Something went wrong retrieving GST tolerance data... If this situation persists please contact your systems administrator.');
  }
}

function getDBToleranceData()
{
	AJAX = createXMLHttpRequest();
	AJAX.onreadystatechange = getToleranceInfoHandler; // specifies the callback function that handles the retrieved data
	AJAX.open("GET", "GetDBData.jsp",AJAX_SYNCHRONOUS); // Sends request to Server side jsp to which queries database.
	AJAX.send("");
}

/** ends here  **/
	
