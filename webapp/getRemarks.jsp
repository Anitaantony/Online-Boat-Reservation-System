<%@ page contentType="text/plain; charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    int boatId = Integer.parseInt(request.getParameter("boat_id"));
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/boat_reservation", "root", "root");

        String sql = "SELECT remarks FROM boats WHERE boat_id = ?";
        stmt = conn.prepareStatement(sql);
        stmt.setInt(1, boatId);
        rs = stmt.executeQuery();

        if (rs.next()) {
            String remarks = rs.getString("remarks");

            // Split remarks by period, semicolon, or newline (customize as needed)
            String[] points = remarks.split("[\\.;\\n]");

            out.println("<ul>");
            for (String point : points) {
                point = point.trim();
                if (!point.isEmpty()) {
                    out.println("<li>" + point + "</li>");
                }
            }
            out.println("</ul>");
        } else {
            out.println("<p>No remarks available.</p>");
        }
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error loading remarks.</p>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception e) {}
        try { if (stmt != null) stmt.close(); } catch (Exception e) {}
        try { if (conn != null) conn.close(); } catch (Exception e) {}
    }
%>
