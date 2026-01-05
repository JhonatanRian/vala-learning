public const string UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
public const string LOWERCASE = "abcdefghijklmnopqrstuvwxyz";
public const string NUMBERS = "0123456789";
public const string SPECIAL = "!@#$%^&*()_+-=[]{}|;:,.<>?";

errordomain PasswordError {
    INVALID_LENGTH,
}

public int randon_index(int max) {
    return Random.int_range(0, max);
}

public string make_password(int length, bool use_uppercase,
                            bool use_lowercase, bool use_numbers, bool use_special) {

    if (length < 4) {
        throw new PasswordError.INVALID_LENGTH("Password length must be at least 4 to include all character types.");
    }
    if (length > 32) {
        throw new PasswordError.INVALID_LENGTH("Password length must not exceed 32 characters.");
    }

    var password_chars = new List<char> ();
    var category_types = new HashTable<string, string> (str_hash, str_equal);
    if (use_uppercase){
        category_types["uppercase"] = UPPERCASE;
    }
    if (use_lowercase){
        category_types["lowercase"] = LOWERCASE;
    }
    if (use_numbers){
        category_types["numbers"] = NUMBERS;
    }
    if (use_special){
        category_types["special"] = SPECIAL;
    }

    var keys_types = category_types.get_keys_as_array();

    while (password_chars.length() < length) {
        var category_type = keys_types[randon_index(keys_types.length())];
        var chars = category_types[category_type];
        var char = chars[randon_index(chars.length())];
        password_chars.append(char);
    }


    return string.join("", password_chars);
}
