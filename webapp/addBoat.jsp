<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>


<%
    String url = "jdbc:mysql://localhost:3306/boat_reservation";
    String user = "root";
    String password = "root";

    Connection conn = null;
    PreparedStatement pstmt = null;
    String message = "";
    String alertClass = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, user, password);

        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String boatName = request.getParameter("boat_name");
            String capacity = request.getParameter("capacity");
            String operatorName = request.getParameter("operator_name");
            String priceAdult = request.getParameter("price_adult");
            String priceChild = request.getParameter("price_child");
            String location = request.getParameter("location");
            String boatType = request.getParameter("boat_type");
            String remarks = request.getParameter("remarks");

            // Validation checks
            if (boatName.isEmpty() || capacity.isEmpty() || operatorName.isEmpty() || priceAdult.isEmpty() ||
                priceChild.isEmpty() || location.isEmpty() || boatType.isEmpty()) {
                message = "All fields are required!";
                alertClass = "alert-danger";
            } else {
                try {
                    int intCapacity = Integer.parseInt(capacity);
                    BigDecimal bdPriceAdult = new BigDecimal(priceAdult);
                    BigDecimal bdPriceChild = new BigDecimal(priceChild);

                    if (intCapacity <= 0) {
                        message = "Capacity must be a positive integer!";
                        alertClass = "alert-danger";
                    } else if (bdPriceAdult.compareTo(BigDecimal.ZERO) <= 0) {
                        message = "Price for Adult must be a positive number!";
                        alertClass = "alert-danger";
                    } else if (bdPriceChild.compareTo(BigDecimal.ZERO) < 0) {
                        message = "Price for Child cannot be negative!";
                        alertClass = "alert-danger";
                    } else {
                        // Insert into database
                        String insertSql = "INSERT INTO boats (boat_name, capacity, operator_name, price_adult, price_child, location, boat_type, remarks) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                        pstmt = conn.prepareStatement(insertSql);
                        pstmt.setString(1, boatName);
                        pstmt.setInt(2, intCapacity);
                        pstmt.setString(3, operatorName);
                        pstmt.setBigDecimal(4, bdPriceAdult);
                        pstmt.setBigDecimal(5, bdPriceChild);
                        pstmt.setString(6, location);
                        pstmt.setString(7, boatType);
                        pstmt.setString(8, remarks);

                        int insertedRows = pstmt.executeUpdate();
                        if (insertedRows > 0) {
                            message = "Boat added successfully!";
                            alertClass = "alert-success";
                        } else {
                            message = "Failed to add boat!";
                            alertClass = "alert-danger";
                        }
                    }
                } catch (NumberFormatException e) {
                    message = "Invalid number format!";
                    alertClass = "alert-danger";
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        message = "An error occurred!";
        alertClass = "alert-danger";
    } finally {
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Boat</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        function validateForm() {
            var capacity = document.forms["boatForm"]["capacity"].value;
            var priceAdult = document.forms["boatForm"]["price_adult"].value;
            var priceChild = document.forms["boatForm"]["price_child"].value;

            // Validate capacity (must be a positive integer)
            if (capacity <= 0 || !Number.isInteger(Number(capacity))) {
                alert("Capacity must be a positive integer.");
                return false;
            }

            // Validate price for adult (must be a positive number)
            if (priceAdult <= 0 || isNaN(priceAdult)) {
                alert("Price for Adult must be a positive number.");
                return false;
            }

            // Validate price for child (must be a non-negative number)
            if (priceChild < 0 || isNaN(priceChild)) {
                alert("Price for Child must be a non-negative number.");
                return false;
            }

            return true;
        }
    </script>

    <style>
        body { background-color: #FAF7F2; font-family: Arial, sans-serif; }
        .navbar { background-color: #003366 !important; padding: 10px; }
        .container { background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); max-width: 500px; margin-top: 100px; }
        .btn-primary { width: 100%; background-color: #003366; border: none; }
        .btn-primary:hover { background-color: #1e2b47; }
        h2 { text-align: center; color: #003366; }
        .alert { margin-bottom: 20px; }
    </style>
</head>
<body>
    <nav class="navbar navbar-dark bg-dark">
        <div class="container-fluid">
            <a class="navbar-brand" href="#">Admin Dashboard</a>
            <a href="manage_boats.jsp" class="btn btn-outline-light">Back</a>
        </div>
    </nav>

    <div class="container mt-5">
        <h2>Add New Boat</h2>
        <% if (!message.isEmpty()) { %>
            <div class="alert <%= alertClass %>"><%= message %></div>
        <% } %>
        <form name="boatForm" method="post" action="addBoat.jsp" onsubmit="return validateForm()">
            <div class="mb-3">
                <label class="form-label">Boat Name:</label>
                <input type="text" class="form-control" name="boat_name" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Capacity:</label>
                <input type="number" class="form-control" name="capacity" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Operator Name:</label>
                <input type="text" class="form-control" name="operator_name" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Price for Adult:</label>
                <input type="number" step="0.01" class="form-control" name="price_adult" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Price for Child:</label>
                <input type="number" step="0.01" class="form-control" name="price_child" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Location:</label>
                <input type="text" class="form-control" name="location" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Boat Type:</label>
                <select class="form-control" name="boat_type" required>
                    <option value="">Select Boat Type</option>
                    <option value="House Boat">Houseboat</option>
                    <option value="Luxury Yacht">Luxury Yacht</option>
                    <option value="Speed Boat">Speed Boat</option>
                </select>
            </div>
            <div class="mb-3">
                <label class="form-label">Remarks:</label>
                <textarea class="form-control" name="remarks" rows="3"></textarea>
            </div>
            <button type="submit" class="btn btn-primary">Add Boat</button>
        </form>
    </div>
</body>
</html>
