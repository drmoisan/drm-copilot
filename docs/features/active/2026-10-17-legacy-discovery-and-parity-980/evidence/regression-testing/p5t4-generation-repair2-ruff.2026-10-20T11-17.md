# P5-T4 generation ruff

Timestamp: 2026-10-20T11-17

Command: `poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/acceptance_generation.py packages/discovery-runtime/src/drm_copilot_discovery/acceptance_generation_context.py tests/discovery_runtime/test_acceptance_generation.py tests/discovery_runtime/test_acceptance_decisions.py tests/discovery_runtime/test_acceptance_generation_limits.py`

EXIT_CODE: 1

Output Summary: FAIL or changed bytes; 1.210 seconds.

```text
B009 [*] Do not call `getattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\discovery_runtime\test_acceptance_generation_limits.py:166:9
    |
164 |     generation = cast(
165 |         "Expansion",
166 |         getattr(generation_module, "_Generation")(
    |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
167 |             context, "target-acceptance", (), (), ()
168 |         ),
    |
help: Replace `getattr` with attribute access

Found 1 error.
[*] 1 fixable with the `--fix` option.

```
