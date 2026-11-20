# Autonomous Decision: Writer Reference in HarnessInstructions.psm1 (H3 Plan, P2-T4 Scope)

Timestamp: 2026-11-19T16-43
Plan: plan-h3-sync-writer-retirement.md
Finding: the P0-T1 search (`writer-reference-baseline.2026-11-19T14-36.md`) found `sync-agents-from-instructions` twice in `scripts/harness-generation/HarnessInstructions.psm1`, added by child 3 (#1028) and merged through the integration-branch sync after preflight: the module header comment and the finding detail text of the `GENERATED-NOTE` check. Neither is a `historical` (`docs/research/`) nor an `example` reference, so P2-T4 could not classify it and AC21 could not hold.
Options considered:
- A: leave it and classify it outside the two permitted classes; AC21 and the P2-T4 acceptance stay unmet.
- B (chosen): reword both texts so they describe the retired AGENTS.md sync writer without naming the deleted script path. The check's detection logic (the `> NOTE: This file is **generated** from:` line test) and its `Kind` are unchanged; `HarnessInstructions.Tests.ps1` asserts only `Kind` for `GENERATED-NOTE`.
Reason: option B removes a dangling reference to a file this item deletes, keeps AC21 satisfiable, changes no behavior other than the detail wording, and costs two lines; it is a related finding fixed inside the item (owner rule) and the recommended option under autonomous mode (OD-1, OD-4 cost-benefit). The spec non-goal "editing the shared-source generators (child 3)" concerns generator behavior; no generator output or detection rule changes.
Timing: made before P2-T1 so that the final static loop (P2-T1) and the final gates (P2-T2) cover it.
Change: `scripts/harness-generation/HarnessInstructions.psm1` header comment `GENERATED-NOTE` line and the `-Detail` text in the `GENERATED-NOTE` finding; the file is not bundled and not in any pack manifest.
Verification: PSScriptAnalyzer and formatter comparison TOTAL 0; `HarnessInstructions.Tests.ps1` task check recorded in `task-check.P2-T4-harness.<timestamp>.md`; WRITER-TOKENS count in the file 0.
