# P4-T2 adapter-lint

Timestamp: 2026-10-19T03-42
Command: `poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dotnet_projects.py tests/discovery_runtime/analyzer/test_dotnet_projects.py`
EXIT_CODE: 1
Output Summary: Exact diagnostics, timing and source hashes are retained in the adjacent JSON; raw output hashes bind the retained scratch bytes.

```text
E501 Line too long (97 > 88)
  --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dotnet_projects.py:32:89
   |
30 |     from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryInput
31 |
32 | _XML_SUFFIXES = frozenset(".slnx .csproj .fsproj .vbproj .vcxproj .proj .props .targets".split())
   |                                                                                         ^^^^^^^^^
33 | _BUILD_NAMESPACE = "http://schemas.microsoft.com/developer/msbuild/2003"
34 | _KINDS = {
   |

E501 Line too long (94 > 88)
  --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dotnet_projects.py:48:89
   |
46 | }
47 | _ATTRIBUTES = frozenset((
48 |     "Name Path Include Update Remove Exclude Version VersionOverride Sdk Project ToolsVersion"
   |                                                                                         ^^^^^^
49 | ).split())
50 | _METADATA = frozenset((
   |

TC002 Move third-party import `drm_copilot_discovery.models.JsonObject` into a type-checking block
  --> tests\discovery_runtime\analyzer\test_dotnet_projects.py:21:42
   |
19 | )
20 | from drm_copilot_discovery.catalog import load_catalog
21 | from drm_copilot_discovery.models import JsonObject
   |                                          ^^^^^^^^^^
22 | from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
23 | from drm_copilot_discovery.snapshot import SnapshotFile
   |
help: Move into type-checking block

E501 Line too long (93 > 88)
   --> tests\discovery_runtime\analyzer\test_dotnet_projects.py:443:89
    |
441 |     Returns None; assertions require exact round trip. No I/O or path evaluation.
442 |     """
443 |     body = f'<Project><ProjectReference Update="{value}" Exclude="skip"/></Project>'.encode()
    |                                                                                         ^^^^^
444 |     analysis = DotnetProjectAnalyzer().analyze(
445 |         capture(catalog, (("src/app.csproj", body),))
    |

Found 4 errors.
No fixes available (1 hidden fix can be enabled with the `--unsafe-fixes` option).

```
