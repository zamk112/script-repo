// File:    StatementSet.java
// Purpose: Create a statement and resultset; navigate the cursor
// Listing: Chapter 22, Listing 22.3
import java.sql.*;
import javax.swing.*;
 

public class StatementSet {

    static final int CURSOR_FIRST = 0;
    static final int CURSOR_LAST = 1;
    static final int CURSOR_NEXT = 2;
    static final int CURSOR_PREVIOUS = 3;
    String errorMessage;
    private ResultSet resultSet = null;
    private Statement statement;

    StatementSet(Connection conn) {                                         // Create scrollable, updateable statement
        try {
            statement = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE);
        }
        catch(Exception ex) {
            System.err.println(ex.getMessage());
            statement = null;                                               // Can't create statement
        }
    }

    ResultSet getResultSet(String query) {                                  // Create a ResultSet based on a SELECT
        resultSet = null;

        try {
            resultSet = statement.executeQuery(query);
            resultSet.beforeFirst();                                        // Re-position the cursor
        }
        catch (SQLException ex) {
            errorMessage = ex.getMessage();
            System.err.println(errorMessage);
            resultSet = null;
        }

        return resultSet;
    }

    boolean moveCursor(int cursorDirection) {                               // Move to cursor next/prior record
        boolean moreRecords = false;

        try {
            switch(cursorDirection) {
                case CURSOR_FIRST:
                    resultSet.first();
                    break;
                case CURSOR_LAST:
                    resultSet.last();
                    break;
                case CURSOR_NEXT:
                    moreRecords = resultSet.next();
                    if (!moreRecords)                                       // Move beyond last
                        resultSet.last();
                    break;
                case CURSOR_PREVIOUS:
                    moreRecords = resultSet.previous();
                    if (!moreRecords)                                       // Moved before first
                        resultSet.first();
                    break;
            }
        }
        catch (SQLException ex) {
            errorMessage = ex.getMessage();
            System.err.println(ex.getMessage());
        }
        return moreRecords;
    }
}
