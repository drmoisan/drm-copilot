# P4-T6 consolidated-check lint

Timestamp: 2026-10-19T08-51
Command: `poetry run python -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/test_references.py packages/discovery-runtime/src/drm_copilot_discovery/analyzer/test_reference_syntax.py tests/discovery_runtime/analyzer/test_test_references.py tests/discovery_runtime/analyzer/test_test_reference_syntax.py`
EXIT_CODE: 1
Output Summary: Scoped development check with exact source bindings and raw diagnostics retained in JSON.

```text
I001 [*] Import block is un-sorted or un-formatted
  --> tests\discovery_runtime\analyzer\test_test_reference_syntax.py:3:1
   |
 1 |   """Verify finite reference grammars, public capacities and bounded lexical work."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | from typing import TYPE_CHECKING, cast
 6 | |
 7 | | import pytest
 8 | | from drm_copilot_discovery.analyzer import test_reference_syntax
 9 | | from drm_copilot_discovery.analyzer.csharp_tokens import (
10 | |     SourceScanError,
11 | |     Token,
12 | |     tokenize_csharp,
13 | | )
14 | | from drm_copilot_discovery.analyzer.source_text import strip_comments_and_strings
15 | | from drm_copilot_discovery.analyzer.test_reference_syntax import (
16 | |     project_reference_sites,
17 | |     type_mentions,
18 | | )
19 | | from drm_copilot_discovery.analyzer.test_references import (
20 | |     TestReferenceAnalyzer as ReferenceAnalyzer,
21 | | )
22 | | from tests.discovery_runtime.analyzer.test_dotnet_projects import catalog as catalog
23 | | from tests.discovery_runtime.analyzer.test_test_references import inputs, serialized
   | |____________________________________________________________________________________^
24 |
25 |   if TYPE_CHECKING:
   |
help: Organize imports

Found 1 error.
[*] 1 fixable with the `--fix` option.

```
