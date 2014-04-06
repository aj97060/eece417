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
		daysArr = parking.days.split("");
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
		if (parkingStartTime <= start_time && parkingEndTime >= end_time) {
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

// Load the parking and put them on the map
function loadMarkers() {
	try {
		xmlHttpReq = new XMLHttpRequest();
		xmlHttpReq.onreadystatechange = httpCallBackFunction_loadMarkers;
		var url = "populateparkings/?GetMarker=all";

		xmlHttpReq.open('GET', url, true);
		xmlHttpReq.send(null);

	} catch (e) {
		alert("Error: " + e);
	}
}

// Ajax callback for loadMarkers()
function httpCallBackFunction_loadMarkers() {
	if (xmlHttpReq.readyState == 1) {
	} else if (xmlHttpReq.readyState == 2) {
	} else if (xmlHttpReq.readyState == 3) {
	} else if (xmlHttpReq.readyState == 4) {

		var plainText = xmlHttpReq.responseText;
		if (plainText) {

			parkingsArray = plainText.split(";");
			parkingsArray.length -= 1; // empty

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

				daysAvail = "";
				daysArr = jsonEncode.days.split("");
				if (daysArr[0] == "1") {
					daysAvail += "Sun, "
				}
				if (daysArr[1] == "1") {
					daysAvail += "Mon, "
				}
				if (daysArr[2] == "1") {
					daysAvail += "Tue, "
				}
				if (daysArr[3] == "1") {
					daysAvail += "Wed, "
				}
				if (daysArr[4] == "1") {
					daysAvail += "Thu, "
				}
				if (daysArr[5] == "1") {
					daysAvail += "Fri, "
				}
				if (daysArr[6] == "1") {
					daysAvail += "Sat, "
				}

				var myLatlng = new google.maps.LatLng(jsonEncode.latitude,
						jsonEncode.longitude);

				var contentString = '<div id=\"InfoWindow\" value=\"'
						+ jsonEncode.availability + '\">';

				if ($(".signInHeader").attr("value") == "in") {
					contentString += "<div id=\"InfoWindowTitle\">"
							+ jsonEncode.name
							+ "<\/div><\/br><table id=\"dateTableRes\"><tr><th id=\"rowDateRes\"><input  type=\"text\" style=\"position: relative; z-index: 10;\" id=\"datepicker\" value=\"Pick your day!\" days=\""
							+ jsonEncode.days
							+ "\"><\/th><\/tr><\/table><\/br><table  id=\"sliderTable\"><tr id=\"rowTimeSliderOut\"><td> <input type=\"text\" id=\"timeSliderOutputRes\" ><\/td><\/tr><tr id=\"rowTimeSlider\"><td><p id=\"time-rangeRes\" value=\""
							+ jsonEncode.start_time
							+ "-"
							+ jsonEncode.end_time
							+ "\"><\/p><\/td><\/tr><\/table><p id=\"InfoWindowPrice\">Only "
							+ jsonEncode.price
							+ "<\/p><p id=\"InfoWindowScore\">Score "
							+ jsonEncode.score
							+ "\/5<\/p><div id=\"InfoWindowButtonHolder\"><input id=\"InfoWindowButton\" type=\"button\" value=\"Reserve Now\" onclick=\"makeReservation("
							+ jsonEncode.key
							+ ")\"\/><\/div><p id=\"ServerResponseRes\"><\/p>";

				} else {
					contentString += '<div id="InfoWindowTitle">'
							+ jsonEncode.name + '</div></br>'
							+ ' Available on: <p id="InfoWindowDays">'
							+ daysAvail + '</p>'
							+ '<p id="InfoWindowST"> From ' + hour_start + ":"
							+ min_start + ' to ' + hour_end + ":" + min_end
							+ '</p>' + '<p id="InfoWindowPrice"> Price: '
							+ jsonEncode.price + '</p>'
							+ '<p id="InfoWindowScore"> Score '
							+ jsonEncode.score + "/5" + '</p>' + '</br>'
							+ 'Login to reserve this parking.';
				}

				contentString += "</div>";

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

// Add slider, date picker and stuff to Infowindows
// This function is called when Infowindow DOM is ready
function addJSRes() {

	// Disable if parking unavailable
	if ($("#InfoWindow").attr("value") == "false") {
		$("#InfoWindow *").attr("disabled", "disabled").off('click');
		$("#ServerResponseRes").html("This parking is currently unavailable");
		$("#InfoWindowButtonHolder").remove();
	}

	// Add date picker to infoWindow
	$("#datepicker").datepicker({
		showButtonPanel : true,
		showOn : "button",
		buttonImage : "resources/date-picker-icon.png", // Source:
		// http://cdn.fleetly.com/assets/A/85/date-picker-icon.png
		buttonImageOnly : true,
		beforeShowDay : function(date) {
			var weekDay = date.getDay();
			var now = new Date();
			var daysArr = $("#datepicker").attr("days").split("");
			if (daysArr[weekDay] == "1" && date > now) {
				// Day selectable
				return [ true, "" ];
			} else {
				// Day not selectable
				return [ false, "" ]
			}
		}
	});

	// Add slider to infoWindow
	$("#time-rangeRes")
			.slider(
					{
						range : true,
						min : parseInt($("#time-rangeRes").attr("value").split(
								"-")[0]),
						max : parseInt($("#time-rangeRes").attr("value").split(
								"-")[1]),
						values : [
								parseInt($("#time-rangeRes").attr("value")
										.split("-")[0]),
								parseInt($("#time-rangeRes").attr("value")
										.split("-")[1]) ],
						create : function(event, ui) {
							defaultVal = [
									parseInt($("#time-rangeRes").attr("value")
											.split("-")[0]),
									parseInt($("#time-rangeRes").attr("value")
											.split("-")[1]) ]
							if (defaultVal[0].toString().length == 3) {
								hour_start = defaultVal[0].toString().slice(0,
										1);
							} else {
								hour_start = defaultVal[0].toString().slice(0,
										2);
							}
							if (defaultVal[0].toString().length == 2) {
								hour_start = 0;
							}

							if (defaultVal[1].toString().length == 3) {
								hour_end = defaultVal[1].toString().slice(0, 1);
							} else {
								hour_end = defaultVal[1].toString().slice(0, 2);
							}
							if (defaultVal[1].toString().length == 2) {
								hour_end = 0;
							}
							min_start = Math.floor(parseInt(defaultVal[0]
									.toString().slice(-2)) * 0.6);
							min_end = Math.floor(parseInt(defaultVal[1]
									.toString().slice(-2)) * 0.6);
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
							$("#timeSliderOutputRes").val(
									"From " + hour_start + ":" + min_start
											+ " - To " + hour_end + ":"
											+ min_end);
						},
						slide : function(event, ui) {
							if (ui.values[0].toString().length == 3) {
								hour_start = ui.values[0].toString()
										.slice(0, 1);
							} else {
								hour_start = ui.values[0].toString()
										.slice(0, 2);
							}
							if (ui.values[0].toString().length == 2) {
								hour_start = 0;
							}

							if (ui.values[1].toString().length == 3) {
								hour_end = ui.values[1].toString().slice(0, 1);
							} else {
								hour_end = ui.values[1].toString().slice(0, 2);
							}
							if (ui.values[1].toString().length == 2) {
								hour_end = 0;
							}
							min_start = Math.floor(parseInt(ui.values[0]
									.toString().slice(-2)) * 0.6);
							min_end = Math.floor(parseInt(ui.values[1]
									.toString().slice(-2)) * 0.6);
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
							$("#timeSliderOutputRes").val(
									"From " + hour_start + ":" + min_start
											+ " - To " + hour_end + ":"
											+ min_end);
						}

					});
}

// Bind infowindows to markers
function addInfowindow(marker, content, mrkID) {
	infowindow = new google.maps.InfoWindow({
		content : content
	});

	// call to addJSRes() when user has click on the infoWindow and its DOM is
	// ready
	google.maps.event.addListener(infowindow, 'domready', function() {
		if ($(".signInHeader").attr("value") == "in") {
			addJSRes();
		}
	});

	// On infowindow click get content
	google.maps.event.addListener(marker, 'click', function() {
		selectedMarkerID = mrkID;
		infowindow.setContent("" + content);
		infowindow.setPosition(marker.getPosition());
		infowindow.open(marker.get('map'), marker);
	});

}

// Called when user click on the button to make a reservation
function makeReservation(mrkId) {
	try {
		xmlHttpReq = new XMLHttpRequest();
		xmlHttpReq.onreadystatechange = httpCallBackFunction_ajaxReservation;

		date = $("#datepicker").val();
		if (date.length == 10) {
			start_time = parseInt($("#time-rangeRes").slider("values", 0))
			end_time = parseInt($("#time-rangeRes").slider("values", 1))

			var url = "queryprocessor/?Reservation=" + mrkId + "&start_time="
					+ start_time + "&end_time=" + end_time + "&date=" + date;

			xmlHttpReq.open('GET', url, true);
			xmlHttpReq.send(null);
		} else {
			$("#ServerResponseRes").attr("class", "ServerResponseResFail");
			$("#ServerResponseRes").html("Invalid date")
		}
	} catch (e) {
		alert("Error: " + e);
	}
}

// MakeReservation() Ajax callback function
function httpCallBackFunction_ajaxReservation() {
	if (xmlHttpReq.readyState == 1) {
	} else if (xmlHttpReq.readyState == 2) {
	} else if (xmlHttpReq.readyState == 3) {
	} else if (xmlHttpReq.readyState == 4) {
		res = xmlHttpReq.responseText;
		if (res) {
			if (res == 0) {
				$("#ServerResponseRes").attr("class", "ServerResponseResSucc");
				$("#ServerResponseRes").html("Reservation successful!");
			}
			if (res == 1) {
				$("#ServerResponseRes").attr("class", "ServerResponseResFail");
				$("#ServerResponseRes").html("Reservation already taken")
			}
		} else {
			alert("No data.");
		}
	}
}

// Called when user click on My Reservation link
function showMyReservation() {
	getMyReservation();
	$("#myReservationFloat").dialog('open');
}

// Called when user click on Cancel button in My Reservation dialog
function cancelMyReservation() {
	var canceledRes = [];
	var countRes = 0;
	$("#myReservationFloat > table > tbody > tr > td > input").each(function() {
		countRes = countRes + 1;
		if ($(this).prop('checked')) {
			canceledRes.push($(this).attr("id"));
			cancelRes($(this).attr("id"));
		}
	});
	for (id in canceledRes) {
		$("#tr" + canceledRes[id]).remove();
		if (countRes - 1 == id) {
			$("#myReservationFloat").html(
					'<div id=\"noReservation\">You have no reservations</div>');
		}
	}

}

// Ajax call that actually cancel the reservation
function cancelRes(resId) {
	try {
		xmlHttpReq = new XMLHttpRequest();
		xmlHttpReq.onreadystatechange = httpCallBackFunction_ajaxCancelRes;

		var url = "queryprocessor/?Cancel=" + resId;

		xmlHttpReq.open('GET', url, true);
		xmlHttpReq.send(null);

	} catch (e) {
		alert("Error: " + e);
	}
}

// Ajax call back function of cancelRes()
function httpCallBackFunction_ajaxCancelRes() {
	if (xmlHttpReq.readyState == 1) {
	} else if (xmlHttpReq.readyState == 2) {
	} else if (xmlHttpReq.readyState == 3) {
	} else if (xmlHttpReq.readyState == 4) {
		res = xmlHttpReq.responseText;
		if (res) {
			if (res == -1) {
				$("#myReservationServerAns").attr("class",
						"ServerResponseResFail");
				$("#myReservationServerAns").html(
						"Unable to cancel reservation");
			}
		} else {
			alert("No data.");
		}
	}
}

// Get user reservations
function getMyReservation() {
	if (!infowindow) {
		infowindow.close();
	}
	// Clear previous data
	$("#myReservationFloat").html("");
	try {
		xmlHttpReq = new XMLHttpRequest();
		xmlHttpReq.onreadystatechange = httpCallBackFunction_ajaxMyReservation;
		var url = "/queryprocessor/?getMyReservations=all";

		xmlHttpReq.open('GET', url, true);
		xmlHttpReq.send(null);

	} catch (e) {
		alert("Error: " + e);
	}
}

// Ajax call back function of getMyReservation
function httpCallBackFunction_ajaxMyReservation() {
	if (xmlHttpReq.readyState == 1) {
	} else if (xmlHttpReq.readyState == 2) {
	} else if (xmlHttpReq.readyState == 3) {
	} else if (xmlHttpReq.readyState == 4) {
		res = xmlHttpReq.responseText;
		if (res) {
			$("#myReservationFloat").html(res);
		} else {
			alert("No data.");
		}
	}
}
