<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Class Meeting Home Page</title>
    </head>
    <body>
        <%-- set the scripting language to Java --%>
        <%@ page language="java" import="java.sql.*,java.time.*,java.time.format.DateTimeFormatter" %>
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


                //
                String time = request.getParameter("start_date")+ " " + request.getParameter("start_time");
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
                LocalDateTime start_meeting_time = LocalDateTime.parse(time, formatter);
                PreparedStatement mcheck = connection.prepareStatement("SELECT COUNT(*) FROM meeting WHERE course_title = (?) AND section_id = (?) AND qtr_year = (?) AND start_meeting_time = (?)");
                mcheck.setString(1, class_str);
                mcheck.setString(2, section);
                mcheck.setString(3, qtr_year);
                mcheck.setTimestamp(4, Timestamp.valueOf(start_meeting_time));

                //ResultSet mrs = mcheck.executeQuery();
                //mrs.next();

                if (false) {
                    // conflicting key!
                    exists = true;
                } else {
                    // Begin transaction
                    time = request.getParameter("start_date")+ " " + request.getParameter("end_time");
                    LocalDateTime end_meeting_time = LocalDateTime.parse(time, formatter);
                    connection.setAutoCommit(false);

                    int count = 10;

                    // Create the prepared statement and use it to
                    if (request.getParameter("meeting_type").equals("REV") || request.getParameter("meeting_type").equals("FINAL")) {
                        // Inserting 10 meetings for the 10 weeks
                        count = 1;
                    }

                    for (int i = 0; i < count; i++) {
                        PreparedStatement mstmt = connection.prepareStatement("INSERT INTO meeting VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                        mstmt.setString(1, class_str);
                        mstmt.setString(2, section);
                        mstmt.setString(3, qtr_year);
                        mstmt.setTimestamp(4, Timestamp.valueOf(start_meeting_time));
                        mstmt.setTimestamp(5, Timestamp.valueOf(end_meeting_time));
                        mstmt.setString(6, request.getParameter("location"));
                        mstmt.setBoolean(7, request.getParameter("mandatory") != null);
                        mstmt.setString(8, request.getParameter("meeting_type"));
                        mstmt.executeUpdate();
                        
                        start_meeting_time = start_meeting_time.plusWeeks(1);
                        end_meeting_time = end_meeting_time.plusWeeks(1);
                    }
                    

                    // Commit transaction
                    connection.commit();
                    connection.setAutoCommit(true);
                    // mark as done
                    created = true;
                    request.reset();
                }
            }
        %>
        <div>
            <h3>Create a new Meeting</h3>
            <%= exists ? "<div id='error'><h3 style='color: red;'>Meeting already exists!</h3></div>" : "" %>
            <%= created ? "<div id='done'><h3 style='color: green;'>Created new meeting(s) for class!</h3></div>" : "" %>

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


                <br /><br />
                Date: <input type="date" name="start_date"><br /><br />
                Start Meeting Time: <input type="time" name="start_time"><br /><br />
                End Meeting Time: <input type="time" name="end_time"><br /><br />
                Location: <input type="input" name="location"><br/><br/>
                Mandatory? <input type="checkbox" name="mandatory"><br/><br/>

                <input type="submit" name="submit" value="Create">
            </form>
        </div>
    </body>


</html>