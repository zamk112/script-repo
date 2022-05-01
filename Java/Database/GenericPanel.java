// File:	GenericPanel.java
// Purpose:	Class for a generic panel with labels in one column of a grid layout
//		and text fields in the second column
// Listing:	Chapter 16, Listing 16.2

import java.awt.*;
import java.awt.event.*;
import javax.swing.*;

public class GenericPanel extends JPanel {
	protected int numFields;
	private JButton buttons[];
	private JLabel labels[];
	private JPanel pnlCentre, pnlSouth;
	private JTextField textFields[];

	public GenericPanel(String fieldNames[], String[] buttonNames) {
		int i;

		this.numFields = fieldNames.length;
		buttons = new JButton[buttonNames.length];
		labels = new JLabel[numFields];
		textFields = new JTextField[numFields];

		pnlCentre = new JPanel();
		pnlCentre.setLayout(new GridLayout(numFields, 2));
		// Add labels and textfields to centre panel
		for (i = 0; i < labels.length; i++) {	
			labels[i] = new JLabel(fieldNames[i]);
			textFields[i] = new JTextField(20); // Set default size to 20
			pnlCentre.add(labels[i]);
			pnlCentre.add(textFields[i]);
		}

		pnlSouth = new JPanel();
		// Add buttons to south panel
		for (i = 0; i < buttonNames.length; i++) {
			buttons[i] = new JButton(buttonNames[i]);
			pnlSouth.add(buttons[i]);
		}

		this.setLayout(new BorderLayout());
		this.add(pnlCentre, BorderLayout.CENTER);
		this.add(pnlSouth, BorderLayout.SOUTH);
		validate();
	}

	public JButton getButton(int index) {	// Return a button reference
		return(buttons[index]);
	}

	public String getTextField(int index) {	// Return field contents
		return(textFields[index].getText());
	}

	public void setTextField(int index, String fldValue) {	// Set field contents
		textFields[index].setText(fldValue);
	}
}

