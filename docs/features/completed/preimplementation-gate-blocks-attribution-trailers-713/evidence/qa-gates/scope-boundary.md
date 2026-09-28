# P4-T1 Scope Boundary (AC7)

Timestamp: 2026-09-27T03-42
Command: git diff --numstat 2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d
EXIT_CODE: 0
Output Summary: Against BASE_SHA, the four helpers copies each read 16/16, the four skill documents each read 11/0, the new test file reads 99/0, and every other path lies under the feature folder. Neither gate file (`.claude/hooks/enforce-orchestration-preimplementation-gate.ps1`, `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1`) appears. Ancestry checks pass under deviation X1.

Other commands (each EXIT_CODE 0):

- `git merge-base --is-ancestor 2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d HEAD`
- `git merge-base --is-ancestor 6747ee7729939467b2181b99a9893599de7ade55 HEAD` (X1)
- `git rev-parse HEAD`
- `git log --format=%h%x20%s 6747ee7729939467b2181b99a9893599de7ade55..HEAD` (X1)
- `git status --porcelain`
- `git diff --name-status 2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d HEAD -- .claude extensions .codex tests` (X1 porcelain companion)

BASE_ANCESTOR_EXIT: 0
HEAD_ANCESTOR_EXIT: 0
HEAD_NOW: a3d02f874c1b1b396921442ccc41f3fa4744decb

## Deviation X1 readings

- HEAD condition: `HEAD_SHA` (6747ee7729939467b2181b99a9893599de7ade55) is an ancestor of HEAD, and every commit in `HEAD_SHA..HEAD` is a phase-boundary commit recorded in `evidence/other/commits-log.md`:

  ```text
  a3d02f87 docs(skills): document attribution-trailer commit forms for issue #713
  eef16acb fix(hooks): admit attribution trailers in the preimplementation gate
  911359bc test(hooks): add attribution-trailer regression suite for issue #713
  8f621b60 docs(evidence): record phase 0 baseline for issue #713
  ```

- Numstat: the plan expected the new test file to be untracked and therefore absent from this numstat. Because X1 committed it at the Phase 1 boundary, it appears as `99	0` for `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1`, which is section 2 item 5. No other non-feature path appears beyond section 2 items 1 to 4 and 6 to 9.
- Porcelain: the eight modified code paths and the new test file were committed at phase boundaries, so they no longer appear in `git status --porcelain`. Each appears in `git diff --name-status BASE_SHA HEAD` (listing below): items 1 to 4 and 6 to 9 as `M`, and the test file as `A`. The porcelain output lists only a feature-folder path.

## Numstat output

```text
16	16	.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
11	0	.claude/skills/epic-plan/SKILL.md
11	0	.claude/skills/parallel-plan/SKILL.md
16	16	.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
35	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/baseline/p0-base-ref.md
25	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/baseline/p0-baseline-summary.md
33	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/baseline/p0-execution-route.md
27	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/baseline/p0-feature-documents-read.md
33	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/baseline/p0-git-trailer-support.md
71	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/baseline/p0-helpers-detection.md
69	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/baseline/p0-pester-full.md
13	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/baseline/p0-poshqc-analyze.md
34	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/baseline/p0-poshqc-format.md
26	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/baseline/p0-pytest-push-down.md
31	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/baseline/p0-reference-search.md
45	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/baseline/p0-scoped-coverage.md
65	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/baseline/p0-skill-detection.md
35	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/baseline/phase0-instructions-read.md
26	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/other/batch-log.md
12	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/other/commits-log.md
27	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/other/execution-deviations.md
47	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/other/mirror-log.md
12	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/other/test-file-created.md
21	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/qa-gates/batch1-existing-suites.md
167	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/qa-gates/canonical-edit-checks.md
46	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/qa-gates/documentation-tokens.md
56	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/qa-gates/mirror-parity-sha256.md
60	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/qa-gates/parity-and-legacy-contracts.md
12	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/qa-gates/test-file-format-stability.md
32	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/qa-gates/test-portability-inspection.md
88	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/regression-testing/fail-before-attribution-trailer.md
20	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/regression-testing/fail-before-exception.2026-09-27T03-34.md
83	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/regression-testing/pass-after-attribution-trailer.md
48	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/issue.md
364	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/plan.2026-09-27T00-23.md
323	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/research/research.2026-09-27T00-30.md
433	0	docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/spec.md
16	16	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
11	0	extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-plan/SKILL.md
11	0	extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md
16	16	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
99	0	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1
```

## Porcelain output

```text
 M docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/other/commits-log.md
```

## Name-status companion (committed code paths since BASE_SHA)

```text
M	.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
M	.claude/skills/epic-plan/SKILL.md
M	.claude/skills/parallel-plan/SKILL.md
M	.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
M	extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-plan/SKILL.md
M	extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md
M	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
A	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1
```

Together with [P2-T2], this shows that `Split-OrchestrationCommandLine` and both gate files are unmodified.
