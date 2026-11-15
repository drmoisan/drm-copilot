# Code Review: Preimplementation gate resolves sibling-worktree Bash to the session root (#1188)

---

**Review Date:** 2026-11-14
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188`
**Feature Folder Selection Rule:** named by the caller; matches the issue number in `issue.md` and the branch `bug/gate-sibling-worktree-pytest-target`
**Base Branch:** `main` (merge base `11c6ecde2e3080722c90bc63289bc160bf9596ea`)
**Head Branch:** `bug/gate-sibling-worktree-pytest-target` at `aca57bf07214fb4436a7459beb1b587eedd6af35` (PR #1191)
**Review Type:** Initial review

---

## Executive Summary

The branch changes 52 files: a new pure string module `enforce-orchestration-preimplementation-gate-operands.ps1` (295 lines, four byte-identical copies), a guarded dot-source plus one call and one early return in `Resolve-OrchestrationGateTarget` of both surfaces' epic-scope files (and their bundle copies), two pack-manifest entries, one `$script:SharedModuleNames` entry, five Pester files (two suites, a shared Cases table, a parity suite, and the legacy list), six byte-identical brief copies, and feature-folder documents and evidence. Neither gate file changed.

Evidence reviewed: the PR context summary (generated at the reviewed head), the full diff, the final QA and coverage-comparison evidence, the reviewer's Pester gate re-run at the head (`evidence/qa-gates/review-pester-gate.2026-11-14T23-52.md`), and reviewer real-process probes of `Get-OrchestrationGateCommandTargetOperand`, `Test-ImplementationCommand`, `Read-CommandLineSegment`, and `Read-CommandLineInvocationSegment` over 70 command forms run from the item worktree's code.

The extraction is well built: it reuses the shared scanner records, keeps I/O in the two existing seams, and fails closed on every non-literal form probed, including forms outside the test table (`pytest "$W/tests"`, `pytest '$W/tests'`, `npm run lint --prefix $W`, `pytest ${HOME}/x`, `` pytest `pwd`/tests ``, `git -C <item> add x && pytest $HOME/x`). Redirection targets (`>`, `>>`, `2>`, `&>`, attached and separate) are skipped, `timeout`/`nice`/`VAR=` prefixes are walked, and payloads under `sh -c` and `pwsh -Command` are harvested.

The one blocking finding concerns acceptance, not the extraction: the AC-6 command `npm --prefix $(pwd) run lint` and the AC-2 command `npx --prefix <item> jest` are never classified by either gate, so they are admitted with no checkpoint read and never reach the new resolution.

**What changed:**
`.claude/hooks/enforce-orchestration-preimplementation-gate-operands.ps1` (+295, new) and its three copies; `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` (+15/-5) and `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` (+10/-2) with bundle copies; Pester suites under `tests/scripts/claude-hooks/` and `tests/scripts/codex-hooks/`; the execution-environment brief.

**Top 3 risks:**
1. Gate fail-open on two command forms named by the acceptance criteria (R1 below): an unquoted command substitution before the npm script word, and an option before the npx tool word.
2. Absolute option values outside every registered worktree (for example `--junitxml /tmp/j.xml` or `--basetemp /tmp/bt` as a separate token) now make an item command ambiguous and deny; this is the AC-7 rule as specified, and the absolute launcher form avoids it.
3. Isolated subagents receive the change only after merge, because hooks run from the default branch (stated in the spec rollout section).

**PR readiness recommendation:** **No-Go** until R1 is remediated in a cycle; the extraction itself needs no change.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` (not in the diff) | `Test-ImplementationCommand` stage-1 loop over `Read-CommandLineSegment` `ScanText` | R1: AC-6 is unmet. `npm --prefix $(pwd) run lint` is scanned as `npm --prefix `, `pwd`, ` run lint`; no segment matches the npm stage-1 pattern (which needs `npm` and the script word in one segment), so the command is unclassified and admitted with zero checkpoint reads. `npx --prefix <item> jest` is likewise unclassified because the npx pattern requires the tool word immediately after `npx` (AC-2 row N3, pinned as an "unclassified control"). The executor's evidence attributes the npm miss to stage 2; the reviewer's probe shows `Test-OrchestrationGateInvocationConfirmed` returns true for every pattern index, so the miss is in stage 1. | Remediate in a cycle per `remediation-inputs.2026-11-14T23-52.md` R1: classify both forms through a stage-1 check that sees the whole substitution-split word and options before the npx tool, placed in a sibling so the 500-line Codex gate does not grow, and revise the spec non-goal and AC-14 accordingly; then restore the V3 gate row to the unquoted AC-6 form and make N3 an allow-ready and deny-not-ready pair. | Both are enforcement-gate fail-opens on commands this item's ACs name; the owner rule routes related findings to a remediation cycle rather than a follow-up issue; the brief now states the gate resolves `npx --prefix`/`-C` for gated commands, which is vacuous while npx with an option is never gated. | Reviewer probe: scan segments and `classified=False` for both commands, `confirmed=True` for stage 2; `evidence/regression-testing/fail-before-v3.2026-11-14T22-09.md`; Cases rows V3 and N3 |
| Minor | `.claude/hooks/enforce-orchestration-preimplementation-gate-operands.ps1` (all four copies) | `Get-OrchestrationGateHostOperand`, POSIX shell branch | `bash --rcfile /w/rc /w/item/run.sh pytest` records `/w/rc` as the script operand (long options are skipped as standalone, so the option value becomes the first non-dash token), giving `Paths` `/w/rc,/w/item/run.sh` and an ambiguous deny. | Optional: skip the value of `--rcfile` and `--init-file` in the POSIX branch, with a G row. | The error is fail-closed (deny), so no command is admitted wrongly; it only denies a rare form. | Reviewer probe output |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-operands.ps1` | rule 5 (runner operands) | Separate-token absolute option values outside every worktree (`pytest <item>/tests --junitxml /tmp/j.xml`, `--basetemp /tmp/bt`) are collected, so the item command resolves `TARGET_WORKTREE_AMBIGUOUS`; inline `--opt=/abs` values are not collected. | No change; the behavior is AC-7 as specified. Consider one sentence in the brief that runner option values should be relative or inline when targeting an item worktree. | Spec decision rule 5 and AC-7 define this; the prescribed launcher form is unaffected. | Reviewer probe output |
| Info | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Cases.ps1` | row U2 | AC-10 names `poetry -C` at the end of the command; the U2 gate row uses `npm run test:unit --prefix`. A trailing `poetry -C` record carries no governed word, so it is not harvested; the npm form exercises the same missing-value rule, and a G row covers `pytest tests && git -C`. | No change. | The substitution is equivalent for the rule under test. | Reviewer probe: `pytest x && poetry -C` gives `Unresolved` false (the poetry record is not harvested); Cases rows 91, 93, 176 |
| Nit | `evidence/regression-testing/fail-before-v3.2026-11-14T22-09.md` | "Why the V3 row changed" | States that stage 2 drops the stage-1 hit; the probe shows stage 1 never matches. | No edit (evidence is append-only); the remediation cycle records the corrected cause. | Accuracy of the recorded root cause guides the R1 fix location. | Reviewer probe |
| Nit | git history | commit `2734e85d9` | A `wip(1188)` checkpoint commit remains in the branch history. | No change if the PR is squash-merged. | History hygiene only. | `git log` |

No covered file is at or above 700 logical lines (largest changed covered file: `legacy-codex-hook-contracts.Tests.ps1` at 517; largest production file: Codex epic-scope at 474). `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The defect is fixed at its source (the operand list passed to `Resolve-HookTargetWorktree`), and neither gate file changed, so classification, the epic per-segment rules, the Write/Edit leg, and the delegation leg are untouched (verified with `git diff --exit-code` against the merge base).
- The `Unresolved` early return precedes the listing reset and every resolver call on both surfaces, so a non-literal operand cannot reach a session-root decision; the V rows assert zero checkpoint reads and zero listing calls.
- The Codex resolver keeps the `apply_patch` marker branch ahead of the operand extraction, so patch bodies are not tokenized as commands.
- Group handling of records split at `$(`, `${`, and backticks harvests the whole shell word, so `pytest $(pwd)/tests` and `poetry -C ${W} run pytest` fail closed even though the scanner splits them.
- Option tables are data with a cited source (`test-execution-command-form.ps1`), and every unmodelled dash token in a prefix or before the poetry subcommand fails closed.

#### API and safety notes

- `Get-OrchestrationGateCommandTargetOperand` returns a fixed shape (`Paths`, `Unresolved`, `Detail`) and is pure; `ShouldProcess` does not apply.
- `Get-OrchestrationGateCommandOperandPath` is unchanged and still called for the staging family; F1 helper parity and the AC-18 inventory pass.
- The sibling is byte-identical in four locations (one SHA-256 prefix `7a8aa56b2666` verified), and each epic-scope file equals its bundle copy (`cmp`).

#### Error handling and logging

- The deny detail names the class and the token (`unresolvable operand (shell variable or substitution): '$W'`).
- A failed dot-source of the sibling is recorded with `Add-HookDependencyFailure` and denies naming the file (I1 on both surfaces).

---

## Test Quality Audit

The G rows pin the extraction for every form named in AC-1 to AC-10 plus governed-word, malformed-record, prefix, redirection, and `git commit -F` rows. The gate rows assert decision, reason code, exact per-path checkpoint reads, and exact listing calls. The fail-before evidence records every named row failing against the unmodified hooks on both surfaces, with R1-R3, N3, and I1 as controls. The mocks use `-ParameterFilter` on `$script:` variables, so no local variable shadows a filter name.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1` and `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-operands.Tests.ps1` — G rows and gate rows per surface.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Cases.ps1` — shared data table.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Parity.Tests.ps1` — four-copy identity, 500-line bound, brief wording.
- `evidence/regression-testing/fail-before.2026-11-14T21-26.md`, `fail-before-v3.2026-11-14T22-09.md` — fail-before proofs.
- `evidence/qa-gates/final-qc-pester.2026-11-14T23-10.md`, `final-qc-pytest.2026-11-14T23-11.md`, `final-qc-powershell-static.2026-11-14T22-58.md`, `coverage-comparison.2026-11-14T23-12.md` — final gates, all exit 0.
- `evidence/qa-gates/review-pester-gate.2026-11-14T23-52.md` — reviewer gate at the head.

### Quality assessment prompts

- **Determinism:** in-memory listing and checkpoint bodies; no clock, file, or process access.
- **Isolation:** one row per form and decision.
- **Speed:** in-memory rows; the full parallel gate ran in 942.33 s wall clock.
- **Diagnostics:** row IDs in `It` names; `-Because` on the Paths assertion; exact `Should -Invoke` counts.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; leak scan 0 failures. |
| No unsafe subprocess or command construction | ✅ PASS | The sibling starts no process and evaluates no text. |
| Input validation at boundaries | ⚠️ PARTIAL | Every non-literal selector or path-like operand of a classified command fails closed; two named forms are never classified (R1). |
| Error handling remains explicit | ✅ PASS | No catch-all; deny reasons carry the reason code and detail. |
| Configuration / path handling is safe | ✅ PASS | Relative operands and lone outside paths keep the prior session-root behavior; ambiguity and listing failure deny. |
| No hook invokes Python | ✅ PASS | No Python call added. |

---

## Research Log

No external research was required. Shell and tool semantics were confirmed by real-process probes of the item worktree's hook code rather than by documentation.

---

## Verdict

The operand extraction and resolver wiring are correct, fully covered, and mirrored. The branch is not ready to merge because AC-6 is unmet and the related npx classification gap leaves the named command forms ungated; both are routed to a remediation cycle as R1.
