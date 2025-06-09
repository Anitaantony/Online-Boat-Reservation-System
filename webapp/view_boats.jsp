<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>

<%
    // Session check for registered users
    String loggedInUser = (String) session.getAttribute("user_email");
    if (loggedInUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String boatType = request.getParameter("boat_type");

    if (boatType == null || boatType.trim().isEmpty()) {
        response.sendRedirect("user_dashboard.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    String displayBoatType = boatType.endsWith("s") ? boatType : boatType + "s";
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Available Boats - <%= boatType %></title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
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
            z-index: 1000;
        }

        .navbar-brand img {
            height: 40px;
            margin-right: 10px;
        }

        .container {
            margin-top: 50px;
            background: white;
            padding: 30px;
            border-radius: 10px;
        }

        h2 {
            color: #003366;
        }

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

        .table-responsive {
            overflow-x: auto;
        }

		.open-btn {
    		background-color: #003366;
    		color: white;
    		padding: 5px 15px;
    		border: none;
    		cursor: pointer;
    		font-size: 16px;
    		position: absolute;
    		top: 10px;
    		left: 20px;
    		z-index: 1100;
		}

		.open-btn:hover {
    		background-color: #0055a5;
		}

        .back-btn {
            background-color: transparent;
            border: none;
            color: #fff;
            font-size: 18px;
            text-decoration: none;
        }

        .back-btn:hover{
            text-decoration: underline;
        }

        /* Sidebar styles */
        .sidebar {
            position: fixed;
            top: 0;
            left: -250px;
            height: 100%;
            width: 250px;
            background-color: #003366;
            color: white;
            padding-top: 60px;
            transition: left 0.3s ease;
            z-index: 1001;
        }

        .sidebar a {
            display: block;
            color: white;
            padding: 15px 20px;
            text-decoration: none;
            font-size: 18px;
        }

        .sidebar a:hover {
            background-color: #0059b3;
        }

        .sidebar.open {
            left: 0;
        }

        .overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 1000;
        }

        .overlay.show {
            display: block;
        }
    </style>
</head>
<body>

<!-- NAVBAR START -->
<nav class="navbar navbar-expand-lg navbar-dark">
    <div class="container-fluid d-flex align-items-center justify-content-between position-relative">
        <!-- Menu Button on the Left -->
        <button class="open-btn me-auto" onclick="toggleMenu()">☰ Menu</button>

        <!-- Centered Logo -->
        <a class="navbar-brand position-absolute start-50 translate-middle-x d-flex align-items-center" href="#">
            <img src="img/boatlogo.png" alt="Logo"> <span class="ms-2">My Boat Tours</span>
        </a>

        <!-- Back Button on the Right -->
        <a href="user_dashboard.jsp" class="btn btn-outline-light ms-auto">Back</a>
    </div>
</nav>
<!-- NAVBAR END -->

<!-- Overlay and Sidebar -->
<div class="overlay" id="overlay" onclick="closeMenu()"></div>

<div class="sidebar" id="sidebar">
    <a href="user_dashboard.jsp">Dashboard</a>
    <a href="my_bookings.jsp">My Bookings</a>
    <a href="user_payment.jsp">Payments</a>
    <a href="user_profile.jsp">User Profile</a>
    <a href="logout.jsp">Logout</a>
</div>

<!-- Main Content -->
<div class="container">
    <h2>Available <%= displayBoatType %></h2>

    <%
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/boat_reservation", "root", "root");

            String sql = "SELECT * FROM boats WHERE boat_type = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, boatType);
            rs = stmt.executeQuery();
    %>

    <div class="table-responsive mt-4">
        <table class="table table-bordered">
            <thead class="table-dark">
                <tr>
                    <th>Boat Name</th>
                    <th>Capacity</th>
                    <th>Operator</th>
                    <th>Adult Price</th>
                    <th>Child Price</th>
                    <th>Location</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
            <%
                boolean hasData = false;
                while (rs.next()) {
                    hasData = true;
            %>
                <tr>
                    <td><%= rs.getString("boat_name") %></td>
                    <td><%= rs.getInt("capacity") %></td>
                    <td><%= rs.getString("operator_name") %></td>
                    <td>$<%= rs.getDouble("price_adult") %></td>
                    <td>$<%= rs.getDouble("price_child") %></td>
                    <td><%= rs.getString("location") %></td>
                    <td>
                        <button class="btn btn-info btn-sm view-remarks" data-id="<%= rs.getInt("boat_id") %>">Remark</button>
                        <a href="book_boat.jsp?boat_id=<%= rs.getInt("boat_id") %>" class="btn btn-success btn-sm ms-2">Book</a>
                    </td>
                </tr>
            <%
                }
                if (!hasData) {
            %>
                <tr><td colspan="7" class="text-center">No boats available.</td></tr>
            <% } %>
            </tbody>
        </table>
    </div>

    <%
        } catch (Exception e) {
            out.println("<p style='color:red;'>Something went wrong while retrieving boats. Please try again later.</p>");
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (stmt != null) stmt.close(); } catch (Exception e) {}
            try { if (conn != null) conn.close(); } catch (Exception e) {}
        }
    %>
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
                <!-- Remarks will be loaded here -->
            </div>
        </div>
    </div>
</div>

<!-- Scripts -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    $(document).on('click', '.view-remarks', function() {
        var boatId = $(this).data('id');
        $.get("getRemarks.jsp", { boat_id: boatId }, function(data) {
            $('#remarks-content').html(data);
            var myModal = new bootstrap.Modal(document.getElementById('remarksModal'));
            myModal.show();
        });
    });

    function toggleMenu() {
        document.getElementById('sidebar').classList.add('open');
        document.getElementById('overlay').classList.add('show');
    }

    function closeMenu() {
        document.getElementById('sidebar').classList.remove('open');
        document.getElementById('overlay').classList.remove('show');
    }
</script>

</body>
</html>
