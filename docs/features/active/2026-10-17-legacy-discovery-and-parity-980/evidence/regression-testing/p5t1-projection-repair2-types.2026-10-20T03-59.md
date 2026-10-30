# p5t1-projection-repair2-types

Timestamp: 2026-10-20T03-59
Command: poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/validation.py tests/discovery_runtime/test_validation_modes.py tests/discovery_runtime/test_agent_output.py tests/discovery_runtime/test_mutation_plan.py
EXIT_CODE: 1
Output Summary: scoped types; duration 2.355 seconds. Raw stdout/stderr hashes and SCRATCH-relative locations are separate from sanitized presentation.

```text
.\tests\discovery_runtime\test_agent_output.py
  .\tests\discovery_runtime\test_agent_output.py:155:13 - error: Argument of type "str" cannot be assigned to parameter "key" of type "Literal['validate_coverage', 'validate_dimensions', 'validate_acceptance']" in function "__getitem__"
    Type "str" is not assignable to type "Literal['validate_coverage', 'validate_dimensions', 'validate_acceptance']"
      "str" is not assignable to type "Literal['validate_coverage']"
      "str" is not assignable to type "Literal['validate_dimensions']"
      "str" is not assignable to type "Literal['validate_acceptance']" (reportArgumentType)
  .\tests\discovery_runtime\test_agent_output.py:155:13 - error: Argument of type "str" cannot be assigned to parameter "key" of type "Literal['validate_coverage', 'validate_dimensions', 'validate_acceptance']" in function "__setitem__"
    Type "str" is not assignable to type "Literal['validate_coverage', 'validate_dimensions', 'validate_acceptance']"
      "str" is not assignable to type "Literal['validate_coverage']"
      "str" is not assignable to type "Literal['validate_dimensions']"
      "str" is not assignable to type "Literal['validate_acceptance']" (reportArgumentType)
2 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`
```
