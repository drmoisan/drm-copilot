# P5-T1 models-pyright

Timestamp: 2026-10-19T14-49
Command: poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/report_models.py
EXIT_CODE: 1

Duration seconds: 1.817

```text
WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\report_models.py
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\report_models.py:149:23 - error: Unnecessary "cast" call; type is already "str" (reportUnnecessaryCast)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\report_models.py:151:23 - error: Unnecessary "cast" call; type is already "int" (reportUnnecessaryCast)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\report_models.py:156:22 - error: Unnecessary "cast" call; type is already "float" (reportUnnecessaryCast)
3 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```
