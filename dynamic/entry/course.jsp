<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Course Home Page</title>

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
        <div id="main">
            <table border="1" id="table_detail" cellpadding="10">
                <tr>
                    <th>Course #</th>
                    <th>Grade Option</th>
                    <th>Instructor Consent</th>
                    <th>Lab Work Required</th>
                </tr>

<%-- set the scripting language to Java --%>
<%@ page language="java" import="java.sql.*" %>
<%
   DriverManager.registerDriver(new org.postgresql.Driver());

   // Make a connection to the database
   Connection connection = DriverManager.getConnection("jdbc:postgresql:cse132b?user=postgres&password=admin");

   String action = request.getParameter("action");
   boolean exists = false;
   if ((action != null) && action.equals("insert")) {
       PreparedStatement pcheck = connection.prepareStatement("SELECT COUNT(*) FROM course WHERE course_num = (?)");
       pcheck.setString(1, request.getParameter("course_num"));
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
            PreparedStatement pstmt = connection.prepareStatement("INSERT INTO course VALUES (?, ?, ?, ?, ?, ?)");
            pstmt.setString(1, request.getParameter("course_num"));
            pstmt.setString(2, request.getParameter("grade_option"));
            pstmt.setBoolean(3, request.getParameter("consent") != null);
            pstmt.setBoolean(4, request.getParameter("lab_work") != null);
            pstmt.setInt(5, Integer.parseInt(request.getParameter("min_units")));
            pstmt.setInt(6, Integer.parseInt(request.getParameter("max_units")));
            pstmt.executeUpdate();

            String prereq_input = request.getParameter("prereqs");
            if ((prereq_input != null) && (prereq_input.length() > 0)) {
                String[] prereqs = prereq_input.split(",");
                for (String prereq: prereqs) {
                    pstmt = connection.prepareStatement("INSERT INTO course_prereq VALUES (?, ?)");
                    pstmt.setString(1, request.getParameter("course_num"));
                    pstmt.setString(2, prereq);
                    pstmt.executeUpdate();
                }
            }
    
            // Commit transaction
            connection.commit();
            connection.setAutoCommit(true);
       }
   }

   Statement stmt = connection.createStatement();
   ResultSet rs = stmt.executeQuery("SELECT * FROM course");
   int course_num = 0;
   while (rs.next()) {  %>
                <%= "<tr onclick='showHiddenRow(`course_" + course_num + "`)'>" %>
                    <td><%= rs.getString(1) %></td>
                    <td><%= rs.getString(2) %></td>
                    <td><%= rs.getBoolean(3) ? "yes" : "no" %></td>
                    <td><%= rs.getBoolean(4) ? "yes" : "no" %></td>
                </tr>
                
                <%= "<tr class='hidden_row' id='course_" + course_num + "'>" %>
                    <td colspan="4">
                        <%
                        int min_units = rs.getInt(5);
                        int max_units = rs.getInt(6);
                        %>

                        <%=
                            (min_units == max_units) ? "Units: <b>" + min_units + "</b><br />"
                            : "Min Units: <b>" + min_units + "</b><br />Max Units: <b>" + max_units + "</b><br />"
                        %>
                        
                        <%
                        PreparedStatement preq_stmt = connection.prepareStatement("SELECT * FROM course_prereq WHERE course_num = (?)");
                        preq_stmt.setString(1, rs.getString(1));
                        ResultSet prs = preq_stmt.executeQuery();
                        
                        StringBuilder preq_str = new StringBuilder();
                        while (prs.next())
                            preq_str.append(prs.getString(2)).append(", ");

                        // remove comma at end
                        if (preq_str.length() > 0)
                            preq_str.setLength(preq_str.length() - 2);
                        %>

                        Pre-reqs: <b><%= (preq_str.length() > 0) ? preq_str.toString() : "None" %></b>
                    </td>
                </tr>
<% 
   course_num++;
} %>   
            </table>

            <div>
                <h3>Insert new Course</h3>
                <%= exists ? "<div id='error'><h3 style='color: red;'>Course number already exists!</h3></div>" : "" %>

                <form action="course.jsp" method="GET">
                    <input type="hidden" name="action" value="insert">

                    Course #: <input type="text" name="course_num" required><br/><br/>
                    Min Units: <input type="number" name="min_units" min="1" max="20"><br/><br/>
                    Max Units: <input type="number" name="max_units" min="1" max="20"><br/><br/>
                    Grade Option:
                    <div id="gr_option">
                        <input type="radio" name="grade_option" value="letter">
                        <label for="grade_option">Letter</label><br>
                        <input type="radio" name="grade_option" value="p/np">
                        <label for="grade_option">Pass / No Pass</label><br/>
                        <input type="radio" name="grade_option" value="both">
                        <label for="grade_option">Both</label><br/><br/>
                    </div>
                    Instructor Consent? <input type="checkbox" name="consent"><br/>
                    Lab Work Required? <input type="checkbox" name="lab_work"><br/><br/>
                    Prereqs: <input type="text" name="prereqs">
                    <label for="grade_option" style="font-size: 10px;"><i>separated by commas</i></label><br/><br/>

                    <input type="submit" name="submit" value="Create">
                </form>
            </div>
        </div>
    </body>
</html>