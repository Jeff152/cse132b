<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Faculty Department Home Page</title>
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
                PreparedStatement pcheck = connection.prepareStatement("SELECT COUNT(*) FROM faculty_department WHERE name = (?) AND dept_name = (?)");
                pcheck.setString(1, request.getParameter("faculty_name"));
                pcheck.setString(2, request.getParameter("faculty_dept"));
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
                        PreparedStatement pstmt = connection.prepareStatement("INSERT INTO faculty_department VALUES (?, ?)");
                        pstmt.setString(1, request.getParameter("faculty_name"));
                        pstmt.setString(2, request.getParameter("faculty_dept"));
                        pstmt.executeUpdate();

                        // Commit transaction
                        connection.commit();
                        connection.setAutoCommit(true);
                }
            }
        %>
        <table border="1" cellpadding="10">
            <tr>
                <th>Faculty Name</th>
                <th>Department</th>
            </tr>
            <%
                Statement stmt = connection.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM faculty_department");

                while (rs.next()) { %>
                    <tr>
                        <td><%= rs.getString(1) %></td>
                        <td><%= rs.getString(2) %></td>
                    </tr>
            <%  }
            %>
        </table>
        
        <div>
            <h3>Insert new Faculty into Department</h3>
            <%= exists ? "<div id='error'><h3 style='color: red;'>Faculty already exists in department exists!</h3></div>" : "" %>

            <form action="faculty_dept.jsp" method="GET">
                <input type="hidden" name="action" value="insert">

                <label for="faculty_name">Faculty</label>
                <select name="faculty_name">
                    <%
                    rs = stmt.executeQuery("SELECT * FROM Faculty");
                    while (rs.next()) { %>
                        <%= "<option value='" + rs.getString(1) + "'>" + rs.getString(1) + "</option>" %>
                <%    
                    }  %>
                </select>

                <br /><br /><label for="faculty_dept">Department</label>
                <select name="faculty_dept">
                    <%
                    rs = stmt.executeQuery("SELECT * FROM Department");
                    while (rs.next()) { %>
                        <%= "<option value='" + rs.getString(1) + "'>" + rs.getString(1) + "</option>" %>
                <%    
                    }  %>
                </select>

                <input type="submit" name="submit" value="Create">
            </form>
        </div>
    </body>
</html>