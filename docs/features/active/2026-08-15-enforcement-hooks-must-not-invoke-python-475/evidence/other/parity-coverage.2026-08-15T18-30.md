# Parity-Coverage Artifact — Row-by-Row Mapping of the 85-Check Inventory — [P13-T1]

Timestamp: 2026-08-15T18-30

Command: inventory source `docs/features/active/2026-08-15-enforcement-hooks-must-not-invoke-python-475/research/2026-08-15T15-30-full-parity-check-inventory-and-bash-json-research.md` section 2 (rows), section 2.5 (totals). Mapping method: for each inventory row ID, locate the implementing PowerShell module and exported/internal function by reading `.claude/lib/**`, and locate the asserting Pester `It` by row-ID-keyed name in `tests/scripts/claude-lib/**`. Every row ID in the inventory appears exactly once below.

EXIT_CODE: 0

Output Summary: 85/85 rows mapped to an implementing module/function and an asserting test. 0 rows deferred. 0 rows unmapped. 6 pre-existing check rows + 2 pre-existing formulas (without check wiring) + 79 ported rows.

## Authoritative Recount and the Recorded Discrepancy

The research artifact's prose total (section 2.5, final paragraph) states "7 of 85 fully or substantially present (U1.1, U1.2 with divergent message text; U2.1; U3.1; U4.1; M1.1) plus the two pure formulas". That parenthetical enumerates **six** row IDs, not seven; the leading numeral "7" does not match its own enumeration. This row-by-row artifact is authoritative per the plan's binding scope state.

**Authoritative recount:**

- Pre-existing check rows: **6** — `U1.1`, `U1.2` (both with the documented message divergence), `U2.1`, `U3.1`, `U4.1`, `M1.1`.
- Pre-existing formulas without check wiring: **2** — `Get-ComplexityFloor` and `Resolve-DelegationModel` in `.claude/lib/model-routing/ModelRouting.psm1`, backing rows `U6.C5` and `U6.M4`. These are formulas, not check rows; the `U6.C5` and `U6.M4` **check wiring** was absent at HEAD `b1a86fd3` and is counted among the ported rows.
- Ported rows: **79** = 85 − 6.

The discrepancy between "7" and the enumerated 6 is a prose arithmetic error in the research artifact. It is recorded here as a discrepancy. **It is not an unmapped row and it is not a deferral.** Every one of the 85 rows below has an implementation and a test.

## Documented Divergences (recorded inline on their rows)

| Divergence | Rows affected | Disposition |
| --- | --- | --- |
| U1 load-error message text | `U1.1`, `U1.2` | The PowerShell loader emits path-prefixed messages (`Checkpoint file '<path>' is not valid JSON: <msg>`) and additionally surfaces missing-file and empty-file conditions that Python surfaces only as an uncaught `OSError` traceback. Exact-string parity with a traceback is not attainable; the fail-closed exit-code contract is preserved and the message divergence is documented. |
| PD-1 — pinned routing-matrix constants | `C3.1`, `C3.2`, `C4.1`–`C4.4`, `C6.1`–`C6.9` | The routing-matrix subset is embedded as pinned constants in `OrchestratorStateRoutingMatrix.psm1` with a static config-parity Pester test, instead of a validation-time disk read of `config/orchestration-routing.json`. Rationale: the config is not shipped to destinations, and a missing-config crash is the portability failure this feature removes. |
| PD-2 — single emission | `M3.1` (and, transitively, `U6.C*`/`U6.M*` under the completion call) | Python emits U6.C/U6.M errors twice under `--require-complete --require-model-routing` (once in the unconditional block, once in the M3 gate re-run). The port emits each error string exactly once under the completion call. Declared divergence. |
| PD-3 — epic/parallel dispatch | none of the 85 rows | Under the hook's flags the Python surface performs zero checkpoint checks for `epic-orchestrator-state` and `parallel-orchestrator-state` (argparse exit 2). The port's type-scoped structural check is defined fail-closed behavior in a region where Python parity is undefined. It is a design decision, not a deferral, and it maps to no inventory row. |

## Module and Test File Abbreviations

| Key | Path |
| --- | --- |
| OS | `.claude/lib/orchestrator-state/OrchestratorState.psm1` |
| OSC | `.claude/lib/orchestrator-state/OrchestratorStateCompletion.psm1` |
| OSR | `.claude/lib/orchestrator-state/OrchestratorStateReceipts.psm1` |
| OSMR | `.claude/lib/orchestrator-state/OrchestratorStateModelReceipts.psm1` |
| OSXR | `.claude/lib/orchestrator-state/OrchestratorStateCodexModelReceipts.psm1` |
| OSTR | `.claude/lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.psm1` |
| OSCC | `.claude/lib/orchestrator-state/OrchestratorStateCompletionChecks.psm1` |
| OSRC | `.claude/lib/orchestrator-state/OrchestratorStateRoutingContract.psm1` |
| OSRM | `.claude/lib/orchestrator-state/OrchestratorStateRoutingMatrix.psm1` |
| OSU | `.claude/lib/orchestrator-state/OrchestratorStateUnconditional.psm1` |
| MR | `.claude/lib/model-routing/ModelRouting.psm1` |
| T-OS | `tests/scripts/claude-lib/orchestrator-state/OrchestratorState.Tests.ps1` |
| T-OSC | `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletion.Tests.ps1` |
| T-OSR | `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateReceipts.Tests.ps1` |
| T-OSMR | `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateModelReceipts.Tests.ps1` |
| T-OSXR | `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexModelReceipts.Tests.ps1` |
| T-OSTR | `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCodexTopologyReceipts.Tests.ps1` |
| T-OSCC | `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateCompletionChecks.Tests.ps1` |
| T-OSRC | `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingContract.Tests.ps1` |
| T-OSU | `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateUnconditional.Tests.ps1` |

Status legend: **PRE** = pre-existing check row at HEAD `b1a86fd3`; **PORT** = ported by this feature.

---

## U Family — Unconditional Block (57 rows)

### U1 — parse and root (2 rows)

| Row | Status | Implementation | Test |
| --- | --- | --- | --- |
| U1.1 | PRE | OS `Get-OrchestratorStateCheckpoint` | T-OS `returns ExitCode 1 when the checkpoint is not valid JSON`; also `returns ExitCode 1 when the checkpoint file is missing`, `returns ExitCode 1 when the checkpoint file exists but is empty` — **documented U1 message divergence** (path-prefixed text; missing/empty-file cases have no Python string equivalent) |
| U1.2 | PRE | OS `Get-OrchestratorStateCheckpoint` | T-OS `returns ExitCode 1 when the checkpoint root is not a JSON object` — **documented U1 message divergence** (path-prefixed text) |

### U2–U4 — required keys, step status, blocked_reason (3 rows)

| Row | Status | Implementation | Test |
| --- | --- | --- | --- |
| U2.1 | PRE | OS `Get-OrchestratorStateBasePresenceError` (22-key constant set) | T-OS `returns ExitCode 1 for a missing required key`; aggregation via T-OSU `surfaces a missing required key` |
| U3.1 | PRE | OS `Get-OrchestratorStateBasePresenceError` (per-key status vocabularies) | T-OS `rejects <value> on <key>` (`-ForEach` matrix), `accepts step9_status value <_>`, `accepts step6_status value blocked_remediation_loop_limit`; aggregation via T-OSU `surfaces an invalid step status` |
| U4.1 | PRE | OS `Get-OrchestratorStateBasePresenceError` | T-OS `returns ExitCode 1 with a base error when blocked_reason is outside the allowed vocabulary`; aggregation via T-OSU `surfaces an invalid blocked_reason` |

### U5 — delegation_receipts shape (8 rows)

| Row | Status | Implementation | Test |
| --- | --- | --- | --- |
| U5.1 | PORT | OSR `Get-DelegationReceiptListError` | T-OSR `U5.1 reports a non-object list entry` |
| U5.2 | PORT | OSR `Get-DelegationReceiptListError` | T-OSR `U5.2 reports each missing receipt key by name`; `U5.2 treats a present null key as satisfied (presence, not truthiness)` |
| U5.3 | PORT | OSR `Get-DelegationReceiptListError` | T-OSR `U5.3 reports a non-list artifact_paths` |
| U5.4 | PORT | OSR `Get-DelegationReceiptNamespaceError` | T-OSR `U5.4 reports an unsupported object-form namespace key`; `U5.4 orders unsupported keys ordinally, matching Python sorted()` |
| U5.5 | PORT | OSR `Get-DelegationReceiptNamespaceError` | T-OSR `U5.5 reports a non-list agents namespace`; `U5.5 applies the list-form rows to a well-formed agents namespace` |
| U5.6 | PORT | OSR `Get-DelegationReceiptNamespaceError` | T-OSR `U5.6 reports a non-object promotion namespace`; `U5.6 treats a null promotion namespace as absent` |
| U5.7 | PORT | OSR `Get-DelegationReceiptNamespaceError` | T-OSR `U5.7 reports an unsupported promotion sub-key` |
| U5.8 | PORT | OSR `Get-OrchestratorStateDelegationReceiptError` | T-OSR `U5.8 reports a delegation_receipts value that is neither list nor object` |

Family passing fixtures: T-OSR `passes a well-formed list-form receipt (U5 passing fixture)`, `passes a well-formed object-form namespace (U5 passing fixture)`, `contributes no error when delegation_receipts is null (absent-key parity)`.

### U6.R — remediation_loop (4 rows)

| Row | Status | Implementation | Test |
| --- | --- | --- | --- |
| U6.R1 | PORT | OSR `Get-OrchestratorStateRemediationLoopError` | T-OSR `U6.R1 reports a non-object cycle` |
| U6.R2 | PORT | OSR `Get-RemediationCycleError` | T-OSR `U6.R2 reports a missing plan_path`; `U6.R2 reports a whitespace-only plan_path` |
| U6.R3 | PORT | OSR `Get-RemediationCycleError` | T-OSR `U6.R3 reports execution recorded before preflight cleared`; `U6.R3 treats a missing preflight object as not cleared`; `U6.R3 does not fire for an execution_status outside the blocked set` |
| U6.R4 | PORT | OSR `Get-RemediationCycleError` | T-OSR `U6.R4 reports a satisfied exit gate with non-zero blocking_count`; `U6.R4 reports a satisfied exit gate with an absent blocking_count`; `U6.R4 does not fire when exit_condition_met is merely truthy, not boolean true` |

Family passing / tolerance fixtures: T-OSR `passes a well-formed cycle (U6.R passing fixture)`, `contributes zero errors for a non-object remediation_loop (Python tolerance)`, `contributes zero errors for a non-list cycles value (Python tolerance)`, `reports each malformed cycle with its own index`.

### U6.H — human_interaction (5 rows)

| Row | Status | Implementation | Test |
| --- | --- | --- | --- |
| U6.H1 | PORT | OSR `Get-OrchestratorStateHumanInteractionError` | T-OSR `U6.H1 reports a non-object human_interaction value` |
| U6.H2 | PORT | OSR `Get-OrchestratorStateHumanInteractionError` | T-OSR `U6.H2 reports a missing requirements list`; `U6.H2 reports a non-list requirements value` |
| U6.H3 | PORT | OSR `Get-OrchestratorStateHumanInteractionError` | T-OSR `U6.H3 reports a non-object requirement` |
| U6.H4 | PORT | OSR `Get-OrchestratorStateHumanInteractionError` | T-OSR `U6.H4 reports an out-of-enum response with the raw value interpolated`; `U6.H4 renders an absent response as Python None` |
| U6.H5 | PORT | OSR `Get-OrchestratorStateHumanInteractionError` | T-OSR `U6.H5 reports an exception response with no runbook_path`; `U6.H5 reports an exception response with a whitespace-only runbook_path`; `U6.H5 does not fire for a non-exception response missing a runbook_path` |

Reconciliation (spec Parity Contract, AC-25): these library checks are **additive** to the stricter hook-internal `Test-HumanInteractionShape` in `.claude/hooks/validate-orchestrator-output.ps1`, which is retained byte-unchanged and continues to run for all artifact types. Strictness never decreases. Both-layers proof: `tests/scripts/claude-hooks/validate-orchestrator-output.artifact-type-dispatch.Tests.ps1`.

### U6.C — complexity_assessments per-entry (7 rows)

| Row | Status | Implementation | Test |
| --- | --- | --- | --- |
| U6.C1 | PORT | OSMR `Get-OrchestratorStateComplexityAssessmentError` | T-OSMR `U6.C1 reports a non-list complexity_assessments value` |
| U6.C2 | PORT | OSMR `Get-OrchestratorStateComplexityAssessmentError` | T-OSMR `U6.C2 reports a non-object entry` |
| U6.C3 | PORT | OSMR `Get-ComplexityAssessmentEntryError` | T-OSMR `U6.C3 reports an out-of-enum band with the raw value interpolated`; `U6.C3 renders an absent band as Python None` |
| U6.C4 | PORT | OSMR `Get-ComplexityAssessmentEntryError` (via `Get-CheckpointStringList`) | T-OSMR `U6.C4 reports a non-list signals_present`; `U6.C4 reports a signals_present list holding a non-string element`; `U6.C4 suppresses the floor-equality check when signals_present is malformed` |
| U6.C5 | PORT (check wiring); formula PRE | OSMR `Get-ComplexityAssessmentEntryError` calling MR `Get-ComplexityFloor` — **the single formula implementation, not a re-implementation** | T-OSMR `U6.C5 reports a floor that does not equal the recomputed floor`; `U6.C5 renders an absent floor as Python None`; reuse assertion `U6.C5 recomputes the floor by calling the shared Get-ComplexityFloor` |
| U6.C6 | PORT | OSMR `Get-ComplexityAssessmentEntryError` | T-OSMR `U6.C6 reports a band below its floor`; `U6.C6 does not fire when the band enum is already invalid` |
| U6.C7 | PORT | OSMR `Get-ComplexityAssessmentEntryError` | T-OSMR `U6.C7 reports a missing rationale`; `U6.C7 reports a whitespace-only rationale` |

Family passing fixtures: T-OSMR `passes a well-formed assessment (U6.C passing fixture)`, `passes an assessment with no floor signals and a C1 floor`, `reports each malformed entry with its own index`.

### U6.M — model_routing_receipts per-entry (6 rows)

| Row | Status | Implementation | Test |
| --- | --- | --- | --- |
| U6.M1 | PORT | OSMR `Get-OrchestratorStateModelRoutingReceiptError` | T-OSMR `U6.M1 reports a non-list model_routing_receipts value` |
| U6.M2 | PORT | OSMR `Get-OrchestratorStateModelRoutingReceiptError` | T-OSMR `U6.M2 reports a non-object entry` |
| U6.M3 | PORT | OSMR `Get-ModelRoutingReceiptEntryError` | T-OSMR `U6.M3 reports an out-of-enum complexity_band with the raw value interpolated`; `U6.M3 stops the receipt so no model comparison is attempted` |
| U6.M4 | PORT (check wiring); formula PRE | OSMR `Get-ModelRoutingReceiptEntryError` calling MR `Resolve-DelegationModel` — **the single formula implementation, not a re-implementation** | T-OSMR `U6.M4 reports a model that does not equal the resolved model`; `U6.M4 renders an absent model as Python None`; `U6.M4 honors the preferred overlay for an overlay agent at C3`; reuse assertion `U6.M4 resolves the expected model by calling the shared Resolve-DelegationModel` |
| U6.M5 | PORT | OSMR `Get-ModelRoutingDisabledClampError` | T-OSMR `U6.M5 reports a fable model under the disabled policy`; `U6.M5 and U6.M6 do not fire outside the disabled policy` |
| U6.M6 | PORT | OSMR `Get-ModelRoutingDisabledClampError` | T-OSMR `U6.M6 reports a disabled-policy fable table cell with no clamp provenance` |

Family passing fixtures: T-OSMR `passes a well-formed receipt (U6.M passing fixture)`, `passes a correctly clamped disabled-policy fable table cell`, `reports each malformed receipt with its own index`.

### U6.X — codex_model_routing_receipts per-entry (11 rows)

| Row | Status | Implementation | Test |
| --- | --- | --- | --- |
| U6.X1 | PORT | OSXR `Get-OrchestratorStateCodexModelRoutingReceiptError` | T-OSXR `U6.X1 reports a non-list value` |
| U6.X2 | PORT | OSXR `Get-OrchestratorStateCodexModelRoutingReceiptError` | T-OSXR `U6.X2 reports a non-object entry with bracket index notation` |
| U6.X3 | PORT | OSXR `Get-OrchestratorStateCodexModelRoutingReceiptError` (10 required keys) | T-OSXR `U6.X3 reports every missing required key in one comma-joined error`; `U6.X3 stops the receipt so no resolver comparison is attempted` |
| U6.X4 | PORT | OSXR `Get-OrchestratorStateCodexModelRoutingReceiptError` | T-OSXR `U6.X4 reports a blank phase`; `U6.X4 does not stop the receipt, so resolver checks still run` |
| U6.X5 | PORT | OSXR `Get-OrchestratorStateCodexModelRoutingReceiptError` calling `Resolve-CodexDeployment` (`.claude/lib/codex-routing/CodexDeployment.psm1`) — **single resolver implementation** | T-OSXR `U6.X5 reports an invalid routing input with the resolver message text`; `U6.X5 reports an unsupported logical agent through the same surface`; `U6.X5 stops the receipt so no resolved-key comparison is attempted` |
| U6.X6 | PORT | OSXR `Get-OrchestratorStateCodexModelRoutingReceiptError` (ceiling monotonicity) | T-OSXR `U6.X6 reports a ceiling that drops between receipts`; `U6.X6 suppresses the transition check for the offending receipt` |
| U6.X7 | PORT | OSXR `Get-CodexCeilingTransitionError` | T-OSXR `U6.X7 reports transition evidence on the first receipt, where no rise is possible`; `U6.X7 reports transition evidence when the ceiling is unchanged` |
| U6.X8 | PORT | OSXR `Get-CodexCeilingTransitionError` | T-OSXR `U6.X8 reports a rise with no transition object`; `U6.X8 reports a rise whose transition is not an object` |
| U6.X9 | PORT | OSXR `Get-CodexCeilingTransitionError` | T-OSXR `U6.X9 reports a transition recording the wrong from/to pair` |
| U6.X10 | PORT | OSXR `Get-CodexCeilingTransitionError` | T-OSXR `U6.X10 reports an empty affected_delegation_ids list`; `U6.X10 reports duplicated affected_delegation_ids`; `U6.X10 reports a non-string affected_delegation_ids member` |
| U6.X11 | PORT | OSXR `Get-CodexModelRoutingResolvedKeyError` (9 resolved keys, Python `repr()`-style interpolation) | T-OSXR `U6.X11 reports a mismatched string key with repr() rendering on both sides`; `U6.X11 reports a mismatched boolean key with Python capitalization`; `U6.X11 reports a mismatched null key as None`; `U6.X11 reports every mismatched key, not only the first` |

Family passing / reuse fixtures: T-OSXR `passes a receipt that matches the resolver exactly`, `passes an empty receipt list`, `passes a sequence whose ceiling never changes`, `passes a rise carrying complete and correct transition evidence`, `reports each malformed receipt with its own index`, resolver-reuse assertion `obtains the expected deployment by calling Resolve-CodexDeployment`.

### U6.T — codex_topology_receipts per-entry (11 rows)

| Row | Status | Implementation | Test |
| --- | --- | --- | --- |
| U6.T1 | PORT | OSTR `Get-OrchestratorStateCodexTopologyReceiptError` | T-OSTR `U6.T1 reports a non-list value` |
| U6.T2 | PORT | OSTR `Get-OrchestratorStateCodexTopologyReceiptError` | T-OSTR `U6.T2 reports a non-object entry with bracket index notation` |
| U6.T3 | PORT | OSTR `Get-OrchestratorStateCodexTopologyReceiptError` (13 required keys) | T-OSTR `U6.T3 reports every missing required key in one comma-joined error`; `U6.T3 stops the receipt so no type check or resolution is attempted` |
| U6.T4 | PORT | OSTR `Get-OrchestratorStateCodexTopologyReceiptError` | T-OSTR `U6.T4 reports a blank phase` |
| U6.T5 | PORT | OSTR `Get-CodexTopologyInputError` | T-OSTR `U6.T5 reports a non-list languages value`; `U6.T5 reports a languages list holding a blank string` |
| U6.T6 | PORT | OSTR `Get-CodexTopologyInputError` (boolean explicitly rejected where integer required) | T-OSTR `U6.T6 rejects a boolean production_file_count`; `U6.T6 rejects a boolean test_file_count`; `U6.T6 rejects a string production_file_count`; `U6.T6 rejects a null test_file_count`; `U6.T6 accepts a zero file count, which is an integer` |
| U6.T7 | PORT | OSTR `Get-CodexTopologyInputError` | T-OSTR `U6.T7 reports a non-boolean cross_cutting` |
| U6.T8 | PORT | OSTR `Get-CodexTopologyInputError` | T-OSTR `U6.T8 reports a non-string execution_context` |
| U6.T9 | PORT | OSTR `Get-CodexTopologyInputError` reading `Get-CodexForcedRootPersona` (`CodexTopology.psm1`) | T-OSTR `U6.T9 reports an out-of-enum root_persona with the sorted tuple`; `U6.T9 accepts a null root_persona`; `reads the permitted root personas from Get-CodexForcedRootPersona` |
| U6.T10 | PORT | OSTR `Get-OrchestratorStateCodexTopologyReceiptError` calling `Resolve-CodexTopology` (`.claude/lib/codex-routing/CodexTopology.psm1`) — **single resolver implementation** | T-OSTR `U6.T10 reports an invalid routing input with the resolver message text`; `U6.T10 reports a forced root persona outside standalone context`; `U6.T10 stops the receipt so no resolved-key comparison is attempted` |
| U6.T11 | PORT | OSTR `Get-CodexTopologyResolvedKeyError` (12 resolved keys, Python `repr()`-style interpolation) | T-OSTR `U6.T11 reports a mismatched list-valued key as a Python list literal`; `U6.T11 reports a mismatched string key with repr() rendering`; `U6.T11 reports a mismatched integer key`; `U6.T11 reports a null expected budget rendered as None`; `U6.T11 reports every mismatched key, not only the first` |

Family passing / reuse fixtures: T-OSTR `passes a receipt that matches the resolver exactly`, `passes an escalation receipt carrying null budgets`, `passes a forced root persona receipt`, `reports each malformed receipt with its own index`, `an input type error stops the receipt before resolution`, resolver-reuse assertion `obtains the expected topology by calling Resolve-CodexTopology`.

**U-family subtotal: 57 rows (2 + 3 + 8 + 4 + 5 + 7 + 6 + 11 + 11). All mapped.**

U-family aggregation entry point: OSU `Get-OrchestratorStateUnconditionalError`, composing OS base checks with OSR, OSMR, OSXR, OSTR under Python key-gated semantics. Aggregation proof: T-OSU (19 tests, including `surfaces a U6.R remediation-cycle error`, `surfaces a U6.H human-interaction error`, `surfaces a U6.C complexity-assessment error`, `surfaces a U6.M model-routing-receipt error`, `surfaces a U6.X codex model-routing-receipt error`, `surfaces a U6.T codex topology-receipt error`, `surfaces errors from several families at once`, `contributes zero errors for every absent optional key`).

---

## C Family — `--require-complete` Block (25 rows)

| Row | Status | Implementation | Test |
| --- | --- | --- | --- |
| C1.1 | PORT | OSCC `Get-OrchestratorStateCompletionStepStatusError` (full five-value blocking set) | T-OSCC `C1.1 reports a pending step status`; `C1.1 reports every value in the five-value blocking set`; `C1.1 does not block on the documented S9 success value passed`; `C1.1 reports in step-key order` |
| C2.1 | PORT | OSCC `Get-OrchestratorStateCompletionBlockedReasonError` (backtick-quoted `none`) | T-OSCC `C2.1 reports any other blocked_reason, quoting none with backticks`; passing fixtures `passes an absent blocked_reason`, `passes a null blocked_reason`, `passes the literal none` |
| C3.1 | PORT — **PD-1 route gate via pinned constants** | OSCC `Get-OrchestratorStateCompletionPrGateError`, route-gated by OSRM `Test-OrchestratorStateRouteRequiresPrGate` | T-OSCC `C3.1 reports an absent pr_gate on a gated route`; `C3.1 reports a non-object pr_gate and does not additionally list fields` |
| C3.2 | PORT — **PD-1** | OSCC `Get-OrchestratorStateCompletionPrGateError` via `Get-MissingGateKey` (absent-or-blank counts as missing) | T-OSCC `C3.2 names each absent or blank pr_gate field` |
| C4.1 | PORT — **PD-1**, absent-flag-keeps-gate-on | OSCC `Get-OrchestratorStateCompletionCiGateError`, route-gated by OSRM `Test-OrchestratorStateRouteRequiresCiGate` | T-OSCC `C4.1 reports an absent ci_gate on a gated route`; `C4.1 reports a non-object ci_gate and stops there` |
| C4.2 | PORT — **PD-1** | OSCC `Get-OrchestratorStateCompletionCiGateError` via `Get-MissingGateKey` | T-OSCC `C4.2 names each absent or blank ci_gate field` |
| C4.3 | PORT — **PD-1** | OSCC `Get-OrchestratorStateCompletionCiGateError` | T-OSCC `C4.3 reports a conclusion other than success` |
| C4.4 | PORT — **PD-1** | OSCC `Get-OrchestratorStateCompletionCiGateError` | T-OSCC `C4.4 reports a ci_gate head_sha that does not match pr_gate`; `C4.4 does not fire when pr_gate head_sha is null` |
| C5.1 | PORT (static map; no config read in Python either) | OSCC `Get-OrchestratorStatePhaseCompletenessError` (`small` and `preparation` only) | T-OSCC `C5.1 reports a missing mandatory phase, naming the route and the phase`; `C5.1 reports both mandatory phases for the preparation route`; `C5.1 treats a malformed completed_steps as recording no phases` |
| C6.1 | PORT — **PD-1** | OSRC `Get-OrchestratorStateRoutingContractError` reading OSRM `Get-OrchestratorStateRoutingMatrix` | T-OSRC `C6.1 reports a matrix carrying no routes object`; `C6.1 reports a matrix whose routes member is not a mapping` |
| C6.2 | PORT — **PD-1** | OSRC `Get-OrchestratorStateRoutingContractError` via OSRM `Get-OrchestratorStateSelectedRouteId` | T-OSRC `C6.2 reports a checkpoint that names no route`; `C6.2 reports a blank route id` |
| C6.3 | PORT — **PD-1** | OSRC `Get-OrchestratorStateRoutingContractError` via OSRM `Get-OrchestratorStateRoute` | T-OSRC `C6.3 reports a fabricated route, naming it`; `resolves the route from path_selected when route_id is absent` |
| C6.4 | PORT — **PD-1** | OSRC `Get-OrchestratorStateRoutingContractError` via OSRM `Get-OrchestratorStateRouteRequiredList` | T-OSRC `C6.4 reports a required_agents list that does not match the matrix`; `C6.4 reports an absent required_agents list`; `C6.4 treats a differently ordered list as a mismatch` |
| C6.5 | PORT — **PD-1** | OSRC `Get-OrchestratorStateRoutingContractError` via OSRM `Get-OrchestratorStateRouteRequiredList` | T-OSRC `C6.5 reports a required_skills list that does not match the matrix` |
| C6.6 | PORT — **PD-1** | OSRC `Get-OrchestratorStateRoutingContractError` via `Get-ResolvedRequiredMcpTool` (bug-promotion substitution `new_potential_entry` → `new_potential_bug_entry` only when `promotion-type == "bug"`) | T-OSRC `C6.6 reports a required_mcp_tools list that does not match the matrix`; substitution fixtures `expects the bug-type promotion-entry tool when promotion-type is bug`, `accepts the bug-type promotion-entry tool in the declared list`, `leaves the matrix list unchanged for a feature promotion`, `leaves the matrix list unchanged when promotion-type is absent`, `substitutes every occurrence while preserving the other tools and their order` |
| C6.7 | PORT | OSRC `Get-CheckpointReceiptAgentName` | T-OSRC `C6.7 reports a required agent with no delegation receipt`; `C6.7 accepts the object namespace form of delegation_receipts` |
| C6.8 | PORT | OSRC `Get-CheckpointAcknowledgedName` (`required is True` and non-empty `evidence`) | T-OSRC `C6.8 reports a required skill with no acknowledged receipt`; `C6.8 does not count a skill receipt whose required flag is false`; `C6.8 does not count a skill receipt with blank evidence` |
| C6.9 | PORT | OSRC `Get-CheckpointAcknowledgedName` (`ok is True` and non-empty `evidence`) | T-OSRC `C6.9 reports a required MCP tool with no successful receipt`; `C6.9 does not count an MCP receipt whose ok flag is false` |
| C6.10 | PORT (both message variants; present-key semantics) | OSRC `Get-CompletionEmptyListError` | T-OSRC `C6.10 reports a non-list local_execution_overrides with the list-shape variant`; `C6.10 reports an absent local_execution_overrides with the list-shape variant`; `C6.10 reports a non-empty local_execution_overrides with the emptiness variant` |
| C6.11 | PORT (both message variants) | OSRC `Get-CompletionEmptyListError` | T-OSRC `C6.11 reports a non-list delegation_bypasses with the list-shape variant`; `C6.11 reports a non-empty delegation_bypasses with the emptiness variant` |
| C6.12 | PORT | OSRC `Get-LifecycleOperationError` | T-OSRC `C6.12 reports a non-list lifecycle_operations`; `C6.12 contributes nothing when lifecycle_operations is absent`; `C6.12 contributes nothing when lifecycle_operations is null` |
| C6.13 | PORT | OSRC `Get-LifecycleOperationError` | T-OSRC `C6.13 reports a non-object lifecycle operation with its index` |
| C6.14 | PORT | OSRC `Get-LifecycleOperationError` | T-OSRC `C6.14 reports an operation that did not use the MCP surface`; `C6.14 reports an operation with no surface at all` |
| C7.1 | PORT (Python `repr()` interpolation) | OSCC `Get-OrchestratorStatePreparationTerminalError` | T-OSCC `C7.1 reports a wrong next_step with repr() rendering on both sides`; `C7.1 renders an absent next_step as None` |
| C7.2 | PORT (Python `repr()` interpolation, all six step keys) | OSCC `Get-OrchestratorStatePreparationTerminalError` | T-OSCC `C7.2 reports a step status other than not-applicable with repr() rendering`; `C7.2 reports all six step keys when every one is absent` |

Route-gate on/off proofs (PD-1): T-OSCC `route gate off: contributes nothing on a route whose flag is absent`, `route gate off: contributes nothing on a route whose flag is false`, `route gate off: contributes nothing when no route is selected`, `route gate on by default: fires for a route whose flag is absent`, `route gate on by default: fires when no route is selected`, `route gate off: contributes nothing on a route whose flag is exactly false`.

PD-1 pinned-constant parity oracle: `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRoutingMatrix.Tests.ps1` reads `config/orchestration-routing.json` **at test time only** and pins every constant against it. `OrchestratorStateRoutingMatrix.psm1` performs no disk read at validation time.

**C-family subtotal: 25 rows (1 + 1 + 2 + 4 + 1 + 14 + 2). All mapped.**

---

## M Family — `--require-model-routing` Block (3 rows)

| Row | Status | Implementation | Test |
| --- | --- | --- | --- |
| M1.1 | PRE | OSC `Get-OrchestratorStateModelRoutingGateError` (delegated-agent set from `Get-OrchestratorStateDelegatedAgent`; receipt agents from `Get-OrchestratorStateRoutingReceiptAgent`) | T-OSC `returns ExitCode 1 with a model_routing_receipts message for an uncovered delegated agent`; `returns ExitCode 0 when every delegated agent has a routing receipt`; `treats a delegating next_step as a delegated agent requiring a receipt`; `returns ExitCode 0 for a delegation-free checkpoint (gate imposes no requirement)` |
| M2.1 | PORT | OSC `Get-OrchestratorStateModelRoutingGateError` via `Get-OrchestratorStateMatchedReceiptPhase` and `Get-OrchestratorStateAssessedPhase` | T-OSC `reports a matched receipt phase that carries no complexity assessment`; `reports a matched receipt phase when the assessments array is absent`; `does not require an assessment for a receipt that matched no delegated agent`; `passes when every matched receipt phase carries an assessment` |
| M3.1 | PORT — **PD-2 single emission** | OSC gate invokes the same OSMR per-entry validators (`Get-OrchestratorStateModelRoutingReceiptError`, `Get-OrchestratorStateComplexityAssessmentError`) — never a re-implementation; `Add-OrchestratorStateErrorOnce` enforces single emission | Reuse assertions T-OSC `invokes the shared model-routing per-entry validator from the gate`, `invokes the shared complexity per-entry validator from the gate`; PD-2 single-emission assertions T-OSC `emits a malformed model_routing_receipts error exactly once`, `emits a malformed complexity_assessments error exactly once`, `emits no duplicate line anywhere in the completion output` |

**M-family subtotal: 3 rows. All mapped.**

---

## Totals and Verdict

| Family | Inventory rows | Mapped | Pre-existing check rows | Ported rows |
| --- | --- | --- | --- | --- |
| U | 57 | 57 | 5 (`U1.1`, `U1.2`, `U2.1`, `U3.1`, `U4.1`) | 52 |
| C | 25 | 25 | 0 | 25 |
| M | 3 | 3 | 1 (`M1.1`) | 2 |
| **Total** | **85** | **85** | **6** | **79** |

Plus 2 pre-existing formulas without check wiring at HEAD `b1a86fd3`: `Get-ComplexityFloor` and `Resolve-DelegationModel` (`.claude/lib/model-routing/ModelRouting.psm1`), now consumed by the ported `U6.C5` and `U6.M4` check wiring as the single implementation.

- **Unmapped rows: 0.**
- **Deferred rows: 0.** No check family is deferred, scoped out, or recorded as a follow-up.
- **Documented divergences: 4 classes** — U1 load-error messages, PD-1, PD-2, PD-3 — each recorded inline on its rows above. PD-3 maps to no inventory row: under the hook's flags the Python surface runs zero checks for the epic/parallel artifact types, so there is no row to defer.

## Verification Reference

The suites asserting these rows ran green under narrowed `scan_folders` at `[P12-T9]`:
`tests/scripts/claude-lib/orchestrator-state` — 378 tests, 0 failures, 0 errors;
`tests/scripts/claude-lib/discovery-validation` + `tests/scripts/claude-lib/codex-routing` — 125 tests, 0 failures, 0 errors.
The full-suite confirmation is `[P15-T3]`.
