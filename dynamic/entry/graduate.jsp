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
            boolean notstudent = false;
            if ((action != null) && action.equals("insert")) {
                PreparedStatement ccheck = connection.prepareStatement("SELECT COUNT(*) FROM student where student_id = (?)");
                ccheck.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                ResultSet crs = ccheck.executeQuery();
                crs.next();
                
                PreparedStatement ucheck = connection.prepareStatement("SELECT COUNT(*) FROM graduate where student_id = (?)");
                ucheck.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                ResultSet urs = ucheck.executeQuery();
                urs.next();
                if (crs.getInt(1) == 0) {
                        // no student like this!!
                        notstudent = true;
                } else if (urs.getInt(1) > 0) {
                        // conflicting key!
                        exists = true;
                } 
                else {
                        // Begin transaction
                        connection.setAutoCommit(false);

                        // Create the prepared statement and use it to
                        // INSERT the student attributes INTO the Student table.
                        PreparedStatement cstmt = connection.prepareStatement("INSERT INTO graduate VALUES (?, ?)");
                        cstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                        cstmt.setString(2, request.getParameter("department"));
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
                    <th>Department</th>
                </tr>

                <%
                    Statement stmt = connection.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT * FROM graduate");

                    int student_num = 0;
                    while (rs.next()) { 

 %>
                        <%= "<tr onclick='showHiddenRow(`student_" + student_num + "`)'>" %>
                            <td><%= rs.getInt(1) %></td>
                            <td><%= rs.getString(2) %></td>
                        </tr>


                <%  student_num++;
                    }
                %>
            </table>
        </div>

        <div>
            <h3>Create new Graduate</h3>
            <%= exists ? "<div id='error'><h3 style='color: red;'>A student already exists with that student ID!</h3></div>" : "" %>
            <%= notstudent ? "<div id='error'><h3 style='color: red;'>No student with that student ID!</h3></div>" : "" %>

            <form action="graduate.jsp" method="GET">
                <input type="hidden" name="action" value="insert">
                
                Student ID: <input type="input" name="student_id" required><br /><br />
                department: <input type="input" name="department" required><br /><br />

                <input type="submit" name="submit" value="Create">
            </form>

            </form>
    </body>
</html>