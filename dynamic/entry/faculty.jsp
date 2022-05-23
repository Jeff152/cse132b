<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Faculty Home Page</title>

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
                PreparedStatement pcheck = connection.prepareStatement("SELECT COUNT(*) FROM faculty WHERE name = (?)");
                pcheck.setString(1, request.getParameter("faculty_name"));
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
                        PreparedStatement pstmt = connection.prepareStatement("INSERT INTO faculty VALUES (?, ?)");
                        pstmt.setString(1, request.getParameter("faculty_name"));
                        pstmt.setString(2, request.getParameter("faculty_title"));
                        pstmt.executeUpdate();

                        // Commit transaction
                        connection.commit();
                        connection.setAutoCommit(true);
                }
            }
        %>
        <table border="1" id="table_detail" cellpadding="10">
            <tr>
                <th>Name</th>
                <th>Title</th>
                <th>Department(s)</th>
            </tr>

            <%
                Statement stmt = connection.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM Faculty");
                int fac_num = 0;

                while (rs.next()) {
                    PreparedStatement dept_s = connection.prepareStatement("SELECT * FROM faculty_department WHERE name = (?)");
                    dept_s.setString(1, rs.getString(1));
                    
                    List<String> departments = new ArrayList<>();
                    ResultSet dept_rs = dept_s.executeQuery();
                    while (dept_rs.next())
                        departments.add(dept_rs.getString(2));
                    
                    StringBuilder dept_display_str = new StringBuilder();
                    for (String dept: departments)
                        dept_display_str.append(dept).append(", ");

                    if (dept_display_str.length() > 0)
                        dept_display_str.setLength(dept_display_str.length() - 2);
                    
                    // truncate if too long
                    String dept_display = dept_display_str.toString();
                    if (dept_display.length() > 15)
                        dept_display = dept_display.substring(0, 15) + "...";
            %>
                    <%= "<tr onclick='showHiddenRow(`faculty_" + fac_num + "`)'>" %>
                        <td><%= rs.getString(1) %></td>
                        <td><%= rs.getString(2) %></td>
                        <td><%= (dept_display.length() > 0) ? dept_display : "<i>none</i>" %></td>
                    </tr>

            <%
                    // retrieve classes of a faculty member, if they have any
                    PreparedStatement fac_count = connection.prepareStatement("SELECT COUNT(*) FROM faculty_class WHERE name = (?)");
                    fac_count.setString(1, rs.getString(1));

                    ResultSet fac_count_rs = fac_count.executeQuery();
                    fac_count_rs.next();

                    int class_count = fac_count_rs.getInt(1);
            %>

            <%= "<tr class='hidden_row' id='faculty_" + fac_num + "'>" %>
                <td colspan="3">
                    <%= ((class_count == 0) ? "This person has taught no classes." : "Taught " + class_count + " class" + ((class_count > 1) ? "es" : "")) + "<br/>" %>

                    <%
                            if (class_count > 0) {
                                PreparedStatement fac_s = connection.prepareStatement("SELECT * FROM faculty_class WHERE name = (?)");
                                fac_s.setString(1, rs.getString(1));
                                ResultSet fac_rs = fac_s.executeQuery();
                                
                                StringBuilder classes_sb = new StringBuilder();
                                while (fac_rs.next())
                                    classes_sb.append(fac_rs.getString(2)).append(" [").append(fac_rs.getString(3)).append("], ");
                                
                                if (classes_sb.length() > 0)
                                    classes_sb.setLength(classes_sb.length() - 2); %>
                            
                            Classes: <b><%= classes_sb.toString() %></b>

                            <%
                            } %>
                </td>
            </tr>
            <%      
                    fac_num++;
                } %>
        </table>

        <div>
            <h3>Insert new Faculty</h3>
            <%= exists ? "<div id='error'><h3 style='color: red;'>Faculty already exists!</h3></div>" : "" %>

            <form action="faculty.jsp" method="GET">
                <input type="hidden" name="action" value="insert">

                Name: <input type="input" name="faculty_name" required><br /><br />
                Title: <input type="input" name="faculty_title"><br /><br />
                <input type="submit" name="submit" value="Create">
            </form>
        </div>
    </body>
</html>