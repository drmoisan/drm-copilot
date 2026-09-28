# Remediation Cycle 1 - Base and Head (issue #713)

Timestamp: 2026-09-27T04-47
Command: git rev-parse HEAD
EXIT_CODE: 0
Output Summary: Branch bug/preimplementation-gate-blocks-attribution-trailers-713 at 819369cc. Code head 0ccba6b3 and base 2d9bb87c are both ancestors (exit 0). Since the code head only the remediation inputs and plan changed; the tree differs only inside the feature folder. The base numstat shows 16/16 for each helpers copy, 99/0 for the test file, and 11/0 for each of the four skill documents; every other path is in the feature folder.

BRANCH: bug/preimplementation-gate-blocks-attribution-trailers-713
HEAD_SHA: 819369ccef370a195b3c39a966f1ab0c8d565ef7
CODE_HEAD_ANCESTOR_EXIT: 0 (`git merge-base --is-ancestor 0ccba6b3edc38128abc567ab9ab92963cb2857ad HEAD`)
BASE_SHA: 2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d
BASE_ANCESTOR_EXIT: 0 (`git merge-base --is-ancestor 2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d HEAD`)

## `git rev-parse --abbrev-ref HEAD` (EXIT_CODE 0)

```text
bug/preimplementation-gate-blocks-attribution-trailers-713
```

## `git diff --name-only 0ccba6b3edc38128abc567ab9ab92963cb2857ad HEAD` (EXIT_CODE 0)

```text
docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/remediation-inputs.2026-09-27T05-05.md
docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/remediation-plan.2026-09-27T05-05.md
```

## Porcelain: `git status --porcelain` (EXIT_CODE 0)

```text
 M docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/remediation-plan.2026-09-27T05-05.md
?? docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/evidence/remediation-baseline/
```

## `git diff --numstat 2d9bb87c9bcc187336c2547b17f152e6b5a6bf0d HEAD` (EXIT_CODE 0)

Non-feature-folder rows (verbatim):

```text
16	16	.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
11	0	.claude/skills/epic-plan/SKILL.md
11	0	.claude/skills/parallel-plan/SKILL.md
16	16	.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
16	16	extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
11	0	extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-plan/SKILL.md
11	0	extensions/drm-copilot/resources/claude-customizations/.claude/skills/parallel-plan/SKILL.md
16	16	extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1
99	0	tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate.AttributionTrailer.Tests.ps1
```

Feature-folder rows (verbatim; every path begins `docs/features/active/preimplementation-gate-blocks-attribution-trailers-713/`, abbreviated here as `FEATURE/`):

```text
145	0	FEATURE/code-review.2026-09-27T04-30.md
35	0	FEATURE/evidence/baseline/p0-base-ref.md
25	0	FEATURE/evidence/baseline/p0-baseline-summary.md
33	0	FEATURE/evidence/baseline/p0-execution-route.md
27	0	FEATURE/evidence/baseline/p0-feature-documents-read.md
33	0	FEATURE/evidence/baseline/p0-git-trailer-support.md
71	0	FEATURE/evidence/baseline/p0-helpers-detection.md
69	0	FEATURE/evidence/baseline/p0-pester-full.md
13	0	FEATURE/evidence/baseline/p0-poshqc-analyze.md
34	0	FEATURE/evidence/baseline/p0-poshqc-format.md
26	0	FEATURE/evidence/baseline/p0-pytest-push-down.md
31	0	FEATURE/evidence/baseline/p0-reference-search.md
45	0	FEATURE/evidence/baseline/p0-scoped-coverage.md
65	0	FEATURE/evidence/baseline/p0-skill-detection.md
35	0	FEATURE/evidence/baseline/phase0-instructions-read.md
19	0	FEATURE/evidence/other/ac-checkoff.md
13	0	FEATURE/evidence/other/ac-status-summary.md
12	0	FEATURE/evidence/other/ac6-ci-clause-check-off.md
26	0	FEATURE/evidence/other/batch-log.md
80	0	FEATURE/evidence/other/commit-handoff.md
14	0	FEATURE/evidence/other/commits-log.md
27	0	FEATURE/evidence/other/execution-deviations.md
23	0	FEATURE/evidence/other/follow-ups.md
47	0	FEATURE/evidence/other/mirror-log.md
12	0	FEATURE/evidence/other/test-file-created.md
21	0	FEATURE/evidence/qa-gates/batch1-existing-suites.md
167	0	FEATURE/evidence/qa-gates/canonical-edit-checks.md
46	0	FEATURE/evidence/qa-gates/documentation-tokens.md
14	0	FEATURE/evidence/qa-gates/final-coverage-delta.md
48	0	FEATURE/evidence/qa-gates/final-pester-full.md
16	0	FEATURE/evidence/qa-gates/final-poshqc-analyze.md
41	0	FEATURE/evidence/qa-gates/final-poshqc-format.md
36	0	FEATURE/evidence/qa-gates/final-preloop-state.md
40	0	FEATURE/evidence/qa-gates/final-pytest-push-down.md
35	0	FEATURE/evidence/qa-gates/final-scoped-coverage.md
19	0	FEATURE/evidence/qa-gates/final-seven-stage-loop.md
56	0	FEATURE/evidence/qa-gates/mirror-parity-sha256.md
60	0	FEATURE/evidence/qa-gates/parity-and-legacy-contracts.md
102	0	FEATURE/evidence/qa-gates/scope-boundary.md
12	0	FEATURE/evidence/qa-gates/test-file-format-stability.md
32	0	FEATURE/evidence/qa-gates/test-portability-inspection.md
88	0	FEATURE/evidence/regression-testing/fail-before-attribution-trailer.md
20	0	FEATURE/evidence/regression-testing/fail-before-exception.2026-09-27T03-34.md
83	0	FEATURE/evidence/regression-testing/pass-after-attribution-trailer.md
101	0	FEATURE/feature-audit.2026-09-27T04-30.md
48	0	FEATURE/issue.md
364	0	FEATURE/plan.2026-09-27T00-23.md
503	0	FEATURE/policy-audit.2026-09-27T04-30.md
42	0	FEATURE/remediation-inputs.2026-09-27T05-05.md
221	0	FEATURE/remediation-plan.2026-09-27T05-05.md
323	0	FEATURE/research/research.2026-09-27T00-30.md
433	0	FEATURE/spec.md
```

Acceptance: BRANCH matches; both ancestor exits 0; name-only and porcelain paths all begin with the feature folder; numstat matches the expected 16/16, 99/0, and 11/0 rows with all other paths in the feature folder. PASS.
