# p4t6-ui-initial-lint

Timestamp: 2026-10-19T08-42
Command: poetry run ruff check --fix packages/discovery-runtime/src/drm_copilot_discovery/analyzer/ui_callbacks.py tests/discovery_runtime/analyzer/test_ui_callbacks.py tests/discovery_runtime/analyzer/test_ui_callback_limits.py
EXIT_CODE: 1
Output Summary: FAIL scoped UI stage lint; duration 1.159 seconds. Exact bytes and original command output are in the paired JSON.

```text
E501 Line too long (91 > 88)
  --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\ui_callbacks.py:48:89
   |
46 | }
47 | _ELEMENTS = frozenset(_EVENTS) | frozenset(
48 |     "Grid StackPanel DockPanel WrapPanel Canvas Border ScrollViewer ContentControl".split()
   |                                                                                         ^^^
49 | )
50 | _NAME = re.compile(r"[A-Za-z_][A-Za-z_0-9]*\Z")
   |

TC002 Move third-party import `drm_copilot_discovery.analyzer.models.InventoryInput` into a type-checking block
  --> tests\discovery_runtime\analyzer\test_ui_callback_limits.py:12:51
   |
10 | from drm_copilot_discovery.analyzer.csharp_tokens import SourceScanError
11 | from drm_copilot_discovery.analyzer.findings import pinned_matches
12 | from drm_copilot_discovery.analyzer.models import InventoryInput
   |                                                   ^^^^^^^^^^^^^^
13 | from drm_copilot_discovery.analyzer.ui_callbacks import (
14 |     UiCallbackAnalyzer,
   |
help: Move into type-checking block

E501 Line too long (89 > 88)
  --> tests\discovery_runtime\analyzer\test_ui_callback_limits.py:87:89
   |
86 |     def counted(local: InventoryCapture, item: InventoryInput) -> bool:
87 |         """Count local pin group sizes, return accepted exact-byte check; mutate list."""
   |                                                                                         ^
88 |         visits.append(len(local.repository_files))
89 |         return pinned_matches(local, item)
   |

E501 Line too long (94 > 88)
  --> tests\discovery_runtime\analyzer\test_ui_callbacks.py:45:89
   |
43 |     """Return synthetic UTF-8 bytes from str body/root/class/namespace; no I/O."""
44 |     return (
45 |         f'<{root} xmlns="{namespace}" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" '
   |                                                                                         ^^^^^^
46 |         f'x:Class="{escape(class_name, quote=True)}">{body}</{root}>'
47 |     ).encode()
   |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\analyzer\test_ui_callbacks.py:327:89
    |
325 |     catalog: SchemaCatalog,
326 | ) -> None:
327 |     """Model SchemaCatalog unavailable/excluded inputs; return None, no external reads."""
    |                                                                                         ^^
328 |     inputs = capture(
329 |         catalog, (("src/a.xaml", markup()), ("src/other.txt", b"SECRET")), pinned=False
    |


Fixed 3 errors:
- tests\discovery_runtime\analyzer\test_ui_callback_limits.py:
    2 × I001 (unsorted-imports)
- tests\discovery_runtime\analyzer\test_ui_callbacks.py:
    1 × I001 (unsorted-imports)

Found 8 errors (3 fixed, 5 remaining).
No fixes available (1 hidden fix can be enabled with the `--unsafe-fixes` option).
```
