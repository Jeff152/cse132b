<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Student Home Page</title>

        <script src= "https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.2/js/bootstrap.min.js"></script>
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.2/css/bootstrap.min.css">
        <link rel="stylesheet" type="text/css" href="https://use.fontawesome.com/releases/v5.6.3/css/all.css">
        
        <script type="text/javascript">
            function showHiddenRow(row) {
                $("#" + row).toggle();
            }
        </script>

        <style>
            #table_detail {
                width: 500px;
                text-align: left;
                border-collapse: collapse;
                color: #2E2E2E;
                border: #A4A4A4;
            }
        
            #table_detail tr:hover {
                background-color: #F2F2F2;
            }
        
            #table_detail .hidden_row {
                display: none;
            }
        </style>
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
            boolean nokey1 = false;
            boolean nokey2 = false;
            if ((action != null) && action.equals("insert")) {
                PreparedStatement ccheck = connection.prepareStatement("SELECT COUNT(*) FROM student where student_id = (?)");
                ccheck.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                ResultSet crs = ccheck.executeQuery();
                crs.next();

                if (crs.getInt(1) > 0) {
                        // conflicting key!
                        exists = true;
                } else {
                        // Begin transaction
                        connection.setAutoCommit(false);

                        // Create the prepared statement and use it to
                        // INSERT the student attributes INTO the Student table.
                        PreparedStatement cstmt = connection.prepareStatement("INSERT INTO student VALUES (?, ?, ?, ?, ?, ?)");
                        cstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                        cstmt.setString(2, request.getParameter("first_name"));
                        cstmt.setString(3, request.getParameter("middle_name"));
                        cstmt.setString(4, request.getParameter("last_name"));
                        cstmt.setString(5, request.getParameter("residency"));
                        cstmt.setBoolean(6, request.getParameter("enrolled") != null);
                        cstmt.executeUpdate();

                        // Commit transaction
                        connection.commit();
                        connection.setAutoCommit(true);
                }
            } else if (((action != null) && action.equals("delete"))) {
                PreparedStatement ccheck = connection.prepareStatement("SELECT COUNT(*) FROM student where student_id = (?)");
                ccheck.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                ResultSet crs = ccheck.executeQuery();
                crs.next();

                if (crs.getInt(1) == 0) {
                        // No student found!
                        nokey1 = true;
                } else {
                        // Begin transaction
                        connection.setAutoCommit(false);

                        // Create the prepared statement and use it to
                        // INSERT the student attributes INTO the Student table.
                        PreparedStatement cstmt = connection.prepareStatement("DELETE FROM student WHERE student_id = (?)");
                        cstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                        cstmt.executeUpdate();

                        // Commit transaction
                        connection.commit();
                        connection.setAutoCommit(true);
                }
            } else if (((action != null) && action.equals("update"))) {
                PreparedStatement ccheck = connection.prepareStatement("SELECT COUNT(*) FROM student where student_id = (?)");
                ccheck.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                ResultSet crs = ccheck.executeQuery();
                crs.next();

                if (crs.getInt(1) == 0) {
                        // No student found!
                        nokey2 = true;
                } else {
                        // Begin transaction
                        connection.setAutoCommit(false);

                        // Create the prepared statement and use it to
                        // INSERT the student attributes INTO the Student table.
                        PreparedStatement dstmt = connection.prepareStatement("DELETE FROM student WHERE student_id = (?)");
                        dstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                        dstmt.executeUpdate();

                        PreparedStatement cstmt = connection.prepareStatement("INSERT INTO student VALUES (?, ?, ?, ?, ?, ?)");
                        cstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                        cstmt.setString(2, request.getParameter("first_name"));
                        cstmt.setString(3, request.getParameter("middle_name"));
                        cstmt.setString(4, request.getParameter("last_name"));
                        cstmt.setString(5, request.getParameter("residency"));
                        cstmt.setBoolean(6, request.getParameter("enrolled") != null);
                        cstmt.executeUpdate();

                        // Commit transaction
                        connection.commit();
                        connection.setAutoCommit(true);
                }
            }
        %>

        <div id="main">
            <table border="1" id="table_detail" cellpadding="10">
                <tr>
                    <th>Student ID</th>
                    <th>First Name</th>
                    <th>Middle Name</th>
                    <th>last_name</th>
                    <th>residency</th>
                    <th>enrolled</th>
                </tr>

                <%
                    Statement stmt = connection.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT * FROM student");

                    int student_num = 0;
                    while (rs.next()) { 
                        PreparedStatement mcount_stmt = connection.prepareStatement("SELECT COUNT(*) FROM meeting WHERE course_title = (?) AND section_id = (?) AND qtr_year = (?)");
                        mcount_stmt.setString(1, rs.getString(1));
                        mcount_stmt.setString(2, rs.getString(2));
                        mcount_stmt.setString(3, rs.getString(3));

                        ResultSet mcount_rs = mcount_stmt.executeQuery();
                        mcount_rs.next(); %>
                        <%= "<tr onclick='showHiddenRow(`student_" + student_num + "`)'>" %>
                            <td><%= rs.getInt(1) %></td>
                            <td><%= rs.getString(2) %></td>
                            <td><%= rs.getString(3) %></td>
                            <td><%= rs.getString(4) %></td>
                            <td><%= rs.getString(5) %></td>
                            <td><%= rs.getBoolean(6) ? "yes" : "no" %></td>
                        </tr>


                <%  student_num++;
                    }
                %>
            </table>
        </div>

        <div>
            <h3>Create new Student</h3>
            <%= exists ? "<div id='error'><h3 style='color: red;'>A student already exists with that student ID!</h3></div>" : "" %>

            <form action="student.jsp" method="GET">
                <input type="hidden" name="action" value="insert">
                
                Student ID: <input type="input" name="student_id" required><br /><br />
                First Name: <input type="input" name="first_name" required><br /><br />
                Middle Name: <input type="input" name="middle_name"><br /><br />
                Last Name: <input type="input" name="last_name"><br /><br />
                Residency: <input type="input" name="residency"><br/><br/>
                Enrolled? <input type="checkbox" name="enrolled"><br/><br/>

                <input type="submit" name="submit" value="Create">
            </form>

            <h3>Delete Student</h3>
            <%= nokey1 ? "<div id='error'><h3 style='color: red;'>Student ID does not exist!</h3></div>" : "" %>

            <form action="student.jsp" method="GET">
                <input type="hidden" name="action" value="delete">
                
                Student ID: <input type="input" name="student_id" required><br /><br />


                <input type="submit" name="submit" value="Delete">
            </form>

            <h3>Update Student</h3>
            <%= nokey2 ? "<div id='error'><h3 style='color: red;'>Student ID does not exist!</h3></div>" : "" %>

            <form action="student.jsp" method="GET">
                <input type="hidden" name="action" value="update">
                
                Student ID: <input type="input" name="student_id" required><br /><br />
                First Name: <input type="input" name="first_name" required><br /><br />
                Middle Name: <input type="input" name="middle_name" required><br /><br />
                Last Name: <input type="input" name="last_name"><br /><br />
                Residency: <input type="input" name="residency"><br/><br/>
                Enrolled? <input type="checkbox" name="enrolled"><br/><br/>

                <input type="submit" name="submit" value="Update">
            </form>
    </body>
</html>