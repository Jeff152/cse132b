<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Degree Requirement Home Page</title>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    </head>
    <body>
        <%-- set the scripting language to Java --%>
        <%@ page language="java" import="java.sql.*" %>
        <%
            DriverManager.registerDriver(new org.postgresql.Driver());

            // Make a connection to the database
            Connection connection = DriverManager.getConnection("jdbc:postgresql:cse132b?user=postgres&password=admin");
        
            String action = request.getParameter("action");
            boolean created = false;
            String success_msg = "";

            if ((action != null) && action.equals("insert")) {
                PreparedStatement pcheck = connection.prepareStatement("SELECT COUNT(*) FROM degree WHERE name = (?)");
                pcheck.setString(1, request.getParameter("degree_name"));
                ResultSet rs = pcheck.executeQuery();
                rs.next();

                // Begin transaction
                connection.setAutoCommit(false);

                // we either create a new degree id, or retrieve the id associated with the degree number
                int degree_id = 0;
                if (rs.getInt(1) == 0) {
                    // create since it doesn't exist
                    PreparedStatement pstmt = connection.prepareStatement("INSERT INTO degree (name) VALUES (?) RETURNING degree_id");
                    pstmt.setString(1, request.getParameter("degree_name"));
                    pstmt.execute();

                    ResultSet last = pstmt.getResultSet();
                    if (last.next())
                        degree_id = last.getInt(1);
                } else {
                    // retrieve degree id, since it already exists
                    PreparedStatement pstmt = connection.prepareStatement("SELECT * FROM degree WHERE name = (?)");
                    pstmt.setString(1, request.getParameter("degree_name"));

                    rs = pstmt.executeQuery();
                    rs.next();
                    degree_id = rs.getInt(1);
                }

                String degree_type = request.getParameter("degree_option");
                if (degree_type.equals("BS")) {
                    PreparedStatement bs_stmt = connection.prepareStatement("SELECT COUNT(*) FROM degree_BS WHERE degree_id = (?)");
                    bs_stmt.setInt(1, degree_id);
                                
                    ResultSet bs_rs = bs_stmt.executeQuery();
                    bs_rs.next();

                    boolean created_new_bs = false;
                    if (bs_rs.getInt(1) == 0) {
                        // only add, if not exists
                        bs_stmt = connection.prepareStatement("INSERT INTO degree_BS VALUES (?)");
                        bs_stmt.setInt(1, degree_id);
                        bs_stmt.executeUpdate();

                        created_new_bs = true;
                    }

                    bs_stmt = connection.prepareStatement("SELECT COUNT(*) FROM degree_unit_categories WHERE degree_id = (?) AND category = (?)");
                    bs_stmt.setInt(1, degree_id);
                    bs_stmt.setString(2, request.getParameter("bs_category"));

                    bs_rs = bs_stmt.executeQuery();
                    bs_rs.next();

                    if (bs_rs.getInt(1) == 0) {
                        // doesn't exist, so we add
                        bs_stmt = connection.prepareStatement("INSERT INTO degree_unit_categories VALUES (?, ?, ?, ?)");
                        bs_stmt.setInt(1, degree_id);
                        bs_stmt.setString(2, request.getParameter("bs_category"));
                        bs_stmt.setString(3, request.getParameter("bs_grade"));
                        bs_stmt.setInt(4, Integer.parseInt(request.getParameter("bs_units")));
                        bs_stmt.executeUpdate();
                    }

                    created = true;
                    if (created_new_bs)
                        success_msg = "Created new BS degree & added new unit category!";
                    else
                        success_msg = "Added new BS unit category!";
                } else {
                    PreparedStatement ms_stmt = connection.prepareStatement("SELECT COUNT(*) FROM degree_MS WHERE degree_id = (?)");
                    ms_stmt.setInt(1, degree_id);
                                
                    ResultSet ms_rs = ms_stmt.executeQuery();
                    ms_rs.next();

                    boolean created_new_ms = false;
                    if (ms_rs.getInt(1) == 0) {
                        // only add, if not exists
                        ms_stmt = connection.prepareStatement("INSERT INTO degree_MS VALUES (?)");
                        ms_stmt.setInt(1, degree_id);
                        ms_stmt.executeUpdate();

                        created_new_ms = true;
                    }

                    ms_stmt = connection.prepareStatement("SELECT COUNT(*) FROM degree_MS_concentration WHERE degree_id = (?) AND course_num = (?)");
                    ms_stmt.setInt(1, degree_id);
                    ms_stmt.setString(2, request.getParameter("course_num"));
                        
                    ms_rs = ms_stmt.executeQuery();
                    ms_rs.next();

                    if (ms_rs.getInt(1) == 0) {
                        // only add, if not exists
                        ms_stmt = connection.prepareStatement("INSERT INTO degree_MS_concentration VALUES (?, ?)");
                        ms_stmt.setInt(1, degree_id);
                        ms_stmt.setString(2, request.getParameter("course_num"));
                        ms_stmt.executeUpdate();
                    }
  
                    created = true;
                    if (created_new_ms)
                        success_msg = "Created new MS degree requirement & added a new concentration [" + request.getParameter("course_num") + "]!";
                    else
                        success_msg = "Added a new MS concentration [" + request.getParameter("course_num") + "]!";
                }

                connection.commit();
                connection.setAutoCommit(true);
            }
        %>

        <div>
            <h3>Insert new Degree</h3>
            <%= created ? "<div id='done'><h3 style='color: green;'>" + success_msg + "</h3></div>" : "" %>

            <form action="degree_req.jsp" method="GET">
                <input type="hidden" name="action" value="insert">

                Name: <input type="input" name="degree_name"><br /><br />
                Type:
                <div id="degree_option">
                    <input type="radio" name="degree_option" value="BS" checked>
                    <label for="degree_option">BS</label><br>
                    <input type="radio" name="degree_option" value="MS">
                    <label for="degree_option">MS</label><br/><br/>
                </div>

                <div id="bs">
                    <i>If the degree already exists, it will add the new unit category instead.</i><br />

                    Category: <input type="input" name="bs_category" maxLength="20"><br /><br />
                    Grade: <select name="bs_grade">
                        <option value="A+">A+</option>
                        <option value="A">A</option>
                        <option value="A-">A-</option>
                        <option value="B+">B+</option>
                        <option value="B">B</option>
                        <option value="B-">B-</option>
                        <option value="C+">C+</option>
                        <option value="C">C</option>
                        <option value="C-">C-</option>
                        <option value="D">D</option>
                        <option value="F">F</option>
                        <option value="N/A">None</option>
                    </select>

                    <br /><br />Units: <input type="number" name="bs_units" min="0" max="100">
                </div>

                <div style="display:none;" id="ms">
                    <label for="course_num">Course</label>
                    <select name="course_num">
                        <%
                        Statement stmt = connection.createStatement();
                        ResultSet rs = stmt.executeQuery("SELECT * FROM course");
                        while (rs.next()) { %>
                            <%= "<option value='" + rs.getString(1) + "'>" + rs.getString(1) + "</option>" %>
                    <%    
                        }  %>
                    </select>
                </div>

                <br /><input type="submit" name="submit" value="Create">
            </form>
        </div>
    </body>

    <script type="text/javascript">
        $(document).ready(() => {
            $('input[type=radio][name=degree_option]').change(() => {
                const selected = $('input[type=radio][name=degree_option]:checked').val();
                if (selected === 'BS') {
                    $('#bs').show();
                    $('#ms').hide();
                } else {
                    $('#bs').hide();
                    $('#ms').show();
                }
            });
        });
    </script>
</html>