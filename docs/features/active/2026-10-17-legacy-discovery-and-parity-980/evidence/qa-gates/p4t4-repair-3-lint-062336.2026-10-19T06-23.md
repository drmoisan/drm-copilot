# P4-T4 repair-3 lint

Timestamp: 2026-10-19T06-23
Command: `poetry run python -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/configuration.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/configuration_input.py tests/discovery_runtime/analyzer/test_configuration.py tests/discovery_runtime/analyzer/test_configuration_input.py`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
B009 [*] Do not call `getattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\discovery_runtime\analyzer\test_configuration.py:407:9
    |
405 |         "Callable[[InventoryCapture, InventoryInput, ConfigurationFormat, "
406 |         "tuple[ConfigurationKey, ...]], Analysis]",
407 |         getattr(configuration_module, "_project"),
    |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
408 |     )
    |
help: Replace `getattr` with attribute access

B009 [*] Do not call `getattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\discovery_runtime\analyzer\test_configuration_input.py:297:44
    |
295 |     """
296 |     parser_type = cast(
297 |         "type[configparser.ConfigParser]", getattr(input_module, "_IniParser")
    |                                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
298 |     )
299 |     original = parser_type.OPTCRE
    |
help: Replace `getattr` with attribute access

Found 2 errors.
[*] 2 fixable with the `--fix` option.

```
