<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    String bookingIdStr = request.getParameter("booking_id");
    String userIdStr = request.getParameter("user_id");
    String amountStr = request.getParameter("amount");

    // Simulated payment details (card number & pin)
    String cardNumber = request.getParameter("card_number");
    String atmPin = request.getParameter("atm_pin");

    boolean paymentSuccess = false;
    String errorMessage = null;

    if (bookingIdStr == null || userIdStr == null || amountStr == null || cardNumber == null || atmPin == null) {
        errorMessage = "Missing payment information.";
    } else {
        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            int userId = Integer.parseInt(userIdStr);
            double amount = Double.parseDouble(amountStr);

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/boat_reservation", "root", "root");

            // Insert into payments
            PreparedStatement insertPayment = conn.prepareStatement(
                "INSERT INTO payments (booking_id, user_id, amount, payment_method, payment_status, payment_date) VALUES (?, ?, ?, ?, 'completed', NOW())"
            );
            insertPayment.setInt(1, bookingId);
            insertPayment.setInt(2, userId);
            insertPayment.setDouble(3, amount);
            insertPayment.setString(4, "Card");
            insertPayment.executeUpdate();
            insertPayment.close();

            // Update booking status
            PreparedStatement updateBooking = conn.prepareStatement("UPDATE bookings SET status = 'confirmed' WHERE booking_id = ?");
            updateBooking.setInt(1, bookingId);
            updateBooking.executeUpdate();
            updateBooking.close();

            conn.close();
            paymentSuccess = true;

        } catch (Exception e) {
            e.printStackTrace();
            errorMessage = "Payment Failed: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Payment Confirmation</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            background-color: #f4f6f8;
        }

        .navbar {
            background-color: #003366;
        }

        .navbar-brand {
            color: white;
            font-weight: bold;
        }

        .back-btn {
            margin-left: auto;
        }

        .back-btn a {
            color: white;
            border: 1px solid white;
            padding: 6px 14px;
            border-radius: 6px;
            text-decoration: none;
        }

        .back-btn a:hover {
            background-color: white;
            color: #003366;
        }

        .container {
            margin-top: 100px;
            max-width: 700px;
        }

        .card {
            border-radius: 15px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }

        .success {
            color: #28a745;
            font-size: 22px;
            margin-bottom: 15px;
        }

        .error {
            color: #dc3545;
            font-size: 18px;
            margin-bottom: 15px;
        }

        .btn-dashboard {
            background-color: #28a745;
            border: none;
        }

        .btn-dashboard:hover {
            background-color: #218838;
        }

        .btn-retry {
            background-color: #dc3545;
            border: none;
        }

        .btn-retry:hover {
            background-color: #c82333;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg fixed-top">
    <div class="container-fluid">
        <a class="navbar-brand" href="#">Your Payment</a>
        <div class="back-btn">
            <a href="user_dashboard.jsp">Back</a>
        </div>
    </div>
</nav>

<div class="container">
    <div class="card p-5 mt-4 text-center">
        <% if (paymentSuccess) { %>
            <div class="success">✅ Payment Successful!</div>
            <p>Your booking has been confirmed and the payment recorded successfully.</p>
        <% } else { %>
            <div class="error">❌ <%= errorMessage %></div>
            <a href="payment.jsp?booking_id=<%= bookingIdStr %>" class="btn btn-retry mt-3 text-white px-4 py-2">Try Again</a>
        <% } %>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
