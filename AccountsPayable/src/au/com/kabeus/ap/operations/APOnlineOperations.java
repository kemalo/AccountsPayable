/**
 * @author Kemal Omar
 *  =============================================
	Author:		Kemal Omar
	Create date: 11/11/2011
	Description:	Procedure to retrieve all users 
	that are CLOB Data 
	This information is copyrighted material
	any unauthorized can result in legal action
	by kodeIT Solutions 
	=============================================
 *
 */
package au.com.kabeus.ap.operations;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.CallableStatement;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import filenet.vw.api.VWAttachment;
import org.apache.log4j.Logger;
import org.apache.log4j.xml.DOMConfigurator;

// tis is just a test

public class APOnlineOperations {
	private static Logger logger = Logger.getLogger(APOnlineOperations.class);
	private static String propsFile = "APOnline.properties";

	public APOnlineOperations() {

		DOMConfigurator.configure("log4j.xml");

	}

	public String testCI(String theName) 
	{

		logger.debug("get CE Connection");
		String DBConnectionUrl = null;
		try {
			Utilities Utilities=new Utilities();
			DBConnectionUrl = Utilities.getProperty("DBConnectionUrl",	propsFile);
			
			
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage());
		}

		return DBConnectionUrl;
	}

	/**
	 * Retrieves Invoice data in the form of XML document from
	 * SQLServer. Requires loginModule user to have 'SQL Server' authentication
	 * to APOnline DB
	 * 
	 * @param BusinessUnit
	 * @param VendorID
	 * @param InvoiceID
	 * @return String XML doc for Upload to PeopleSoft
	 * @throws Exception
	 *  
	 */
	public String getCLOBData(String BusinessUnit, String VendorID,	String InvoiceID) throws Exception 
	{

		String PSAPXML = null;

		try {

			// First get the login info..

			logger.debug("getting login credentials");

						 			
			logger.debug("instantiating jtds driver");
			Class.forName("net.sourceforge.jtds.jdbc.Driver");

			Utilities Utilities=new Utilities();
			String DBConnectionUrl = Utilities.getProperty("DBConnectionUrl",
					propsFile);
			logger.debug("DBConnectionUrl =" + DBConnectionUrl);

			String connectionUrl=DBConnectionUrl;

			logger.debug("getting a db connection");
			java.sql.Connection theconnection = DriverManager
					.getConnection(connectionUrl);

			CallableStatement cs = theconnection
					.prepareCall("exec usp_getPSAPXML(?,?,?,?)");
			cs.registerOutParameter(4, java.sql.Types.CLOB);
			cs.setString(1, BusinessUnit);
			cs.setString(2, VendorID);
			cs.setString(3, InvoiceID);

			logger.debug("executing stored proc");

			ResultSet rs = cs.executeQuery();
			while (rs.next()) {
				logger.debug("Getting the results");
				PSAPXML = rs.getString(1);
				logger.debug("Got the results");

			}			
			
			
			theconnection.close();
			return PSAPXML;

		} catch (ClassNotFoundException e) {
			logger.error(e.getLocalizedMessage());
			throw (e);
		} catch (SQLException e) {
			logger.error(e.getLocalizedMessage());
			throw (e);

		}

	}

	/**
	 * Save the XML resultset as a file on network drive
	 * @see getCLOBData{@link} getCLOBData
	 * @param fileLocation
	 * @param fileName
	 * @param PSAPXML
	 * @throws IOException
	 * 
	 */
	public String saveXMLfile(String fileLocation, String fileName,	String PSAPXML) throws IOException
	
	{

		try {
			String file_name = fileLocation + "\\" + fileName;
			
			logger.debug("writing out to file" + file_name);
			FileWriter file = new FileWriter(file_name);
			BufferedWriter out = new BufferedWriter(file);
			out.write(PSAPXML);
			out.close();
			file.close();
			logger.debug("Completed");
			return "success";
		} catch (IOException e) 
		{
			logger.error(e.getLocalizedMessage());
			throw (e);
		}
	}

	/**
	 * Retrieve the document id. this is not provided natively
	 * @param docAttachment
	 * @return
	 * @throws Exception
	 * 
	 */
	public String getDocumentId(VWAttachment docAttachment) throws Exception 
	{

		try {

			return docAttachment.getId();

		} catch (Exception ex) {
			ex.printStackTrace();
			logger.info(ex.getLocalizedMessage().toString());
			throw (ex);
		}
	}

	public String[] getIncompleteReviewers(String[] Reviewers,	boolean[] CompletedReviews) throws Exception 
	{

		String[] NullReviews = {""};
		String strIncompleteReviews = null;
		logger.debug("Getting escalated Reviews");
		try {

			for (int rcount = 0; rcount < Reviewers.length; rcount++)

			{
				logger.debug("rcount - " + rcount);
				if (!CompletedReviews[rcount]) {
					logger.debug("incomplete - " + CompletedReviews[rcount]);
					if (strIncompleteReviews == ""
							|| strIncompleteReviews == null) {
						strIncompleteReviews = Reviewers[rcount] + "~";
					} else {
						strIncompleteReviews = strIncompleteReviews + "~"
								+ Reviewers[rcount];

					}

				}

			}

			if (strIncompleteReviews == null || strIncompleteReviews.equals("")) {
				logger.debug("No Incomplete Reviewers - Returning Null");
				return NullReviews;
			} else {
				logger.debug("Incomplete Reviewers - " + strIncompleteReviews);
				return strIncompleteReviews.split("~");
			}
		} catch (Exception ex) {
			ex.printStackTrace();
			logger.error(ex.getLocalizedMessage().toString());
			throw (ex);
		}
	}
	
	/**
	 * Convert the given array to an array with unique values
	 * @see getUniqueArray{@link} getUniqueArray
	 * @param theArray
	 * @throws IOException
	 * 
	 */
	public String[] getUniqueArray(String[] theArray) throws Exception
	//
	{
		try {

			for (int i = 0; i < theArray.length; i++) {
				logger.debug("Index = " + ":: Value " + theArray[i]);
			}
			
			
			String[] temp = new String[theArray.length];
			for (int i = 0; i < temp.length; i++) {
				temp[i] ="";// in case u have value of 0 in he array
			}
			int counter = 0;
			for (int i = 0; i < theArray.length; i++) {
				if (isUnique(temp, theArray[i]))
					temp[counter++] = theArray[i];
			}
			String[] uniqueArray = new String[counter];
			System.arraycopy(temp, 0, uniqueArray, 0, uniqueArray.length);
			return uniqueArray;
		} catch (Exception ex) {
			
			ex.printStackTrace();
			logger.error(ex.getLocalizedMessage().toString());
			throw (ex);

		}
	}


	// Print given array
	private static void printArray(int[] array)
	{
		for (int i = 0; i < array.length; i++) {
			System.out.print(array[i] + " ");
		}
		System.out.println("");
	}

	// Return true if number
	// num is appeared only
	// once in the array –
	// num is unique.	
	private static boolean isUnique(String[] arry, String Val)
	{
		for (int i = 0; i < arry.length; i++) {
			if (arry[i].equalsIgnoreCase(Val)) {
				return false;
			}
		}
		return true;
	}

}
