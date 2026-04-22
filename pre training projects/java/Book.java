public class Book {
    int id;
    String title, author, cat;
    boolean issued;

    public Book(int id, String title, String author, String cat) {
        this.id = id;
        this.title = title;
        this.author = author;
        this.cat = cat;
        this.issued = false;
    }

    public String toString() {
        return id + " | " + title + " | " + author + " | " + cat + " | " + (issued ? "Issued" : "Available");
    }
}
