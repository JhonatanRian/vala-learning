public class TextFileViewerSample : Gtk.Application {
    private Gtk.TextView text_view;
    private Gtk.ApplicationWindow window;

    public TextFileViewerSample () {
        Object (application_id: "com.example.TextFileViewerSample");
    }

    public override void activate () {
        this.window = new Gtk.ApplicationWindow (this) {
            title = "Text File Viewer",
            default_width = 600,
            default_height = 400,
        };
        
        var toolbar = new Gtk.Toolbar (Gtk.Orientation.HORIZONTAL, 0);

        window.present ();

        load_text_file ("example.txt");
    }

    private void load_text_file (string file_path) {
        try {
            string content = GLib.FileUtils.get_contents (file_path);
            var buffer = this.text_view.get_buffer ();
            buffer.set_text (content);
        } catch (Error e) {
            stderr.printf ("Error loading file: %s\n", e.message);
        }
    }

    public static int main (string[] args) {
        var app = new TextFileViewerSample ();
        return app.run (args);
    }
}