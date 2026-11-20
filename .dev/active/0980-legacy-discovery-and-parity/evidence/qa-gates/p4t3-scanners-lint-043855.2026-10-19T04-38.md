# P4-T3 scanners lint

Timestamp: 2026-10-19T04-38
Command: `poetry run python -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/csharp_declarations.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/event_subscriptions.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/dotnet_inventory.py tests/discovery_runtime/analyzer/test_csharp_declarations.py tests/discovery_runtime/analyzer/test_event_subscriptions.py tests/scripts/dev_tools/discovery/analyzer/test_dotnet_inventory.py scripts/dev_tools/discovery/analyzer/dotnet_inventory.py`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
E501 Line too long (167 > 88)
  --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\csharp_declarations.py:21:89
   |
19 | …m", "record"})
20 | …
21 | … partial readonly ref unsafe new virtual override file extern async required const volatile fixed".split()
   |                             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
22 | …
   |

E501 Line too long (99 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dotnet_inventory.py:188:89
    |
186 |                     id_prefix="dotnet",
187 |                     tool="dev.discovery.dotnet",
188 |                     description="Heuristic textual detection of C# declaration or handler syntax.",
    |                                                                                         ^^^^^^^^^^^
189 |                     detection=detection,
190 |                     captured_at=ctx.captured_at,
    |

E501 Line too long (95 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dotnet_inventory.py:311:89
    |
309 |             "compiler-binding-not-performed",
310 |             item.path,
311 |             "Lexical names, member candidates and assignment operands are not compiler-bound.",
    |                                                                                         ^^^^^^^
312 |             analyzer=identifier,
313 |             blocking=False,
    |

E501 Line too long (108 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dotnet_inventory.py:321:89
    |
319 |                 "preprocessing-not-evaluated",
320 |                 item.path,
321 |                 "All textual branches are inspected; active branches and #line mappings remain unresolved.",
    |                                                                                         ^^^^^^^^^^^^^^^^^^^^
322 |                 analyzer=identifier,
323 |                 blocking=False,
    |

E501 Line too long (97 > 88)
   --> packages\discovery-runtime\src\drm_copilot_discovery\analyzer\dotnet_inventory.py:331:89
    |
329 |                 "source-revision-unverified",
330 |                 item.path,
331 |                 "Capture matching immutable repository bytes before publishing C# observations.",
    |                                                                                         ^^^^^^^^^
332 |                 analyzer=identifier,
333 |             )
    |

I001 [*] Import block is un-sorted or un-formatted
  --> scripts\dev_tools\discovery\analyzer\dotnet_inventory.py:7:1
   |
 5 |   """
 6 |
 7 | / from drm_copilot_discovery.analyzer.dotnet_inventory import (
 8 | |     DotnetInventoryAnalyzer as DotnetInventoryAnalyzer,
 9 | |     classify_text as classify_text,
10 | | )
   | |_^
   |
help: Organize imports

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\analyzer\test_csharp_declarations.py:3:1
   |
 1 |   """Verify multiline lexical declarations, inferred members and exact source bytes."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | import hashlib
 6 | | from dataclasses import replace
 7 | | from pathlib import Path
 8 | | from typing import TYPE_CHECKING, cast
 9 | |
10 | | import pytest
11 | | from drm_copilot_discovery.analyzer.csharp_declarations import declaration_candidates
12 | | from drm_copilot_discovery.analyzer.csharp_tokens import SourceScanError
13 | | from drm_copilot_discovery.analyzer.dotnet_inventory import (
14 | |     CSharpDeclarationAnalyzer,
15 | |     DotnetInventoryAnalyzer,
16 | |     classify_text,
17 | | )
18 | | from drm_copilot_discovery.analyzer.emitter import inventory_result
19 | | from drm_copilot_discovery.analyzer.inventory import AnalyzerError
20 | | from drm_copilot_discovery.analyzer.models import (
21 | |     AnalyzerContext,
22 | |     ClassifyResult,
23 | |     InventoryInput,
24 | | )
25 | | from drm_copilot_discovery.analyzer.pipeline import RealAnalyzerFileSystem
26 | | from drm_copilot_discovery.analyzer.source_text import DetectionResult, TextParseResult
27 | | from scripts.dev_tools.discovery.analyzer.dotnet_inventory import (
28 | |     DotnetInventoryAnalyzer as LegacyAnalyzer,
29 | | )
30 | | from scripts.dev_tools.discovery.analyzer.dotnet_inventory import (
31 | |     classify_text as legacy_classify,
32 | | )
33 | | from tests.discovery_runtime.analyzer.test_dotnet_projects import capture, properties
34 | | from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog
   | |____________________________________________________________________________________^
35 |
36 |   if TYPE_CHECKING:
   |
help: Organize imports

TC003 Move standard library import `pathlib.Path` into a type-checking block
 --> tests\discovery_runtime\analyzer\test_csharp_declarations.py:7:21
  |
5 | import hashlib
6 | from dataclasses import replace
7 | from pathlib import Path
  |                     ^^^^
8 | from typing import TYPE_CHECKING, cast
  |
help: Move into type-checking block

E501 Line too long (99 > 88)
  --> tests\discovery_runtime\analyzer\test_csharp_declarations.py:81:89
   |
79 | def test_same_line_nested_partial_and_record_forms_remain_distinct() -> None:
80 |     """All inline declaration sites survive and record keywords do not duplicate."""
81 |     text = "partial class A { class B {} } partial class A {} record class R(); record struct S();"
   |                                                                                         ^^^^^^^^^^^
82 |     values = declaration_candidates("a.cs", text, include_members=False)
83 |     assert [(value.symbol, value.symbol_kind) for value in values] == [
   |

E501 Line too long (89 > 88)
   --> tests\discovery_runtime\analyzer\test_csharp_declarations.py:142:89
    |
140 | )
141 | def test_non_declaration_fragments_do_not_invent_names(source: str) -> None:
142 |     """str source contains incomplete/member-access syntax; no declaration is emitted."""
    |                                                                                         ^
143 |     assert declaration_candidates("a.cs", source) == ()
    |

E501 Line too long (98 > 88)
   --> tests\discovery_runtime\analyzer\test_csharp_declarations.py:157:89
    |
155 | ):
156 |     """Masked literals and directive text cannot create false source facts."""
157 |     text = '#region class Fake\n[A("class Hidden")] class Real { string s = """class Raw {}"""; }'
    |                                                                                         ^^^^^^^^^^
158 |     assert [
159 |         value.symbol
    |

E501 Line too long (100 > 88)
   --> tests\discovery_runtime\analyzer\test_csharp_declarations.py:166:89
    |
164 | def test_v2_schema_provenance_and_separate_inference(catalog: SchemaCatalog) -> None:
165 |     """SchemaCatalog validates rows with exact hashes and honest candidate statuses."""
166 |     payload = b"#if MODE\r\nclass First { public int Count; }\r\n#else\r\nclass Second {}\r\n#endif"
    |                                                                                         ^^^^^^^^^^^^
167 |     inputs = capture(catalog, (("src/a.cs", payload),))
168 |     result = CSharpDeclarationAnalyzer().analyze(inputs)
    |

E501 Line too long (93 > 88)
   --> tests\discovery_runtime\analyzer\test_csharp_declarations.py:198:89
    |
196 |     catalog: SchemaCatalog, pinned: bool
197 | ) -> None:
198 |     """catalog/pinned select missing or different bytes; all claims remain low confidence."""
    |                                                                                         ^^^^^
199 |     inputs = capture(catalog, (("src/a.cs", b"class A {}"),), pinned=pinned)
200 |     inputs = replace(
    |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\analyzer\test_csharp_declarations.py:286:89
    |
284 |     catalog: SchemaCatalog,
285 | ) -> None:
286 |     """SchemaCatalog supplies identical same-line sites whose offsets disambiguate IDs."""
    |                                                                                         ^^
287 |     inputs = capture(catalog, (("src/A.CS", b"partial class A {} partial class A {}"),))
288 |     first = CSharpDeclarationAnalyzer().analyze(inputs)
    |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\analyzer\test_csharp_declarations.py:351:89
    |
350 | def test_legacy_decode_failure_clears_prior_context(mem_fs_path: Path) -> None:
351 |     """In-memory invalid bytes fail explicitly and cannot reuse an earlier run context."""
    |                                                                                         ^^
352 |     path = mem_fs_path / "a.cs"
353 |     path.write_bytes(b"class A {}")
    |

I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\analyzer\test_event_subscriptions.py:3:1
   |
 1 |   """Keep possible handler assignments distinct from compiler/runtime event proof."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | from typing import TYPE_CHECKING, cast
 6 | |
 7 | | import pytest
 8 | | from drm_copilot_discovery.analyzer.dotnet_inventory import (
 9 | |     EventSubscriptionAnalyzer,
10 | |     classify_text,
11 | | )
12 | | from drm_copilot_discovery.analyzer.emitter import inventory_result
13 | | from drm_copilot_discovery.analyzer.event_subscriptions import subscription_candidates
14 | | from tests.discovery_runtime.analyzer.test_dotnet_projects import capture, properties
15 | | from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog
   | |____________________________________________________________________________________^
16 |
17 |   if TYPE_CHECKING:
   |
help: Organize imports

E501 Line too long (93 > 88)
  --> tests\discovery_runtime\analyzer\test_event_subscriptions.py:68:89
   |
66 | )
67 | def test_non_handler_or_incomplete_syntax_is_not_promoted(source: str) -> None:
68 |     """str source contains literals/arithmetic/incomplete syntax, so no candidate escapes."""
   |                                                                                         ^^^^^
69 |     assert subscription_candidates("a.cs", source) == ()
   |

E501 Line too long (90 > 88)
   --> tests\discovery_runtime\analyzer\test_event_subscriptions.py:134:89
    |
133 | def test_missing_source_pin_downgrades_relationships(catalog: SchemaCatalog) -> None:
134 |     """SchemaCatalog creates unpinned input; neither relationship nor finding verifies."""
    |                                                                                         ^^
135 |     result = EventSubscriptionAnalyzer().analyze(
136 |         capture(catalog, (("src/a.cs", b"x += Handler;"),), pinned=False)
    |

Found 18 errors.
[*] 3 fixable with the `--fix` option (1 hidden fix can be enabled with the `--unsafe-fixes` option).

```
