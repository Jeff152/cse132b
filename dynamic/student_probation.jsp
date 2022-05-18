<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Student Probation Home Page</title>
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
            String error_msg = "";

            boolean created = false;
            String success_msg = "";
            if ((action != null) && action.equals("insert")) {
                // Begin transaction
                connection.setAutoCommit(false);

                PreparedStatement pstmt = connection.prepareStatement("INSERT INTO probation VALUES (DEFAULT, ?, ?, ?, ?, ?) RETURNING probation_id");
                pstmt.setString(1, request.getParameter("start_qtr"));
                pstmt.setInt(2, Integer.parseInt(request.getParameter("start_year")));
                pstmt.setString(3, request.getParameter("end_qtr"));
                pstmt.setInt(4, Integer.parseInt(request.getParameter("end_year")));
                pstmt.setString(5, request.getParameter("reason"));
                pstmt.execute();

                ResultSet last = pstmt.getResultSet();
                if (last.next()) {
                    int probation_id = last.getInt(1);

                    pstmt = connection.prepareStatement("INSERT INTO student_probation VALUES (?, ?)");
                    pstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                    pstmt.setInt(2, probation_id);
                    pstmt.executeUpdate();

                    created = true;
                    success_msg = "Added new probation for student with reason [" + request.getParameter("reason") + "], with id = " + probation_id + "!";
                }

                // Commit transaction
                connection.commit();
                connection.setAutoCommit(true);
            }
        %>
        
        <div>
            <h3>Add new Probation for Student</h3>
            <%= exists ? "<div id='error'><h3 style='color: red;'>" + error_msg + "</h3></div>" : "" %>
            <%= created ? "<div id='done'><h3 style='color: green;'>" + success_msg + "</h3></div>" : "" %>

            <form action="student_probation.jsp" method="GET">
                <input type="hidden" name="action" value="insert">

                <label for="student_id">Student</label>
                <select name="student_id">
                    <%
                    Statement stmt = connection.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT * FROM student");
                    while (rs.next()) { %>
                        <%= "<option value='" + rs.getInt(1) + "'>" + rs.getString(2) + rs.getString(3) + rs.getString(4) + "</option>" %>
                    <%    
                    }  %>
                </select>

                <br /><br />Start Quarter: <input type="input" name="start_qtr" required><br /><br />
                Start Year: <input type="number" name="start_year" min="0" max="2022" required><br /><br />
                End Quarter: <input type="input" name="end_qtr" required><br /><br />
                End Year: <input type="number" name="end_year" min="0" max="2022" required><br /><br />
                Reason: <input type="input" name="reason" maxlength="256" required>

                <input type="submit" name="submit" value="Create">
            </form>
        </div>
    </body>
</html>