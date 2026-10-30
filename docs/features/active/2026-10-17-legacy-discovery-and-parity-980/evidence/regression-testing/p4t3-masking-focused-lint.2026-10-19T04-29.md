# p4t3-masking-focused-lint

Timestamp: 2026-10-19T04-29
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/analyzer/source_text.py scripts/dev_tools/discovery/analyzer/source_text.py tests/scripts/dev_tools/discovery/analyzer/test_source_text.py tests/discovery_runtime/analyzer/test_source_masking.py
EXIT_CODE: 1
Output Summary: FAIL scoped P4-T3 masking stage 2; duration 1.37 seconds. Exact source hashes are in the paired JSON receipt.

```text
I001 [*] Import block is un-sorted or un-formatted
  --> scripts\dev_tools\discovery\analyzer\source_text.py:3:1
   |
 1 |   """Preserve legacy imports through explicit aliases to the discovery runtime."""
 2 |
 3 | / from drm_copilot_discovery.analyzer.source_text import (
 4 | |     Detection as Detection,
 5 | | )
 6 | |
 7 | | from drm_copilot_discovery.analyzer.source_text import (
 8 | |     DetectionResult as DetectionResult,
 9 | | )
10 | |
11 | | from drm_copilot_discovery.analyzer.source_text import (
12 | |     TextParseResult as TextParseResult,
13 | | )
14 | |
15 | | from drm_copilot_discovery.analyzer.source_text import (
16 | |     build_evidence_id as build_evidence_id,
17 | | )
18 | |
19 | | from drm_copilot_discovery.analyzer.source_text import (
20 | |     build_evidence_record as build_evidence_record,
21 | | )
22 | |
23 | | from drm_copilot_discovery.analyzer.source_text import (
24 | |     numbered_lines as numbered_lines,
25 | | )
26 | |
27 | | from drm_copilot_discovery.analyzer.source_text import (
28 | |     slugify as slugify,
29 | | )
30 | |
31 | | from drm_copilot_discovery.analyzer.source_text import (
32 | |     strip_comments_and_strings as strip_comments_and_strings,
33 | | )
   | |_^
   |
help: Organize imports

I001 [*] Import block is un-sorted or un-formatted
  --> tests\scripts\dev_tools\discovery\analyzer\test_source_text.py:9:1
   |
 7 |   """
 8 |
 9 | / from __future__ import annotations
10 | |
11 | | import dataclasses
12 | | import re
13 | |
14 | | import pytest
15 | | from drm_copilot_discovery.analyzer import source_text as canonical
16 | |
17 | | from scripts.dev_tools.discovery.analyzer import source_text as compatibility
18 | | from scripts.dev_tools.discovery.analyzer.models import ClassifyResult
19 | | from scripts.dev_tools.discovery.analyzer.models import ParseResult
20 | | from scripts.dev_tools.discovery.analyzer.source_text import (
21 | |     TextParseResult,
22 | |     build_evidence_id,
23 | |     numbered_lines,
24 | |     slugify,
25 | |     strip_comments_and_strings,
26 | | )
   | |_^
27 |
28 |   # Shared discovery identifier grammar every evidence id must satisfy.
   |
help: Organize imports

B010 [*] Do not call `setattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\scripts\dev_tools\discovery\analyzer\test_source_text.py:375:9
    |
373 |     )
374 |     with pytest.raises(dataclasses.FrozenInstanceError):
375 |         setattr(detection, "line", 3)
    |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
376 |     with pytest.raises(dataclasses.FrozenInstanceError):
377 |         setattr(classified, "detections", ())
    |
help: Replace `setattr` with assignment

B010 [*] Do not call `setattr` with a constant attribute value. It is not any safer than normal property access.
   --> tests\scripts\dev_tools\discovery\analyzer\test_source_text.py:377:9
    |
375 |         setattr(detection, "line", 3)
376 |     with pytest.raises(dataclasses.FrozenInstanceError):
377 |         setattr(classified, "detections", ())
    |         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    |
help: Replace `setattr` with assignment

Found 4 errors.
[*] 4 fixable with the `--fix` option.
```
