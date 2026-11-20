# Native corpus census ([P3-T3])

Timestamp: 2026-11-04T16-10
Command: sh SCRATCH/issue-1031-run.sh issue-1031-json-check.ps1 issue-1031-json-check.out (ConvertFrom-DocsJsonText over tests/scripts/claude-lib/docs/fixtures/python-native-corpus.json, then a listing of diagnostic_classes and native_only_elements); a byte scan of the same file for CR
EXIT_CODE: 0
Output Summary: ConvertFrom-DocsJsonText returns 0 findings; the file holds no CR byte. diagnostic_classes has 57 rows, equal to the 57 expected_diagnostics of the four identifiers in the 1022 corpus (retained 39, resolved 1, scanner-only 17); native_only_elements has 13 rows; native_inputs has 3 files; console_scripts has 5 entries (one per supported script-table entry of the 1022 corpus pyproject.toml).

## diagnostic_classes (code | path | analyzer_id | class)

- PYTHON_ENCODING_UNSUPPORTED | src/pkg/lex_encoding.py | python-architecture | scanner-only
- PYTHON_ENCODING_UNSUPPORTED | src/pkg/lex_encoding.py | python-cli | scanner-only
- PYTHON_ENCODING_UNSUPPORTED | src/pkg/lex_encoding.py | python-http | scanner-only
- PYTHON_ENCODING_UNSUPPORTED | src/pkg/lex_encoding.py | python-public-api | scanner-only
- PYTHON_LEXER_UNTERMINATED | src/pkg/lex_unterminated.py | python-architecture | scanner-only
- PYTHON_LEXER_UNTERMINATED | src/pkg/lex_unterminated.py | python-cli | scanner-only
- PYTHON_LEXER_UNTERMINATED | src/pkg/lex_unterminated.py | python-http | scanner-only
- PYTHON_LEXER_UNTERMINATED | src/pkg/lex_unterminated.py | python-public-api | scanner-only
- PYTHON_LEXER_UNCLASSIFIED | src/pkg/lex_unclassified.py | python-architecture | scanner-only
- PYTHON_LEXER_UNCLASSIFIED | src/pkg/lex_unclassified.py | python-cli | scanner-only
- PYTHON_LEXER_UNCLASSIFIED | src/pkg/lex_unclassified.py | python-http | scanner-only
- PYTHON_LEXER_UNCLASSIFIED | src/pkg/lex_unclassified.py | python-public-api | scanner-only
- PYTHON_INDENTATION_INVALID | src/pkg/lex_indent.py | python-architecture | scanner-only
- PYTHON_INDENTATION_INVALID | src/pkg/lex_indent.py | python-cli | scanner-only
- PYTHON_INDENTATION_INVALID | src/pkg/lex_indent.py | python-http | scanner-only
- PYTHON_INDENTATION_INVALID | src/pkg/lex_indent.py | python-public-api | scanner-only
- PYTHON_IMPORT_STAR_FRAMEWORK | src/pkg/lex_imports.py | python-architecture | retained
- PYTHON_IMPORT_STAR_FRAMEWORK | src/pkg/lex_imports.py | python-cli | retained
- PYTHON_IMPORT_STAR_FRAMEWORK | src/pkg/lex_imports.py | python-http | retained
- PYTHON_IMPORT_STAR_FRAMEWORK | src/pkg/lex_imports.py | python-public-api | retained
- PYTHON_IMPORT_NESTED_FRAMEWORK | src/pkg/lex_imports.py | python-architecture | retained
- PYTHON_IMPORT_NESTED_FRAMEWORK | src/pkg/lex_imports.py | python-cli | retained
- PYTHON_IMPORT_NESTED_FRAMEWORK | src/pkg/lex_imports.py | python-http | retained
- PYTHON_IMPORT_NESTED_FRAMEWORK | src/pkg/lex_imports.py | python-public-api | retained
- PYTHON_BINDING_AMBIGUOUS | src/pkg/lex_imports.py | python-architecture | retained
- PYTHON_BINDING_AMBIGUOUS | src/pkg/lex_imports.py | python-cli | retained
- PYTHON_BINDING_AMBIGUOUS | src/pkg/lex_imports.py | python-http | retained
- PYTHON_BINDING_AMBIGUOUS | src/pkg/lex_imports.py | python-public-api | retained
- PYTHON_IDENTIFIER_NON_ASCII | src/pkg/api_naming.py | python-public-api | resolved
- CLI_DYNAMIC_REGISTRATION | src/pkg/_cli_argparse_diag.py | python-cli | retained
- CLI_REGISTRATION_IN_LOOP | src/pkg/_cli_argparse_diag.py | python-cli | retained
- CLI_UNBOUND_REGISTRATION | src/pkg/_cli_argparse_diag.py | python-cli | retained
- CLI_PARENTS_UNRESOLVED | src/pkg/_cli_argparse_diag.py | python-cli | retained
- CLI_CUSTOM_CLASS | src/pkg/_cli_click_diag.py | python-cli | retained
- CLI_DECORATOR_INDIRECT | src/pkg/_cli_click_diag.py | python-cli | retained
- CLI_REGISTRATION_IN_LOOP | src/pkg/_cli_click_diag.py | python-cli | retained
- CLI_UNBOUND_REGISTRATION | src/pkg/_cli_click_diag.py | python-cli | retained
- CLI_CUSTOM_CLASS | src/pkg/_cli_typer_diag.py | python-cli | retained
- CLI_TYPER_PARAMETER_UNRESOLVED | src/pkg/_cli_typer_diag.py | python-cli | retained
- CLI_CONSOLE_SCRIPT_UNSUPPORTED | pyproject.toml | python-cli | scanner-only
- HTTP_PREFIX_DYNAMIC | src/pkg/_http_fastapi.py | python-http | retained
- HTTP_METHOD_VIEW_UNRESOLVED | src/pkg/_http_flask.py | python-http | retained
- HTTP_DYNAMIC_ROUTE | src/pkg/_http_diag.py | python-http | retained
- HTTP_ROUTE_IN_LOOP | src/pkg/_http_diag.py | python-http | retained
- HTTP_MOUNT_UNRESOLVED | src/pkg/_http_diag.py | python-http | retained
- HTTP_UNBOUND_ROUTE | src/pkg/_http_diag.py | python-http | retained
- HTTP_INCLUDE_UNRESOLVED | src/pkg/_http_diag.py | python-http | retained
- PUBLIC_API_STAR_IMPORT | src/pkg/api_all.py | python-public-api | retained
- PUBLIC_API_NAME_UNRESOLVED | src/pkg/api_all.py | python-public-api | retained
- PUBLIC_API_CONDITIONAL_DEFINITION | src/pkg/api_naming.py | python-public-api | retained
- PUBLIC_API_UNPACKING_TARGET | src/pkg/api_naming.py | python-public-api | retained
- PUBLIC_API_DYNAMIC_ALL | src/pkg/api_dynamic.py | python-public-api | retained
- PUBLIC_API_MODULE_NOT_IMPORTABLE | src/pkg/bad-name.py | python-public-api | retained
- ARCHITECTURE_DYNAMIC_IMPORT | src/pkg/arch.py | python-architecture | retained
- ARCHITECTURE_RELATIVE_IMPORT_UNRESOLVED | src/pkg/arch.py | python-architecture | retained
- ARCHITECTURE_RELATIVE_IMPORT_UNRESOLVED | src/toplevel.py | python-architecture | retained
- ARCHITECTURE_MODULE_NAME_INVALID | src/pkg/bad-name.py | python-architecture | retained

## native_only_elements (analyzer_id | kind | path | declaration)

- python-architecture | architecture-component | src/pkg/lex_encoding.py | pkg.lex_encoding
- python-public-api | public-symbol | src/pkg/lex_encoding.py | pkg.lex_encoding.x
- python-public-api | public-symbol | src/pkg/api_naming.py | pkg.api_naming.café
- python-cli | cli-command | native/escaped_cli.py | escaped
- python-cli | cli-option | native/escaped_cli.py | escaped --name
- python-http | http-route | native/escaped_http.py | GET /items
- python-public-api | public-symbol | native/escaped_cli.py | escaped_cli.escaped_command
- python-public-api | public-symbol | native/escaped_http.py | escaped_http.app
- python-public-api | public-symbol | native/escaped_http.py | escaped_http.list_items
- python-public-api | public-symbol | native/deep_brackets.py | deep_brackets.compute
- python-architecture | architecture-component | native/escaped_cli.py | escaped_cli
- python-architecture | architecture-component | native/escaped_http.py | escaped_http
- python-architecture | architecture-component | native/deep_brackets.py | deep_brackets

## Resolved constructs per identifier

- python-cli: the Click option written with an escaped printable character in native/escaped_cli.py (scanner: CLI_DYNAMIC_REGISTRATION; native: escaped --name).
- python-http: the FastAPI route path written with an escaped printable character in native/escaped_http.py (scanner: HTTP_DYNAMIC_ROUTE; native: GET /items).
- python-public-api: the non-ASCII function name in src/pkg/api_naming.py (scanner: PYTHON_IDENTIFIER_NON_ASCII; native: pkg.api_naming.café, the one resolved diagnostic_classes row) and deep_brackets.compute in native/deep_brackets.py.
- python-architecture: native/deep_brackets.py, nested 65 brackets deep (scanner: PYTHON_LEXER_UNCLASSIFIED for all four identifiers; native: component deep_brackets with one internal edge to escaped_cli).
