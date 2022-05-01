// File:    Connect.java
// Purpose: Obtain a connection to an OBDC data source
// Listing: Chapter 22, Listing 22.4
import java.sql.*;

public class Connect {
    static Connection conn;

    static Connection openDatabase(String url) {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            conn = DriverManager.getConnection(url);
        }
        catch(Exception ex) {
            System.err.println(ex.getMessage());
            conn = null;
        }

        return conn;
    }

    static void isDatabaseUpdatable() {                             // Get concurrency level
        try {
            DatabaseMetaData dbMetaData = conn.getMetaData();
            if (dbMetaData.supportsResultSetConcurrency(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE))
                System.err.println("Concurrency support");
            else 
                System.err.println("Concurrency not supported");
        }
        catch (Exception ex) {
            System.err.println(ex.getMessage());
        }
    }
}