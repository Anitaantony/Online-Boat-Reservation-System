<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.io.*" %>
<%
    String jdbcURL = "jdbc:mysql://localhost:3306/boat_reservation";
    String dbUser = "root";
    String dbPassword = "root";
    Connection conn = null;
    ResultSet rs = null;

    // Delete logic
    String deleteId = request.getParameter("delete");
    if (deleteId != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(jdbcURL, dbUser, dbPassword);

            // Step 1: Delete related bookings
            String deleteBookingsQuery = "DELETE FROM bookings WHERE user_id = ?";
            PreparedStatement deleteBookingsStmt = conn.prepareStatement(deleteBookingsQuery);
            deleteBookingsStmt.setInt(1, Integer.parseInt(deleteId));
            deleteBookingsStmt.executeUpdate();
            deleteBookingsStmt.close();

            // Step 2: Delete user
            String deleteQuery = "DELETE FROM user WHERE id = ?";
            PreparedStatement deleteStmt = conn.prepareStatement(deleteQuery);
            deleteStmt.setInt(1, Integer.parseInt(deleteId));
            deleteStmt.executeUpdate();
            deleteStmt.close();

            conn.close();
            response.sendRedirect("admin_user_management.jsp");
            return;
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error Deleting User: " + e.getMessage() + "</p>");
        }
    }

    // Fetch users
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcURL, dbUser, dbPassword);
        String query = "SELECT * FROM user WHERE user_type = 'user'";
        PreparedStatement stmt = conn.prepareStatement(query);
        rs = stmt.executeQuery();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Database Connection Error: " + e.getMessage() + "</p>");
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        body { background-color: #FAF7F2; font-family: Arial, sans-serif; margin: 0; padding: 0; }
        .navbar { background-color: #003366 !important; padding: 10px; }
        .sidebar { height: 100vh; width: 250px; position: fixed; top: 0; left: -250px; background-color: #003366; padding-top: 60px; transition: 0.3s; z-index: 1000; }
        .sidebar a { padding: 15px; text-decoration: none; font-size: 18px; color: white; display: block; }
        .sidebar a:hover { background-color: #0055a5; }
        .open-btn { background-color: #003366; color: white; padding: 10px 15px; border: none; cursor: pointer; font-size: 16px; position: absolute; top: 20px; left: 20px; z-index: 1100; }
        .open-btn:hover { background-color: #0055a5; }
        .table-container { margin: 50px auto; width: 90%; }
        .overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.5); z-index: 900; }
    </style>
    <script>
        function toggleMenu() {
            var sidebar = document.getElementById("sidebar");
            var overlay = document.getElementById("overlay");
            if (sidebar.style.left === "-250px") {
                sidebar.style.left = "0";
                overlay.style.display = "block";
            } else {
                sidebar.style.left = "-250px";
                overlay.style.display = "none";
            }
        }

        function closeMenu() {
            document.getElementById("sidebar").style.left = "-250px";
            document.getElementById("overlay").style.display = "none";
        }
    </script>
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark">
    <div class="container-fluid">
        <button class="open-btn" onclick="toggleMenu()">☰ Menu</button>
        <a class="navbar-brand mx-auto" href="#">User Management</a>
        <a href="admin_dashboard.jsp" class="btn btn-outline-light">Back</a>
    </div>
</nav>

<div class="overlay" id="overlay" onclick="closeMenu()"></div>
<div class="sidebar" id="sidebar">
    <a href="admin_dashboard.jsp">Dashboard</a>
    <a href="manage_boats.jsp">Manage Boats</a>
    <a href="admin_user_management.jsp">Manage Users</a>
    <a href="my_bookings.jsp">View Bookings</a>
    <a href="admin_profile.jsp">Admin Profile</a>
</div>

<div class="table-container">
    <table class="table table-bordered table-striped">
        <thead class="table-dark">
        <tr>
            <th>ID</th>
            <th>First Name</th>
            <th>Middle Name</th>
            <th>Last Name</th>
            <th>Email</th>
            <th>Phone</th>
            <th>Action</th>
        </tr>
        </thead>
        <tbody>
        <% while (rs != null && rs.next()) { %>
            <tr>
                <td><%= rs.getInt("id") %></td>
                <td><%= rs.getString("first_name") %></td>
                <td><%= rs.getString("middle_name") %></td>
                <td><%= rs.getString("last_name") %></td>
                <td><%= rs.getString("email") %></td>
                <td><%= rs.getString("phone") %></td>
                <td>
                    <a href="admin_user_management.jsp?delete=<%= rs.getInt("id") %>"
                       class="btn btn-danger btn-sm"
                       onclick="return confirm('Are you sure you want to delete this user?');">
                        Delete
                    </a>
                </td>
            </tr>
        <% } %>
        </tbody>
    </table>
</div>
</body>
</html>

<%
    if (rs != null) rs.close();
    if (conn != null) conn.close();
%>
