<%@ page import="java.sql.*, java.text.DecimalFormat" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%
    if (session.getAttribute("user_id") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String jdbcURL = "jdbc:mysql://localhost:3306/boat_reservation";
    String dbUser = "root";
    String dbPassword = "root";

    Connection con = null;
    PreparedStatement pst = null;
    ResultSet rs = null;

    Integer userId = (Integer) session.getAttribute("user_id");
    String bookingIdParam = request.getParameter("booking_id");

    if (userId == null || bookingIdParam == null) {
        out.println("<h3>Error: Missing booking ID!</h3>");
        return;
    }

    int bookingId = Integer.parseInt(bookingIdParam);
    String boatName = "", location = "", timeSlot = "", boatType = "", operator = "";
    int adults = 0, children = 0, capacity = 0;
    double priceAdult = 0.0, priceChild = 0.0, totalAmount = 0.0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(jdbcURL, dbUser, dbPassword);

        String sql = "SELECT b.adults, b.children, b.time_slot, b.total_price, "
                   + "bt.boat_name, bt.location, bt.boat_type, bt.operator_name, "
                   + "bt.price_adult, bt.price_child, bt.capacity "
                   + "FROM bookings b JOIN boats bt ON b.boat_id = bt.boat_id "
                   + "WHERE b.booking_id = ?";
        pst = con.prepareStatement(sql);
        pst.setInt(1, bookingId);
        rs = pst.executeQuery();

        if (rs.next()) {
            adults = rs.getInt("adults");
            children = rs.getInt("children");
            timeSlot = rs.getString("time_slot");
            totalAmount = rs.getDouble("total_price");

            boatName = rs.getString("boat_name");
            location = rs.getString("location");
            boatType = rs.getString("boat_type");
            operator = rs.getString("operator_name");
            priceAdult = rs.getDouble("price_adult");
            priceChild = rs.getDouble("price_child");
            capacity = rs.getInt("capacity");
        } else {
            out.println("<h3>Booking not found!</h3>");
            return;
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<h3>Error: " + e.getMessage() + "</h3>");
    } finally {
        try {
            if (rs != null) rs.close();
            if (pst != null) pst.close();
            if (con != null) con.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    DecimalFormat df = new DecimalFormat("#,##0.00");
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Payment - <%= boatName %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #FAF7F2;
            font-family: 'Segoe UI', sans-serif;
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

        .payment-container {
            background: linear-gradient(to right, #ffffff, #f2f9ff);
            border-radius: 20px;
            padding: 30px;
            margin-top: 30px;
            box-shadow: 0 6px 20px rgba(0,0,0,0.1);
        }

        h4 {
            color: #003366;
            border-bottom: 2px solid #006699;
            padding-bottom: 10px;
            margin-bottom: 25px;
        }

        p {
            font-size: 16px;
            margin-bottom: 8px;
            color: #333;
        }

        .form-label {
            font-weight: 600;
            color: #004080;
        }

        .form-control {
            border-radius: 12px;
            padding: 10px;
            border: 1px solid #ccc;
            transition: border 0.2s;
        }

        .form-control:focus {
            border-color: #006699;
            box-shadow: 0 0 0 0.2rem rgba(0,102,153,0.2);
        }

        .btn-primary {
            background-color: #007bff;
            border-radius: 25px;
            padding: 10px 25px;
            font-weight: bold;
        }

        .btn-primary:hover {
            background-color: #0056b3;
        }

        .summary-section {
            background-color: #eaf6ff;
            border-radius: 15px;
            padding: 20px;
            margin-bottom: 25px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }

    </style>
</head>
<body>

<!-- NAVBAR START -->
<nav class="navbar navbar-expand-lg navbar-dark">
    <div class="container-fluid d-flex align-items-center justify-content-between position-relative">
        <a class="navbar-brand position-absolute start-50 translate-middle-x d-flex align-items-center" href="#">
            <img src="img/boatlogo.png" alt="Logo"> <span class="ms-2">My Boat Tours</span>
        </a>
        <a href="user_dashboard.jsp" class="btn btn-outline-light ms-auto">Back</a>
    </div>
</nav>
<!-- NAVBAR END -->

<div class="container">
    <div class="payment-container">
        <div class="row">
            <!-- Booking Info -->
            <div class="col-md-6">
                <div class="summary-section">
                    <h4>Booking Summary</h4>
                    <p><strong>Boat Name:</strong> <%= boatName %></p>
                    <p><strong>Location:</strong> <%= location %></p>
                    <p><strong>Type:</strong> <%= boatType %></p>
                    <p><strong>Operator:</strong> <%= operator %></p>
                    <p><strong>Time Slot:</strong> <%= timeSlot %></p>
                    <p><strong>Adults:</strong> <%= adults %> x ₹<%= df.format(priceAdult) %></p>
                    <p><strong>Children:</strong> <%= children %> x ₹<%= df.format(priceChild) %></p>
                    <p><strong>Total Price:</strong> ₹<%= df.format(totalAmount) %></p>
                </div>
            </div>

            <!-- Payment Form -->
            <div class="col-md-6">
                <h4>Payment Details</h4>
                <form action="confirmPayment.jsp" method="post" onsubmit="return validatePayment()">
                    <input type="hidden" name="booking_id" value="<%= bookingId %>">
                    <input type="hidden" name="user_id" value="<%= userId %>">
                    <input type="hidden" name="amount" value="<%= totalAmount %>">

                    <div class="mb-3">
                        <label class="form-label">Card Number</label>
                        <input type="text" name="card_number" maxlength="16" class="form-control" placeholder="Enter 16-digit card number" required oninput="this.value=this.value.replace(/[^0-9]/g,'');">
                    </div>

                    <div class="mb-3">
                        <label class="form-label">ATM PIN</label>
                        <input type="password" name="atm_pin" maxlength="4" class="form-control" placeholder="Enter 4-digit PIN" required oninput="this.value=this.value.replace(/[^0-9]/g,'');">
                    </div>

                    <button type="submit" class="btn btn-primary w-100">Pay ₹<%= df.format(totalAmount) %></button>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    function validatePayment() {
        let cardNumber = document.getElementsByName("card_number")[0].value;
        let atmPin = document.getElementsByName("atm_pin")[0].value;

        if (cardNumber.length !== 16) {
            alert("Card number must be exactly 16 digits.");
            return false;
        }
        if (atmPin.length !== 4) {
            alert("ATM PIN must be exactly 4 digits.");
            return false;
        }
        return true;
    }
</script>

</body>
</html>
