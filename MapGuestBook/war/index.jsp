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
     			max: 2399,
      			values: [ 0, 2399 ],
      			create: function( event, ui ) {
      				defaultVal = [0, 2399]
      				
     			 	if(defaultVal[ 0 ].toString().length == 3){
      					hour_start = defaultVal[ 0 ].toString().slice(0,1);
      				}else{
      					hour_start = defaultVal[ 0 ].toString().slice(0,2);
      				}
      				if(defaultVal[ 0 ].toString().length == 2){
      					hour_start = 0;
      				}//quick fix
      				
      				if(defaultVal[ 1 ].toString().length == 3){
      					hour_end = defaultVal[ 1 ].toString().slice(0,1);
      				}else{
      					hour_end = defaultVal[1 ].toString().slice(0,2);
      				}
      				if(defaultVal[ 0 ].toString().length == 2){
      					hour_end = 0;
      				}//quick fix
      			    min_start = Math.floor(parseInt(defaultVal[ 0 ].toString().slice(-2))*0.6);
      			    min_end = Math.floor(parseInt(defaultVal[ 1 ].toString().slice(-2))*0.6);
      			    if (min_start.toString().length == 1
									&& min_start > 16) {
								min_start = min_start.toString() + "0";
							}
							if (min_start.toString().length == 1
									&& min_start < 17) {
								min_start = "0" + min_start.toString();
							}

							if (min_end.toString().length == 1 && min_end > 16) {
								min_end = min_end.toString() + "0";
							}
							if (min_end.toString().length == 1 && min_end < 17) {
								min_end = "0" + min_end.toString();
							}
					
        			$( "#timeSliderOutput" ).val( "From " + hour_start+":"+min_start + " - To " + hour_end+":"+min_end );
     			 },
      			change: function( event, ui ) {
      				refreshMap();
     			 },
     			 slide: function( event, ui ) {
     			 	
     			 	if(ui.values[ 0 ].toString().length == 3){
      					hour_start = ui.values[ 0 ].toString().slice(0,1);
      				}else{
      					hour_start = ui.values[ 0 ].toString().slice(0,2);
      				}
      				if(ui.values[ 0 ].toString().length == 2){
     			 	 	hour_start = 0;
     			 	}//quick fix
      				
      				if(ui.values[ 1 ].toString().length == 3){
      					hour_end = ui.values[ 1 ].toString().slice(0,1);
      				}else{
      					hour_end = ui.values[ 1 ].toString().slice(0,2);
      				}
      				if(ui.values[ 1 ].toString().length == 2){
     			 	 	hour_end = 0;
     			 	}//quick fix
      			    min_start = Math.floor(parseInt(ui.values[ 0 ].toString().slice(-2))*0.6);
      			    min_end = Math.floor(parseInt(ui.values[ 1 ].toString().slice(-2))*0.6);
      			    
					if (min_start.toString().length == 1
									&& min_start > 16) {
								min_start = min_start.toString() + "0";
							}
							if (min_start.toString().length == 1
									&& min_start < 17) {
								min_start = "0" + min_start.toString();
							}

							if (min_end.toString().length == 1 && min_end > 16) {
								min_end = min_end.toString() + "0";
							}
							if (min_end.toString().length == 1 && min_end < 17) {
								min_end = "0" + min_end.toString();
							}
					
        			$( "#timeSliderOutput" ).val( "From " + hour_start+":"+min_start + " - To " + hour_end+":"+min_end );
     			 }
     			 
    		});
    		
    		$( "#price-range" ).slider({
      			range: true,
      			min: 0,
     			max: 15,
      			values: [ 0, 15 ],
      			create:  function( event, ui ) {
        			$( "#priceSliderOutput" ).val( "Price between $" + 0 + " and $" + 15 );
     			 },
      			slide: function( event, ui ) {
        			$( "#priceSliderOutput" ).val( "Price between $" + ui.values[ 0 ] + " and $" + ui.values[ 1 ] );
     			 	refreshMap();
     			 },
      			change: function( event, ui ) {
        			$( "#priceSliderOutput" ).val( "Price between $" + ui.values[ 0 ] + " and $" + ui.values[ 1 ] );
     			 	refreshMap();
     			 }
    		});
    		
    		$( "#score-range" ).slider({
    			range: true,
      			min: 0,
     			max: 5,
     			step: 1,
     			values: [ 0, 5 ],
     			create: function( event, ui ) {
        			$( "#scoreSliderOutput" ).val( "Score between " +  0 + " and " + 5);
     			 },
     			slide: function( event, ui ) {
        			$( "#scoreSliderOutput" ).val( "Score between " + ui.values[ 0 ] + " and " + ui.values[ 1 ] );
     			 	refreshMap();
     			 },
     			change: function( event, ui ) {
        			$( "#scoreSliderOutput" ).val( "Score between " + ui.values[ 0 ] + " and " + ui.values[ 1 ] );
     			 	refreshMap();
     			 }
    		});
    		
    		//
    		// Taken from:
    		// http://stackoverflow.com/questions/3945216/pop-up-form-on-button-click
    		//
    		$("#myReservationFloat").dialog({
	   			 autoOpen: false,
	   			 //show: 'slide',
	   			 resizable: false,
	   			 position: 'center',
	    		 stack: true,
	    		 height: 'auto',
	    		 width: 'auto',
	    		 modal: true,
	    		 title: "My reservations"
			});
			//
			// End of borrowed code
			//
    		
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
<p id="signIn" class="signInHeader" value="in"><a id="myReservationLink" href="javascript:void(0);" onclick="showMyReservation();" >My Reservations</a>&nbsp;${fn:escapeXml(user.nickname)} (
<a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">sign out</a>)</p>
<%
    } else {
%>
<p class="signInHeader" value="out">
<a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign in</a>
</p>
<%
    }
%>
	<div id="SidePanelSearch"></br>  </br>
		<table id="availTable">
		   	<tr>
		    	<th><img src="/resources/parking_lot_maps.png" alt="Available Parking"><input class="filterCheckbox" type="checkbox"  checked="true"  id="avail"></th>
			 	<th><img src="/resources/parking_lot_maps_disable.png" alt="Unavailable Parking"><input type="checkbox" checked="true" id="unavail"></th>
			</tr>
			<tr>
				<th id="rowAvailUnavail">Available</th>
				<th id="rowAvailUnavail">Unavailable</th>
			</tr>
		</table>
		</br>
		<table id="dayTable">
		   	<tr id="rowDayOfWeek">
		    	<th>Sun</th>
			 	<th>Mon</th>
			 	<th>Tue</th>
			 	<th>Wed</th>
			 	<th>Thu</th>
			 	<th>Fri</th>
			 	<th>Sat</th>
			</tr>
			<tr>
				<th><input type="checkbox" checked="true" class="dayOfweekCheckbox" id="sunday"></th>
				<th><input type="checkbox" checked="true" class="dayOfweekCheckbox" id="monday"></th>
				<th><input type="checkbox" checked="true" class="dayOfweekCheckbox" id="tuesday"></th>
				<th><input type="checkbox" checked="true" class="dayOfweekCheckbox" id="wednesday"></th>
				<th><input type="checkbox" checked="true" class="dayOfweekCheckbox" id="thursday"></th>
				<th><input type="checkbox" checked="true" class="dayOfweekCheckbox" id="friday"></th>
				<th><input type="checkbox" checked="true" class="dayOfweekCheckbox" id="saturday"></th>
			</tr>
		</table>
		</br>
		<table  id="sliderTable">
			<tr id="rowTimeSliderOut">
		    	<td><input type="text" id="timeSliderOutput" ></td>
			</tr>
			<tr id="rowTimeSlider">
		    	<td><p id="time-range"></p></td>
			</tr>
		</table>
		</br>
		<table  id="sliderTable">
			<tr id="rowPriceSliderOut">
		    	<th><input type="text" id="priceSliderOutput" ></th>
			</tr>
			<tr id="rowPriceSlider">
		    	<th><p id="price-range"></p></th>
			</tr>
		</table>
		</br>
		<table  id="sliderTable">
			<tr id="rowScoreSliderOut">
		    	<th><input type="text" id="scoreSliderOutput" ></th>
			</tr>
			<tr id="rowScoreSlider">
		    	<th><p id="score-range"></p></th>
			</tr>
		</table>
	</div>  
    <div id="map-canvas"></div>
    <div id="myReservationFloat"></div>
	<br/>
	<div id="usagenote" >Please click on a marker to view parking info</div>
	<br/>
	<div id="source" >UBC parking location available <a href="http://www.parking.ubc.ca/find-parking">here</a>  </div>	
  </body>
</html>