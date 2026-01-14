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
            string str_value = json.substring (start, i);
            tokens.append_val (new Token (TypeToken.TYPE_STRING, str_value));
            i++;
            break;
        default:
            if (c.isdigit () || c == '-') {
                int start = i;
                while (i < json.length && (json[i].isdigit () || json[i] == '.' || json[i] == '-' || json[i] == '+' || json[i] == 'e' || json[i] == 'E')) {
                    i++;
                }
                string num_value = json.substring (start, i);
                tokens.append_val (new Token (TypeToken.TYPE_NUMBER, num_value));
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
        var token = current_token ();
        if (token != null) {
            return tokens;
        }
        throw new JsonError.PARSE_ERROR ("No more tokens");
    }

    public GLib.Value parse_value () throws JsonError {
        var token = current_token ();

        switch (token.type) {
        case TypeToken.TYPE_LBRACE:
            return parse_object ();
        case TypeToken.TYPE_LBRACKET:
            return parse_array ();
        case TypeToken.TYPE_STRING:
            consume ();
            return token.value;
        case TypeToken.TYPE_NUMBER:
            consume ();
            if (token.value.contains (".")) {
                var val = GLib.Value (typeof (double));
                val.set_double (double.parse (token.value));
                return val;
            } else {
                var val = GLib.Value (typeof (int));
                val.set_int (int.parse (token.value));
                return val;
            }
        case TypeToken.TYPE_TRUE:
            consume ();
            var val = GLib.Value (typeof (bool));
            val.set_boolean (true);
            return val;
        case TypeToken.TYPE_FALSE:
            consume ();
            var val = GLib.Value (typeof (bool));
            val.set_boolean (false);
            return val;
        case TypeToken.TYPE_NULL:
            consume ();
            return GLib.Value (typeof (void));
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

    private GLib.Value parse_object () throws JsonError {
        VariantDict dict = new VariantDict ();
        consume (TypeToken.TYPE_LBRACE);

        if (current_token () == null) {
            throw new JsonError.PARSE_ERROR ("Objeto incompleto");
        }

        if (current_token ().type == TypeToken.TYPE_RBRACE) {
            consume (TypeToken.TYPE_RBRACE);
            return dict.end ();
        }

        while (true) {
            var key_token = consume (TypeToken.TYPE_STRING);
            var key_string = key_token.value;

            consume (TypeToken.TYPE_COLON);

            var value = parse_value ();
            dict.insert_value (key_string, value);

            if (current_token ().type == TypeToken.TYPE_COMMA) {
                consume (TypeToken.TYPE_COMMA);
            } else if (current_token ().type == TypeToken.TYPE_RBRACE) {
                break;
            } else {
                throw new JsonError.PARSE_ERROR ("Esperado ',' ou '}'");
            }
        }

        consume (TypeToken.TYPE_RBRACE);
        return dict.end ();
    }

    private GLib.Value parse_array () throws JsonError {
        Array<GLib.Value> array = new Array<GLib.Value> ();
        consume (TypeToken.TYPE_LBRACKET);

        if (current_token ().type == TypeToken.TYPE_RBRACKET) {
            consume (TypeToken.TYPE_RBRACKET);
            return array;
        }
        ;

        while (true) {
            var value = parse_value ();
            array.append_val (value);

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
        "autor": "Gemini",
        "nulo": null
    }
}
""";
    var tokens = lexer (json_input);
    var parser = new JsonParser (tokens);
    try {
        var result = parser.parse_value ();
        print ("Parsed JSON successfully.\n");
    } catch (JsonError e) {
        print ("Error parsing JSON: %s\n", e.message);
    }
}