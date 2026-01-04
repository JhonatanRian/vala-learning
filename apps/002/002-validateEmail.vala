public bool validate_email(string email) {
    // Simple regex pattern for validating email addresses
    string pattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$";
    try {
        Regex regex = new Regex(pattern);
        return regex.match(email);
    } catch (RegexError e) {
        stderr.printf("Error compiling regex: %s\n", e.message);
        return false;
    }
}

// Command-line application to validate email addresses
// class Program : Object {
// public static int main(string[] args) {
// if (args.length < 2) {
// stdout.printf("Usage: %s <email>\n", args[0]);
// return 1;
// }

// string[] emails = args;
// for (int i = 1; i < emails.length; i++) {
// string email = emails[i];
// if (validate_email(email)) {
// stdout.printf(@"The email $(email) is valid.\n");
// } else {
// stdout.printf(@"The email $(email) is invalid.\n");
// }
// }
// return 0;
// }
// }

class Program : Object {
    public static int main(string[] args) {
        var emails = new GLib.List<string> ();

        while (true) {
            stdout.printf("Enter an email address to validate (or type 'exit' to quit): ");
            string? input = stdin.read_line();
            if (input == null || input.strip().down() == "exit") {
                break;
            }
            emails.append(input.strip());
        }

        emails.foreach((email) => {
            if (validate_email(email)) {
                stdout.printf(@"The email $(email) is valid.\n");
            } else {
                stdout.printf(@"The email $(email) is invalid.\n");
            }
        });
        return 0;
    }
}