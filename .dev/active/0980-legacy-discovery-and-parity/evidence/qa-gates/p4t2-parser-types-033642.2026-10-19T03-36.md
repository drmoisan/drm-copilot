# P4-T2 parser-types

Timestamp: 2026-10-19T03-36
Command: `poetry run pyright packages/discovery-runtime/src/drm_copilot_discovery/analyzer/xml_input.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/solution_input.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dotnet_projects.py tests/discovery_runtime/analyzer/test_xml_input.py tests/discovery_runtime/analyzer/test_solution_input.py`
EXIT_CODE: 1
Output Summary: Exact diagnostics, timing and source hashes are retained in the adjacent JSON; raw output hashes bind the retained scratch bytes.

```text
WORKSPACE\tests\discovery_runtime\analyzer\test_solution_input.py
  WORKSPACE\tests\discovery_runtime\analyzer\test_solution_input.py:14:6 - error: Import "hypothesis" could not be resolved (reportMissingImports)
  WORKSPACE\tests\discovery_runtime\analyzer\test_solution_input.py:14:24 - error: Type of "given" is unknown (reportUnknownVariableType)
  WORKSPACE\tests\discovery_runtime\analyzer\test_solution_input.py:15:6 - error: Import "hypothesis" could not be resolved (reportMissingImports)
  WORKSPACE\tests\discovery_runtime\analyzer\test_solution_input.py:15:38 - error: Type of "st" is unknown (reportUnknownVariableType)
  WORKSPACE\tests\discovery_runtime\analyzer\test_solution_input.py:199:2 - error: Untyped function decorator obscures type of function; ignoring decorator (reportUntypedFunctionDecorator)
  WORKSPACE\tests\discovery_runtime\analyzer\test_solution_input.py:199:8 - error: Type of "text" is unknown (reportUnknownMemberType)
WORKSPACE\tests\discovery_runtime\analyzer\test_xml_input.py
  WORKSPACE\tests\discovery_runtime\analyzer\test_xml_input.py:12:6 - error: Import "hypothesis" could not be resolved (reportMissingImports)
  WORKSPACE\tests\discovery_runtime\analyzer\test_xml_input.py:12:24 - error: Type of "given" is unknown (reportUnknownVariableType)
  WORKSPACE\tests\discovery_runtime\analyzer\test_xml_input.py:13:6 - error: Import "hypothesis" could not be resolved (reportMissingImports)
  WORKSPACE\tests\discovery_runtime\analyzer\test_xml_input.py:13:38 - error: Type of "st" is unknown (reportUnknownVariableType)
  WORKSPACE\tests\discovery_runtime\analyzer\test_xml_input.py:243:2 - error: Untyped function decorator obscures type of function; ignoring decorator (reportUntypedFunctionDecorator)
  WORKSPACE\tests\discovery_runtime\analyzer\test_xml_input.py:244:5 - error: Type of "text" is unknown (reportUnknownMemberType)
  WORKSPACE\tests\discovery_runtime\analyzer\test_xml_input.py:245:5 - error: Type of "integers" is unknown (reportUnknownMemberType)
13 errors, 0 warnings, 0 informations
WARNING: there is a new pyright version available (v1.1.409 -> v1.1.414).
Please install the new version or set PYRIGHT_PYTHON_FORCE_VERSION to `latest`


```
