# p5t1-legacy-pass2-lint

Timestamp: 2026-10-19T14-51
Command: poetry run ruff check scripts/dev_tools/discovery/coverage_report.py tests/scripts/dev_tools/discovery/test_coverage_report.py tests/scripts/dev_tools/discovery/test_rendering.py
EXIT_CODE: 1
Output Summary: scoped lint; duration 1.154 seconds. Raw stdout/stderr hashes and SCRATCH-relative locations are separate from sanitized presentation.

```text
I001 [*] Import block is un-sorted or un-formatted
  --> scripts\dev_tools\discovery\coverage_report.py:8:1
   |
 6 |   """
 7 |
 8 | / from __future__ import annotations
 9 | |
10 | | import argparse
11 | | import sys
12 | | from pathlib import Path
13 | | from typing import TYPE_CHECKING
14 | |
15 | | from drm_copilot_discovery.report_models import (
16 | |     build_coverage_rows as build_coverage_rows,
17 | |     parse_coverage_ledger as parse_coverage_ledger,
18 | |     render_coverage_report as render_coverage_report,
19 | | )
20 | |
21 | | from scripts.dev_tools.discovery.io import (
22 | |     ArtifactValidationError,
23 | |     ArtifactValidator,
24 | |     read_artifact_text,
25 | |     validate_or_raise,
26 | |     write_report,
27 | | )
   | |_^
28 |
29 |   if TYPE_CHECKING:
   |
help: Organize imports

E501 Line too long (89 > 88)
   --> tests\scripts\dev_tools\discovery\test_coverage_report.py:261:89
    |
259 |     helper: str, monkeypatch: MonkeyPatch, capsys: pytest.CaptureFixture[str]
260 | ) -> None:
261 |     """For helper (str), catch ValueError without exposing its source-bearing message."""
    |                                                                                         ^
262 |     writes: list[str] = []
    |

E501 Line too long (90 > 88)
  --> tests\scripts\dev_tools\discovery\test_rendering.py:92:89
   |
91 | def test_coverage_adapter_retains_pretty_json_escaping_and_single_lf() -> None:
92 |     """Retain deterministic legacy bytes for Unicode/newlines without external effects."""
   |                                                                                         ^^
93 |     rows: list[dict[str, object]] = [
94 |         {
   |

Found 3 errors.
[*] 1 fixable with the `--fix` option.
```
