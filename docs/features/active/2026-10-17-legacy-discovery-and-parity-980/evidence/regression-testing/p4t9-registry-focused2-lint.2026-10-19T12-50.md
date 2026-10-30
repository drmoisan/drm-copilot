# p4t9-registry-focused2-lint

Timestamp: 2026-10-19T12-50
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/registry.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/__init__.py tests/discovery_runtime/analyzer/test_registry.py tests/discovery_runtime/analyzer/test_registry_dispatch.py tests/scripts/dev_tools/discovery/analyzer/test_domain_neutrality.py
EXIT_CODE: 1
Output Summary: scoped lint; duration 1.199 seconds. Raw stdout/stderr hashes and SCRATCH-relative locations are separate from sanitized presentation.

```text
I001 [*] Import block is un-sorted or un-formatted
 --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\__init__.py:3:1
  |
1 |   """Provide typed, read-only discovery analyzers with explicit guarded publication."""
2 |
3 | / from drm_copilot_discovery.analyzer.registry import (
4 | |     InventoryAdapter as Analyzer,
5 | |     builtin_analyzer_identities,
6 | |     select_analyzers,
7 | | )
  | |_^
8 |
9 |   __all__ = ["Analyzer", "builtin_analyzer_identities", "select_analyzers"]
  |
help: Organize imports

S101 Use of `assert` detected
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\registry.py:126:5
    |
124 |         return UiCallbackAnalyzer()
125 |     # The complete public selector check leaves only the dependency adapter here.
126 |     assert identifier == "dependencies"
    |     ^^^^^^
127 |     from drm_copilot_discovery.analyzer.dependencies import DependencyAnalyzer
    |

E501 Line too long (101 > 88)
   --> tests\discovery_runtime\analyzer\test_registry_dispatch.py:101:89
    |
 99 |             b'<Project Sdk="Microsoft.NET.Sdk"><PropertyGroup>'
100 |             b"<TargetFramework>net8.0</TargetFramework></PropertyGroup><ItemGroup>"
101 |             b'<COMReference Include="Interop"/><PackageReference Include="Example" Version="1.2.3"/>'
    |                                                                                         ^^^^^^^^^^^^^
102 |             b"</ItemGroup></Project>",
103 |         ),
    |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\analyzer\test_registry_dispatch.py:106:89
    |
104 |         (
105 |             "src/view.xaml",
106 |             b'<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" '
    |                                                                                         ^
107 |             b'xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" x:Class="Demo.View">'
108 |             b'<Button Click="OnClick"/></Window>',
    |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\analyzer\test_registry_dispatch.py:107:89
    |
105 |             "src/view.xaml",
106 |             b'<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" '
107 |             b'xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" x:Class="Demo.View">'
    |                                                                                         ^^
108 |             b'<Button Click="OnClick"/></Window>',
109 |         ),
    |

E501 Line too long (101 > 88)
   --> tests\discovery_runtime\analyzer\test_registry_dispatch.py:119:89
    |
117 |             "src/ribbon.xml",
118 |             b'<customUI xmlns="http://schemas.microsoft.com/office/2009/07/customui">'
119 |             b'<ribbon><tabs><tab id="tab"><group id="group"><button id="button" onAction="OnClick"/>'
    |                                                                                         ^^^^^^^^^^^^^
120 |             b"</group></tab></tabs></ribbon></customUI>",
121 |         ),
    |

Found 6 errors.
[*] 1 fixable with the `--fix` option.
```
