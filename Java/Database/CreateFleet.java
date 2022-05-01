// File:    CreateFleet.java
// Purpose: Create the fleet table, and insert and list rows
// Listing: Chapter 22, Listing 22.1
import java.sql.*;

public class CreateFleet {

    public static void main(String[] args) throws ClassNotFoundException {
        Connection conn;
        Statement statement;
        // String url = "jdbc:odbc:fleet";                                              // Can't use this connection string
        // Find and replace <YOUR_SERVER> with your SQL Server name, <YOUR_USERNAME> with your username & password with <YOUR_PASSWORD>
        String url = "jdbc:sqlserver://<YOUR_SERVER>;"
        + "database=NorthWind;"
        + "user=<YOUR_USERNAME>;"
        + "password=<YOUR_PASSWORD>;"
        + "encrypt=false;"
        + "trustServerCertificate=false;"
        + "loginTimeout=30;";

        String createFleet = "CREATE TABLE Fleet " + 
                "(model VARCHAR(12), " + 
                "Manufacturer VARCHAR(20), " +
                "MaxPassengers INTEGER, " +
                "RefuelDistance INTEGER)";
        
        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");                      // SQL Server Driver
        //Class.forName("sun.jdbc.odbc.JdbcOdbcDriver");                                    // Load ODBC Driver
        try {
            conn = DriverManager.getConnection(url);
            statement = conn.createStatement();
            statement.executeUpdate(createFleet);                                           // Create Fleet table

            // Insert rows
            statement.executeUpdate("INSERT INTO fleet " +
                    "VALUES ('B747-438', 'Boeing', 394, 127000)");
            statement.executeUpdate("INSERT INTO fleet " +
                    "VALUES ('B767-338', 'Boeing', 210, 6000)");
            statement.executeUpdate("INSERT INTO fleet " +
                    "VALUES ('BAe   146', 'British Aero', 87, 2155)");
            statement.executeUpdate("INSERT INTO fleet " +
                    "VALUES ('Dash  8', 'Dash', 50, 1520)");
            
            // List the fleet
            ResultSet rs = statement.executeQuery("SELECT * FROM fleet");
            System.out.println("Model       No.Passengers");
            while (rs.next()) {
                String planeModel = rs.getString("Model");
                int passengers = rs.getInt("MaxPassengers");
                System.out.println(planeModel + '\t' + passengers);
            }

            statement.close();
            conn.close();
        }
        catch (SQLException ex) {
            System.err.println("SQLException: " + ex.getMessage());
        }
    }
}
