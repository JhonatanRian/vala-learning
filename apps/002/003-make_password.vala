public const string UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
public const string LOWERCASE = "abcdefghijklmnopqrstuvwxyz";
public const string NUMBERS = "0123456789";
public const string SPECIAL = "!@#$%^&*()_+-=[]{}|;:,.<>?";

public errordomain PasswordError {
    INVALID_LENGTH,
}

public int randon_index(int max) {
    return Random.int_range(0, max);
}

public string make_password(
    int length,
    bool use_uppercase,
    bool use_numbers,
    bool use_special,
    bool use_lowercase = true)
    throws PasswordError {

    if (length < 4) {
        throw new PasswordError.INVALID_LENGTH("Password length must be at least 4 to include all character types.");
    }
    if (length > 32) {
        throw new PasswordError.INVALID_LENGTH("Password length must not exceed 32 characters.");
    }

    var category_types = new HashTable<string, string> (str_hash, str_equal);
    if (use_uppercase) category_types.insert("uppercase", UPPERCASE);
    if (use_lowercase) category_types.insert("lowercase", LOWERCASE);
    if (use_numbers) category_types.insert("numbers", NUMBERS);
    if (use_special) category_types.insert("special", SPECIAL);

    var keys_types = category_types.get_keys_as_array();
    var builder = new StringBuilder ();

    foreach (var value in category_types.get_values()) {
        var char_index = randon_index(value.length);
        builder.append_c(value[char_index]);
    }

    while (builder.str.length < length) {
        var category_type_id = keys_types[randon_index(keys_types.length)];
        var chars = category_types.lookup(category_type_id);
        var char_index = randon_index(chars.length);
        builder.append_c(chars[char_index]);
    }

    return builder.str;
}

public void main(){
    while (true){
        try {
            print("\033[2J\033[H");
            print("\n=== Password Generator ===\n");
            print("press Ctrl+C to exit\n\n");
            print("Enter desired password length (4-32): ");
            var input = stdin.read_line().strip();
            int length = int.parse(input);

            if (length < 4 || length > 32) {
                throw new PasswordError.INVALID_LENGTH("Password length must be between 4 and 32.");
            }

            print("Enter whether to use uppercase letters (true/false): ");
            var use_uppercase = bool.parse(stdin.read_line().strip());

            print("Enter whether to use numbers (true/false): ");
            var use_numbers = bool.parse(stdin.read_line().strip());

            print("Enter whether to use special characters (true/false): ");
            var use_special = bool.parse(stdin.read_line().strip());

            print("\033[2J\033[H");
            print("Generating password...\n\n");

            var password = make_password(length, use_uppercase, use_numbers, use_special);
            print("\n------------------------------\n");
            print(@"Generated Password: $(password)");
            print("\n------------------------------\n");
            print("Press Enter to continue...");
            stdin.read_line().strip();

        } catch (Error e) {
            print("Invalid input. Please enter a number between 4 and 32.\n");
            continue;
        }
    }
}
