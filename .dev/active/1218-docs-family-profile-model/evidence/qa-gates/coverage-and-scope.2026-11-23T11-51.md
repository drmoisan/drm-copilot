# Coverage and Scope Comparison (Issue #1218, P4-T3)

Timestamp: 2026-11-23T11-51
Command: compare .dev/active/1218-docs-family-profile-model/evidence/baseline/pester-gate.2026-11-23T07-26.md (latest `pester-gate.*.md`) with .dev/active/1218-docs-family-profile-model/evidence/qa-gates/final-qc-pester.2026-11-23T11-50.md (latest `final-qc-pester.*.md`); `git merge-base origin/main HEAD` after `git fetch origin main`; `git diff --name-only <merge base>` plus `git status --porcelain --untracked-files=all`, filtered for `\.(ts|tsx|js|py)$`, `^\.claude/hooks/`, `^\.codex/hooks/`, `common\.schema\.json$`, `docs-profile\.example\.json$`, `DocsProfileCommands\.psm1$`; `git diff --quiet <merge base> -- schemas/docs/v1/common.schema.json examples/docs/v1/docs-profile.example.json .claude/lib/docs/DocsProfileCommands.psm1`; `wc -l` per touched file
EXIT_CODE: 0
Output Summary:

| Comparison | Baseline (Phase 0) | Final | Result |
| --- | --- | --- | --- |
| DocsProfileFamilies.psm1 line coverage | not present (new file) | 100.00% (65/65) | PASS (threshold 85%) |
| DocsProfile.psm1 line coverage | 100.00% (82/82) | 100.00% (91/91) | PASS (no drop; the 9 added executable lines are covered) |
| DocsProfileCommands.psm1 line coverage | 97.75% (87/89) | 97.75% (87/89) | PASS (unchanged file) |
| Repo-wide PowerShell line coverage | 96.84% (47286/48827) | 96.85% (47360/48901) | PASS (no drop) |
| Pester failures | 0 of 29157 | 0 of 29234 | PASS (no new failing test) |
| pytest failures | 0 (17104 passed) | 0 (17104 passed) | PASS |

- Touched file line counts (all at most 800): DocsProfile.psm1 259; DocsProfileFamilies.psm1 202; docs-profile.schema.json 145; Claude core.json 504; DocsProfile.Tests.ps1 271; DocsProfileCommands.Tests.ps1 375; DocsValidateCommands.Tests.ps1 519; DocsValidation.Properties.Tests.ps1 171; DocsValidation.Tests.ps1 492; DocsProfileFamilies.Schema.Tests.ps1 214; DocsProfileFamilies.Tests.ps1 309; docs-authoring-roles.WorkflowText.Tests.ps1 168; .agents and .claude docs-init SKILL.md 97 each; standard.md 22. Bundle copies equal their sources.
- Scope: merge base 3d905ca0bb80f12061f6ff7d3a0d79c0c53046bf; 75 tracked paths changed since the merge base (the item's files plus the epic planning records committed on this branch before execution) and the untracked new files of this item. Forbidden-path filter matches: 0 (no TypeScript, JavaScript, Python, `.claude/hooks/`, `.codex/hooks/`, `common.schema.json`, `examples/docs/v1/docs-profile.example.json`, or `DocsProfileCommands.psm1` path).
- `git diff --quiet` of common.schema.json, the example profile, and DocsProfileCommands.psm1 against the merge base: exit 0 (unchanged).
- Every comparison passes (AC2, AC3, AC18, AC22, AC24).
