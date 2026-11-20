# P4-T3 tokenizer lint

Timestamp: 2026-10-19T04-30
Command: `poetry run python -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/csharp_tokens.py tests/discovery_runtime/analyzer/test_csharp_tokens.py`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
B010 [*] Do not call `setattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\discovery_runtime\analyzer\test_csharp_tokens.py:200:9
    |
198 |     token = tokenize_csharp("Name")[0]
199 |     with pytest.raises(FrozenInstanceError):
200 |         setattr(token, "line", 2)
    |         ^^^^^^^^^^^^^^^^^^^^^^^^^
    |
help: Replace `setattr` with assignment

Found 1 error.
[*] 1 fixable with the `--fix` option.

```
