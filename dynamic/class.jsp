<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Class Home Page</title>

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
            if ((action != null) && action.equals("insert")) {
                PreparedStatement ccheck = connection.prepareStatement("SELECT COUNT(*) FROM class WHERE course_title = (?) AND section_id = (?) AND qtr_year = (?)");
                ccheck.setString(1, request.getParameter("course_title"));
                ccheck.setString(2, request.getParameter("section_id"));
                ccheck.setString(3, request.getParameter("start_date"));
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
                        PreparedStatement cstmt = connection.prepareStatement("INSERT INTO class VALUES (?, ?, ?, ?, ?)");
                        cstmt.setString(1, request.getParameter("course_title"));
                        cstmt.setString(2, request.getParameter("section_id"));
                        cstmt.setString(3, request.getParameter("start_date"));
                        cstmt.setInt(4, Integer.parseInt(request.getParameter("class_size")));
                        cstmt.setInt(5, Integer.parseInt(request.getParameter("waitlist_size")));
                        cstmt.executeUpdate();

                        // create the connection between course and class
                        cstmt = connection.prepareStatement("SELECT COUNT(*) FROM class_course WHERE course_num = (?) AND course_title = (?) AND section_id = (?) AND qtr_year = (?)");
                        cstmt.setString(1, request.getParameter("course_num"));
                        cstmt.setString(2, request.getParameter("course_title"));
                        cstmt.setString(3, request.getParameter("section_id"));
                        cstmt.setString(4, request.getParameter("start_date"));

                        crs = cstmt.executeQuery();
                        crs.next();

                        if (crs.getInt(1) == 0) {
                            // connection doesn't exist, let's create it
                            cstmt = connection.prepareStatement("INSERT INTO class_course VALUES (?, ?, ?, ?)");
                            cstmt.setString(1, request.getParameter("course_num"));
                            cstmt.setString(2, request.getParameter("course_title"));
                            cstmt.setString(3, request.getParameter("section_id"));
                            cstmt.setString(4, request.getParameter("start_date"));
                            cstmt.executeUpdate();
                        }
                        
                        // Commit transaction
                        connection.commit();
                        connection.setAutoCommit(true);
                }
            }
        %>

        <div id="main">
            <table border="1" id="table_detail" cellpadding="10">
                <tr>
                    <th>Course Title</th>
                    <th>Section ID</th>
                    <th>Start Date</th>
                    <th>Class Size</th>
                    <th>Waitlist Size</th>
                </tr>

                <%
                    Statement stmt = connection.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT * FROM Class");

                    int class_num = 0;
                    while (rs.next()) { 
                        PreparedStatement mcount_stmt = connection.prepareStatement("SELECT COUNT(*) FROM meeting WHERE course_title = (?) AND section_id = (?) AND qtr_year = (?)");
                        mcount_stmt.setString(1, rs.getString(1));
                        mcount_stmt.setString(2, rs.getString(2));
                        mcount_stmt.setString(3, rs.getString(3));

                        ResultSet mcount_rs = mcount_stmt.executeQuery();
                        mcount_rs.next(); %>
                        <%= "<tr onclick='showHiddenRow(`class_" + class_num + "`)'>" %>
                            <td><%= rs.getString(1) %></td>
                            <td><%= rs.getString(2) %></td>
                            <td><%= rs.getString(3) %></td>
                            <td><%= rs.getInt(4) %></td>
                            <td><%= rs.getInt(5) %></td>
                        </tr>

                        <%= "<tr class='hidden_row' id='class_" + class_num + "'>" %>
                            <td colspan="5">
                                <h6>Meetings [<%= mcount_rs.getInt(1) %>]</h6><br />

                                <table border="1">
                                    <tr>
                                        <th>Type</th>
                                        <th>Start Meeting Time</th>
                                        <th>End Meeting Time</th>
                                        <th>Location</th>
                                        <th>Mandatory</th>
                                    </tr>
                                    <%
                                        PreparedStatement mstmt = connection.prepareStatement("SELECT * FROM meeting WHERE course_title = (?) AND section_id = (?) AND qtr_year = (?)");
                                        mstmt.setString(1, rs.getString(1));
                                        mstmt.setString(2, rs.getString(2));
                                        mstmt.setString(3, rs.getString(3));

                                        ResultSet mrs = mstmt.executeQuery();
                                        while (mrs.next()) { %>
                                            <tr>
                                                <td><%= mrs.getString(8) %></td>
                                                <td><%= mrs.getString(4) %></td>
                                                <td><%= mrs.getString(5) %></td>
                                                <td><%= mrs.getString(6) %></td>
                                                <td><%= mrs.getBoolean(7) ? "yes" : "no" %></td>
                                            </tr>
                                    <%  }
                                    %>
                                </table>
                            </td>
                        </tr>
                <%  class_num++;
                    }
                %>
            </table>
        </div>

        <div>
            <h3>Insert new Class</h3>
            <%= exists ? "<div id='error'><h3 style='color: red;'>A class already exists with that title, section id, and start date!</h3></div>" : "" %>

            <form action="class.jsp" method="GET">
                <input type="hidden" name="action" value="insert">
                
                Title: <input type="input" name="course_title" required><br /><br />
                Section ID: <input type="input" name="section_id" maxlength="4" required><br /><br />
                Start Date: <input type="input" name="start_date" required><br /><br />
                Class Size: <input type="number" name="class_size" min="0" max="500"><br /><br />
                Waitlist Size: <input type="number" name="waitlist_size" min="0" max="500"><br /><br />

                <label for="course_num">Course:</label>
                <select name="course_num">
                    <%
                    rs = stmt.executeQuery("SELECT * FROM course");
                    while (rs.next()) { %>
                        <%= "<option value='" + rs.getString(1) + "'>" + rs.getString(1) + "</option>" %>
                <%    
                    }  %>
                </select>

                <input type="submit" name="submit" value="Create">
            </form>
    </body>
</html>