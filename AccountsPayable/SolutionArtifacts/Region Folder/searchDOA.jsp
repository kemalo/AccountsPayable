<!--
********************************************************************************************************************									
  							(c) Copyright 2011, Kemal Omar, kodeIT Solutions.
									www.kodeitsolutions.com.au
*********************************************************************************************************************
-->

<%
response.setHeader("Cache-Control","no-cache"); //HTTP 1.1
response.setHeader("Pragma","no-cache"); //HTTP 1.0
response.setDateHeader ("Expires", 0); //prevents caching at the proxy server
%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*" %>
<%@page import="java.io.InputStream" %>
<%@page import="java.util.Properties" %>
<%@ page import="java.utils.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.lang.*"%>
<%@ page import java.text.*"%>
<%@ page errorPage="error_page.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF8" %>  

<link rel="stylesheet" href="APOnline.css" type="text/css">

<script language="JavaScript" src="../forms/misc/eforms-factory.js"></script>
<script language="JavaScript" src="../regions/Utilities.js"></script>


<HTML>
<HEAD>
<TITLE>DOA Search</TITLE>
</HEAD>

<BODY onLoad="window.focus();">

	<Table style="">
		<TR>
			<TD width="10%"><input type="image"
				src="rabo_logo.jpg" name="image" width="120" height="40"
				valign="bottom">
			</TD>
			<TD class="header" align="center">AP Online DOA Search
		</TR>
		<TR>
			<TD class="header">&nbsp</TD>
		</TR>
	</Table>

	
<%!

 String getvalidOU(String inOU )
	{
		while (inOU.endsWith("_"))
		{
			inOU = inOU.substring(0,inOU.length()-1);
		}
		return inOU;
		
	}
%>	
<%
	

	String strBU= request.getParameter("BU");
	String strparamOU= request.getParameter("OU");	
	String theOUList=getvalidOU(strparamOU.replace("'", ""));
	String strAmount= request.getParameter("Amt");	
	String strEC= request.getParameter("EC");	
	String struseEC= request.getParameter("useEC");	
	
	Properties props = new Properties();
	props.load(new FileInputStream(request.getRealPath("/regions/aponline.properties")));

	String DBServer=props.getProperty("DBServer");
	String DBName=props.getProperty("DBName");	
	String DBPort=props.getProperty("DBPort");	


	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");

	//	Does not require ODBC connection sing JDBC Connection	
	// This is currently using the P8svc account
		Connection connection = DriverManager.getConnection("jdbc:sqlserver://" +DBServer+":"+DBPort+";databaseName="+DBName+";integratedSecurity=true;");

	int i=0;
   CallableStatement cs = connection.prepareCall("{call usp_getDOAApprovers(?,?,?,?,?,?)}");
	cs.registerOutParameter(1, java.sql.Types.VARCHAR);

	cs.setString(2,theOUList);
	cs.setString(3, strBU.replace("'", ""));
	cs.setString(4,strEC.replace("'", ""));
	cs.setString(5, strAmount.replace("'", ""));
	cs.setString(6, struseEC.replace("'", ""));

	ResultSet rs = cs.executeQuery();
	out.println("<DIV ALIGN=CENTER>");
	out.println("<TABLE BORDER=\"1\">");
	out.println("<TR>");
	out.println("<TD bgcolor=\"d3d3d3\" class=\"tdheader\">UserID</TD>");
	out.println("<TD bgcolor=\"d3d3d3\"  class=\"tdheader\">Approver</TD>");
	out.println("<TD bgcolor=\"d3d3d3\"  class=\"tdheader\">OU Group</TD>");
	out.println("<TD bgcolor=\"d3d3d3\"  class=\"tdheader\">Bus Unit</TD>");
	out.println("<TD bgcolor=\"d3d3d3\"  class=\"tdheader\">Exp Category</TD>");
	out.println("<TD bgcolor=\"d3d3d3\"  class=\"tdheader\">Amount</TD>");
	out.println("<TD bgcolor=\"d3d3d3\"  class=\"tdheader\">Description</TD>");

	out.println("</TR>");				

	while (rs.next()) 
	{
		String displayuserid=rs.getString(1);
		// escape the apostrophe
		String userid = displayuserid.replaceAll("'","\\\\'");
		String Approver =rs.getString(2);
		String fAmount =rs.getString(3);
		
		if (fAmount==null){
			//out.println("notnull");
			fAmount="";
		}else{
			double d = Double.parseDouble(fAmount);
			fAmount= String.format("$%1$,.2f", d);
		}
		String OUG =rs.getString(4);
		String BU =rs.getString(5);
		
		String EC =rs.getString(6);
		String Description =rs.getString(7);

		out.println("<TR>");

		out.println("<TD  class=\"body\"><a href=\"#\"     onclick=\"setRowValues(\'"
			+ userid + "\')\">" + displayuserid + "</TD>");
		out.println("<TD  class=\"body\" WIDTH=\"200\">" + Approver + "</TD>");
		out.println("<TD  class=\"body\" WIDTH=\"10\">" + OUG + "</TD>");
		out.println("<TD  class=\"body\" WIDTH=\"10\">" + BU + "</TD>");
		out.println("<TD class=\"body\" WIDTH=\"200\">" + EC + "</TD>");
		out.println("<TD class=\"body\">" + fAmount + "</TD>");
		out.println("<TD class=\"body\" WIDTH=\"300\">" + Description + "</TD>");
		out.println("</TR>");
%>
<script language="JavaScript">

	function setRowValues(thevalue)

	{
		for (var i = 0; i < arguments.length; i++)
			var  Approver= form.getCell("Approver" ) ;
			Approver.setValueFromString(arguments[0]);
			parent.close("_parent");

	
	}
</script>
<%
	}
	out.println("</TABLE>");
	out.println("</DIV>");	
	out.println("<br></br>");	
	out.println("<br></br>");	
	out.println("<br></br>");	
	out.println("<br></br>");	
	out.println("<br></br>");	
	out.println("<br></br>");	
	out.println("<br></br>");	
	out.println("<br></br>");	
	out.println("End of results");	
	
	connection.close();
%>
	
</BODY>
</HTML>