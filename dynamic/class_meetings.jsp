<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Class Meeting Home Page</title>
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
            boolean created = false;
            
            if ((action != null) && action.equals("insert")) {
                String[] class_section_data = request.getParameter("class_section").split(",");
                String class_str = class_str = class_section_data[0];
                String section = section = class_section_data[1];
                String qtr_year = qtr_year = class_section_data[2];

                PreparedStatement mcheck = connection.prepareStatement("SELECT COUNT(*) FROM meeting WHERE course_title = (?) AND section_id = (?) AND qtr_year = (?) AND start_meeting_time = (?)");
                mcheck.setString(1, class_str);
                mcheck.setString(2, section);
                mcheck.setString(3, qtr_year);
                mcheck.setString(4, request.getParameter("start_time"));

                ResultSet mrs = mcheck.executeQuery();
                mrs.next();

                if (mrs.getInt(1) > 0) {
                    // conflicting key!
                    exists = true;
                } else {
                    // Begin transaction
                    connection.setAutoCommit(false);

                    // Create the prepared statement and use it to
                    // INSERT the student attributes INTO the Student table.
                    PreparedStatement mstmt = connection.prepareStatement("INSERT INTO meeting VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                    mstmt.setString(1, class_str);
                    mstmt.setString(2, section);
                    mstmt.setString(3, qtr_year);
                    mstmt.setString(4, request.getParameter("start_time"));
                    mstmt.setString(5, request.getParameter("end_time"));
                    mstmt.setString(6, request.getParameter("location"));
                    mstmt.setBoolean(7, request.getParameter("mandatory") != null);
                    mstmt.setString(8, request.getParameter("meeting_type"));
                    mstmt.executeUpdate();

                    // Commit transaction
                    connection.commit();
                    connection.setAutoCommit(true);

                    // mark as done
                    created = true;
                }
            }
        %>
        <div>
            <h3>Create a new Meeting</h3>
            <%= exists ? "<div id='error'><h3 style='color: red;'>Meeting already exists!</h3></div>" : "" %>
            <%= created ? "<div id='done'><h3 style='color: green;'>Created new meeting for class!</h3></div>" : "" %>

            <form action="class_meetings.jsp" method="GET">
                <input type="hidden" name="action" value="insert">

                <label for="class_section">Class</label>
                <select name="class_section">
                    <%
                    Statement stmt = connection.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT * FROM Class");
                    while (rs.next()) { %>
                        <%= "<option value='" + rs.getString(1) + "," + rs.getString(2) + "," + rs.getString(3) + "'>" + rs.getString(1) + " [" + rs.getString(2) + ", " + rs.getString(3) + "]</option>" %>
                <%    
                    }  %>
                </select>

                <br /><br />Meeting Type: <select name="meeting_type">
                    <option value="LE">Lecture</option>
                    <option value="DI">Discussion</option>
                    <option value="LAB">Lab</option>
                    <option value="REV">Review</option>
                    <option value="FINAL">Final</option>
                </select>

                <br /><br />Start Meeting Time: <input type="input" name="start_time"><br /><br />
                End Meeting Time: <input type="input" name="end_time"><br /><br />
                Location: <input type="input" name="location"><br/><br/>
                Mandatory? <input type="checkbox" name="mandatory"><br/><br/>

                <input type="submit" name="submit" value="Create">
            </form>
        </div>
    </body>
</html>