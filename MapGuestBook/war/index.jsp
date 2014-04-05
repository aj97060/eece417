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
    <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.js"></script>
    <script type="text/javascript" src="/javascripts/main.js"></script>        
    <script type="text/javascript"
      src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCIajFRrg2dFzP5hMXVeAHyVsS75dEQP4s&sensor=true">
    </script>    
    <link rel="stylesheet" href="/javascripts/jquery-ui/ui-lightness/jquery-ui-1.10.4.custom.css">
    <script src="/javascripts/jquery-ui/js/jquery-ui-1.10.4.custom.js"></script>
    
    <script type="text/javascript"> 
	  
		function initialize() {
					
			var myLatlng = new google.maps.LatLng(49.263426761536,-123.24782870883);   
		   
			var mapOptions = {
			  center: myLatlng,
			  zoom: 14
			};
				
			map = new google.maps.Map(document.getElementById("map-canvas"),
			  mapOptions);	
			  
			// Load the selected markers	
			loadMarkers();   
		
			
    		
			    
		}      
 	
		google.maps.event.addDomListener(window, 'load', initialize);
		
		$( document ).ready(function() {
		
			 $(':checkbox').change(function() {
   				refreshMap();
			}); 
		
			//Filter panel sliders
			$( "#time-range" ).slider({
      			range: true,
      			min: 0,
     			max: 2359,
      			values: [ 0, 2359 ],
      			change: function( event, ui ) {
      				refreshMap();
     			 },
     			 slide: function( event, ui ) {
     			 	if(ui.values[ 0 ].toString().length == 3){
      					hour_start = ui.values[ 0 ].toString().slice(0,1);
      				}else{
      					hour_start = ui.values[ 0 ].toString().slice(0,2);
      				}
      				if(ui.values[ 1 ].toString().length == 3){
      					hour_end = ui.values[ 1 ].toString().slice(0,1);
      				}else{
      					hour_end = ui.values[1 ].toString().slice(0,2);
      				}
      			    min_start = Math.floor(parseInt(ui.values[ 0 ].toString().slice(-2))*0.6);
      			    min_end = Math.floor(parseInt(ui.values[ 1 ].toString().slice(-2))*0.6);
      			    if (min_start.toString().length == 1) {
						min_start = min_start.toString() + "0";
					}

					if (min_end.toString().length == 1) {
						min_end = min_end.toString() + "0";
					}
        			$( "#timeSliderOutput" ).val( "From " + hour_start+":"+min_start + " - To " + hour_end+":"+min_end );
     			 }
     			 
    		});
    		
    		$( "#price-range" ).slider({
      			range: true,
      			min: 0,
     			max: 15,
      			values: [ 0, 15 ],
      			slide: function( event, ui ) {
        			$( "#priceSliderOutput" ).val( "Between $" + ui.values[ 0 ] + " and $" + ui.values[ 1 ] );
     			 	refreshMap();
     			 },
      			change: function( event, ui ) {
        			$( "#priceSliderOutput" ).val( "Between $" + ui.values[ 0 ] + " and $" + ui.values[ 1 ] );
     			 	refreshMap();
     			 }
    		});
    		
    		$( "#score-range" ).slider({
    			range: true,
      			min: 0,
     			max: 5,
     			step: 1,
     			values: [ 0, 5 ],
     			slide: function( event, ui ) {
        			$( "#scoreSliderOutput" ).val( "Between " + ui.values[ 0 ] + " and " + ui.values[ 1 ] );
     			 	refreshMap();
     			 },
     			change: function( event, ui ) {
        			$( "#scoreSliderOutput" ).val( "Between " + ui.values[ 0 ] + " and " + ui.values[ 1 ] );
     			 	refreshMap();
     			 }
    		});
    		
    		
    		refreshMap();
    		
		});
    </script>
    
  </head>
  <body>
  </br>
  <div id="bigHeader">OurParkingSpot</div>
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
<p id="signInHeader" value="in">${fn:escapeXml(user.nickname)}! (
<a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">sign out</a>.)</p>
<%
    } else {
%>
<p id="signInHeader" value="out">
<a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign in</a>
</p>
<%
    }
%>
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
	<div id="SidePanelSearch">Filter  </br>  </br>
		Current availability: </br>
		Show available <input class="filterCheckbox" type="checkbox"  checked="true"  id="avail"> </br>
		Show unavailable <input type="checkbox" checked="true" id="unavail"></br>
		Days: </br>
		Sun  <input type="checkbox" checked="true" id="sunday"> 
		Mon  <input type="checkbox" checked="true" id="monday"> 
		Tue  <input type="checkbox" checked="true" id="tuesday"> 
		Wed  <input type="checkbox" checked="true" id="wednesday"> 
		Thu  <input type="checkbox" checked="true" id="thursday"> 
		Fri  <input type="checkbox" checked="true" id="friday"> 
		Sat  <input type="checkbox" checked="true" id="saturday"></br></br>
		Time <input type="text" id="timeSliderOutput" ></br>
		<div id="time-range"></div></br>
		Price <input type="text" id="priceSliderOutput" >
		</br><div id="price-range"></div></br>
		Score <input type="text" id="scoreSliderOutput" >
		</br><div id="score-range"></div></br>
	</div>  
    <div id="map-canvas"></div>
    
	<br/>
	<div id="usagenote" >Please click on a marker to view and/or post greetings.</div>
	<br/>
	<div id="source" >UBC parking location available <a href="http://www.parking.ubc.ca/find-parking">here</a>  </div>	
  </body>
</html>