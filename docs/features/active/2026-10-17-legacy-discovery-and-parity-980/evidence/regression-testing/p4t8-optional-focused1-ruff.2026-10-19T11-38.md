# p4t8-optional-focused1 ruff

Timestamp: 2026-10-19T11-38
Command: .\.venv\Scripts\python.exe -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/__init__.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/vsto_office.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/vsto_patterns.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/optional/vsto_syntax.py tests/discovery_runtime/analyzer/test_optional_adapter.py tests/discovery_runtime/analyzer/test_optional_limits.py
EXIT_CODE: 1
Output Summary: scoped ruff, 0.109 seconds; source changed=False. Separate exact raw streams qualify sanitized presentation.

```text
TC001 Move application import `drm_copilot_discovery.profile_v2.ProfileV2` into a type-checking block
  --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\optional\vsto_office.py:28:46
   |
26 | from drm_copilot_discovery.models import JsonObject
27 | from drm_copilot_discovery.path_models import relative_path
28 | from drm_copilot_discovery.profile_v2 import ProfileV2
   |                                              ^^^^^^^^^
29 |
30 | if TYPE_CHECKING:
   |
help: Move into type-checking block

E501 Line too long (153 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\optional\vsto_office.py:192:89
    |
190 | …
191 | …
192 | …figured limits; binding, conditions and execution remain unresolved. Source values are withheld.",
    |                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
193 | …
194 | …
    |

E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\optional\vsto_office.py:240:89
    |
239 |     def reserve(self, count: int, cost: int) -> None:
240 |         """Charge int count/cost before output allocation; return None, private mutation.
    |                                                                                         ^
241 |
242 |         SourceScanError distinguishes exhausted row and conservative encoded-byte
    |

I001 [*] Import block is un-sorted or un-formatted
  --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\optional\vsto_syntax.py:7:1
   |
 5 |   """
 6 |
 7 | / from __future__ import annotations
 8 | |
 9 | | import re
10 | | from dataclasses import replace
11 | |
12 | | from drm_copilot_discovery.analyzer.com_interop import (
13 | |     com_project_candidates,
14 | |     com_source_candidates,
15 | | )
16 | | from drm_copilot_discovery.analyzer.csharp_declarations import declaration_candidates
17 | | from drm_copilot_discovery.analyzer.csharp_tokens import (
18 | |     SourceScanError,
19 | |     tokenize_csharp,
20 | | )
21 | | from drm_copilot_discovery.analyzer.source_text import (
22 | |     Detection,
23 | |     strip_comments_and_strings,
24 | | )
25 | | from drm_copilot_discovery.analyzer.xml_input import XmlInputError, parse_xml
26 | | from drm_copilot_discovery.profile_v2 import ProfileV2
27 | | from drm_copilot_discovery.path_models import relative_path
28 | | from drm_copilot_discovery.analyzer.optional.vsto_patterns import (
29 | |     CUSTOMUI_URIS,
30 | |     DESIGNER_RIBBON_LITERAL,
31 | | )
   | |_^
32 |
33 |   _IDENTIFIER = re.compile(
   |
help: Organize imports

E501 Line too long (250 > 88)
  --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\optional\vsto_syntax.py:41:89
   |
39 | …
40 | …
41 | …ropDown gallery menu splitButton box buttonGroup dialogBoxLauncher separator labelControl contextualTabs tabSet officeMenu qat sharedControls documentControls".split()
   |       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
42 | …
43 | …
   |

E501 Line too long (152 > 88)
  --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\optional\vsto_syntax.py:44:89
   |
42 | …
43 | …
44 | …getPressed getText getContent getItemCount getItemLabel getItemImage getSelectedItemIndex".split()
   |                                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
45 | …
   |

TC002 Move third-party import `drm_copilot_discovery.profile_v2.ProfileV2` into a type-checking block
  --> tests\discovery_runtime\analyzer\test_optional_adapter.py:27:46
   |
25 | from drm_copilot_discovery.analyzer.xml_input import XmlInputError
26 | from drm_copilot_discovery.models import JsonObject, canonical_json
27 | from drm_copilot_discovery.profile_v2 import ProfileV2
   |                                              ^^^^^^^^^
28 | from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
29 | from drm_copilot_discovery.snapshot import SnapshotFile
   |
help: Move into type-checking block

E501 Line too long (105 > 88)
   --> tests\discovery_runtime\analyzer\test_optional_adapter.py:249:89
    |
247 |     "body",
248 |     [
249 |         '<ProjectExtensions><ItemGroup><COMReference Include="SECRET"/></ItemGroup></ProjectExtensions>',
    |                                                                                         ^^^^^^^^^^^^^^^^^
250 |         '<PropertyGroup><ItemGroup><COMReference Include="SECRET"/></ItemGroup></PropertyGroup>',
251 |         '<ItemGroup><Reference Include="C:/SECRET"/></ItemGroup>',
    |

E501 Line too long (97 > 88)
   --> tests\discovery_runtime\analyzer\test_optional_adapter.py:250:89
    |
248 |     [
249 |         '<ProjectExtensions><ItemGroup><COMReference Include="SECRET"/></ItemGroup></ProjectExtensions>',
250 |         '<PropertyGroup><ItemGroup><COMReference Include="SECRET"/></ItemGroup></PropertyGroup>',
    |                                                                                         ^^^^^^^^^
251 |         '<ItemGroup><Reference Include="C:/SECRET"/></ItemGroup>',
252 |     ],
    |

E501 Line too long (223 > 88)
   --> tests\discovery_runtime\analyzer\test_optional_adapter.py:270:89
    |
268 | …
269 | …"""
270 | …EmbedInteropTypes>false</EmbedInteropTypes></COMReference><Reference Include="Microsoft.Office.Interop.GenericHost"/></ItemGroup></Project>'
    |       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
271 | …
272 | …
    |

E501 Line too long (148 > 88)
   --> tests\discovery_runtime\analyzer\test_optional_adapter.py:287:89
    |
285 | …
286 | …
287 | …>\r\n<customUI xmlns="{URI}" onLoad="Start"><ribbon><button onAction="Go"/></ribbon></customUI>'
    |                                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
288 | …
289 | …
    |

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\analyzer\test_optional_limits.py:3:1
   |
 1 |   """Verify optional consent, exact limit types, encoding and aggregate exhaustion."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | from typing import TYPE_CHECKING, cast
 6 | |
 7 | | import pytest
 8 | | from drm_copilot_discovery.analyzer.csharp_tokens import SourceScanError
 9 | | from drm_copilot_discovery.analyzer.models import InventoryCapture
10 | | from drm_copilot_discovery.analyzer.optional import vsto_syntax as patterns
11 | | from drm_copilot_discovery.analyzer.optional.vsto_office import (
12 | |     VstoOfficeAnalyzer,
13 | |     classify_csharp,
14 | |     classify_project,
15 | |     classify_xml,
16 | | )
17 | | from drm_copilot_discovery.profile_v2 import ProfileError, ProfileV2
18 | | from tests.discovery_runtime.analyzer.test_optional_adapter import (
19 | |     captured,
20 | |     profile as profile,
21 | |     profile_for,
22 | |     rendered,
23 | | )
24 | | from tests.discovery_runtime.analyzer.test_repository import (
25 | |     analyzer_catalog as analyzer_catalog,
26 | | )
27 | | from tests.discovery_runtime.analyzer.test_repository import inventory_profile
   | |______________________________________________________________________________^
28 |
29 |   if TYPE_CHECKING:
   |
help: Organize imports

TC002 Move third-party import `drm_copilot_discovery.analyzer.models.InventoryCapture` into a type-checking block
  --> tests\discovery_runtime\analyzer\test_optional_limits.py:9:51
   |
 7 | import pytest
 8 | from drm_copilot_discovery.analyzer.csharp_tokens import SourceScanError
 9 | from drm_copilot_discovery.analyzer.models import InventoryCapture
   |                                                   ^^^^^^^^^^^^^^^^
10 | from drm_copilot_discovery.analyzer.optional import vsto_syntax as patterns
11 | from drm_copilot_discovery.analyzer.optional.vsto_office import (
   |
help: Move into type-checking block

Found 13 errors.
[*] 2 fixable with the `--fix` option (3 hidden fixes can be enabled with the `--unsafe-fixes` option).
```
