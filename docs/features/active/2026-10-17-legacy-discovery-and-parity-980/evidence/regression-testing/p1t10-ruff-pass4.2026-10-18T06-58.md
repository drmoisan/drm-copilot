# p1t10-ruff-pass4

Timestamp: 2026-10-18T06-58
Command: poetry run ruff check --output-format concise packages/discovery-runtime/src/drm_copilot_discovery/profile_v2.py packages/discovery-runtime/src/drm_copilot_discovery/profile_models.py packages/discovery-runtime/src/drm_copilot_discovery/activation_models.py packages/discovery-runtime/src/drm_copilot_discovery/domain_profile.py scripts/dev_tools/validate_discovery_profile.py tests/discovery_runtime/test_profile_v2.py tests/discovery_runtime/test_profile_dimensions.py tests/scripts/dev_tools/test_validate_discovery_profile.py tests/scripts/dev_tools/test_validate_discovery_artifacts_dispatch.py
EXIT_CODE: 1
Output Summary: [1mpackages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py[0m[36m:[0m33[36m:[0m89[36m:[0m [1m[31m]8;;httpEXTERNAL_PATH Line too long (89 > 88); [1mpackages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py[0m[36m:[0m59[36m:[0m89[36m:[0m [1m[31m]8;;httpEXTERNAL_PATH Line too long (93 > 88); [1mtests\discovery_runtime\test_profile_dimensions.py[0m[36m:[0m65[36m:[0m89[36m:[0m [1m[31m]8;;httpEXTERNAL_PATH Line too long (89 > 88); Found 4 errors.

Working directory: .
Started: 2026-10-18T06:58:49.454648+00:00
Duration seconds: 0.806
Phase: P1-T10 immutable profile, inherited gates and explicit compatibility; focused task verification.

## Captured output

```text
[1mpackages\discovery-runtime\src\drm_copilot_discovery\profile_models.py[0m[36m:[0m319[36m:[0m89[36m:[0m [1m[31m]8;;httpEXTERNAL_PATH Line too long (90 > 88)
[1mpackages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py[0m[36m:[0m33[36m:[0m89[36m:[0m [1m[31m]8;;httpEXTERNAL_PATH Line too long (89 > 88)
[1mpackages\discovery-runtime\src\drm_copilot_discovery\profile_v2.py[0m[36m:[0m59[36m:[0m89[36m:[0m [1m[31m]8;;httpEXTERNAL_PATH Line too long (93 > 88)
[1mtests\discovery_runtime\test_profile_dimensions.py[0m[36m:[0m65[36m:[0m89[36m:[0m [1m[31m]8;;httpEXTERNAL_PATH Line too long (89 > 88)
Found 4 errors.
```
