<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>

<%
    String boatIdStr = request.getParameter("boat_id");
    String bookingDateStr = request.getParameter("booking_date");
    String timeSlot = request.getParameter("time_slot");
    String adultsStr = request.getParameter("adults");
    String childrenStr = request.getParameter("children");

    // Basic validation
    if (boatIdStr == null || bookingDateStr == null || timeSlot == null || adultsStr == null) {
        out.println("<p style='color:red;'>Missing required booking details. Please go back and try again.</p>");
        return;
    }

    int boatId = Integer.parseInt(boatIdStr);
    int adults = Integer.parseInt(adultsStr);
    int children = (childrenStr == null || childrenStr.trim().isEmpty()) ? 0 : Integer.parseInt(childrenStr);

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

        // Step 1: Check boat capacity
        int capacity = 0;
        PreparedStatement capacityStmt = conn.prepareStatement("SELECT capacity FROM boats WHERE boat_id = ?");
        capacityStmt.setInt(1, boatId);
        ResultSet capRs = capacityStmt.executeQuery();
        if (capRs.next()) {
            capacity = capRs.getInt("capacity");
        }
        capRs.close();
        capacityStmt.close();

        // Step 2: Get already booked seats
        PreparedStatement bookedStmt = conn.prepareStatement(
            "SELECT SUM(adults + children) AS total_booked FROM bookings WHERE boat_id = ? AND booking_date = ? AND time_slot = ? AND status = 'confirmed'"
        );
        bookedStmt.setInt(1, boatId);
        bookedStmt.setDate(2, bookingDate);
        bookedStmt.setString(3, timeSlot);
        ResultSet bookedRs = bookedStmt.executeQuery();

        int alreadyBooked = 0;
        if (bookedRs.next()) {
            alreadyBooked = bookedRs.getInt("total_booked");
        }
        bookedRs.close();
        bookedStmt.close();

        int totalToBook = adults + children;
        if ((alreadyBooked + totalToBook) > capacity) {
%>
            <p style="color:red;">Sorry, not enough seats available for the selected time slot.<br>
            Only <%= (capacity - alreadyBooked) %> seat(s) are left.</p>
            <a href="book_boat.jsp?boat_id=<%= boatId %>">Go Back</a>
<%
        } else {
            // Step 3: Calculate total price
            double priceAdult = 0, priceChild = 0;
            PreparedStatement priceStmt = conn.prepareStatement("SELECT price_adult, price_child FROM boats WHERE boat_id = ?");
            priceStmt.setInt(1, boatId);
            ResultSet priceRs = priceStmt.executeQuery();

            if (priceRs.next()) {
                priceAdult = priceRs.getDouble("price_adult");
                priceChild = priceRs.getDouble("price_child");
            }
            priceRs.close();
            priceStmt.close();

            double totalPrice = (adults * priceAdult) + (children * priceChild);

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

            // Step 5: Retrieve generated booking ID
            ResultSet rs = insertBooking.getGeneratedKeys();
            int bookingId = -1;
            if (rs.next()) {
                bookingId = rs.getInt(1);
            }
            rs.close();
            insertBooking.close();
            conn.close();

            // Step 6: Redirect to payment page
            response.sendRedirect("payment.jsp?booking_id=" + bookingId + "&amount=" + totalPrice);
        }

    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }
%>
