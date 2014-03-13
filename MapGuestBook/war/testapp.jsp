<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
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
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no" /> 
    <meta charset="utf-8">       
    <link type="text/css" rel="stylesheet" href="/stylesheets/main.css" />
    <script type="text/javascript" src="/javascripts/main.js"></script>        
    <script type="text/javascript"
      src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCIajFRrg2dFzP5hMXVeAHyVsS75dEQP4s&sensor=true">
    </script>    
    <script type="text/javascript"> 
	  
		function initialize() {
					
			var myLatlng = new google.maps.LatLng(49.263426761536,-123.24782870883);   
		   
			var mapOptions = {
			  center: myLatlng,
			  zoom: 14
			};
			
			map = new google.maps.Map(document.getElementById("map-canvas"),
			  mapOptions);		
						
			var mrkID = "0";
			var gstBkNm = guestbookNameString; //"default";
			var msgbox = "msgbox_";	
			var msglist = "msglist_";
									
			// @PartC Added '0' to msglist ID
			var contentString  = '<div id="InfoWindowTitle">' + 'Health Sciences Parkade' + '</div>' +'<div id="content">' +  	
			  '<div class="msglist" id="'+ msglist +'0"></div>' + '</div>' +
			  '<textarea name="InfoWindow" id="'+ msgbox +'" rows="2" cols="20" ></textarea>' +			  
			  '<input id="InfoWindowButton" type="button" value="Post" onclick="postAjaxRequest('+ 
				"'" + msgbox + "', '" + mrkID + "', '" + gstBkNm + "', '" + msglist + "'" +')"/>';  
			
			var infowindow = new google.maps.InfoWindow({
			  content: contentString
			}); 
			
			var iconBase = 'https://maps.google.com/mapfiles/kml/shapes/';
			var icons = {
  				parking: {
    				icon: iconBase + 'parking_lot_maps.png'
  				},
  				library: {
    				icon: iconBase + 'library_maps.png'
  				},
  				info: {
    				icon: iconBase + 'info-i_maps.png'
  				}
			};
						   
			var marker = new google.maps.Marker({       
			  position: myLatlng,
			  map: map,
			  icon: icons['parking'].icon,			  
			  title: 'Health Sciences Parkade'
			});    
			
			google.maps.event.addListener(marker, 'click', function() {
			  selectedMarkerID = mrkID;  	
			  infowindow.open(map, marker);
			  getAjaxRequest();   
			});        
					
			// Load the selected markers			
			loadMarkers();       
		}      
 	
		google.maps.event.addDomListener(window, 'load', initialize);
    </script>
    
  </head>
  <body>
  </br>
  <div id="bigHeader">Welcome to Parking Finder</div>
<%
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
<p id="signInHeader">Hello, ${fn:escapeXml(user.nickname)}! (
<a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">sign out</a>.)</p>
<%
    } else {
%>
<p id="signInHeader">
<a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign in</a>
</p>
<%
    }
%>
<div id="guestbook">
Guestbook: ${fn:escapeXml(guestbookName)}
</div>
<script type="text/javascript">guestbookNameString = "${fn:escapeXml(guestbookName)}";</script>
<!--<script type="text/javascript">alert(guestbookNameString);</script>-->

<!-- Original -->
<div id=oldMsgList>
<%
    DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
    Key guestbookKey = KeyFactory.createKey("Guestbook", guestbookName);
    
    // Run an ancestor query to ensure we see the most up-to-date
    // view of the Greetings belonging to the selected Guestbook.
    
    Query query = new Query("Greeting", guestbookKey).addSort("date", Query.SortDirection.DESCENDING);
    List<Entity> greetings = datastore.prepare(query).asList(FetchOptions.Builder.withLimit(5));
    
    if (greetings.isEmpty()) {
        %>
        <p>Guestbook '${fn:escapeXml(guestbookName)}' has no comment on this parking.</p>
        <%
    } else {
        %>
        <p>Messages in Guestbook '${fn:escapeXml(guestbookName)}'.</p>
        <%
        for (Entity greeting : greetings) {
            pageContext.setAttribute("greeting_content",
                                     greeting.getProperty("content"));
            if (greeting.getProperty("user") == null) {
                %>
                <p>An anonymous person wrote:</p>
                <%
            } else {
                pageContext.setAttribute("greeting_user",
                                         greeting.getProperty("user"));
                %>
                <p><b>${fn:escapeXml(greeting_user.nickname)}</b> wrote:</p>
                <%
            }
            %>
            <blockquote>${fn:escapeXml(greeting_content)}</blockquote>
            <%
        }
    }
%>

    <form action="/sign" method="post">
      <div><textarea name="content" rows="3" cols="60" resize="none"></textarea>
      <input type="submit" value="Post" /></div>
      <input type="hidden" name="guestbookName" value="${fn:escapeXml(guestbookName)}"/>
    </form>
    
</div> 
<!-- Original -->
	        
    <div id="map-canvas"></div>
    
	<br/>
	<div id="usagenote" >Please click on a marker to view and/or post greetings.</div>
	<br/>
	<div id="source" >UBC parking location available <a href="http://www.parking.ubc.ca/find-parking">here</a>  </div>	
  </body>
</html>