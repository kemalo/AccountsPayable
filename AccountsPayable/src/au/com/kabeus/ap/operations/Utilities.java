/**
 * 
 */
package au.com.kabeus.ap.operations;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;

import org.apache.log4j.Logger;

import com.filenet.api.core.Connection;
import com.filenet.api.util.UserContext;
import com.filenet.wcm.toolkit.server.operations.util.opsUtil;

/**
 * @author Kemal Omar
 * 
 */
class Utilities {

	private static String username = null;
	private static String password = null;
	private static String uri = null;
	private static String stanza = null;
	private static String theos = null;

	static java.util.Properties getProperties(String propsFile)
			throws IOException {
		try {
			
		
			InputStream propertyStream = Thread.currentThread()
					.getContextClassLoader().getResourceAsStream("/"+propsFile);
			java.util.Properties thepropsfile = new java.util.Properties();
			thepropsfile.load(propertyStream);
			username = thepropsfile.getProperty("username");
			thepropsfile.put("username", username);
			password = thepropsfile.getProperty("password");
			thepropsfile.put("password", password);
			uri = thepropsfile.getProperty("uri");
			thepropsfile.put("uri", uri);
			stanza = thepropsfile.getProperty("stanza");
			thepropsfile.put("stanza", stanza);
			theos = thepropsfile.getProperty("objectstore");
			thepropsfile.put("theos", theos);
			propertyStream.close();
			return thepropsfile;
		} catch (IOException e) {
			throw e;
		}
	}

	String getProperty(String PropertyName, String propsFile)
			throws IOException {
		try {
			//InputStream propertyStream = Thread.currentThread().getClass().getResourceAsStream("/"+propsFile);
			InputStream propertyStream = getClass().getResourceAsStream("/"+propsFile);

			java.util.Properties thepropsfile = new java.util.Properties();
			thepropsfile.load(propertyStream);
			return thepropsfile.getProperty(PropertyName);
		} catch (IOException e) {
			throw e;
		}
	}

	static Connection getSessionConnection(Logger logger) throws Exception {

		opsUtil objOpsUtil = new opsUtil();
		com.filenet.wcm.api.Session ceSession;

		logger.debug("Getting Opsutil Session");
		ceSession = objOpsUtil.getSession();

		logger.debug("Getting getSessionConnection");

		String token = ceSession.getToken();
		HashMap<?, ?> tokenMap = ceSession.fromToken(token);
		username = (String) tokenMap.get("userid");
		password = (String) tokenMap.get("password");
		String ceURI = System.getProperty("filenet.pe.bootstrap.ceuri");

		Connection conn = com.filenet.api.core.Factory.Connection
				.getConnection(ceURI);
		UserContext uc = UserContext.get();
		javax.security.auth.Subject subject = UserContext.createSubject(conn,
				username, password, null);
		uc.pushSubject(subject);
		logger.debug("success... username is " + username);
		return conn;

	}

	@SuppressWarnings("rawtypes")
	static HashMap getSessionCredentials(Logger logger) throws Exception {

		opsUtil objOpsUtil = new opsUtil();
		com.filenet.wcm.api.Session ceSession;

		logger.debug("Getting Opsutil Session");
		ceSession = objOpsUtil.getSession();

		logger.debug("Getting getSessionConnection");

		String token = ceSession.getToken();
		HashMap tokenMap = ceSession.fromToken(token);
		username = (String) tokenMap.get("userid");
		password = (String) tokenMap.get("password");

		logger.debug("success... username is " + username);
		return tokenMap;

		// return username + "|" + password;

	}

	static String RightStr(String bigstr, String smstr) {
		int strlen = bigstr.length();
		int strpos = bigstr.lastIndexOf(smstr);
		if (strpos == -1) {
			// not found - return nothing
			return "";
		} else {
			String resultstr = bigstr
					.substring(strpos + smstr.length(), strlen);
			return resultstr.trim();
		}
	}

	static String LeftStr(String bigstr, String smstr) {
		int strpos = bigstr.lastIndexOf(smstr);
		if (strpos == -1) {
			// not found - return nothing
			return "";
		} else {
			String resultstr = bigstr.substring(0, strpos);
			return resultstr;
		}
	}

}
