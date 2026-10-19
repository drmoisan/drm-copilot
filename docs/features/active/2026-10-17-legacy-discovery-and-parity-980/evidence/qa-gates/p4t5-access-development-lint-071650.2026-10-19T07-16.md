# P4-T5 development lint

Timestamp: 2026-10-19T07-16
Command: `poetry run python -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/api_access.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/api_syntax.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/filesystem_access.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry_access.py tests/discovery_runtime/analyzer/test_filesystem_access.py tests/discovery_runtime/analyzer/test_registry_access.py`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
I001 [*] Import block is un-sorted or un-formatted
  --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\api_access.py:9:1
   |
 7 |   """
 8 |
 9 | / from __future__ import annotations
10 | |
11 | | from typing import TYPE_CHECKING
12 | |
13 | | from drm_copilot_discovery.analyzer.csharp_tokens import (
14 | |     SourceScanError,
15 | |     decode_source,
16 | | )
17 | | from drm_copilot_discovery.analyzer.findings import (
18 | |     diagnostic,
19 | |     pinned_matches,
20 | |     row,
21 | |     source_reference,
22 | |     stable_id,
23 | |     tool,
24 | | )
25 | | from drm_copilot_discovery.analyzer.models import Analysis
26 | | from drm_copilot_discovery.analyzer.api_syntax import (
27 | |     ApiSurface,
28 | |     AccessSite,
29 | |     access_sites,
30 | | )
31 | | from drm_copilot_discovery.models import JsonObject
   | |___________________________________________________^
32 |
33 |   if TYPE_CHECKING:
   |
help: Organize imports

E501 Line too long (127 > 88)
  --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\api_access.py:46:89
   |
44 |         code,
45 |         path,
46 |         "Check captured C# syntax, immutable provenance and configured limits; runtime values and error details are withheld.",
   |                                                                                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
47 |         analyzer=identifier,
48 |     )
   |

E501 Line too long (159 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\api_access.py:156:89
    |
154 | …
155 | …
156 | …es, aliases, conditional compilation, runtime targets and platform applicability remain unresolved.",
    |                                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
157 | …
158 | …
    |

E501 Line too long (94 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\api_syntax.py:164:89
    |
162 |     """Return bounded fixed-name candidates from C# text and immutable surface.
163 |
164 |     max_tokens (int, 1..100000) and max_sites (int, 0..100000) bound tokens/records. Comments,
    |                                                                                         ^^^^^^
165 |     all string/interpolation contents and directives cannot create API evidence.
166 |     SourceScanError reports size/token/delimiter/record limits without partial
    |

E501 Line too long (89 > 88)
  --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\registry_access.py:46:89
   |
45 | class RegistryAccessAnalyzer:
46 |     """Project unresolved registry candidates without accessing the platform registry."""
   |                                                                                         ^
47 |
48 |     identifier = "registry-access"
   |

E501 Line too long (117 > 88)
   --> tests\discovery_runtime\analyzer\test_filesystem_access.py:156:89
    |
154 |     Returns None; candidates remain inferred even when runtime usage is uncertain.
155 |     """
156 |     source = b"using File = Custom; class File { void Open() {} }\n#if DISABLED\nFile.Open();\n#endif\n@File.Open();"
    |                                                                                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
157 |     result = FilesystemAccessAnalyzer().analyze(
158 |         capture(catalog, (("src/a.cs", source),))
    |

E501 Line too long (107 > 88)
   --> tests\discovery_runtime\analyzer\test_registry_access.py:274:89
    |
272 |     projected: list[str] = []
273 |     original = cast(
274 |         "Callable[[InventoryCapture, InventoryInput, ApiSurface, tuple[AccessSite, ...], bool], Analysis]",
    |                                                                                         ^^^^^^^^^^^^^^^^^^^
275 |         vars(api_access)["_project"],
276 |     )
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\analyzer\test_registry_access.py:347:89
    |
346 | class CountedTokens:
347 |     """Wrap immutable tokens with a local access counter for deterministic work tests."""
    |                                                                                         ^
348 |
349 |     def __init__(self, values: tuple[Token, ...]) -> None:
    |

Found 8 errors.
[*] 1 fixable with the `--fix` option.

```
