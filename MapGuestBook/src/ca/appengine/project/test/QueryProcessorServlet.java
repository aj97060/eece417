package ca.appengine.project.test;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.FetchOptions;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Query.Filter;
import com.google.appengine.api.datastore.Query.FilterPredicate;
import com.google.appengine.api.datastore.Query.FilterOperator;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

import java.io.IOException;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.tools.ant.util.DateUtils;

public class QueryProcessorServlet extends HttpServlet {

	private DatastoreService datastore;

	@Override
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		UserService userService = UserServiceFactory.getUserService();
		User user = userService.getCurrentUser();

		String responseHTMLString = "";

		String getRes = req.getParameter("getMyReservations");
		String cancelRes = req.getParameter("Cancel");
		String parkingId = req.getParameter("Reservation");
		String rentStartTime = req.getParameter("start_time");
		String rentEndTime = req.getParameter("end_time");
		String date = req.getParameter("date");

		if (parkingId != null && rentStartTime != null && rentEndTime != null
				&& date != null) {
			this.datastore = DatastoreServiceFactory.getDatastoreService();

			Entity reservation = new Entity("Reservation");

			if (checkReservation(user.getUserId(), parkingId, rentStartTime,
					rentEndTime, date)) {

				reservation.setProperty("User", user.getUserId());
				reservation.setProperty("ParkingId", parkingId);
				Date creationDate = new Date();
				reservation.setProperty("Creation_Date", creationDate);
				reservation.setProperty("Date", date);
				reservation.setProperty("Rent_Start_Time", rentStartTime);
				reservation.setProperty("Rent_End_Time", rentEndTime);
				reservation.setProperty("User_Score", "-1");
				reservation.setProperty("Canceled", false);

				System.out.print("Adding Reservation: "
						+ reservation.toString());

				datastore.put(reservation);

				responseHTMLString = "0"; // All good bro
			} else {
				responseHTMLString = "1"; // Reservation conflict
			}
		} else if (getRes != null) {
			int count = 0;
			this.datastore = DatastoreServiceFactory.getDatastoreService();
			responseHTMLString = "<table id=\"myReservationTable\">";
			Query query = new Query("Reservation");
			Query parking = new Query("Parking");
			Filter userFilter = new FilterPredicate("User",
					Query.FilterOperator.EQUAL, user.getUserId());
			query.setFilter(userFilter);
			List<Entity> Reservations = this.datastore.prepare(query).asList(
					FetchOptions.Builder.withLimit(20));
			List<Entity> Parkings = this.datastore.prepare(parking).asList(
					FetchOptions.Builder.withLimit(20));
			if (!Reservations.isEmpty()) {
				responseHTMLString += "<tr><th>Parking</th><th>Date</th><th>From</th><th>To</th><th></th></tr>";
				for (Entity Reservation : Reservations) {
					DateFormat formatter = new SimpleDateFormat("MM/dd/yyyy");
					Date resDate = null;
					Date nowDate = null;
					try {
						resDate = formatter.parse(Reservation.getProperty(
								"Date").toString());
						nowDate = new Date();
					} catch (ParseException e) {
						e.printStackTrace();
					}
					if (Reservation.getProperty("Canceled").toString()
							.equalsIgnoreCase("false")
							&& resDate.after(nowDate)) {
						count++;
						responseHTMLString += "<tr id=\"tr"
								+ Reservation.getKey().getId() + "\">";
						for (Entity Parking : Parkings) {
							if (Long.parseLong(Reservation.getProperty(
									"ParkingId").toString()) == Parking
									.getKey().getId()) {
								responseHTMLString += "<td>"
										+ Parking.getProperty("Name") + "</td>";
								break;
							}

						}
						responseHTMLString += "<td>"
								+ Reservation.getProperty("Date") + "</td>";

						rentStartTime = Reservation.getProperty(
								"Rent_Start_Time").toString();
						rentEndTime = Reservation.getProperty("Rent_End_Time")
								.toString();
						String hour_start;
						String hour_end;
						String min_start;
						String min_end;

						if (rentStartTime.length() == 3) {
							hour_start = rentStartTime.substring(0, 1);
						} else {
							hour_start = rentStartTime.substring(0, 2);
						}
						if (rentStartTime.length() == 2) {
							hour_start = "0";
						}
						
						if (rentEndTime.length() == 3) {
							hour_end = rentEndTime.substring(0, 1);
						} else {
							hour_end = rentEndTime.substring(0, 2);
						}
						
						if (rentEndTime.length() == 2) {
							hour_end = "0";
						}
						
						min_start = String.valueOf((int) Math.floor(Integer
								.parseInt(rentStartTime.substring(rentStartTime
										.length() - 2)) * 0.6));
						min_end = String.valueOf((int) Math.floor(Integer
								.parseInt(rentEndTime.substring(rentEndTime
										.length() - 2)) * 0.6));
						if (min_start.length() == 1
								&& Integer.parseInt(min_start) > 16) {
							min_start = min_start + "0";
						}
						if (min_start.length() == 1
								&& Integer.parseInt(min_start) < 17) {
							min_start = "0" + min_start;
						}

						if (min_end.length() == 1
								&& Integer.parseInt(min_end) > 16) {
							min_end = min_end + "0";
						}
						if (min_end.length() == 1
								&& Integer.parseInt(min_end) < 17) {
							min_end = "0" + min_end;
						}

						responseHTMLString += "<td>" + hour_start + ":"
								+ min_start + "</td>";
						responseHTMLString += "<td>" + hour_end + ":" + min_end
								+ "</td>";
						responseHTMLString += "<td><input type=\"checkbox\" id=\""
								+ Reservation.getKey().getId() + "\"></td>";
						responseHTMLString += "</tr>";
					}
				}
			}
			if (count == 0) {
				responseHTMLString = "<div id=\"noReservation\">You have no reservations</div>";
			} else {
				responseHTMLString += "</table>";
				responseHTMLString += "<input id=\"cancelResButton\" type=\"button\" value=\"Cancel selected reservations\" onclick=\"cancelMyReservation()\"/>";
			}
		} else if (cancelRes != null) {
			try {
				this.datastore = DatastoreServiceFactory.getDatastoreService();
				responseHTMLString = "";
				Query query = new Query("Reservation");
				// Bad, but will do for the prototype
				List<Entity> reservations = datastore.prepare(query).asList(
						FetchOptions.Builder.withLimit(50));
				for (Entity reservation : reservations) {
					if (Long.parseLong(cancelRes) == reservation.getKey()
							.getId()) {
						reservation.setProperty("Canceled", true);
						datastore.put(reservation);
						break;
					}
				}
				responseHTMLString = cancelRes;
			} catch (Exception e) {
				responseHTMLString = "-1";
			}

		} else {
			responseHTMLString = "-1"; // Nothing to do
		}
		System.out.println(responseHTMLString);
		resp.setContentType("text/plain");
		resp.getWriter().println(responseHTMLString);

	}

	private boolean checkReservation(String userId, String parkingId,
			String rentStartTime, String rentEndTime, String date) {
		Query query = new Query("Reservation");
		Filter userFilter = new FilterPredicate("User",
				Query.FilterOperator.EQUAL, userId);
		query.setFilter(userFilter);
		List<Entity> Reservations = this.datastore.prepare(query).asList(
				FetchOptions.Builder.withLimit(20));

		if (!Reservations.isEmpty()) {
			for (Entity Reservation : Reservations) {
				if (Reservation.getProperty("ParkingId").toString()
						.equalsIgnoreCase(parkingId)
						&& Reservation.getProperty("Canceled").toString()
								.equalsIgnoreCase("false")) {
					if (date.equalsIgnoreCase(Reservation.getProperty("Date")
							.toString())) {
						// We need to check if rented hours clash
						System.out.println("Same date reservation detected");
						int cs = Integer.parseInt(Reservation.getProperty(
								"Rent_Start_Time").toString());
						int ce = Integer.parseInt(Reservation.getProperty(
								"Rent_End_Time").toString());
						int us = Integer.parseInt(rentStartTime);
						int ue = Integer.parseInt(rentEndTime);
						if ((cs <= us && ce >= us) || (cs >= us && ce <= ue)
								|| (cs <= ue && ce >= ue)) {
							System.out.println("Reservation already taken");
							return false;
						}
					}
				}
			}

		}
		System.out.println("Reservation check passed");
		return true;

	}
}
