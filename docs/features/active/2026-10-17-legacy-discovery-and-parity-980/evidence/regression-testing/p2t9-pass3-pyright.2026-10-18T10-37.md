# p2t9-pass3-pyright

Timestamp: 2026-10-18T10-37
Command: poetry run pyright
EXIT_CODE: 1
Output Summary:     Argument type is "list[dict[str, str | list[Unknown] | None]]" (reportUnknownArgumentType); 4 errors, 0 warnings, 0 informations; WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).; Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`

Working directory: .
Started: 2026-10-18T10:37:21.821136+00:00
Duration seconds: 8.285
Phase: P2-T9 validation composition and role outputs; focused task verification.

## Captured output

```text
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument of type "str" cannot be assigned to parameter "key" of type "ArtifactKey" in function "__getitem__"
    Type "str" is not assignable to type "ArtifactKey"
      "str" is not assignable to type "Literal['root']"
      "str" is not assignable to type "Literal['profile']"
      "str" is not assignable to type "Literal['scope']"
      "str" is not assignable to type "Literal['coverage_ledger']"
      "str" is not assignable to type "Literal['unspecified_behaviors']"
      "str" is not assignable to type "Literal['product_decisions']"
      "str" is not assignable to type "Literal['parity_matrix']" (reportArgumentType)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument of type "str" cannot be assigned to parameter "gate" of type "CompletionGate" in function "required"
    Type "str" is not assignable to type "CompletionGate"
      "str" is not assignable to type "Literal['require_confirmed_scope']"
      "str" is not assignable to type "Literal['require_current_inventory']"
      "str" is not assignable to type "Literal['require_all_dispositions']"
      "str" is not assignable to type "Literal['require_feature_evidence']"
      "str" is not assignable to type "Literal['require_acceptance_scenarios']"
      "str" is not assignable to type "Literal['require_runtime_for_declared_features']"
      "str" is not assignable to type "Literal['block_on_unresolved_required_behavior']"
    ... (reportArgumentType)
EXTERNAL_PATH
  EXTERNAL_PATH - error: Argument of type "bool" cannot be assigned to parameter "planning" of type "str" in function "mode_profile"
    "bool" is not assignable to "str" (reportArgumentType)
  EXTERNAL_PATH - error: Argument type is partially unknown
    Argument corresponds to parameter "repositories" in function "profile_with"
    Argument type is "list[dict[str, str | list[Unknown] | None]]" (reportUnknownArgumentType)
4 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
