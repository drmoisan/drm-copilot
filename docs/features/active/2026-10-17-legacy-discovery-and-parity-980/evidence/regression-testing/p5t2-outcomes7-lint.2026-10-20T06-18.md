# P5-T2 outcomes7-lint

Timestamp: 2026-10-20T06-18

Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/parity_models.py packages/discovery-runtime/src/drm_copilot_discovery/parity_rules.py packages/discovery-runtime/src/drm_copilot_discovery/parity_entry_rules.py tests/discovery_runtime/test_parity_models.py tests/discovery_runtime/test_parity_rules.py tests/discovery_runtime/test_parity_clients.py

EXIT_CODE: 1

Output Summary: Exact scoped stage completed in 1.187s; raw bytes are retained in the JSON receipt.

```text
TC002 Move third-party import `drm_copilot_discovery.models.ParseLimits` into a type-checking block
  --> tests\discovery_runtime\test_parity_models.py:12:42
   |
10 | from drm_copilot_discovery.claim_rules import ClaimContext
11 | from drm_copilot_discovery.findings import Finding
12 | from drm_copilot_discovery.models import ParseLimits
   |                                          ^^^^^^^^^^^
13 | from drm_copilot_discovery.parity_models import ParityValidation
14 | from drm_copilot_discovery.parity_rules import (
   |
help: Move into type-checking block

Found 1 error.
No fixes available (1 hidden fix can be enabled with the `--unsafe-fixes` option).
```
