# P4-T4 bounded repair confirmation

Timestamp: 2026-10-19T06-38
Command: `poetry run python SCRATCH/issue-980-p4t4-repair-confirmation.py`
EXIT_CODE: 0
Output Summary: R1, R2 and R3 are confirmed closed on the frozen repaired candidate. Nine original bounded reproductions pass without timing thresholds. No broad test suite or predecessor review was replayed.

Status: **READY_FOR_FINAL_GATES**. This confirms the repair only; P4-T4 remains unchecked pending the scoped final ordered sequence.

Candidate commit: `5329894a0e8485c7837cc67f1700bf3764116fd2`.
The fresh `atomic_execution_p4t4_bounded_repair_confirmation` receipt and native attestation agree with the unchanged C4 Astra/max profile SHA-256 `ac681ebf70607a2d00c76e29d142df0a05751c0c375f0ee878cec30b29c044b9`; routing, launch authority and provenance are valid.

The [repair freeze](p4t4-repair-freeze.2026-10-19T06-32.json) has SHA-256 `59076e69064acac3b90609c73788d952d1774b59e8fb2477e5bb313526da335f`. The [independent confirmation JSON](p4t4-executor-repair-confirmation.2026-10-19T06-38.json), SHA-256 `761771c6a97b89dd28809a3d6bed9e36c9b8a8d2b0221f635793d243aee97281`, records the actual working/index/commit hashes, raw proof bindings and nine reproduction results. Its [exact harness](p4t4-executor-repair-confirmation-harness.2026-10-19T06-38.txt) has SHA-256 `e17f974bc9892f2e6a670664fd6dee38145ab23aba651d0a0ede7a7592a17ecf`.

- **R1:** Prospective RFC6901 paths and records reserve text before construction. Complete projected rows are charged across files before allocation; text overflow discards partial claims. The documented 12-byte-per-character reservation covers compact JSON with either ASCII policy, including astral surrogate-pair escapes. Retained regressions cover before-helper and before-projection rejection, escaped/multibyte identifiers, inherited INI paths, cross-file exhaustion and complete serialization. All three original long-prefix payload hashes now produce the fixed text-limit error.
- **R2:** The locator and ConfigParser share the fixed linear option expression. Both invalid and valid original whitespace families pass through exactly two matches each; total matched characters remain bounded by twice input length. The inherited overlapping matcher is prohibited. Retained 64-line regressions prove aggregate linear match input and both delimiters. No elapsed-time threshold is used.
- **R3:** The identified loop and assertion-comprehension comments are present, including comments for new repair behavior. All 16 original test/helper executable ASTs and parametrization are preserved.

Only the four approved Python paths changed. All eight current files exactly match working, index and committed bytes; four fixtures and 34 accepted dependency hashes remain unchanged. Python file lengths are 291, 440, 468 and 336 lines.

The retained clean focused sequence passes Black, Ruff, scoped Pyright and **91 tests (61 retained plus 30 new)**. Coverage remains accurately reported as **290/293 statements and 116/122 branch destinations**, with **23 measured class/callable ranges at least 90%**. Original failing runs, timed diagnostics and the separately documented checker-only false positive remain preserved in the supplied manifest.

There are no remaining findings or open probes. Reuse this confirmation and the completed original review during final receipt reconciliation if the bytes remain unchanged. Registry publication remains P4-T9, TOML remains explicitly unsupported, and direct-adapter proof is not native coding-agent-host proof.

Plan and AC files were unchanged: **35/84 tasks and 13/66 ACs**. Parent owns the scoped final-gate release, acceptance commit/push and successor release.
