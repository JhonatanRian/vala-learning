enum TypeToken {
    TYPE_STRING,
    TYPE_NUMBER,
    TYPE_TRUE,
    TYPE_FALSE,
    TYPE_NULL,
    TYPE_LBRACE,
    TYPE_RBRACE,
    TYPE_LBRACKET,
    TYPE_RBRACKET,
    TYPE_COLON,
    TYPE_COMMA
}

const char LBRACE = '{';
const char RBRACE = '}';
const char LBRACKET = '[';
const char RBRACKET = ']';
const char COLON = ':';
const char COMMA = ',';
const char SPACE = ' ';
const char QUOTE = '"';
const char NEWLINE = '\n';
const char TAB = '\t';


class Token {
    public TypeToken type;
    public string value;

    public Token (TypeToken type, string value) {
        this.type = type;
        this.value = value;
    }
}

abstract class JsonValue {
    public abstract string to_string ();
}

class JsonString : JsonValue {
    public string value;

    public JsonString (string value) {
        this.value = value;
    }

    public override string to_string () {
        return @"\"$(value)\"";
    }
}

class JsonNumber : JsonValue {
    public string value;

    public JsonNumber (string value) {
        this.value = value;
    }

    public override string to_string () {
        return value;
    }
}

class JsonBool : JsonValue {
    public bool value;

    public JsonBool (bool value) {
        this.value = value;
    }

    public override string to_string () {
        return value ? "true" : "false";
    }
}

class JsonNull : JsonValue {
    public override string to_string () {
        return "null";
    }
}

class JsonArray : JsonValue {
    public Array<JsonValue> items;

    public JsonArray () {
        items = new Array<JsonValue> ();
    }

    public void add (JsonValue value) {
        items.append_val (value);
    }

    public override string to_string () {
        var result = new StringBuilder ("[");
        for (int i = 0; i < items.length; i++) {
            result.append (items.index (i).to_string ());
            if (i < items.length - 1) {
                result.append (", ");
            }
        }
        result.append ("]");
        return result.str;
    }
}

class JsonObject : JsonValue {
    public GLib.HashTable<string, JsonValue> properties;

    public JsonObject () {
        properties = new GLib.HashTable<string, JsonValue> (str_hash, str_equal);
    }

    public void set (string key, JsonValue value) {
        properties.insert (key, value);
    }

    public override string to_string () {
        var result = new StringBuilder ("{");
        var keys = properties.get_keys ();
        for (int i = 0; i < keys.length (); i++) {
            string key = keys.nth_data (i);
            var value = properties.lookup (key);
            result.append (@"\"$(key)\": $(value.to_string ())");
            if (i < keys.length () - 1) {
                result.append (", ");
            }
        }
        result.append ("}");
        return result.str;
    }
}

Array<Token> lexer (string json) {
    var tokens = new Array<Token> ();
    int i = 0;
    while (i < json.length) {
        char c = json[i];
        switch (c) {
        case LBRACE:
            tokens.append_val (new Token (TypeToken.TYPE_LBRACE, "{"));
            i++;
            break;
        case RBRACE:
            tokens.append_val (new Token (TypeToken.TYPE_RBRACE, "}"));
            i++;
            break;
        case LBRACKET:
            tokens.append_val (new Token (TypeToken.TYPE_LBRACKET, "["));
            i++;
            break;
        case RBRACKET:
            tokens.append_val (new Token (TypeToken.TYPE_RBRACKET, "]"));
            i++;
            break;
        case COLON:
            tokens.append_val (new Token (TypeToken.TYPE_COLON, ":"));
            i++;
            break;
        case COMMA:
            tokens.append_val (new Token (TypeToken.TYPE_COMMA, ","));
            i++;
            break;
        case SPACE:
        case NEWLINE:
        case TAB:
            i++;
            break;
        case QUOTE:
            int start = i + 1;
            i++;
            while (i < json.length && json[i] != QUOTE) {
                i++;
            }
            string str_value = json.substring (start, i - start);
            tokens.append_val (new Token (TypeToken.TYPE_STRING, str_value));
            i++;
            break;
        default:
            if (c.isdigit () || c == '-') {
                int start = i;
                while (i < json.length && (json[i].isdigit () || json[i] == '.' || json[i] == '-' || json[i] == '+' || json[i] == 'e' || json[i] == 'E')) {
                    i++;
                }
                string num_value = json.substring (start, i - start);
                tokens.append_val (new Token (TypeToken.TYPE_NUMBER, num_value));
            } else if (c.isalpha ()) {
                int start = i;
                while (i < json.length && json[i].isalpha ()) {
                    i++;
                }
                string word = json.substring (start, i - start);
                if (word == "true") {
                    tokens.append_val (new Token (TypeToken.TYPE_TRUE, "true"));
                } else if (word == "false") {
                    tokens.append_val (new Token (TypeToken.TYPE_FALSE, "false"));
                } else if (word == "null") {
                    tokens.append_val (new Token (TypeToken.TYPE_NULL, "null"));
                }
            } else {
                i++;
            }
            break;
        }
    }
    return tokens;
}

errordomain JsonError {
    PARSE_ERROR
}

class JsonParser {
    Array<Token> tokens;
    int position = 0;

    public JsonParser (Array<Token> tokens) {
        this.tokens = tokens;
    }

    public Token current_token () throws JsonError {
        if (position < tokens.length) {
            return tokens.index (position);
        }
        throw new JsonError.PARSE_ERROR ("No more tokens");
    }

    public JsonValue parse_value () throws JsonError {
        var token = current_token ();

        switch (token.type) {
        case TypeToken.TYPE_LBRACE:
            return parse_object ();
        case TypeToken.TYPE_LBRACKET:
            return parse_array ();
        case TypeToken.TYPE_STRING:
            consume ();
            return new JsonString (token.value);
        case TypeToken.TYPE_NUMBER:
            consume ();
            return new JsonNumber (token.value);
        case TypeToken.TYPE_TRUE:
            consume ();
            return new JsonBool (true);
        case TypeToken.TYPE_FALSE:
            consume ();
            return new JsonBool (false);
        case TypeToken.TYPE_NULL:
            consume ();
            return new JsonNull ();
        default:
            throw new JsonError.PARSE_ERROR (@"Token inesperado: $(token.value)");
        }
    }

    private Token consume (TypeToken? expected_type = null) throws JsonError {
        var token = current_token ();
        if (expected_type != null && token.type != expected_type) {
            throw new JsonError.PARSE_ERROR (@"Token inesperado: $(token.value), esperado: $(expected_type.to_string ())");
        }
        position++;
        return token;
    }

    private JsonValue parse_object () throws JsonError {
        JsonObject obj = new JsonObject ();
        consume (TypeToken.TYPE_LBRACE);

        if (current_token () == null) {
            throw new JsonError.PARSE_ERROR ("Objeto incompleto");
        }

        if (current_token ().type == TypeToken.TYPE_RBRACE) {
            consume (TypeToken.TYPE_RBRACE);
            return obj;
        }

        while (true) {
            var key_token = consume (TypeToken.TYPE_STRING);
            var key_string = key_token.value;

            consume (TypeToken.TYPE_COLON);

            var value = parse_value ();
            obj.set (key_string, value);

            if (current_token ().type == TypeToken.TYPE_COMMA) {
                consume (TypeToken.TYPE_COMMA);
            } else if (current_token ().type == TypeToken.TYPE_RBRACE) {
                break;
            } else {
                throw new JsonError.PARSE_ERROR ("Esperado ',' ou '}'");
            }
        }

        consume (TypeToken.TYPE_RBRACE);
        return obj;
    }

    private JsonValue parse_array () throws JsonError {
        JsonArray array = new JsonArray ();
        consume (TypeToken.TYPE_LBRACKET);

        if (current_token ().type == TypeToken.TYPE_RBRACKET) {
            consume (TypeToken.TYPE_RBRACKET);
            return array;
        }

        while (true) {
            var value = parse_value ();
            array.add (value);

            if (current_token ().type == TypeToken.TYPE_COMMA) {
                consume (TypeToken.TYPE_COMMA);
            } else if (current_token ().type == TypeToken.TYPE_RBRACKET) {
                break;
            } else {
                throw new JsonError.PARSE_ERROR ("Esperado ',' ou ']'");
            }
        }

        consume (TypeToken.TYPE_RBRACKET);
        return array;
    }
}

public void main (string[] args) {
    string json_input = """
{
    "projeto": "Micro Compiler",
    "versao": 1.0,
    "ativo": true,
    "lista": [10, 20, "trinta"],
    "nested": {
        "autor": "Jhonatan",
        "nulo": null
    }
}
""";
    var tokens = lexer (json_input);
    var parser = new JsonParser (tokens);
    try {
        JsonValue result = parser.parse_value ();
        print ("Parsed JSON successfully:\n");
        print ("%s\n", result.to_string ());
    } catch (JsonError e) {
        print ("Error parsing JSON: %s\n", e.message);
    }
}