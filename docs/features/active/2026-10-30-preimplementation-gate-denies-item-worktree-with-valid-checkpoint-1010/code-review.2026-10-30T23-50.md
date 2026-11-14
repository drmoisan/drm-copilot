# Code Review: Preimplementation gate resolves the target worktree checkpoint (#1010)

---

**Review Date:** 2026-10-30
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-10-30-preimplementation-gate-denies-item-worktree-with-valid-checkpoint-1010`
**Feature Folder Selection Rule:** the only active folder whose suffix matches issue 1010 in the branch name; it holds the material scoping-doc changes.
**Base Branch:** `main` (merge base `0c0027faefff4231a129579b2a850fe4c377f4e8`)
**Head Branch:** `bug/preimplementation-gate-item-worktree-1010` (`54b2b77b1db84a616493e05d6f5d01811823520c`)
**Review Type:** Post-remediation review (remediation cycle 1, findings F1 and F2 from `code-review.2026-10-30T21-54.md`)

---

## Executive Summary

The branch fixes the preimplementation gate evaluating the coordinator session-root checkpoint instead of the checkpoint of the worktree a call targets, on both the Claude and Codex surfaces, by consuming `Resolve-HookTargetWorktree` (#1009) behind the existing `Resolve-OrchestrationGateTarget` seam, and tightens `lifecycle_ready` to the JSON boolean `true`. The initial review (`code-review.2026-10-30T21-54.md`) found no blocking issue. Remediation cycle 1 addressed its two related Minor findings: F1, a Pester suite now pins the three duplicated helper functions to identical text across the Claude and Codex `-epic-scope` files; F2, `Get-OrchestrationGateCommandOperandPath` now walks the tokens after `add`/`commit` with a per-subcommand option model, so `git commit -m msg /abs/wt/file` reads the item checkpoint. The full branch diff against `main` was reviewed, with direct inspection of commit `54b2b77b1`, the coverage artifact, bundle comparisons, the cycle-1 evidence, and a 323-test re-run of seven affected suites.

**What changed in cycle 1:**
The walk consumes the value of a modeled value option (separate, `--name=value`, or attached `-mvalue`), skips standalone flags, treats every token after `--` as an operand, skips redirections and their targets, and stops at any other dash token. Absolute literal tokens it reads as operands are collected; tokens it reads as option values are also removed from the shared parser's `Operands`, which corrects a pre-existing case in which `git commit -F /abs/msg.txt` collected the message file as a pathspec (row B12, which failed before the change).

**Top 3 risks:**
1. The walk stops at any option outside its model (for example `-p`, `-S`, `--cleanup=strip`, or a cluster such as `-am`), so a commit written in those forms is still evaluated against the session-root checkpoint. This fails toward deny and is recorded as a deviation.
2. The shared `Get-CommandLineInvocationOperand` in `hook-command-invocation.ps1` (unchanged on this branch) matches option names case-insensitively, so `-F` is read as the generic standalone `-f`. This branch neutralizes the effect for its own parser; other consumers of the shared parser are not changed.
3. The adapter tail of `Resolve-OrchestrationGateTarget` remains duplicated across surfaces without a text-equality pin, because the Codex function also resolves `apply_patch` markers and the two whole functions cannot be compared.

**PR readiness recommendation:** **Go** — no Blocker or Major findings; all local gates pass, and the PR-head CI run is owned by the S9 gate.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/hooks/hook-command-invocation.ps1` (unchanged on this branch; the Codex copy carries the same logic per the cycle-1 evidence) | `Get-CommandLineInvocationOperand`, lines 286-287 | Option names are tested with the case-insensitive `-contains`, and `$script:CommandLineStandaloneFlagNames` (line 63) holds `-f`, so `git commit -F <file>` is parsed as the flag `-f` followed by an operand. Consumers other than this item's parser still receive the message-file path as an operand. | Track separately: change the option comparisons to `-ccontains` and add case-distinct rows for the consumers of the shared parser. Not a change for this item, whose file set excludes the shared module. | Pre-existing behavior in a file outside the branch diff; this branch's parser now removes walked option values from `Operands` (B12), so the defect no longer affects this gate. | `evidence/regression-testing/fail-before-claude-operand-options.2026-10-30T22-18.md` Deviation section; `grep -n` of lines 63, 286, 287 by this review |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | `Get-OrchestrationGateCommandOperandPath` option walk | Remaining parser scope: unmodeled options, clustered short flags such as `-am`, and argument-injected records stop or skip collection, so those commits read the session-root checkpoint. | Mention in the PR description beside R4 that `git -C <wt> commit ...` and the modeled option forms are the supported item-worktree commit forms. | Fails toward the pre-fix evaluation (stricter), not toward relaxation; B13 pins the conservative stop. | `evidence/qa-gates/self-review.2026-10-30T23-39.md` Deviations, first bullet |
| Info | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeHelperParity.Tests.ps1` | F1 rows | The parity suite pins `Get-OrchestrationGateWorktreeList`, `Invoke-OrchestrationGateWorktreeList`, and `Get-OrchestrationGateCommandOperandPath`. The adapter tail inside each surface's `Resolve-OrchestrationGateTarget` (listing failure, ambiguous, null root, session or other worktree) is still duplicated without a text pin. | None required for this item; behavior parity for the adapter is covered by matching T and C rows on both surfaces. Extracting the adapter into a shared helper would allow it to be pinned in a later change. | The remediation input scoped F1 to the three helper functions; the Codex function differs by design (marker paths). | `remediation-inputs.2026-10-30T21-59.md` F1; this review's diff inspection |
| Nit | `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeHelperParity.Tests.ps1` | lines 69-75 | Both file paths are built from `Join-Path` segments so the epic-state discovery guard, which treats any `hooks/<name>.ps1` literal as a loaded hook, does not count them. The comment documents this. | Optional: give the discovery guard an explicit read-only marker instead of relying on literal shape. | The suite dot-sources nothing, so the census exclusion is correct; the mechanism depends on the guard's literal heuristic. | `evidence/regression-testing/isolation-single-process.2026-10-30T23-38.md` run 1 failure 1 |
| Info | `remediation-plan.2026-10-30T21-59.md` | P1-T4, P1-T6 | The two fail-before tasks are left unchecked because their predictions (B10 `-F msg.txt` fails, B12 passes) were reversed by the shared-parser behavior above. The recorded fail-before runs still show T15/C18, B11, B14, and eight B10 cases failing before the fix. | None; the deviation is documented in both evidence files and the self-review. | Plan-tracking state only; the fail-before evidence for F2 exists. | `evidence/regression-testing/fail-before-*-operand-options.*.md` |
| Info | `artifacts/pester/powershell-coverage.xml` | Claude gate entry point | The latest coverage artifact is the cycle-1 suite subset and reports the Claude gate at 80.50% (128/159). The file is unchanged since commit `84a345c7d`; its main-plan suite-set measurement is 93.08% (148/159). | Confirm the per-file figure in the PR-head CI coverage shard at S9. | Coverage is monotone in the suite set; the subset figure is a lower bound, not a regression. | `evidence/qa-gates/pester-coverage.2026-10-30T21-08.md`; LINE counters parsed by this review |
| Nit | `.codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1` | `Resolve-OrchestrationGateTarget`, `$markerPaths` assignment | Carried from the initial review: every non-path command, including Bash text, is scanned for `apply_patch` markers first. | None; consistent with the pre-existing epic-scope leg. | Unusual input; behavior consistent within the file. | `code-review.2026-10-30T21-54.md` |
| Info | Both `-epic-scope` files | `Get-OrchestrationGateWorktreeList` body | Carried: the three wrapper body lines are uncovered by design (always mocked); one `git worktree list --porcelain` per gated call that needs a checkpoint (spec R5). | None. | Accepted design decision. | `spec.md` R5; `coverage-delta.2026-10-30T22-28.md` |

No Blocker or Major findings. No covered file is at or above 700 logical lines (largest: `tests/scripts/codex-hooks/legacy-codex-hook-contracts.Tests.ps1` at 506; largest production file the Codex gate at 491), so no file-size Warning applies. `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The option walk is identical on both surfaces and is now enforced by the F1 rows, which this review re-ran (5/5).
- Value options are matched case-sensitively (`-ccontains`, `-ceq`), so `-C`/`-c` (reuse/reedit message) and `-F`/`-f` are distinguished inside this parser.
- Every collected token must pass `Test-CommandLineTokenLiteral` and the absolute-path pattern, so quoted or substituted tokens are not treated as paths.
- Option values are subtracted from the shared parser's `Operands`, which closes the pre-existing `-F <abs>` misread for this gate without editing the shared module.
- B15 was added when the coverage delta showed the bare-redirection target skip was unexercised; changed-line coverage is 24/24 on each surface.

#### API and safety notes

- No signature or output-shape change; existing mocks of `Resolve-OrchestrationGateTarget` and the B1-B8 rows are unchanged and pass.
- Collecting more pathspecs can only move evaluation from the session-root checkpoint to the checkpoint of the worktree named by an absolute path; operands in two distinct worktrees still deny as ambiguous, and every readiness requirement is unchanged.

#### Error handling and logging

- An unmodeled option ends the walk without error, which keeps the pre-cycle conservative result.
- `Assert-GateHelperDefinitionParity` throws with a message naming the function and whether it is missing or different.

---

## Test Quality Audit

Cycle 1 added one suite (F1, 5 tests) and 17 rows to each TargetWorktree suite (B10 with eleven cases, B11 to B15, T15 or C18). Fail-before, pass-after, coverage-delta, three seeded shuffles, and a full single-process run are recorded.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.TargetWorktree.Tests.ps1` — 43 tests.
- `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-target-worktree.Tests.ps1` — 47 tests.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.EpicScopeHelperParity.Tests.ps1` — 5 tests.
- `evidence/regression-testing/fail-before-claude-operand-options.2026-10-30T22-18.md`, `fail-before-codex-operand-options.2026-10-30T22-19.md`, `fail-before-exception.2026-10-30T22-17.md`, `f1-parity-detection.2026-10-30T22-17.md`, `pass-after-operand-options.2026-10-30T22-22.md`.
- `evidence/qa-gates/coverage-delta.2026-10-30T22-28.md` — re-verified against the LINE counters in `artifacts/pester/powershell-coverage.xml` by this review (103/115 and 130/134).

### Quality assessment prompts

- **Determinism:** in-memory command text and checkpoint fixtures; the F1 suite reads tracked files and normalizes line endings.
- **Isolation:** one behavior per `It`; the case-fold name collision found by `test-name-uniqueness.Tests.ps1` was fixed with distinct labels.
- **Speed:** no process or disk I/O in the new B, T, and C rows.
- **Diagnostics:** assertions compare the exact returned path list or the checkpoint path read.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; no credentials or tokens. |
| No unsafe subprocess or command construction | ✅ PASS | Cycle 1 adds no process; the parser is pure token logic. |
| Input validation at boundaries | ✅ PASS | Literal-token and absolute-path filters on every collected token. |
| Error handling remains explicit | ✅ PASS | Listing failure, ambiguity, and null root deny with named reason codes; the walk stops conservatively. |
| Configuration / path handling is safe | ✅ PASS | No path composition changed in cycle 1. |
| Gate strictness preserved | ✅ PASS | No readiness requirement relaxed; ambiguity across worktrees still denies; `-targets` files untouched. |

---

## Research Log

No external research was required. The review relied on `spec.md`, the remediation inputs and plan, rule files, the branch diff, the shared `hook-command-invocation.ps1`, and the cycle-1 evidence.

---

## Verdict

The change is ready for normal PR flow. Both remediation findings are resolved with fail-before and pass-after evidence, the duplicated helpers are pinned, per-file coverage of the edited files is 88.17% to 97.01% in its governing measurement with 100% changed-line coverage in cycle 1, and isolation runs are clean. The remaining findings are one Minor item in an unchanged shared module (unrelated to this item's change and suitable for a separate issue), and Info and Nit items that need no change before merge.
