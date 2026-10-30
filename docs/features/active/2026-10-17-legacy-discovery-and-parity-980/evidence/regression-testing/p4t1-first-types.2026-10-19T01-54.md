Timestamp: 2026-10-19T01:54:02.083718+00:00
Command: poetry run python -m pyright packages/discovery-runtime/src/drm_copilot_discovery/analyzer/emitter.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/findings.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/input_capture.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/inventory.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/models.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/pipeline.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry.py
EXIT_CODE: 1
Output Summary:

```text
WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py:29:6 - error: Stub file not found for "drm_copilot_discovery.analyzer.findings" (reportMissingTypeStubs)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py:30:6 - error: Stub file not found for "drm_copilot_discovery.analyzer.models" (reportMissingTypeStubs)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\emitter.py:38:10 - error: Stub file not found for "drm_copilot_discovery.analyzer.models" (reportMissingTypeStubs)
WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\findings.py
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\findings.py:15:10 - error: Stub file not found for "drm_copilot_discovery.analyzer.models" (reportMissingTypeStubs)
WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\input_capture.py
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\input_capture.py:14:6 - error: Stub file not found for "drm_copilot_discovery.analyzer.models" (reportMissingTypeStubs)
WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\inventory.py
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\inventory.py:37:6 - error: Stub file not found for "drm_copilot_discovery.analyzer.findings" (reportMissingTypeStubs)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\inventory.py:45:6 - error: Stub file not found for "drm_copilot_discovery.analyzer.models" (reportMissingTypeStubs)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\inventory.py:53:6 - error: Stub file not found for "drm_copilot_discovery.analyzer.pipeline" (reportMissingTypeStubs)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\inventory.py:58:10 - error: Stub file not found for "drm_copilot_discovery.analyzer.models" (reportMissingTypeStubs)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\inventory.py:59:10 - error: Stub file not found for "drm_copilot_discovery.analyzer.pipeline" (reportMissingTypeStubs)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\inventory.py:262:17 - error: Type of "append" is partially unknown
    Type of "append" is "(object: Unknown, /) -> None" (reportUnknownMemberType)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\inventory.py:275:17 - error: Type of "append" is partially unknown
    Type of "append" is "(object: Unknown, /) -> None" (reportUnknownMemberType)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\inventory.py:289:13 - error: Type of "append" is partially unknown
    Type of "append" is "(object: Unknown, /) -> None" (reportUnknownMemberType)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\inventory.py:304:36 - error: Argument type is partially unknown
    Argument corresponds to parameter "components" in function "__init__"
    Argument type is "tuple[Unknown, ...]" (reportUnknownArgumentType)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\inventory.py:304:42 - error: Argument type is partially unknown
    Argument corresponds to parameter "iterable" in function "__new__"
    Argument type is "list[Unknown]" (reportUnknownArgumentType)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\inventory.py:304:67 - error: Argument type is partially unknown
    Argument corresponds to parameter "diagnostics" in function "__init__"
    Argument type is "tuple[Unknown, ...]" (reportUnknownArgumentType)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\inventory.py:304:73 - error: Argument type is partially unknown
    Argument corresponds to parameter "iterable" in function "__new__"
    Argument type is "list[Unknown]" (reportUnknownArgumentType)
WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\models.py
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\models.py:274:24 - error: Unnecessary isinstance call; "JsonObject" is always an instance of "JsonObject" (reportUnnecessaryIsInstance)
WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py:27:6 - error: Stub file not found for "drm_copilot_discovery.analyzer.models" (reportMissingTypeStubs)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py:33:10 - error: Stub file not found for "drm_copilot_discovery.analyzer.models" (reportMissingTypeStubs)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py:178:10 - error: Stub file not found for "drm_copilot_discovery.analyzer.emitter" (reportMissingTypeStubs)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py:179:10 - error: Stub file not found for "drm_copilot_discovery.analyzer.registry" (reportMissingTypeStubs)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py:205:10 - error: Stub file not found for "drm_copilot_discovery.analyzer.input_capture" (reportMissingTypeStubs)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\pipeline.py:225:9 - error: Unnecessary "cast" call; type is already "JsonObject" (reportUnnecessaryCast)
WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\registry.py
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\registry.py:11:6 - error: Stub file not found for "drm_copilot_discovery.analyzer.inventory" (reportMissingTypeStubs)
  WORKSPACE\packages\discovery-runtime\src\drm_copilot_discovery\analyzer\registry.py:14:10 - error: Stub file not found for "drm_copilot_discovery.analyzer.models" (reportMissingTypeStubs)
26 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```

Elapsed seconds: 1.393231
Source and test bytes unchanged: True

```json
{
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/emitter.py": "1afd277e993db449a82471212e06e78d1321be5da26c9923978357edda4fd29c",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/findings.py": "7edffaa36d0d3c4ca72d6e6f00e9f48e377205472d3874c8222ad00ece2de01d",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/input_capture.py": "08ecb1689251e688e512066904bbf7706e1800df9a8c69b14004c987e2ed13b7",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/inventory.py": "2d6018f6b1333c52225dd703558580ac330f93efa149ac8a01c6aa9393e2cd6a",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/models.py": "8819429432c644027eabd3b838626a18798bb31ae2d26e5363542367b841de04",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/pipeline.py": "171907c69734f9d469d386aa6c97bec7dc5e899f4bcd7c733a59710bea346237",
  "packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry.py": "5fe0b51412b45d26faf02476aae93435746efe4d996ad7ff841846d01fc54d97"
}
```
