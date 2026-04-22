import javax.swing.*;
import javax.swing.table.*;
import java.awt.*;
import java.time.LocalDate;
import java.util.ArrayList;

public class LibraryApp extends JFrame {

    ArrayList<Book> books = new ArrayList<>();
    ArrayList<User> users = new ArrayList<>();
    ArrayList<Transaction> txns = new ArrayList<>();
    int bid = 1, uid = 1;

    DefaultTableModel bookModel, userModel, txnModel;

    public LibraryApp() {
        setTitle("Library Management System");
        setSize(850, 550);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setLocationRelativeTo(null);

        JTabbedPane tabs = new JTabbedPane();
        tabs.addTab("Books", bookPanel());
        tabs.addTab("Users", userPanel());
        tabs.addTab("Issue / Return", issuePanel());
        tabs.addTab("Search", searchPanel());
        tabs.addTab("Transactions", txnPanel());

        add(tabs);
        setVisible(true);
    }

    JPanel bookPanel() {
        JPanel p = new JPanel(new BorderLayout(5, 5));
        p.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        String[] cols = {"ID", "Title", "Author", "Category", "Status"};
        bookModel = new DefaultTableModel(cols, 0);
        JTable tbl = new JTable(bookModel);
        p.add(new JScrollPane(tbl), BorderLayout.CENTER);

        JPanel form = new JPanel(new GridLayout(2, 4, 5, 5));
        JTextField t = new JTextField(), a = new JTextField(), c = new JTextField();
        form.add(new JLabel("Title:")); form.add(t);
        form.add(new JLabel("Author:")); form.add(a);
        form.add(new JLabel("Category:")); form.add(c);

        JButton add = new JButton("Add Book");
        JButton del = new JButton("Remove Selected");
        form.add(add); form.add(del);

        add.addActionListener(e -> {
            if (t.getText().trim().isEmpty()
                    || a.getText().trim().isEmpty()
                    || c.getText().trim().isEmpty()) {
                JOptionPane.showMessageDialog(this, "Fill all fields.");
                return;
            }
            Book b = new Book(bid++, t.getText().trim(), a.getText().trim(), c.getText().trim());
            books.add(b);
            bookModel.addRow(new Object[]{b.id, b.title, b.author, b.cat, "Available"});
            t.setText(""); a.setText(""); c.setText("");
        });

        del.addActionListener(e -> {
            int row = tbl.getSelectedRow();
            if (row == -1) {
                JOptionPane.showMessageDialog(this, "Select a book.");
                return;
            }
            int id = (int) bookModel.getValueAt(row, 0);
            books.removeIf(x -> x.id == id);
            bookModel.removeRow(row);
        });

        p.add(form, BorderLayout.SOUTH);
        return p;
    }

    JPanel userPanel() {
        JPanel p = new JPanel(new BorderLayout(5, 5));
        p.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        String[] cols = {"ID", "Name", "Department"};
        userModel = new DefaultTableModel(cols, 0);
        JTable tbl = new JTable(userModel);
        p.add(new JScrollPane(tbl), BorderLayout.CENTER);

        JPanel form = new JPanel(new GridLayout(1, 5, 5, 5));
        JTextField n = new JTextField(), d = new JTextField();
        form.add(new JLabel("Name:")); form.add(n);
        form.add(new JLabel("Dept:")); form.add(d);

        JButton add = new JButton("Register");
        form.add(add);

        add.addActionListener(e -> {
            if (n.getText().trim().isEmpty()
                    || d.getText().trim().isEmpty()) {
                JOptionPane.showMessageDialog(this, "Fill all fields.");
                return;
            }
            User u = new User(uid++, n.getText().trim(), d.getText().trim());
            users.add(u);
            userModel.addRow(new Object[]{u.id, u.name, u.dept});
            n.setText(""); d.setText("");
        });

        p.add(form, BorderLayout.SOUTH);
        return p;
    }

    JPanel issuePanel() {
        JPanel p = new JPanel(new GridBagLayout());
        p.setBorder(BorderFactory.createEmptyBorder(20, 20, 20, 20));
        GridBagConstraints g = new GridBagConstraints();
        g.insets = new Insets(8, 8, 8, 8);
        g.fill = GridBagConstraints.HORIZONTAL;

        JTextField uid_f = new JTextField(10), bid_f = new JTextField(10);
        JLabel status = new JLabel(" ");
        status.setFont(new Font("Arial", Font.BOLD, 13));

        g.gridx = 0; g.gridy = 0; p.add(new JLabel("User ID:"), g);
        g.gridx = 1; p.add(uid_f, g);
        g.gridx = 0; g.gridy = 1; p.add(new JLabel("Book ID:"), g);
        g.gridx = 1; p.add(bid_f, g);

        JButton iss = new JButton("Issue Book");
        JButton ret = new JButton("Return Book");

        g.gridx = 0; g.gridy = 2; p.add(iss, g);
        g.gridx = 1; p.add(ret, g);
        g.gridx = 0; g.gridy = 3; g.gridwidth = 2; p.add(status, g);

        iss.addActionListener(e -> {
            try {
                int u = Integer.parseInt(uid_f.getText().trim());
                int b = Integer.parseInt(bid_f.getText().trim());
                User usr = users.stream().filter(x -> x.id == u).findFirst().orElse(null);
                Book bok = books.stream().filter(x -> x.id == b).findFirst().orElse(null);
                if (usr == null || bok == null) {
                    status.setForeground(Color.RED);
                    status.setText("User or Book not found.");
                    return;
                }
                if (bok.issued) {
                    status.setForeground(Color.RED);
                    status.setText("Book already issued.");
                    return;
                }
                bok.issued = true;
                Transaction t = new Transaction(u, b);
                txns.add(t);
                refreshTxn();
                refreshBookStatus(b, "Issued");
                status.setForeground(new Color(0, 128, 0));
                status.setText("Issued! Due: " + t.due_dt);
            } catch (NumberFormatException ex) {
                status.setForeground(Color.RED);
                status.setText("Enter valid IDs.");
            }
        });

        ret.addActionListener(e -> {
            try {
                int u = Integer.parseInt(uid_f.getText().trim());
                int b = Integer.parseInt(bid_f.getText().trim());
                Transaction t = null;
                for (Transaction x : txns) {
                    if (x.uid == u
                            && x.bid == b
                            && x.return_dt == null) {
                        t = x;
                        break;
                    }
                }
                if (t == null) {
                    status.setForeground(Color.RED);
                    status.setText("No active transaction found.");
                    return;
                }
                t.return_dt = LocalDate.now();
                Book bok = books.stream().filter(x -> x.id == b).findFirst().orElse(null);
                if (bok != null)
                    bok.issued = false;
                refreshTxn();
                refreshBookStatus(b, "Available");
                status.setForeground(new Color(0, 128, 0));
                status.setText("Returned! Fine: Rs." + t.fine());
            } catch (NumberFormatException ex) {
                status.setForeground(Color.RED);
                status.setText("Enter valid IDs.");
            }
        });

        return p;
    }

    JPanel searchPanel() {
        JPanel p = new JPanel(new BorderLayout(5, 5));
        p.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        JTextField q = new JTextField();
        JTextArea res = new JTextArea();
        res.setEditable(false);
        res.setFont(new Font("Monospaced", Font.PLAIN, 13));

        JButton btn = new JButton("Search");
        btn.addActionListener(e -> {
            String kw = q.getText().trim().toLowerCase();
            res.setText("");
            if (kw.isEmpty()) {
                res.setText("Enter a keyword.");
                return;
            }
            StringBuilder sb = new StringBuilder();
            for (Book b : books) {
                if (b.title.toLowerCase().contains(kw)
                        || b.author.toLowerCase().contains(kw)
                        || b.cat.toLowerCase().contains(kw)) {
                    sb.append(b.toString());
                    sb.append("\n");
                }
            }
            res.setText(sb.length() == 0 ? "No results found." : sb.toString());
        });

        JPanel top = new JPanel(new BorderLayout(5, 5));
        top.add(new JLabel("Search (title/author/category):"), BorderLayout.WEST);
        top.add(q, BorderLayout.CENTER);
        top.add(btn, BorderLayout.EAST);

        p.add(top, BorderLayout.NORTH);
        p.add(new JScrollPane(res), BorderLayout.CENTER);
        return p;
    }

    JPanel txnPanel() {
        JPanel p = new JPanel(new BorderLayout(5, 5));
        p.setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));

        String[] cols = {"User ID", "Book ID", "Issued", "Due", "Returned", "Fine"};
        txnModel = new DefaultTableModel(cols, 0);
        JTable tbl = new JTable(txnModel);
        p.add(new JScrollPane(tbl), BorderLayout.CENTER);
        return p;
    }

    void refreshTxn() {
        txnModel.setRowCount(0);
        for (Transaction t : txns) {
            String r = (t.return_dt == null) ? "Pending" : t.return_dt.toString();
            txnModel.addRow(new Object[]{t.uid, t.bid, t.issued_dt, t.due_dt, r, "Rs." + t.fine()});
        }
    }

    void refreshBookStatus(int id, String s) {
        for (int i = 0; i < bookModel.getRowCount(); i++) {
            if ((int) bookModel.getValueAt(i, 0) == id) {
                bookModel.setValueAt(s, i, 4);
                break;
            }
        }
    }

    public static void main(String[] a) {
        SwingUtilities.invokeLater(LibraryApp::new);
    }
}
