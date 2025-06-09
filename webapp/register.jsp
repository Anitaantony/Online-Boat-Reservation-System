<%@ page import="java.sql.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    String jdbcURL = "jdbc:mysql://localhost:3306/boat_reservation";
    String dbUser = "root";
    String dbPassword = "root";
    String message = "";
    boolean registrationSuccess = false;

    if (request.getMethod().equalsIgnoreCase("POST")) {
        String firstName = request.getParameter("first_name");
        String middleName = request.getParameter("middle_name");
        String lastName = request.getParameter("last_name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirm_password");
        String userType = "user";

        if (!password.equals(confirmPassword)) {
            message = "Passwords do not match!";
        } else {
            try (Connection conn = DriverManager.getConnection(jdbcURL, dbUser, dbPassword)) {
                Class.forName("com.mysql.cj.jdbc.Driver");
                String sql = "INSERT INTO user (first_name, middle_name, last_name, email, phone, password, user_type) VALUES (?, ?, ?, ?, ?, ?, ?)";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, firstName);
                    stmt.setString(2, middleName);
                    stmt.setString(3, lastName);
                    stmt.setString(4, email);
                    stmt.setString(5, phone);
                    stmt.setString(6, password);
                    stmt.setString(7, userType);
                    if (stmt.executeUpdate() > 0) {
                        message = "Registration successful! <a href='login.jsp'>Login here</a>";
                        registrationSuccess = true;
                    } else {
                        message = "Registration failed. Please try again.";
                    }
                }
            } catch (Exception e) {
                message = "Error: " + e.getMessage();
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Online Boat Reservation System</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        body { 
             background-color: #FAF7F2;
             font-family: Arial, sans-serif; 
        }
        .navbar { 
             background-color: #003366 !important;
        }
        .register-container {
             width: 100%;
    		 max-width: 800px; /* Increased width */
   			 margin: 50px auto;
   			 padding: 30px;
   			 background-color: white;
   			 border-radius: 8px;
   			 box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
        }
        .form-group { 
             margin-bottom: 15px;
             text-align: left; 
        }
        input { 
            width: 100%; 
            padding: 10px; 
            border: 1px solid #ccc; 
            border-radius: 4px; 
            font-size: 16px; 
         }
        input[type="submit"] {
            background-color: #003366;
            color: white;
            border: none;
            cursor: pointer;
        }
        input[type="submit"]:hover { 
            background-color: #0055a5; 
        }
        .message { color: <%= registrationSuccess ? "green" : "red" %>; }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark">
        <div class="container">
            <a class="navbar-brand" href="#">
                <img src="img/boatlogo.png" alt="Logo" height="40"> My Boat Tours
            </a>
        </div>
    </nav>
    <div class="register-container">
        <h2><center>Create an Account</center></h2>
        <% if (!message.isEmpty()) { %>
            <p class="message"><%= message %></p>
        <% } %>
        <form action="register.jsp" method="POST">
            <div class="form-group">
                <label for="first-name">First Name</label>
                <input type="text" id="first-name" name="first_name" required>
            </div>
            <div class="form-group">
                <label for="middle-name">Middle Name</label>
                <input type="text" id="middle-name" name="middle_name">
            </div>
            <div class="form-group">
                <label for="last-name">Last Name</label>
                <input type="text" id="last-name" name="last_name" required>
            </div>
            <div class="form-group">
                <label for="email">Email</label>
                <input type="email" id="email" name="email" required>
            </div>
            <div class="form-group">
                <label for="phone">Phone Number</label>
                <input type="tel" id="phone" name="phone" required>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required>
            </div>
            <div class="form-group">
                <label for="confirm-password">Confirm Password</label>
                <input type="password" id="confirm-password" name="confirm_password" required>
            </div>
            <div class="form-group">
                <input type="submit" value="Register">
            </div>
        </form>
        <div class="login-link">
        	Already have an account? <a href="login.jsp">Login here</a>
        </div>
    </div>
</body>
</html>
