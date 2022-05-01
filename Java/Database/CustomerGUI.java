// File:    CustomerGUI.java
// Purpose: Set up the customer GUI with next, previous, find and update buttons
// Listing: Chapter 22, Listing 22.2

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.sql.*;

public class CustomerGUI extends JFrame implements ActionListener {

    private int totalRows;
    private StatementSet statement;
    private JButton btnAdd, btnFirst, btnLast, btnNext, btnPrevious, btnSave, btnUpdate;
    private GenericPanel gui;
    private ResultSet rsCustomer;
    private String buttonNames[] = {"|<", "<", ">", ">|", "Add", "Save", "Update"};
    private String fieldNames[] = {"Customer Id", "Company Name", "Contact Title", "City", "Country", "Record No."};
    private String errorMessage;

    public CustomerGUI() {
        Container cn = this.getContentPane();
        cn.setLayout(new BorderLayout());
        gui = new GenericPanel(fieldNames, buttonNames);
        
        btnFirst = gui.getButton(0);                    btnPrevious = gui.getButton(1);
        btnNext = gui.getButton(2);                     btnLast = gui.getButton(3);
        btnAdd = gui.getButton(4);                      btnSave = gui.getButton(5);
        btnUpdate = gui.getButton(6);

        btnFirst.addActionListener(this);                     btnPrevious.addActionListener(this);
        btnNext.addActionListener(this);                      btnLast.addActionListener(this);
        btnAdd.addActionListener(this);                       btnSave.addActionListener(this);
        cn.add(gui, BorderLayout.CENTER);
        // Find and replace <YOUR_SERVER> with your SQL Server name, <YOUR_USERNAME> with your username & password with <YOUR_PASSWORD>
        String url = "jdbc:sqlserver://<YOUR_SERVER>;"
        + "database=NorthWind;"
        + "user=<YOUR_USERNAME>;"
        + "password=<YOUR_PASSWORD>;"
        + "encrypt=false;"
        + "trustServerCertificate=false;"
        + "loginTimeout=30;";

        Connection connNWind = Connect.openDatabase(url);

        if (connNWind == null) {
            JOptionPane.showMessageDialog(null, "Could not create statement set");
            System.exit(1);
        }

        statement = new StatementSet(connNWind);
        if (statement == null) {
            JOptionPane.showMessageDialog(null, "Could not create statement set");
            System.exit(1);
        }
        rsCustomer = statement.getResultSet("SELECT * FROM customers");             // Execute query
        this.getTotalRows();                                                                // Get total no. of rows

        if (statement.moveCursor(StatementSet.CURSOR_NEXT))                         // Move to first customer
            this.custTableToFrame(gui);
        else
            JOptionPane.showMessageDialog(null, "End of customers");
        btnSave.setEnabled(false);                                              // User can add or update, but not

        btnAdd.setEnabled(true);
        btnUpdate.setEnabled(true);
    }

    public void actionPerformed(ActionEvent e) {
        if (e.getSource() == btnNext) {
            if (statement.moveCursor(StatementSet.CURSOR_NEXT))
                this.custTableToFrame(gui);                                         // Display next customer
            else
                JOptionPane.showMessageDialog(null, "End of customers");
        }
        else if (e.getSource() == btnPrevious) {
            if (statement.moveCursor(StatementSet.CURSOR_PREVIOUS))
                this.custTableToFrame(gui);                                         // Display prev. customer       
            else
                JOptionPane.showMessageDialog(null, "Start of customers");
        }
        else if (e.getSource() == btnFirst) {
            statement.moveCursor(StatementSet.CURSOR_FIRST);                        // Display first customer
            this.custTableToFrame(gui);
        }
        else if (e.getSource() == btnLast) {
            statement.moveCursor(StatementSet.CURSOR_LAST);
            this.custTableToFrame(gui);                                             // Display last customer
        }
        else if (e.getSource() == btnAdd) {
            int response;
            response = JOptionPane.showConfirmDialog(null, "Add customer - are you sure", "", JOptionPane.YES_NO_CANCEL_OPTION, JOptionPane.QUESTION_MESSAGE);
            if (response == JOptionPane.YES_OPTION) {
                for (int i = 0; i < gui.numFields; i++)
                    gui.setTextField(i, "");
                btnSave.setEnabled(true);
                btnAdd.setEnabled(false);
                btnUpdate.setEnabled(false);                                    // User can now add or update
            }
            else
                JOptionPane.showMessageDialog(null, statement.errorMessage);
        }
        else if (e.getSource() == btnUpdate) {
            if (this.updateCustomer(gui))
                JOptionPane.showMessageDialog(null, "Customer updated");
            else
                JOptionPane.showMessageDialog(null, statement.errorMessage);
        }
    }
    final static int CUSTID_LENGTH = 5;                                     // CustomerID field in cust table MUST
    boolean addCustomer(GenericPanel gui) {                                 // Add a customer record at the 'insert'

        boolean success = true;
        String custId = "";

        custId = gui.getTextField(0);
        if (custId.length() != CUSTID_LENGTH) {                             // valid the primary key
            errorMessage = "CustomerId field must be exactly 5 characters";
            return false;
        }
        try {
            rsCustomer.moveToCurrentRow();
            rsCustomer.updateString("Customer ID", custId);
            custFrameToTable(gui);                                          // Copy frame fields to table
            System.err.println("try - add customer: " + gui.getTextField(0));
            rsCustomer.insertRow();
            rsCustomer.moveToCurrentRow();
            totalRows++;
            gui.setTextField(5, Integer.toString(totalRows) + " / " + Integer.toString(totalRows));
        }
        catch(SQLException ex) {
            errorMessage = ex.getMessage();
            System.err.println(errorMessage);
            success = false;
        }

        return success;
    }

    boolean updateCustomer(GenericPanel gui) {                              // Update a current record
        boolean success = true;
        try {
            custFrameToTable(gui);                                          // Copy frame fields to table
            rsCustomer.updateRow();
            SQLWarning warn = rsCustomer.getWarnings();                     // Process warnings inline
            if (warn != null) {
                while (warn != null) {
                    System.out.println("Warning: " + warn.getMessage());
                    warn = warn.getNextWarning();
                }
            }
        }
        catch (SQLException ex) {
            errorMessage = ex.getMessage();
            System.err.println(errorMessage);
            success = false;
        }
        return success;
    }

    void custFrameToTable(GenericPanel gui) {                                   // Copy frame fields to table fields
        try {                                                                   // Only update the primary key field (0) when adding
            rsCustomer.updateString("CompanyName", gui.getTextField(1));
            rsCustomer.updateString("ContactName", gui.getTextField(2));
            rsCustomer.updateString("City", gui.getTextField(3));
            rsCustomer.updateString("Country", gui.getTextField(4));
        }
        catch(SQLException ex) {
            System.err.println(ex.getMessage());
        }
    }

    void custTableToFrame (GenericPanel gui) {                                  // Copy frame fields to table fields
        try {
            gui.setTextField(0, rsCustomer.getString("CustomerID"));
            gui.setTextField(1, rsCustomer.getString("CompanyName"));
            gui.setTextField(2, rsCustomer.getString("ContactName"));
            gui.setTextField(3, rsCustomer.getString("City"));
            gui.setTextField(4, rsCustomer.getString("Country"));
            gui.setTextField(5, Integer.toString(rsCustomer.getRow()) + " / " + Integer.toString(totalRows));
        }
        catch (SQLException ex) {
            System.err.println(ex.getMessage());
        }
    }

    void getTotalRows() {
        try {                                                                   // Get number of rows in set
            if (rsCustomer.last())
                totalRows = rsCustomer.getRow();
            rsCustomer.beforeFirst();                                           // Re-position the cursor
        }
        catch (SQLException ex) {
            System.err.println(ex.getMessage());
        }
    }

    public static void main(String[] args) {
        CustomerGUI app = new CustomerGUI();
        app.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        app.setTitle("Maintain Customer Data");
        app.setSize(425, 175);
        app.setVisible(true);
    }
}