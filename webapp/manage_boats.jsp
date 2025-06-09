<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.io.*" %>


<%
    String jdbcURL = "jdbc:mysql://localhost:3306/boat_reservation";
    String dbUser = "root";
    String dbPassword = "root";
    Connection conn = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcURL, dbUser, dbPassword);
        String query = "SELECT * FROM boats";
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
    <title>Manage Boats</title>
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
        .table-container { margin: 50px auto; width: 90%; }
        .overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.5); z-index: 900; }
        .add-boat-btn { position: fixed; top: 100px; right: 20px; z-index: 1000; }

        /* Modal Styles */
        .modal-content {
            background-color: #f8f9fa;
            border-radius: 8px;
            padding: 5px;
        }

        .modal-header {
            border-bottom: 2px solid #dee2e6;
        }

        .modal-title {
            font-size: 18px;
        }

        .modal-body {
            font-size: 16px;
        }
    </style>
    <script>
        // Function to toggle the sidebar
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

        // Function to close the sidebar
        function closeMenu() {
            document.getElementById("sidebar").style.left = "-250px";
            document.getElementById("overlay").style.display = "none";
        }

        // Function to show the remark details in a custom modal
        function showRemarks(boatId, boatName) {
            // Fetching remarks using AJAX
            var xhr = new XMLHttpRequest();
            xhr.open("GET", "getRemarks.jsp?boat_id=" + boatId, true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    var remarks = xhr.responseText;
                    // Set the remarks to the modal's body content
                    document.getElementById("remarks-content").innerHTML = remarks;
                    // Set the modal title to the boat's name
                    document.getElementById("remarksModalLabel").innerHTML = boatName + "- Features";
                    // Show the modal
                    var modal = new bootstrap.Modal(document.getElementById("remarksModal"));
                    modal.show();
                }
            };
            xhr.send();
        }
    </script>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark">
        <div class="container-fluid">
            <button class="open-btn" onclick="toggleMenu()">☰ Menu</button>
            <a class="navbar-brand mx-auto" href="#">
                <img src="img/boatlogo.png" alt="Logo"> My Boat Tours
            </a>
            <a href="admin_dashboard.jsp" class="btn btn-outline-light">Back</a>
        </div>
    </nav>

    <div class="overlay" id="overlay" onclick="closeMenu()"></div>

    <div class="sidebar" id="sidebar">
        <a href="admin_dashboard.jsp">Dashboard</a>
        <a href="manage_boats.jsp">Manage Boats</a>
        <a href="admin_user_management.jsp">Manage Users</a>
        <a href="admin_view_bookings.jsp">View Bookings</a>
        <a href="admin_profile.jsp">Admin Profile</a>
        <a href="logout.jsp">Logout</a>
    </div>

    <a href="addBoat.jsp" class="btn btn-success add-boat-btn">+ New Boat</a>

    <div class="table-container">
        <h2 class="text-center">Boats</h2>
        <table class="table table-bordered table-striped">
            <thead class="table-dark">
                <tr>
                    <th>Boat Name</th>
                    <th>Capacity</th>
                    <th>Operator</th>
                    <th>Price (Adult)</th>
                    <th>Price (Child)</th>
                    <th>Location</th>
                    <th>Type</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% while (rs.next()) { %>
                    <tr>
                        <td><%= rs.getString("boat_name") %></td>
                        <td><%= rs.getInt("capacity") %></td>
                        <td><%= rs.getString("operator_name") %></td>
                        <td><%= rs.getBigDecimal("price_adult") %></td>
                        <td><%= rs.getBigDecimal("price_child") %></td>
                        <td><%= rs.getString("location") %></td>
                        <td><%= rs.getString("boat_type") %></td>
                        <td>
                            <a href="updateBoat.jsp?id=<%= rs.getInt("boat_id") %>" class="btn btn-warning btn-sm">Edit</a>
                            <a href="deleteBoat.jsp?id=<%= rs.getInt("boat_id") %>" class="btn btn-danger btn-sm">Delete</a>
                            <button type="button" class="btn btn-info btn-sm" onclick="showRemarks(<%= rs.getInt("boat_id") %>, '<%= rs.getString("boat_name") %>')">Remark</button>
                        </td>
                    </tr>
                <% } %>
            </tbody>
        </table>
    </div>

    <!-- Remarks Modal -->
    <div class="modal fade" id="remarksModal" tabindex="-1" aria-labelledby="remarksModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="remarksModalLabel">Boat Remarks</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" id="remarks-content">
                    <!-- Remarks will be displayed here -->
                </div>
            </div>
        </div>
    </div>
</body>
</html>

<%
    if (rs != null) rs.close();
    if (conn != null) conn.close();
%>
