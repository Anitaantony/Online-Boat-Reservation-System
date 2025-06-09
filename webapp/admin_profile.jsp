<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>

<%
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
                String updateSql = "UPDATE user SET first_name=?, middle_name=?, last_name=?, email=?, phone=?, password=? WHERE id=1 AND user_type='admin'";

                pstmt = conn.prepareStatement(updateSql);
                pstmt.setString(1, newFirstName);
                pstmt.setString(2, newMiddleName);
                pstmt.setString(3, newLastName);
                pstmt.setString(4, newEmail);
                pstmt.setString(5, newPhone);
                pstmt.setString(6, newPassword); // Always update password

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

        String sql = "SELECT * FROM user WHERE id = 1 AND user_type = 'admin'";
        pstmt = conn.prepareStatement(sql);
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
    <title>Admin Profile</title>
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
        .profile-info {
            margin-bottom: 15px;
        }
        .profile-info label {
            font-weight: bold;
            color: #003366;
            display: block;
            margin-bottom: 4px;
        }
        .profile-info span {
            display: block;
            font-size: 16px;
            color: #333;
            background-color: #f8f8f8;
            padding: 8px 12px;
            border-radius: 5px;
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
        .readonly-field {
            background-color: #e9ecef;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-dark bg-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="#">Admin Dashboard</a>
        <a href="manage_boats.jsp" class="btn btn-outline-light">Back</a>
    </div>
</nav>

<div class="container">
    <div class="top-buttons">
        <h2>Admin Profile</h2>
        <% if (!isEditing) { %>
            <form method="get" action="admin_profile.jsp">
                <input type="hidden" name="edit" value="true">
                <button type="submit" class="edit-btn">Edit</button>
            </form>
        <% } %>
    </div>

    <% if (!message.isEmpty()) { %>
        <div class="alert <%= alertClass %>"><%= message %></div>
    <% } %>

    <form method="post" action="admin_profile.jsp">
        <div class="mb-3">
            <label class="form-label">First Name:</label>
            <input type="text" class="form-control" name="first_name" value="<%= firstName %>" <%= isEditing ? "" : "readonly class='readonly-field'" %>>
        </div>
        <div class="mb-3">
            <label class="form-label">Middle Name:</label>
            <input type="text" class="form-control" name="middle_name" value="<%= middleName %>" <%= isEditing ? "" : "readonly class='readonly-field'" %>>
        </div>
        <div class="mb-3">
            <label class="form-label">Last Name:</label>
            <input type="text" class="form-control" name="last_name" value="<%= lastName %>" <%= isEditing ? "" : "readonly class='readonly-field'" %>>
        </div>
        <div class="mb-3">
            <label class="form-label">Email:</label>
            <input type="email" class="form-control" name="email" value="<%= email %>" <%= isEditing ? "" : "readonly class='readonly-field'" %>>
        </div>
        <div class="mb-3">
            <label class="form-label">Phone:</label>
            <input type="text" class="form-control" name="phone" value="<%= phone %>" <%= isEditing ? "" : "readonly class='readonly-field'" %>>
        </div>

        <% if (isEditing) { %>
            <div class="mb-3">
                <label class="form-label">New Password:</label>
                <input type="password" class="form-control" name="new_password">
            </div>
            <div class="mb-3">
                <label class="form-label">Confirm Password:</label>
                <input type="password" class="form-control" name="confirm_password">
            </div>
            <button type="submit" class="btn btn-primary">Update Profile</button>
        <% } %>
    </form>
</div>

<% if ("alert-success".equals(alertClass)) { %>
<script>
    setTimeout(function() {
        window.location.href = "manage_boats.jsp";
    }, 2000);
</script>
<% } %>

</body>
</html>
