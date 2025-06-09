<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>

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

    String firstName = "", middleName = "", lastName = "", email = "", phone = "";
    String message = "", alertClass = "";
    boolean isEditing = "true".equalsIgnoreCase(request.getParameter("edit")) || "POST".equalsIgnoreCase(request.getMethod());

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, dbUser, dbPassword);

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String newFirstName = request.getParameter("first_name");
            String newMiddleName = request.getParameter("middle_name");
            String newLastName = request.getParameter("last_name");
            String newEmail = request.getParameter("email");
            String newPhone = request.getParameter("phone");
            String newPassword = request.getParameter("new_password");
            String confirmPassword = request.getParameter("confirm_password");

            if (newFirstName.isEmpty() || newLastName.isEmpty() || newEmail.isEmpty() || newPhone.isEmpty()) {
                message = "All required fields must be filled!";
                alertClass = "alert-danger";
            } else if (!newFirstName.matches("[a-zA-Z]+") || !newLastName.matches("[a-zA-Z]+")) {
                message = "Name fields must contain only letters!";
                alertClass = "alert-danger";
            } else if (!newEmail.matches("^[a-zA-Z0-9._%+-]+@gmail\\.com$")) {
                message = "Only Gmail addresses are allowed!";
                alertClass = "alert-danger";
            } else if (!newPhone.matches("\\d{10}")) {
                message = "Phone number must be exactly 10 digits!";
                alertClass = "alert-danger";
            } else if (!newPassword.isEmpty() && !newPassword.equals(confirmPassword)) {
                message = "Passwords do not match!";
                alertClass = "alert-danger";
            } else {
                String updateSql = "UPDATE user SET first_name=?, middle_name=?, last_name=?, email=?, phone=?";
                if (!newPassword.isEmpty()) {
                    updateSql += ", password=?";
                }
                updateSql += " WHERE id=? AND user_type='user'";

                pstmt = conn.prepareStatement(updateSql);
                pstmt.setString(1, newFirstName);
                pstmt.setString(2, newMiddleName);
                pstmt.setString(3, newLastName);
                pstmt.setString(4, newEmail);
                pstmt.setString(5, newPhone);
                if (!newPassword.isEmpty()) {
                    pstmt.setString(6, newPassword);
                    pstmt.setInt(7, userId);
                } else {
                    pstmt.setInt(6, userId);
                }

                int updatedRows = pstmt.executeUpdate();
                if (updatedRows > 0) {
                    message = "Profile updated successfully!";
                    alertClass = "alert-success";
                    isEditing = false;
                } else {
                    message = "Failed to update profile!";
                    alertClass = "alert-danger";
                }
            }
        }

        String sql = "SELECT * FROM user WHERE id = ? AND user_type = 'user'";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            firstName = rs.getString("first_name");
            middleName = rs.getString("middle_name");
            lastName = rs.getString("last_name");
            email = rs.getString("email");
            phone = rs.getString("phone");
        }

    } catch (Exception e) {
        e.printStackTrace();
        message = "An error occurred!";
        alertClass = "alert-danger";
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>User Profile</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <style>
        body { background-color: #FAF7F2; font-family: Arial, sans-serif; }
        .navbar { background-color: #003366 !important; padding: 10px; }
        .container {
            background-color: white;
            padding: 25px 30px;
            border-radius: 10px;
            box-shadow:  0 4px 12px rgba(0, 0, 0, 0.2);
            max-width: 600px;
            margin-top: 80px;
            position: relative;
        }
        .btn-primary { width: 100%; background-color: #003366; border: none; }
        .btn-primary:hover { background-color: #1e2b47; }
        h2 { color: #003366; margin-bottom: 20px; }
        .alert { margin-bottom: 20px; }
        .top-buttons {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .edit-btn {
            background-color: #003366;
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 5px;
        }
        .edit-btn:hover {
            background-color: #1e2b47;
        }
        label {
            font-weight: bold;
            color: #003366;
        }
        .readonly-field {
            background-color: #e9ecef;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-dark bg-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="#">User Dashboard</a>
        <a href="user_dashboard.jsp" class="btn btn-outline-light">Back</a>
    </div>
</nav>

<div class="container">
    <div class="top-buttons">
        <h2>User Profile</h2>
        <% if (!isEditing) { %>
            <form method="get" action="user_profile.jsp">
                <input type="hidden" name="edit" value="true">
                <button type="submit" class="edit-btn">Edit</button>
            </form>
        <% } %>
    </div>

    <% if (!message.isEmpty()) { %>
        <div class="alert <%= alertClass %>"><%= message %></div>
    <% } %>

    <form method="post" action="user_profile.jsp">
        <div class="mb-3">
            <label>First Name:</label>
            <input type="text" name="first_name" class="form-control <%= isEditing ? "" : "readonly-field" %>" value="<%= firstName %>" <%= isEditing ? "" : "readonly" %> required>
        </div>
        <div class="mb-3">
            <label>Middle Name:</label>
            <input type="text" name="middle_name" class="form-control <%= isEditing ? "" : "readonly-field" %>" value="<%= middleName %>" <%= isEditing ? "" : "readonly" %>>
        </div>
        <div class="mb-3">
            <label>Last Name:</label>
            <input type="text" name="last_name" class="form-control <%= isEditing ? "" : "readonly-field" %>" value="<%= lastName %>" <%= isEditing ? "" : "readonly" %> required>
        </div>
        <div class="mb-3">
            <label>Email:</label>
            <input type="email" name="email" class="form-control <%= isEditing ? "" : "readonly-field" %>" value="<%= email %>" <%= isEditing ? "" : "readonly" %> required>
        </div>
        <div class="mb-3">
            <label>Phone:</label>
            <input type="text" name="phone" class="form-control <%= isEditing ? "" : "readonly-field" %>" value="<%= phone %>" <%= isEditing ? "" : "readonly" %> required>
        </div>

        <% if (isEditing) { %>
            <div class="mb-3">
                <label>New Password:</label>
                <input type="password" name="new_password" class="form-control">
            </div>
            <div class="mb-3">
                <label>Confirm Password:</label>
                <input type="password" name="confirm_password" class="form-control">
            </div>
            <button type="submit" class="btn btn-primary">Update Profile</button>
        <% } %>
    </form>
</div>

<% if ("alert-success".equals(alertClass)) { %>
<script>
    setTimeout(function() {
        window.location.href = "user_dashboard.jsp";
    }, 2000);
</script>
<% } %>

</body>
</html>
