package au.com.kabeus.ap.security;

import java.util.ArrayList;
import java.util.Iterator;
import org.apache.log4j.Logger;
import org.apache.log4j.xml.DOMConfigurator;

import com.filenet.api.collection.AccessPermissionList;
import com.filenet.api.collection.VersionableSet;
import com.filenet.api.constants.AccessLevel;
import com.filenet.api.constants.AccessRight;
import com.filenet.api.constants.AccessType;
import com.filenet.api.constants.PermissionSource;
import com.filenet.api.constants.RefreshMode;
import com.filenet.api.core.Connection;
import com.filenet.api.core.Document;
import com.filenet.api.core.Factory;
import com.filenet.api.core.ObjectStore;
import com.filenet.api.core.Versionable;

import com.filenet.api.security.AccessPermission;
import com.filenet.api.security.SecurityPolicy;
import com.filenet.api.util.Id;
import com.filenet.wcm.toolkit.util.WcmException;
import filenet.vw.api.VWAttachment;
import filenet.vw.api.VWSession;
import au.com.kabeus.ap.security.LoginUtilities;


/**
 * This class implements security for the Accounts Payable solution
 * @author Kemal Omar
 * @version 1.0
 *
 */
public class SecurityOperations {

	private static Logger logger = Logger.getLogger(SecurityOperations.class);


	public SecurityOperations() {

		DOMConfigurator.configure("log4j.xml");

	}	

	/**
	 *This methods simply tests that CM is working correctly by getting 
	 * either a VW or CE Connection
	 * @param theName Must specify either "VW" or "CE" to return a valid connection
	 * @return
	 *  Returns the CM Connection URI in the case of CM and PEConnection point in the case of PE
	 *  
	 */

	public String testCM(String theName) throws Exception
	{

		String theResult=null;
		try{
			if (theName.equalsIgnoreCase("VW"))
			{
				LoginUtilities loginUtils=new LoginUtilities();
				VWSession vwsession= loginUtils.getVWSessionConnection();
				theResult=vwsession.getConnectionPointName();

			}else if(theName.equalsIgnoreCase("CE"))
			{
				LoginUtilities loginUtils=new LoginUtilities();
				Connection conn = loginUtils.getCESessionConnection();
				theResult = conn.getURI();


			}else
			{
				theResult="NULL";
			}



		} catch (WcmException ex1) {
			logger.debug(ex1.getLocalizedMessage());
			throw (ex1);

		} catch (Exception ex2) {
			logger.debug(ex2.getLocalizedMessage());
			throw (ex2);
		}
		return theResult;

	}

	/**
	 * This assigns Read Only access to all of the versions of the document for all users of each version of the document
	 * @param theAttachments All of the documents that need to be updated
	 * @param granteeList if granteeList[0] = DIRECT_DEFAULT_USERS then all DIRECT, DEFAULT user permissions 
	 * will be updated to Read Only
	 * 
	 * @throws Exception
	 */

	public void assignAllVersionsReadOnly(VWAttachment[] theAttachments, String[] granteeList)

	{

		try {
			LoginUtilities loginUtils=new LoginUtilities();
			Connection conn = loginUtils.getCESessionConnection();
			com.filenet.api.core.Domain domain = com.filenet.api.core.Factory.Domain.fetchInstance(conn, null, null);

			for(int i = 0; i < theAttachments.length; i++)
			{
				if (theAttachments[i].getId()!=null) //the attachment is valid and not empty
				{
					logger.debug("Getting Document " + theAttachments[i].getAttachmentName());
					logger.debug("Version Series ID : " + theAttachments[i].getId());


					//now to get the id's of individual document versions

					ObjectStore os = com.filenet.api.core.Factory.ObjectStore.fetchInstance(domain, theAttachments[i].getLibraryName(), null);
					com.filenet.api.core.VersionSeries verSeriesObject = com.filenet.api.core.Factory.VersionSeries.fetchInstance(os, new Id(theAttachments[i].getId()), null);
					//we've got the version series now we can get each document.
					VersionableSet AllVersions = verSeriesObject.get_Versions();


					//Versionable CurrentVersion;
					Iterator<?> VersionIterator = AllVersions.iterator();
					while (VersionIterator.hasNext() )
					{
						Versionable CurrentVersion = (Versionable) VersionIterator.next();

						//Now get the document
						Document thedoc=(Document) CurrentVersion;				
						//theID=theID + ":"+ thedoc.get_Id();
						logger.debug("Got Version :"+thedoc.get_MajorVersionNumber());
						int accessMask= AccessLevel.VIEW.getValue();
						AccessType accessType=AccessType.ALLOW;

						logger.debug("Updating permissions to :" + AccessLevel.VIEW.toString());

						modifyDocumentPermissions(thedoc, granteeList, accessMask, accessType);
						thedoc.refresh();

						logger.debug("***********************************END************************************");

					}



				}else
				{

					logger.debug("the item " + i + " in the " + theAttachments.toString()+ " list is empty");

				}


			}

		} catch (WcmException ex1) {
			logger.error(ex1.getLocalizedMessage());
			//throw (ex1);

		} catch (Exception ex2) {
			logger.error(ex2.getLocalizedMessage());
			//throw (ex2);
		}

	}

	/**
	 *  Assigns users read only access to the document
	 * @param theAttachment The document attachment that users are given access to
	 * @param granteeList the grantee list
	 * @see {@link #assignAllVersionsReadOnly}
	 * @throws Exception
	 */

	public void assignUsers(VWAttachment theAttachment, String[] granteeList) throws Exception
	{
		try{

			VWAttachment[] theDocAttachment={theAttachment};

			assignAllVersionsReadOnly(theDocAttachment, granteeList);

		}catch (Exception e){
			logger.error(e.getMessage());
			throw(e);
		}		

	}	
	/**
	 * Assigns all grantees in the grantee list readOnly permissions to the document.
	 * @param theAttachment The document that will be modified
	 * @param granteeList The grantee list
	 * @see {@link #assignAllVersionsReadOnly(VWAttachment[], String[])}
	 * @throws Exception
	 */

	public void assignUsersReadOnly(VWAttachment theAttachment, String[] granteeList) throws Exception

	{
		try{

			VWAttachment[] theDocAttachment={theAttachment};

			assignAllVersionsReadOnly(theDocAttachment, granteeList);

		}catch (Exception e){
			logger.error(e.getMessage());
			throw(e);
		}
	}

	/**
	 * Adds a security policy to all versions of a document
	 * @param theAttachments The list of documents that the security policy is applied to
	 * @param secPolicyGuid the ID/GUID of the security policy
	 */
	public void applySecurityPolicy(VWAttachment[] theAttachments, String secPolicyGuid)
	{

		try {

			LoginUtilities loginUtils=new LoginUtilities();
			Connection conn = loginUtils.getCESessionConnection();
			com.filenet.api.core.Domain domain = com.filenet.api.core.Factory.Domain.fetchInstance(conn, null, null);

			for(int i = 0; i < theAttachments.length; i++)
			{
				if (theAttachments[i].getId()!=null) //the attachment is valid and not empty
				{
					logger.debug("Getting Document " + theAttachments[i].getAttachmentName());
					logger.debug("Version Series ID : " + theAttachments[i].getId());



					ObjectStore os = com.filenet.api.core.Factory.ObjectStore.fetchInstance(domain, theAttachments[i].getLibraryName(), null);
					com.filenet.api.core.VersionSeries verSeriesObject = com.filenet.api.core.Factory.VersionSeries.fetchInstance(os, new Id(theAttachments[i].getId()), null);

					SecurityPolicy secPolicy= Factory.SecurityPolicy.fetchInstance(os, new Id(secPolicyGuid), null);						

					//we've got the version series now we can get each document.
					VersionableSet AllVersions = verSeriesObject.get_Versions();


					//Versionable CurrentVersion;
					Iterator<?> VersionIterator = AllVersions.iterator();
					while (VersionIterator.hasNext() )
					{
						Document thedoc= (Document) VersionIterator.next();

						thedoc.set_SecurityPolicy(secPolicy);
						logger.debug("Removed sec policy " + secPolicyGuid + "from " + thedoc.get_Id() );
						thedoc.save(RefreshMode.REFRESH);
					}



				}else
				{

					logger.debug("The item " + i + " in the " + theAttachments[i].getAttachmentName()+ " list is empty");

				}


			}

		} catch (WcmException ex1) {
			logger.debug(ex1.getLocalizedMessage());


		} catch (Exception ex2) {
			logger.debug(ex2.getLocalizedMessage());

		}


	}

	/**
	 * Assigns all grantees major version + modify permissions to the document. Calls {@link #modifyDocumentPermissions}
	 * @param theAttachment The document to be updated
	 * @param newGrantees The grantee list 
	 * @throws Exception
	 */

	public void assignUsersMajorVersioning(VWAttachment theAttachment,String[] newGrantees) throws Exception

	{
		try {
			if (theAttachment.getId()!=null) //the attachment is valid and not empty
			{
				logger.debug("Getting Document " + theAttachment.getAttachmentName());
				LoginUtilities loginUtils=new LoginUtilities();
				Connection conn = loginUtils.getCESessionConnection();
				com.filenet.api.core.Domain domain = com.filenet.api.core.Factory.Domain.fetchInstance(conn, null, null);

				logger.debug("Version Series ID : " + theAttachment.getId());


				//now to get the id's of individual document versions

				ObjectStore os = com.filenet.api.core.Factory.ObjectStore.fetchInstance(domain, theAttachment.getLibraryName(), null);
				com.filenet.api.core.VersionSeries verSeriesObject = com.filenet.api.core.Factory.VersionSeries.fetchInstance(os, new Id(theAttachment.getId()), null);
				//we've got the version series now we can get each document.
				VersionableSet AllVersions = verSeriesObject.get_Versions();

				//Versionable CurrentVersion;
				@SuppressWarnings("unchecked")
				Iterator<VersionableSet> VersionIterator =  AllVersions.iterator();
				while (VersionIterator.hasNext() )
				{
					Versionable CurrentVersion = (Versionable) VersionIterator.next();

					//Now get the document
					Document thedoc=(Document) CurrentVersion;				

					//theID=theID + ":"+ thedoc.get_Id();
					logger.debug("Got Doc..." + thedoc.get_Id() + " Version :"+thedoc.get_MajorVersionNumber());

					int accessMask = AccessLevel.MAJOR_VERSION_DOCUMENT.getValue()| AccessRight.WRITE_ACL.getValue();
					AccessType accessType=AccessType.ALLOW;

					logger.debug("Updating permissions to "+ AccessLevel.MAJOR_VERSION_DOCUMENT.toString() +":"+  AccessRight.WRITE_ACL.toString());
					modifyDocumentPermissions(thedoc, newGrantees, accessMask, accessType);

				}



			}else
			{

				logger.debug("The attachment " + theAttachment.getAttachmentName()+ " is empty");

			}



		} catch (WcmException ex1) {
			logger.debug(ex1.getLocalizedMessage());
			throw (ex1);

		} catch (Exception ex2) {
			logger.debug(ex2.getLocalizedMessage());
			throw (ex2);
		}


	}

	/**
	 * Updates all direct & default permissions on the document. 
	 * Called from {@link #modifyDocumentPermissions}
	 * @param thedoc The document to be updated
	 * @param accessMask The access mask that is applied
	 * @param accessType The type of access given to the grantee
	 * @throws Exception
	 * 
	 */

	@SuppressWarnings("unchecked")
	private void updateDefaultDirectPermissions(Document thedoc, int accessMask, AccessType accessType) throws Exception

	{

		try {

			AccessPermissionList docPermissions= getDirectDefaultPermissionsList(thedoc);


			logger.debug("Got the user List");


			//now add the collection of users

			AccessPermissionList newPermissionsList = Factory.AccessPermission.createList();

			for (Iterator<AccessPermission> ap = docPermissions.iterator(); ap.hasNext();) 
			{
				AccessPermission userPermission = ap.next();				
				AccessPermission newAP=Factory.AccessPermission.createInstance();

				/************************************
				docPermissions.remove(userPermission);
				thedoc.set_Permissions(docPermissions);
				//Not sure you have to remove the old permission
				 **************************************/
				// Now add the new permission.
				newAP.set_GranteeName(userPermission.get_GranteeName());
				newAP.set_AccessMask(accessMask);
				newAP.set_AccessType(accessType);            
				// Add the permissions to the list.
				logger.debug("Updating "+ userPermission.get_GranteeName() + thedoc.get_Id());
				newPermissionsList.add(newAP);
			}
			thedoc.set_Permissions(newPermissionsList);
			thedoc.save(RefreshMode.REFRESH);

		} catch (Exception e) {
			logger.error(e.getMessage());
			throw (e);
		}		 

	}



	/**
	 * Modify a document's permissions. 
	 * Called from {@link #assignAllVersionsReadOnly },
	 * {@link #assignUsersMajorVersioning}
	 * @param thedoc The document to be updated
	 * @param newGrantees All of the grantees that need to be added/modified. A single array value of DIRECT_DEFAULT_USERS 
	 * updates the permissions for all direct and default assigned users
	 * @param accessMask {@link AccessLevel} The access mask that is applied
	 * @param accessType {@link AccessType}The type of access given to the grantee }
	 * 
	 * @return void
	 * 
	 * @throws Exception
	 * 
	 * 
	 */

	@SuppressWarnings("unchecked")
	private void modifyDocumentPermissions(Document thedoc,String[] newGrantees, int accessMask, AccessType accessType) throws Exception

	{

		try {
			//All default direct users' modification needs to be altered.
			if (newGrantees.length>0 && newGrantees[0].toString().equalsIgnoreCase("DIRECT_DEFAULT_USERS"))
			{
				updateDefaultDirectPermissions(thedoc, accessMask, accessType);
			}else
			{
				//We've got a list of users.get their permissions
				AccessPermissionList docPermissions= getDirectDefaultPermissionsList(thedoc);

				logger.debug("Got the user List : "+docPermissions.size());


				AccessPermissionList newPermissionsList = Factory.AccessPermission.createList();
				ArrayList<String> processedUsers=new ArrayList<String>();

				if(docPermissions.size()>0) // There are permissions on the document
				{
					for (Iterator<AccessPermission> ap = docPermissions.iterator(); ap.hasNext();) 
					{
						AccessPermission userPermission = ap.next();

						for(int i = 0; i < newGrantees.length; i++)
						{
							//Need to match the Grantee login ( that's passed from BPM with the principal name of the user on the document
							String theGranteelogin=(String)userPermission.get_GranteeName().subSequence(0,userPermission.get_GranteeName().indexOf("@"));

							if(theGranteelogin.equalsIgnoreCase(newGrantees[i]))// User is already there then just change the accessmask
							{
								logger.debug("Existing Grantee : " + userPermission.get_GranteeName());

								userPermission.set_AccessMask( accessMask);
								userPermission.set_AccessType(accessType);
								processedUsers.add(new String(newGrantees[i]));
								logger.debug("Updating "+ userPermission.get_GranteeName() + " permissions doc : " + thedoc.get_Id());
							}
							// Add the permissions to the list.
							newPermissionsList.add(userPermission);
							thedoc.set_Permissions(newPermissionsList);
						}				 
						thedoc.save(RefreshMode.REFRESH);

					}

				}else // there are no permissions on the document. So all of the grantees need to be added to the document
				{
					for(int i = 0; i < newGrantees.length; i++)
					{
						logger.debug("All grantees are new");
						AccessPermission newAP=Factory.AccessPermission.createInstance();
						newAP.set_GranteeName(newGrantees[i]);
						newAP.set_AccessMask(accessMask);
						newAP.set_AccessType(AccessType.ALLOW);  
						newPermissionsList.add(newAP);
						processedUsers.add(new String(newGrantees[i]));
						logger.debug("Updating "+newGrantees[i] + " permissions to Major Version on doc : " + thedoc.get_Id());

					}

					thedoc.set_Permissions(newPermissionsList);

				}
				//Now save the document
				thedoc.save(RefreshMode.REFRESH);

				//Now process all of the users that were not added to the document

				logger.debug(" Now adding all of the other grantees");
				for(int i = 0; i < newGrantees.length; i++)
				{
					boolean processed=false;

					for(int p = 0; p < processedUsers.size(); p++)
					{
						if(processedUsers.get(p).toString().equalsIgnoreCase(newGrantees[i].toString()))
						{
							//logger.debug(newGrantees[i] + "already added");// User already added.
							processed=true;

						}
					}

					if(processed==false)
					{
						AccessPermission newAP=Factory.AccessPermission.createInstance();
						newAP.set_GranteeName(newGrantees[i]);
						newAP.set_AccessMask(accessMask);
						newAP.set_AccessType(AccessType.ALLOW);  
						newPermissionsList.add(newAP);
						logger.debug("Adding "+newGrantees[i] + " to doc : " + thedoc.get_Id());
						thedoc.set_Permissions(newPermissionsList);
						thedoc.save(RefreshMode.NO_REFRESH);						
					}


				}

			}

			logger.debug("Completed modifyDocumentPermissions");
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage());
			throw (e);
		}		 

	}

	/**
	 * 
	 * Retrieves all direct or default user permissions.
	 * called from {@link #modifyDocumentPermissions},{@link #updateDefaultDirectPermissions} 
	 *  @param  thedoc {@link com.filenet.api.core.Factory.Document}
	 *
	 * @return {@link AccessPermissionList}
	 * @throws Exception
	 */
	@SuppressWarnings("unchecked")
	private  AccessPermissionList getDirectDefaultPermissionsList(Document thedoc) throws Exception

	{
		AccessPermissionList docPermissions=Factory.AccessPermission.createList();


		try {
			AccessPermissionList thePermissionsList = thedoc.get_Permissions();

			Iterator<?> itr =thePermissionsList.iterator();
			//docPermissions = new HashSet<AccessPermission>(); 
			while(itr.hasNext()) {

				AccessPermission userPermission = (AccessPermission) itr.next(); 


				PermissionSource myperms=userPermission.get_PermissionSource();

				if (myperms.equals(PermissionSource.SOURCE_DIRECT) ||myperms.equals(PermissionSource.SOURCE_DEFAULT) )
				{
					//logger.debug ("will update " +userPermission.get_GranteeName()+" from the list");

					docPermissions.add(userPermission);


				}
			}


			return docPermissions; 

		} catch (Exception e) {
			logger.error(e.getLocalizedMessage());
			throw(e);
		}

	}	 

	/**
	 * Removes the grantee list from all versions of all documents specified in granteeList arrays}
	 * @param theAttachments The list of documents to be updated.
	 * @param granteeList set of users whose permissions are remove
	 */


	@SuppressWarnings("unchecked")
	public void removeUsersAllVersions(VWAttachment[] theAttachments, String[] granteeList)
	{

		try
		{
			LoginUtilities loginUtils=new LoginUtilities();
			Connection conn = loginUtils.getCESessionConnection();
			com.filenet.api.core.Domain domain = com.filenet.api.core.Factory.Domain.fetchInstance(conn, null, null);

			for (int i = 0; i < theAttachments.length; i++)
			{
				if (theAttachments[i].getId() != null) // the attachment is
					// valid and not empty
				{
					logger.debug("Getting Document " + theAttachments[i].getAttachmentName() +":: Version Series ID:" + theAttachments[i].getId());

					// now to get the id's of individual document versions

					ObjectStore os = com.filenet.api.core.Factory.ObjectStore.fetchInstance(domain, theAttachments[i].getLibraryName(), null);
					com.filenet.api.core.VersionSeries verSeriesObject = com.filenet.api.core.Factory.VersionSeries.fetchInstance(os, new Id(theAttachments[i].getId()), null);

					// we've got the version series now we can get document.

					//Iterator<Versionable>docversion=verSeriesObject.get_Versions().iterator();

					for (Iterator<Versionable> docVersion = verSeriesObject.get_Versions().iterator(); docVersion.hasNext();) 
					{
						Document thedoc = (Document)docVersion.next();
						removeDocumentPermissions(thedoc, granteeList);
					}
				}
			}
		} catch (WcmException fe)
		{
			logger.error(fe.getMessage());

		} catch (Exception e)
		{
			logger.error(e.getMessage());

		}

	}

	/**
	 * Removes users from a document
	 * @param theAttachment The attached document
	 * @param granteeList The user set that needs to be removed from the document

	 * @return void
	 * @throws Exception
	 */

	@SuppressWarnings("unchecked")
	public void removeUsers(VWAttachment theAttachment, String[] granteeList) throws Exception
	{


		try {

			// First get the document.
			logger.debug("Getting Document " + theAttachment.getAttachmentName());

			LoginUtilities loginUtils=new LoginUtilities();
			Connection conn = loginUtils.getCESessionConnection();
			logger.debug("Version Series ID : " + theAttachment.getId());


			//now to get the id's of individual document versions

			com.filenet.api.core.Domain domain = com.filenet.api.core.Factory.Domain.fetchInstance(conn, null, null);
			ObjectStore os = com.filenet.api.core.Factory.ObjectStore.fetchInstance(domain, theAttachment.getLibraryName(), null);
			com.filenet.api.core.VersionSeries verSeriesObject = com.filenet.api.core.Factory.VersionSeries.fetchInstance(os, new Id(theAttachment.getId()), null);

			//we've got the version series now we can get document.
			Document thedoc=(Document)verSeriesObject.get_ReleasedVersion();



			AccessPermissionList docPermissions= getDirectDefaultPermissionsList(thedoc);


			logger.debug("Got the user List");


			//now add the collection of users
			AccessPermissionList removePermissionsList = Factory.AccessPermission.createList();
			for (Iterator<AccessPermission> ap = docPermissions.iterator(); ap.hasNext();) 
			{
				AccessPermission userPermission = ap.next();

				String theGranteelogin=(String)userPermission.get_GranteeName().subSequence(0,userPermission.get_GranteeName().indexOf("@"));


				for (int m=0;m<granteeList.length;m++)
				{
					if(theGranteelogin.equalsIgnoreCase(granteeList[m]))// User is already there then just change the accessmask
					{
						//remove the user from the lis
						logger.debug("removing " + granteeList[m] + " from the document ");
						removePermissionsList.add(userPermission);
					}


				}
			}
			docPermissions.removeAll(removePermissionsList);
			thedoc.set_Permissions(docPermissions);

			thedoc.save(RefreshMode.REFRESH);

		}
		catch (Exception e) {
			logger.error(e.getMessage());
			throw (e);
		}		 


	}
	/**
	 * Removes the Specified security policy from all versions of a document
	 * @param theAttachments - The list of documents the policy is to be removed from
	 * @param secPolicyGuid The ID/GUID of the security policy
	 * @throws Exception
	 */
	public void removeSecurityPolicy(VWAttachment[] theAttachments, String secPolicyGuid) throws Exception
	{

		try {


			LoginUtilities loginUtils=new LoginUtilities();
			Connection conn = loginUtils.getCESessionConnection();
			com.filenet.api.core.Domain domain = com.filenet.api.core.Factory.Domain.fetchInstance(conn, null, null);

			for(int i = 0; i < theAttachments.length; i++)
			{
				if (theAttachments[i].getId()!=null) //the attachment is valid and not empty
				{
					logger.debug("Getting Document " + theAttachments[i].getAttachmentName());
					logger.debug("Version Series ID : " + theAttachments[i].getId());



					ObjectStore os = com.filenet.api.core.Factory.ObjectStore.fetchInstance(domain, theAttachments[i].getLibraryName(), null);
					com.filenet.api.core.VersionSeries verSeriesObject = com.filenet.api.core.Factory.VersionSeries.fetchInstance(os, new Id(theAttachments[i].getId()), null);


					//we've got the version series now we can get each document.
					VersionableSet AllVersions = verSeriesObject.get_Versions();


					//Versionable CurrentVersion;
					Iterator<?> VersionIterator = AllVersions.iterator();
					while (VersionIterator.hasNext() )
					{
						Document thedoc= (Document) VersionIterator.next();

						thedoc.set_SecurityPolicy(null);
						thedoc.save(RefreshMode.REFRESH);
						logger.debug("Removed sec policy " + secPolicyGuid + "from " + thedoc.get_Id() );
					}

				}else
				{

					logger.debug("the item " + i + " in the " + theAttachments[i].getAttachmentName()+ " list is empty");

				}


			}

		} catch (WcmException ex1) {
			logger.debug(ex1.getLocalizedMessage());
			throw(ex1);


		} catch (Exception ex2) {
			logger.debug(ex2.getLocalizedMessage());
			throw(ex2);

		}


	}

	/**
	 * Removes user permissions from a document. 
	 * Called from {@link #removeUsersAllVersions,#removeUsers},
	 * {@link #assignUsersMajorVersioning}
	 * @param thedoc The document to be updated
	 * @param granteeList All of the grantees that need to be added/modified. A single array value of DIRECT_DEFAULT_USERS 
	 * removes all direct and default assigned users
	 * 
	 * @return void
	 * 
	 * @throws{@link Exception,WcmException}
	 * 
	 * 
	 */

	@SuppressWarnings("unchecked")
	private void removeDocumentPermissions(Document thedoc,String[] granteeList) throws WcmException,Exception

	{

		logger.debug("removing Permissions from version : " + thedoc.get_MajorVersionNumber());

		try {
			AccessPermissionList docPermissions= getDirectDefaultPermissionsList(thedoc);
			AccessPermissionList removePermissionsList= Factory.AccessPermission.createList();

			logger.debug("Got the user List : "+docPermissions.size());
			//All default direct users' modification needs to be altered.

			if (granteeList.length>0 && granteeList[0].toString().equalsIgnoreCase("DIRECT_DEFAULT_USERS"))
			{

				logger.debug ("Removing all default direct permissions");

				for (Iterator<AccessPermission> ap = docPermissions.iterator(); ap.hasNext();) 
				{
					AccessPermission userPermission = ap.next();

					logger.debug ("Removing : " + userPermission.get_GranteeName());
					removePermissionsList.add(userPermission);

				}
				docPermissions.removeAll(removePermissionsList);
				thedoc.set_Permissions(docPermissions);
				thedoc.save(RefreshMode.REFRESH);
				logger.debug ("Done");



			}else
			{
				//We've got a list of users... so delete them
				logger.debug ("Removing individual permissions");


				if(docPermissions.size()>0) // There are permissions on the document
				{
					for (Iterator<AccessPermission> ap = docPermissions.iterator(); ap.hasNext();) 
					{
						AccessPermission userPermission = ap.next();

						for(int i = 0; i < granteeList.length; i++)
						{
							//Need to match the Grantee login ( that's passed from BPM with the principal name of the user on the document

							String theGranteelogin=(String)userPermission.get_GranteeName().subSequence(0,userPermission.get_GranteeName().indexOf("@"));

							if(theGranteelogin.equalsIgnoreCase(granteeList[i]))// User is already there then just change the accessmask
							{
								logger.debug("Removing existing Grantee : " + userPermission.get_GranteeName());
								removePermissionsList.add(userPermission);
							}
							docPermissions.removeAll(removePermissionsList);
							thedoc.set_Permissions(docPermissions);

						}				 
					}
				}

				//Now save the document
				thedoc.save(RefreshMode.REFRESH);

			}

		} catch (WcmException  fe) {
			logger.error(fe.getLocalizedMessage());
			throw(fe);
		} catch (Exception e) {
			logger.error(e.getLocalizedMessage());
			throw(e);
		}		 

	}
}
