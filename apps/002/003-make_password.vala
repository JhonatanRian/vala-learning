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

    var password_chars = new List<char> ();
    var category_types = new HashTable<string, string> (str_hash, str_equal);
    if (use_uppercase) category_types.insert("uppercase", UPPERCASE);
    if (use_lowercase) category_types.insert("lowercase", LOWERCASE);
    if (use_numbers) category_types.insert("numbers", NUMBERS);
    if (use_special) category_types.insert("special", SPECIAL);

    var keys_types = category_types.get_keys_as_array();
    var builder = new StringBuilder ();

    while (builder.str.length < length) {
        var category_type_id = keys_types[randon_index(keys_types.length)];
        print("Selected category: %s\n", category_type_id);
        var chars = category_types.lookup(category_type_id);
        var char_index = randon_index(chars.length);
        builder.append_c(chars[char_index]);
    }

    return builder.str;
}

public void main(){
    try {
        var password = make_password(12, true, true, true);
        print(@"Generated Password: $(password)");
    } catch (PasswordError e) {
        print(@"Error: %s", e.message);
    }
}
