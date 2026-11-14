# Golden Identity Vectors ([P1-T1])

Timestamp: 2026-11-03T11-51
Command: sh SCRATCH/issue-1020-golden.sh (each V1..V4 string piped through `printf '%s\n' <string> | sha256sum`; D1 piped through `printf 'def handler():\n    return 1\n' | sha256sum`)
EXIT_CODE: 0
Output Summary: Four element-identifier vectors (V1..V4) and one declaration-lines digest vector (D1) computed by an independent route (POSIX sha256sum, not the PowerShell modules). Each digest is 64 lowercase hex characters.

Rule: for V1..V4 the hashed bytes are the canonical string followed by one LF; for D1 the hashed bytes are the canonical declaration text exactly (28 bytes, already ending in LF). The element identifier of each V vector is `<kind>-<digest>`.

## Element identifier vectors

| Vector | Canonical string (hashed with one trailing LF) | SHA-256 (hex) | Element identifier |
|---|---|---|---|
| V1 | `{"declaration":"tool docs inventory","kind":"cli-command","path":"src/example_pkg/cli.py"}` | `b9cda1283b765831a04bf07223320d70c1f07de9da312b21731f40e8790cf00a` | `cli-command-b9cda1283b765831a04bf07223320d70c1f07de9da312b21731f40e8790cf00a` |
| V2 | `{"declaration":"tool docs inventory --analyzer","kind":"cli-option","path":"src/example_pkg/cli.py"}` | `4dac82ff130bd249bc5405947e1c0d29de1b7374d2aba5fb490213d36cd1ba85` | `cli-option-4dac82ff130bd249bc5405947e1c0d29de1b7374d2aba5fb490213d36cd1ba85` |
| V3 | `{"declaration":"GET /items/{id}","kind":"http-route","path":"src/example_pkg/routes.py"}` | `953dac18dfc986f87330003d45e387536b6fa02b8b34b64b49245a2482d5136f` | `http-route-953dac18dfc986f87330003d45e387536b6fa02b8b34b64b49245a2482d5136f` |
| V4 | `{"declaration":"tool.settings.timeout","kind":"config-key","path":"config/settings.json"}` | `c861a7d842f18ab03e7ad64dbca3ac7283e51566286b3810ae6163f096fcc69b` | `config-key-c861a7d842f18ab03e7ad64dbca3ac7283e51566286b3810ae6163f096fcc69b` |

## Declaration-lines digest vector

| Vector | Source text | Range | Canonical declaration text | SHA-256 (hex) |
|---|---|---|---|---|
| D1 | `a = 1<CR><LF>def handler():<CR><LF>    return 1<CR><LF>b = 2` (no final newline) | `@(2, 3)` | `def handler():<LF>    return 1<LF>` | `4b1f1972e4baea3016f1021a3cfe9ca6e6076ca82a0ae05a9b26de11403e24ea` |

These values are the ones used by the examples ([P1-T3]..[P1-T5]) and by `DocsSurface.Tests.ps1` ([P2-T3]).
