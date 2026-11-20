# Acceptance-Criteria Status Summary (issue #413, [P7-T3])

Timestamp: 2026-07-25T17-36

AC source (work mode `full-bug`, so `spec.md` is the sole AC source and `user-story.md` is
intentionally absent): `docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/spec.md`,
section `## Acceptance Criteria` (13 items, lines 160-172).

Protocol applied: `.claude/skills/acceptance-criteria-tracking/SKILL.md` — evidence before
check-off, one item at a time, criterion text preserved verbatim, unmet items left unchecked
with the gap documented.

## Per-criterion evaluation

### AC1 — Unit-level ALLOW regression test exists and passes — **[x] SATISFIED**

`It 'reports no errors when the seam returns exit 0 with the validator success line (issue #413)'`
exists in `Context 'Invoke-RoutingContractValidation'` of
`tests/scripts/claude-hooks/validate-orchestrator-output.Tests.ps1`, stubbing `ExitCode = 0`
with `Output = 'orchestrator-state validation passed: artifacts/orchestration/orchestrator-state.json'`
and asserting `$result.HasErrors | Should -BeFalse`.

Evidence: `../regression-testing/fail-before.2026-07-25T17-14.md` (FAILED before the fix) and
`../regression-testing/pass-after.2026-07-25T17-17.md` (PASSED after, 2ms).

### AC2 — End-to-end ALLOW regression test exists and passes — **[x] SATISFIED**

`It 'allows DONE when the validator exits 0 and prints its success line (issue #413)'` exists in
`Context 'routing-contract validation (Gap 1)'`, exercising `Invoke-OrchestratorOutputValidation`
with a `-RoutingInvoker` stub returning `ExitCode = 0` and the success-line output, asserting
`$result.Ok | Should -BeTrue` and `$result.Message | Should -BeNullOrEmpty`.

Evidence: `../regression-testing/fail-before.2026-07-25T17-14.md` (FAILED before) and
`../regression-testing/pass-after.2026-07-25T17-17.md` (PASSED after, 7ms).

### AC3 — Existing non-zero-exit BLOCK tests pass unmodified — **[x] SATISFIED**

`reports HasErrors when the seam returns a non-zero exit code` and
`blocks DONE with ROUTING_CONTRACT_BLOCKED when the validator reports errors` both pass and
neither appears as a changed line in `git diff` of the test file.

Evidence: `../regression-testing/pass-after.2026-07-25T17-17.md` section `[P4-T2]` (per-test
diff-scope table plus pass status).

### AC4 — Gate still fails closed with no weakening, including exit 2 and crash paths — **[x] SATISFIED**

No blocking assertion was removed or relaxed (AC3 evidence). The new
`It 'reports HasErrors when the seam returns exit code 2 (argparse misuse / crash path stays fail-closed)'`
passes both before and after the fix, proving non-1 non-zero exits still block. The fixed
expression `$hasErrors = ($exitCode -ne 0)` blocks on every non-zero value by construction.

Evidence: `../regression-testing/fail-before.2026-07-25T17-14.md` and
`../regression-testing/pass-after.2026-07-25T17-17.md` (exit-2 test PASSED in both);
`hook-e2e-live-checkpoint.2026-07-25T17-36.md` (real-path fail-closed: the hook exits 1 and
emits `ROUTING_CONTRACT_BLOCKED:` against the genuinely failing live checkpoint).

### AC5 — Block-reason discrimination unchanged — **[x] SATISFIED**

`validate-orchestrator-output.model-routing.Tests.ps1` passes unmodified (6/6), including both
`MODEL_ROUTING_BLOCKED` cases and the `ROUTING_CONTRACT_BLOCKED` fallback. The hook diff
contains only two hunks, both inside `Invoke-RoutingContractValidation`, so the
`model_routing_receipts|complexity_assessments` regex in `Invoke-OrchestratorOutputValidation`
is textually unchanged.

Evidence: `../regression-testing/model-routing-discrimination.2026-07-25T17-17.md`.

### AC6 — Defect-asserting test revised; exit-0-with-text-blocks assertion gone from the suite — **[x] SATISFIED**

`It 'reports HasErrors when the seam returns error text with exit 0'` was replaced in place.
A tree-wide search confirms the assertion no longer exists:
SearchScope `tests/`; SearchPatterns `ExitCode = 0.*Output\s*=\s*'some error'` and
`reports HasErrors when the seam returns error text with exit 0`; SearchResult `none`.

Evidence: `../regression-testing/pass-after.2026-07-25T17-17.md` (diff hunk 2 and the
negative-claim search record).

### AC7 — Return contract and seam signature unchanged; docstring corrected — **[x] SATISFIED**

The hook diff shows `return @{ HasErrors = $hasErrors; ErrorText = $outputText }` as an
unchanged context line, and the `param(...)` block including
`[scriptblock] $Invoker = { param($Path, $Type) ... }` is entirely outside both hunks. The
`.DESCRIPTION` now documents exit-code-only discrimination and no longer documents the
two-disjunct rule. `ErrorText` still carries the captured combined output, demonstrated live
by the block message quoting the validator's real error lines verbatim.

Evidence: `../regression-testing/model-routing-discrimination.2026-07-25T17-17.md` (two-hunk
diff), `hook-e2e-live-checkpoint.2026-07-25T17-36.md` (ErrorText content on the real path).

### AC8 — Bundled copy byte-identical and parity pytest passes — **[x] SATISFIED**

Both copies hash to `5E4BFA47C748C4E2E44262141E1F543B1ADE1A19ED43005855735AB422D3183B`
(`equal=True`), and the parity pytest passes 7/7 both immediately after the resync and again
at the end of the QA loop.

Evidence: `bundle-byte-parity.2026-07-25T17-16.md`, `parity-pytest.2026-07-25T17-16.md`,
`final-parity-pytest.2026-07-25T17-24.md`.

### AC9 — Portable fallback verified unchanged and still fails closed — **[x] SATISFIED**

`git status --porcelain` returns empty for both `OrchestratorStateCompletion.psm1` copies and
its test file. `OrchestratorStateCompletion.Tests.ps1` passes 7/7 unmodified, including three
`fail-closed conditions` tests. Both module copies were read and confirmed to return literally
`@{ ExitCode = 0; Output = '' }` on success (line 240) with `ExitCode = 1` on every error path
(lines 227, 237).

Evidence: `../regression-testing/portable-fallback-tests.2026-07-25T17-17.md`,
`../baseline/portable-fallback-verification.2026-07-25T17-01.md`.

### AC10 — Test file at or under the 500-line cap — **[x] SATISFIED**

Post-edit count **486** lines (pre-edit 449, net +37); cap 500; 14 lines of headroom. No
sibling test file was required, so the test-location clause does not apply.

Evidence: `../baseline/test-file-line-budget.2026-07-25T17-01.md` section `[P4-T5]`.

### AC11 — Toolchain clean in a single pass with line >= 85%, branch >= 75%, no regression on changed lines — **[ ] NOT FULLY VERIFIABLE**

**Left unchecked.** Five of the six sub-clauses are verified; the branch-coverage sub-clause
cannot be verified with any measured value by this toolchain.

| Sub-clause | Status | Evidence |
|---|---|---|
| PoshQC format succeeds | **PASS**, no files changed | `final-poshqc-format.2026-07-25T17-24.md` |
| PSScriptAnalyzer analyze succeeds | **PASS**, 0 findings | `final-poshqc-analyze.2026-07-25T17-24.md` |
| Pester test succeeds | **PASS**, 1,347 passed / 0 failed / 9 skipped | `final-poshqc-test.2026-07-25T17-24.md` |
| Single clean pass (no restart) | **PASS** — no stage failed or changed a file | all three artifacts above |
| Line coverage >= 85% | **PASS** — 89.68% overall (threshold +4.68 pp) | `coverage-delta.2026-07-25T17-24.md` check (a) |
| No coverage regression on changed lines | **PASS** — changed line 232 is covered (`mi=0`), per-file missed counts unchanged (12 instructions / 8 lines), per-file LINE % unchanged at 92.16% | `coverage-delta.2026-07-25T17-24.md` check (b) |
| **Branch coverage >= 75%** | **NOT MEASURABLE** | `coverage-delta.2026-07-25T17-24.md` check (c) |

**Stated gap:** `artifacts/pester/powershell-coverage.xml` is written by Pester's
`CoverageGutters` (JaCoCo) writer, whose counter set in this repository is INSTRUCTION, LINE,
METHOD, and CLASS only. No `BRANCH` counter is emitted at the report or per-`<sourcefile>`
level, so no branch-coverage figure exists to compare against the 75% gate. This is a
documented, pre-existing tooling limitation of the repository's PowerShell stack, not a
consequence of this change; precedent is recorded at
`docs/features/completed/2026-07-02-local-preflight-orchestrator-state-gate-272/evidence/baseline/poshqc-test-baseline.md`,
and plan tasks [P0-T5], [P6-T3], and [P6-T5] state explicitly that the absent branch metric
does not trigger the fail-closed evidence rule.

Per the acceptance-criteria-tracking rule "leave unmet items unchecked", this item stays
`- [ ]` because one clause of it cannot be substantiated with evidence. Nothing in this change
degraded branch coverage; the metric simply is not produced. Accepting this AC requires a
reviewer decision to treat the branch-coverage clause as not-measurable, which is outside this
executor's authority to grant.

### AC12 — Primary acceptance evidence: hook exercised end-to-end, exits 0 — **[x] SATISFIED**

The fixed hook was run with its **real** default `$Invoker` (a genuine Python subprocess with
`2>&1` capture, no mock, no injected seam) and a DONE-claiming `CLAUDE_HOOK_INPUT`, against a
checkpoint independently proven to pass
`--require-complete --require-model-routing` at exit 0. **The hook exited 0** and produced no
output.

**Recorded deviation (sanctioned by the approved plan, task [P5-T2]):** the checkpoint used was
the fixture
`<FEATURE>/evidence/other/completion-passing-checkpoint.2026-07-25T17-19.json`,
not the live `artifacts/orchestration/orchestrator-state.json`. The live checkpoint is owned by
the enclosing orchestration, is mid-run, and fails the DONE gate for reasons unrelated to this
change (steps 6-10 pending; `pr_gate`/`ci_gate` and downstream receipts not yet written — see
`live-checkpoint-precheck.2026-07-25T17-19.md`). Bringing it to a passing state would require
writing to a file this execution is forbidden to modify. The plan created the fixture branch
precisely for this situation and defines its acceptance as "hook exit code 0 against a
checkpoint proven to pass `--require-complete --require-model-routing` through the real Python
subprocess seam", which is met exactly. The live checkpoint was read only and never written.

Evidence: `hook-e2e-allow.2026-07-25T17-19.md` (fixture validation exit 0; hook exit 0;
old-vs-new decision measurement `OLD_hasErrors=True` / `NEW_hasErrors=False` against the real
validator output), `hook-e2e-live-checkpoint.2026-07-25T17-36.md` (skip-branch record and
live-path fail-closed demonstration).

### AC13 — No unintended changes outside scope — **[x] SATISFIED**

The audited union of `git status --porcelain`, `git diff --name-only`,
`git diff --name-only --cached`, and `git diff --name-only main...HEAD` contains exactly the
three in-scope files plus files under `<FEATURE>/` (and pre-existing branch commits). No Python
validator, complexity-floor implementation, `ModelRouting.psm1`, `.codex/` file,
`OrchestratorStateCompletion.psm1`, `pester.runsettings.psd1`, lockfile, policy document, or
`artifacts/orchestration/orchestrator-state.json` appears.

Evidence: `diff-scope-audit.2026-07-25T17-36.md`.

## Summary

```text
### Acceptance Criteria Status
- Source: docs/features/active/2026-07-25-orchestrator-completion-hook-false-block-413/spec.md
- Total AC items: 13
- Checked off (delivered): 12
- Remaining (unchecked): 1
- Items remaining: AC11 — "The PowerShell toolchain loop passes cleanly in a single pass:
  PoshQC format, PSScriptAnalyzer analyze, and Pester test all succeed, with line coverage
  >= 85% and branch coverage >= 75% and no coverage regression on changed lines."
  Reason: 6 of 7 sub-clauses verified (format clean, analyze 0 findings, Pester 1,347 passed /
  0 failed, single clean pass, line coverage 89.68% >= 85%, no regression on changed lines).
  The branch-coverage >= 75% sub-clause is NOT MEASURABLE — this repository's Pester
  CoverageGutters/JaCoCo output emits INSTRUCTION/LINE/METHOD/CLASS counters and no BRANCH
  counter. Documented tooling limitation with repository precedent (#272); not caused by this
  change. Requires a reviewer decision to accept the clause as not-measurable.
```

Every checked AC above cites at least one artifact that exists on disk under
`<FEATURE>/evidence/`. The single unchecked AC has a stated reason.
