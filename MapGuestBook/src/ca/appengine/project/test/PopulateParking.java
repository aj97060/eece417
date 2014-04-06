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
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class PopulateParking extends HttpServlet {
	@Override
	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {

		DatastoreService datastore = DatastoreServiceFactory
				.getDatastoreService();
		String getAllMarker = req.getParameter("GetMarker");
		if (getAllMarker != null && !getAllMarker.equalsIgnoreCase("")) {
			List<Entity> parkings;

			// Get all parkings or a specific one
			if (getAllMarker.equalsIgnoreCase("all")) {
				Query query = new Query("Parking");
				parkings = datastore.prepare(query).asList(
						FetchOptions.Builder.withLimit(20));
			} else {
				Key parkingKey = KeyFactory.createKey("Parking", getAllMarker);
				Query query = new Query("Parking", parkingKey);
				parkings = datastore.prepare(query).asList(
						FetchOptions.Builder.withLimit(1));
			}
			String responseHTMLString = "";

			if (!parkings.isEmpty()) {
				for (Entity parking : parkings) {
					String key = String.valueOf(parking.getKey().getId());
					String name = parking.getProperty("Name").toString();
					String availability = parking.getProperty("Availability")
							.toString();
					String days = parking.getProperty("Days").toString();
					String start_time = parking.getProperty("Start_Time")
							.toString();
					String end_time = parking.getProperty("End_Time")
							.toString();
					String latitude = parking.getProperty("Latitude")
							.toString();
					String longitude = parking.getProperty("Longitude")
							.toString();
					String price = parking.getProperty("Price").toString();
					String score = parking.getProperty("Score").toString();

					responseHTMLString += key + "," + name + "," + availability
							+ "," + days + "," + start_time + "," + end_time
							+ "," + latitude + "," + longitude + "," + price
							+ "," + score + ";";

				}
				// Output the parkings
				System.out.print(responseHTMLString);
				resp.setContentType("text/plain");
				resp.getWriter().println(responseHTMLString);

			}

		}
		String runOnce = req.getParameter("CreateParking");
		// RUN ONCE to populate parkings in datastore
		if (runOnce != null && runOnce.equalsIgnoreCase("yes")) {
			Entity parking1 = new Entity("Parking");
			Entity parking2 = new Entity("Parking");
			Entity parking3 = new Entity("Parking");
			Entity parking4 = new Entity("Parking");
			Entity parking5 = new Entity("Parking");
			Entity parking6 = new Entity("Parking");
			Entity parking7 = new Entity("Parking");
			Entity parking8 = new Entity("Parking");
			Entity parking9 = new Entity("Parking");
			Entity parking10 = new Entity("Parking");
			Entity parking11 = new Entity("Parking");
			Entity parking12 = new Entity("Parking");
			Entity parking13 = new Entity("Parking");
			Entity parking14 = new Entity("Parking");

			parking1.setProperty("Name", "UBC School of Music");
			parking1.setProperty("Availability", true);
			parking1.setProperty("Days", "0111110");
			parking1.setProperty("Start_Time", "800"); // 8AM
			parking1.setProperty("End_Time", "1700"); // 5PM
			parking1.setProperty("Latitude", "49.2673915");
			parking1.setProperty("Longitude", "-123.2573533");
			parking1.setProperty("Score", "4");
			parking1.setProperty("Price", "$3 per hour");

			parking2.setProperty("Name", "UBC Osborne Center");
			parking2.setProperty("Availability", true);
			parking2.setProperty("Days", "0110110");
			parking2.setProperty("Start_Time", "900");
			parking2.setProperty("End_Time", "1900");
			parking2.setProperty("Latitude", "49.26078222");
			parking2.setProperty("Longitude", "-123.2454014");
			parking2.setProperty("Score", "3");
			parking2.setProperty("Price", "$2 per hour");

			parking3.setProperty("Name", "Thunderbird Parkade");
			parking3.setProperty("Availability", true);
			parking3.setProperty("Days", "0011100");
			parking3.setProperty("Start_Time", "800");
			parking3.setProperty("End_Time", "1700");
			parking3.setProperty("Latitude", "49.261620176786");
			parking3.setProperty("Longitude", "-123.24309528532");
			parking3.setProperty("Score", "4");
			parking3.setProperty("Price", "$5 per hour");

			parking4.setProperty("Name", "North Parkade");
			parking4.setProperty("Availability", true);
			parking4.setProperty("Days", "1111111");
			parking4.setProperty("Start_Time", "1100");
			parking4.setProperty("End_Time", "1700");
			parking4.setProperty("Latitude", "49.269046471181");
			parking4.setProperty("Longitude", "-123.25097440454");
			parking4.setProperty("Score", "5");
			parking4.setProperty("Price", "$7 per hour");

			parking5.setProperty("Name", "Museum of Anthropology");
			parking5.setProperty("Availability", true);
			parking5.setProperty("Days", "1000011");
			parking5.setProperty("Start_Time", "500");
			parking5.setProperty("End_Time", "2100");
			parking5.setProperty("Latitude", "49.27087782");
			parking5.setProperty("Longitude", "-123.2578683");
			parking5.setProperty("Score", "2");
			parking5.setProperty("Price", "$2 per hour");

			parking6.setProperty("Name", "Fraser River Parkade");
			parking6.setProperty("Availability", true);
			parking6.setProperty("Days", "0111110");
			parking6.setProperty("Start_Time", "800");
			parking6.setProperty("End_Time", "1700");
			parking6.setProperty("Latitude", "49.266062608329");
			parking6.setProperty("Longitude", "-123.25805952117");
			parking6.setProperty("Score", "3");
			parking6.setProperty("Price", "$10 per hour");

			parking7.setProperty("Name", "War Memorial Gym");
			parking7.setProperty("Availability", false);
			parking7.setProperty("Days", "0111000");
			parking7.setProperty("Start_Time", "1200");
			parking7.setProperty("End_Time", "1700");
			parking7.setProperty("Latitude", "49.26744601");
			parking7.setProperty("Longitude", "-123.2470858");
			parking7.setProperty("Score", "4");
			parking7.setProperty("Price", "$5 per hour");

			parking8.setProperty("Name", "UBC Hospital");
			parking8.setProperty("Availability", true);
			parking8.setProperty("Days", "1111111");
			parking8.setProperty("Start_Time", "600");
			parking8.setProperty("End_Time", "2000");
			parking8.setProperty("Latitude", "49.26490146");
			parking8.setProperty("Longitude", "-123.2450795");
			parking8.setProperty("Score", "1");
			parking8.setProperty("Price", "$2 per hour");

			parking9.setProperty("Name", "Ritsumeikan residence");
			parking9.setProperty("Availability", true);
			parking9.setProperty("Days", "0000001");
			parking9.setProperty("Start_Time", "800");
			parking9.setProperty("End_Time", "1800");
			parking9.setProperty("Latitude", "49.26048814");
			parking9.setProperty("Longitude", "-123.2516241");
			parking9.setProperty("Score", "5");
			parking9.setProperty("Price", "$4 per hour");

			parking10.setProperty("Name", "Falculty of Pharmaceutical");
			parking10.setProperty("Availability", true);
			parking10.setProperty("Days", "0111010");
			parking10.setProperty("Start_Time", "800");
			parking10.setProperty("End_Time", "1700");
			parking10.setProperty("Latitude", "49.26168345");
			parking10.setProperty("Longitude", "-123.2451466");
			parking10.setProperty("Score", "4");
			parking10.setProperty("Price", "$8 per hour");

			parking11.setProperty("Name", "Thunderbird Stadium");
			parking11.setProperty("Availability", false);
			parking11.setProperty("Days", "0111100");
			parking11.setProperty("Start_Time", "1500");
			parking11.setProperty("End_Time", "2100");
			parking11.setProperty("Latitude", "49.25496336");
			parking11.setProperty("Longitude", "-123.2441247");
			parking11.setProperty("Score", "3");
			parking11.setProperty("Price", "$12 per hour");

			parking12.setProperty("Name", "Thunderbird Park");
			parking12.setProperty("Availability", true);
			parking12.setProperty("Days", "0111110");
			parking12.setProperty("Start_Time", "900");
			parking12.setProperty("End_Time", "1700");
			parking12.setProperty("Latitude", "49.256735");
			parking12.setProperty("Longitude", "-123.241024");
			parking12.setProperty("Score", "2");
			parking12.setProperty("Price", "$7 per hour");

			parking13.setProperty("Name", "Thunderbird residence");
			parking13.setProperty("Availability", true);
			parking13.setProperty("Days", "0111111");
			parking13.setProperty("Start_Time", "1000");
			parking13.setProperty("End_Time", "1700");
			parking13.setProperty("Latitude", "49.25993499");
			parking13.setProperty("Longitude", "-123.2498002");
			parking13.setProperty("Score", "4");
			parking13.setProperty("Price", "$1 per hour");

			parking14.setProperty("Name", "Health Sciences Parkade");
			parking14.setProperty("Availability", true);
			parking14.setProperty("Days", "1111110");
			parking14.setProperty("Start_Time", "1100");
			parking14.setProperty("End_Time", "1600");
			parking14.setProperty("Latitude", "49.263426761536");
			parking14.setProperty("Longitude", "-123.24782870883");
			parking14.setProperty("Score", "2");
			parking14.setProperty("Price", "$5 per hour");

			List<Entity> parkings = Arrays.asList(parking1, parking2, parking3,
					parking4, parking5, parking6, parking7, parking8, parking9,
					parking10, parking11, parking12, parking13, parking14);
			datastore.put(parkings);
			System.out.print("Parkings created");
			resp.setContentType("text/plain");
			resp.getWriter().println("Parkings created");
		}
	}
}
