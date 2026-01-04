public class Task : Object {
    public string name { get; set; }
    public int16 priority { get; set; }

    public Task (string name, int16 priority) {
        Object (
            name: name,
            priority: priority
        );
    }
}



public class CheckListSample : Object {
    GLib.List<Task> tasks;

    public CheckListSample () {
        this.tasks = new GLib.List<Task> ();
    }

    public void add_task (string name, int16 priority) {
        Task task = new Task (name, priority);
        this.tasks.append (task);
    }

    public void remove_task (string name) {
        foreach (Task task in tasks) {
            if (task.name == name) {
                this.tasks.remove (task);
                break;
            }
        }
    }

    public static int compare_tasks (Task a, Task b) {
        return b.priority - a.priority;
    }

    public void sort_by_priority () {
        this.tasks.sort (compare_tasks);
    }

    public void print_tasks () {
        var count = 0;
        foreach (Task task in tasks) {
            count += 1;
            stdout.printf (@"$(count). $(task.name) - Priority: $(task.priority)\n");
        }
    }

}

public static int main (string[] args) {
    var checkListSample = new CheckListSample ();

    var entry = (string) "";

    while (entry != "exit") {
        checkListSample.print_tasks ();
        print ("Enter a command (add, remove, sort, print, exit): ");
        entry = stdin.read_line ().strip ();

        if (entry == "add") {
            print ("Enter task name: ");
            var name = stdin.read_line ().strip ();
            print ("Enter task priority (integer): ");
            var priority = (int16) int.parse (stdin.read_line ().strip ());
            checkListSample.add_task (name, priority);
            print("\033[2J\033[H");
        } else if (entry == "remove") {
            print ("Enter task name to remove: ");
            var name = stdin.read_line () .strip ();
            checkListSample.remove_task (name);
            print("\033[2J\033[H");
        } else if (entry == "sort") {
            checkListSample.sort_by_priority ();
            print("\033[2J\033[H");
            print ("Tasks sorted by priority.\n");
        }

    }

    return 0;
}
