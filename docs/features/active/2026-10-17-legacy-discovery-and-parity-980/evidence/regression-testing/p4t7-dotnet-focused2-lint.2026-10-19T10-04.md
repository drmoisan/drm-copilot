# P4-T7 .NET parser scoped gate

Timestamp: 2026-10-19T10-04
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dependency_dotnet.py tests/discovery_runtime/analyzer/test_dependency_dotnet.py
EXIT_CODE: 1

Path rendering uses WORKSPACE and SCRATCH tokens; exact streams are preserved by hash.

```text
E501 Line too long (91 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_dotnet.py:116:89
    |
114 |         )
115 |         versions = int(version is not None)
116 |         # Overrides and child versions remain separate syntax rather than effective values.
    |                                                                                         ^^^
117 |         override = node.attribute("VersionOverride")
118 |         if override is not None:
    |

E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_dotnet.py:237:89
    |
235 |             _charge(child, budget)
236 |     elif isinstance(value, tuple):
237 |         # Array contents remain bounded even when the selected lock grammar ignores them.
    |                                                                                         ^
238 |         for child in value:
239 |             _charge(child, budget)
    |

E501 Line too long (91 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_dotnet.py:262:89
    |
260 |     )
261 |     if parsed.value is None:
262 |         # Translate only fixed categories, never messages, pointers or source-derived text.
    |                                                                                         ^^^
263 |         codes = {finding.code for finding in parsed.findings}
264 |         code = (
    |

E501 Line too long (89 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_dotnet.py:277:89
    |
275 |     frameworks = _object(root.get("dependencies"))
276 |     occurrence = 0
277 |     # JsonObject order is canonical member order, never a claimed physical JSON location.
    |                                                                                         ^
278 |     for packages in frameworks.values():
279 |         for name, value in _object(packages).items():
    |

E501 Line too long (92 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_dotnet.py:294:89
    |
292 |                 anchor=DependencyAnchor("json", "/dependencies", occurrence),
293 |             )
294 |             # Edges retain the declared owner spelling, without inventing record resolution.
    |                                                                                         ^^^^
295 |             for target, version in _object(
296 |                 record.get("dependencies", JsonObject(()))
    |

E501 Line too long (91 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dependency_dotnet.py:325:89
    |
323 |     budget = DependencyBudget(limits)
324 |     budget.decode(content)
325 |     # Explicit selection determines the grammar; content never chooses executable behavior.
    |                                                                                         ^^^
326 |     if format == "packages-lock":
327 |         _lock(content, budget)
    |

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\analyzer\test_dependency_dotnet.py:3:1
   |
 1 |   """Verify pure .NET dependency declarations, redaction and bounded failure contracts."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | import json
 6 | | from dataclasses import replace
 7 | | from typing import cast
 8 | |
 9 | | import pytest
10 | |
11 | | from drm_copilot_discovery.analyzer.dependency_dotnet import (
12 | |     DotnetDependencyFormat,
13 | |     parse_dotnet_dependencies,
14 | | )
15 | | from drm_copilot_discovery.analyzer.dependency_inputs import (
16 | |     DependencyInputError,
17 | |     DependencyLimits,
18 | | )
   | |_^
   |
help: Organize imports

E501 Line too long (143 > 88)
   --> tests\discovery_runtime\analyzer\test_dependency_dotnet.py:113:89
    |
111 | …l effects.
112 | …
113 | …rsion="1.2.3" targetFramework="SECRET"/>\n<package id="Beta" Condition="SECRET"/></packages>'
    |                                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
114 | …
115 | …DependencyLimits()
    |

E501 Line too long (123 > 88)
   --> tests\discovery_runtime\analyzer\test_dependency_dotnet.py:164:89
    |
162 |     Returns None; assertions propagate; no external effects.
163 |     """
164 |     first = b'{"version":1,"dependencies":{"net8":{"B":{"type":"Project"},"A":{"type":"Direct"}}},"ignored":[null,[true]]}'
    |                                                                                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
165 |     second = b'{"ignored":[null,[true]],"dependencies":{"net8":{"A":{"type":"Direct"},"B":{"type":"Project"}}},"version":1}'
166 |     result = parse_dotnet_dependencies(
    |

E501 Line too long (124 > 88)
   --> tests\discovery_runtime\analyzer\test_dependency_dotnet.py:165:89
    |
163 |     """
164 |     first = b'{"version":1,"dependencies":{"net8":{"B":{"type":"Project"},"A":{"type":"Direct"}}},"ignored":[null,[true]]}'
165 |     second = b'{"ignored":[null,[true]],"dependencies":{"net8":{"A":{"type":"Direct"},"B":{"type":"Project"}}},"version":1}'
    |                                                                                         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
166 |     result = parse_dotnet_dependencies(
167 |         first, format="packages-lock", limits=DependencyLimits()
    |

E501 Line too long (98 > 88)
   --> tests\discovery_runtime\analyzer\test_dependency_dotnet.py:220:89
    |
218 |         project('<PackageReference Include="A" Update="B"/>'),
219 |         project(
220 |             '<PackageReference Include="A"><Version><Value>1</Value></Version></PackageReference>'
    |                                                                                         ^^^^^^^^^^
221 |         ),
222 |         b'<!DOCTYPE Project [<!ENTITY x "SECRET">]><Project/>',
    |

E501 Line too long (99 > 88)
   --> tests\discovery_runtime\analyzer\test_dependency_dotnet.py:223:89
    |
221 |         ),
222 |         b'<!DOCTYPE Project [<!ENTITY x "SECRET">]><Project/>',
223 |         b'<Project xmlns:x="http://www.w3.org/2001/XInclude"><x:include href="SECRET"/></Project>',
    |                                                                                         ^^^^^^^^^^^
224 |     ],
225 | )
    |

Found 12 errors.
[*] 1 fixable with the `--fix` option.

```
