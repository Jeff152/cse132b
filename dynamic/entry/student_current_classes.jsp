<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Adding a new Student Class Home Page</title>
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
                String[] class_section_data = request.getParameter("class_section").split(",");
                String course_title = class_section_data[0];
                String section = class_section_data[1];
                String qtr_year = class_section_data[2];

                PreparedStatement pcheck = connection.prepareStatement("SELECT COUNT(*) FROM current_classes WHERE student_id = (?) AND course_title = (?) AND section_id = (?) AND qtr_year = (?)");
                pcheck.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                pcheck.setString(2, course_title);
                pcheck.setString(3, section);
                pcheck.setString(4, qtr_year);

                ResultSet rs = pcheck.executeQuery();
                rs.next();

                if (rs.getInt(1) > 0) {
                        // conflicting key!
                        exists = true;
                        error_msg = "Student is already enrolled in this class!";
                } else {
                        // Begin transaction
                        connection.setAutoCommit(false);

                        // find connection
                        /* pcheck = connection.prepareStatement("SELECT COUNT(*) FROM class_course WHERE course_title = (?) AND section_id = (?) AND qtr_year = (?)");
                        pcheck.setString(1, course_title);
                        pcheck.setString(2, section);
                        pcheck.setString(3, qtr_year);

                        rs = pcheck.executeQuery();
                        rs.next();

                        if (rs.getInt(1) == 0){ 
                            exists = true;
                            error_msg = "Could not find connection for course: " + course_title;
                        } else { */
                            // Create the prepared statement and use it to
                            // INSERT the student attributes INTO the Student table.
                            PreparedStatement pstmt = connection.prepareStatement("INSERT INTO current_classes VALUES (?, ?, ?, ?, ?)");
                            pstmt.setInt(1, Integer.parseInt(request.getParameter("student_id")));
                            pstmt.setString(2, course_title);
                            pstmt.setString(3, section);
                            pstmt.setString(4, qtr_year);
                            pstmt.setInt(5, Integer.parseInt(request.getParameter("units")));
                            pstmt.executeUpdate();
                            created = true;
                            success_msg = "Enrolled the student in " + course_title + "!";
                        // }

                        // Commit transaction
                        connection.commit();
                        connection.setAutoCommit(true);
                }
            }
        %>
        
        <div>
            <h3>Insert new Class for Student</h3>
            <%= exists ? "<div id='error'><h3 style='color: red;'>" + error_msg + "</h3></div>" : "" %>
            <%= created ? "<div id='done'><h3 style='color: green;'>" + success_msg + "</h3></div>" : "" %>

            <form action="student_current_classes.jsp" method="GET">
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

                <br /><br /><label for="class_section">Class</label>
                <select name="class_section">
                    <%
                    rs = stmt.executeQuery("SELECT * FROM Class");
                    while (rs.next()) { %>
                        <%= "<option value='" + rs.getString(1) + "," + rs.getString(2) + "," + rs.getString(3) + "'>" + rs.getString(1) + " [" + rs.getString(2) + ", " + rs.getString(3) + "]</option>" %>
                <%    
                    }  %>
                </select>

                <br /><br />Units: <input type="number" name="units" min="0" max="100">
                <input type="submit" name="submit" value="Create">
            </form>
        </div>
    </body>
</html>