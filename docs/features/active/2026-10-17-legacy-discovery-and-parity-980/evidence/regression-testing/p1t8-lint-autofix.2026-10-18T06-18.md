# p1t8-lint-autofix

Timestamp: 2026-10-18T06-18
Command: poetry run ruff check --fix --output-format concise packages/discovery-runtime/src/drm_copilot_discovery/parsing.py packages/discovery-runtime/src/drm_copilot_discovery/findings.py packages/discovery-runtime/src/drm_copilot_discovery/models.py tests/discovery_runtime/test_parsing.py tests/discovery_runtime/test_parsing_limits.py tests/discovery_runtime/test_findings.py
EXIT_CODE: 1
Output Summary: [36m-[0m [1mtests\discovery_runtime\test_parsing_limits.py[0m[36m:[0m;     1 × [1;31mI001[0m (unsorted-imports); ; Found 25 errors (14 fixed, 11 remaining).

Working directory: .
Started: 2026-10-18T06:18:31.422567+00:00
Duration seconds: 0.821
Phase: P1-T8 strict parsing and immutable diagnostics; focused task verification.

## Captured output

```text
[1mpackages\discovery-runtime\src\drm_copilot_discovery\findings.py[0m[36m:[0m133[36m:[0m89[36m:[0m [1m[31m]8;;httpEXTERNAL_PATH Line too long (89 > 88)
[1mpackages\discovery-runtime\src\drm_copilot_discovery\parsing.py[0m[36m:[0m38[36m:[0m89[36m:[0m [1m[31m]8;;httpEXTERNAL_PATH Line too long (89 > 88)
[1mpackages\discovery-runtime\src\drm_copilot_discovery\parsing.py[0m[36m:[0m80[36m:[0m89[36m:[0m [1m[31m]8;;httpEXTERNAL_PATH Line too long (91 > 88)
[1mpackages\discovery-runtime\src\drm_copilot_discovery\parsing.py[0m[36m:[0m170[36m:[0m89[36m:[0m [1m[31m]8;;httpEXTERNAL_PATH Line too long (89 > 88)
[1mpackages\discovery-runtime\src\drm_copilot_discovery\parsing.py[0m[36m:[0m299[36m:[0m89[36m:[0m [1m[31m]8;;httpEXTERNAL_PATH Line too long (89 > 88)
[1mpackages\discovery-runtime\src\drm_copilot_discovery\parsing.py[0m[36m:[0m350[36m:[0m89[36m:[0m [1m[31m]8;;httpEXTERNAL_PATH Line too long (89 > 88)
[1mtests\discovery_runtime\test_findings.py[0m[36m:[0m164[36m:[0m89[36m:[0m [1m[31m]8;;httpEXTERNAL_PATH Line too long (90 > 88)
[1mtests\discovery_runtime\test_findings.py[0m[36m:[0m191[36m:[0m89[36m:[0m [1m[31m]8;;httpEXTERNAL_PATH Line too long (89 > 88)
[1mtests\discovery_runtime\test_parsing_limits.py[0m[36m:[0m35[36m:[0m89[36m:[0m [1m[31m]8;;httpEXTERNAL_PATH Line too long (89 > 88)
[1mtests\discovery_runtime\test_parsing_limits.py[0m[36m:[0m133[36m:[0m89[36m:[0m [1m[31m]8;;httpEXTERNAL_PATH Line too long (89 > 88)
[1mtests\discovery_runtime\test_parsing_limits.py[0m[36m:[0m184[36m:[0m89[36m:[0m [1m[31m]8;;httpEXTERNAL_PATH Line too long (89 > 88)

[1;32mFixed 14 errors:[0m
[36m-[0m [1mpackages\discovery-runtime\src\drm_copilot_discovery\parsing.py[0m[36m:[0m
    3 × [1;31mTC006[0m (runtime-cast-value)
[36m-[0m [1mtests\discovery_runtime\test_findings.py[0m[36m:[0m
    1 × [1;31mI001[0m (unsorted-imports)
    1 × [1;31mB010[0m (set-attr-with-constant)
    1 × [1;31mTC006[0m (runtime-cast-value)
[36m-[0m [1mtests\discovery_runtime\test_parsing.py[0m[36m:[0m
    5 × [1;31mTC006[0m (runtime-cast-value)
    1 × [1;31mI001[0m (unsorted-imports)
    1 × [1;31mB010[0m (set-attr-with-constant)
[36m-[0m [1mtests\discovery_runtime\test_parsing_limits.py[0m[36m:[0m
    1 × [1;31mI001[0m (unsorted-imports)

Found 25 errors (14 fixed, 11 remaining).
```
