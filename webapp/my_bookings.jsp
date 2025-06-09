<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    Integer userId = (Integer) session.getAttribute("user_id");
    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Cancel booking logic
    String cancelIdStr = request.getParameter("cancel_id");
    String cancelMessage = null;

    if (cancelIdStr != null && !cancelIdStr.trim().isEmpty()) {
        try {
            int cancelId = Integer.parseInt(cancelIdStr);
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/boat_reservation", "root", "root");
            PreparedStatement ps = con.prepareStatement("UPDATE bookings SET status = 'cancelled' WHERE booking_id = ?");
            ps.setInt(1, cancelId);
            int result = ps.executeUpdate();
            if (result > 0) {
                cancelMessage = "Booking ID " + cancelId + " has been successfully cancelled.";
            } else {
                cancelMessage = "Failed to cancel booking ID " + cancelId + ". It may not exist.";
            }
            con.close();
        } catch (Exception e) {
            cancelMessage = "Error: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Bookings</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        body {
            background-color: #FAF7F2;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .navbar {
            background-color: #003366;
            padding: 10px 20px;
        }
        .navbar-brand {
            color: white;
            font-weight: bold;
            display: flex;
            align-items: center;
        }
        .navbar-brand img {
            height: 40px;
            margin-right: 10px;
        }
        .back-btn {
            color: white;
            background-color: #0055a5;
            border: none;
            padding: 6px 14px;
            border-radius: 6px;
            font-size: 15px;
            text-decoration: none;
        }
        .back-btn:hover {
            background-color: #0077cc;
        }
        .content {
            padding: 30px;
            max-width: 1200px;
            margin: auto;
        }
        table {
            background-color: white;
            border-radius: 12px;
            overflow: hidden;
        }
        th {
            background-color: #003366;
            color: white;
        }
        .cancel-btn {
            background-color: #d9534f;
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 5px;
        }
        .cancel-btn:hover {
            background-color: #c9302c;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-dark d-flex justify-content-between align-items-center">
    <a class="navbar-brand" href="#">
        <img src="img/boatlogo.png" alt="Logo"> My Boat Tours
    </a>
        <a href="user_dashboard.jsp" class="btn btn-outline-light">Back</a>
</nav>

<div class="content">
    <h3 class="mb-4"><b>My Bookings</b></h3>

    <% if (cancelMessage != null) { %>
        <div class="alert alert-info"><%= cancelMessage %></div>

        <% if (cancelMessage.contains("successfully")) { %>
            <script>
                setTimeout(function () {
                    window.location.href = 'user_dashboard.jsp';
                }, 2000); // 2 seconds
            </script>
        <% } %>
    <% } %>

    <table class="table table-bordered table-hover text-center table-striped">
        <thead class="table-dark">
            <tr>
                <th>Booking ID</th>
                <th>Boat ID</th>
                <th>Booking Date</th>
                <th>Time Slot</th>
                <th>Adults</th>
                <th>Children</th>
                <th>Total Price</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
        <%
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/boat_reservation", "root", "root");
                PreparedStatement ps = con.prepareStatement("SELECT * FROM bookings WHERE user_id = ?");
                ps.setInt(1, userId);
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
        %>
            <tr>
                <td><%= rs.getInt("booking_id") %></td>
                <td><%= rs.getInt("boat_id") %></td>
                <td><%= rs.getDate("booking_date") %></td>
                <td><%= rs.getString("time_slot") %></td>
                <td><%= rs.getInt("adults") %></td>
                <td><%= rs.getInt("children") %></td>
                <td>$<%= rs.getDouble("total_price") %></td>
                <td><%= rs.getString("status") %></td>
                <td>
                    <% if (!rs.getString("status").equals("cancelled")) { %>
                        <form method="post" action="my_bookings.jsp">
                            <input type="hidden" name="cancel_id" value="<%= rs.getInt("booking_id") %>">
                            <button type="submit" class="cancel-btn">Cancel</button>
                        </form>
                    <% } else { %>
                        Cancelled
                    <% } %>
                </td>
            </tr>
        <%
                }
                con.close();
            } catch (Exception e) {
        %>
            <tr><td colspan="9">Error: <%= e.getMessage() %></td></tr>
        <%
            }
        %>
        </tbody>
    </table>
</div>

</body>
</html>
