# Remediation Inputs (Issue #824)

Review-Verdict: REMEDIATION_REQUIRED

**Entry timestamp:** 2026-10-03T16-55
**Feature folder:** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824`
**Base branch:** `origin/main` (merge base `f6ef5b2fbec8218ed4c93aea98aa29c19ed454c5`)
**Head:** `bug/promotion-hook-raw-containment-false-positive-deny-824` @ `425772de97a84663d781d2bffeac4b8e4787787f`
**Work mode:** `full-bug`; AC source is `spec.md` v0.3 only (including `## Scope Extension` and `### Remediation cycle 2 additions`)
**Review pass:** 3 (reaudit after remediation cycle 2)
**Blocking finding count:** 2 (R1 autonomous; R2 awaiting_ci)
**Remediation plan target:** `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/remediation-plan.2026-10-03T16-55.md` (to be authored by `atomic-planner` through the orchestrator handoff)

## Audit Artifacts

- `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/policy-audit.2026-10-03T16-55.md` (Section 8, G-1, G-2)
- `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/code-review.2026-10-03T16-55.md` (Findings Table, CR-1, CR-2)
- `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/feature-audit.2026-10-03T16-55.md` (40 PASS, 2 PARTIAL AC-14 and AC-43, 1 pending-CI AC-27, 0 FAIL)
- `docs/features/active/2026-10-03-promotion-hook-raw-containment-false-positive-deny-824/evidence/qa-gates/review-p3-ac42-kcov.2026-10-03T16-55.md` (reviewer bats and kcov record for AC-42)

## Trigger Justification

Remediation is triggered under `.claude/skills/feature-review-workflow/SKILL.md` step 8. The code review contains an autonomous blocker (CR-1), AC-14 and AC-43 are PARTIAL, and a modified workflow lacks a green run against the head (CR-2, wait path). Format, lint, tests, and coverage pass for every changed language: PowerShell 85.52% repo-wide with no uncovered changed line, Python unchanged, and Bash at 100% of the changed functions.

## Probe Method (for reproducing R1)

Extract the merge base with `git archive f6ef5b2f .claude/hooks .claude/lib .codex/hooks` into a scratch directory outside the repository. Dot-source each gate from that copy and from the worktree, then call the decision seam with one command at a time:

- `Invoke-EpicWorktreeRemovalGateDecision`: Claude envelope `{tool_name: Bash, tool_input: {command}}`. Mock `Resolve-EpicWorktreeGateRunTarget` to a SessionRoot. Mock `Get-EpicWorktreeGateCheckpointContent` to `{"features":[{"worktree_path":"/repo/worktrees/item-b-102","merge_status":"merged"}]}` and `Get-EpicWorktreeGateParallelCheckpointContent` to `$null`.
- `Invoke-ParallelWorktreeRemovalGateDecision`: the same envelope. Mock `Resolve-ParallelWorktreeGateRunTarget` to a SessionRoot. Mock `Get-ParallelWorktreeRemovalGateCheckpointContent` to `{"items":[{"issue_num":102,"worktree_path":"/repo/worktrees/item-b-102","merge_status":"merged"}]}` and `Get-ParallelWorktreeRemovalGateEpicCheckpointContent` to `$null`.
- `Invoke-CodexWorktreeRemovalDecision`: `-PayloadRaw` with `{cwd: /repo, tool_name: Bash, tool_input: {command}}` and `-EpicCheckpointRaw` naming item-b-102. A `$null` result means allow.

These are the same checkpoints the existing A824-X rows use, so nothing authorizes `/repo/worktrees/item-a-101`.

Controls:

- `bash -c "git worktree remove /repo/worktrees/item-a-101"` is denied at both commits.
- `bash -c "git worktree remove /repo/worktrees/item-b-102"` is allowed at head.

## Findings

### R1 — Worktree-removal gates authorize a whole command from one literal operand

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The defect is confined to Get-CommandLineRawInvocationOperand and Resolve-CommandLineWrappedInvocationOperand in hook-command-raw-invocation.ps1 (four byte-identical copies) and the three gate call sites; every reproduction string is recorded below and no external system, policy change, or owner decision is needed.

**Problem.** For each fully literal match, `Get-CommandLineRawInvocationOperand` reads the token after the match. When that token is empty, it exits the loop without recording anything. The token is empty when the operand follows `>`, `<`, or `(`, and when `xargs` supplies the operand. If another match in the same text yields a literal operand, the function returns `Operand` with that single value. Separately, `Resolve-CommandLineWrappedInvocationOperand` reads only the first segment that classifies.

Each gate then replaces the structural path with that one operand and authorizes the command on it. A command that names an authorized worktree can therefore carry a second, unauthorized removal. B is `/repo/worktrees/item-b-102` (authorized) and A is `/repo/worktrees/item-a-101` (not authorized):

| ID | Command (verbatim, B and A expanded) | Epic (Claude) base/head | Parallel (Claude) base/head | Codex epic base/head |
|---|---|---|---|---|
| W1 | `bash -c 'git worktree remove /repo/worktrees/item-b-102; git worktree remove >/dev/null /repo/worktrees/item-a-101'` | deny/allow | deny/allow | deny/allow |
| W2 | `bash -c 'git worktree remove /repo/worktrees/item-b-102; echo /repo/worktrees/item-a-101 \| xargs git worktree remove'` | deny/allow | deny/allow | deny/allow |
| W3 | `pwsh -c 'git worktree remove /repo/worktrees/item-b-102; git worktree remove (Join-Path /repo/worktrees item-a-101)'` | deny/allow | deny/allow | not run |
| W4 | `bash -c 'git worktree remove /repo/worktrees/item-b-102 && git worktree remove </dev/null /repo/worktrees/item-a-101'` | deny/allow | deny/allow | not run |
| W5 | `bash -c "git worktree remove /repo/worktrees/item-b-102"; bash -c "git worktree remove /repo/worktrees/item-a-101"` | deny/allow | deny/allow | deny/allow |
| W6 | `bash -c "git worktree remove /repo/worktrees/item-b-102" && git worktree remove /repo/worktrees/item-a-101` | deny/allow | deny/allow | deny/allow |

(`\|` in the table is the shell pipe character.)

The spec's cycle 2 design decision 2 lists "an operand the reader cannot read" among the outcomes that must be denied. The boundary invariant states "No R2 classification and no non-literal operand outcome is routed to an allow". AC-14's general clause states that detection is not weakened. All six commands violate these.

**Required fix (in `hook-command-raw-invocation.ps1`; copy byte-identically to `.codex/hooks/` and both extension mirrors):**

1. In `Get-CommandLineRawInvocationOperand`, return `Indeterminate` when any fully literal match yields no operand token while another match yields one. Return `Operand` only when every accepted match yields the same literal token. Return `NoOperand` only when no match yields a token. An equivalent stricter rule is also acceptable: require the number of fully literal matches to equal the number of whole-token occurrences of the last subcommand word, and return `Indeterminate` otherwise.
2. In `Resolve-CommandLineWrappedInvocationOperand`, return `Indeterminate` when more than one segment of the command classifies for the command word and subcommand path, whether wrapper-led, substituted, or structural. This closes W5 and W6. It may also close the pre-existing structural analogue (`git worktree remove B && git worktree remove A`, allowed at both commits). If the structural analogue is closed, add a row for it. If it is left open, record it as a follow-up and do not widen this cycle further.
3. Keep A824-WT3 (Addendum 1 reproduction allowed), A824-WT4-1..5, A824-WT5-1..5 (single literal operand with an authorizing record allowed), A824-WT6, A824-WT10, A824-WT11-1..2, A824-X1..X10, and every promotion row green without assertion edits.
4. Keep every file under 500 lines and every public signature unchanged. `hook-command-invocation.ps1` is at 494 lines; place new logic in `hook-command-raw-invocation.ps1` (300 lines).

**Required tests (tag `Issue824`):**

- Deny rows for W1-W6, with the checkpoint authorizing item-b-102 only, in `enforce-epic-worktree-removal-gate.TriggerScoping.Tests.ps1`, `enforce-parallel-worktree-removal-gate.TriggerScoping.Tests.ps1`, and `enforce-epic-worktree-removal-gate-trigger-scoping.Tests.ps1` (Codex). Assert the existing deny reason prefix; the Codex rows assert a non-null decision.
- Unit rows in both `hook-command-raw-invocation.Tests.ps1` files:
  - `Get-CommandLineRawInvocationOperand` returns `Indeterminate` for the raw texts of W1-W4.
  - It still returns `Operand` for `git worktree remove /repo/worktrees/item-b-102; git worktree remove /repo/worktrees/item-b-102` (the same operand twice).
  - `Resolve-CommandLineWrappedInvocationOperand` returns `Indeterminate` for W5 and W6.
- Fail-before evidence: run the new rows against head `425772de`, record that they fail, then record pass-after under `evidence/regression-testing/`.

### R2 — Modified workflow has no green run against the branch head

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: The branch modifies .github/workflows/_shell-coverage.yml; the rule requires a successful run of the ci.yml shell-coverage job (Shell Coverage (Bats + kcov)) whose head SHA equals the branch head, and head 425772de is on no remote branch, so no run can exist until the branch is pushed and CI runs.

**Problem.** `modified-workflow-needs-green-run` (`.claude/skills/feature-review-workflow/SKILL.md`) applies because `.github/workflows/_shell-coverage.yml` gains three steps:

- Measure `.codex/codex-web-setup.sh` coverage with kcov.
- Upload the coverage artifacts.
- Gate the changed-function coverage.

`git branch -r --contains HEAD` is empty, and `gh pr list --head bug/promotion-hook-raw-containment-false-positive-deny-824 --state all` returns `[]`.

**Exit condition.** After R1 is remediated, push the branch and open the PR, or dispatch `ci.yml`. Then record under `evidence/qa-gates/` the run URL, the head SHA (equal to the branch head), and conclusion `success` for `shell-coverage / Shell Coverage (Bats + kcov)`. Include the Gate step's six `FUNCTION ... PASS` lines and its `CHANGED-LINES=<n> INSTRUMENTED=<m> UNCOVERED-CHANGED=NONE` line from the pull_request run. This does not require a code change. It is resolved through the orchestrator's push and CI gate (S9), which also covers AC-27.

## Verification Commands

- `Invoke-Pester` on the three gate trigger-scoping suites and both `hook-command-raw-invocation.Tests.ps1` files with `-TagFilter Issue824`. Then run `Import-Module ./scripts/powershell/PoshQC; Invoke-PoshQCTest -Root .` with coverage. The raw-invocation modules and the three gates must stay at or above 85% lines with no uncovered changed line.
- `Invoke-PoshQCFormat -Root .` (no rewrite) and `Invoke-PoshQCAnalyze -Root .` (zero findings).
- `sha256sum` across the four copies of `hook-command-raw-invocation.ps1` (one distinct hash).
- `poetry run pytest` on the four parity files named in AC-24.
- Repeat the base-versus-head probe above for W1-W6 and for the controls, and record the decisions under `evidence/regression-testing/`.

**AC impact:** The reaudit re-checks AC-14 and AC-43 when W1-W6 are denied on every gate where the hook exists. AC-27 and R2 close at S9.

## Advisory Items (do not gate the exit condition)

- **A1 (code review CR-3, Minor).** Add a committed fixture directory with one or more empty `*.sln` files. Assert a non-empty `list_root_solution_files` listing and the derived `REPO_ROOT` and `SOLUTION_FILE` from the top-level wiring.
- **A2.** The shell-QC discovery roots exclude `.codex/`, which conflicts with the Coverage Exclusion Policy. This is carried and needs an owner decision. The whole-file kcov figure for the setup script is 17.0%.
- **A3.** Carried items: residual No-COM names in `.claude/rules/typescript.md` and `.claude/rules/csharp.md`, the fixed 80% floor in `.codex/hooks/validate-feature-review-coverage.ps1`, and the unfiled spec Non-Goals follow-ups.
- **A4 (code review CR-4, Info).** `Set-StrictMode -Version Latest` at file scope in `KcovFunctionCoverageGate.ps1` applies to the dot-sourcing scope.

## Do Not Do

- Do not reword or delete existing tests or assertions to make them pass; AC-16 and AC-29 forbid assertion edits.
- Do not restore `Test-CommandLineRawContainment` or an ordered grammar as a classification path. Do not route any R2 match, any `Indeterminate` outcome, or any unread removal to an allow.
- Do not change deny reason strings, `.claude/settings.json`, or hook registration. Change gate decision logic only as R1 requires.
- Do not modify `.claude/rules/` or `.github/instructions/`.
- Do not edit `spec.md` criterion text; only the AC-14 and AC-43 checkboxes change, and only at reaudit.
- Do not change the kcov gate threshold, its function list, or its include pattern.
- Do not expand scope to the spec Non-Goals items or to advisories A1-A4.
