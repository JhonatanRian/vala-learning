class App: GLib.Object {
    private GLib.MainLoop loop;

    public App() {
        this.loop = new GLib.MainLoop();
    }

    public signal void stop();

    public void run() {
        int count = 0;

        this.stop.connect(() => {
            loop.quit();
        });


        // Add a timeout source that triggers every second
        GLib.Timeout.add_seconds(1, () => {
            count++;
            print("Tick %d\n", count);

            // Stop the loop after 5 ticks
            if (count >= 5) {
                this.stop();
            }
            return true;
        });

        loop.run();
    }

    public static int main(string[] args) {
        var app = new App();
        app.run();        
        return 0;
    }
}