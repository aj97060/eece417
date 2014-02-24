<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreService" %>
<%@ page import="com.google.appengine.api.datastore.Query" %>
<%@ page import="com.google.appengine.api.datastore.Entity" %>
<%@ page import="com.google.appengine.api.datastore.FetchOptions" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html>
  <head>
    <link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
    <script type="text/javascript"
      src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCIajFRrg2dFzP5hMXVeAHyVsS75dEQP4s&sensor=true">
    </script>
    <script type="text/javascript">
    	//Global variables
    	var messageLocations = [];
    	var map;
    </script>
  </head>

  <body>

<%
	//For saving all message locations (see for loop) 
	List<String[]> locations = new ArrayList<String[]>();
	
    String guestbookName = request.getParameter("guestbookName");
    if (guestbookName == null) {
        guestbookName = "default";
    }
    pageContext.setAttribute("guestbookName", guestbookName);
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();
    if (user != null) {
      pageContext.setAttribute("user", user);
%>
<p>Hello, ${fn:escapeXml(user.nickname)}! (You can
<a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">sign out</a>.)</p>
<%
    } else {
%>
<p>Hello!
<a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign in</a>
to include your name with greetings you post.</p>
<%
    }
%>

<%
    DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
    Key guestbookKey = KeyFactory.createKey("Guestbook", guestbookName);
    // Run an ancestor query to ensure we see the most up-to-date
    // view of the Greetings belonging to the selected Guestbook.
    Query query = new Query("Greeting", guestbookKey).addSort("date", Query.SortDirection.DESCENDING);
    List<Entity> greetings = datastore.prepare(query).asList(FetchOptions.Builder.withLimit(10));
    if (greetings.isEmpty()) {
        %>
        <p>Guestbook '${fn:escapeXml(guestbookName)}' has no messages.</p>
        <%
    } else {
        %>
        <p>Messages in Guestbook '${fn:escapeXml(guestbookName)}'.</p>
        <%
        for (Entity greeting : greetings) {
            pageContext.setAttribute("greeting_content",
                                     greeting.getProperty("content"));
                                     
			//Get location if it exists
			if(greeting.getProperty("latitude").equals("")) {
				pageContext.setAttribute("greeting_location", "");
			} else {
				String[] location = {(String) greeting.getProperty("latitude"), (String) greeting.getProperty("longitude")};
				locations.add(location);
				pageContext.setAttribute("greeting_location", "(" + greeting.getProperty("latitude") + ", " + greeting.getProperty("longitude") + ")");
			}
			
            if (greeting.getProperty("user") == null) {
                %>
                <p>An anonymous person <span class="maplink" onclick="centerMap${fn:escapeXml(greeting_location)}">${fn:escapeXml(greeting_location)}</span> wrote:</p>
                <%
            } else {
                pageContext.setAttribute("greeting_user",
                                         greeting.getProperty("user"));
                %>
                <p><b>${fn:escapeXml(greeting_user.nickname)}</b> <span class="maplink" onclick="centerMap${fn:escapeXml(greeting_location)}">${fn:escapeXml(greeting_location)}</span> wrote:</p>
                <%
            }
            %>
            <blockquote>${fn:escapeXml(greeting_content)}</blockquote>
            <%
            if (greeting.getProperty("date") != null){
            	pageContext.setAttribute("date", greeting.getProperty("date").toString());
            	%>
            	<p>On ${date}</p>
            	<%
            }
        }
    }
%>
 
    <form action="/sign" method="post" name="guestbookForm">
      <div><textarea name="content" rows="3" cols="60"></textarea></div>
      <div><input type="submit" value="Post Message" /></div>
      <input type="hidden" name="guestbookName" value="${fn:escapeXml(guestbookName)}"/>
        <input type="hidden" name="userLatitude" value=""/>
        <input type="hidden" name="userLongitude" value=""/>
    </form>    
    <div id="map-canvas"/>
  </body>
  
<script type="text/javascript">
/*
	Saves the user's latitude and longitude in the web form
	
	@author	alvinlao
	@return	array		[lat, long]
*/
function getLocation() {
	if(navigator.geolocation) {
		navigator.geolocation.getCurrentPosition(success, fail);
	} else {
		alert('Your browser does not support geolocation services');
	}
	
	//Success call-back function
	function success(position) {
		//Put the lat and long in the form's two hidden fields: "userLatitude" and "userLongitude"
		document.forms['guestbookForm'].elements['userLatitude'].value = position.coords.latitude;
		document.forms['guestbookForm'].elements['userLongitude'].value = position.coords.longitude;
	}
	
	//Fail call-back function
	function fail() {
		alert('Could not obtain location');
	}
}

/*
	Centers the map at specified lat and long
	@author alvinlao
	@param	long	latitude
	@param	long	longitude
*/
function centerMap(lat, long) {
	map.setCenter(new google.maps.LatLng(lat, long));
} 


/*
	@author alvinlao
*/
function initialize() {
  var mapOptions = {
    zoom: 8,
    center: new google.maps.LatLng(49.26, -123.11)
  };

  map = new google.maps.Map(document.getElementById('map-canvas'),
      mapOptions);

	//Place markers at all message locations
  <%
  	for(String[] location : locations) {
  		pageContext.setAttribute("marker_lat", location[0]);
  		pageContext.setAttribute("marker_long", location[1]);
  		%>
  		new google.maps.Marker({
  		position: new google.maps.LatLng(${fn:escapeXml(marker_lat)}, ${fn:escapeXml(marker_long)}),
  		map: map  		
  	});
  		<%
  	}
  %>
}


getLocation();
initialize();


    
</script>
</html>