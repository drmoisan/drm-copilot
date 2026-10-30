# p5t3-mechanical-pass1-lint

Timestamp: 2026-10-20T08-45
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/validation.py packages/discovery-runtime/src/drm_copilot_discovery/validation_operation.py tests/discovery_runtime/test_parity_report_projection.py tests/discovery_runtime/test_agent_output.py
EXIT_CODE: 1
Output Summary: lint, 1.181s; exact raw streams separately bound.

```text
I001 [*] Import block is un-sorted or un-formatted
  --> packages\discovery-runtime\src\drm_copilot_discovery\validation.py:3:1
   |
 1 |   """Compose explicit validation modes without issuing native authority."""
 2 |
 3 | / from __future__ import annotations
 4 | |
 5 | | from dataclasses import dataclass
 6 | | from typing import TYPE_CHECKING, Literal, TypeAlias
 7 | |
 8 | | from drm_copilot_discovery.agent_output import (
 9 | |     REPORT_KINDS,
10 | |     historical_report,
11 | |     validate_agent_output,
12 | | )
13 | | from drm_copilot_discovery.coverage_report import (
14 | |     coverage_preflight,
15 | |     unavailable_coverage_summary,
16 | | )
17 | | from drm_copilot_discovery.findings import Finding
18 | | from drm_copilot_discovery.models import to_plain_value
19 | | from drm_copilot_discovery.parity_report import (
20 | |     parity_preflight,
21 | |     unavailable_parity_summary,
22 | | )
23 | | from drm_copilot_discovery.validation_inputs import (
24 | |     input_problem as _problem,
25 | | )
26 | | from drm_copilot_discovery.validation_inputs import (
27 | |     report_input_digest as report_input_digest,
28 | | )
29 | | from drm_copilot_discovery.validation_inputs import (
30 | |     validate_inputs as _schema_findings,
31 | | )
32 | | from drm_copilot_discovery.validation_operation import _Validation, _findings
   | |_____________________________________________________________________________^
33 |
34 |   if TYPE_CHECKING:
   |
help: Organize imports

TC001 Move application import `drm_copilot_discovery.findings.Finding` into a type-checking block
  --> packages\discovery-runtime\src\drm_copilot_discovery\validation.py:17:44
   |
15 |     unavailable_coverage_summary,
16 | )
17 | from drm_copilot_discovery.findings import Finding
   |                                            ^^^^^^^
18 | from drm_copilot_discovery.models import to_plain_value
19 | from drm_copilot_discovery.parity_report import (
   |
help: Move into type-checking block

Found 2 errors.
[*] 1 fixable with the `--fix` option (1 hidden fix can be enabled with the `--unsafe-fixes` option).
```
