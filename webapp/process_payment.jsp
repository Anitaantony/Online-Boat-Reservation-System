<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    String boatIdStr = request.getParameter("boat_id");
    String bookingDateStr = request.getParameter("booking_date");
    String timeSlot = request.getParameter("time_slot");
    int adults = Integer.parseInt(request.getParameter("adults"));
    int children = Integer.parseInt(request.getParameter("children"));

    int boatId = Integer.parseInt(boatIdStr);

    java.sql.Date bookingDate = null;
    try {
        bookingDate = java.sql.Date.valueOf(bookingDateStr);
    } catch (IllegalArgumentException e) {
        out.println("<p style='color:red;'>Invalid date format. Please go back and select a valid date.</p>");
        return;
    }

    // Get user ID from session
    Integer userId = (Integer) session.getAttribute("user_id");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/boat_reservation", "root", "root");

        // Step 1: Get boat capacity
        int capacity = 0;
        PreparedStatement getCapacity = conn.prepareStatement("SELECT capacity FROM boats WHERE boat_id = ?");
        getCapacity.setInt(1, boatId);
        ResultSet capacityResult = getCapacity.executeQuery();
        if (capacityResult.next()) {
            capacity = capacityResult.getInt("capacity");
        }
        capacityResult.close();
        getCapacity.close();

        // Step 2: Get already booked seats for the selected date and time
        PreparedStatement getBooked = conn.prepareStatement(
            "SELECT SUM(adults + children) AS total_booked FROM bookings WHERE boat_id = ? AND booking_date = ? AND time_slot = ? AND status = 'confirmed'"
        );
        getBooked.setInt(1, boatId);
        getBooked.setDate(2, bookingDate);
        getBooked.setString(3, timeSlot);
        ResultSet bookedResult = getBooked.executeQuery();

        int alreadyBooked = 0;
        if (bookedResult.next()) {
            alreadyBooked = bookedResult.getInt("total_booked");
        }
        bookedResult.close();
        getBooked.close();

        int totalToBook = adults + children;
        if (alreadyBooked + totalToBook > capacity) {
%>
            <p style="color:red;">Sorry, not enough seats available for the selected time slot. Only <%= (capacity - alreadyBooked) %> seat(s) left.</p>
            <a href="book_boat.jsp?boat_id=<%= boatId %>">Go Back</a>
<%
        } else {
            // Step 3: Calculate total price
            double totalPrice = 0;
            PreparedStatement priceStmt = conn.prepareStatement("SELECT price_adult, price_child FROM boats WHERE boat_id = ?");
            priceStmt.setInt(1, boatId);
            ResultSet priceRs = priceStmt.executeQuery();
            if (priceRs.next()) {
                double priceAdult = priceRs.getDouble("price_adult");
                double priceChild = priceRs.getDouble("price_child");
                totalPrice = adults * priceAdult + children * priceChild;
            }
            priceRs.close();
            priceStmt.close();

            // Step 4: Insert booking
            PreparedStatement insertBooking = conn.prepareStatement(
                "INSERT INTO bookings (user_id, boat_id, booking_date, time_slot, adults, children, total_price, status) VALUES (?, ?, ?, ?, ?, ?, ?, 'confirmed')",
                Statement.RETURN_GENERATED_KEYS
            );
            insertBooking.setInt(1, userId);
            insertBooking.setInt(2, boatId);
            insertBooking.setDate(3, bookingDate);
            insertBooking.setString(4, timeSlot);
            insertBooking.setInt(5, adults);
            insertBooking.setInt(6, children);
            insertBooking.setDouble(7, totalPrice);

            insertBooking.executeUpdate();

            // Step 5: Get generated booking ID
            ResultSet rsBookingId = insertBooking.getGeneratedKeys();
            int bookingId = 0;
            if (rsBookingId.next()) {
                bookingId = rsBookingId.getInt(1);
            }
            rsBookingId.close();
            insertBooking.close();
            conn.close();

            // Step 6: Redirect to payment
            response.sendRedirect("payment.jsp?booking_id=" + bookingId + "&amount=" + totalPrice);
            return;
        }

        conn.close();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }
%>
