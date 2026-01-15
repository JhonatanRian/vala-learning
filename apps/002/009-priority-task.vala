public class Job : Object {
    public string name { get; set; }
    public int priority { get; set; }

    public Job (string name, int priority) {
        Object (
            name: name,
            priority: priority
        );
    }
}

public int compare_jobs (Job a, Job b) {
    return b.priority - a.priority;
}

public static void main () {
    var scheduler = new Gee.PriorityQueue<Job> (compare_jobs);
    scheduler.add (new Job ("Low priority task", 10));
    scheduler.add (new Job ("High priority task", 1));
    scheduler.add (new Job ("Medium priority task", 5));
    scheduler.add (new Job ("Very high priority task", 0));
    while (!scheduler.is_empty) {
        var job = scheduler.poll ();
        print ("Executing job: %s with priority %d\n", job.name, job.priority);
    }

}
