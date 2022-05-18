<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Department Home Page</title>
    </head>
    <body>
        <%-- set the scripting language to Java --%>
        <%@ page language="java" import="java.sql.*" %>
        <%
            DriverManager.registerDriver(new org.postgresql.Driver());

            // Make a connection to the database
            Connection connection = DriverManager.getConnection("jdbc:postgresql:cse132b?user=postgres&password=admin");
        
            String action = request.getParameter("action");
            boolean exists = false;
            if ((action != null) && action.equals("insert")) {
                PreparedStatement pcheck = connection.prepareStatement("SELECT COUNT(*) FROM Department WHERE dept_name = (?)");
                pcheck.setString(1, request.getParameter("dept_name"));
                ResultSet rs = pcheck.executeQuery();
                rs.next();

                if (rs.getInt(1) > 0) {
                        // conflicting key!
                        exists = true;
                } else {
                        // Begin transaction
                        connection.setAutoCommit(false);

                        // Create the prepared statement and use it to
                        // INSERT the student attributes INTO the Student table.
                        PreparedStatement pstmt = connection.prepareStatement("INSERT INTO Department VALUES (?)");
                        pstmt.setString(1, request.getParameter("dept_name"));
                        pstmt.executeUpdate();

                        // Commit transaction
                        connection.commit();
                        connection.setAutoCommit(true);
                }
            }
        %>
        <table border="1" cellpadding="10">
            <tr>
                <th>Name</th>
            </tr>
            <%
                Statement stmt = connection.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM Department");

                while (rs.next()) { %>
                    <tr>
                        <td><%= rs.getString(1) %></td>
                    </tr>
            <%  }
            %>
        </table>
        
        <div>
            <h3>Insert new Department</h3>
            <%= exists ? "<div id='error'><h3 style='color: red;'>Department already exists!</h3></div>" : "" %>

            <form action="department.jsp" method="GET">
                <input type="hidden" name="action" value="insert">

                Name: <input type="input" name="dept_name"><br /><br />
                <input type="submit" name="submit" value="Create">
            </form>
        </div>
    </body>
</html>