public class User {
    int id;
    String name, dept;

    public User(int id, String name, String dept) {
        this.id = id;
        this.name = name;
        this.dept = dept;
    }

    public String toString() {
        return id + " | " + name + " | " + dept;
    }
}
