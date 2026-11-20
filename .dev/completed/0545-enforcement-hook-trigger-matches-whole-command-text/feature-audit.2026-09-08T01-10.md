# Feature Audit — Remediation Cycle 2 Reaudit (issue #545)

Timestamp: 2026-09-08T01-10
Feature: `docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545`
Branch: `bug/enforcement-hook-trigger-matches-whole-command-text-545-r4`
Head audited: `636b18a7bf2e6ec4ff76abbc8d1d45577e80af3a`
Work mode: `full-bug`
AC source: `spec.md` only, `## Acceptance Criteria` section, lines 1452–1660
Cycle: 2 of a hard cap of 3

---

# BLOCKING COUNT

```
blocking_count = 0
```

**Zero.** There is no FAIL finding and no blocking-PARTIAL finding in any of the three cycle-2
reaudit artifacts. Cycle 2 closes. Cycle 3 is not required.

Breakdown by artifact:

| Artifact | FAIL findings | Blocking PARTIAL | Non-blocking findings |
|---|---|---|---|
| `policy-audit.2026-09-08T01-10.md` | 0 | 0 | 3 (P-1 Advisory, P-2 Informational, P-3 Advisory) |
| `code-review.2026-09-08T01-10.md` | 0 | 0 | 5 (C-5, C-6, C-7 Low; C-8, C-9 Informational) |
| `feature-audit.2026-09-08T01-10.md` (this file) | 0 | 0 | 1 (AC-22 UNVERIFIED, orchestrator-owned, expressly non-blocking) |
| **Total** | **0** | **0** | 9 |

No `remediation-inputs` artifact is produced for this cycle, because no remediation is required.

---

## 1. Scope and Method

The audit scope is the full branch diff against the resolved base. Two anchors were used:
`6dff80ed4596bec088d548b23013e6077e32c484` (epic base) for whole-feature questions, and
`26dba29533ba70f6cd80d14ac3c87ac24ca82aca` (cycle-2 scope) for what cycle 2 changed.

Evidence artifacts on disk were read but not taken on trust. Every claim that carries the cycle-2
exit gate was re-derived from the tree, the diff, the JUnit, or the coverage XML. Where the
reviewer's derivation could not reach a claim, that is stated rather than papered over. The specific
re-derivations are listed in section 4.

`pwsh`, `powershell`, and `cmd` are not invocable in this session. Python, `git`, and `grep` are, and
were used.

## 2. The Cycle-1 Blocking Finding — Instance-by-Instance Closure

| Instance | Regressing command | Epic base `6dff80ed` | Before cycle 2 | At head `636b18a7` | Pinning case | Result |
|---|---|---|---|---|---|---|
| R-2.a | `bash -c "gh pr merge --merge 688"` | deny `EPIC_MERGE_GATE_BLOCKED` | allow | deny | `R2a-C1` (Claude), `R2a-X1` (Codex) — both `Passed` | **CLOSED** |
| R-2.b | `bash -c "python … --disposition abandon"` | deny `PARALLEL_ABANDON_BLOCKED` | allow | deny | `R2b-C1`, `R2b-C2` — both `Passed` | **CLOSED** |
| R-2.c | `bash -c "gh pr edit 42 --body 'x'"` | deny `PR_AUTHOR_SKILL_BLOCKED` | allow | deny | `R2c-C1` — `Passed` | **CLOSED** |
| R-2.d | `bash -c "cd /x && head f"` | denied by the `cd`-chain pattern | allow | denied | `R2d-C1`, `R2d-C2`, `R2d-C3` — all `Passed` | **CLOSED** |

The binding constraint was honoured. `Test-CommandLineFlag` and `Get-CommandLineFlagValue` live in
`hook-command-invocation.ps1`, which is absent from the cycle-2 changed-file list and is
byte-identical across all four copies at `sha256 b82246c6…`. The six fail-closed-correct call sites
are byte-unchanged, verified line by line at head. The fix is a new separately named predicate,
`Test-CommandLineSegmentRawScan`, applied at the call sites.

The over-match this feature exists to remove is not reintroduced. The predicate's three disjuncts are
set-identical with the scanner's ScanText selection clause at line 151; every call site reads
`ScanText` rather than `RawText`, so a masked segment is unreachable; and each instance carries an
explicit negative case pinning the canonical over-match input to an allow. Full analysis in
`code-review.2026-09-08T01-10.md` section "The over-match analysis, in full".

## 3. Acceptance Criteria Evaluation

Counted from the `## Acceptance Criteria` heading at line 1452 through the `## Risks & Mitigations`
heading. The severity radio-button block at lines 69–72 and the checklist item at line 150 are
outside that range and are not acceptance criteria.

| # | Line | Criterion (abbreviated) | Verdict | Basis |
|---|---|---|---|---|
| AC-01 | 1453 | Over-match regression test exists, fail-before recorded | PASS | Cycle-1 verified; unaffected by cycle 2 (0 test deletions). |
| AC-02 | 1457 | Under-match regression test exists, fail-before recorded | PASS | Cycle-1 verified; unaffected. |
| AC-03 | 1461 | Both regression tests pass after the fix, both runtimes | PASS | Cycle-1 verified; both suites report 0 failures at head. |
| AC-04 | 1463 | Scanner emits the five D2 Piece 1 properties; heredoc rules pinned | PASS | Record shape read at `hook-command-scanner.ps1` L152–161; suite at 47 cases, 0 failures. |
| AC-05 | 1468 | Scan-text selection follows D2 Piece 2; wrapper set exact membership pinned | PASS | Selection clause read at L151. Wrapper set read at L21–24: 14 members, unchanged in cycle 2 (scanner diff is +33 / -0). |
| AC-06 | 1476 | Structural relocation classifier implements the six D2 Piece 3 steps | PASS | Cycle-1 verified; `hook-command-invocation.ps1` unchanged in cycle 2. |
| AC-07 | 1480 | Frozen literals byte-unchanged | PASS | Independently re-derived by direct base-versus-head comparison for all seven literal groups. See policy audit section 5. |
| AC-08 | 1495 | Every D3 fail-closed row pinned per applicable side, incl. seven wrapper deny pins | PASS | Cycle-1 verified; cycle 2 adds pins and removes none. |
| AC-09 | 1499 | **No existing denial is weakened** | PASS | See section 3.1. |
| AC-10 | 1505 | Issue #539 exemption layer unchanged | PASS | `enforce-orchestration-preimplementation-gate-helpers.ps1` absent from the cycle-2 changed-file list. |
| AC-11 | 1509 | `enforce-promotion-mcp-only.ps1` changed in all four copies, scan-text based | PASS | Head L108/L117/L138 read against ScanText; the two `gh` literals byte-identical to base. |
| AC-12 | 1514 | `enforce-pr-author-skill-helpers.ps1` fixed in both Claude copies; PR_* codes unchanged | PASS | Canonical and mirror byte-identical at `b809a8b3…`; all seven `PR_*` codes appear only on added lines feature-wide. |
| AC-13 | 1519 | Parser ships as two `.ps1` files across eight locations, each <= 500 lines | PASS | Both files present in all four trees; scanner 483 lines, invocation 483 lines; both byte-identical across copies. |
| AC-14 | 1525 | Registration set complete: 14 entries across 5 registry files | PASS | Re-derived: 2 + 2 (pack manifests) + 2 (`$script:SharedModuleNames`) + 4 + 4 (two coverage lists) = 14. |
| AC-15 | 1532 | Both parity mechanisms green in the same change | PASS | `python -m pytest` over the three contract suites: 22 passed. Codex byte-identity `It` in the contract suite reports 0 failures at head. |
| AC-16 | 1537 | Recomputed pair-hash parity evidence at the final commit | PASS | `evidence/other/pair-hash-parity.2026-09-07T15-52.md` present; the reviewer independently recomputed SHA-256 for all seven cycle-2 pairs at head and all seven match. |
| AC-17 | 1541 | Every touched file at or under 500 lines | PASS | `wc -l` over all 14 changed `.ps1` files: max 486 (production), 387 (test). |
| AC-18 | 1544 | Line coverage >= 85% on every changed or added production file; scanner in the denominator both sides | PASS | Seven-row table, min 93.5897, no regression. Both scanner paths present in `CodeCoverage.Path` at lines 253 and 255. See policy audit section 7. |
| AC-19 | 1548 | No Python introduced anywhere | PASS | Zero `.py` files in the 255-path feature-wide diff. |
| AC-20 | 1552 | Issue #539 `spec.md` annotated additively at all five D8 locations | PASS | Diff is 6 insertions / 3 deletions; each "deleted" line is the original text with a bold `Superseded … by issue #545` clause appended. No sentence removed. |
| AC-21 | 1557 | Nine in-scope hooks each carry a diff across their full copy set; nothing outside the list modified | PASS | Feature-wide `.ps1` numstat lists exactly the nine hooks plus the two parser files, each across its declared copy set. No `.github/instructions/` or `.claude/rules/` path in the diff. |
| **AC-22** | **1565** | **Issue #591 recorded as superseded and closed on merge; PR body states it** | **UNVERIFIED (non-blocking)** | Closes on the PR body, which is the orchestrator's responsibility and does not exist in the tree. Left unchecked. Expressly non-blocking per the review scope. |
| AC-23 | 1569 | PoshQC toolchain passes clean in a single pass | PASS | CI run `34181009673` conclusion `success`; the reviewer verified from `.github/workflows/_poshqc.yml` that the format step fails on a dirty tree and the analyze and test steps fail the job on error. |
| AC-24 | 1573 | Manual replay recorded for the five over-match instances plus the relocating deny | PASS | Cycle-1 verified; the five instances are pinned by test and unaffected by cycle 2. |
| AC-25 | 1576 | Promotion hook classifies a relocating `gh` issue spelling in all four copies (AT-5) | PASS | Cycle-1 verified; hook unchanged in cycle 2. |
| AC-26 | 1584 | AT-1 latent-bypass case denies | PASS | Cycle-1 verified; `enforce-epic-worktree-removal-gate.ps1` unchanged in cycle 2. |
| AC-27 | 1592 | AT-2 issue #591 operand mis-parse fixed | PASS | See section 3.2 — re-derived, including the false-allow direction required by EA-2. |
| AC-28 | 1598 | AT-4 merge-gate over-match allows | PASS | The `printf` case plus the cycle-2 addition `R2a-N1` (`git commit -m "gh pr merge --merge 688"` allows). Both `Passed`. |
| AC-29 | 1602 | AT-6 wrapper deny pin still denies | PASS | Trigger-pattern block byte-identical base versus head; suite green. |
| AC-30 | 1608 | AT-7 cross-runtime divergence closed | PASS | Cycle-1 verified; both worktree-removal hooks unchanged in cycle 2. |
| AC-31 | 1615 | `validate-bash.ps1` matching primitive delivered and pinned (D11.3) | PASS | Six denylist literals byte-identical base versus head; suite at 16 cases, 0 failures; cycle 2 adds four `R2d-*` cases and deletes none. |
| AC-32 | 1622 | Abandon gate fixed in both Claude copies and pinned; token seam intact | PASS | Both literals present exactly once each at L41–42; `test_parallel_abandon_token_seam.py` passes in the reviewer's own run; suite at 7 cases, 0 failures. |
| AC-33 | 1631 | `enforce-pr-author-skill.epic-base-branch.ps1` fixed in both Claude copies | PASS | Cycle-1 verified; file unchanged in cycle 2, and its `Get-CommandLineFlagValue` call at L109 is one of the six ring-fenced sites confirmed byte-unchanged. |
| AC-34 | 1638 | Codex merge gate acquires no unanchored whole-text digit scan | PASS | Head L61 uses `Get-CommandLineFlagValue` only; the cycle-2 diff adds a `--merge` presence read against `ScanText` but no digit scan. Verified by reading the file. |
| AC-35 | 1642 | D12 parser contract documented and honoured; three constant accessors pinned | PASS | The six named signatures are unchanged (their file is untouched in cycle 2) and the contract suite passes. The new predicate is additional surface, not a contract deviation. Noted as P-3 / C-9. |
| AC-36 | 1650 | `Test-CommandLineFlag` exists and is exercised by all three presence-only call sites | PASS | All three call sites still invoke it; the cycle-2 fallbacks run only after it returns absent and do not replace it. |
| AC-37 | 1655 | The two D11.6 follow-ups filed as separate potential entries | PASS | `docs/features/potential/2026-09-07-codex-preimplementation-gate-modes-module-unregistered.md` and `…-parallel-abandon-equals-joined-disposition-runtime-confirmation.md` both present in the feature-wide diff. |

### 3.1 AC-09 — substantive evaluation, independent of the artifact

The criterion is "no existing denial is weakened". The `[P5-T9]` artifact discharges it against the
feature-wide anchor. The reviewer evaluated the question directly for the five new legs, because a
raw-scan fallback in the *allow* direction is the one shape that could weaken a denial.

- Merge gate, both runtimes: the fallback can only set `$hasMergeFlag` from `$false` to `$true`, and
  it is conjoined with an unchanged structural invocation test. It can only move a command into
  scope. No denial can be weakened by construction.
- Abandon gate, scope leg: same shape — it can only report a disposition where none was reported.
- `validate-bash`: the new leg runs before the walk and returns a match where the walk found none. It
  cannot suppress a walk result, because it returns only on a match.
- pr-author helpers: the fallback runs only when both flags read absent. Setting `$hasBodyFile` could
  in principle route a wrapper-led create away from the Case B deny and into the receipt path. The
  reviewer traced that path: `Test-PrAuthorReceiptVerification` matches `--body-file` against the
  whole `$CommandText` with a case-sensitive regex at L70, so it resolves the path inside the wrapper
  and runs all six checks; a non-canonical path returns `PR_BODY_PATH_NONCANONICAL`. No verification
  is skipped and no deny becomes an unverified allow.
- Abandon gate, confirmation leg: this is the one leg whose direction is allow. Two shapes let the
  raw read see a marker the token read cannot — a marker inside a heredoc body, and a superstring
  such as `--confirm-abandon-now` under `IndexOf`. Both were checked against the epic base, where the
  test was `$NormalizedCommand.Contains('--confirm-abandon', OrdinalIgnoreCase)` — plain whole-text
  substring containment. Both shapes allowed at the epic base too. No denial that existed before the
  feature is weakened.

Corroborating structural evidence: cycle-2 test files show **247 added lines and 0 deleted lines**,
so no assertion was modified, reversed, or removed; and zero reason-code tokens appear on any removed
line anywhere in the feature-wide diff.

Verdict: **PASS.** Already checked in `spec.md`; no check-off action required. The criterion's text
was extended during check-off, which is recorded as non-blocking finding P-1 in the policy audit.

### 3.2 AC-27 and EA-2 — the false-allow direction is pinned

EA-2 requires at least one Pester case pinning the FALSE-ALLOW direction of the merge-gate PR-number
extraction defect: an extracted number matching a *different* authorized item, asserting the merge is
denied. A fail-closed-only case does not satisfy it.

The case is at `tests/scripts/claude-hooks/enforce-epic-merge-gate.TriggerScoping.Tests.ps1` **line
104**, named `denies merging unauthorized PR 777 even though authorized item 501 appears earlier on
the line`. Verified:

- **It exists**, at exactly line 104. Confirmed by `grep -n`.
- **It is the false-allow direction.** The fixture is
  `cd /repo/worktrees/501 && gh pr merge --merge 777`. The parallel checkpoint is mocked with item
  501 at `merge_status: ci_green` (authorized) and item 777 at `merge_status: pr_open`
  (unauthorized). Before the fix the whole-line scan returned 501, matched the authorized item, and
  permitted merging PR 777. The case asserts `deny` with `EPIC_MERGE_GATE_BLOCKED`. This is the
  unauthorized-merge direction, not a fail-closed direction.
- **It passes.** The head JUnit records it `Passed`.
- **It was not weakened.** `git log -S` on the case name returns exactly one commit, `fdf1c84c`,
  where it was introduced; the string was never removed and re-added. The cycle-2 diff of this file
  is `41 insertions, 0 deletions`, so neither the case body nor the surrounding Context was touched.
- The cycle-2 raw-scan fallback does not affect it: neither segment of the fixture is wrapper-led,
  live-substituting, or unbalanced, so `Test-CommandLineSegmentRawScan` returns `$false` and the
  fallback is skipped. The assertion still turns on the structural extraction, as intended.

The Context also carries the two required complements: an extractor-level case asserting the number
is 777 rather than 501, and an allow case for the authorized `--merge 501` spelling so the fix does
not over-deny. Both `Passed`.

Verdict: **EA-2 satisfied.**

### 3.3 The `[P5-T5]` acceptance-condition correction — judged on the merits

The original condition counted every removed line carrying a frozen literal, and so could not
distinguish a deletion from an in-place operand rewrite. The corrected condition discounts a removed
line only when it is paired, in the same hunk, with an added line carrying the identical literal, and
it counts the pairing rather than merely detecting it.

**Is the corrected condition sound?** Substantially yes, with one known hole. It is sound for the
failure mode that matters: a genuinely deleted literal produces a `-` line with no matching `+` line
in its hunk and still fails its row. The artifact demonstrates this with a negative control —
deleting the four `+` lines from the real diff makes the formula report `TOTAL_UNPAIRED=4` where the
real diff reports `0` — so the pass is a measurement, not a tautology. The known hole, which the
artifact records rather than conceals, is that a hunk deleting a literal while separately adding an
unrelated line carrying the same literal nets to zero. Pairing is also the correct semantics for the
permitted change: standing constraint 2 freezes the literal text and expressly permits the operand to
change, and a line-oriented diff renders an in-place operand rewrite as exactly such a pair. Counting
per hunk rather than per file keeps the pairing local, which is the right granularity.

**Does the frozen-literal guarantee actually hold?** Yes, and the reviewer established it by a
stronger method that does not depend on the formula at all: direct base-versus-head content
comparison of every literal group. All seven groups are byte-identical at head — the six denylist
literals in the same order, the five trigger patterns in the same order, the four promotion tokens in
the same order with the reason string intact, both `gh` expressions, the `$ghApiIssuesPostPattern`
declaration, `$script:CdChainedReadCommandPattern`, and both abandon token constants. The only
change on any of those lines is the operand (`$CommandText` to `$segment.ScanText`), which is the
permitted change. A whole-feature scan additionally shows **zero reason-code tokens on any removed
line**. The residual limitation the artifact accepts is therefore closed by observation on this
branch, even though it remains a limitation of the formula in general.

## 4. Independent Verification of the Orchestrator's Four Claims

| # | Orchestrator claim | Reviewer's derivation | Agreement |
|---|---|---|---|
| 1 | `ci.yml` is gated on the PR base ref, so an epic-child PR runs essentially no CI; `_poshqc.yml` was dispatched directly against `06d166e0` (run `34181009673`, `success`); the Format step is a fail-on-dirty gate; 4363 tests / 0 failures | Read `.github/workflows/ci.yml`: `pull_request: branches: [main, development]` filters the base ref, and `push` excludes the feature branch, so neither trigger fires for this branch. Read `.github/workflows/_poshqc.yml`: it carries `workflow_dispatch:` alongside `workflow_call:`, and the Format step runs `Invoke-PoshQCFormat` and then `Write-Error` if `git status --porcelain` is non-empty. Analyze and Test likewise fail the job on error, and the artifact upload step publishes both XML files. | **Agrees.** The reviewer holds no copy of the run's own XML and did not re-derive the 4363 figure directly, but the workflow's gating semantics make `success` sufficient evidence of 0 failures. |
| 2 | The two local failures do not reproduce in CI; the local tolerance is evidenced | Extracted both from the local JUnit. (a) `enforce-pr-author-skill.Tests.ps1:145` fails because this worktree's gitignored `orchestrator-state.json` carries `epic_mode: true` and the fixture carries no `--base`, so `EPIC_BASE_BRANCH_MISMATCH` fires at `enforce-pr-author-skill.epic-base-branch.ps1` L109. The `[P0-T6]` cycle-2 baseline records the same failure before any cycle-2 code change, and the fixture is a plain non-wrapper command that never enters the cycle-2 fallback block. (b) `codex-pretooluse-integration.Tests.ps1:165` fails with `EPIC_WAVE_BARRIER_BLOCKED: '545' cannot mutate until every depends_on edge is merged`, which reads the live epic checkpoint from disk. | **Agrees.** Both are ambient-state dependent and neither touches a cycle-2 file. A CI runner has neither an epic-mode orchestrator-state nor an epic checkpoint naming 545. Evidenced, not asserted. |
| 3 | All seven changed production files at or above 85.0000 with no regression, at the stated figures | Parsed `artifacts/pester/powershell-coverage.xml` directly. Four of the seven rows are reproducible locally and **all four match the stated figure to four decimal places**: 96.7213, 93.5897, 96.0000, 94.6237. The three unreproducible rows are exactly the newly registered `CodeCoverage.Path` entries, which is the documented MCP-runner limitation and is confirmatory rather than a gap. | **Agrees** on the four re-derivable rows; the remaining three are accepted on the CI artifact with the absence pattern as corroboration. |
| 4 | Plan completion: 61 of 61 tasks checked | `grep -c "^- \[x\]"` returns 61; `grep -c "^- \[ \]"` returns 0. | **Agrees.** |

## 5. Non-Blocking Observations

Recorded for completeness; none affects the blocking count.

- **AC-22** closes on the PR body and is the orchestrator's responsibility. Left unchecked in
  `spec.md`. Issue #591 remains open through this epic.
- **EA-3(a)**, scope-fenced: `Test-ChildCheckpointAllowsEpicMerge` (L177–205, consulted first at
  L419) and its Codex sibling take only a `Checkpoint` parameter, so a checkpoint with `epic_mode`
  true and `step9_status` passed authorizes merging any PR. Confirmed present; filed follow-up.
- **EA-3(b)**, scope-fenced: the `.codex` hook copies outside the delivered D11 scope. The reviewer
  confirms `.codex/hooks/` carries no abandon gate and no pr-author helpers, and that
  `.codex/hooks/validate-bash.ps1` contains no `CdChainedRead` logic, so R-2.b, R-2.c, and R-2.d are
  correctly Claude-only rather than partially delivered.
- **P-1**: the AC-09 criterion text was extended during check-off. Substance unchanged; see policy
  audit 10.1.
- **C-5 through C-9**: five Low or Informational code observations; see the code review.
- Cycle-1 **C-2** (`rm -rfv`) and **C-4** (the 500-line file) remain open and out of scope. C-4 was
  re-verified untouched at exactly 500 lines. Cycle-1 **C-3** (the dead pattern constant) closes as a
  side effect of R-2.d, as predicted.
- Follow-ups **F-1 through F-7** at
  `docs/features/potential/2026-09-07-issue-545-feature-review-follow-ups.md` remain out of scope.

## 6. Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/spec.md
- Total AC items: 37
- Checked off (delivered): 36
- Remaining (unchecked): 1
- Items remaining: AC-22 (line 1565) — "Issue #591 is recorded as superseded by issue #545 and
  closed on merge. … The pull-request body states the supersession and names issue #591."
```

Check-off actions taken by this reviewer: **none required.** Every criterion evaluated PASS was
already checked in `spec.md`. AC-22 is the only unchecked item; it is evaluated UNVERIFIED because it
closes on an artifact outside the tree, and it is correctly left unchecked. No criterion was
unchecked, reworded, or added by this audit.

## 7. Verdict

**PASS. `blocking_count = 0`.**

Cycle 2 delivered exactly what cycle 1 required: the four fail-open call sites are fixed by a new
separately named predicate, the two ring-fenced token readers and the six fail-closed-correct call
sites are byte-unchanged, both directions are pinned by test on every applicable runtime, the frozen
literals and copy-set parity hold under independent re-derivation, coverage rose on all seven changed
production files with no regression, and 61 of 61 plan tasks are complete. The over-match this
feature exists to remove has not been reintroduced.

Remediation cycle 2 closes. Cycle 3 is not required.
