package au.com.kabeus.ap.security;

import java.util.HashMap;
import java.util.Set;

import org.apache.log4j.xml.DOMConfigurator;

import com.filenet.api.core.Connection;
import com.filenet.api.util.UserContext;
import com.filenet.wcm.api.Session;
import com.filenet.wcm.toolkit.server.operations.util.opsUtil;
import com.filenet.wcm.toolkit.util.WcmException;

import filenet.vw.api.VWSession;

/**
 * Retrieves p8 Logins for CE and PE
 */

class LoginUtilities
{

	LoginUtilities() {

		DOMConfigurator.configure("log4j.xml");
	}

	/**
	 * Retrieves a CE connection from the JAAS login
	 * @param {@link Connection};
	 * @return com.filenet.api.core.Factory.Connection
	 * @throws WcmException 
	 */

	Connection getCESessionConnection() throws WcmException
	{

		Session ceSession= null;
		opsUtil objOpsUtil = new opsUtil();
		ceSession = objOpsUtil.getSession();
		String token = ceSession.getToken();
		HashMap<?,?> tokenMap = ceSession.fromToken(token);
		String userName = (String)tokenMap.get("userid");
		String password = (String)tokenMap.get("password");
		String ceURI= System.getProperty("filenet.pe.bootstrap.ceuri");
		Connection conn = com.filenet.api.core.Factory.Connection.getConnection(ceURI);
		UserContext uc = UserContext.get();
		javax.security.auth.Subject subject = UserContext.createSubject(conn, userName, password, null);
		uc.pushSubject(subject);
		return conn;
	}	

/**
 * Retrieves a VWSession from the JAAS Login
 * @return {@link VWSession};
 * @throws ClassNotFoundException
 */

	VWSession getVWSessionConnection() throws ClassNotFoundException 
	{

		UserContext uc = UserContext.get();
		javax.security.auth.Subject subject = UserContext.getAmbientSubject();
		uc.pushSubject(subject);
		Set<?> creds=subject.getPrivateCredentials(Class.forName("filenet.vw.api.VWSession"));
		VWSession vwsession=(VWSession) creds.iterator().next();
		return vwsession;
	}




}	
