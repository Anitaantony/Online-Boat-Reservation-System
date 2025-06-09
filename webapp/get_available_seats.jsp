<%@ page language="java" contentType="text/plain; charset=UTF-8" %>
<%@ page import="java.sql.*" %>

<%
    String boatIdStr = request.getParameter("boat_id");
    String dateStr = request.getParameter("booking_date");
    String timeSlot = request.getParameter("time_slot");

    if (boatIdStr == null || dateStr == null || timeSlot == null) {
        out.print("0");
        return;
    }

    try {
        int boatId = Integer.parseInt(boatIdStr);
        java.sql.Date bookingDate = java.sql.Date.valueOf(dateStr);

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/boat_reservation", "root", "root");

        // Get boat capacity
        PreparedStatement capStmt = conn.prepareStatement("SELECT capacity FROM boats WHERE boat_id = ?");
        capStmt.setInt(1, boatId);
        ResultSet capRs = capStmt.executeQuery();
        int capacity = 0;
        if (capRs.next()) {
            capacity = capRs.getInt("capacity");
        }
        capRs.close();
        capStmt.close();

        // Get total booked seats for selected date & slot
        PreparedStatement bookedStmt = conn.prepareStatement("SELECT SUM(adults + children) AS total_booked FROM bookings WHERE boat_id = ? AND booking_date = ? AND time_slot = ? AND status = 'confirmed'");
        bookedStmt.setInt(1, boatId);
        bookedStmt.setDate(2, bookingDate);
        bookedStmt.setString(3, timeSlot);
        ResultSet bookedRs = bookedStmt.executeQuery();

        int booked = 0;
        if (bookedRs.next()) {
            booked = bookedRs.getInt("total_booked");
        }

        bookedRs.close();
        bookedStmt.close();
        conn.close();

        int available = capacity - booked;
        out.print(Math.max(available, 0));
    } catch (Exception e) {
        out.print("0");
    }
%>
