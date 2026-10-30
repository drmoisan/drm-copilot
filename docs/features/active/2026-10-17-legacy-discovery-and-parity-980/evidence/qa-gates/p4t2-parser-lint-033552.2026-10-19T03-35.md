# P4-T2 parser-lint

Timestamp: 2026-10-19T03-35
Command: `poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/xml_input.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/solution_input.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dotnet_projects.py tests/discovery_runtime/analyzer/test_xml_input.py tests/discovery_runtime/analyzer/test_solution_input.py`
EXIT_CODE: 1
Output Summary: Exact diagnostics, timing and source hashes are retained in the adjacent JSON; raw output hashes bind the retained scratch bytes.

```text
I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\analyzer\test_solution_input.py:3:1
   |
 1 |   """Test solution-text declarations using bounded in-memory byte sequences."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | from dataclasses import FrozenInstanceError, replace
 6 | | from typing import cast
 7 | |
 8 | | import pytest
 9 | | from drm_copilot_discovery.analyzer.solution_input import (
10 | |     SolutionEntry,
11 | |     SolutionInputError,
12 | |     parse_solution,
13 | | )
14 | | from hypothesis import given, strategies as st
   | |______________________________________________^
15 |
16 |   HEADER = "Microsoft Visual Studio Solution File, Format Version 12.00\n"
   |
help: Organize imports

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\analyzer\test_solution_input.py:121:89
    |
119 |     text = solution().replace(
120 |         "EndProject",
121 |         "ProjectSection(Unresolved) = preProject\n X = Y\nEndProjectSection\nEndProject",
    |                                                                                         ^
122 |     )
123 |     assert len(parse((text + "Global\nEndGlobal\n").encode())) == 1
    |

B010 [*] Do not call `setattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\discovery_runtime\analyzer\test_solution_input.py:171:9
    |
169 |     entry = parse(solution().encode())[0]
170 |     with pytest.raises(FrozenInstanceError):
171 |         setattr(entry, "path", "other")
    |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    |
help: Replace `setattr` with assignment

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\analyzer\test_xml_input.py:3:1
   |
 1 |   """Exercise secure XML byte parsing with immutable, isolated in-memory inputs."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | from dataclasses import FrozenInstanceError, replace
 6 | | from types import SimpleNamespace
 7 | | from typing import cast
 8 | |
 9 | | import pytest
10 | | from drm_copilot_discovery.analyzer import xml_input
11 | | from drm_copilot_discovery.analyzer.xml_input import XmlInputError, XmlNode, parse_xml
12 | | from hypothesis import given, strategies as st
   | |______________________________________________^
   |
help: Organize imports

E501 Line too long (124 > 88)
  --> tests\discovery_runtime\analyzer\test_xml_input.py:33:89
   |
31 |     Returns None; assertions fail on changes. Only in-memory byte parsing occurs.
32 |     """
33 |     content = '<Project xmlns="urn:synthetic" Z="2" A="1">\r\n <Name>État &amp; Ω</Name>\r\n <Empty/>\r\n</Project>'.encode(
   |                                                                                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
34 |         encoding
35 |     )
   |

E501 Line too long (115 > 88)
  --> tests\discovery_runtime\analyzer\test_xml_input.py:56:89
   |
54 |     Returns None; AssertionError signals a mismatch. No arguments, I/O or mutation.
55 |     """
56 |     content = b'<?synthetic instruction?>\n<Project>\n<!-- comment -->\n <Reference\n Include="A"\n />\n</Project>'
   |                                                                                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^
57 |     nodes = parse(content)
58 |     assert len(nodes) == 2 and nodes[1].tag == "Reference"
   |

B010 [*] Do not call `setattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\discovery_runtime\analyzer\test_xml_input.py:232:9
    |
230 |     node = XmlNode(tag="Child", attributes=(), text="", line=2, parent=0)
231 |     with pytest.raises(FrozenInstanceError):
232 |         setattr(node, "line", 9)
    |         ^^^^^^^^^^^^^^^^^^^^^^^^
233 |     assert node.line == 2 and node.parent == 0
    |
help: Replace `setattr` with assignment

Found 7 errors.
[*] 4 fixable with the `--fix` option.

```
