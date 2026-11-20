# p1t2-lint-pass1

Timestamp: 2026-10-18T04-48
Command: poetry run ruff check scripts/dev_tools/build_discovery_runtime.py packages/discovery-runtime/src/drm_copilot_discovery/resources.py tests/scripts/dev_tools/test_build_discovery_runtime.py tests/scripts/dev_tools/test_build_discovery_runtime_io.py tests/discovery_runtime/test_resources.py
EXIT_CODE: 1
Output Summary: [1m[94m193 |[0m     assert build.verify_import_closure(modules) == ("PyYAML", "referencing");     [1m[94m|[0m; ; Found 7 errors.

Working directory: .
Started: 2026-10-18T04:48:16.524558+00:00
Duration seconds: 0.784
Phase: P1-T2 resource staging; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (110 > 88)[0m
   [1m[94m-->[0m scripts\dev_tools\build_discovery_runtime.py:233:89
    [1m[94m|[0m
[1m[94m231 |[0m     if expected != actual:
[1m[94m232 |[0m         raise ResourceError(
[1m[94m233 |[0m             f"Resource input mismatch; missing={sorted(expected - actual)}, extra={sorted(actual - expected)}"
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^^^^^^^^^^^^[0m
[1m[94m234 |[0m         )
[1m[94m235 |[0m     verify_schema_closure(inputs)
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (99 > 88)[0m
   [1m[94m-->[0m scripts\dev_tools\build_discovery_runtime.py:252:89
    [1m[94m|[0m
[1m[94m250 |[0m                 if node.level:
[1m[94m251 |[0m                     raise ResourceError(
[1m[94m252 |[0m                         f"Runtime import closure requires explicit absolute imports: {module_name}"
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^[0m
[1m[94m253 |[0m                     )
[1m[94m254 |[0m                 targets = (node.module,) if node.module else ()
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (131 > 88)[0m
   [1m[94m-->[0m scripts\dev_tools\build_discovery_runtime.py:352:89
    [1m[94m|[0m
[1m[94m350 |[0m     if result.returncode:
[1m[94m351 |[0m         raise ResourceError(
[1m[94m352 |[0m             f"Wheel build failed; install the approved poetry-core build backend: {result.stderr.strip() or result.stdout.strip()}"
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^[0m
[1m[94m353 |[0m         )
[1m[94m354 |[0m     wheel = output / f"drm_copilot_discovery-{__version__}-py3-none-any.whl"
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (106 > 88)[0m
  [1m[94m-->[0m tests\scripts\dev_tools\test_build_discovery_runtime.py:14:89
   [1m[94m|[0m
[1m[94m12 |[0m ROOT = "schemas/discovery/v1"
[1m[94m13 |[0m SCHEMA_PATH = f"{ROOT}/example.schema.json"
[1m[94m14 |[0m SCHEMA = b'{"$id":"urn:example","$defs":{"value":{"type":"string"}},"allOf":[{"$ref":"#/$defs/value"}]}\n'
   [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^^^^^^^^[0m
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (96 > 88)[0m
   [1m[94m-->[0m tests\scripts\dev_tools\test_build_discovery_runtime.py:173:89
    [1m[94m|[0m
[1m[94m171 |[0m     inputs = {
[1m[94m172 |[0m         SCHEMA_PATH: SCHEMA,
[1m[94m173 |[0m         f"{ROOT}/caller.schema.json": b'{"$id":"urn:caller","$ref":"urn:example#/$defs/value"}',
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^[0m
[1m[94m174 |[0m         "docs/discovery/templates/example.yaml": b"draft: true\n",
[1m[94m175 |[0m     }
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (111 > 88)[0m
   [1m[94m-->[0m tests\scripts\dev_tools\test_build_discovery_runtime.py:190:89
    [1m[94m|[0m
[1m[94m188 |[0m     """Closure reports only approved dependencies and verifies local module names."""
[1m[94m189 |[0m     modules = {
[1m[94m190 |[0m         "drm_copilot_discovery": "import json\nimport yaml\nfrom drm_copilot_discovery.helpers import value\n",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^^^^^^^^^^^^^[0m
[1m[94m191 |[0m         "drm_copilot_discovery.helpers": "value = 1\nfrom referencing import Registry\n",
[1m[94m192 |[0m     }
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\scripts\dev_tools\test_build_discovery_runtime.py:191:89
    [1m[94m|[0m
[1m[94m189 |[0m     modules = {
[1m[94m190 |[0m         "drm_copilot_discovery": "import json\nimport yaml\nfrom drm_copilot_discovery.helpers import value\n",
[1m[94m191 |[0m         "drm_copilot_discovery.helpers": "value = 1\nfrom referencing import Registry\n",
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m192 |[0m     }
[1m[94m193 |[0m     assert build.verify_import_closure(modules) == ("PyYAML", "referencing")
    [1m[94m|[0m

Found 7 errors.
```
