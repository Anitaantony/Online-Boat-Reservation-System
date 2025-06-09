<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    HttpSession sessionObj = request.getSession(false);
    Integer userId = (sessionObj != null) ? (Integer) sessionObj.getAttribute("user_id") : null;

    if (userId == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String url = "jdbc:mysql://localhost:3306/boat_reservation";
    String dbUser = "root";
    String dbPassword = "root";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Your Payments</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f4f6f8;
            font-family: Arial, sans-serif;
        }

        .container {
            margin-top: 100px;
            max-width: 1000px;
        }

        h2 {
            color: #003366;
            margin-bottom: 30px;
        }

        table {
            background-color: white;
            border-radius: 10px;
            overflow: hidden;
        }

        th {
            background-color: #003366;
            color: white;
        }

        td, th {
            text-align: center;
            vertical-align: middle !important;
        }

        .navbar {
            background-color: #003366;
        }

        .navbar-brand,
        .navbar-text,
        .btn-outline-light {
            color: white !important;
        }

        .back-btn {
            margin-left: auto;
        }
    </style>
</head>
<body>

<!-- Navbar with only back button -->
<nav class="navbar navbar-expand-lg fixed-top">
    <div class="container-fluid">
        <a class="navbar-brand" href="#">User Payments</a>
        <div class="ms-auto">
            <a href="user_dashboard.jsp" class="btn btn-outline-light back-btn">Back</a>
        </div>
    </div>
</nav>

<!-- Main Container -->
<div class="container">
    <h2>Your Payment History</h2>

    <table class="table table-bordered table-hover">
        <thead class="table-dark">
            <tr>
                <th>Payment ID</th>
                <th>Booking ID</th>
                <th>Amount</th>
                <th>Payment Method</th>
                <th>Status</th>
                <th>Date</th>
            </tr>
        </thead>
        <tbody>
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection(url, dbUser, dbPassword);

                    String sql = "SELECT * FROM payments WHERE user_id = ? ORDER BY payment_date DESC";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setInt(1, userId);
                    rs = pstmt.executeQuery();

                    boolean hasResults = false;
                    while (rs.next()) {
                        hasResults = true;
            %>
                        <tr>
                            <td><%= rs.getInt("payment_id") %></td>
                            <td><%= rs.getInt("booking_id") %></td>
                            <td>₹<%= rs.getDouble("amount") %></td>
                            <td><%= rs.getString("payment_method") %></td>
                            <td>
                                <span class="badge bg-<%= rs.getString("payment_status").equals("completed") ? "success" : rs.getString("payment_status").equals("pending") ? "warning text-dark" : "danger" %>">
                                    <%= rs.getString("payment_status").toUpperCase() %>
                                </span>
                            </td>
                            <td><%= new SimpleDateFormat("dd MMM yyyy, hh:mm a").format(rs.getTimestamp("payment_date")) %></td>
                        </tr>
            <%
                    }

                    if (!hasResults) {
            %>
                        <tr>
                            <td colspan="6">No payments found.</td>
                        </tr>
            <%
                    }
                } catch (Exception e) {
                    out.println("<tr><td colspan='6'>Error: " + e.getMessage() + "</td></tr>");
                } finally {
                    if (rs != null) rs.close();
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                }
            %>
        </tbody>
    </table>
</div>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
