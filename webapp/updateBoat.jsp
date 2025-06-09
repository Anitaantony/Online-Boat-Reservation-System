<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>


<%
    // Database credentials
    String jdbcURL = "jdbc:mysql://localhost:3306/boat_reservation";
    String dbUser = "root";
    String dbPassword = "root";
    
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    String boatId = request.getParameter("id");
    String message = null; // Variable to hold success/error messages
    String alertClass = "";
    
    try {
        // Load MySQL JDBC Driver
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcURL, dbUser, dbPassword);
        
        if (boatId == null || boatId.isEmpty()) {
            message = "Error: Boat ID is missing!";
            alertClass = "alert-danger";
        } else {
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                // Retrieving form data
                String boatName = request.getParameter("boat_name");
                int capacity = Integer.parseInt(request.getParameter("capacity"));
                String operatorName = request.getParameter("operator_name");
                double priceAdult = Double.parseDouble(request.getParameter("price_adult"));
                double priceChild = Double.parseDouble(request.getParameter("price_child"));
                String location = request.getParameter("location");
                String boatType = request.getParameter("boat_type");
                String remarks = request.getParameter("remarks"); // Added Remarks

                // Validation for all fields
                if (boatName.isEmpty() || operatorName.isEmpty() || location.isEmpty() || remarks.isEmpty()) {
                    message = "All fields are required!";
                    alertClass = "alert-danger";
                } else if (capacity <= 0) {
                    message = "Capacity must be a positive number!";
                    alertClass = "alert-danger";
                } else if (priceAdult <= 0 || priceChild < 0) {
                    message = "Price values must be positive!";
                    alertClass = "alert-danger";
                } else {
                    // Update query
                    String updateQuery = "UPDATE boats SET boat_name = ?, capacity = ?, operator_name = ?, price_adult = ?, price_child = ?, location = ?, boat_type = ?, remarks = ? WHERE boat_id = ?";
                    stmt = conn.prepareStatement(updateQuery);
                    stmt.setString(1, boatName);
                    stmt.setInt(2, capacity);
                    stmt.setString(3, operatorName);
                    stmt.setDouble(4, priceAdult);
                    stmt.setDouble(5, priceChild);
                    stmt.setString(6, location);
                    stmt.setString(7, boatType);
                    stmt.setString(8, remarks); // Setting remarks
                    stmt.setInt(9, Integer.parseInt(boatId));

                    int rowsUpdated = stmt.executeUpdate();
                    if (rowsUpdated > 0) {
                        message = "Boat details updated successfully!";
                        alertClass = "alert-success";
                    } else {
                        message = "Error updating boat details!";
                        alertClass = "alert-danger";
                    }
                }
            }

            // Fetch existing boat details for form pre-filling
            String query = "SELECT * FROM boats WHERE boat_id = ?";
            stmt = conn.prepareStatement(query);
            stmt.setInt(1, Integer.parseInt(boatId));
            rs = stmt.executeQuery();

            if (rs.next()) {
                request.setAttribute("boatId", rs.getInt("boat_id"));
                request.setAttribute("boatName", rs.getString("boat_name"));
                request.setAttribute("capacity", rs.getInt("capacity"));
                request.setAttribute("operator", rs.getString("operator_name"));
                request.setAttribute("priceAdult", rs.getDouble("price_adult"));
                request.setAttribute("priceChild", rs.getDouble("price_child"));
                request.setAttribute("location", rs.getString("location"));
                request.setAttribute("boatType", rs.getString("boat_type"));
                request.setAttribute("remarks", rs.getString("remarks"));
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        message = "Database Error: " + e.getMessage();
        alertClass = "alert-danger";
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update Boat Details</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        body { background-color: #FAF7F2; font-family: Arial, sans-serif; margin: 0; padding: 0; }
        .navbar { background-color: #003366 !important; padding: 10px; }
        .navbar-brand img { height: 40px; margin-right: 10px; }
        .sidebar { height: 100vh; width: 250px; position: fixed; top: 0; left: -250px; background-color: #003366; padding-top: 60px; transition: 0.3s; z-index: 1000; }
        .sidebar a { padding: 15px; text-decoration: none; font-size: 18px; color: white; display: block; }
        .sidebar a:hover { background-color: #0055a5; }
        .open-btn { background-color: #003366; color: white; padding: 10px 15px; border: none; cursor: pointer; font-size: 16px; position: absolute; top: 20px; left: 20px; z-index: 1100; }
        .open-btn:hover { background-color: #0055a5; }
        .container { background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); max-width: 500px; width: 100%; margin-top: 100px; }
        .btn-primary { width: 100%; background-color: #003366; border: none; }
        .btn-primary:hover { background-color: #1e2b47; }
        h2 { text-align: center; color: #003366; }
        .alert { margin-bottom: 20px; }
        .message.success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .message.error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark">
        <div class="container-fluid">
            <button class="open-btn" onclick="toggleMenu()">☰ Menu</button>
            <a class="navbar-brand mx-auto" href="#">My Boat Tours</a>
            <a href="manage_boats.jsp" class="btn btn-outline-light">Back</a>
        </div>
    </nav>

    <div class="sidebar" id="sidebar">
        <a href="admin_dashboard.jsp">Dashboard</a>
        <a href="manage_boats.jsp">Manage Boats</a>
        <a href="#">Manage Users</a>
        <a href="#">View Bookings</a>
        <a href="admin_profile.jsp">Admin Profile</a>
        <a href="logout.jsp">Logout</a>
    </div>

    <div class="container">
        <h2>Update Boat Details</h2>

        <% if (message != null) { %>
            <div class="alert <%= alertClass %>"><%= message %></div>
        <% } %>

        <form action="updateBoat.jsp?id=<%= boatId %>" method="post">
            <div class="mb-3">
                <label class="form-label">Boat Name</label>
                <input type="text" class="form-control" name="boat_name" value="<%= request.getAttribute("boatName") %>" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Capacity</label>
                <input type="number" class="form-control" name="capacity" value="<%= request.getAttribute("capacity") %>" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Operator Name</label>
                <input type="text" class="form-control" name="operator_name" value="<%= request.getAttribute("operator") %>" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Price (Adult)</label>
                <input type="number" step="0.01" class="form-control" name="price_adult" value="<%= request.getAttribute("priceAdult") %>" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Price (Child)</label>
                <input type="number" step="0.01" class="form-control" name="price_child" value="<%= request.getAttribute("priceChild") %>" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Location</label>
                <input type="text" class="form-control" name="location" value="<%= request.getAttribute("location") %>" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Boat Type</label>
                <select class="form-control" name="boat_type" required>
                    <option value="House Boat" <%= "House Boat".equals(request.getAttribute("boatType")) ? "selected" : "" %>>House Boat</option>
                    <option value="Speed Boat" <%= "Speed Boat".equals(request.getAttribute("boatType")) ? "selected" : "" %>>Speed Boat</option>
                    <option value="Luxuary Yacht" <%= "Luxuary Yacht".equals(request.getAttribute("boatType")) ? "selected" : "" %>>Luxuary Yacht</option>
                </select>
            </div>
            <div class="mb-3">
                <label class="form-label">Remarks</label>
                <textarea class="form-control" name="remarks" required><%= request.getAttribute("remarks") %></textarea>
            </div>
            <button type="submit" class="btn btn-primary">Update Boat</button>
        </form>
    </div>
    <% if ("alert-success".equals(alertClass)) { %>
    <script>
        setTimeout(function() {
            window.location.href = "manage_boats.jsp";
        }, 2000); // Redirect after 2 seconds
    <% } %>   
    </script>
    <script>
        function toggleMenu() {
            const sidebar = document.getElementById("sidebar");
            sidebar.style.left = sidebar.style.left === "0px" ? "-250px" : "0px";
        }
    </script>
</body>
</html>
