<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Online Boat Reservation System</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <style>
        body {
            background-color: #FAF7F2;
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
        }
        .navbar {
            background-color: #003366 !important;
        }
        .login-container {
            width: 100%;
            max-width: 400px;
            margin: 100px auto;
            padding: 30px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            text-align: center;
        }
        .form-group {
            margin-bottom: 15px;
            text-align: left;
        }
        input[type="text"], input[type="password"] {
            width: 100%;
            padding: 10px;
            margin-top: 5px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 16px;
        }
        input[type="submit"] {
            width: 100%;
            padding: 10px;
            background-color: #003366;
            color: white;
            border: none;
            border-radius: 4px;
            font-size: 18px;
            cursor: pointer;
        }
        input[type="submit"]:hover {
            background-color: #0055a5;
        }
        .error {
            color: red;
            margin-top: 10px;
        }
        .register-link {
            margin-top: 15px;
            font-size: 14px;
        }
        .register-link a {
            color: #0055a5;
            text-decoration: none;
        }
        .register-link a:hover {
            text-decoration: underline;
        }
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

    <div class="login-container">
        <h2>Login</h2>
        <form method="POST">
            <div class="form-group">
                <label for="email">Email</label>
                <input type="text" id="email" name="email" required>
            </div>
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required>
            </div>
            <div class="form-group">
                <input type="submit" name="login" value="Login">
            </div>

            <div class="register-link">
                Don't have an account? <a href="register.jsp">Register</a>
            </div>
        </form>

        <%
            if (request.getParameter("login") != null) {
                String email = request.getParameter("email");
                String password = request.getParameter("password");

                Connection conn = null;
                PreparedStatement stmt = null;
                ResultSet rs = null;

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/boat_reservation", "root", "root");

                    String query = "SELECT * FROM user WHERE email = ? AND password = ?";
                    stmt = conn.prepareStatement(query);
                    stmt.setString(1, email);
                    stmt.setString(2, password);
                    rs = stmt.executeQuery();

                    if (rs.next()) {
                        int userId = rs.getInt("id");
                        String userType = rs.getString("user_type");

                        session.setAttribute("user_id", userId);
                        session.setAttribute("user_email", email);
                        session.setAttribute("user_type", userType);

                        if ("admin".equals(userType)) {
                            response.sendRedirect("admin_dashboard.jsp");
                        } else {
                            response.sendRedirect("user_dashboard.jsp");
                        }
                    } else {
        %>
                        <p class="error">Invalid email or password.</p>
        <%
                    }
                } catch (Exception e) {
        %>
                    <p class="error">Database error: <%= e.getMessage() %></p>
        <%
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                    if (stmt != null) try { stmt.close(); } catch (SQLException ignored) {}
                    if (conn != null) try { conn.close(); } catch (SQLException ignored) {}
                }
            }
        %>
    </div>
</body>
</html>
