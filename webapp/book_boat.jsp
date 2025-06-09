<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    String boatIdParam = request.getParameter("boat_id");
    if (boatIdParam == null || boatIdParam.trim().isEmpty()) {
        response.sendRedirect("user_dashboard.jsp");
        return;
    }

    int boatId = Integer.parseInt(boatIdParam);
    String boatName = "", operator = "", location = "", boatType = "", remarks = "";
    int capacity = 0;
    double priceAdult = 0.0, priceChild = 0.0;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/boat_reservation", "root", "root");

        String sql = "SELECT * FROM boats WHERE boat_id = ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setInt(1, boatId);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            boatName = rs.getString("boat_name");
            capacity = rs.getInt("capacity");
            operator = rs.getString("operator_name");
            priceAdult = rs.getDouble("price_adult");
            priceChild = rs.getDouble("price_child");
            location = rs.getString("location");
            boatType = rs.getString("boat_type");
            remarks = rs.getString("remarks");
        } else {
            out.println("<p style='color:red;'>Boat not found!</p>");
            return;
        }

        rs.close();
        ps.close();
        conn.close();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error retrieving boat details: " + e.getMessage() + "</p>");
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Book Boat - <%= boatName %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #FAF7F2;
            font-family: Arial, sans-serif;
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
        .calendar-container, .form-container {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        .calendar-container {
            height: 75%;
            width: 100%;
        }
        #selected-date-display, #available-seats {
            font-weight: bold;
        }
        #selected-date-display {
            color: #006699;
        }
        #available-seats {
            color: green;
        }

        /* Updated form-container styling */
        .form-container {
            background: linear-gradient(to right, #ffffff, #f2f9ff);
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 6px 20px rgba(0,0,0,0.1);
            transition: all 0.3s ease-in-out;
        }

        .form-container h4 {
            color: #003366;
            border-bottom: 2px solid #006699;
            padding-bottom: 10px;
            margin-bottom: 25px;
        }

        .form-container p {
            font-size: 16px;
            margin-bottom: 8px;
            color: #333;
        }

        .form-label {
            font-weight: 600;
            color: #004080;
        }

        .form-control,
        .form-select {
            border-radius: 12px;
            padding: 10px;
            border: 1px solid #ccc;
            transition: border 0.2s;
        }

        .form-control:focus,
        .form-select:focus {
            border-color: #006699;
            box-shadow: 0 0 0 0.2rem rgba(0,102,153,0.2);
        }

        .btn-success {
            background-color: #28a745;
            border-radius: 25px;
            padding: 10px 25px;
            font-weight: bold;
        }

        .btn-secondary {
            border-radius: 25px;
            padding: 10px 25px;
            margin-left: 10px;
        }

        #available-seats {
            font-size: 18px;
            color: #28a745;
        }

        #selected-date-display {
            color: #005f99;
            font-size: 16px;
        }

        .btn:hover {
            opacity: 0.9;
            transform: translateY(-1px);
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

<div class="container mt-4">
    <div class="row">
        <!-- Calendar Column -->
        <div class="col-md-5">
            <div class="calendar-container">
                <h5>Select Booking Date</h5>
                <div id="calendar"></div>
            </div>
        </div>

        <!-- Booking Summary Column -->
        <div class="col-md-7">
            <div class="form-container">
                <h4 class="mb-3">Booking Summary</h4>
                <p><strong>Boat Name:</strong> <%= boatName %></p>
                <p><strong>Operator:</strong> <%= operator %></p>
                <p><strong>Location:</strong> <%= location %></p>
                <p><strong>Selected Date:</strong> <span id="selected-date-display">None</span></p>
                <p><strong>Available Seats:</strong> <span id="available-seats">-</span></p>

                <form action="process_booking.jsp" method="post">
                    <input type="hidden" name="boat_id" value="<%= boatId %>">
                    <input type="hidden" name="boat_name" value="<%= boatName %>">
                    <input type="hidden" name="booking_date" id="booking_date" required>
                    <input type="hidden" id="capacity" value="<%= capacity %>">

                    <div class="mb-3">
                        <label for="time_slot" class="form-label">Convenient Time Slot:</label>
                        <select name="time_slot" id="time_slot" class="form-select" required onchange="checkAvailability()">
                            <option value="">Select</option>
                            <option>08:00 AM - 10:00 AM</option>
                            <option>10:30 AM - 12:30 PM</option>
                            <option>03:30 PM - 05:30 PM</option>
                            <option>06:00 PM - 08:00 PM</option>
                        </select>
                    </div>

                    <div class="mb-3">
                        <label for="adults" class="form-label">Number of Adults:</label>
                        <input type="number" name="adults" id="adults" class="form-control" min="1" max="<%= capacity %>" required>
                    </div>

                    <div class="mb-3">
                        <label for="children" class="form-label">Number of Children:</label>
                        <input type="number" name="children" id="children" class="form-control" min="0" max="<%= capacity %>">
                    </div>

                    <button type="submit" class="btn btn-success">Confirm Booking</button>
                    <a href="user_dashboard.jsp" class="btn btn-secondary">Cancel</a>
                </form>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/fullcalendar@6.1.8/index.global.min.js"></script>
<script>
    const boatId = <%= boatId %>;

    document.addEventListener('DOMContentLoaded', function () {
        const calendarEl = document.getElementById('calendar');
        const calendar = new FullCalendar.Calendar(calendarEl, {
            initialView: 'dayGridMonth',
            selectable: true,
            dateClick: function(info) {
                const selectedDate = info.dateStr;
                document.getElementById("booking_date").value = selectedDate;
                document.getElementById("selected-date-display").innerText = selectedDate;
                updateTimeSlotOptions(selectedDate);
                checkAvailability();
            },
            validRange: { start: new Date().toISOString().split("T")[0] }
        });

        calendar.render();
    });

    function updateTimeSlotOptions(selectedDate) {
        const timeSlotSelect = document.getElementById("time_slot");
        const now = new Date();
        const selected = new Date(selectedDate);
        const currentHour = now.getHours() + now.getMinutes() / 60;

        for (let option of timeSlotSelect.options) {
            option.disabled = false;
        }

        if (selected.toDateString() === now.toDateString()) {
            if (currentHour >= 8) disableSlot("08:00 AM - 10:00 AM");
            if (currentHour >= 10.5) disableSlot("10:30 AM - 12:30 PM");
            if (currentHour >= 15.5) disableSlot("03:30 PM - 05:30 PM");
            if (currentHour >= 18) disableSlot("06:00 PM - 08:00 PM");
        }

        function disableSlot(label) {
            const options = timeSlotSelect.options;
            for (let i = 0; i < options.length; i++) {
                if (options[i].text === label) {
                    options[i].disabled = true;
                    if (options[i].selected) {
                        options[i].selected = false;
                        document.getElementById("available-seats").innerText = "-";
                    }
                }
            }
        }
    }

    function checkAvailability() {
        const date = document.getElementById("booking_date").value;
        const timeSlot = document.getElementById("time_slot").value;
        const capacity = parseInt(document.getElementById("capacity").value);
        const submitBtn = document.querySelector("button[type='submit']");
        const adultsInput = document.getElementById("adults");
        const childrenInput = document.getElementById("children");

        if (date && timeSlot) {
            fetch("get_available_seats.jsp?boat_id=" + boatId + "&booking_date=" + date + "&time_slot=" + encodeURIComponent(timeSlot))
                .then(response => response.text())
                .then(data => {
                    const availableSeats = parseInt(data.trim());
                    document.getElementById("available-seats").innerText = availableSeats;

                    if (availableSeats <= 0) {
                        submitBtn.disabled = true;
                        adultsInput.disabled = true;
                        childrenInput.disabled = true;
                        alert("No seats available for the selected time slot.");
                    } else {
                        submitBtn.disabled = false;
                        adultsInput.disabled = false;
                        childrenInput.disabled = false;
                        adultsInput.max = availableSeats;
                        childrenInput.max = availableSeats;
                    }
                })
                .catch(error => {
                    console.error("Error fetching available seats:", error);
                    document.getElementById("available-seats").innerText = "Error";
                });
        }
    }

    document.getElementById("time_slot").addEventListener("change", checkAvailability);
</script>
</body>
</html>
