# Remediation Inputs (Issue #824)

Review-Verdict: REMEDIATION_REQUIRED

**Entry timestamp:** 2026-10-03T13-56
**Feature folder:** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824`
**Base branch:** `origin/main` (merge base `f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5`)
**Head:** `bug/promotion-hook-raw-containment-false-positive-deny-824` @ `c7b78cd2ea8c5a0bd010f0424f54498b7802597c`
**Work mode:** `full-bug`; AC source is `spec.md` only (including `## Scope Extension`)
**Review pass:** 2 (reaudit after remediation cycle 1)
**Blocking finding count:** 3 (all autonomous)
**Remediation plan target:** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/remediation-plan.2026-10-03T13-56.md` (to be authored by `atomic-planner` through the orchestrator handoff)

## Audit Artifacts

- `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/policy-audit.2026-10-03T13-56.md` (Section 8, G-1, G-2, G-3)
- `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/code-review.2026-10-03T13-56.md` (Findings Table, CR-1, CR-2, CR-3)
- `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/feature-audit.2026-10-03T13-56.md` (39 PASS, 1 PARTIAL AC-14, 1 pending-CI AC-27, 0 FAIL)

## Trigger Justification

Remediation is triggered under `.claude/skills/feature-review-workflow/SKILL.md` step 8. The code review contains three blockers (CR-1, CR-2, CR-3), AC-14 is PARTIAL, and the Bash coverage verdict is FAIL. Format, lint, type-check, and tests pass. PowerShell and Python coverage meet the governing thresholds.

## Probe Method (for reproducing every row below)

Extract the merge base with `git archive f6ef5b2f .claude/hooks .claude/lib .codex` into a scratch directory outside the repository. Dot-source each hook from that copy and from the worktree, then call the decision seam with one command at a time:

- `Invoke-EpicWorktreeRemovalGateDecision` and `Invoke-ParallelWorktreeRemovalGateDecision`: Claude envelope `{tool_name: Bash, tool_input: {command}}`. Mock `Resolve-*RunTarget` to a SessionRoot. Mock the checkpoint seams so that the checkpoint names `/repo/worktrees/item-b-102`, so nothing authorizes `/repo/worktrees/item-a-101`.
- `Invoke-CodexWorktreeRemovalDecision`: `-PayloadRaw` with `{cwd, tool_name, tool_input}` and `-EpicCheckpointRaw` naming item-b-102. A `$null` result means allow.
- `Invoke-PromotionMcpOnlyDecision`: Claude envelope, and Codex mapped envelope `{command}`.

Controls: `bash -c "git worktree remove /repo/worktrees/item-a-101"` and `gh issue create --title x` are denied at both commits.

## Findings

### R1 — Worktree-removal gates allow real removals through the NoOperand branch

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The defect is confined to Get-CommandLineRawInvocationOperand in hook-command-raw-invocation.ps1 (four byte-identical copies) and the three gate call sites; every reproduction string is recorded below and no external system, policy change, or owner decision is needed.

**Problem.** Commit c7b78cd2 added a branch to each gate: when `Resolve-CommandLineWrappedInvocationOperand` returns `NoOperand`, the gate allows. The reader returns `NoOperand` when the first token after the matched `git worktree remove` is empty under `^[^\s;&|<>()]*`. That happens when the operand follows a redirection or a PowerShell parenthesized expression, and when `xargs` supplies the operand. In P = `/repo/worktrees/item-a-101`:

| ID | Command (verbatim, P expanded) | Epic (Claude) base/head | Parallel (Claude) base/head | Codex epic base/head |
|---|---|---|---|---|
| X1 | `bash -c 'echo /repo/worktrees/item-a-101 \| xargs git worktree remove'` | deny/allow | deny/allow | deny/allow |
| X2 | `echo /repo/worktrees/item-a-101 \| xargs git worktree remove` | deny/allow | deny/allow | not run |
| X3 | `pwsh -c 'git worktree remove (Join-Path /repo/worktrees item-a-101)'` | deny/allow | deny/allow | deny/allow |
| X4 | `bash -c 'git worktree remove >/dev/null /repo/worktrees/item-a-101'` | deny/allow | deny/allow | deny/allow |
| X7 | `pwsh -c 'git worktree remove --force (Get-Item /repo/worktrees/item-a-101)'` | deny/allow | deny/allow | not run |
| X8 | `bash -c 'printf "%s" /repo/worktrees/item-a-101 \| xargs git worktree remove --force'` | deny/allow | deny/allow | not run |
| X10 | `bash -c 'git worktree remove </dev/null /repo/worktrees/item-a-101'` | deny/allow | deny/allow | not run |

(`\|` in the table is the shell pipe character.)

**Required fix (in `hook-command-raw-invocation.ps1`; copy byte-identically to `.codex/hooks/` and both extension mirrors):**

1. In `Get-CommandLineRawInvocationOperand`, return `Indeterminate`, not `NoOperand`, when the first non-separator character after the match (or after a skipped `-f`, `--force`, or `--`) is `(`, `<`, `>`, `@`, or a digit immediately followed by `>`. As an alternative, skip a redirection operator and its target, then continue reading the operand.
2. Return `Indeterminate` when the matched invocation is the command argument of `xargs` (token-bounded `xargs`, an optional option run, then the matched command word) or of `find ... -exec`/`-execdir`.
3. Return `NoOperand` only when the next character after the match is end of text, a closing quote followed by end of text or a terminator, `;`, `&`, `|`, `#`, `)`, or a newline.
4. Keep `A824-WT6` (`pwsh -NoProfile -Command 'git worktree remove'` allowed), `A824-WT3` (Addendum 1 reproduction allowed), `A824-WT4-1..5`, and `A824-WT5-1..5` green without assertion edits.
5. Keep `hook-command-raw-invocation.ps1` under 500 lines and every public signature unchanged.

**Required tests (tag `Issue824`):**

- Deny rows for X1, X2, X3, X4, X7, X8, X10 without an authorizing record in `enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1`, `enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1`, and `enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1` (Codex), asserting the existing deny reason prefix.
- Unit rows in both `hook-command-raw-invocation.Tests.ps1` files: `Get-CommandLineRawInvocationOperand` returns `Indeterminate` for each X raw text, and `NoOperand` for `git worktree remove`, `git worktree remove; echo done`, and `git worktree remove | cat`.

### R2 — R2 matcher misses positional-parameter and xargs-led invocations

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The correction is confined to the expansion and absorber grammar in Get-CommandLineRawInvocationPattern and Get-CommandLineRawInvocationMatch (four byte-identical copies) plus new Pester rows; every reproduction string is recorded below.

**Problem.** Through `Invoke-PromotionMcpOnlyDecision`, each of these is denied at the merge base and allowed at head on both runtimes:

| ID | Command (verbatim) |
|---|---|
| Y1 | `bash -c 'gh "$@"' _ issue create` |
| Y2 | `bash -c 'gh $*' _ issue create` |
| Y3 | `bash -c 'echo issue create \| xargs gh'` |
| Y5 | `bash -c 'gh $1 $2' _ issue create` |

The shared matcher serves every R2 caller, so the same spellings with other command paths (for example `gh pr create`, `git worktree remove`) are affected.

**Required fix:**

1. Add positional and special parameters to the expansion and absorber alternatives: `\$[0-9@*#]` and `\$\{[0-9]+\}`, optionally quoted.
2. Add an xargs form. Accept a match when token-bounded `xargs`, an optional option run, and the literal command word are followed by end of command (end of text, a closing quote, `;`, `&`, `|`, or a newline), and every subcommand literal occurs token-bounded somewhere in the raw text. Treat this form as not fully literal, so the operand reader returns `Indeterminate`.
3. Keep the reproduction (P824-A1), AC-6 (P824-A2), A824-PR1, A824-WT1, A824-WT3, A824-WT9, the pass-1 CR-2 allow rows, R824-N1..N7, and N824-1 green without edits.

**Required tests (tag `Issue824`, both runtimes):**

- Unit rows: Y1, Y2, Y3, Y5 raw texts classify for `gh issue create`. Negative rows: `bash -c 'gh "$@"' _ pr list` does not classify for `issue create`, and `echo issue | xargs gh` does not classify (one literal absent).
- Promotion deny rows for Y1, Y2, Y3, Y5 in `enforce-promotion-mcp-only.TriggerScoping.Tests.ps1` and `enforce-promotion-mcp-only-trigger-scoping.Tests.ps1`, asserting `Get-PromotionMcpOnlyGhIssueBlockedReason`.

### R3 — Bash changed lines in `.codex/codex-web-setup.sh` are untested and unmeasured

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: Adding bats tests and a scoped kcov measurement for the changed lines requires only repository test files and recorded evidence; no policy file, external system, or owner decision is involved.

**Problem.** The branch adds solution-file discovery (lines 9-16), a skipped restore when no solution exists (lines 268-271), and a `fail` in `verify_windows_visual_studio_task_capability` (line 294). No test drives them. The existing `tests/shell/test_codex_web_setup_*.bats` source `.github/codex/codex-web-setup.sh`, which is a different copy. The executor recorded "Bash coverage: N/A", which the review contract does not accept for a language with changed files.

**Required fix:**

1. The `.codex` copy calls `main "$@"` unconditionally (line 394), so sourcing it runs the setup. First make it safe to source: add the standard `BASH_SOURCE` guard that the `.github/codex/` copy already carries, or move discovery into a function that the tests can call alone. Mirror the change to the bundled copy. Then add bats tests that cover four cases: no `.sln` at the root, so `REPO_ROOT` falls back to the working directory and `SOLUTION_FILE` is empty; one `.sln`; several `.sln` files, where the first by `LC_ALL=C` order is chosen; and both no-solution branches with their messages. Use committed fixture directories under `tests/fixtures/`, or refactor discovery into a function that takes the candidate names. Do not create temporary files.
2. Run the tests under kcov scoped to `.codex/codex-web-setup.sh`, and record the changed-line coverage under `evidence/qa-gates/`. Every changed executable line must be covered.
3. Keep both copies byte-identical, keep `bash -n` clean, and keep the file under 500 lines.

**Exit condition for this finding:** a reviewer can grade the Bash changed lines PASS from the recorded measurement. Whole-file coverage of the pre-existing script, and adding `.codex/` to the shell-QC discovery roots, are policy questions recorded as advisory A2. They are not part of this finding.

## Verification Commands

- `Invoke-Pester` with `-TagFilter Issue824` on every changed suite, then `Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .` with coverage. The raw-invocation modules and the three gates must stay at or above 85% lines with no uncovered changed line.
- `Invoke-PoshQCFormat -Root .` (no rewrite) and `Invoke-PoshQCAnalyze -Root .` (zero findings).
- `sha256sum` across the four copies of `hook-command-raw-invocation.ps1` (one distinct hash).
- `poetry run pytest` on the four parity files named in AC-24 and on `tests/scripts/dev_tools/test_push_down_issue_824_follow_ups.py`.
- `bats` on the new setup-script tests, kcov for the changed-line measurement, and `bash -n` on both copies.
- Fail-before evidence: run the new X and Y rows against head `c7b78cd2` and record that they fail. Record pass-after under `evidence/regression-testing/`.
- Repeat the base-versus-head probe above for X1-X10 and Y1-Y5 and record the decisions.

**AC impact:** AC-14 is re-checked by the reaudit when every X and Y row is denied on every runtime where the hook exists.

## Advisory Items (do not gate the exit condition)

- **A1.** The matcher is still a list of recognized spellings, and each review pass has found more. A closed alternative is token-bounded unordered presence: classify when the command word and every subcommand literal each occur token-bounded somewhere in the raw text. It still allows every AC false-positive fixture (AC-5, AC-6, AC-18, AC-20, AC-21, AC-30). It conflicts with AC-1's "order-preserving" wording, so adopting it is the owner's decision. Do not adopt it in this cycle without that decision.
- **A2.** Policy conflict: the shell-QC discovery roots (`.claude/rules/shell.md`) exclude `.codex/`, while the Coverage Exclusion Policy admits no excluded production file. Record a follow-up for the owner.
- **A3.** `.claude/rules/typescript.md` line 57 still refers to "the No-COM architecture assertions", and `.claude/rules/csharp.md` lines 5 and 10 name No-COM; the bundled copies match. The owner's authorization does not cover these files. Record a follow-up.
- **A4.** `.codex/hooks/validate-feature-review-coverage.ps1` keeps a fixed 80% floor and no threshold precedence. Record a follow-up.
- **A5.** The six spec Non-Goals follow-ups are still unfiled (carried from pass 1).
- **A6.** Optional hardening: read a quoted operand up to its closing quote (code review CR-5), and require a comparator before a CLAUDE.md coverage figure (CR-4).

## Do Not Do

- Do not reword or delete existing tests or assertions to make them pass; AC-16 and AC-29 forbid assertion edits.
- Do not restore `Test-CommandLineRawContainment` as a classification path. Do not route any R2 match, or any `Indeterminate` operand, to an allow.
- Do not change deny reason strings, `.claude/settings.json`, or hook registration. Change gate decision logic only as R1 requires.
- Do not modify `.claude/rules/` or `.github/instructions/` in this cycle; the owner authorization in comment 5970141337 is spent on the FU-823 edits already made.
- Do not edit `spec.md` criterion text; only AC-14's checkbox changes, and only at reaudit.
- Do not expand scope to the spec Non-Goals items or to advisories A1-A6.
