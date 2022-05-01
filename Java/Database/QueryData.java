// File:    QueryData.java
// Purpose: Retrieve the column names and data types from the database metadata.
// Listing: Chapter 22, Listing 22.6
import java.sql.*;
import java.util.*;

public class QueryData {
    private Vector columnsTitles = new Vector<>();
    private Vector rows = new Vector<>();

    QueryData(ResultSet resultSet) {                                                        // Constructor
        try {
            ResultSetMetaData rsMetaData = resultSet.getMetaData();
            for (int i = 1; i < rsMetaData.getColumnCount(); i++)
                columnsTitles.addElement(rsMetaData.getColumnName(i));
            
                resultSet.beforeFirst();
                while (resultSet.next())
                    rows.addElement(setRowData(resultSet, rsMetaData));
        }
        catch(Exception ex) {
            System.err.println(ex.getMessage());
        }
    }

    private Vector setRowData(ResultSet rs, ResultSetMetaData rsMetaData) throws SQLException { // Set data for a row
        Vector row = new Vector<>();
        for (int i = 1; i <= rsMetaData.getColumnCount(); i++) {
            switch(rsMetaData.getColumnType(i)) {                                               // Add column to vector
                case Types.VARCHAR:
                case Types.NVARCHAR:
                case Types.LONGNVARCHAR:                                                        // String
                    row.addElement(rs.getString(i));
                    break;
                case Types.INTEGER:
                case Types.SMALLINT:                                                            // Long
                    row.addElement(Long.valueOf(rs.getLong(i)));
                    break;
                case Types.DECIMAL:
                case Types.DOUBLE:                                                              // Double
                    row.addElement(Double.valueOf(rs.getDouble(i)));
                    break;
                case Types.BIT:                                                                 // Boolean
                    row.addElement(Boolean.valueOf(rs.getBoolean(i)));
                    break;
                default:
                    row.addElement(rsMetaData.getColumnTypeName(i));
            }
        }

        return row;
    }

    Vector getColumnTitles() {                                                                  // Getter for column titles
        return columnsTitles;
    }

    Vector getRowData() {
        return rows;                                                                            // Getter for row data
    }
}