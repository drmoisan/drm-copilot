# Remediation Inputs: #565 feature review, pass 1

Timestamp: 2026-10-08T19-24
Branch: `bug/epic-wave-barrier-resolves-nested-artifact-as-feature-folder-exec-565` @ `2aa326cc`
Base: `origin/epic/enforcement-hook-precision-integration` (merge-base `991aae0a`)
Verdict: REMEDIATION_REQUIRED (1 blocking finding, `autonomous`)

## Source Artifacts

- `docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/policy-audit.2026-10-08T19-24.md` (0 blocking)
- `docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/code-review.2026-10-08T19-24.md` (1 blocking: CR-1)
- `docs/features/active/2026-08-26-epic-wave-barrier-resolves-nested-artifact-as-feature-folder-565/feature-audit.2026-10-08T19-24.md` (0 blocking; AC item 30 awaiting PR CI)
- `artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt` (generated 2026-10-08 23:25:24 UTC, head `2aa326cc`)

## Remediation-Required Findings

### R1 (from CR-1) - `-modes.ps1` tie-break accepts a positional bare `#<n>`

- Remediability: autonomous
- Severity: Major (blocking)
- Files:
  - `.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
  - `.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
  - Bundled mirrors: `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-modes.ps1`
  - Tests: `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1`, `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.TargetFolder.Tests.ps1`
- Current behavior: `Get-EpicOrchestrationReadinessFailure` and `Get-ParallelOrchestrationReadinessFailure` pass `$IssueNumber` to `Select-FeatureFolderTarget -DeclaredIssueNumber`. `$IssueNumber` comes from `Find-OrchestrationDelegationIssueNumber`, which returns the keyed `issue_num:` / `issue number:` form or, failing that, the first bare `#<n>` anywhere in the prompt. A bare `#<n>` naming a cited non-target item therefore selects that item and the predicates evaluate its `merge_status`.
- Expected behavior (spec R4, R6, and Technical specifications "Declared issue number"): only the keyed form acts as the declared-issue tie-break among several remaining candidates. The bare hash form may continue to serve the decision-D3 fallback when no candidate is cited (zero-candidate path through `Find-OrchestrationModeRecord`). Prompt position takes no part in selection among cited candidates.
- Reproduction (probe run by the review): parallel checkpoint items `target-a-with-a-much-longer-slug-301` (`merge_status: merged`) and `b-302` (`not_started`); prompt `Parallel mode: true. Coordinate with #302. Execute docs/features/active/target-a-with-a-much-longer-slug-301 with context from docs/features/active/b-302 now.` Current result: `Get-ParallelOrchestrationReadinessFailure` returns `''` (allow). Expected: `target-ambiguous: target-a-with-a-much-longer-slug-301, b-302`.
- Required changes:
  1. Provide a keyed-only issue-number source for the tie-break (for example a `-KeyedOnly` switch on `Find-OrchestrationDelegationIssueNumber`, or pass the keyed value separately from the D3 fallback value), applied symmetrically on both surfaces so the pre-existing Claude/Codex asymmetry is not widened.
  2. Keep the D3 fallback behavior unchanged for zero candidates (M6a, M8 must still pass).
  3. Add one case per surface (parallel and epic legs): two cited non-dependency records, target terminal, sibling non-terminal, bare `#<sibling>` in the prompt, no keyed line, expected `target-ambiguous`. Add one case per surface where a keyed `issue_num: <target>` resolves the pair.
  4. Copy both changed hooks to their bundled mirrors; SHA256 must match.
  5. Stay under 500 lines (Claude `-modes.ps1` is at 489, Codex at 486).
- Verification commands:
  - `Invoke-Pester` on both `...-mode-resolution.TargetFolder.Tests.ps1` suites and the existing preimplementation-gate suites on both surfaces.
  - PoshQC format, analyze (Findings=0), and the full self-hosted `Invoke-PoshQCTest`; failing set must equal `evidence/baseline/junit-failing-set.2026-10-08T17-53.md`.
  - Per-file line coverage >= 85% for both `-modes.ps1` files from `artifacts/pester/powershell-coverage.xml`; no previously covered changed line uncovered.
  - `sha256sum` on the two hook/mirror pairs.

## Non-Blocking Items (record or file; do not expand scope without approval)

- CR-2: extend the R1 trim set to `)`, `]`, `>`, `*`, `_` (requires a spec amendment to R1); candidate for a follow-up issue.
- CR-3: `Find-OrchestrationModeRecord` was not converted to a delegate as the spec "Callers" section states; either delegate or record the deviation.
- CR-4: reword the barrier import-failure deny reason so the resolver is not called a worktree-resolution module.
- PA-2: estimated evidence timestamps (Phase 1 to Phase 10 iteration 2); keep `evidence/other/timestamp-correction.2026-10-08T18-46.md` referenced in the PR description. All new remediation evidence must use clock-read timestamps.
- PA-3: `evidence/qa-gates/analyze-selfhosted.1.2026-10-08T19-50.md` renders as a `fail` row in the PR context; move superseded iteration artifacts out of `qa-gates/` or mark them superseded.
- AC item 30 (`awaiting_ci`): confirm the seven contract suites in CI on the pull request.

## Do Not Do

- Do not modify policy documents under `.claude/rules/` or `.github/instructions/`.
- Do not change the shared resolver's public API or the cohort/drift/wave-barrier behavior as part of R1.
- Do not weaken or delete existing assertions; do not mark any test skipped.
- Do not add Python to any hook; do not use temporary files in tests.
- Do not write evidence outside `<FEATURE>/evidence/<kind>/`.
- Do not check off spec AC item 30 before CI evidence exists.
