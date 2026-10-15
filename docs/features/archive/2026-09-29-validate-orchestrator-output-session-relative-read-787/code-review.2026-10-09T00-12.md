# Code Review: validate-orchestrator-output session-relative checkpoint read (#787, bundling #840)

---

**Review Date:** 2026-10-09 (timestamp 2026-10-09T00-12)
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-09-29-validate-orchestrator-output-session-relative-read-787`
**Base Branch:** `origin/epic/enforcement-hook-precision-integration` @ `497cb504`
**Head Branch:** `bug/validate-orchestrator-output-session-relative-read-exec-787` @ `a9fcabc5`
**Review Type:** Initial review
**Reviewed:** every non-evidence file in the branch diff (27 files), with line-by-line reading of the three production PowerShell files and the Python authority they port.

---

## Executive Summary

The change does what the spec describes, at the right layer. The hook resolves its checkpoint through the exported `WorktreeRunResolution.psm1` surface, in a dot-sourced sibling. It blocks before any read when there is not exactly one target, and it passes the resolved absolute path to every downstream seam. The Layer 2 port is a compact, readable translation of `validate_wave_barrier_ordering` and its union-index helpers. Parity is enforced from both sides by a shared corpus: the Pester lane checks the port, and the pytest lane checks the corpus expectations against the Python authority. Tests are in-memory, mock the seams at module scope, and create no files.

No blocking findings. Seven non-blocking observations are listed in the Findings Table (two Minor, five Informational).

**Top 3 risks:**
1. CR-3: an unexpected resolver exception fails closed but without the `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` lead token that consumers match on.
2. CR-1: discovery reproduces a private WRR read/parse/filter with case-sensitive `route_id` matching; the divergence fails closed.
3. CR-6: the MCP PoshQC coverage artifact omits both new files, so their coverage relies on a self-hosted run.

**PR readiness recommendation:** **Go** — no blocking findings; the observations are follow-up or informational.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor (non-blocking) | `.claude/hooks/validate-orchestrator-output-resolution.ps1` | Lines 150-162 | CR-1: Discovery reproduces WRR's private read/parse/route filter. It differs in property-name case handling: it uses `-ccontains 'route_id'`, where WRR uses `-notcontains` and `.$Name`, which are case-insensitive. A checkpoint whose only route key is `Route_Id` is skipped by discovery but would be kept by WRR. | Follow-up for C3/C4: export a WRR function that enumerates distinct run identity values, and have the sibling consume it. | The effect fails closed (`NoTarget`), and the payload-signal path is unaffected. The spec prescribes this discovery step in the sibling, and WRR is owned by C3 (#850) and may not be edited here. | Line-by-line comparison against the private `Get-WorktreeRunCheckpoint`/`ConvertFrom-WorktreeRunCheckpointText` pair |
| Info | `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1` | Timing comparison, line 300 | CR-2: `CompareOrdinal` orders by UTF-16 code unit, not by code point (declared divergence D2). For non-ASCII timestamps the port may differ from Python in either direction, and this divergence does not fail closed. | None required. | It is declared, pinned by D2, and matches the TypeScript port. Timestamps in practice are ASCII. | Parity suite header D2 and its pinning row |
| Minor (non-blocking) | `.claude/hooks/validate-orchestrator-output.ps1` | Lines 476-480 | CR-3: An unexpected exception from the resolver path (for example, a git failure inside `Get-WorktreeItemLiveRoot`, or a non-absolute root passed to `Get-WorktreeRunCheckpointPath`) terminates under `$ErrorActionPreference = 'Stop'`. It exits 1, so it fails closed, but the message lacks the `ORCHESTRATOR_CHECKPOINT_UNRESOLVED:` lead token that consumers match on. | Consider wrapping the `Resolve-OrchestratorOutputCheckpointPath` call in a `try`/`catch` that emits the lead token with a reason such as `RESOLVER_FAILED`. | Consumers match on the lead token; the behavior is still fail-closed. | Code reading of the hook; lines 476-479 and 482 are among the uncovered hook lines |
| Info | `.claude/hooks/validate-orchestrator-output-resolution.ps1` | Unresolved message format | CR-4: The spec defines `<Status>` as `NoTarget` or `Ambiguous`. The cross-check failure uses status `Rejected`, and the import failure hard-codes `NoTarget` with `RESOLVER_IMPORT_FAILED`. | Document `Rejected` in the spec's error-handling section when the spec is next revised. | Both carry the lead token and the reason codes the spec names, so AC-3, AC-4, and AC-5 are met. | S2-1 to S2-5, S2-12; spec error-handling section |
| Info | `tests/scripts/claude-hooks/validate-orchestrator-output-resolution.Tests.ps1` | Lines 192-199 (S2-11) | CR-5: The runbook-seam row calls the real `Test-Path` on a non-existent path and on the test file itself. It is read-only and deterministic, but it does touch the filesystem. | Acceptable as the single direct test of the I/O seam. No change required. | It is the only direct test of the I/O seam and creates no files. | Test file lines 192-199 |
| Info (tooling, pre-existing) | `config/poshqc-coverage.json` | MCP PoshQC coverage population | CR-6: The MCP runner's coverage artifact omits about 60 files that `config/poshqc-coverage.json` places in the population, including both new files and the pre-existing `feature-folder-resolution.ps1`. Coverage for new files must therefore be measured with a self-hosted run. | Track separately (installed-extension runner versus in-repo population). | This is not caused by this branch. | `artifacts/pester/powershell-coverage.xml` (127 of 187 derived files); policy audit section 5 |
| Info (pre-existing) | `.claude/hooks/validate-orchestrator-output.ps1` | Lines 450-451 | CR-7: The comment "One subprocess call now covers both --require-complete and..." predates this change and conflicts with the #475 in-process design. | Optional cleanup in a later change. | Comment accuracy only; no behavior impact. | Code reading of the hook |

No Blocker or Major findings.

---

## Implementation Audit

### PowerShell implementation audit

#### `.claude/hooks/validate-orchestrator-output-resolution.ps1` (new, 314 lines)

- **Structure.** The sibling holds small, single-purpose functions. Two are pure (`Test-OrchestratorOutputCheckpointLeafShape`, `Resolve-OrchestratorOutputRunbookPath`); one composes the result object; one runs discovery; one is the main resolver; one is the runbook I/O seam; and one is the Layer 2 decision wrapper. The decision order is commented. This matches the simplicity and separation-of-concerns priorities.
- **Fail-closed ordering.** A malformed `-CheckpointPath` is rejected before any resolver call (line 201). `NoTarget` and `Ambiguous` are returned before the leaf cross-check (line 233). The canonical-path comparison is ordinal (`-ceq`, line 120). Rooted values (`^([A-Za-z]:|/)` after slash collapse, which also catches UNC and `\\`) and `..` segments are rejected.
- **Resolver surface.** Calls are limited to `Find-WorktreeRunIdentitySignal`, `Get-WorktreeRunCheckpointText`, `Get-WorktreeRunCheckpointPath`, `Resolve-WorktreeEpicTarget`, `Resolve-WorktreeParallelTarget`, `Resolve-WorktreeOperandTarget` (all in the WRR export list at `WorktreeRunResolution.psm1:490-497`), and `Get-WorktreeItemLiveRoot`. No private WRR function is called.
- **Reason codes.** The two resolver reason-code literals are duplicated as constants (lines 32-33) instead of being read from the accessor functions. The comment states why, and S2-7, R5, and R6 assert equality with the accessor values, so drift would be caught by tests.

#### `.claude/hooks/validate-orchestrator-output.ps1` (modified, 421 to 482 lines)

- The sibling dot-source and the two resolver imports are guarded, and the first failure is recorded. The Layer 2 import is guarded separately and blocks only the epic leg (H12). This matches AC-5 and the spec.
- Every downstream use of the checkpoint path now uses `$resolution.CheckpointPath`: the read, four error messages, the routing args, and the runbook seam (through a closure over `$resolution.WorktreeRoot`). The diff confirms that no use of the bound literal remains after resolution.
- Layer 2 runs only for `epic-orchestrator-state`, after the routing dispatch passes, on `$file.Content` (the text already read). The `Invoker` signature is unchanged.
- The UTF-8 BOM on line 1 was removed. All three production files are pure ASCII (`file` reports `ASCII text`; a grep for non-ASCII bytes found none), so script parsing is unaffected and `PSUseBOMForUnicodeEncodedFile` does not apply. Bundle parity holds because the mirror is byte-identical.

#### `.claude/lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.psm1` (new, 346 lines)

Parity was traced branch by branch against `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py:78-163` and `_epic_orchestrator_state_resolution.py:47-149`:

| Python behavior | Port | Match |
|---|---|---|
| `by_folder` over string `feature_folder`, later duplicate wins | `$byFolder[$folder] = $feature` | Yes |
| Union index only for non-empty string folders | `if ($folder.Length -eq 0) { continue }` before the hint and issue index | Yes |
| `_normalize_folder_hint`: first matching prefix, ordinal, in tuple order | `ConvertTo-EpicWaveBarrierFolderHint` with the same four prefixes in the same order | Yes |
| `issue_num` key by value; `True == 1`; string is unreachable from a non-string reference | `n:1`/`n:0` for booleans, `n:<BigInteger>` for integer tokens, `$null` for strings | Yes |
| Start guard `isinstance(created, str) or status != "not_started"` | `Test-EpicWaveBarrierFeatureStarted` | Yes |
| Status before timing; one line per edge | `continue` after the status line | Yes |
| `str(dependency)` rendering | `Format-EpicWaveBarrierReference` (raw string, `True`/`False`, canonical int) | Yes |
| Duplicate JSON key, last wins | `Get-EpicWaveBarrierProperty` enumerates and keeps the last match | Yes (U6) |

Parsing with `JsonDocument` avoids `ConvertFrom-Json` date coercion and case folding, as the module header explains. The declared divergence classes (D1-D5) are documented in the parity suite header and pinned by rows. The document is disposed in `finally`.

---

## Test Quality Audit

- **`validate-orchestrator-output.WorktreeResolution.Tests.ps1` (14 rows).** It models the two-worktree topology by mocking the live-root and checkpoint-text seams in both module scope and script scope. The script-scope mock is needed because the sibling calls `Get-WorktreeItemLiveRoot` directly. Every unresolved row asserts that the read seam, the routing invoker, and the Layer 2 function were not invoked. Synthetic `/synthetic-worktrees/` roots are used throughout.
- **`validate-orchestrator-output-resolution.Tests.ps1` (12 rows).** It covers the leaf cross-check variants, the six real registrations (read-only parse of `settings.json` and three agent frontmatters), discovery filtering, the runbook helpers, and the guarded import (S2-12).
- **`validate-orchestrator-output.WaveBarrier.Tests.ps1` (12 rows).** It covers the violation block, the halt instruction (H3 asserts no edit, timestamp, `merge_status`, or history vocabulary), the parallel and item legs not invoking the port, the unevaluable classes, and the Layer 2 import failure.
- **Port unit (20 rows) and parity (7 rows) suites.** All pass. The parity row asserts per file that the executed count equals the `cases` length and that the length is non-zero.
- **Existing suites.** Each suite that reaches `Invoke-OrchestratorOutputValidation` gains a `Describe`-level `BeforeAll` mock of `Resolve-OrchestratorOutputCheckpointPath`. The two relative-literal rows in `validate-orchestrator-output.Tests.ps1` were removed rather than edited in place. Their behavior is now asserted with absolute paths in the new suite: R12 covers the defaults, and R1 and R14 cover a custom epic path. This keeps that file under the cap (490 to 437 lines).
- **Python lane.** `test_epic_wave_barrier_parity_corpus.py` runs the corpus through `validate_epic_orchestrator_state_text` (30 nodes, all passed). The pin re-baseline in `parallel_orchestrator_surface_expectations.py` carries a dated rationale comment, and the new digests equal the SHA-256 values I computed for both documents.

---

## Assessment of the Seven Recorded Departures from Plan Text

The executor's departures are not recorded in the feature folder. They were assessed from the code and the executor's report.

| # | Departure | Assessment |
|---|---|---|
| 1 | Array-wrapper nesting in the sibling (`return , $values.ToArray()` in `Find-OrchestratorOutputRunSignalValue`; caller iterates and copies into a `List[string]`) | Not a defect. This is the standard PowerShell idiom that keeps a zero- or one-element result from unrolling. S2-10 (two values), R4 (one), and R6 (zero) exercise all three cardinalities. |
| 2 | `-AsHashtable` in a scratch script | Not a defect. Scratch scripts are not committed and do not affect shipped behavior. |
| 3 | `[OutputType([string[]], [object[]])]` on the port and on two helpers | Not a defect. It declares the comma-wrapped return accurately, satisfies PSSA's output-type rule, and does not change runtime behavior. |
| 4 | Run-time Unicode construction in parity row D2 | Not a defect. It keeps the test file ASCII (consistent with the BOM-free production files) and builds the same characters (`U+FF21`, `U+1F600`). |
| 5 | Comment rewording | Not a defect. Comments were checked against the code they describe and are accurate. |
| 6 | Six mocked roots in S2-10 | Not a defect. The extra roots add coverage of a case-variant `route_id`, unparseable text, an array root, a blank branch, and two case-distinct branch values. This strengthens the row. |
| 7 | Scratch location | Not a defect, provided scratch files stay outside the repository. `git status` was clean at review start, and no scratch file is in the diff. |

---

## Duplication Check (#565 helper and WorktreeRunResolution.psm1)

- **#565 `feature-folder-resolution.ps1`.** Not duplicated. The port's `ConvertTo-EpicWaveBarrierFolderHint` and union index are separate by design: the spec states that Layer 1 and Layer 2 share no code. The semantics also differ. `ConvertTo-FeatureFolderBasename` strips any `docs/features/<x>/` prefix, trims slashes, and keeps the last segment. The Python authority strips only the first of four fixed prefixes and keeps the remainder (U7 pins this). Reusing the #565 helper would break parity.
- **`WorktreeRunResolution.psm1`.** No function is copied, and the module is unchanged. One narrow overlap exists (CR-1): `Find-OrchestratorOutputRunSignalValue` reproduces the read, parse, object-check, and `route_id` filter of the private `Get-WorktreeRunCheckpoint`/`ConvertFrom-WorktreeRunCheckpointText` pair (about eight lines). The spec prescribes this discovery step in the sibling, and WRR is owned by C3 (#850) and may not be edited here. The overlap is therefore justified for this change.

---

## Research Log

No external research was required. The Python authority (`scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py`, `_epic_orchestrator_state_resolution.py`) and `WorktreeRunResolution.psm1` in the repository were the reference sources.

---

## Verdict

PASS. No blocking findings.
