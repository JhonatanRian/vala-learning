using GLib;

public class PasswordGenerator : Object {
    private static Rand rng;

    public static void init_rng() {
        if (rng == null) {
            int64 now = get_real_time();
            
            uint32 seed = (uint32) (now ^ (now >> 32));
            
            rng = new Rand.with_seed(seed);
        }
    }

    public static int random_index(int max) {
        if (rng == null) init_rng();
        return rng.int_range(0, max);
    }

    public static string make_password(int length) {
        string charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*";
        string result = "";
        
        for (int i = 0; i < length; i++) {
            int idx = random_index(charset.length);
            result += charset[idx].to_string();
        }
        
        return result;
    }
}

void main() {
    PasswordGenerator.init_rng();
    string pass = PasswordGenerator.make_password(12);
    print("Senha Gerada: %s\n", pass);
}