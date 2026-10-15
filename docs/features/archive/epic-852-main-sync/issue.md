# epic-852-main-sync

- Work Mode: minor-audit
- Issue: #852
- Branch: chore/epic-852-main-sync-852
- Base: epic/enforcement-hook-precision-integration
- Epic: enforcement-hook-precision

## Problem / Why

All eight child features of the enforcement-hook-precision epic are merged into `epic/enforcement-hook-precision-integration`. Before the final integration PR into `main`, `origin/main` (about 278 commits ahead) must be merged into the integration branch. The epic coordinator cannot resolve the merge conflict itself, so this child performs the sync on its own branch and lands it through a PR into the integration branch.

## Implementation Intent

Merge `origin/main` into `chore/epic-852-main-sync-852` with a merge commit, resolve conflicts by keeping both sides' intent, bring main's new feature-review coverage hook into compliance with the 786 import-guard rules, verify the hook test suites on the merged tree, and land the result through a green PR into the integration branch.

## Acceptance Criteria

- [x] 1. origin/main is merged into the branch with a merge commit (no rebase, no force-push).
- [x] 2. The only textual conflict, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, is resolved by keeping both sides' entries in sorted order. The three lines are `".claude/hooks/feature-folder-resolution.ps1",`, `".claude/hooks/feature-review-coverage-thresholds.ps1",` and `".claude/hooks/hook-command-heredoc.ps1",`. Any further conflict that appears is resolved by keeping both sides' intent and is recorded.
- [x] 3. 786's hook dependency-guard completeness test (`hook-dependency-guard-completeness.Tests.ps1`), the import-failure exemption guard and FailClosed suites, the bundle-parity tests, and the Claude and Codex hook Pester suites all pass on the merged tree. Before and after evidence is recorded.
- [x] 4. main's new hook `.claude/hooks/validate-feature-review-coverage.ps1` (with `feature-review-coverage-thresholds.ps1` and their Codex copies and bundled mirrors) satisfies 786's rules: either it carries the standard import guard, so a dependency load failure denies or blocks (SubagentStop: exit 2), or it is named as an exemption under the 786 rules with a recorded fail-closed proof (a test or cited code path showing it never allows on import failure). If it can fail open, it is converted to the uniform guard. Claude, Codex and bundle copies are parity-consistent. No Python in hooks. 500-line cap. Line coverage >= 85% on changed PowerShell files.
- [ ] 5. The PR into the integration branch is green on ALL checks (positive assertion; a non-zero check count with every check SUCCESS) and is merged.

## Dependencies / Risks

- main may move again before the PR merges; in that case origin/main is merged again (no rebase) and checks are re-run.
- Hook enforcement may block some git operations; no hook is bypassed.

## Verification Steps

- Merge commit has two parents: the integration-branch tip and the origin/main tip.
- Pester suites named in AC 3 pass on the merged tree.
- PR checks: non-zero count, all SUCCESS.

## Evidence Checklist
- [x] baseline
- [x] targeted verification
- [x] end-state
