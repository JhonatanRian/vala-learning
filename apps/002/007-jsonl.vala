public abstract class Serializable : Object {

    public GLib.VariantDict serialize () {
        var dict = new GLib.VariantDict ();

        foreach (ParamSpec prop in ((GLib.Object) this).get_class ().list_properties ()) {
            GLib.Value value = GLib.Value (prop.value_type);
            get_property (prop.name, ref value);

            if (prop.value_type == typeof (string)) {
                dict.insert_value (prop.name, new GLib.Variant.string ((string) value));
            } else if (prop.value_type == typeof (int)) {
                dict.insert_value (prop.name, new GLib.Variant.int32 ((int) value));
            } else if (prop.value_type == typeof (int64)) {
                dict.insert_value (prop.name, new GLib.Variant.int64 ((int64) value));
            } else if (prop.value_type == typeof (uint)) {
                dict.insert_value (prop.name, new GLib.Variant.uint32 ((uint) value));
            } else if (prop.value_type == typeof (bool)) {
                dict.insert_value (prop.name, new GLib.Variant.boolean ((bool) value));
            } else if (prop.value_type == typeof (double)) {
                dict.insert_value (prop.name, new GLib.Variant.double ((double) value));
            } else if (prop.value_type == typeof (float)) {
                dict.insert_value (prop.name, new GLib.Variant.double ((double) (float) value));
            } else {
                // Para tipos não suportados, tenta converter para string
                dict.insert_value (prop.name, new GLib.Variant.string (value.strdup_contents ()));
            }
        }

        return dict;
    }

    public void deserialize (GLib.VariantDict data) throws Error {
        foreach (ParamSpec prop in ((GLib.Object) this).get_class ().list_properties ()) {
            var v = data.lookup_value (prop.name, null);
            if (v == null) {
                print ("Aviso: Propriedade '%s' não encontrada nos dados\n", prop.name);
                continue;
            }
            GLib.Value val = GLib.Value (prop.value_type);

            if (prop.value_type == typeof (string)) {
                val.set_string (v.get_string ());
            } else if (prop.value_type == typeof (int)) {
                val.set_int ((int) v.get_int32 ());
            } else if (prop.value_type == typeof (int64)) {
                val.set_int64 (v.get_int64 ());
            } else if (prop.value_type == typeof (uint)) {
                val.set_uint (v.get_uint32 ());
            } else if (prop.value_type == typeof (bool)) {
                val.set_boolean (v.get_boolean ());
            } else if (prop.value_type == typeof (double)) {
                val.set_double (v.get_double ());
            } else if (prop.value_type == typeof (float)) {
                val.set_float ((float) v.get_double ());
            }

            set_property (prop.name, val);
        }
    }

    public string to_json_like () {
        var variant = serialize ();
        var sb = new StringBuilder ();

        sb.append ("{\n");

        bool first = true;

        foreach (ParamSpec prop in ((GLib.Object) this).get_class ().list_properties ()) {
            if (!first)sb.append_printf (",\n");
            first = false;

            var v = variant.lookup_value (prop.name, null);
            sb.append (@"  \"$(prop.name)\": ");

            if (v.is_of_type (GLib.VariantType.STRING)) {
                sb.append_printf ("\"%s\"", v.get_string ().replace ("\"", "\\\""));
            } else if (v.is_of_type (GLib.VariantType.INT16)) {
                sb.append_printf ("%d", v.get_int16 ());
            } else if (v.is_of_type (GLib.VariantType.INT32)) {
                sb.append_printf ("%d", v.get_int32 ());
            } else if (v.is_of_type (GLib.VariantType.INT64)) {
                sb.append_printf ("%lld", v.get_int64 ());
            } else if (v.is_of_type (GLib.VariantType.UINT32)) {
                sb.append_printf ("%u", v.get_uint32 ());
            } else if (v.is_of_type (GLib.VariantType.BOOLEAN)) {
                sb.append_printf ("%s", v.get_boolean () ? "true" : "false");
            } else if (v.is_of_type (GLib.VariantType.DOUBLE)) {
                sb.append_printf ("%f", v.get_double ());
            } else {
                sb.append_printf ("\"%s\"", "");
            }
        }

        sb.append ("\n}");

        return sb.str;
    }
}

public class Pessoa : Serializable {
    public string nome { get; set; }
    public int64 id { get; set; }
    public string email { get; set; }

    public Pessoa (string nome = "", int64 id = 0, string email = "") {
        this.nome = nome;
        this.id = id;
        this.email = email;
    }
}

public static void main (string[] args) {
    var pessoa = new Pessoa ("Jhonatan Rian", 224234234243423425, "jhonatan@example.com");

    print ("=== Serialização ===\n");
    var variant = pessoa.serialize ();
    print ("Variant serializado\n");

    print ("\n=== Representação JSON-like ===\n");
    print ("%s\n", pessoa.to_json_like ());

    print ("\n=== Desserialização ===\n");
    var pessoa2 = new Pessoa ();
    try {
        pessoa2.deserialize (variant);
        print ("Pessoa desserializada:\n");
        print ("Nome: %s\n", pessoa2.nome);
        print ("Id: %lld\n", pessoa2.id);
        print ("Email: %s\n", pessoa2.email);
    } catch (Error e) {
        print ("Erro na desserialização: %s\n", e.message);
    }
}