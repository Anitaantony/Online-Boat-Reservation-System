<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Dashboard</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        body {
			background-color: #FAF7F2;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .navbar {
            background-color: #003366;
            padding: 10px;
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
        .open-btn {
            background-color: transparent;
            border: none;
            color: white;
            font-size: 24px;
        }
        .sidebar {
            height: 100%;
            width: 250px;
            position: fixed;
            top: 0;
            left: -250px;
            background-color: #003366;
            padding-top: 60px;
            transition: 0.4s ease;
            z-index: 1000;
        }
        .sidebar a {
            color: white;
            display: block;
            padding: 15px 20px;
            font-size: 18px;
            text-decoration: none;
            transition: background 0.3s;
        }
        .sidebar a:hover {
            background-color: #0055a5;
        }
        .overlay {
            position: fixed;
            display: none;
            width: 100%;
            height: 100%;
            top: 0;
            left: 0;
            background-color: rgba(0, 0, 0, 0.4);
            z-index: 999;
        }
        .content {
            padding: 30px;
            max-width: 1300px;
            margin: auto;
        }
        .package-container {
            background-color: white;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            padding: 20px;
            margin-bottom: 50px;
            transition: transform 0.3s ease;
        }
        .package-container:hover {
            transform: translateY(-5px);
        }
        .image-grid {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            justify-content: space-between;
        }
        .image-grid img {
            flex: 1 1 30%;
            border-radius: 8px;
            object-fit: cover;
            height: 180px;
            width: 100%;
        }
        .details-container {
            margin-top: 20px;
            display: flex;
            justify-content: space-between;
            text-align: center;
        }
        .details-container div {
            flex: 1;
        }
        .details-container h5 {
            color: #003366;
            font-weight: bold;
        }
        .details-container p {
            background: #f0f0f0;
            padding: 10px;
            border-radius: 5px;
            margin: 5px 0;
        }
        .book-btn {
            background-color: #003366;
            color: white;
            border: none;
            padding: 10px 20px;
            margin-top: 20px;
            width: 100%;
            max-width: 300px;
            border-radius: 6px;
            transition: background-color 0.3s;
        }
        .book-btn:hover {
            background-color: #0055a5;
        }
        .instruction-container {
            background-color: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .scroll-btn {
            background-color: #003366;
            color: white;
            padding: 8px 15px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            margin-left: auto;
        }
        .scroll-btn:hover {
            background-color: #0055a5;
        }
        @media (max-width: 768px) {
            .details-container {
                flex-direction: column;
            }
            .image-grid {
                flex-direction: column;
            }
            .book-btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>

<nav class="navbar navbar-dark">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <button class="open-btn" onclick="toggleMenu()">☰</button>
        <a class="navbar-brand mx-auto" href="#">
            <img src="img/boatlogo.png" alt="Logo"> My Boat Tours
        </a>
    </div>
</nav>

<div class="overlay" id="overlay" onclick="closeMenu()"></div>

<div class="sidebar" id="sidebar">
    <a href="user_dashboard.jsp">Dashboard</a>
    <a href="my_bookings.jsp">My Bookings</a>
    <a href="user_payment.jsp">Payments</a>
    <a href="user_profile.jsp">User Profile</a>
    <a href="logout.jsp">Logout</a>
</div>

<div class="content">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h3><b>Package Details</b></h3>
        <button class="scroll-btn" onclick="scrollToInstruction()">View Instructions</button>
    </div>

    <!-- Boat Types (Dynamically repeatable) -->
    <%
        String[] types = {"House Boat", "Speed Boat", "Luxury Yacht"};
        String[][] prices = {
            {"500", "500", "250", "250"},
            {"300", "350", "150", "175"},
            {"1200", "1500", "600", "750"}
        };
        String[][] images = {
            {"4.jpg", "8.jpg", "9.jpg"},
            {"sb1.jpeg", "sb2.jpeg", "sb3.jpeg"},
            {"ly1.jpeg", "ly2.jpeg", "ly3.jpeg"}
        };

        for (int i = 0; i < types.length; i++) {
    %>
    <div class="package-container">
        <h4><%= types[i] %></h4>
        <div class="image-grid">
            <img src="img/<%= images[i][0] %>" alt="Image 1">
            <img src="img/<%= images[i][1] %>" alt="Image 2">
            <img src="img/<%= images[i][2] %>" alt="Image 3">
        </div>
        <div class="details-container">
            <div>
                <h5>Days</h5>
                <p>Weekdays</p>
                <p>Holidays</p>
            </div>
            <div>
                <h5>Price (Adult)</h5>
                <p>$<%= prices[i][0] %></p>
                <p>$<%= prices[i][1] %></p>
            </div>
            <div>
                <h5>Price (Child)</h5>
                <p>$<%= prices[i][2] %></p>
                <p>$<%= prices[i][3] %></p>
            </div>
        </div>
        <div class="d-flex justify-content-end mt-3">
        <form method="get" action="view_boats.jsp">
            <input type="hidden" name="boat_type" value="<%= types[i] %>">
            <button type="submit" class="book-btn">Book Tickets →</button>
        </form>
        </div>
    </div>
    <%
        }
    %>

 <div class="instruction-container mt-5" id="instruction-section">
    <h4>Instructions</h4>
    <p>
        Welcome to the Online Boat Reservation System. Please review the following important instructions before proceeding with your booking:
    </p>
    <ul>
        <li><strong>Booking Confirmation:</strong> Ensure that you have selected the correct boat type, time slot, and number of passengers before confirming your reservation.</li>
        <li><strong>Payment Policy:</strong> All payments must be completed online using the available methods. Once paid, your booking will be confirmed and reflected in your dashboard.</li>
        <li><strong>Refund & Cancellation:</strong> Cancellations made 24 hours prior to the trip may be eligible for a refund. Refer to the cancellation policy on your bookings page.</li>
        <li><strong>Safety Guidelines:</strong> All passengers must wear life jackets during the ride. Follow the instructions given by the boat operator at all times.</li>
        <li><strong>Arrival Time:</strong> Arrive at the designated location at least 30 minutes before your scheduled departure to avoid delays or missed trips.</li>
        <li><strong>Weather Conditions:</strong> Boat trips are subject to weather conditions. In case of cancellation due to weather, you will be notified and eligible for rescheduling or refund.</li>
        <li><strong>Contact Support:</strong> For any issues related to booking, payment, or general inquiries, feel free to reach out to our support team through the contact page.</li>
    </ul>
    <p>
        Thank you for choosing our service. We hope you have a safe and enjoyable boat tour experience!
    </p>
</div>

</div>

<script>
    function toggleMenu() {
        const sidebar = document.getElementById("sidebar");
        const overlay = document.getElementById("overlay");
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
    function scrollToInstruction() {
        document.getElementById("instruction-section").scrollIntoView({ behavior: "smooth" });
    }
</script>

</body>
</html>
