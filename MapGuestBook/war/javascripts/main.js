var map;
var xmlHttpReq = null;
var selectedMarkerID;
var guestbookNameString = "";
var infowindow;
var markers = [];

// Hide or show markers based on filter panel value
function refreshMap() {

	avail = $("#avail").prop('checked');
	unavail = $("#unavail").prop('checked');

	sunday = $("#sunday").prop('checked');
	monday = $("#monday").prop('checked');
	tuesday = $("#tuesday").prop('checked');
	wednesday = $("#wednesday").prop('checked');
	thursday = $("#thursday").prop('checked');
	friday = $("#friday").prop('checked');
	saturday = $("#saturday").prop('checked');

	start_time = parseInt($("#time-range").slider("values", 0))
	end_time = parseInt($("#time-range").slider("values", 1))

	low_price = parseInt($("#price-range").slider("values", 0))
	high_price = parseInt($("#price-range").slider("values", 1))

	score_low = parseInt($("#score-range").slider("values", 0))
	score_high = parseInt($("#score-range").slider("values", 1))

	for (i = 0; i < markers.length; i++) {
		parking = markers[i];
		// alert(parking.days)
		daysArr = parking.days.split("");
		// alert(daysArr)
		selectedDays = [ sunday, monday, tuesday, wednesday, thursday, friday,
				saturday ];

		var isInDays = false;
		var isInPrice = false;
		var isInScore = false;
		var isInTime = false;

		// Check day
		for (x = 0; x < 7; x++) {
			if (daysArr[x] == "1" && selectedDays[x]) {
				isInDays = true;
				break;
			}
		}

		// Check time
		parkingStartTime = parseInt(parking.start_time);
		parkingEndTime = parseInt(parking.end_time);
		if (parkingStartTime >= start_time && parkingEndTime <= end_time) {
			isInTime = true;
		}

		// Check price
		parkingPrice = parseInt(parking.price.match(/\d+/)[0]);
		if (parkingPrice >= low_price && parkingPrice <= high_price) {
			isInPrice = true;
		}

		// Check score
		if (parseInt(parking.score) >= score_low
				&& parseInt(parking.score) <= score_high) {
			isInScore = true;
		}

		if (isInDays && isInPrice && isInScore && isInTime) {
			parking.marker.setVisible(true);
			if (avail) {
				if (parking.availability == "true") {
					parking.marker.setVisible(true);
				}
			} else {
				if (parking.availability == "true") {
					parking.marker.setVisible(false);
				}
			}

			if (unavail) {
				if (parking.availability == "false") {
					parking.marker.setVisible(true);
				}
			} else {
				if (parking.availability == "false") {
					parking.marker.setVisible(false);
				}
			}
		} else {
			parking.marker.setVisible(false);
		}

	}

}

function loadMarkers() {
	// alert("loadMarkers");
	try {
		xmlHttpReq = new XMLHttpRequest();
		xmlHttpReq.onreadystatechange = httpCallBackFunction_loadMarkers;
		var url = "populateparkings/?GetMarker=all";

		xmlHttpReq.open('GET', url, true);
		xmlHttpReq.send(null);

		// alert();

	} catch (e) {
		alert("Error: " + e);
	}
}

function httpCallBackFunction_loadMarkers() {
	// alert("httpCallBackFunction_loadMarkers");

	if (xmlHttpReq.readyState == 1) {
		// updateStatusMessage("<blink>Opening HTTP...</blink>");
	} else if (xmlHttpReq.readyState == 2) {
		// updateStatusMessage("<blink>Sending query...</blink>");
	} else if (xmlHttpReq.readyState == 3) {
		// updateStatusMessage("<blink>Receiving...</blink>");
	} else if (xmlHttpReq.readyState == 4) {

		var plainText = xmlHttpReq.responseText;
		if (plainText) {
			// alert(plainText);

			parkingsArray = plainText.split(";");
			parkingsArray.length -= 1; // empty

			// var markerElements = xmlDoc.getElementsByTagName('marker');
			// alert(markerElements[0].getAttribute("srl"));
			// alert(markerElements.length);

			for (i = 0; i < parkingsArray.length; i++) {
				var parking = parkingsArray[i].split(",");
				// 0: key
				// 1: name
				// 2: availability
				// 3: days
				// 4: start_time
				// 5: end_time
				// 6: latitude
				// 7: longitude
				// 8: price
				// 9: score
				var marker = null;

				jsonEncode = {
					"key" : parking[0],
					"marker" : marker,
					"name" : parking[1],
					"availability" : parking[2],
					"days" : parking[3],
					"start_time" : parking[4],
					"end_time" : parking[5],
					"latitude" : parseFloat(parking[6]),
					"longitude" : parseFloat(parking[7]),
					"price" : parking[8],
					"score" : parking[9]
				}
				
				daysArr = jsonEncode.days.split("");
				daysAvail = "";
				checkBoxDay = "";
				if (daysArr[0] == "1") {
					daysAvail += "Sun, "
					checkBoxDay += 'Sun  <input type="checkbox" id="sundayRes"> '
				}
				if (daysArr[1] == "1") {
					daysAvail += "Mon, "
					checkBoxDay += 'Mon  <input type="checkbox" id="mondayRes"> '
				}
				if (daysArr[2] == "1") {
					daysAvail += "Tue, "
					checkBoxDay += 'Tue  <input type="checkbox" id="tuesdayRes"> '
				}
				if (daysArr[3] == "1") {
					daysAvail += "Wed, "
					checkBoxDay += 'Wed  <input type="checkbox" id="wednesdayRes"> '
				}
				if (daysArr[4] == "1") {
					daysAvail += "Thu, "
					checkBoxDay += 'Thu  <input type="checkbox" id="thurdayRes"> '
				}
				if (daysArr[5] == "1") {
					daysAvail += "Fri, "
					checkBoxDay += 'Fri  <input type="checkbox" id="fridayRes"> '
				}
				if (daysArr[6] == "1") {
					daysAvail += "Sat, "
					checkBoxDay += 'Sat  <input type="checkbox" id="saturdayRes"> '
				}

				if (jsonEncode.start_time.toString().length == 3) {
					hour_start = jsonEncode.start_time.toString().slice(0, 1);
				} else {
					hour_start = jsonEncode.start_time.toString().slice(0, 2);
				}
				if (jsonEncode.end_time.toString().length == 3) {
					hour_end = jsonEncode.end_time.toString().slice(0, 1);
				} else {
					hour_end = jsonEncode.end_time.toString().slice(0, 2);
				}
				min_start = Math.floor(parseInt(jsonEncode.start_time
						.toString().slice(-2)) * 0.6);
				min_end = Math.floor(parseInt(jsonEncode.end_time.toString()
						.slice(-2)) * 0.6);

				if (min_start.toString().length == 1) {
					min_start = min_start.toString() + "0";
				}

				if (min_end.toString().length == 1) {
					min_end = min_end.toString() + "0";
				}

				var myLatlng = new google.maps.LatLng(jsonEncode.latitude,
						jsonEncode.longitude);

				var contentString = "";
				
				
				if ($("#signInHeader").attr("value") == "in") {
					contentString += '<div id="InfoWindowTitle">'
					+ jsonEncode.name + '</div>'
					+ '<p id="InfoWindowDays"> Reserve for: </br>'
					+ checkBoxDay + '</p>' + 
					+ '<input type="text" id="timeSliderOutputRes" ></br>' 
					+ '<div id="time-rangeRes"></div>'
					+ '<p id="InfoWindowPrice"> Price: '
					+ jsonEncode.price + '</p>'
					+ '<p id="InfoWindowScore"> Score ' + jsonEncode.score
					+ "/5" + '</p>' + '</br>'
					+ '<input id="InfoWindowButton" type="button" value="Reserve" onclick="makeReservation('
							+ jsonEncode.key + ')"/>';
				} else {
					contentString += '<div id="InfoWindowTitle">'
					+ jsonEncode.name + '</div>'
					+ '<p id="InfoWindowDays"> Available on: </br>'
					+ daysAvail + '</p>' + '<p id="InfoWindowST"> From '
					+ hour_start + ":" + min_start + '</p>'
					+ '<p id="InfoWindowET"> To ' + hour_end + ":"
					+ min_end + '</p>' + '<p id="InfoWindowPrice"> Price: '
					+ jsonEncode.price + '</p>'
					+ '<p id="InfoWindowScore"> Score ' + jsonEncode.score
					+ "/5" + '</p>' + '</br>'
					+ 'Login to reserve this parking.';
				}

				if (jsonEncode.availability == "false") {
					// TODO gray overlay
				}

				if (jsonEncode.availability == "true") {
					var image = {
						url : 'resources/parking_lot_maps.png'
					}
				} else {
					var image = {
						url : 'resources/parking_lot_maps_disable.png'
					}
				}

				marker = new google.maps.Marker({
					position : myLatlng,
					map : map,
					title : '' + jsonEncode.name,
					icon : image
				});

				jsonEncode.marker = marker;
				markers.push(jsonEncode);
				addInfowindow(marker, contentString, jsonEncode.key);
			}
		} else {
			alert("No data.");
		}
	}
}

function addSliderRes(){
	//Marker info Bubble
	$( "#time-rangeRes" ).slider({
			range: true,
			min: 0,
			max: 2359,
			values: [ 0, 2359 ],
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
			    if (min_start.toString().length == 1 && min_start > 16) {
				min_start = min_start.toString() + "0";
			}
			if (min_start.toString().length == 1 && min_start < 17) {
				min_start = "0" + min_start.toString() ;
			}

			if (min_end.toString().length == 1 && min_start > 16) {
				min_end = min_end.toString() + "0";
			}
			if (min_end.toString().length == 1 && min_start < 17) {
				min_end = "0" +  min_end.toString();
			}
			
			$( "#timeSliderOutputRes" ).val( "From " + hour_start+":"+min_start + " - To " + hour_end+":"+min_end );
			 }
			 
	});
}


function addInfowindow(marker, content, mrkID) {
	infowindow = new google.maps.InfoWindow({
		content : content
	});
	google.maps.event.addListener(marker, 'click', function() {
		selectedMarkerID = mrkID;
		infowindow.setContent("" + content);
		infowindow.setPosition(marker.getPosition());
		infowindow.open(marker.get('map'), marker);
		getAjaxRequest();
	});
	addSliderRes();
}

function getAjaxRequest() {
	// alert("getAjaxRequest");
	if (!infowindow) {
		infowindow.close();
	}
	try {
		xmlHttpReq = new XMLHttpRequest();
		xmlHttpReq.onreadystatechange = httpCallBackFunction_getAjaxRequest;
		var url = "/queryprocessor/?markerID=" + selectedMarkerID
				+ "&guestbookName=" + guestbookNameString;

		xmlHttpReq.open('GET', url, true);
		xmlHttpReq.send(null);

		// alert();

	} catch (e) {
		alert("Error: " + e);
	}
}

function httpCallBackFunction_getAjaxRequest() {
	// alert("httpCallBackFunction_getAjaxRequest");

	if (xmlHttpReq.readyState == 1) {
		// updateStatusMessage("<blink>Opening HTTP...</blink>");
	} else if (xmlHttpReq.readyState == 2) {
		// updateStatusMessage("<blink>Sending query...</blink>");
	} else if (xmlHttpReq.readyState == 3) {
		// updateStatusMessage("<blink>Receiving...</blink>");
	} else if (xmlHttpReq.readyState == 4) {
		var xmlDoc = null;

		if (xmlHttpReq.responseXML) {
			xmlDoc = xmlHttpReq.responseXML;
		} else if (xmlHttpReq.responseText) {
			var parser = new DOMParser();
			xmlDoc = parser
					.parseFromString(xmlHttpReq.responseText, "text/xml");
		}

		if (xmlDoc) {
			// alert(xmlHttpReq.responseText);
			//document.getElementById("msglist_" + selectedMarkerID).innerHTML = xmlHttpReq.responseText;
		} else {
			alert("No data.");
		}
	}
}

function postAjaxRequest(postMsg, markerID, guestbookName, rspMsgList) {
	// alert("postAjaxRequest");
	try {
		xmlHttpReq = new XMLHttpRequest();
		xmlHttpReq.onreadystatechange = httpCallBackFunction_postAjaxRequest;
		var url = "/sign";

		xmlHttpReq.open("POST", url, true);
		xmlHttpReq.setRequestHeader('Content-Type',
				'application/x-www-form-urlencoded');

		var postMsgValue = encodeURIComponent(document.getElementById(postMsg).value);
		var markerIDValue = markerID;
		var guestbookNameValue = guestbookName;

		xmlHttpReq.send("postMsg=" + postMsgValue + "&markerID="
				+ markerIDValue + "&guestbookName=" + guestbookNameValue);

		// alert();

	} catch (e) {
		alert("Error: " + e);
	}
}

function httpCallBackFunction_postAjaxRequest() {
	// alert("httpCallBackFunction_postAjaxRequest");

	if (xmlHttpReq.readyState == 1) {
		// updateStatusMessage("<blink>Opening HTTP...</blink>");
	} else if (xmlHttpReq.readyState == 2) {
		// updateStatusMessage("<blink>Sending query...</blink>");
	} else if (xmlHttpReq.readyState == 3) {
		// updateStatusMessage("<blink>Receiving...</blink>");
	} else if (xmlHttpReq.readyState == 4) {
		var xmlDoc = null;

		if (xmlHttpReq.responseXML) {
			xmlDoc = xmlHttpReq.responseXML;
		} else if (xmlHttpReq.responseText) {
			var parser = new DOMParser();
			xmlDoc = parser
					.parseFromString(xmlHttpReq.responseText, "text/xml");
		}

		if (xmlDoc) {
			// alert(xmlHttpReq.responseText);
			document.getElementById("msglist_" + selectedMarkerID).innerHTML = xmlHttpReq.responseText;
			document.getElementById("msgbox_" + selectedMarkerID).value = "";
		} else {
			alert("No data.");
		}
	}
}