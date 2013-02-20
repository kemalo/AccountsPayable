<!--
********************************************************************************************************************									
  							(c) Copyright 2011, Kemal Omar, kodeIT Solutions.
									www.kodeitsolutions.com.au
	No unauthorised copying,reproduction, Distibution or replication allowed without prior consent. Any such 
	activity can result in legal action being taken.
	Purpose : This file acts as the form's main region source file.
				see  workflow policy --Step --advanced options --region layout
*********************************************************************************************************************
-->
<%
response.setHeader("Cache-Control","no-cache"); //HTTP 1.1
response.setHeader("Pragma","no-cache"); //HTTP 1.0
response.setDateHeader ("Expires", 0); //prevents caching at the proxy server
%>
<%//@ page import="filenet.vw.api.*"%>
<%@page import="java.util.Properties" %>
<%@ page import="java.io.*" %>
<%@ page errorPage="/WcmError.jsp"
   import="com.filenet.wcm.apps.server.util.*,com.filenet.wcm.toolkit.server.base.*,com.filenet.wcm.toolkit.server.util.WcmServerCredentials,com.filenet.wcm.toolkit.server.util.WcmDataStore,java.util.*"%>
<jsp:useBean id="controller"
   class="com.filenet.wcm.apps.server.controller.WcmWorkplaceController"
   scope="request">
</jsp:useBean>

<%@page import="com.filenet.wcm.toolkit.util.WcmEncodingUtil"%>
<%@page import="java.net.URLEncoder"%>

<html>
<head>
<link rel="stylesheet" href="APOnline.css" type="text/css">

<script language="JavaScript" src="../forms/misc/eforms-factory.js"></script>
<script language="JavaScript" src="../regions/Declarations.js"></script>
<!-- Contains all global variable and object declarations -->
<script language="JavaScript" src="../regions/Utilities.js"></script>
<!-- Contains all utility functions-->
<script language="JavaScript" src="../regions/GSTCalculations.js"></script>
<!-- Contains  GST calculations-->

<%
	controller.configurePage(application, request, WcmController.NO_WINDOW_ID);
	WcmDataStore dataStore = controller.getDataStore();
	WcmServerCredentials credentials = dataStore.getServerCredentials();
	String usernameA = credentials.getUserId();
	String username = usernameA.replace("'","\\'");
	
	out.print(username);
	 	Properties props = new Properties();
	props.load(new FileInputStream(request.getRealPath("/regions/aponline.properties")));
	String BaseURL=props.getProperty("BaseURL");
	String helpFile=props.getProperty("helpFile");
			
%>


<script language="JavaScript">

/************************ Initialisation starts here *********************************************/	
	form.OnLoad.add(initHandler);
	function initHandler()
	{
		//try{
		//initialize the current user
				form.setNotification("Initializing Form Data");

				loggedInUser='<%=username%>';
				
				BaseURL='<%=BaseURL%>';
				
				form.findCell("CurrentUser").setValueFromString(loggedInUser);
				form.commit;
				cmdComplete=form.findCommand("dispatch");
				
				// ****************** test Fields ******************************	
				//		var testButton = form.findButton("testButton");
				//	testButton.OnClick.add(function() {fntestButton(); });
				// ****************** Hidden Fields ******************************	
			
				var selectedWindow=form.findCell("selectedWindow");
				selectedWindow.setValue(new Value(false));
				
				//Initializing the form with the various control objects
				
				// ****************** Buttons  ******************************	
				var btnAccount1 = form.findButton("btnAccount1");
				btnAccount1.OnClick.add(function() {showsrchAccount(1); });
				var btnAccount2 = form.findButton("btnAccount2");
				btnAccount2.OnClick.add(function() {showsrchAccount(2); });
				var btnAccount3 = form.findButton("btnAccount3");
				btnAccount3.OnClick.add(function() {showsrchAccount(3); });
				var btnAccount4 = form.findButton("btnAccount4");
				btnAccount4.OnClick.add(function() {showsrchAccount(4); });

				var btnOU1 = form.findButton("btnOU1");
				btnOU1.OnClick.add(function() {showsrchOU(1); });		
				var btnOU2 = form.findButton("btnOU2");
				btnOU2.OnClick.add(function() {showsrchOU(2); });		
				var btnOU3 = form.findButton("btnOU3");
				btnOU3.OnClick.add(function() {showsrchOU(3); });		
				var btnOU4 = form.findButton("btnOU4");
				btnOU4.OnClick.add(function() {showsrchOU(4); });		

				var btnProject1 = form.findButton("btnProject1");
				btnProject1.OnClick.add(function() {showsrchProject(1); });		
				
				var btnProject2 = form.findButton("btnProject2");
				btnProject2.OnClick.add(function() {showsrchProject(2); });		
				var btnProject3 = form.findButton("btnProject3");
				btnProject3.OnClick.add(function() {showsrchProject(3); });		
				var btnProject4 = form.findButton("btnProject4");
				btnProject4.OnClick.add(function() {showsrchProject(4); });

				
				var btnDOA = form.findButton("btnDOA");
				btnDOA.OnClick.add(function() {fnDOA(); });
				
				var btnComplete=form.findButton("btnComplete");
				btnComplete.OnClick.add(function() {complete(); });

				var btnHelp=form.findButton("btnHelp");
				btnHelp.OnClick.add(function() {help(); });

				var btngetXLS1=form.findButton("btngetXLS1");
				btngetXLS1.OnClick.add(function() {UploadXL(1); });
				var btngetXLS2=form.findButton("btngetXLS2");
				btngetXLS2.OnClick.add(function() {UploadXL(2); });
				
				var btngetXLS3=form.findButton("btngetXLS3");
				btngetXLS3.OnClick.add(function() {UploadXL(3); });		
				var btngetXLS4=form.findButton("btngetXLS4");
				btngetXLS4.OnClick.add(function() {UploadXL(4); });
				
				var btnFileBrowser=form.findButton("btnFileBrowser");
				btnFileBrowser.OnClick.add(FileBrowse);

				// ****************** header Fields ******************************	
					
				//var fldHeaderBU=form.findCell("BU");
				//fldHeaderBU.OnChange.add(UpdateBU);
				
				var fldUserComment=form.findCell("UserComment");
				fldUserComment.OnFocus.add(fnUserComment);

				//this seems to be no onger required 
				VendorSetID=form.findCell("VendorSetID")
				VendorSetID.OnChange.add(SetID_Change);
				VendorSetID.OnBlur.add(SetID_Change);

				VendorID=form.findCell("VendorID")
				VendorID.OnChange.add(SetID_Change);
				VendorID.OnBlur.add(SetID_Change);
				
				var Reviewers=form.findCell("Reviewers");
				Reviewers.OnFocus.add(fngetReviewerIndex);

				var Reviewers=form.findCell("Reviewers");
				Reviewers.OnBlur.add(fngetReviewer);

				
				var fldHeaderTotal=form.findCell("HeaderTotal");
				fldHeaderTotal.OnBlur.add(fnInvoiceValues);

				// ****************** Table Fields ******************************	

				// ****************** GLAccount ******************************		
				var fldGLBU1 = form.findCell("GLBU1");
				fldGLBU1.OnBeforeChange.add(function() {fnGLBUOnBeforeChange(1); });

				var fldGLBU2 = form.findCell("GLBU2");
				fldGLBU2.OnBeforeChange.add(function() {fnGLBUOnBeforeChange(2); });

				var fldGLBU3 = form.findCell("GLBU3");
				fldGLBU3.OnBeforeChange.add(function() {fnGLBUOnBeforeChange(3); });

				var fldGLBU4 = form.findCell("GLBU4");
				fldGLBU4.OnBeforeChange.add(function() {fnGLBUOnBeforeChange(4); });
				
			
			
				// ****************** CA ******************************		
				var fldCA1 = form.findCell("CA1");
				fldCA1.OnBeforeChange.add(fnCAOnBeforeChange);
			
				var fldCA2 = form.findCell("CA2");
				fldCA2.OnBeforeChange.add(fnCAOnBeforeChange);

				var fldCA3= form.findCell("CA3");
				fldCA3.OnBeforeChange.add(fnCAOnBeforeChange);

				var fldCA4= form.findCell("CA4");
				fldCA4.OnBeforeChange.add(fnCAOnBeforeChange);
				
				// ****************** Percentage ******************************		
				var fldPercentage1 = form.findCell("Percentage1");
				fldPercentage1.OnChange.add(function() {fnPercentage(1); });

				var fldPercentage2 = form.findCell("Percentage2");
				fldPercentage2.OnChange.add(function() {fnPercentage(2); });

				var fldPercentage3 = form.findCell("Percentage3");
				fldPercentage3.OnChange.add(function() {fnPercentage(3); });

				var fldPercentage4 = form.findCell("Percentage4");
				fldPercentage4.OnChange.add(function() {fnPercentage(4); });

				// ****************** Poject******************************		
		/* 	
				var fldProject1 = form.findCell("Project1");
				fldProject1.OnFocus.add(function() {fnProject(1); });
		*/

				// ****************** Amount ******************************			
				var fldAmount1=form.findCell("Amount1");
				fldAmount1.OnBeforeChange.add(function() {fnAmountOnBeforeChange(1); });
				fldAmount1.OnFocus.add(function() {fnAmountOnFocus(1); });

				var fldAmount2=form.findCell("Amount2");
				fldAmount2.OnBeforeChange.add(function() {fnAmountOnBeforeChange(2); });
				fldAmount2.OnFocus.add(function() {fnAmountOnFocus(2); });

				var fldAmount3=form.findCell("Amount3");
				fldAmount3.OnBeforeChange.add(function() {fnAmountOnBeforeChange(3); });
				fldAmount3.OnFocus.add(function() {fnAmountOnFocus(3); });

				var fldAmount4=form.findCell("Amount4");
				fldAmount4.OnBeforeChange.add(function() {fnAmountOnBeforeChange(4); }); 
				fldAmount4.OnFocus.add(function() {fnAmountOnFocus(4); });

				// ****************** Scenario Totals ******************************				
				var ScenarioTot1=form.findCell("ScenarioTotal1");
				ScenarioTot1.OnBlur.add(function() {fnScenarioTot(1); });
				ScenarioTot1.OnBeforeChange.add(function() {fnScenarioTotOnBeforeChange(1); });
				
				var ScenarioTot2=form.findCell("ScenarioTotal2");
				ScenarioTot2.OnBlur.add(function() {fnScenarioTot(2); });
				var ScenarioTot3=form.findCell("ScenarioTotal3");
				ScenarioTot3.OnBlur.add(function() {fnScenarioTot(3); });
				var ScenarioTot4=form.findCell("ScenarioTotal4");
				ScenarioTot4.OnBlur.add(function() {fnScenarioTot(4); });

				// ****************** Scenario Line Difference ******************************			
				var ScenarioLineDiff1=form.findCell("ScenarioLineDiff1");
				ScenarioLineDiff1.OnChange.add(function() {fnScenarioLineDiff(1); });
				var ScenarioLineDiff2=form.findCell("ScenarioLineDiff2");
				ScenarioLineDiff2.OnChange.add(function() {fnScenarioLineDiff(2); });
				var ScenarioLineDiff3=form.findCell("ScenarioLineDiff3");
				ScenarioLineDiff3.OnChange.add(function() {fnScenarioLineDiff(3); });
				var ScenarioLineDiff4=form.findCell("ScenarioLineDiff4");
				ScenarioLineDiff4.OnChange.add(function() {fnScenarioLineDiff(4); });
				
				// ****************** Operating Unit******************************	
				
				var fldOU1= form.findCell("OU1");
				fldOU1.OnChange.add(function() {fnOUOnChange(1); });
				
				var fldOU2= form.findCell("OU2");
				fldOU2.OnChange.add(function() {fnOUOnChange(2); });	
				//fldOU2.OnFocus.add(fnOU2OnFocus);	

				var fldOU3= form.findCell("OU3");
				fldOU3.OnChange.add(function() {fnOUOnChange(3); });		
				var fldOU4= form.findCell("OU4");
				fldOU4.OnChange.add(function() {fnOUOnChange(4); });	
				
				form.addOnChange(changeHandler);
				form.findCell("UserComment").setValueFromString("");
				

			//Now get some data
				populateGLBU_AU();
				populateGLBU_NZ();
				populateOU();
				populateGLAccount();
				populateProject();
				populateExpenseCategory();
				getDBToleranceData();


		//******************** Get Data done ***************************


		//************ determine if this is GST scenario 3 only and change the tab on the form 		
				if (form.getCell("HeaderGST").getValue()==0 && form.getCell("HeaderTotal").getValue()!=0 &&form.getCell("F_StepName").getValueAsString()!=STEP_VERIFY)
				{
					form.setCurrentPage(form.getPage("GSTScenario3"));		
				}
				
				form.setNotification("");

				// Now proceed to evaluate the form based on the data that it has 		
				// This section applies purely to Standard invoices. because they are triggered automatically so the automatic validation that happens at launch does not apply to Standard Invoices.
				//	hence we invoke it here 

				if ((form.getCell("DocumentType").getValueAsString()==DOC_STANDARD_INVOICE) && (form.getCell("F_StepName").getValueAsString()==STEP_PREPARE) )
				{
					var justLaunched = form.getCell("justLaunched").getValueAsString(); // there's a reason...

					// we do this at just launched so that the initialiisation can take place. If we do it constantly the initialiisation will overwrite existing values that have
					// been modified by the workflow participants
					if (justLaunched.toLowerCase()=="true")
					{
						if (InitialiseGSTValues()==0)
						{
							//validateVendor(); //not required because vendor is validated in the workflow 
						}
					}else  if (justLaunched.toLowerCase()=="false")
					{
						/* lockdown the Scenarios as per current values*/
						lockdownGSTScenarios();
					}
					//	end Standardinvoice only section
				}
				//If Validating vendor and  header summary total at verify.
				if ((form.getCell("DocumentType").getValueAsString()==DOC_STANDARD_INVOICE) && (form.getCell("F_StepName").getValueAsString()==STEP_VERIFY) )
				{
					//validateVendor(); //not required because vendor is validated in the workflow 
					var resSummary=validateHeaderSummary();
				}		
				
				// If not standard invoice then check to see if we're at Preparer and perform lockdown		
				if ((form.getCell("DocumentType").getValueAsString()!=DOC_STANDARD_INVOICE) && (form.getCell("F_StepName").getValueAsString()==STEP_PREPARE) )
				{
					lockdownGSTScenarios();
				}

				if (form.getCell("F_StepName").getValueAsString()==STEP_PREPARE ||form.getCell("F_StepName").getValueAsString()==STEP_LAUNCH )
				{
					getPreparerLocation();
				}

			
/* 			}catch(err) {
			
				// sometimes eforms throws a useless error when a current user has an apostrophe. something  like
				// "incorrect syntax follows". This happens even when the apostophe is escaped. need to keep and 
				// eye out for new forms version. NOTE this does not seem to affect functionality.
				//if(err.description!=undefined)
				//{
					alert("The Error is " + err.description);
				//}
			} */
	}
/*************************************Initialisation Completed ***************************************************************************************/	

	function changeHandler() 
	{
		formDirty = true;
		//form.getPage("GSTScenario1").OnLoad.add(initPageHandler);
		//form.getPage("GSTScenario2").OnLoad.add(initScenario2Handler);
	}
	

	
	
	function fntestButton()
	{
		alert( "this is a test");
		
		getOriginValue()
	}
	
	
	function initScenario2Handler()
	{
		
		/*04112012
		restrictGSTInput(); 
		*/
	}	

	function addClick() {
		var thefield;

		thefield = form.findCell("Cell10");

		var theArray = new Array()
		var Cell7 = form.findCell("Cell7");
		thestringfield = thefield.getValueAsString();

		if (thestringfield.length > 0)

		{
			theArray = thefield.getValueAsString().split(" ");
	
		} else {
		}

	}

	function populateOU() 
	{
		//OU uses the tokenzie function to populate the choice list
			var myCell = form.findCell("OUStringList");
			var myResponse = myCell.doLookup();
			var myDataArray = myResponse.getData();
			var theResponse=myResponse.getType();
			var myData;
			var i;
			 myCell.setValue(myDataArray[0].getValue("OUStringList"));// There should only be one result for this sort of query anyway
	}

	function populateGLAccount() {
			var myCell = form.findCell("GLAccountStringList");
			var myResponse = myCell.doLookup();
			var myDataArray = myResponse.getData();
			myCell.setValue(myDataArray[0].getValue("GLAccountStringList"));// There should only be one result 
	}
	function populateGLBU_AU() {
			var myCell = form.findCell("AU_GLBU");
			var myResponse = myCell.doLookup();
			var myDataArray = myResponse.getData();
			myCell.setValue(myDataArray[0].getValue("AU_GLBU"));// There should only be one result 
	}
	function populateGLBU_NZ() {
			var myCell = form.findCell("NZ_GLBU");
			var myResponse = myCell.doLookup();
			var myDataArray = myResponse.getData();
			myCell.setValue(myDataArray[0].getValue("NZ_GLBU"));// There should only be one result 
	}

	function populateProject() {
			var myCell = form.findCell("ProjectStringList");
			var myResponse = myCell.doLookup();
			var myDataArray = myResponse.getData();
			myCell.setValue(myDataArray[0].getValue("ProjectStringList"));// There should only be one result 
	}	
	
	function populateExpenseCategory() {
			var myCell = form.findCell("ExpenseCatStringList");
			var myResponse = myCell.doLookup();
			var myDataArray = myResponse.getData();
			myCell.setValue(myDataArray[0].getValue("ExpenseCatStringList"));// There should only be one result 
	}		
	
	function ValidClassProduct(tableid,row) {
	
		form.commit();
		var myCell = form.findCell("GLAccount"+tableid);
		var mysearchfield=form.findCell("srchGLAccount");
		mysearchfield.setValueFromString(myCell.getValueAsString(row));
		form.commit();
		if (myCell.getValueAsString(row)!="")
		{
			var myResponse = mysearchfield.doLookup();
			
			var myDataArray = myResponse.getData();
			var theResponse=myResponse.getType();
			var myData;
			var i;
			var  found=false;
			
 			if (myDataArray.length!=0)
			{
			
				for (i=0;i<=myDataArray.length-1;i++)
				{
					var valClass=form.findCell("Class"+tableid).getValueAsString(row);
					var valProduct=form.findCell("Product"+tableid).getValueAsString(row);
					var classRetVal=String(myDataArray[i].getValue("srchClass"));
					var productRetVal=String(myDataArray[i].getValue("srchProduct"));
					var FARetVal=String(myDataArray[i].getValue("srchFixedAsset"));
					var CARetVal=String(myDataArray[i].getValue("srchCreditableAccount"));
					if((valClass.toLowerCase()===classRetVal.toLowerCase())&&(valProduct.toLowerCase()===productRetVal.toLowerCase()))
					 {
						form.findCell("Class"+tableid).setValueFromString(classRetVal,row);
						form.findCell("Product"+tableid).setValueFromString(productRetVal,row);
						form.findCell("FA"+tableid).setValueFromString(FARetVal,row);
						form.findCell("CA"+tableid).setValueFromString(CARetVal,row);

					 return true;
					}
				}
				//	If we get here then there's an error
						alert(" There is a Class and Product field validation Error for  Line "+row);
						return false;
			}else{
			
					alert(" GLAccount/Class/Product combinations could not be found in the database "+row);
					return false;
			} 
			return true;

		}	
	}					

	function fnInvoiceValues()
	{

		/*** For standard invoices this would happen on 1st open of the form. but for PC and Reimbursements these components need to be executed after the invoice totals have been updated. 
			this is because  Reimbursements and Petty cash do not have default invoice values.
			User has to enter these values first and then we need to trigger the functions that do the validation calculations.		
		***/
		if (form.getCell("DocumentType").getValueAsString()==DOC_REIMBURSEMENT ||form.getCell("DocumentType").getValueAsString()==DOC_PETTY_CASH )
		{
			InitialiseGSTValues();
		}	
		if (form.getCell("DocumentType").getValueAsString()==DOC_STANDARD_INVOICE &&form.getCell("F_StepName").getValueAsString()==STEP_VERIFY)
		{
			//alert("validating header summary");
			var resSummary=validateHeaderSummary();
			getGSTPercentage();
		}	

	}	
	
	function getPreparerLocation()
	{
		if(form.getCell("PreparerLocation").getValueAsString()=="")
		{
			var myCell = form.findCell("Preparer");
			var myResponse = myCell.doLookup();
			var myDataArray = myResponse.getData();

			if (myDataArray.length==0)
			{
				alert ("The current Preparer " + form.getCell("Preparer").getValueAsString() + " could not be located. Please contact the system administrators.")
				form.getCell("Preparer").clear();
			}else
			{
				// There should only be one result because a user can only be located in one place.
				form.getCell("PreparerLocation").setValue(myDataArray[0].getValue("PreparerLocation"));
			}				
			
		}
			
	}
	
	function showTracker() {
	
		//displayTrackerAssignment('Inbox', Cell200.getValueAsString(), '800','600');
		displayTrackerAssignment('Inbox', '2A59DB19FF37DE41930A559335D8EBF0');


	}

	function loadjscssfile(filename, filetype) {
		if (filetype == "js") { //if filename is a external JavaScript file
			var fileref = document.createElement('script')
			fileref.setAttribute("type", "text/javascript")
			fileref.setAttribute("src", filename)
		} else if (filetype == "css") { //if filename is an external CSS file
			var fileref = document.createElement("link")
			fileref.setAttribute("rel", "stylesheet")
			fileref.setAttribute("type", "text/css")
			fileref.setAttribute("href", filename)
		}
		if (typeof fileref != "undefined")
			document.getElementsByTagName("head")[0].appendChild(fileref)
	}
	
	
	
	function fnCAOnBeforeChange(eventArgs,sender)
	
	{
	
		var tableid=getCurrentScenario()
		try {
			validateCreditableAccount(tableid)
			}
		catch(err) {
			//alert(err.description +": There was an error validating the creditable status of the GLAccount");
		}
		
		
		
	}
	

	function validateCreditableAccount(tableid)
	
	
	{
		var justadded= (getFullRowCount("GLAccount",tableid)-1);
		if (form.getCell("CA"+tableid).getValue(justadded)=="N" && tableid!=4)
		
		{
				alert("You cannot add this account to GST Scenario " + tableid + "... Non Creditable Assets can only be added to GST Scenario 4");
				form.getCell("GlAccount"+tableid).clear(justadded);
				form.getCell("Class"+tableid).clear(justadded);
				form.getCell("Product"+tableid).clear(justadded);
				form.getCell("CA"+tableid).clear(justadded);
				return false;
		}
		
		if (form.getCell("CA"+tableid).getValue(justadded)=="Y" && tableid==4)
		
		{
				alert("You cannot add this account to GST Scenario " + tableid + "... Creditable Assets can only be added to GST Scenarios 1 to 3");
				form.getCell("GlAccount"+tableid).clear(justadded);
				form.getCell("Class"+tableid).clear(justadded);
				form.getCell("Product"+tableid).clear(justadded);
				form.getCell("CA"+tableid).clear(justadded);
				
				return false;
		}
			
	
	}
	
	function fnchkExpCatOU()
	{
		 var chkExpCatOU=form.findCell("chkExpCatOU");
		var chkDistribOU=form.findCell("chkDistribOU");	
		if (chkExpCatOU.getValueAsString()=="N" && chkDistribOU.getValueAsString()=="N")
			 {
			 chkExpCatOU.setValueAsString("Y");
			 }
	}	

	function showsrchAccount(tableid) 
	{
		if(form.getCell("F_StepName").getValueAsString()==STEP_REVIEW || form.getCell("F_StepName").getValueAsString()==STEP_APPROVE || form.getCell("F_StepName").getValueAsString()==STEP_FAILED_PAYMENT )
		{
			// Dont do anything.... this is a last minute addition because eforms not working properly in UAT
			return;
		}
		try {
			var theCurrentRow = form.findCell("GLAccount"+tableid).getCurrentRow();
		//form.setCurrentCell(form.findCell("Class"+tableid),(form.findCell("DistribLine"+tableid).getCurrentRow()+1));
			form.setCurrentCell(form.findCell("Project"+tableid),theCurrentRow);
			var searchfilter =prompt("Enter the search filter", "");
			var theurl = "searchGLAccounts.jsp?tableid="+ tableid +"&searchfilter="+searchfilter + "&CurrentRow="+theCurrentRow;;
			window.open(theurl, "mywindow",'toolbar=no, menu=no,width=900, resize=0, height=750, scrollbars=1');
				form.commit();
			
		}catch(err)
		{
			alert( "Please ensure that you have selected an GLAccount field before executing a search"); 
		}
	}
	
	function showsrchOU(tableid) 
	{
		if(form.getCell("F_StepName").getValueAsString()==STEP_REVIEW || form.getCell("F_StepName").getValueAsString()==STEP_APPROVE || form.getCell("F_StepName").getValueAsString()==STEP_FAILED_PAYMENT)
		{
			// Dont do anything.... this is a last minute addition because eforms not working properly in UAT
			return;
		}
	
		try 
		{
			var theCurrentRow = form.findCell("OU"+tableid).getCurrentRow();
			//form.setCurrentCell(form.findCell("GLAccount"+tableid),(form.findCell("DistribLine"+tableid).getCurrentRow()+1));
			form.setCurrentCell(form.findCell("GLAccount"+tableid),theCurrentRow);
			var searchfilter =prompt("Enter the search filter", "");
			var theurl = "searchOU.jsp?tableid="+ tableid +"&searchfilter="+searchfilter  + "&CurrentRow="+theCurrentRow;
			window.open(theurl, "mywindow",'toolbar=no, menu=no,width=550, resize=0, height=750, scrollbars=1');
		}catch(err)
		{
			alert("Please ensure that you have selected an OU field before executing a search"); 
		}
	}
	
	function showsrchProject(tableid) 
	{
		if(form.getCell("F_StepName").getValueAsString()==STEP_REVIEW || form.getCell("F_StepName").getValueAsString()==STEP_APPROVE || form.getCell("F_StepName").getValueAsString()==STEP_FAILED_PAYMENT)
		{
			// Dont do anything.... this is a last minute addition because eforms not working properly in UAT
			return;
		}
	
		try 
		{
			var theCurrentRow = form.findCell("Project"+tableid).getCurrentRow();
		//form.setCurrentCell(form.findCell("GLAccount"+tableid),(form.findCell("DistribLine"+tableid).getCurrentRow()+1));
			form.setCurrentCell(form.findCell("Description"+tableid),theCurrentRow);
			var searchfilter =prompt("Enter the search filter", "");
			var theurl = "searchProject.jsp?BU='RIAUD'&tableid="+ tableid +"&searchfilter="+searchfilter + "&CurrentRow="+theCurrentRow;
			window.open(theurl, "mywindow",'toolbar=no, menu=no,width=550, resize=0, height=750, scrollbars=1');
		}catch(err)
		{
			alert("Please ensure that you have selected a Project field before executing a search"); 
		}
	}
	
	function fnProject(tableid)
	
	{
		if (form.findCell("GLAccount"+tableid).getValueAsString(form.findCell("Project"+tableid).getCurrentRow())=="")
		{
			form.setCurrentCell(form.findCell("GLAccount"+tableid),form.findCell("Project"+tableid).getCurrentRow());
		}
	
	}
	
	
	function fnPercentage(tableid)
	{
		if (gbCancel) {return;}
		try{	
			form.commit();
			//var theCurrentRow = fldPercentage1.getCurrentRow();
			var fldPercentage=form.findCell("Percentage" + tableid);
			var theCurrentRow = fldPercentage.getCurrentRow();
			gCurrentRow=theCurrentRow;

			if (gbUploading)
			{
				var theCurrentRow = getCurrentFirstEmptyRow("DistribLine",tableid)
				gCurrentRow=theCurrentRow;
			}
			var fldAmount=form.getCell("Amount" + tableid);
			var theamount=CalculateAmount(tableid,gCurrentRow);
			if (theamount==0) 
			{
			}else
			{
				if(gbUploading){
					fldAmount.setValue(theamount,gCurrentRow-1);
				}else{
					fldAmount.setValue(theamount,gCurrentRow);
					}
			}
		} catch (err){
			alert(" The error is " + err.description);
		}
	
	}
		
 	function VendorChange()
	{

		// trigger the GST Percentage and Line  distribution calculation
		form.setCurrentCell(form.findCell("HeaderTotal"));
		// now go back to the vendor
		form.setCurrentCell(form.findCell("VendorId"));
	}	

 	function SetID_Change()
	{
		if (form.getCell("DocumentType").getValueAsString()==DOC_STANDARD_INVOICE)
		{
			form.setCurrentCell(form.findCell("HeaderTotal"));
		}	
	}
	
	function fnAmountOnBeforeChange(tableid)
	{
		try{
			var fldAmount=form.getCell("Amount" + tableid);
			var theCurrentRow = fldAmount.getCurrentRow();

			if (theCurrentRow==-1){theCurrentRow=gCurrentRow};
			if (typeof gCurrentRow != "undefined")
			{
				

				var fldScenarioTot=form.getCell("ScenarioTotal" + tableid);
				var  valScenario=fldScenarioTot.getValueAsString();
			
				if ( isNaN(parseFloat(valScenario))==true )
				{
					form.setCurrentCell(fldScenarioTot);
				}
			}	
		}catch(err){
			alert("The Error is " + err.description);
		}
	}		
	
	function go()
	{
	
	}

	function fnAmountOnFocus(tableid)
	{
		try{
			var fldAmount=form.getCell("Amount" + tableid);
			var theCurrentRow = fldAmount.getCurrentRow();
			if (theCurrentRow==-1){theCurrentRow=gCurrentRow};

			var fldScenarioTot=form.getCell("ScenarioTotal" + tableid);
			var  valScenario=fldScenarioTot.getValueAsString();
			if (valScenario==""){
				form.setCurrentCell(form.getCell("ScenarioTotal" + tableid));
			}
		} catch (err){
		}
	}

	function fnOUOnChange(tableid)
	{
	var theCurrentRow = getCurrentFirstEmptyRow("DistribLine",tableid)
	
	gCurrentRow=theCurrentRow;
	var theApprover=form.findCell("Approver");
	theApprover.clear();
	form.commit()
	}
	
 
	function fnGLBUOnBeforeChange(tableid)
	{
		var theCurrentRow=form.findCell("GLBU"+tableid).getCurrentRow();
		if (!gbUploading&&!gbCancel)
		{
			setDistribLine(tableid,theCurrentRow)
			if(form.findCell("Description"+tableid).getValueAsString(theCurrentRow)=="")
			{
				form.findCell("Description"+tableid).setValueFromString(form.findCell("ScenarioDescription"+tableid).getValueAsString(), theCurrentRow);
				form.commit();
			}
		}
	}

	function fnDescriptionOnBeforeChange(tableid)
	{
		form.commit();

		if (!gbUploading)
		{
			form.findCell("Description"+tableid).setValueFromString(form.findCell("ScenarioDescription"+tableid).getValueAsString(), form.findCell("GLAccount"+tableid).getCurrentRow());
		}
	}	


	function FileBrowse()
	{
		if (form.getCell("F_StepName").getValueAsString()==STEP_VERIFY || form.getCell("F_StepName").getValueAsString()==STEP_PREPARE|| form.getCell("F_StepName").getValueAsString()==STEP_LAUNCH)
		{
			var theurl ="FileBrowser.jsp?"
			window.open(theurl, "Upload",'toolbar=no, location=no,titlebar=no, width=650, resize=1, height=175, scrollbars=0');		
		}
	}

	function getGLBU()
	{
		//Get the GLBU Val
		if  (Left(form.getCell("BU").getValueAsString(),2)=="AU")
		{
			 gsvalGLBU=form.getCell("AU_GLBU").getValueAsString();
		}else
		{
			 gsvalGLBU=form.getCell("NZ_GLBU").getValueAsString()
		}		

	}

	function validGLBU(xlVal)
	{
		//Get the GLBU Val
		if  (gsvalGLBU.indexOf(xlVal)>=0)
		{
			return true;
		}else
		{
			return false;
		}		

	}
	
	function validProject(xlVal)
	{
	
		form.getCell("srchProject").setValueFromString(xlVal.toString());
		var mysearchfield=form.getCell("srchProject");
		
		/**Now execute the Query**/
		form.commit();
		var myResponse = mysearchfield.doLookup();
		
		var myDataArray = myResponse.getData();
		var theResponse=myResponse.getType();
		var myData;
		var i;
		
		if (myDataArray.length!=0)
		{
			/**Check if there is at least one record in the return list 
			This query returns a count. So there is only one record
			so check if the value is at least 1                 **/
			if (myDataArray[0].getValue("srchProject")>0)
			{
				return true;
			}else
			{
				return false;
			}
		}				
	}	
	
	function UploadXL(tableid)
	{
		if (form.getCell("F_StepName").getValueAsString()!=STEP_VERIFY && form.getCell("F_StepName").getValueAsString()!=STEP_PREPARE && form.getCell("F_StepName").getValueAsString()!=STEP_LAUNCH)
			{return;}
		getGLBU();
		try{
				
				var Excel =null;
				var txt;
				//var thedir = prompt("Message", "C:/rabo/book6.xlsx");
				var thedir=form.getCell("UploadFile").getValueAsString();
				var upLoadOffset=6;
				form.setNotification("Uploading excel data...");
				if(thedir==null){form.setNotification();return;};
			

				Excel = new ActiveXObject("Excel.Application");
				var worksheet = Excel.Workbooks.Open(thedir);
				gbUploading=true;
				Excel.Visible = true;
				alert("Uploading spreadsheet for " +form.getCurrentPage().getLabel());
				Excel.Sheets(form.getCurrentPage().getLabel()).Select();
					gbCancel=true;
				//clearGSTLines(tableid);
				setTableRow();
				form.setNotification("Clearing current distributions...");
				clearLineDistributions(tableid);
				gbCancel=false;		
				var ScenLineTot=form.getCell("ScenarioTotal"+tableid); 	
	//			ScenLineTot.clear();
				var ScenarioDistribution=form.getCell("ScenarioDistribution"+tableid);
	//			ScenarioDistribution.clear(); 
				var numberOfRows=getCurrentFirstEmptyRow("DistribLine",tableid)
				gnAmount=0;
				gnPercentage=0;
				form.commit();			


				
				gnLineTotal=worksheet.ActiveSheet.Range("Scen" + tableid+"_LineTotal").Value
				ScenLineTot.setValue(new Value(gnLineTotal));
				var ScenarioDescription=form.getCell("ScenarioDescription"+tableid); 
				ScenarioDescription.setValueFromString(worksheet.ActiveSheet.Range("Scen" + tableid+"_LineDesc").Value);
				var therowcount=worksheet.ActiveSheet.UsedRange.Rows.Count;//-upLoadOffset+1;
				var EndRow=therowcount+upLoadOffset;
				form.setNotification("Uploading Excel data...");

				for (i=upLoadOffset;i<=therowcount;i++)
				{
					var tablerow=i-upLoadOffset;
					var fldDistribLine=form.getCell("DistribLine"+tableid); 	
						 fldDistribLine.setValue(new Value(tablerow+1),tablerow);

					var fldGLBU=form.getCell("GLBU"+tableid); 	
					fldGLBU.setValue(new Value(worksheet.ActiveSheet.Range("Scen" + tableid+"_GLBU").Cells(i).Value),tablerow);

					if (!validGLBU(worksheet.ActiveSheet.Range("Scen" + tableid+"_GLBU").Cells(i).Value))
					{
						alert("Invalid GLBU error. The Upload will end. Please check the file before uploading.");
						 throw "UPLOAD_ERROR";
					}
					var fldOU=form.getCell("OU"+tableid); 	
						fldOU.setValueFromString(worksheet.ActiveSheet.Range("Scen" + tableid+"_OU").Cells(i).Value,tablerow);

					var fldProject=form.getCell("Project"+tableid); 	
					
					var XLProjectVal=worksheet.ActiveSheet.Range("Scen" + tableid+"_Project").Cells(i).Value;

					if ((typeof XLProjectVal != "undefined") &&  XLProjectVal != "" )
					{
						//fldProject.setValueFromString(worksheet.ActiveSheet.Range("Scen" + tableid+"_Project").Cells(i).Value,tablerow);
						fldProject.setValueFromString(XLProjectVal,tablerow);
						if (!validProject(XLProjectVal))
						{
							alert("Invalid Project error. The Upload will end. Please check the file before uploading.");
							 throw "UPLOAD_ERROR";
						}
					}

					
					
					
					var fldGLAccount=form.getCell("GLAccount"+tableid); 	
						fldGLAccount.setValueFromString(worksheet.ActiveSheet.Range("Scen" + tableid+"_GLAccount").Cells(i).Value,tablerow);
						
					var fldClass=form.getCell("Class"+tableid); 	
					
					var XLClassVal=worksheet.ActiveSheet.Range("Scen" + tableid+"_Class").Cells(i).Value;

					if ((typeof XLClassVal != "undefined") &&  XLClassVal != "" )
					{
						fldClass.setValueFromString(worksheet.ActiveSheet.Range("Scen" + tableid+"_Class").Cells(i).Value,tablerow);
					}

					var fldProduct=form.getCell("Product"+tableid); 	
					var XLProductVal=worksheet.ActiveSheet.Range("Scen" + tableid+"_Product").Cells(i).Value;

					if ((typeof XLProductVal != "undefined") &&  XLProductVal != "" )
					{
						fldProduct.setValueFromString(worksheet.ActiveSheet.Range("Scen" + tableid+"_Product").Cells(i).Value,tablerow);
					}
						form.commit();
					if (!ValidClassProduct(tableid,tablerow)){
						alert("Class & Product validation error. The Upload will end. Please check the file before uploading");
					 throw "UPLOAD_ERROR";
					}; 

					var fldDescription=form.getCell("Description"+tableid); 	
					var XLLineDescVal=worksheet.ActiveSheet.Range("Scen" + tableid + "_Description").Cells(i).Value;
					if ((typeof XLLineDescVal != "undefined") &&  XLLineDescVal != "" )
						{
							fldDescription.setValueFromString(XLLineDescVal,tablerow);
						}else
						{
							fldDescription.setValueFromString(form.getCell("ScenarioDescription" + tableid).getValueAsString(),tablerow);
						}				
					
					//Amount and Percentage work hand in hand it's one or the other
					gnPercentage=worksheet.ActiveSheet.Range("Scen" + tableid+"_Percentage").Cells(i).Value;
					gnAmount=worksheet.ActiveSheet.Range("Scen" + tableid+"_Amount").Cells(i).Value;

				  if ( isNaN(parseFloat(gnPercentage))==false )// Percentage is valid
					 {
						 var Percentage=form.getCell("Percentage"+tableid); 
						 Percentage.setValue(new Value(gnPercentage),tablerow);
						
					 }else if ( isNaN(parseFloat(gnAmount))==false )
					 {
						 var Amount=form.getCell("Amount"+tableid); 
						 Amount.setValue(new Value(gnAmount),tablerow);
					}
						form.commit();
				
					if (i%10==0){
						form.setNotification("Updated 1 to " + i +" rows..." );
					}

				}
				form.setNotification("Now validating Data..." );
				form.commit();
				validateUploadData(1);
				worksheet.close();
				Excel.Quit();

				Excel = null;
				setTimeout("CollectGarbage()", 1);
				gbUploading=false;
				//Now check the Difference Field
				var Scenariodiff = form.findCell("ScenarioLineDiff"+tableid);
				var valScenariodiff=Scenariodiff.getValue();
				if(valScenariodiff<0)
				{
					alert( "Please check the allocations and Line Amount. The maximum variation is $1.00");
				}
				form.commit();
				form.setNotification();
				form.setCurrentCell(form.getCell("Amount"+tableid),1);
				//form.setCurrentCell(form.getCell("Amount"+tableid),1);
			
			}catch (err){
				
				
				form.setNotification("There was an error. Please refer to error message");
			if (err !="UPLOAD_ERROR")
				{
					alert ("The error is "+ err.description);
				}
				if (worksheet){alert("Closing worksheet");worksheet.close();worksheet=null;}		
				Excel.Quit();
				Excel = null;

				setTimeout("CollectGarbage()", 1);
			
				gbUploading=false;
				form.setNotification();
			}

				
	}	

	
	function ScenarioDistribution(tableid){
		//alert("the table");
	}
	function fnScenarioTotOnBeforeChange(tableid)
	{


	}
	function fnScenarioTot(tableid)
	{
	try{
		var numberOfRows=getFullRowCount("DistribLine",tableid)
		var fldscenariotot=form.getCell("ScenarioTotal" +tableid);
		var  fldTotVal = fldscenariotot.getValue();
		var fldamount=form.getCell("Amount" +tableid);
		var fldpercentage=form.getCell("Percentage" +tableid);
		if (fldTotVal==0){form.getCell("ScenarioDescription"+tableid).clear()};
			for(rowindex= 0; rowindex< numberOfRows; rowindex++)
			{
				var thepercentage=fldpercentage.getValue(rowindex);
				if (thepercentage>0)
					{
						fldamount.setValue(new Value(fldTotVal* (thepercentage/100)),rowindex);
					} 
			}

		}catch(err){
		}
	
	}
	
	
	fnScenarioLineDiff=function(tableid)
	{
	//document.getElementById("ScenarioLineDiff").style.color = "#FF0000";
	
		var fldScenarioLineDiff=form.findCell("ScenarioLineDiff"+tableid);
		var valfldScenarioLineDiff=fldScenarioLineDiff.getValue();

		if (parseFloat(valfldScenarioLineDiff)<0)
		{
			if (!gbUploading)
			{	// This will popup too many times when there are lots of entries... so check it at the end 		
			}else
			{
				// We'll check this at the end of the upload
			}
		}
	}
	function UpdateBU()
	{
	//InitialiseGSTValues()
	}
	
	
	function setTableRow()
	{
		/** This is a house keeping exercise.
		it is done because the form throws up errors if the number of visible lines
		is less than the actual row count and the user is trying to despatch the work item
		This needs to be fixed by IBM ... Need to log a call.
		**/
		
		for(tableid=1; tableid<=4; tableid++)
		{
			/**get the rowcount first to determine if the scenario has any rows... 
			It will qualify ashaving rows if GLAccount field is NOT empty.**/
			var tableRowCount=getCurrentFirstEmptyRow("GLAccount",tableid);
			if(!tableRowCount<=0)
			{
			
			form.findCell("Description"+tableid).setValueFromString("",tableRowCount);
				form.setCurrentCell(form.getCell("Description"+tableid),1);
				form.commit();
			
			}

		}			
	}	
	
	complete=function()
	{


	
		// if Invoice is being cancelled then perform the cancellation function
		setTableRow();
		if(form.getCell("F_StepName").getValueAsString()==STEP_VERIFY && form.getCell("F_Responses").getValueAsString()==ACTION_CANCEL)
		{
			if (!cancelInvoice())
			return;
		}
		
		/** if Preparer is blank then cancel the complete **/
	
		if (form.getCell("Preparer").getValueAsString()=="")
		{
			alert ("Please select a valid Preparer");
			return;
		}		
		
		/** get Unique form id ... We're only doing this  here because because 
		the forms product seems to have a problem with auto-incrementing using JDBC **/
		if (
			form.getCell("DocumentType").getValueAsString()==DOC_REIMBURSEMENT && form.getCell("F_StepName").getValueAsString()==STEP_LAUNCH ||
			form.getCell("DocumentType").getValueAsString()==DOC_PETTY_CASH && form.getCell("F_StepName").getValueAsString()==STEP_LAUNCH ||
			form.getCell("DocumentType").getValueAsString()==DOC_STANDARD_INVOICE && form.getCell("F_StepName").getValueAsString()==STEP_PREPARE ||
			form.getCell("DocumentType").getValueAsString()==DOC_STANDARD_INVOICE && form.getCell("F_StepName").getValueAsString()==STEP_VERIFY)
			{
				getFormUniqueID();
			}
		/** Validating Scenario data at Launch Preparer and Verify**/
		if (form.getCell("F_StepName").getValueAsString()==STEP_PREPARE || form.getCell("F_StepName").getValueAsString()==STEP_VERIFY ||form.getCell("F_StepName").getValueAsString()==STEP_LAUNCH)
		{
			if (form.getCell("F_Responses").getValueAsString()!=ACTION_CANCEL)
			{
				// Validate the distribution data
				if (!validDistributionData())
				{
					return;
				}
			}
		}
		
		/** Validate the header summary... If it's standard Invoice do not let it pass verify if the summary is not correct **/
		if (form.getCell("F_StepName").getValueAsString()==STEP_VERIFY && form.getCell("DocumentType").getValueAsString()==DOC_STANDARD_INVOICE)
		{
			if (form.getCell("F_Responses").getValueAsString()!=ACTION_CANCEL)
			{
				if (!validateHeaderSummary())
				{
					return;
				}
			}
		}

		
		form.setNotification("Validating...Origin");
		getOriginValue();
		
		form.setNotification("Validating...Attachment");
		// For PC/R  Check if an invoice attachment has been added
		if ((form.getCell("DocumentType").getValueAsString()==DOC_REIMBURSEMENT||form.getCell("DocumentType").getValueAsString()==DOC_PETTY_CASH) && form.getCell("F_StepName").getValueAsString()=="Launch")
		{
			var r=confirmAction("Have you added an Invoice attachment? If you don't the workflow will fail.","Attachment Confirmation") ;
			if (r==CONFIRM_NO)
			{
				return;
			}
		}		
		
		//Ensure SetID not blank and not verify
		form.setNotification("Validating...Vendor");

		if ((form.getCell("VendorSetID").getValueAsString()=="" ||form.getCell("VendorID").getValueAsString()=="" )&& (form.getCell("F_Responses").getValueAsString()!=ACTION_VERIFY))
		{
			alert( "The Vendor ID/SETID is blank. Please correct the error before continuing. Otherwise send to AP");
			setCancel=true;
			form.setNotification("")
			return ;
		}

		// Check that the header amounts match with the line amounts
		form.setNotification("Validating...Header and Line Totals");
		//If we're at Prepare and changing the invoice amounts
		if (form.getCell("F_StepName").getValueAsString()==STEP_PREPARE && (form.getCell("F_Responses").getValueAsString()==ACTION_SUBMIT_APPROVAL||form.getCell("F_Responses").getValueAsString()==ACTION_REVIEW))
		{
			form.setNotification("Validating Fields");
		 	if (validateDifference()==1)
			{
				//alert(" Please ensure that the difference between the header and the line items is contained to within $1.00");
				alert(" Ensure that line items add up to invoice summary totals. Please correct or send to AP.");
				return;
			} 
		} 
		
		//If we're at Launch and setting up invoices.
		if (form.getCell("F_StepName").getValueAsString()==STEP_LAUNCH && (form.getCell("F_Responses").getValueAsString()==ACTION_SUBMIT_APPROVAL||form.getCell("F_Responses").getValueAsString()==ACTION_REVIEW))
		{
			form.setNotification("Validating Fields");
		 	if (validateDifference()==1)
			{
				//alert(" Please ensure that the difference between the header and the line items is contained to within $1.00");
				alert(" Ensure that line items add up to invoice summary totals. Please correct or send to AP.");
				return;
			} 
		} 
	
		//ensure Approver selected before continiuing
		form.setNotification("Validating...Approval");
		if ((form.getCell("Approver").getValueAsString()=="")&& (form.getCell("F_Responses").getValueAsString()==ACTION_SUBMIT_APPROVAL))
		{
			alert("Please select an Approver before continuing");
			setCancel=true;
			form.setNotification("")
			return ;
		}
		/** Now validate Approver **/

			if ((form.getCell("F_StepName").getValueAsString()==STEP_PREPARE||form.getCell("F_StepName").getValueAsString()==STEP_LAUNCH || form.getCell("F_StepName").getValueAsString()==STEP_VERIFY) && form.getCell("Approver").getValueAsString()!="")
			{
				if (!validApprover())
				{
					alert( "A Preparer cannot approve an invoice. Please correct.") ;
					return;
				}
			} 
		
		//if we are @ Review then Assign review status indicator
		form.setNotification("Validating...Review");
		if (form.getCell("F_StepName").getValueAsString()==STEP_REVIEW)
		{
			
			SetReviewStatus();
			form.setNotification("")
		}
		
		//If we are @ Prepare then collate overall GST Scenario info
		form.setNotification("Validating...Approval");
	
		if (form.getCell("F_StepName").getValueAsString()==STEP_PREPARE||form.getCell("F_StepName").getValueAsString()==STEP_LAUNCH)
		{		
			var GSTValues =getGSTScenarioValues();
		}

		if (form.getCell("F_StepName").getValueAsString()==STEP_PREPARE)
		{
			//var GSTValues =getGSTScenarioValues();
			form.setNotification("");
			if(form.getCell("Approver").getValueAsString()=="" && (form.getCell("F_Responses").getValueAsString()==ACTION_SUBMIT_APPROVAL)) //|| form.getCell("F_Responses").getValueAsString()==ACTION_REVIEW))
				{
					alert("Please select an Approver before continuing");
					form.setNotification("");
					return ;
				}
		}

	//Checking Review 	
	
		form.setNotification("Validating...Review");
	
		if (form.getCell("F_Responses").getValueAsString()==ACTION_REVIEW)
		{
			var NoReviewers=true;
			for (i=0;i<form.getCell("Reviewers").getVisibleRowCount();i++)
			{
				if (form.getCell("Reviewers").getValueAsString(i)!="")
				{
					NoReviewers=false;
				}
			}
			
			if (NoReviewers)
			{
				alert("Please select a Reviewer before completing");
				return;
			}
			if (!validReviewer())
			{
				alert( "A Preparer cannot review an invoice. Please correct.") ;
				return;
			}

			if (!validReviewerList())
			{
				alert( "Please correct all reviews before continuing, Ensure users' login names are entered or have been selected. Please select from the selection list if you are unsure.") ;
				return;
			}
				

		}
		form.setNotification("Validating...GST and Header Totals");

		if ((parseFloat(form.getCell("HeaderGST").getValueAsString())>MAX_GST) && (form.getCell("F_StepName").getValueAsString()==STEP_PREPARE))
		{
			alert ("The GST Calculated Amount is  incorrect. This invoice MUST be sent to Verify");
			form.getCell("F_Responses").setValueFromString(ACTION_VERIFY);
			return;
		}

		
		if (form.getCell("F_StepName").getValueAsString()==STEP_APPROVE&&form.getCell("F_Responses").getValueAsString()==ACTION_APPROVE)
		{		
			storefinalComment()
		}

		
		//Now Complete
		form.setNotification("")
		cmdComplete.execute();
		
		return;

	}
	

	fnDOA=function ()
	{	
		if (form.findCell("F_StepName").getValueAsString()==STEP_PREPARE||form.findCell("F_StepName").getValueAsString()==STEP_VERIFY||form.findCell("F_StepName").getValueAsString()==STEP_LAUNCH)
		{
			var strNewOUCollection="";
			var CollOU=form.findCell("CollOU");	
			var valCollOU= CollOU.getValueAsString() ;
			var OUCollArray=valCollOU.split("_");
			var i;
			var OU1List=form.findCell("selectedOU1_1").getValueAsString();
			var OU2List=form.findCell("selectedOU2_1").getValueAsString();
			var OU3List=form.findCell("selectedOU3_1").getValueAsString();
			var OU4List=form.findCell("selectedOU4_1").getValueAsString();
			// Trim OU  all the OU Lists 
			while (Right(OU1List,1)=="_")
			{
			OU1List=Left(OU1List,OU1List.length-1)
			}
			while (Right(OU2List,1)=="_")
			{
			OU2List=Left(OU2List,OU2List.length-1)
			}
			
			while (Left(OU2List,1)=="_")
			{
				OU2List=OU2List.substring(1,OU2List.length)
			}					
			
			while (Right(OU3List,1)=="_")
			{
			OU3List=Left(OU3List,OU3List.length-1)
			}
			while (Left(OU3List,1)=="_")
			{
				OU3List=OU3List.substring(1,OU3List.length)
			}				
	
			while (Right(OU4List,1)=="_")
			{
			OU4List=Left(OU4List,OU4List.length-1)
			}			
			while (Left(OU4List,1)=="_")
			{
				OU4List=OU4List.substring(1,OU4List.length)
			}					
		// end Field trim Now combine and trim front and back
		
			strNewOUCollection=OU1List +"_"+OU2List+"_" +OU3List+"_"+OU4List;

			while (Right(strNewOUCollection,1)=="_")
			{
			strNewOUCollection=Left(strNewOUCollection,strNewOUCollection.length-1)
			}			
			while (Left(strNewOUCollection,1)=="_")
			{
				strNewOUCollection=strNewOUCollection.substring(1,strNewOUCollection.length)
			}
			//Now replace double underscore in string 
			var DOAOU= strNewOUCollection.replace(/___/g,"_");
			DOAOU= DOAOU.replace(/__/g,"_");
			var BU=form.findCell("BU");
			var EC=form.findCell("ExpenseCategory");
			var Amount=form.findCell("HeaderTotal");
			var useEC=form.findCell("useEC");
			var theurl ="searchDOA.jsp?";
			theurl=theurl+"BU='"+ BU.getValueAsString() + "'&";
			theurl=theurl+"OU='" + DOAOU + "'&" ;
			theurl=theurl+"EC='" + EC.getValueAsString()  + "'&" ; 
			theurl=theurl+"Amt='"	+ Amount.getValueAsString()	  + "'&"; 
			theurl=theurl+"useEC='"	+useEC.getValueAsString() + "'";
			window.open(theurl, "mywindow",'toolbar=yes, location=yes,width=1100, resizable=1, height=750, scrollbars=1');
		}else
		{
			alert( "An Approver cannot be selected at this step.")
		}
	}

	function CalculateAmount(tableid, row)
	{
		
		try{
			if (gbUploading) {
				var  thepercentage;
				thepercentage=gnPercentage/100;
				var  thetotal;
				thetotal=gnLineTotal;
			}else{
				var scenariototcell=form.findCell("ScenarioTotal"+tableid);
				var thetotal=scenariototcell.getValue();
				var thepercentageField=form.findCell("Percentage" + tableid);
				var thepercentage=thepercentageField.getValue(row)/100;
			}
			
			if ( isNaN(parseFloat(thetotal))==true )
			{ 
				alert ("Distribution amount cannot be calculated. Please ensure that the line total is filled out correctly.Please ignore this message if you are uploading from and Excel spreadsheet");
				return (0);
			}else
			{	
			var theamount=Value(thetotal * thepercentage);
			return (theamount);
			}
		}catch (err)
		{
			alert ("The error is "+ err.description);
			return (0);
		}
	}
	

	
	

	validateUploadData=function (tableid)
	{
		form.setNotification("Validating data");
		validateAccountData(tableid);
		form.setNotification("");
	}
	
	
	
 	validateAccountData = function  (tableid)
	{
	form.commit();
	
		var numberOfRows=getCurrentFirstEmptyRow("DistribLine",tableid);
		var rowindex;

		for(rowindex= 0; rowindex< numberOfRows; rowindex++)
		 {
			  var theGLAccount=form.getCell("GLAccount" +tableid);
			 if (!theGLAccount.getValueAsString(rowindex)){
				alert("Invalid Account Data @ line " + rowindex+1 );
				break;
			 }
		 }
	
	}
	
	function fnUserComment()
	{
	}

	


	function getFormUniqueID()
	{
		var mysearchfield=form.getCell("uniqueid");

		/**Now execute the Query**/
		var myResponse = mysearchfield.doLookup();
		
		var myDataArray = myResponse.getData();
		var theResponse=myResponse.getType();
		var myData;
		var i;
		if (myDataArray.length!=0)
		{
			/** Now set the GST Origin field for the invoice**/
			//alert(myDataArray[0].getValue("FormUniqueID"));
			form.getCell("uniqueid").setValue(myDataArray[0].getValue("uniqueid"));
		}							
	}	
	
	
 	function validApprover()
		{
			if (form.getCell("Approver").getValueAsString().toLowerCase()==form.getCell("Preparer").getValueAsString().toLowerCase() && form.getCell("Approver").getValueAsString()!="")
			{
				return false;
			}else if  (form.getCell("Approver").getValueAsString().toLowerCase()==loggedInUser.toLowerCase() && form.getCell("Approver").getValueAsString()!="")
			{
				return false;
			}else
			{
				return true;
			}
		}	
 	function validReviewer()
		{
			// Preparer or Approver cannot assign themselves as reviewer. Unless it is being overidden by a System Admin function like Administrator or Tracker.
			// There is no mechanism to deal with this and it is highly unlikely that the general ppoulation of preparers will have Admin access to the system so this is trackable
			// especially from the audit log.
		
		for (i=0;i<form.getCell("Reviewers").getValueCount();i++)
			{
			
				if (form.getCell("Reviewers").getValueAsString(i).toLowerCase()===loggedInUser.toLowerCase())
				{
					return false;
				}else if (form.getCell("Reviewers").getValueAsString(i).toLowerCase()==form.getCell("Preparer").getValueAsString().toLowerCase() )
				{
					return false;
				}
				
			}
			return true;		
	
		}	

	function getOriginValue()
	{
		// Note each tableid corresponds to a specific scenario
		//Get BU first
		var BU = form.getCell("BU").getValueAsString();
		var MixedAssets = "False";
		var FixedAsset = new Boolean(false);
		var NonFixedAsset = new Boolean(false);
		
		/**
		First run a query to determine whether there are any mixed assets
		i.e. a combination of fixed and non fixed assets across the spread of all
		scenarios. If there are then go and select the origin based on "mixed Asset" value.
		**/
		for(tableid=1; tableid<=4; tableid++)
		{
			/**get the rowcount first to determine if the scenario has any rows... It will qualify ashaving rows if OU field is NOT empty
				also determine  if there are fixed assets and non fixed assets across all of the tables.**/
			var tableRowCount=getFullRowCount("GLAccount",tableid)
		
			if (tableRowCount>0)
			{
				for(itemcount=0; itemcount<tableRowCount; itemcount++)
				{
					if (form.getCell("FA"+tableid).getValue(itemcount)=="Y")
					{
						FixedAsset=true;
					}else if (form.getCell("FA"+tableid).getValue(itemcount)=="N")
					{
						NonFixedAsset=true;
					
					}
				} 

			}
		}

		if(FixedAsset ==true && NonFixedAsset==true)
		{
			MixedAssets="True";
		}		 
		// Need to tally the results and write back to the origin field
		form.findCell("MixedAssets").setValueFromString(MixedAssets);

		var mysearchfield=form.getCell("HeaderOrigin");
		/**Now execute the Query**/
		var myResponse = mysearchfield.doLookup();
		
		var myDataArray = myResponse.getData();
		var theResponse=myResponse.getType();
		var myData;
		var i;
		
		if (myDataArray.length!=0)
		{
			/** Now set the GST Origin field for the invoice**/

			form.getCell("HeaderOrigin").setValue(myDataArray[0].getValue("HeaderOrigin"));
		}							
	}

	//Sets CompletedReview = true for the current review
 	SetReviewStatus=function ()		 
	{
		try{
			var Reviewers=form.getCell("Reviewers");
			for (i=0;i<form.getCell("Reviewers").getValueCount();i++)
			{
				if (Reviewers.getValueAsString(i).toLowerCase()===loggedInUser.toLowerCase())
				{
					form.getCell("CompletedReviews").setValueFromString("True",i);
				}
			}		

		}catch (err){
			alert("The Error is " + err.description);
		}
		
	}

	/** validDistributionData
		 * This function runs through all of the scenarios to determine whether there is invalid data in any  of the mandatory entries. They are;
		 *GLBU, OU, GLAccount,Description and Amount  
		 * 
		**/
 	function validDistributionData()
	{
		for(tableid=1; tableid<=4; tableid++)
		{
			var  GSTVal1=parseFloat(form.findCell("ScenarioTotal1").getValueAsString());
			var  GSTVal2=parseFloat(form.findCell("ScenarioTotal2").getValueAsString());
			var  GSTVal3=parseFloat(form.findCell("ScenarioTotal3").getValueAsString());
			var  GSTVal4=parseFloat(form.findCell("ScenarioTotal4").getValueAsString());
			var  HeaderExGST=parseFloat(form.findCell("HeaderExGST").getValueAsString());
			var  HeaderTotal=parseFloat(form.findCell("HeaderTotal").getValueAsString());
			var  GSTDiff=parseFloat(form.findCell("HeaderTotal").getValueAsString());
			
			
 			if((HeaderExGST==0 || HeaderTotal==0) && (form.getCell("F_Responses").getValueAsString()==ACTION_REVIEW ||form.getCell("F_Responses").getValueAsString()==ACTION_SUBMIT_APPROVAL))
			{
				alert ("Please ensure that the invoice summary section is completed correctly");
				return false;
			} 

			if((HeaderExGST==0 || HeaderTotal==0) && (form.getCell("F_Responses").getValueAsString()==ACTION_REVIEW ||form.getCell("F_Responses").getValueAsString()==ACTION_SUBMIT_APPROVAL))
			{
				alert ("Please ensure that the invoice summary section is completed correctly");
				return false;
			} 
  
			if((GSTVal1==0 && GSTVal2==0 &&GSTVal3==0 &&GSTVal4==0) && (form.getCell("F_Responses").getValueAsString()==ACTION_REVIEW ||form.getCell("F_Responses").getValueAsString()==ACTION_SUBMIT_APPROVAL))
			{
				alert ("Please ensure that the invoice summary section is completed and at least once GST scenario line has been added in order to send the invoice to Approval or Review.");
				return false;
			} 
			
			//get the rowcount first to determine if the scenario has any rows...
			var tableRowCount=getFullRowCount("OU",tableid);
			
			var OUCount=getFullRowCount("OU",tableid);
			var GLACount=getFullRowCount("GLAccount",tableid);
			var DescriptionCount=getFullRowCount("Description",tableid);
			var AmountCount=getFloatRowCount("Amount",tableid); 
			var GLBUCount=getFullRowCount("GLBU",tableid);

			if (GLBUCount!=OUCount || OUCount!=GLACount || GLACount!=DescriptionCount || DescriptionCount!=AmountCount) 
				{
					alert (" There is a problem at line " + (Math.min(GLBUCount,OUCount,OUCount,GLACount , DescriptionCount,AmountCount)+1) +" for GST Scenario " + tableid + ". Please fix the error before continuing.");
					return false;
				} 
		}
		return true;
		
	}	

	/**validateDifference 
		Ensures that the distribution totals are within the specified invoice tolerance levels. 
	**/
	validateDifference=function()
	{
	
		//var HeaderExGST = form.findCell("HeaderExGST").getValueAsString();
		var HeaderExGST = parseFloat(roundNumber(form.getCell("HeaderExGST").getValue(),2));
		//var HeaderLineTotal = form.findCell("HeaderLineTotal").getValueAsString();
		var HeaderLineTotal = parseFloat(roundNumber(form.getCell("HeaderLineTotal").getValue(),2));
		//var HeaderLineDiff= form.findCell("HeaderLineDiff").getValue();
		var HeaderLineDiff = parseFloat(roundNumber(form.getCell("HeaderLineDiff").getValue(),2));
		var InvoiceDiff = parseFloat(roundNumber(form.getCell("InvoiceDiff").getValue(),2));
		//var GSTDiff= form.findCell("GSTDiff").getValue();
		var GSTDiff = parseFloat(roundNumber(form.getCell("GSTDiff").getValue(),2));
		
		
		try
		{

/****************** New  Functionality ************************************
	The overall invoice tolerance has to be equal to the distribution Tolerance 
	The distribution tolerance consists of the invoice tolerance + distribution tolerance
	i.e Invoice tolerance = $1.00
		Distribution tolerance= Invoice tolerance + Tolerance to allow for  variances of GST Scenarios
	-->Distribution tolerance = Invoice tolerance + 0.03 cents ( at the time of writing		
	
	GST tolerance level information
 ****************************************************************************/	

			// ensure that the total payable is not outside the tolerance levels
			if (InvoiceDiff>(maxInvoiceGSTTolerance+maxGSTLineDiff)||InvoiceDiff < (minInvoiceGSTTolerance+minGSTLineDiff))
			{
				alert ("The header totals are outside the tolerance levels. Please adjust the invoice or send to AP.");
				return 1;
			}

			//Ensure that the distributed GST (Bottom Up) is not outside the tolerance levels
			if (GSTDiff>maxInvoiceGSTTolerance+maxGSTLineDiff||GSTDiff <minInvoiceGSTTolerance+minGSTLineDiff)
			{
				alert("There is an error with GST. Please correct before continuing.");
				return 1;
			}
			return 0;
				
		}catch (err){
			alert("The Error is " + err.description);
			return 1
		}
	
	} 
	
	fngetReviewerIndex=function()
	{
			gReviewerIndex= form.findCell("Reviewers").getCurrentRow();
	}
	
	
	/** fngetReviewer
	This function allows the user to add reviewers by clicking anywhere in the Reviewer List
	The function then automatically adds the reviewer to the first non-empty index of the 
	Reviewer list.
	**/
	fngetReviewer=function()
	{
		try
		{
		form.commit();
			var theCurrentRow = form.findCell("Reviewers").getCurrentRow();
			var lastRow=form.findCell("Reviewers").getVisibleRowCount();
			if(theCurrentRow==-1){theCurrentRow=form.findCell("Reviewers").getVisibleRowCount();};
			var ReviewerUserId=form.findCell("ReviewerUserId");
			
			var ReviewerLength=form.getCell("Reviewers").getValueAsString(theCurrentRow-1).length;
			if (ReviewerLength!=0)
				{
					var theReviewer=form.getCell("Reviewers").getValueAsString(gReviewerIndex);
 					ReviewerUserId.setValueFromString(theReviewer);
					//form.getCell("Reviewers").setValueFromString("SettingValue" + theCurrentRow,theCurrentRow-1);
					form.getCell("Reviewers").setValueFromString("",gReviewerIndex)
					var myResponse = ReviewerUserId.doLookup();
					var myDataArray = myResponse.getData();
					var theResponse=myResponse.getType();
					var myData;
					var i;
					if (myDataArray.length==0)
					{
						alert("No users could be found")
						form.getCell("Reviewers").setValueFromString("",gReviewerIndex)
					}else
					{
						//Let the user Select the value
						form.showQueryResponseDialog(myDataArray);
						
						if (form.getCell("Reviewers").getValueAsString(0)==""||form.getCell("Reviewers").getValueAsString(0)==theReviewer)
						{
							form.getCell("Reviewers").setValueFromString(ReviewerUserId.getValueAsString(),0);
							//Now clear the Review field 
							if(gReviewerIndex!=0)// If it's not the same as the field we just added to then delete the value from thefield that was entered into
							{
								form.getCell("Reviewers").setValueFromString("",gReviewerIndex)
							}
							form.setCurrentCell(form.findCell("HeaderExGST"));
							return;
						}
						if (form.getCell("Reviewers").getValueAsString(1)==""||form.getCell("Reviewers").getValueAsString(1)==theReviewer)
						{
							form.getCell("Reviewers").setValueFromString(ReviewerUserId.getValueAsString(),1);
							//Now clear the Review field 
							if(gReviewerIndex!=1) // If it's not the same as the field we just added to then delete the value from thefield that was entered into
							{
								form.getCell("Reviewers").setValueFromString("",gReviewerIndex)
							}
							form.setCurrentCell(form.findCell("HeaderExGST"));
							
							return;
						}
						if (form.getCell("Reviewers").getValueAsString(2)==""||form.getCell("Reviewers").getValueAsString(2)==theReviewer)
						{
							form.getCell("Reviewers").setValueFromString(ReviewerUserId.getValueAsString(),2);
							//Now clear the Review field 
							if(gReviewerIndex!=2)// If it's not the same as the field we just added to then delete the value from thefield that was entered into
							{
								form.getCell("Reviewers").setValueFromString("",gReviewerIndex)
							}
							form.setCurrentCell(form.findCell("HeaderExGST"));
						}
						
					}
				}
		}catch (err)
		{
			
			if (err.description !=undefined)
			{
				alert("The Error is " + err.description);
			}	
		}		
	}


	//validate the vendor on form Open
	validateVendor=function()
	
	{
		try{
		
			var VendorID=form.findCell("VendorID");
			
			var myResponse = VendorID.doLookup();
			var myDataArray = myResponse.getData();
			var theResponse=myResponse.getType();
			var myData;
			var i;

			if (myDataArray.length==0)
			{
				alert("This vendor could not be validated. Please correct before proceeding or send to AP")
				return;
			}else{
				//Now verify the rest of the Vendor details
				if (myDataArray[0].getValue("VendorName")!=form.findCell("VendorName").getValueAsString())
				{
					alert("Vendor Name details do not match. Please correct before proceeding.");
					return;
				}
				if (myDataArray[0].getValue("VendorSetID")!=form.findCell("VendorSetID").getValueAsString())
				{
					alert("Vendor SetID details do not match. Please correct  before proceeding.");
					form.findCell("VendorSetID").setValueFromString("");
					return;
				}
				if (form.getCell("DocumentType").getValueAsString()==DOC_STANDARD_INVOICE)
				{
					if (myDataArray[0].getValue("ABN_IRD")!=form.findCell("ABN_IRD").getValueAsString())
					{
						alert("ABN_IRD details do not match. Please correct before proceeding or send to AP.");
						return;
					}
				}

			}
		}catch (err){
			alert("The Error is " + err.description);
		}
	}	
	
	function validateHeaderSummary()
	{
		var HeaderExGST = parseFloat(form.getCell("HeaderExGST").getValueAsString());
		var HeaderGST = parseFloat(form.getCell("HeaderGST").getValueAsString());
		var HeaderTotal = parseFloat(form.getCell("HeaderTotal").getValueAsString());
		//var calculatedTotal=(Math.round((HeaderGST+HeaderExGST)*100)/100); //round to 2 decimal places
		var calculatedTotal=roundNumber((HeaderGST+HeaderExGST),2); // what the invoice total should be.
		
		if(calculatedTotal!=HeaderTotal)
		{
			alert ("There is an Error. Please correct Invoice Summary totals.");
			form.getCell("HeaderTotal").setValueFromString("0.00");
			return false ;
		}else{return true;}		
	}
	
	function  enableGST3()
	{
			//Disabling Line 1,2,4 and enable 3
			for (var i = 1;i<=4;i++)
			{
				if (i==3)
				{
					//form.findCell("ScenarioTotal"+i).setValue(new Value("0"));
					form.findCell("ScenarioTotal"+i).setEnabled(true);
					form.findCell("ScenarioDescription"+i).setEnabled(true);
					form.findButton("btngetXLS"+i).setEnabled(true);
					form.findCell("GLBU"+i).setEnabled(true);
					form.findCell("OU"+i).setEnabled(true);
					form.findCell("GLAccount"+i).setEnabled(true);
					form.findCell("Project"+i).setEnabled(true);
					form.findCell("Description"+i).setEnabled(true);
					form.findCell("Percentage"+i).setEnabled(true);
					form.findCell("Amount"+i).setEnabled(true);
				}else	{
					form.findCell("ScenarioTotal"+i).setValue(new Value("0"));
					form.findCell("ScenarioDescription"+i).clear();
					form.findCell("ScenarioTotal"+i).setEnabled(false);
					form.findCell("ScenarioDescription"+i).setEnabled(false);
					form.findButton("btngetXLS"+i).setEnabled(false);
					form.findCell("GLBU"+i).setEnabled(false);
					form.findCell("OU"+i).setEnabled(false);
					form.findCell("GLAccount"+i).setEnabled(false);
					form.findCell("Project"+i).setEnabled(true);
					form.findCell("Description"+i).setEnabled(false);
					form.findCell("Percentage"+i).setEnabled(false);
					form.findCell("Amount"+i).setEnabled(false);
				}				
			}				

	}
	function disableGST3()
	{
 			//Enabling Line 1
			for (var i = 1;i<=4;i++)
			{
				if (i==3)
				{
					form.findCell("ScenarioTotal"+i).setValue(new Value("0"));
					form.findCell("ScenarioTotal"+i).setEnabled(false);
					form.findCell("ScenarioDescription"+i).clear();
					form.findCell("ScenarioDescription"+i).setEnabled(false);
					form.findButton("btngetXLS"+i).setEnabled(false);
					form.findCell("GLBU"+i).setEnabled(false);
					form.findCell("OU"+i).setEnabled(false);
					form.findCell("GLAccount"+i).setEnabled(false);
					form.findCell("Project"+i).setEnabled(false);
					form.findCell("Description"+i).setEnabled(false);
					form.findCell("Percentage"+i).setEnabled(false);
					form.findCell("Amount"+i).setEnabled(false);
				}else	{
					//form.findCell("ScenarioTotal"+i).setValue(new Value("0"));
					form.findCell("ScenarioTotal"+i).setEnabled(true);
					form.findCell("ScenarioDescription"+i).setEnabled(true);
					form.findButton("btngetXLS"+i).setEnabled(true);
					form.findCell("GLBU"+i).setEnabled(true);
					form.findCell("OU"+i).setEnabled(true);
					form.findCell("GLAccount"+i).setEnabled(true);
					form.findCell("Project"+i).setEnabled(true);
					form.findCell("Description"+i).setEnabled(true);
					form.findCell("Percentage"+i).setEnabled(true);
					form.findCell("Amount"+i).setEnabled(true);
				}				
			}		

	}
	
	function enableAllGSTScenarios()
	{
		for (var i = 1;i<=4;i++)
		{
			//form.findCell("ScenarioTotal"+i).setValue(new Value("0"));
			form.findCell("ScenarioTotal"+i).setEnabled(true);
			form.findCell("ScenarioDescription"+i).setEnabled(true);
			form.findButton("btngetXLS"+i).setEnabled(true);
			form.findCell("GLBU"+i).setEnabled(true);
			form.findCell("OU"+i).setEnabled(true);
			form.findCell("GLAccount"+i).setEnabled(true);
			form.findCell("Project"+i).setEnabled(true);
			form.findCell("Description"+i).setEnabled(true);
			form.findCell("Percentage"+i).setEnabled(true);
			form.findCell("Amount"+i).setEnabled(true);
		}	
	
	}
	
	function lockdownGSTScenarios()
	{
	   var  GSTVal1=parseFloat(form.findCell("ScenarioTotal1").getValueAsString());
	   var  GSTVal2=parseFloat(form.findCell("ScenarioTotal2").getValueAsString());
	   var  GSTVal3=parseFloat(form.findCell("ScenarioTotal3").getValueAsString());
	   var  GSTVal4=parseFloat(form.findCell("ScenarioTotal4").getValueAsString());
		if ((GSTVal1 !=0||GSTVal2 !=0||GSTVal4 !=0  ) && GSTVal3 !=0) 
		{
				enableAllGSTScenarios();
				return;
				
		}else	if (GSTVal3==0)
		{
			disableGST3();
			return;
			
		}else if (GSTVal3!=0)
		{
			enableGST3();
		}	
	
	}	
	
	
	function cancelInvoice()
	// This function clears all the distributions for all GST Scenarios
	{
		try{
			gbCancel=true;
			clearHeaderFields();
			clearLineDistributions(1);
			clearGSTLines(1);
			clearLineDistributions(2);
			clearGSTLines(2);
			clearLineDistributions(3);
			clearGSTLines(3);
			clearLineDistributions(4);
			clearGSTLines(4);
			gbCancel=false;
			if (trimString(form.getCell("UserComment").getValueAsString())=="") // Check that the user has added a comment
			{
				alert ("Please add a comment before cancelling an invoice.");
				return false;
			}
			// Combines the comments on the form else it wont' show when workflow is completed
			storefinalComment();
			return true;
		}catch(err)
		{
			alert("There was an error cancelling the invoice")
			gbCancel=false
			return false;
		}
	}
	

	function clearHeaderFields()
	{
		
		try{
			form.getCell("HeaderExGST").setValue(new Value(0.00));
			form.getCell("HeaderGST").setValue(new Value(0.00));
			form.getCell("Headertotal").setValue(new Value(0.00));
		}catch(err)
		{
			alert("clearHeaderFields. " + err.description);
			return false;
		}
	}


	function clearGSTLines(tableid)
	{
		try{

				form.getCell("ScenarioTotal"+tableid).setValue(new Value(0.00));
				form.getCell("GST"+tableid).setValue(new Value(0.00));
				form.getCell("ScenarioDescription"+tableid).setValueFromString("");
		}catch(err)
		{
			alert("clearGSTLines. "+err.description);
			return false;
		}		
	}
	
	function clearLineDistributions(tableid)
	{	
		var numberOfRows=getFullRowCount("OU",tableid);
	try{
			for (var i=0;i<numberOfRows;i++)
			{
				var fldGLBU=form.getCell("GLBU"+tableid); 
					fldGLBU.clear(i);
					var fldProject=form.getCell("Project"+tableid); 	
					fldProject.clear(i);
				var fldOU=form.getCell("OU"+tableid); 	
					fldOU.clear(i);
				var fldDistribLine=form.getCell("DistribLine"+tableid); 	
					fldDistribLine.clear(i);
				var fldDescription=form.getCell("Description"+tableid); 
					fldDescription.clear(i);
				var fldGLAccount=form.getCell("GLAccount"+tableid); 	
					fldGLAccount.clear(i);
				var fldClass=form.getCell("Class"+tableid); 	
					fldClass.clear(i);
				var fldProduct=form.getCell("Product"+tableid); 	
					fldProduct.clear(i);
				var Percentage=form.getCell("Percentage"+tableid); 
					Percentage.setValueFromString("",i);
				var Amount=form.getCell("Amount"+tableid); 
					Amount.clear(i);
			}
		}catch(err)
		{
			alert("clearGSTLineDistributions. "+err.description);
			return false;
		}		
	}	

	

 	function validReviewerList()
	{
	
	var ReviewerUserId=form.getCell("ReviewerUserId");
		try{
			for (var i=0;i<MaxReviewers;i++)
			{
				var theReviewer=form.getCell("Reviewers").getValueAsString(i);
				// we need to modify the reviewer field in case it has apostophes in the value.
				// this needs tobeescaped for SQL Server....so
				var themodReviewer=theReviewer.replace("'","''");
				if (theReviewer !="")
				{
					ReviewerUserId.setValueFromString(themodReviewer);
					var myResponse = ReviewerUserId.doLookup();
					var myDataArray = myResponse.getData();
					var theResponse=myResponse.getType();
					var myData;
					//alert (form.getCell("ReviewerUserId").getValueAsString());
					if (myDataArray.length>=1) // There should only be one user
					{	
						for (i=0;i<=myDataArray.length-1;i++)
						{
							if (myDataArray[i].getValue("ReviewerUserId").toString().toLowerCase()==theReviewer.toString().toLowerCase())
							 {
								//alert("found a valid user");
								// user is valid accept iand move on
							 return true;
							}
						}
					alert ("Please correct Reviewer" + (i+1) + ". The value " +  theReviewer+ " is not valid.") 
						return false;
					}
				}
		
				
			}
		return true;
		}catch (err)
		{
		alert("There was an error - " + err.description + " - validating the Reviewer List. Please contact your administrator if this continues."); 
		}
	} 	

	function setLineDistributionNumbers(tableid)
	{
		var  numberOfRows;
	try{
			var numberOfRows=getFullRowCount("OU",tableid)
			for (i=0;i<numberOfRows;i++)
			{
				setDistribLine(tableid,i);
			}
		}catch(err)
		{
			alert("clearGSTLineDistributions. "+err.description);
			return false;
		}		
	}		
	
	
	function storefinalComment()
	{
		var CommentsIn = form.getCell("CommentsIn").getValueAsString();
		var CommentsOut = form.getCell("CommentsOut").getValueAsString();
		form.getCell("CommentsIn").setValueFromString(CommentsOut + CommentsIn);
		form.getCell("UserComment").clear();
		form.commit();
	}
	
	
	function help() 
	{
		var theurl = '<%=helpFile%>';
		window.open(theurl, "helpwindow",'toolbar=no, menu=yes, resizable=1,scrollbars=1');
	}


</script>
</head>
<body bgcolor="#E8E8E8">

</body>
</html>