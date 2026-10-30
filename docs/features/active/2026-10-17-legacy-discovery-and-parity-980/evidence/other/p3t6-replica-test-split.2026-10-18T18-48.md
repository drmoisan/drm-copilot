# P3-T6 replica resolution test split

Timestamp: 2026-10-18 18:48:40 UTC

The plan-of-record governing contract permits splitting new modules within their named component when required by the 500-physical-line limit, with exact resulting paths recorded and the same behavior/tests retained.

Before creation, authorize exactly `tests/discovery_runtime/test_snapshot_replica_resolution.py` under the existing P3-T6 snapshot component. It owns the isolated typed-index regression for an imported canonical representative in a proven replica-equivalence group, with representative and alias manifest selection, deterministic source-contract selection, and unmatched physical-manifest rejection assertions.

Both prescribed snapshot behavior suites are already 489 physical lines and the fixture helper is 460 lines. The readable typed-index construction and assertions need approximately 45–60 lines. This additional test file avoids compressing or relocating existing assertions; no production module, helper module, or behavior is added.

The independent coverage reconciliation identified one newly missing statement and arc in `references.py`: line 243 and arc 242→243. Current coverage is 168/171 statements and 81/84 arcs, versus the accepted 152/154 and 74/76. No previously covered mapped line was lost. Exercising this real boundary should produce 169/171 statements and 82/84 arcs; these are expected values pending measurement.

The specialist owns this file and the existing authorized P3-T6 files. The executor independently verifies the assertion and current coverage, updates the final frozen inventory from nine to ten paths, and retains all existing tests. Narrow verification and a checked correction WIP commit precede the full ordered restart. The prior 430/430 test result remains valid historical evidence for its recorded bytes but does not satisfy current task acceptance. P3-T6 remains unchecked at 29/84 tasks and 11/66 criteria.
