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
                
                PreparedStatement ucheck = connection.prepareStatement("SELECT COUNT(*) FROM undergraduate where student_id = (?)");
                ucheck.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                ResultSet urs = ucheck.executeQuery();
                urs.next();

                //PreparedStatement majorcheck = connection.prepareStatement("SELECT Count(*) FROM major where student_id = (?)");
                //majorcheck.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                //ResultSet majorrs = majorcheck.executeQuery();
                //majorrs.next()

                //PreparedStatement minorcheck = connection.prepareStatement("SELECT Count(*) FROM minor where student_id = (?)");
                //minorcheck.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                //ResultSet minorrs = minorcheck.executeQuery();
                //minorrs.next()
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
                        PreparedStatement pstmt = connection.prepareStatement("INSERT INTO undergraduate VALUES (?, ?, ?)");
                        pstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                        pstmt.setString(3, request.getParameter("college"));
                        pstmt.setBoolean(2, request.getParameter("fiveyear") != null);
                        pstmt.executeUpdate();

                        // Major loop for multiple majors
                        String major_input = request.getParameter("major");
                        if ((major_input != null) && (major_input.length() > 0)) {
                            String[] majors = major_input.split(",");
                            for (String major: majors) {
                                pstmt = connection.prepareStatement("INSERT INTO undergrad_major VALUES (?,?)");
                                pstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                                pstmt.setString(2, major);
                                pstmt.executeUpdate();
                            }
                        }
                        // minor loop for multiple minors
                        String minor_input = request.getParameter("minor");
                        if ((minor_input != null) && (minor_input.length() > 0)) {
                            String[] minors = minor_input.split(",");
                            for (String minor: minors) {
                                pstmt = connection.prepareStatement("INSERT INTO undergrad_minor VALUES (?,?)");
                                pstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                                pstmt.setString(2, minor);
                                pstmt.executeUpdate();
                            }
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
                    <th>Student ID</th>
                    <th>College</th>
                    <th>5 year BS/MS</th>
                </tr>

                <%
                    Statement stmt = connection.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT * FROM undergraduate");

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
                            <td><%= rs.getString(3) %></td>
                            <td><%= rs.getBoolean(2) ? "yes" : "no" %></td>
                        </tr>


                <%  student_num++;
                    }
                %>
            </table>
        </div>

        <div>
            <h3>Create new Undergraduate</h3>
            <%= exists ? "<div id='error'><h3 style='color: red;'>A student already exists with that student ID!</h3></div>" : "" %>
            <%= notstudent ? "<div id='error'><h3 style='color: red;'>No student with that student ID!</h3></div>" : "" %>

            <form action="undergraduate.jsp" method="GET">
                <input type="hidden" name="action" value="insert">
                
                Student ID: <input type="input" name="student_id" required><br /><br />
                college: <input type="input" name="college" required><br /><br />
                5 year bs/ms program? <input type="checkbox" name="fiveyear"><br/><br/>
                Major: <input type="input" name="major" required>
                <label for="major" style="font-size: 10px;"><i>separated by commas</i></label><br/><br/>
                Minor: <input type="input" name="minor" required>
                <label for="major" style="font-size: 10px;"><i>separated by commas</i></label><br/><br/>

                <input type="submit" name="submit" value="Create">
            </form>

            </form>
    </body>
</html>