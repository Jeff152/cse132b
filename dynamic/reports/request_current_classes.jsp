<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Current Classes from Student X</title>
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
            String error_msg = "";

            boolean created = false;
            String success_msg = "";
        %>
        <div>
            <h3>Select Student to view Current Classes (Spring 2018)</h3>

            <form action="request_current_classes.jsp" method="GET">
                <input type="hidden" name="action" value="query">

                <label for="student_id">Student ID</label>
                <select name="student_id">
                    <%
                    Statement stmt = connection.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT student_id, first_name, middle_name, last_name from student");
                    while (rs.next()) { %>
                        <%= "<option value='" + rs.getInt(1) + "'>" + rs.getInt(1) + ", " + rs.getString(2) + " " + rs.getString(3) + " " + rs.getString(4)  +"</option>" %>
                    <%    
                    }  %>
                </select>
                <br/>

                <input type="submit" name="submit" value="query">
            </form>
        </div>
        <%
            if ((action != null) && action.equals("query")) {


                PreparedStatement pcheck = connection.prepareStatement("SELECT COUNT(*) FROM current_classes where student_id = ?");
                pcheck.setInt(1, Integer.parseInt(request.getParameter("student_id")));

                rs = pcheck.executeQuery();
                rs.next();

                if (rs.getInt(1) == 0) {
                        // No classes found for this student
                        exists = true;
                        error_msg = "Student is not enrolled in any classes for the current quarter!";
        %>
        <div>
        <%= exists ? "<div id='error'><h3 style='color: red;'>" + error_msg + "</h3></div>" : "" %>
        <%= created ? "<div id='done'><h3 style='color: green;'>" + success_msg + "</h3></div>" : "" %>
        </div>
        <%
                } else {
                        // Begin transaction
        %>
        

        <div id="report">
            <table border="1" id="table_detail" cellpadding="10">
                <tr>
                    <th>Course #</th>
                </tr>
        <%
                        connection.setAutoCommit(false);
                        PreparedStatement reportstmt = connection.prepareStatement("SELECT course_num, course_title, section_id, units from class_course NATURAL JOIN current_classes where student_id = ?;");
                        reportstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                        ResultSet report = reportstmt.executeQuery();
                        int course_num = 0;
                        while (report.next()) { %>
                            <%= "<tr onclick='showHiddenRow(`course_" + course_num + "`)'>" %>
                                <td><%= report.getString(1) %></td>
                            </tr>

                            <%= "<tr class='hidden_row' id='course_" + course_num + "'>" %>
                                <td colspan="4">
                                    Title: <%= report.getString(2) %> <br/>
                                    Section ID: <%= report.getString(3) %> <br/>
                                    Units: <%= report.getInt(4) %> <br/>
                                </td>
                            </tr>
                        <%
                            course_num++;
                        }
                        connection.commit();
                        connection.setAutoCommit(true);
                }
            } %>

    </body>
</html>