public static void main (string[] args) {
    KeyFile file = new KeyFile ();
    file.set_list_separator (',');
    try {
        file.load_from_file ("config_test.ini", GLib.KeyFileFlags.NONE);
    } catch (GLib.Error e) {
        print ("Erro ao carregar: %s\n", e.message);
    }

    try {
        bool feat = file.get_boolean ("features", "enable_feature_y");
        print(feat ? "Feature Y está habilitada\n" : "Feature Y está desabilitada\n");
    } catch (GLib.Error e) {
        print ("A chave 'enable_feature_y' não existe em 'features'\n");
    }
   
}