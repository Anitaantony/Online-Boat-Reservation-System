<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>

<%
    String filterDate = request.getParameter("filterDate");
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    String jdbcURL = "jdbc:mysql://localhost:3306/boat_reservation";
    String dbUser = "root";
    String dbPassword = "root";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcURL, dbUser, dbPassword);

        String query = "SELECT b.booking_id, u.first_name, u.last_name, bt.boat_name, b.booking_date, b.time_slot, b.adults, b.children, b.total_price, b.status " +
                       "FROM bookings b " +
                       "JOIN user u ON b.user_id = u.id " +
                       "JOIN boats bt ON b.boat_id = bt.boat_id ";

        if (filterDate != null && !filterDate.isEmpty()) {
            query += "WHERE b.booking_date = ?";
            stmt = conn.prepareStatement(query);
            stmt.setDate(1, java.sql.Date.valueOf(filterDate));
        } else {
            stmt = conn.prepareStatement(query);
        }

        rs = stmt.executeQuery();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Admin - View Bookings</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #FAF7F2;
            font-family: Arial, sans-serif;
        }
        .navbar {
            background-color: #003366;
        }
        .navbar-brand {
            color: #fff !important;
            font-weight: bold;
            display: flex;
            align-items: center;
        }
        .navbar-brand img {
            height: 40px;
            margin-right: 10px;
        }
        .container {
            margin-top: 30px;
        }
        .table thead {
            background-color: #003366;
            color: white;
        }
        .filter-form {
            text-align: right;
            margin-bottom: 20px;
        }
        .filter-form input[type="date"] {
            padding: 6px;
            border-radius: 8px;
            border: 1px solid #ccc;
        }
        .filter-form button {
            padding: 6px 12px;
            border-radius: 8px;
            border: none;
            background-color: #003366;
            color: white;
            margin-left: 5px;
        }
        .filter-form button:hover {
            background-color: #0055a5;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark px-3">
    <a class="navbar-brand" href="admin_dashboard.jsp">
        <img src="img/boatlogo.png" alt="Logo"> My Boat Tours
    </a>
    <div class="ms-auto">
        <a href="admin_dashboard.jsp" class="btn btn-outline-light">Back</a>
    </div>
</nav>


<div class="container">
    <div class="row">
        <div class="col-12 filter-form">
            <form method="get" action="admin_view_bookings.jsp" class="d-flex justify-content-end">
                <label class="me-2">Filter by Date:</label>
                <input type="date" name="filterDate" value="<%= filterDate != null ? filterDate : "" %>" required>
                <button type="submit">Filter</button>
            </form>
        </div>
    </div>

    <h3 class="text-center mb-4">All Bookings</h3>

    <div class="table-responsive">
        <table class="table table-bordered text-center align-middle table-striped">
            <thead class="table-dark">
            
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
                    <td><%= rs.getString("first_name") %> <%= rs.getString("last_name") %></td>
                    <td><%= rs.getString("boat_name") %></td>
                    <td><%= rs.getDate("booking_date") %></td>
                    <td><%= rs.getString("time_slot") %></td>
                    <td><%= rs.getInt("adults") %></td>
                    <td><%= rs.getInt("children") %></td>
                    <td>$<%= rs.getBigDecimal("total_price") %></td>
                    <td><%= rs.getString("status") %></td>
                </tr>
                <% } if (!hasData) { %>
                <tr>
                    <td colspan="9">No bookings found<%= filterDate != null ? " for " + filterDate : "" %>.</td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

</body>
</html>

<%
    if (rs != null) rs.close();
    if (stmt != null) stmt.close();
    if (conn != null) conn.close();
%>
