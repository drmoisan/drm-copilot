# Feature Audit — issue #554

- Timestamp: 2026-08-27T22-47
- Branch: `bug/preimplementation-gate-blocks-epic-execution-554-r3` at `f24bbc7f`
- Base: `origin/main` at `1e991b86`
- Work mode: `full-bug` (marker `- Work Mode: full-bug` in `issue.md`)
- Acceptance-criteria source: `docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md` §Acceptance Criteria, **exclusively**
- `user-story.md`: deliberately absent, correct for `full-bug`. `issue.md` carries a pointer section only and was not treated as a second source.

## Baseline Comparison

The audit compares branch head against the merge base `1e991b86`, which is identical to the base
branch tip, so the three-dot and two-dot diffs coincide. The defect described in the issue body and
in the 2026-08-26 amendment is present at the base and absent at the head:

- At base, `Test-ImplementationDelegation` matched `(python-typed-engineer|powershell-typed-engineer|typescript-engineer|csharp-typed-engineer|atomic-executor|implementation|execute)`
  against `($ToolInput | ConvertTo-Json -Depth 20 -Compress)` — the whole serialized payload.
- At head, it reads `subagent_type` and `prompt` as named fields and decides structurally. The
  whole-payload scan is removed and the two free-text tokens are gone.
- At base, the only readiness source was `$script:CheckpointPath =
  'artifacts/orchestration/orchestrator-state.json'`. At head, the source is selected from a fixed
  four-row table by resolved mode, and the epic and parallel predicates match their checkpoints'
  actual schemas.

The regression pair recorded at `evidence/regression-testing/fail-before-case-6b.2026-08-26T10-18.md`
and `evidence/regression-testing/pass-after-case-6b.2026-08-26T11-36.md` documents the one
allow-to-deny behaviour change (matrix case 6b) in both directions.

## Verification Method

Every criterion was verified against the repository at head, not against the executor's evidence
artifacts. Independent verification performed for this audit:

- `git diff --name-status origin/main...HEAD` — full file inventory (64 files).
- SHA-256 recomputation of all four mirrored production pairs.
- Line counts of all six changed/new `.ps1` files.
- `Invoke-Formatter` idempotency check and `Invoke-ScriptAnalyzer` over the six files.
- `Invoke-Pester` over the two new suites plus the six pre-existing gate/contract suites: 368 passed,
  0 failed.
- `pytest` over the manifest/parity/PoshQC selection: 494 passed, 5 skipped.
- Independent parse of `artifacts/pester/powershell-coverage.xml` for repo-wide, per-file, and
  per-line coverage, intersected with `git diff -U0` added-line sets.
- `python scripts/dev_tools/validate_evidence_locations.py --root .` — exit 0.

## Acceptance Criteria Evaluation

35 criteria. Verdicts: **34 PASS, 1 FAIL**.

| # | Criterion (abridged) | Verdict | Evidence |
| --- | --- | --- | --- |
| 1 | Amendment 1 — epic-child delegation allowed iff the epic checkpoint proves the epic prepared and the target is a real, not-yet-merged record | PASS | `Get-EpicOrchestrationReadinessFailure` implements the seven-conjunct predicate; matrix cases 1, 3, D8 assert allow/deny in both directions and pass |
| 2 | Amendment 2 — reordering or rewording an execution prompt cannot change the decision for any matrix case | PASS | Classification reads two named fields; mode resolution is containment over the prompt; matrix case 5 proves field-scoping; case 6b proves wording-independence. Residual N3 (two bare-hash numbers) lies outside the matrix and is recorded, not suppressed |
| 3 | Amendment 3 — a denied delegation's reason names the checkpoint consulted and the failed predicate | PASS | `Get-OrchestrationModeDenyReason` emits both; matrix cases 2, 3, 4 assert on `epic-orchestrator-state.json` and on `'target-record'` / `'declared-checkpoint-path'` |
| 4 | Amendment 4 — standalone orchestration, planner-surface writes, and the #539 staging exemption behaviourally unchanged | PASS | `Test-ImplementationPath`, `Test-ImplementationCommand`, and all four `-helpers.ps1` copies absent from the diff; six pre-existing suites unmodified and 368 cases pass |
| 5 | Matrix case 1 — ready epic checkpoint via `-EpicCheckpointRaw` allows | PASS | Claude suite line 389; passes |
| 6 | Matrix case 2 — empty injected epic content denies, reason names the epic checkpoint | PASS | Claude suite line 390, asserts `*epic-orchestrator-state.json*`; passes |
| 7 | Matrix case 3 — features array lacking the target denies | PASS | Claude suite line 391, asserts `'target-record'`; passes |
| 8 | Matrix case 4 — non-canonical declared `epic_checkpoint_path` denies | PASS | Claude suite line 392, asserts `'declared-checkpoint-path'`; passes |
| 9 | Matrix case 5 — epic marker in a non-prompt field resolves to the default mode | PASS | Claude suite lines 406-418; asserts the reason names `orchestrator-state.json` and **not** `epic-orchestrator-state.json`, which is what proves the source consulted |
| 10 | Matrix case 6a — allow-listed agent, no legacy tokens, unready checkpoint denies | PASS | Claude suite line 424 (`atomic-executor`); passes |
| 11 | Matrix case 6b — orchestrator, "atomic execution", no legacy tokens, unready checkpoint **denies** | PASS | Claude suite lines 131-149; paired fail-before / pass-after regression artifacts present |
| 12 | Matrix case 7 — both preparation markers allow | PASS | Claude suite line 425; passes |
| 13 | Matrix case 8 — standalone orchestrator allow/deny against ready/unready | PASS | Claude suite lines 437-452; both pass |
| 14 | Parallel readiness positive — ready parallel checkpoint via `-ParallelCheckpointRaw` allows | PASS | Claude suite line 457; passes |
| 15 | Parallel readiness negative — items lacking the target denies, naming the parallel checkpoint | PASS | Claude suite line 458, asserts `*parallel-orchestrator-state.json*`; passes |
| 16 | Parallel canonical-path cross-check denies | PASS | Claude suite line 459; passes |
| 17 | Epic target unresolvable denies | PASS | Claude suite line 393, asserts `'target-record'`; passes |
| 18 | Merge-status hardening D8 — terminal-merged denies, failure status allows | PASS | Claude suite lines 280-296 and 337-353; all four cases pass on both surfaces |
| 19 | Codex logic parity D5(i) — Codex suite dot-sources the Codex copy and asserts the same outcomes | PASS | `tests/scripts/codex-hooks/…-mode-resolution.Tests.ps1` lines 35-201; passes. Coverage of that parity is incomplete — see B1 — but the criterion as worded is satisfied |
| 20 | Codex transport gap D5(ii) — a test reads `.codex/config.toml` and asserts no matcher admits Agent/Task, citing #555 | PASS | Same suite lines 203-233; passes |
| 21 | All four pre-existing Pester suites pass **unmodified**, verified by absence from the diff | PASS | All four absent from `git diff --name-only`; all cases pass in the 368-test run |
| 22 | `PreToolUseSchema.Contract.Tests.ps1` passes unmodified | PASS | Absent from the diff; passes |
| 23 | The four `-helpers.ps1` copies byte-identical to the branch point | PASS | `git diff --name-only … \| grep -c helpers.ps1` returns `0` |
| 24 | Each mirrored production pair SHA-256 byte-identical, hashes recorded in a qa-gates artifact | PASS | Recomputed independently: 4 of 4 MATCH. Artifact `evidence/qa-gates/final-mirror-pair-hashes.2026-08-27T22-42.md` present |
| 25 | Both `pester.runsettings.psd1` copies list both new hook files; PoshQC bundled-parity Python test passes | PASS | Both copies carry identical diffs adding both entries; 494 Python tests pass |
| 26 | Both pack manifests list the new modes hook for their surface; push-down completeness tests pass | PASS | Claude manifest line 37, Codex manifest line 41; Python tests pass |
| 27 | The new production hook files appear in the self-hosted Pester coverage report | PASS | Both appear as `sourcefile` entries in `artifacts/pester/powershell-coverage.xml` with non-zero line counts |
| 28 | **Line coverage ≥ 85% AND no changed line in either modified hook loses coverage** | **FAIL** | First clause PASS (94.22%). Second clause FAIL: 37 uncovered changed lines across the two modified hooks, plus a ten-line regression on pre-existing lines. See the dedicated section below. **Left unchecked.** |
| 29 | No file under `.claude/rules/`, `.claude/skills/`, or `.github/` in the diff | PASS | Full 64-file inventory enumerated; zero matches |
| 30 | Deny-by-default preserved; three named deny assertions pass | PASS | Claude suite lines 470-492; all three pass. Observation N4 recorded against the criterion's broader wording |
| 31 | Every file written by the branch appears in the DECLARED BLAST RADIUS | PASS | All 64 diff paths fall within the declared file list or the six declared directory prefixes |
| 32 | The full PowerShell toolchain passes in a single pass: format, analyze zero findings, Pester with coverage | PASS | Independently re-run: `FORMAT-CLEAN` ×6, `PSSA: 0 findings`, JUnit `tests=3808 failures=0 errors=0` |
| 33 | The plan records D6 batch sequencing and states the byte-copy treatment explicitly | PASS | `plan.2026-08-26T08-40.md` lines 34-74 |
| 34 | Every production `.ps1` written by this change is ≤ 500 lines | PASS | 489 / 477 / 495 / 477 |
| 35 | A follow-up record for the D3 epic kickoff contract gap exists under `evidence/other/` | PASS | `evidence/other/followup-epic-kickoff-contract-gap.2026-08-26T11-36.md` present, with the gap, the recommended amendment, and the out-of-scope reason |

## Criterion 28 — Detailed Evaluation

> Line coverage across the PowerShell suite remains at or above 85%, and no changed line in either
> modified hook loses coverage.

**Verdict: FAIL. Left unchecked. Criterion text unamended.**

### Clause 1 — PASS

Repository-wide PowerShell line coverage is **94.22%** (7174 covered, 440 missed), recomputed
independently from the JaCoCo root counters. Well above the 85% uniform threshold in
`.claude/rules/quality-tiers.md`. Pester measures no branch coverage, so no branch figure is required
and its absence is not a failure.

### Clause 2 — FAIL

The executor's changed-line measurement is accurate and was reproduced exactly: 348 measurable added
lines, 63 uncovered, 81.90% aggregate; 37 of the 63 in the two modified hooks. Two facts the
executor's artifact does not record change the evaluation:

1. **Three of the four changed production files fall below the 85% uniform line threshold at file
   granularity**, including one **new** file:

   | File | New/Modified | File line coverage |
   | --- | --- | --- |
   | `.claude/…/gate.ps1` | Modified | 80.67% |
   | `.claude/…/gate-modes.ps1` | New | 98.48% |
   | `.codex/…/gate.ps1` | Modified | 82.10% |
   | `.codex/…/gate-modes.ps1` | **New** | **81.82%** |

2. **Ten previously-covered pre-existing lines regressed.** Lines 170-185 of the Claude hook are the
   body of `Test-PreparationModeDelegation`, whose only production call site this change removed. It
   is now dead on the Claude surface and uncovered. The executor's artifact flags "up to 9
   [unattributed] misses" without diagnosing them; this is that population.

### Evaluation of the executor's four-group characterization

The executor grouped the 63 lines as (1) read seams bypassed by injection, (2) the non-injected
`else` arm, (3) the Codex transport gap, (4) a `Write-Debug` catch. Assessed group by group:

- **Group 1 (16 lines) and Group 2 (3 lines) — the argument holds.** These are the bodies of
  `Get-EpicCheckpointContent` / `Get-ParallelCheckpointContent` and the `else` arm that calls them.
  They perform real filesystem I/O. `.claude/rules/general-unit-test.md` requires that core domain
  logic be testable without touching the filesystem, and the injection seam is the mechanism that
  satisfies it. Covering these bodies would require a test that reads the live checkpoint, which
  would also make several allow assertions pass vacuously. **Accepted residual.**
- **Group 4 (4 lines, not 2) — the argument holds.** A `catch` that fires only when
  `PSObject.Properties` itself throws. **Accepted residual.**
- **Group 3 (39 lines) — the argument is over-extended and is rejected in part.** Decision D5
  prohibits *"fabricating an `Agent` envelope on the Codex side and asserting a decision on it."*
  That prohibition covers the 15 lines of the Codex epic/parallel decision branch and nothing else.
  It does **not** cover the 22 lines in the Codex `-modes.ps1` file (`Find-OrchestrationDelegationTargetFolder`,
  `Find-OrchestrationDelegationIssueNumber`, the unknown-mode `return ''`) or the 2 lines of
  `Get-OrchestrationModeDenyReason`: all are pure string functions taking a string and returning a
  string, requiring no envelope and asserting nothing about transport. The Codex suite already calls
  pure functions directly in three of its five `Context` blocks, and the Claude suite already covers
  every one of these functions with literal fixtures that can be copied verbatim. The gap is a
  consequence of the Codex suite carrying 13 `It` blocks against the Claude suite's 43, not a
  consequence of D5. **Rejected for 24 of the 39 lines; accepted for 15.**
- **One line is uncharacterized.** Line 210 of the Claude hook — the classifier's non-orchestrator
  **allow** branch — belongs to none of the four groups. It is an allow path in newly written code on
  the only reachable surface, and nothing on that surface exercises it.

### Evaluation of the executor's "unfalsifiable clause" argument

The executor argues that under a literal reading no added line can "lose" coverage, so the clause
could not fail, and cites `.claude/rules/plan-acceptance-gates.md` on gates that cannot fail. That
argument is sound as far as it goes, and the executor's substitution of the falsifiable reading
("reported as uncovered") is the right call.

But the argument is incomplete: it treats "changed line" as synonymous with "added line". The clause
is also falsifiable in its literal sense against lines the change did not add but **de-covered** —
precisely the `Test-PreparationModeDelegation` case. Under the literal reading the clause therefore
does have a failing instance, and it is one the executor did not look for. The clause is not
unfalsifiable; it fails on both readings.

### Verdict rationale

Criterion 28 fails. The remediation is small and carries no design cost: the 24 Codex lines and the
one Claude allow branch are closed by copying existing `It` blocks between two suites, and the ten
orphaned lines are closed by one direct unit test. Only 15 lines — the Codex decision branch — are a
genuine, D5-constrained residual, and those should be recorded as a named exception tied to issue
#555 rather than absorbed silently into a coverage table.

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md
- Total AC items: 35
- Checked off (delivered): 34
- Remaining (unchecked): 1
- Items remaining:
  - Line coverage across the PowerShell suite remains at or above 85%, and no changed line in
    either modified hook loses coverage.
```

**No acceptance criterion was newly checked off by this audit.** All 34 criteria evaluated PASS were
already checked by the executor; the sole unchecked criterion evaluated FAIL and correctly remains
unchecked. `spec.md` was not modified.

## Requirements Not Covered by an Acceptance Criterion

Two behaviours specified in `spec.md` are implemented but carry no dedicated criterion. Both are
verified here for completeness:

- **The default single-feature deny reason retains `route metadata` and `lifecycle readiness`** — the
  hard constraint at `spec.md` §Diagnosability. Verified: the literal is unchanged at the tail of the
  decision function, and the pre-existing suite that asserts both substrings passes.
- **The Codex `Get-StringProperty` trimming divergence introduces no decision dependence** — verified:
  every new predicate is a containment test or an exact comparison after explicit normalization; no
  predicate's outcome depends on untrimmed leading or trailing whitespace.

## Conclusion

The bug described in issue #554 and its amendment is fixed. Both faults are structurally repaired,
not patched: the classifier is field-scoped and wording-independent, and the readiness source is
mode-dispatched from a fixed table that no prompt can influence. Thirty-four of thirty-five
acceptance criteria pass on independently reproduced evidence.

One criterion fails on test-coverage grounds. The failure is narrow, well characterized, and cheaply
remediable; it does not indicate a defect in the shipped decision logic. Remediation inputs are at
`remediation-inputs.2026-08-27T22-47.md`.
