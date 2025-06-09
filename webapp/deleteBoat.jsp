<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.io.*" %>
<%
    String boatId = request.getParameter("id");
    String confirm = request.getParameter("confirm");

    if (boatId == null || boatId.isEmpty()) {
        response.sendRedirect("manage_boats.jsp?error=true");
        return;
    }

    if (confirm == null) {
%>
<!DOCTYPE html>
<html>
<head>
    <title>Delete Confirmation</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <!-- Bootstrap Modal -->
    <div class="modal show d-block" tabindex="-1" style="background-color: rgba(0,0,0,0.5);">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-danger text-white">
                    <h5 class="modal-title">Confirm Deletion</h5>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete this boat?</p>
                </div>
                <div class="modal-footer">
                    <a href="deleteBoat.jsp?id=<%= boatId %>&confirm=true" class="btn btn-danger">Yes, Delete</a>
                    <a href="manage_boats.jsp" class="btn btn-secondary">Cancel</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
<%
        return;
    }

    try {
        String jdbcURL = "jdbc:mysql://localhost:3306/boat_reservation";
        String dbUser = "root";
        String dbPassword = "root";

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(jdbcURL, dbUser, dbPassword);
        String deleteQuery = "DELETE FROM boats WHERE boat_id = ?";
        PreparedStatement stmt = conn.prepareStatement(deleteQuery);
        stmt.setInt(1, Integer.parseInt(boatId));

        int rowsAffected = stmt.executeUpdate();
        stmt.close();
        conn.close();

        if (rowsAffected > 0) {
%>
            <div style="max-width: 500px; margin: 20px auto; padding: 15px; background-color: #d4edda; border: 1px solid #c3e6cb; color: #155724; border-radius: 5px; text-align: center;">
                Boat deleted successfully!
            </div>
            <script>
                setTimeout(function() {
                    window.location.href = "manage_boats.jsp";
                }, 1000);
            </script>
<%
        } else {
            response.sendRedirect("manage_boats.jsp?error=true");
        }
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error deleting boat: " + e.getMessage() + "</p>");
    }
%>
