# Policy Audit — Remediation Cycle 2 Reaudit (issue #545)

Timestamp: 2026-09-08T01-10
Feature: `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545`
Branch: `bug/enforcement-hook-trigger-matches-whole-command-text-545-r4`
Head audited: `636b18a7bf2e6ec4ff76abbc8d1d45577e80af3a`
Work mode: `full-bug` (AC source: `spec.md` only)
Cycle: 2 of a hard cap of 3

## Diff anchors used

| Anchor | Commit | Used for |
|---|---|---|
| Feature-wide | `6dff80ed4596bec088d548b23013e6077e32c484` (epic base) | whole-feature questions, frozen-literal preservation, deny preservation |
| Cycle-2 scope | `26dba29533ba70f6cd80d14ac3c87ac24ca82aca` | "what did cycle 2 change" |

Feature-wide surface: 255 files, 36191 insertions, 352 deletions.
Cycle-2 surface: 71 files, 7025 insertions, 22 deletions. The plan commit `459d245f` sits between
the cycle-scope anchor and head, so `remediation-plan.2026-09-07T20-45.md` legitimately appears in
the cycle-scope diff.

## Rejected Scope Narrowing

None. The delegating prompt scoped this audit to the full branch against the resolved base and
supplied both anchors. The one explicit exclusion it carries — the EA-3 scope fence and follow-ups
F-1 through F-7 — is a set of separately filed items, not a narrowing of the branch diff and not a
suppression of any language's coverage obligation. No language with changed files was marked out of
scope, and no toolchain or coverage check was waived. Nothing was ignored on this ground.

## 1. Policy Reading Order Discharged

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`, `.claude/rules/powershell.md`, `.claude/rules/tonality.md`

PowerShell is the only language with changed production files on the branch. The branch contains
zero `.py`, `.ts`, `.tsx`, and `.cs` files:

```
grep -E "\.py$" <feature-wide file list>   -> NONE
suffix census of the 255 changed paths     -> 188 md, 63 ps1, 2 psd1, 2 json
```

No file under `.claude/rules/` or `.github/instructions/` was modified:

```
grep "github" <feature-wide file list>  -> rc=1 (no match)
grep "rules/" <feature-wide file list>  -> rc=1 (no match)
```

## 2. Compliance Verdict Table

| Policy area | Verdict | Evidence |
|---|---|---|
| Tonality (`.claude/rules/tonality.md`) | PASS | Cycle-2 code comments, evidence artifacts, and spec annotations are factual and measured. No humor, hyperbole, or decorative metaphor observed in the 176 added production lines or the 21 cycle-2 evidence artifacts read. |
| No policy documents modified | PASS | See section 1 grep output. |
| File size limit (500 lines) | PASS | Changed production files at head: 486, 353, 260, 483, 442, 186, 483. Changed test files: 174, 100, 327, 387, 147, 106, 361. `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` is exactly 500 and is absent from the cycle-2 changed-file list, so it is untouched. |
| Coverage Exclusion Policy | PASS | The `pester.runsettings.psd1` diff is additive only: eight new `CodeCoverage.Path` entries, zero new `exclude` entries. All twelve canonical hook production files changed feature-wide are present in the list. |
| Fail-fast, explicit error handling | PASS | Every new leg is a pure boolean read with an explicit null guard (`Test-CommandLineSegmentRawScan` returns `$false` on `$null`). No broad catch was added. |
| Separation of concerns | PASS | The shared predicate lives in the scanner beside the clause it mirrors; the four call sites carry only the guarded read. No I/O added. |
| Reusability, no copy-paste | PASS | One predicate, five call sites across four hooks and two runtimes. The scanner is byte-identical in all four copies at `sha256 d8543cb9…`. |
| Determinism in tests | PASS | All 20 added cases drive pure functions or mocked decision seams over literal fixtures. No sleep, no temporary file, no disk read, no child process. |
| Test file location | PASS | All seven changed suites are under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`, mirroring the production tree. No colocation. |
| No temporary files in tests | PASS | The cycle-2 test additions contain no `New-TemporaryFile`, no `GetTempPath`, no `Out-File`. |
| Dependencies | PASS | No dependency added; `poetry.lock` and `package.json` are absent from the changed-file list. |
| No Python introduced | PASS | Zero `.py` files in the feature-wide diff. |

## 3. Evidence Location Compliance

Independently re-derived, not accepted from the artifact:

```
grep -E "^artifacts/(baselines|qa|evidence|coverage)/" <feature-wide file list>
-> NONE

python scripts/dev_tools/validate_evidence_locations.py --root .
EXIT=0 (no output)
```

All feature evidence sits under
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/<kind>/`
with `baseline/`, `remediation-baseline/`, `qa-gates/`, `regression-testing/`, `issue-updates/`, and
`other/` as the kinds. No violation. **PASS.**

`EVIDENCE_LOCATION_OVERRIDE_REJECTED`: not applicable; no non-canonical path was supplied.

## 4. The Cycle-1 Blocking Finding (R-2) — Closure Assessment

The single cycle-1 blocking finding was that `ConvertTo-CommandLineToken` collapses a balanced
quoted span into one token, so every token-based flag read reports the flag absent on a segment the
scanner reads raw. The four call sites that read absence as *out of scope* therefore failed open.

### 4.1 The mechanism delivered

`Test-CommandLineSegmentRawScan` was added to both `hook-command-scanner.ps1` copies at line 165:

```powershell
return ([bool]$Segment.IsWrapperLed -or [bool]$Segment.HasLiveSubstitution -or [bool]$Segment.Unbalanced)
```

The scanner's own ScanText selection clause, `ConvertTo-CommandLineSegmentRecord` line 151:

```powershell
$scanText = $MaskedText
if ($Unbalanced -or $HasLiveSubstitution -or $isWrapperLed) { $scanText = $RawText }
```

The record assigns `IsWrapperLed = $isWrapperLed`, `HasLiveSubstitution = $HasLiveSubstitution`, and
`Unbalanced = $Unbalanced`, so the predicate's three disjuncts are drawn from exactly the three
inputs the selection clause uses, in the same disjunctive form. **The two are set-identical.**
Verified by reading both bodies at head rather than by accepting the docstring.

### 4.2 No call site reads raw on a segment the scanner does not

Exhaustive grep of both runtimes:

```
grep -rn "Test-CommandLineSegmentRawScan" .claude/hooks .codex/hooks
.claude/hooks/enforce-epic-merge-gate.ps1:405
.claude/hooks/enforce-parallel-abandon-gate.ps1:144
.claude/hooks/enforce-parallel-abandon-gate.ps1:226
.claude/hooks/enforce-pr-author-skill-helpers.ps1:201
.claude/hooks/hook-command-scanner.ps1:165        (definition)
.claude/hooks/validate-bash.ps1:291
.codex/hooks/enforce-epic-merge-gate.ps1:137
.codex/hooks/hook-command-scanner.ps1:165          (definition)
```

Five call sites, each guarding a read of `$segment.ScanText` — not `$segment.RawText`. Because
`ScanText` equals `RawText` precisely when the predicate is true, the read is exactly the raw read
the scanner already performs, and it is unreachable on a masked segment.

A separate grep for unguarded raw reads returns only pre-existing sites:

```
grep -rn "\.RawText" .claude/hooks .codex/hooks
hook-command-invocation.ps1:203  (pre-existing D12 raw-containment leg)
validate-bash.ps1:205 and .codex/hooks/validate-bash.ps1:174  (pre-existing structural git match)
```

Neither was changed in cycle 2.

### 4.3 The over-match this feature exists to remove is not reintroduced

The canonical over-match input still allows, pinned on both runtimes:

- `hook-command-scanner.Tests.ps1` case `R2-P4 reports false for a masked quoted mention in a
  non-wrapper segment` drives `git commit -m "gh pr merge --merge 688"` and asserts the predicate
  returns `$false`. Recorded `Passed`.
- `enforce-epic-merge-gate.TriggerScoping.Tests.ps1` case `R2a-N1` and
  `enforce-epic-merge-gate-trigger-scoping.Tests.ps1` case `R2a-X2` assert the same input still
  produces an allow on the Claude and Codex decision surfaces. Both `Passed`.
- `validate-bash.TriggerScoping.Tests.ps1` case `R2d-N1` asserts `echo "cd /x && head f"` still
  returns null. `Passed`.
- `enforce-pr-author-skill.TriggerScoping.Tests.ps1` case `R2c-N2` asserts a quoted `--body` mention
  inside a JSON receipt value still allows. `Passed`.

Verdict: **PASS.** The raw-scan legs sit strictly between the token-only reading (too narrow, the
cycle-1 defect) and the epic-base whole-text reading (the over-match this feature removes). They
never exceed the epic base.

### 4.4 The six fail-closed-correct call sites are byte-unchanged

Confirmed at head by reading each line, and confirmed unchanged by the absence of any diff hunk
covering them in the cycle-2 diff:

| # | Site | Head line | Reader in use |
|---|---|---|---|
| 1 | `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 164 | `Test-CommandLineFlag … '--force'` |
| 2 | `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 94 | `Test-CommandLineFlag … '--force'` |
| 3 | `.codex/hooks/enforce-epic-worktree-removal-gate.ps1` | 58 | `Test-CommandLineFlag … '--force'` |
| 4 | `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 109 | `Get-CommandLineFlagValue … '--base'` |
| 5 | `.claude/hooks/enforce-epic-merge-gate.ps1` | 169 | `Get-CommandLineFlagValue … '--merge'` |
| 6 | `.codex/hooks/enforce-epic-merge-gate.ps1` | 61 | `Get-CommandLineFlagValue … '--merge'` |

Files 1 through 4 do not appear in the cycle-2 changed-file list at all. Files 5 and 6 were edited,
but the only hunks in their cycle-2 diffs are at Claude line 393 and Codex line 126; lines 169 and
61 fall outside every hunk and carry the original token readers verbatim. **PASS.**

### 4.5 The binding constraint on the token readers was honoured

`Test-CommandLineFlag` and `Get-CommandLineFlagValue` both live in `hook-command-invocation.ps1`.
That file does not appear in the cycle-2 changed-file list, and all four copies are byte-identical
at `sha256 b82246c61bb9fcb44ad6471dfa15278069c599ac3a52da26e62ede0cf1e92609`. The fix was made at
the call sites, guarded by a new separately named predicate, exactly as the constraint required.
**PASS.**

## 5. Frozen Literals — Independently Re-derived

The `[P5-T5]` artifact discharges this with a per-hunk paired-count formula. That formula is sound
for its stated purpose and carries a working negative control, but it has an acknowledged residual:
a hunk that deletes a literal while separately adding an unrelated line carrying the same literal
nets to zero. This audit closed that residual by the stronger method — direct base-versus-head
content comparison — rather than by accepting the formula.

| Literal group | Method | Result |
|---|---|---|
| Six `Get-BlockedBashPattern` denylist literals | base `validate-bash.ps1` lines 48–56 versus head lines 53–61 | Byte-identical, same six literals in the same order |
| Five preimplementation trigger patterns | base lines 128–134 versus head lines 132–138 | Byte-identical, same five patterns in the same order |
| Four promotion forbidden tokens | base `enforce-promotion-mcp-only.ps1` lines 87–90 versus head lines 94–97 | Byte-identical, same order; the `PROMOTION_MCP_ONLY_BLOCKED` reason string is unchanged |
| `(?i)\bgh\s+issue\s+(?:create\|new)\b` | base line 101 versus head line 117 | Literal byte-identical; only the operand changed (`$CommandText` to `$segment.ScanText`) |
| `$ghApiIssuesPostPattern` declaration line | base line 110 versus head line 136 | Byte-identical |
| `$script:CdChainedReadCommandPattern` | head line 222, single assignment | Byte-identical, and now read at line 292, so it is no longer a dead constant |
| `--disposition abandon`, `--confirm-abandon` | head lines 41–42, one occurrence each in the file | Byte-identical; the raw leg reconstructs both spellings from the split constant rather than restating them |

Corroborating check across the whole feature-wide diff:

```
<feature-wide ps1 diff> | grep '^-' | grep -oE "\b[A-Z][A-Z0-9]+(_[A-Z0-9]+)+\b" | sort | uniq -c
-> (no output)
```

**Zero reason-code tokens appear on any removed line anywhere in the feature.** All fourteen reason
codes appear only on added lines. No reason code was deleted or rewritten.

Verdict: **PASS.** The frozen-literal guarantee holds on direct evidence, independent of the
formula's residual limitation.

## 6. Copy-Set Parity

SHA-256 recomputed at head, not carried forward:

| Pair | Canonical | Bundle mirror | Match |
|---|---|---|---|
| `enforce-epic-merge-gate.ps1` (Claude) | `05feec2a…` | `05feec2a…` | yes |
| `enforce-parallel-abandon-gate.ps1` | `827e81b9…` | `827e81b9…` | yes |
| `enforce-pr-author-skill-helpers.ps1` | `b809a8b3…` | `b809a8b3…` | yes |
| `hook-command-scanner.ps1` (Claude) | `d8543cb9…` | `d8543cb9…` | yes |
| `validate-bash.ps1` (Claude) | `21654b66…` | `21654b66…` | yes |
| `enforce-epic-merge-gate.ps1` (Codex) | `d87b5437…` | `d87b5437…` | yes |
| `hook-command-scanner.ps1` (Codex) | `d8543cb9…` | `d8543cb9…` | yes |

Cross-runtime: the Claude and Codex `hook-command-scanner.ps1` copies are byte-identical; all four
copies share `d8543cb9…`. `hook-command-invocation.ps1` is byte-identical in all four copies at
`b82246c6…`.

The machine-enforced parity mechanisms were run independently by the reviewer:

```
python -m pytest tests/scripts/dev_tools/test_parallel_abandon_token_seam.py \
                 tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py \
                 tests/scripts/dev_tools/test_poshqc_bundled_parity.py -q
22 passed in 0.27s
```

**PASS.**

## 7. Test Coverage Detail

Languages with changed files in the branch diff: **PowerShell only.**

| Language | Changed files | Coverage artifact | Verdict |
|---|---|---|---|
| PowerShell | 63 `.ps1` and 2 `.psd1` feature-wide; 21 `.ps1` in cycle 2 | `artifacts/pester/powershell-coverage.xml` present, plus CI run `34181009673` | **PASS** |
| Python | 0 | — | N/A (zero changed files) |
| TypeScript | 0 | — | N/A (zero changed files) |
| C# | 0 | — | N/A (zero changed files) |

PowerShell is a coverage language subject to the 85% line floor and the no-regression rule. Pester
measures command and line coverage only, so no branch percentage exists and no branch threshold
applies, per `.claude/rules/powershell.md` and `.claude/rules/quality-tiers.md`. No FAIL is recorded
for the absent branch figure.

### 7.1 Per-file line coverage, cycle-2 changed production files

| # | File | Baseline (run `34158596238`) | Post-change (run `34181009673`) | Delta | >= 85 |
|---|---|---|---|---|---|
| 1 | `.claude/hooks/hook-command-scanner.ps1` | 97.7778 | 97.8142 | +0.0364 | yes |
| 2 | `.codex/hooks/hook-command-scanner.ps1` | 100.0000 | 100.0000 | +0.0000 | yes |
| 3 | `.claude/hooks/enforce-epic-merge-gate.ps1` | 96.6102 | 96.7213 | +0.1111 | yes |
| 4 | `.codex/hooks/enforce-epic-merge-gate.ps1` | 98.5075 | 98.5915 | +0.0840 | yes |
| 5 | `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 92.7536 | 93.5897 | +0.8361 | yes |
| 6 | `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 95.5224 | 96.0000 | +0.4776 | yes |
| 7 | `.claude/hooks/validate-bash.ps1` | 94.4444 | 94.6237 | +0.1793 | yes |

Zero files below 85. Zero regressions on changed lines.

### 7.2 Independent re-derivation

The reviewer parsed `artifacts/pester/powershell-coverage.xml` directly, summing the JaCoCo `LINE`
counters per `<sourcefile>` within the package whose name ends with the file's directory
(package-qualified selection is required because several hook filenames exist under both
`.claude/hooks` and `.codex/hooks`). Four of the seven rows are reproducible from that artifact and
**all four match the reported figure to four decimal places**:

| File | Reported | Locally re-derived (missed / covered) | Match |
|---|---|---|---|
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 96.7213 | 4 / 118 = 96.7213 | yes |
| `.claude/hooks/enforce-parallel-abandon-gate.ps1` | 93.5897 | 5 / 73 = 93.5897 | yes |
| `.claude/hooks/enforce-pr-author-skill-helpers.ps1` | 96.0000 | 3 / 72 = 96.0000 | yes |
| `.claude/hooks/validate-bash.ps1` | 94.6237 | 5 / 88 = 94.6237 | yes |

The three unreproducible rows are `.claude/hooks/hook-command-scanner.ps1`,
`.codex/hooks/hook-command-scanner.ps1`, and `.codex/hooks/enforce-epic-merge-gate.ps1`. The local
artifact contains **no row at all** for exactly the eight `CodeCoverage.Path` entries this feature
newly registered — the two scanner paths, the two invocation paths, and the four Codex canonical
hooks — and for no others. That is precisely the failure mode the `TOOLCHAIN_SUBSTITUTION` block in
`final-coverage-delta.2026-09-07T22-56.md` predicts: the MCP runner resolves runsettings from the
installed extension payload and cannot see this branch's new entries. The absence pattern is
therefore confirmatory of the stated reason for using the CI route, not a coverage gap.

### 7.3 Repo-wide figure — Informational, carried forward

The local aggregate over the 88 measured files is 5120 / 7959 = 64.3297, with 18 files reporting
exactly 0.0000 because their suites did not execute in that narrower run. That number measures a
different denominator from the CI run and is **not** a valid repo-wide figure. It is recorded here
only so the discrepancy is visible rather than hidden.

The repo-wide figure this audit relies on is 95.4638, orchestrator-attested from CI run
`34158596238` and carried forward through cycle 1's finding G-3. Cycle 2 added 176 production lines
and 247 test lines, all of which are covered per section 7.1, so the figure cannot have fallen below
the threshold as a result of this cycle. The reviewer did not independently re-derive the repo-wide
number because the CI artifact for run `34181009673` is not on disk in this worktree. Recorded as
**Informational**, unchanged from cycle 1, and not a new cycle-2 finding.

## 8. Toolchain Loop

PowerShell has no type-check stage, so the applicable loop is format, lint, unit test.

| Stage | Route | Result | Independent corroboration |
|---|---|---|---|
| Format | `_poshqc.yml` run `34181009673`, `Invoke-PoshQCFormat` then fail-on-dirty | success | The reviewer read `.github/workflows/_poshqc.yml` lines 22–29 and confirms the step runs the formatter and then errors when `git status --porcelain` is non-empty. A `success` conclusion is positive evidence the formatter rewrote nothing. Agrees. |
| Lint | same run, `Invoke-PoshQCAnalyze` | success | Workflow lines 31–36 confirm the step fails the job on analyzer error. Agrees. |
| Unit test | same run, `Invoke-PoshQCTest`; 4363 tests, 0 failures, 0 errors | success | Workflow lines 38–42 confirm the step fails the job on test failure; lines 44–53 confirm the run uploads `pester-junit.xml` and `powershell-coverage.xml`. Agrees structurally. |

`pwsh`, `powershell`, and `cmd` are not invocable in this session, so the reviewer could not re-run
the loop locally. That is a `TOOLCHAIN_SUBSTITUTION`, not a gap: the CI dispatch is the stronger
route, and the reviewer verified the workflow's gating semantics directly from the workflow file.

### 8.1 Real CI versus the PR checks tab — independent agreement

The reviewer independently read `.github/workflows/ci.yml`:

```yaml
on:
  push:
    branches: [main, development]
  pull_request:
    branches: [main, development]
  workflow_dispatch:
```

`pull_request.branches` filters the PR **base** ref. A child PR based on the epic integration branch
never triggers `ci.yml`, so none of its nine reusable workflows run and the checks tab is empty
rather than green. The `push` filter likewise excludes the feature branch. `_poshqc.yml` carries
`workflow_dispatch:` alongside `workflow_call:`, so direct dispatch is available and is the only
route to real CI for this branch. **The reviewer's derivation agrees with the orchestrator's
`EPIC_CHILD_PRS_RUN_NO_REAL_CI` finding.**

### 8.2 The two tolerated local failures — independent agreement

The local `artifacts/pester/pester-junit.xml` at head reports `tests="2408" errors="0" failures="2"`.
The reviewer extracted both:

1. `enforce-pr-author-skill.Tests.ps1:145`, `allows gh pr create --body-file artifacts/pr_body_12.md
   when context exists`, expected `allow`, observed `deny`. The `[P0-T6]` cycle-2 baseline artifact
   records this same failure **before any cycle-2 code change**, attributed to ambient gitignored
   state: `artifacts/orchestration/orchestrator-state.json` in this worktree carries
   `"epic_mode": true` and the fixture command carries no `--base`, so `EPIC_BASE_BRANCH_MISMATCH`
   fires at `enforce-pr-author-skill.epic-base-branch.ps1` line 109. The reviewer confirmed that
   causal chain by reading the code. The fixture command is a plain non-wrapper invocation, so the
   cycle-2 fallback block at `enforce-pr-author-skill-helpers.ps1` lines 197–210 is not entered at
   all and cannot be the cause.
2. `codex-pretooluse-integration.Tests.ps1:165`. The failure text is
   `EPIC_WAVE_BARRIER_BLOCKED: '545' cannot mutate until every depends_on edge is merged or
   worktree_removed in the epic checkpoint`. This reads the live epic checkpoint from disk and is
   ambient by construction.

Both failures are environment-dependent and neither touches a file cycle 2 changed. A CI runner has
neither an epic-mode orchestrator-state nor an epic checkpoint naming 545, which is a sufficient
explanation for the CI run reporting 0 failures against the same tree. **The reviewer's derivation
agrees with the orchestrator: the local tolerance is evidenced, not asserted.**

### 8.3 Per-suite deltas, re-derived from the JUnit at head

| Suite | Cycle-2 baseline | Head | Delta | Failures |
|---|---|---|---|---|
| `claude-hooks/hook-command-scanner.Tests.ps1` | 42 | 47 | +5 | 0 |
| `claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` | 9 | 12 | +3 | 0 |
| `claude-hooks/enforce-parallel-abandon-gate.TriggerScoping.Tests.ps1` | 3 | 7 | +4 | 0 |
| `claude-hooks/enforce-pr-author-skill.TriggerScoping.Tests.ps1` | 18 | 22 | +4 | 0 |
| `claude-hooks/validate-bash.TriggerScoping.Tests.ps1` | 12 | 16 | +4 | 0 |
| `codex-hooks/hook-command-scanner.Tests.ps1` | 41 | 46 | +5 | 0 |
| `codex-hooks/enforce-epic-merge-gate-trigger-scoping.Tests.ps1` | 5 | 7 | +2 | 0 |

Every delta matches the increment its plan task declares. Cycle-2 test-file changes total **247
added lines and 0 deleted lines** across all seven suites, so no existing assertion was weakened,
reversed, or removed.

## 9. Plan Completion

```
grep -c "^- \[x\]" remediation-plan.2026-09-07T20-45.md  -> 61
grep -c "^- \[ \]" remediation-plan.2026-09-07T20-45.md  -> 0
```

61 of 61 tasks checked, 0 unchecked. **The reviewer's derivation agrees with the orchestrator.**

## 10. Findings

| ID | Severity | Area | Finding |
|---|---|---|---|
| P-1 | Advisory (non-blocking) | `spec.md` AC-09 | The AC-09 criterion text was extended during check-off, contrary to `acceptance-criteria-tracking` rule 3. Detail in 10.1. |
| P-2 | Informational | Coverage | Repo-wide PowerShell figure for run `34181009673` is not on disk; carried forward from run `34158596238`. See 7.3. |
| P-3 | Advisory (non-blocking) | `spec.md` D12 | `Test-CommandLineSegmentRawScan` is a new public scanner function not enumerated in the D12 parser contract section. See 10.2. |

No FAIL. No blocking PARTIAL.

### 10.1 P-1 — AC-09 criterion text extended during check-off

File: `docs/features/active/…-545/spec.md`, line 1499.
Rule: `.claude/skills/acceptance-criteria-tracking/SKILL.md`, Check-Off Protocol rule 3 — "change
only `- [ ]` to `- [x]`. Do not modify the criterion text."

Verification command and output (cycle-scope diff of `spec.md`):

```
-- [ ] **No existing denial is weakened.** … pass unmodified.
+- [x] **No existing denial is weakened.** … pass unmodified. Cycle 2 discharges this criterion
+      through `evidence/qa-gates/deny-preservation-audit.2026-09-07T22-59.md` (`[P5-T9]`), …
```

Assessed **non-blocking**. The rule exists to stop a criterion being rewritten to match what was
delivered. Here the original sentence is preserved verbatim and the addition is a citation pointing
at the discharging evidence, so the criterion's substance is unchanged and is not weakened. The
substantive evaluation of AC-09 is independent and is recorded in the feature audit. Recommended
correction in a later documentation pass: move the citation into the evidence index rather than the
criterion body.

### 10.2 P-3 — new public scanner function not in the D12 contract section

File: `.claude/hooks/hook-command-scanner.ps1` line 165 and its Codex twin.

AC-35 requires that the public signatures of six named functions match D12. It does not require the
scanner's public surface to be exhaustive, so no criterion is violated. The cycle-1
`remediation-inputs` explicitly authorized the mechanism: "If a shared helper is introduced, it must
be a new, separately named predicate." The gap is that D12 now under-describes the delivered
surface. Non-blocking; recommended for a documentation amendment when the #545 spec is next touched.

## 11. Verdict

**PASS.** No FAIL finding and no blocking PARTIAL finding in this artifact.
