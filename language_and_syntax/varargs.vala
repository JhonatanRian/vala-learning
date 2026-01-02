//  void print_args(string name, ...) {
//      var args = va_list();
//      stdout.printf("Function Name: %s\n", name);
//      stdout.printf("Arguments:\n");

//      while (true) {
//          string? arg = args.arg();
//          if (arg == null) {
//              break;
//          }
//          stdout.printf(" - %s\n", arg.to_string());
//      }
//  }

void print_args(string name, GLib.Value[] args) {
    var args = va_list();
    stdout.printf("Function Name: %s\n", name);
    stdout.printf("Arguments:\n");

    foreach (var arg in args) {
        stdout.printf(" - %s\n", arg.to_string());
    }
}

void main() {
    print_args("TestFunction", "1", "2.5", "three", "true");
}
