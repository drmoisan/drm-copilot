# Remediation Inputs (Issue #952) - cycle 2

Review-Verdict: REMEDIATION_REQUIRED

**Entry timestamp:** 2026-10-16T17-18
**Feature folder:** `docs/features/active/2026-10-16-ci-merge-queue-for-main-952`
**Base branch:** `main` (merge base `d72ec6a1010223f7036b9c3d15dad102ae262f98`)
**Head audited:** `bug/ci-merge-queue-for-main-952` @ `5c1e795a54031a8247cd8a324668de3fb089b84c`
**Work mode:** `full-bug`; AC source is `spec.md` only
**Review pass:** re-audit after remediation cycle 1
**Blocking finding count:** 3 (R1 class autonomous; R2 class autonomous; R3 class awaiting_ci)

## Audit Artifacts

- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/policy-audit.2026-10-16T17-18.md` (Section 8: PA-1 and PA-2 FAIL, PA-3 UNVERIFIED; PA-N1, PA-N2 non-blocking)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/code-review.2026-10-16T17-18.md` (Findings Table: CR-1 and CR-12 Blocker; CR-13 Minor; CR-10, CR-11, CR-14 Info)
- `docs/features/active/2026-10-16-ci-merge-queue-for-main-952/feature-audit.2026-10-16T17-18.md` (13 PASS, 0 PARTIAL, 14 UNVERIFIED, 1 FAIL (AC-27))

## Trigger Justification

Remediation is triggered under `.claude/skills/feature-review-workflow/SKILL.md` step 8: (a) coverage below the governing thresholds for a new file (`.codex/hooks/enforce-epic-merge-gate-command.ps1` 74.07% on R_final_2 38933561015); (b) a correctness defect in the merged scope (the #927 docs-only exemption accepts a cross-repository URL selector after #952 made URL selectors resolve). Format, lint, tests on Windows and Linux, mirrors, line counts, scope boundary, evidence locations, and Python coverage pass.

## Workflow Green-Run Evidence (`modified-workflow-needs-green-run`)

- Workflow: `.github/workflows/ci.yml` (modified by this branch).
- Run: R_final_2 38933561015, event `workflow_dispatch`, head `fd1913a0d1d555959edca41289fc38ace1c5d439`, conclusion `success`, 17/17 jobs success (reviewer `gh run view`; `evidence/qa-gates/ci-rows-windows.2026-10-16T17-08.md`).
- `git diff --stat fd1913a0d HEAD` lists four evidence files only. The cycle-2 changes are outside the feature folder and invalidate this evidence; the repeat dispatch in R1 step 5 replaces it.

## Findings

### R1 - New-file PowerShell coverage below 85% for the Codex helper (PA-1, CR-1)

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The remedy is a local diagnostic Pester run, a text or test-setup change inside this repository, and a CI dispatch the orchestrator already performs; no external system, policy change, or human decision is involved.

**Problem.** `.codex/hooks/enforce-epic-merge-gate-command.ps1` is at 74.07% (40/54) on R_final_2; uncovered lines 67, 68, 72, 165, 166, 171, 172, 179, 182-186, 189. The covered set equals the cycle-0 set renumbered. Row (g) proves the functions are defined by the Codex file; row (j) calls `ConvertFrom-EpicMergeGateSelector` with a URL in-process and passes, yet lines 67-68 are uncovered. The byte-identical Claude copy is at 100.00%. The ORCH-R3 hypothesis (hits credited to the first-loaded byte-identical Claude copy) is contradicted in its general form by the same report: `hook-docs-only-diff.ps1`, byte-identical in both runtimes (blob `7e429ae6c` at `fd1913a0d`), has Claude missed {189, 314, 358} and Codex missed {189, 217, 314}. The credited Codex suites (`-trigger-scoping`, `-authorization`, `-decision-surface`, `-docs-only`) dot-source the gate from `Join-Path $script:RepoRoot`; the uncredited ones (`-merge-queue`, `-command`) use `Resolve-Path` and the command suite also dot-sources the helper a second time. The mechanism is not established.

**Required change.**

1. Diagnose locally before any CI dispatch. In the main session, through the PowerShell tool (not the PoshQC MCP runner, whose results carry no output), run `Invoke-Pester` with a scratch configuration: `CodeCoverage.Enabled = $true`, `CodeCoverage.Path` = the two helper files, `CodeCoverage.OutputPath` and `TestResult.OutputPath` under the session scratchpad, default `UseBreakpoints`. Run A: `Run.Path` = `tests/scripts/codex-hooks/enforce-epic-merge-gate-command.Tests.ps1` only. Run B: `tests/scripts/claude-hooks/enforce-epic-merge-gate.MergeQueue.Tests.ps1` then the same Codex suite. Run C: the six Codex merge-gate suites only. Parse the Codex helper's covered lines from each output. Write `evidence/regression-testing/codex-helper-coverage-local.<timestamp>.md` with `Timestamp`, `Command`, `EXIT_CODE`, `Output Summary`, and the three covered-line sets. Do not commit the scratch configuration or outputs.
2. Select the remedy from the result:
   - Run A credits lines 67-68 and 165-189 and run B does not: cross-file interaction. Make the Codex helper's text differ from the Claude helper's (a Codex-specific sentence in the `.DESCRIPTION` block) while keeping every executable statement identical; keep each helper byte-identical to its own bundle mirror; apply CR-13.
   - Run A does not credit them: the loss is in the suites' load sequence. Change `enforce-epic-merge-gate-command.Tests.ps1` and `enforce-epic-merge-gate-merge-queue.Tests.ps1` to load the gate with the form the credited Codex suites use and to stop dot-sourcing the helper a second time; keep the row (g) provenance assertion. Re-run A and C.
   - Neither variant changes run A: record the result and apply both changes, then re-run A to C; if the Codex helper still does not reach 85% locally, stop and report the per-line data as cycle-3 input rather than dispatching CI.
3. Confirm locally with run C plus the Claude merge-gate suites that the Codex helper is >= 85% line coverage. Record the figure in the same evidence file.
4. Do not add coverage exclusions, lower thresholds, rename functions in one copy only, or edit `pester.runsettings.psd1`, `config/poshqc-coverage.json`, the PoshQC module, or `.github/workflows/_poshqc.yml`.
5. Run the PowerShell toolchain loop on the touched files, dispatch `ci.yml` on the branch head together with R2, and repeat ORCH-R1, ORCH-R2, and ORCH-R3. ORCH-R3 must report the Codex helper at >= 85% line and changed-line coverage, record the repository-wide PowerShell figure, and record the step 1 result and the `hook-docs-only-diff.ps1` observation in its cause statement (CR-14).

**Verification commands.**

```bash
# main session, PowerShell tool, worktree root (scratch configuration; nothing committed)
#   Invoke-Pester -Configuration <scratch config> for runs A, B, C; parse <scratch>/coverage.xml
gh workflow run ci.yml --ref bug/ci-merge-queue-for-main-952
gh run watch <run-id> --exit-status
gh run download <run-id> -n poshqc-test-results -D <scratch>/issue-952-ci-<run-id>/win
poetry run python scripts/dev_tools/validate_evidence_locations.py --root .
# Expect: local run >= 85.00 for the Codex helper before dispatch; CI conclusion success; ORCH-R3 PASS
```

### R2 - Docs-only exemption accepts a cross-repository URL selector (PA-2, CR-12)

Severity: Blocking
Remediability: autonomous
Remediability-Evidence: The fix is one additional M1 shape rule in a repository hook file and its three byte-identical copies plus tests on both runtimes; no external system, policy document, or human decision is involved.

**Problem.** Since #952, `ConvertFrom-EpicMergeGateSelector` resolves `gh pr merge https://github.com/<other-owner>/<other-repo>/pull/5 --merge` to 5. When no checkpoint records 5, both gates call `Get-DocsOnlyMergeExemption` (Claude gate `:389-395`, Codex gate `:177-181`). M1 (`hook-docs-only-diff.ps1:353-375`) rejects `-R`, `--repo`, and `VAR=` repository overrides but not a URL selector, and M3 runs `gh pr view 5` in the session repository (`:403`). A docs-only local PR 5 therefore allows a command that merges PR 5 of another repository. On `main` a URL selector yields `$null` and the docs-only branch is not reached. No DocsOnly suite contains a URL case.

**Required change.**

1. In `Get-DocsOnlyMergeShapeViolation`, reject any token of the single segment that contains `/pull/` with a `DOCS_ONLY_EXEMPTION_PR_UNRESOLVED:` reason naming the token as a URL selector that is not accepted, and add the rule to the M1 text in the file header. Apply the change byte-identically to `.claude/hooks/hook-docs-only-diff.ps1`, `.codex/hooks/hook-docs-only-diff.ps1`, and both bundle mirrors (the H11 / #927 four-copy parity test enforces identity).
2. Add tests: an M1 row in `tests/scripts/claude-hooks/hook-docs-only-diff.Tests.ps1` for `gh pr merge https://github.com/o/r/pull/5 --merge` expecting the new reason; one case in `tests/scripts/claude-hooks/enforce-epic-merge-gate.DocsOnly.Tests.ps1` and one in `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` with no recording target, expecting deny with the `(docs-only exemption not applied: DOCS_ONLY_EXEMPTION_PR_UNRESOLVED` suffix and asserting that the `gh pr view` seam is not called. Keep every file under 500 lines.
3. Update the ORCH-R1 and ORCH-R2 Passed-count expectations for the three touched suites (new counts = current counts plus the added rows) before the dispatch.
4. Run the PowerShell toolchain loop on the touched files; the CI dispatch is shared with R1 step 5.

### R3 - AC-28 pending the `pull_request` CI run on the final PR head (PA-3)

Severity: Blocking
Remediability: awaiting_ci
Remediability-Evidence: AC-28 is verified only by the pull_request run of ci.yml on the final PR head, which cannot exist before the PR is opened; it is resolved at S9 and needs no code change.

**Problem.** No PR exists for the branch, so the `pull_request` run required by AC-28 has not occurred.

**Required change.** None in code. After R1 and R2 complete and the PR is opened, the item's own orchestrator run checks off AC-28 at S9 once `ci_gate.conclusion == "success"` with `ci_gate.head_sha` equal to the final PR head.

## In-Item Non-blocking Findings (fix in the same cycle)

| ID | Severity | File | Required change |
|---|---|---|---|
| CR-13 (PA-N1) | Minor | Helper `.DESCRIPTION` lines 5-6 (four copies); `.codex/hooks/enforce-epic-merge-gate.ps1:33-34,73-74` and mirror; `tests/scripts/codex-hooks/enforce-epic-merge-gate-merge-queue.Tests.ps1:69` | If R1 differentiates the Codex helper, reword these comments to state that the two helpers carry the same executable statements and each is mirrored byte-identically. Otherwise no change. |
| CR-14 (PA-N2) | Info | Next coverage-comparison artifact | Record the R1 step 1 result and the `hook-docs-only-diff.ps1` counter-observation in the cause statement. |

## Do Not Do

- Do not edit policy documents under `.claude/rules/` or `.github/instructions/`.
- Do not apply, PUT, or otherwise change ruleset 15241672.
- Do not edit `.github/workflows/_poshqc.yml`, `.claude/hooks/hook-command-invocation.ps1`, the PoshQC module, or its settings.
- Do not add coverage exclusions or lower thresholds.
- Do not check off AC-1, AC-2, AC-5 to AC-15, AC-27, or AC-28 from the executor.
- Do not let any `.claude/`, `.codex/`, `.agents/` file and its bundle mirror diverge, and do not let the four `hook-docs-only-diff.ps1` copies diverge.
- Do not dispatch CI for R1 before the local run confirms the Codex helper at >= 85%.

## Exit Gate

Re-audit (policy-audit, code-review, feature-audit) with zero autonomous blocking findings: one new dispatched `ci.yml` run on the branch head concludes `success`; ORCH-R1 and ORCH-R2 pass on it with the updated DocsOnly counts; ORCH-R3 reports every new and modified PowerShell production file at >= 85% line and changed-line coverage, including `.codex/hooks/enforce-epic-merge-gate-command.ps1`, with the repository-wide PowerShell figure recorded; the URL-selector rows pass on both runtimes. AC-28 remains pending CI until S9.
