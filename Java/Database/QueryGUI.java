// File:    QueryGUI.java
// Purpose: GUI to interactively execute a SELECT statement
// Listing: Chapter 22, Listing 22.5
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import javax.swing.event.*;
import java.sql.*;
import java.util.*;

public class QueryGUI extends JFrame implements ActionListener {
    private Container cn;
    private JButton btnExecute;
    private JTable tblResults;
    private JTextArea txaQuery;
    private ResultSet resultSet;
    private StatementSet statement;

    public QueryGUI() {
        txaQuery = new JTextArea("SELECT * FROM ", 5, 40);
        btnExecute = new JButton("Execute Query");
        btnExecute.addActionListener(this);
        JPanel pnlQuery = new JPanel();                                                     // Panel for query
        pnlQuery.setLayout(new BorderLayout());
        pnlQuery.add(txaQuery, BorderLayout.CENTER);
        pnlQuery.add(btnExecute, BorderLayout.SOUTH);

        tblResults = new JTable(4, 5);
        cn = this.getContentPane();
        cn.add(pnlQuery, BorderLayout.NORTH);
        cn.add(tblResults, BorderLayout.CENTER);
        // Find and replace <YOUR_SERVER> with your SQL Server name, <YOUR_USERNAME> with your username & password with <YOUR_PASSWORD>
        String url = "jdbc:sqlserver://<YOUR_SERVER>;"
        + "database=NorthWind;"
        + "user=<YOUR_USERNAME>;"
        + "password=<YOUR_PASSWORD>;"
        + "encrypt=false;"
        + "trustServerCertificate=false;"
        + "loginTimeout=30;";

        Connection connNWind = Connect.openDatabase(url);
        statement = new StatementSet(connNWind);
    }

    public void actionPerformed(ActionEvent e) {
        if (e.getSource() == btnExecute) {
            displayResults();
        }
    }

    void displayResults() {                                                                 // Execute and display results
        String queryText = txaQuery.getText();
        resultSet = statement.getResultSet(queryText);                                      // Execute query
        JOptionPane.showMessageDialog(null, "<" + queryText + ">");
        if (resultSet == null) {                                                            // Error in query
            JOptionPane.showMessageDialog(null, statement.errorMessage);
            tblResults = new JTable(4, 5);
        }
        else if (!statement.moveCursor(StatementSet.CURSOR_NEXT)) {                         // No records
            JOptionPane.showMessageDialog(null, "No records selected");
            tblResults = new JTable(4, 5);
        }
        else {
            QueryData queryData = new QueryData(resultSet);
            Vector columnTitles = queryData.getColumnTitles();
            Vector rows = queryData.getRowData();

            // Set a new table with column and row data for current query
            tblResults = new JTable(rows, columnTitles);
        }
        cn.remove(1);                                                               // Remove table with old rows
        cn.add(new JScrollPane(tblResults));                                              // Add table with new rows
        cn.validate();                                                                    // Re-establish the components
    }

    public static void main(String args[]) {
        QueryGUI app = new QueryGUI();
        app.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        app.setTitle("Query NWind Database");
        app.setSize(425, 225);
        app.setVisible(true);
    }
}