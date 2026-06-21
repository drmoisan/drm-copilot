# full-release-missing-branch-push (Plan)

- **Issue:** #221
- **Issue source:** docs/features/active/2026-06-21-full-release-missing-branch-push-221/issue.md
- **Spec source:** docs/features/active/2026-06-21-full-release-missing-branch-push-221/spec.md
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-06-21T12-06
- **Status:** Draft
- **Version:** 0.2
- **Work Mode:** full-bug
- **Language in scope:** PowerShell (Pester) only. Type-checking is not applicable to PowerShell.

**Fail-closed evidence rule:** This plan includes explicit PowerShell baseline artifact tasks, final-QA artifact tasks, and a coverage-comparison task. If any required baseline artifact, QA artifact, or coverage-comparison artifact is missing or incomplete, the audit verdict must be BLOCKED or INCOMPLETE, never PASS.

**Evidence accounting rule:** Each evidence-producing task records its canonical artifact path. Do not mark an evidence-backed task complete without the artifact present and schema-complete (`Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`).

**Evidence location invariant:** All evidence artifacts resolve under `docs/features/active/2026-06-21-full-release-missing-branch-push-221/evidence/<kind>/`. Non-canonical paths (e.g., `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`) are prohibited and fail preflight.

**Scope lock (do not exceed):**
- Production file: `scripts/dev-tools/Invoke-FullRelease.ps1` only.
- Test file: `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` only.
- No tagging, no publishing, no refactors. Preserve all existing return-code contracts (2 on missing confirmation; 1 on missing manifest, dirty tree, or failed git/gh seam; npm exit code on bump failure; 0 on success) and the wrapper-seam isolation pattern. File remains under 500 lines.

---

### Phase 0 — Baseline Capture

- [x] [P0-T1] Read policy files in required order and record evidence to `docs/features/active/2026-06-21-full-release-missing-branch-push-221/evidence/baseline/phase0-instructions-read.md` with `Timestamp:`, `Policy Order:`, and the explicit list of files read: `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`.
- [x] [P0-T2] Record the branch and HEAD commit baseline (`git rev-parse --abbrev-ref HEAD` and `git rev-parse HEAD`) to `docs/features/active/2026-06-21-full-release-missing-branch-push-221/evidence/baseline/git-baseline.2026-06-21T12-06.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
- [x] [P0-T3] Run PoshQC format check on the in-scope files and record result to `docs/features/active/2026-06-21-full-release-missing-branch-push-221/evidence/baseline/poshqc-format.2026-06-21T12-06.md` with `Timestamp:`, `Command: mcp__drm-copilot__run_poshqc_format`, `EXIT_CODE:`, `Output Summary:` (pass/fail and any files reformatted).
- [x] [P0-T4] Run PoshQC analyze on the in-scope files and record result to `docs/features/active/2026-06-21-full-release-missing-branch-push-221/evidence/baseline/poshqc-analyze.2026-06-21T12-06.md` with `Timestamp:`, `Command: mcp__drm-copilot__run_poshqc_analyze`, `EXIT_CODE:`, `Output Summary:` (diagnostic count).
- [x] [P0-T5] Run PoshQC Pester tests in coverage mode and record baseline result to `docs/features/active/2026-06-21-full-release-missing-branch-push-221/evidence/baseline/poshqc-test.2026-06-21T12-06.md` with `Timestamp:`, `Command: mcp__drm-copilot__run_poshqc_test`, `EXIT_CODE:`, `Output Summary:` including numeric baseline line-coverage percent and branch-coverage percent for `scripts/dev-tools/Invoke-FullRelease.ps1`.

### Phase 1 — Constrained Small-Path Implementation

- [x] [P1-T1] [expect-fail] Add a negative-path Pester test to `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` in the "git/npm/gh seam failures" context: mock `Invoke-GitExe` to return `ExitCode 1` for `push -u origin <branch>` args (success for all other git args), mock `Invoke-NpmExe` success, mock `Invoke-GhExe` to throw if invoked; assert the result is `1`, that `$script:capturedMessage` matches `Failed to push release branch`, and assert `Should -Invoke -CommandName Invoke-GhExe -Times 0 -Exactly`. Run only this test and record the failing run (push step not yet implemented) to `docs/features/active/2026-06-21-full-release-missing-branch-push-221/evidence/regression-testing/push-failure-fail-before.2026-06-21T12-06.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`.
- [x] [P1-T2] Insert the push step in `scripts/dev-tools/Invoke-FullRelease.ps1` function `Invoke-FullReleaseGuarded`, between Step 4 (the `commit` block ending at the current line that returns after a failed commit) and Step 5 (the `gh pr create` block): call `Invoke-GitExe -GitArgs @('push', '-u', 'origin', $branchName)`; on non-zero `ExitCode`, call `Write-StderrLine -Message "Failed to push release branch '$branchName' to origin (git exit code $(...))."` and `return 1`. Make no other production change. Confirm the file remains under 500 lines.
- [x] [P1-T3] Update the existing success-path test "bumps both manifests and opens a PR against main" in `tests/scripts/dev-tools/Invoke-FullRelease.Tests.ps1` so the `Invoke-GitExe` mock returns `ExitCode 0` for the new `push` args, assert a `push -u origin <branch>` call is recorded in `$script:capturedGitArgsList`, and assert the push call index precedes the `gh pr create` invocation (push is issued before `Invoke-GhExe`). Result must remain `0`.
- [x] [P1-T4] Acceptance check for implementation completion: the push call is present in `Invoke-FullReleaseGuarded` between commit and `gh pr create`; the negative-path test from [P1-T1] now passes; the success-path test from [P1-T3] passes; return-code contracts are unchanged; no edits outside the two in-scope files.

### Phase 2 — Final QC Loop

- [x] [P2-T1] Run PoshQC format (`mcp__drm-copilot__run_poshqc_format`) on the in-scope files; record to `docs/features/active/2026-06-21-full-release-missing-branch-push-221/evidence/qa-gates/poshqc-format.2026-06-21T12-06.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. If files change, restart from this task.
- [x] [P2-T2] Run PoshQC analyze (`mcp__drm-copilot__run_poshqc_analyze`) on the in-scope files; record to `docs/features/active/2026-06-21-full-release-missing-branch-push-221/evidence/qa-gates/poshqc-analyze.2026-06-21T12-06.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` (must be 0 diagnostics). If a fix changes files, restart from [P2-T1].
- [x] [P2-T3] Run PoshQC Pester tests in coverage mode (`mcp__drm-copilot__run_poshqc_test`); record to `docs/features/active/2026-06-21-full-release-missing-branch-push-221/evidence/qa-gates/poshqc-test.2026-06-21T12-06.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:` including numeric post-change line-coverage percent and branch-coverage percent for `scripts/dev-tools/Invoke-FullRelease.ps1`. All tests must pass. If a fix changes files, restart from [P2-T1].
- [x] [P2-T4] Coverage delta verification: record to `docs/features/active/2026-06-21-full-release-missing-branch-push-221/evidence/qa-gates/coverage-delta.2026-06-21T12-06.md` the baseline coverage (from [P0-T5]), post-change coverage (from [P2-T3]), and changed-line coverage for the inserted push step. Verify line coverage >= 85%, branch coverage >= 75%, and no regression on changed lines. If any threshold is unmet, mark the plan outcome remediation-required (not PASS).
