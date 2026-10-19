# P4-T4 final execution handoff

Timestamp: 2026-10-19T06-43
Command: `poetry run python SCRATCH/issue-980-final-handoff.py docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/qa-gates/p4t4-final-ordered-stages.2026-10-19T06-41.json`
EXIT_CODE: 0
Output Summary: All seven final stages passed in one clean loop on checked WIP 5329894a0e8485c7837cc67f1700bf3764116fd2. Executor acceptance is pending; no task or acceptance criterion was checked off by this worker.

| Stage | Gate | Seconds | Result |
| --- | --- | ---: | --- |
| 1 | format | 0.340709 | Pass |
| 2 | lint | 0.101769 | Pass |
| 3 | types | 11.684971 | Pass |
| 4 | architecture | 0.130019 | Pass |
| 5 | tests-reverse | 54.966804 | Pass |
| 6 | contracts | 1.589425 | Pass |
| 7 | native | 2.366120 | Pass |

The reverse-order suite passed all 91 cases, the established applicable contracts passed 176 cases, and native Windows/Git composition passed eight assertions. Production coverage is 290/293 statements and 116/122 branch destinations. All 23 retained class/callable ranges retain their exact counts and exceed the 90% statement requirement. Ruff, whole-repository Pyright and new-test-failure deltas are zero. The 34 accepted predecessor paths remain unchanged.

All eight source/test/fixture working, index and committed streams match exactly. The paired JSON binds actual Git attributes, blob IDs, raw outputs, module coverage and the exact test-node order. The original review and repair history are referenced through the immutable repair manifest and bounded R1–R3 confirmation; they are not repeated here. Exact final harness bytes are preserved as canonical text snapshots.

Downstream callers may use ConfigurationAnalyzer.analyze(InventoryCapture) for pure declared-key Analysis and parse_configuration for immutable ConfigurationKey tuples. The parser's optional max_text_bytes bounds prospective escaped paths and retained identifiers; the adapter additionally bounds complete aggregate projection. The documented 12-byte Unicode reservation covers compact UTF-8 JSON under either ensure_ascii policy, including surrogate pairs. It is a conservative finite allocation guard, not a heap measurement. Values, raw conditions and effective activation are never reported.

Public registry integration remains P4-T9. TOML is explicitly unsupported; JSON line positions are not invented. This proves direct Windows Python/Git integration, not native coding-agent-host execution or non-Windows CI. The three retained defensive parser gaps and exact supported format boundaries remain documented in the repair manifest.
