<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.time.LocalDate" %>

<%
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    String jdbcURL = "jdbc:mysql://localhost:3306/boat_reservation";
    String dbUser = "root";
    String dbPassword = "root";

    LocalDate today = LocalDate.now();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcURL, dbUser, dbPassword);
        String query = "SELECT b.booking_id, u.first_name, bt.boat_name, b.booking_date, b.time_slot, b.adults, b.children, b.total_price, b.status " +
                       "FROM bookings b " +
                       "JOIN user u ON b.user_id = u.id " +
                       "JOIN boats bt ON b.boat_id = bt.boat_id " +
                       "WHERE b.booking_date = ?";
        stmt = conn.prepareStatement(query);
        stmt.setDate(1, java.sql.Date.valueOf(today));
        rs = stmt.executeQuery();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        body {
            background-color: #FAF7F2;
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
        }
        .navbar {
            background-color: #003366 !important;
            padding: 10px;
        }
        .navbar-brand img {
            height: 40px;
            margin-right: 10px;
        }
        .sidebar {
            height: 100vh;
            width: 250px;
            position: fixed;
            top: 0;
            left: -250px;
            background-color: #003366;
            padding-top: 60px;
            transition: 0.3s;
            z-index: 1000;
        }
        .sidebar a {
            padding: 15px;
            text-decoration: none;
            font-size: 18px;
            color: white;
            display: block;
        }
        .sidebar a:hover {
            background-color: #0055a5;
        }
        .open-btn {
            background-color: #003366;
            color: white;
            padding: 10px 15px;
            border: none;
            cursor: pointer;
            font-size: 16px;
            position: absolute;
            top: 20px;
            left: 20px;
            z-index: 1100;
        }
        .open-btn:hover {
            background-color: #0055a5;
        }
        .content {
            margin-left: 0;
            padding: 100px 30px 30px 30px;
            font-size: 20px;
        }
        .overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 900;
        }
        .table-container {
            margin-top: 30px;
        }
        .table {
            background-color: white;
            border-radius: 12px;
            overflow: hidden;
        }
        .table th {
            background-color: black;
            color: white;
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark">
        <div class="container-fluid">
            <button class="open-btn" onclick="toggleMenu()">☰ Menu</button>
            <a class="navbar-brand mx-auto" href="#">
                <img src="img/boatlogo.png" alt="Logo"> My Boat Tours
            </a>
        </div>
    </nav>

    <div class="overlay" id="overlay" onclick="closeMenu()"></div>

    <div class="sidebar" id="sidebar"><br>
        <a href="admin_dashboard.jsp">Dashboard</a>
        <a href="manage_boats.jsp">Manage Boats</a>
        <a href="admin_user_management.jsp">Manage Users</a>
        <a href="admin_view_bookings.jsp">View Bookings</a>
        <a href="admin_profile.jsp">Admin Profile</a>
        <a href="logout.jsp">Logout</a>
    </div>

    <div class="content">
        <h2 class="text-center">Today's Bookings</h2>

        <div class="table-container">
            <h4 class="text-center mt-4"> (<%= today %>)</h4>
            <div class="table-responsive">
                <table class="table table-bordered table-hover text-center table-striped">
                    <thead>
                        <tr>
                            <th>Booking ID</th>
                            <th>User</th>
                            <th>Boat</th>
                            <th>Date</th>
                            <th>Time Slot</th>
                            <th>Adults</th>
                            <th>Children</th>
                            <th>Total Price</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            boolean hasData = false;
                            while (rs != null && rs.next()) {
                                hasData = true;
                        %>
                        <tr>
                            <td><%= rs.getInt("booking_id") %></td>
                            <td><%= rs.getString("first_name") %></td>
                            <td><%= rs.getString("boat_name") %></td>
                            <td><%= rs.getDate("booking_date") %></td>
                            <td><%= rs.getString("time_slot") %></td>
                            <td><%= rs.getInt("adults") %></td>
                            <td><%= rs.getInt("children") %></td>
                            <td>$<%= rs.getBigDecimal("total_price") %></td>
                            <td><%= rs.getString("status") %></td>
                        </tr>
                        <%
                            }
                            if (!hasData) {
                        %>
                        <tr>
                            <td colspan="9">No bookings for today.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        function toggleMenu() {
            let sidebar = document.getElementById("sidebar");
            let overlay = document.getElementById("overlay");
            if (sidebar.style.left === "0px") {
                sidebar.style.left = "-250px";
                overlay.style.display = "none";
            } else {
                sidebar.style.left = "0px";
                overlay.style.display = "block";
            }
        }

        function closeMenu() {
            document.getElementById("sidebar").style.left = "-250px";
            document.getElementById("overlay").style.display = "none";
        }
    </script>
</body>
</html>

<%
    if (rs != null) rs.close();
    if (stmt != null) stmt.close();
    if (conn != null) conn.close();
%>
