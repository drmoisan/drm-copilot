# Remediation Inputs — Cycle 3 (#363)

- Timestamp: 2026-07-18T17-05
- Feature: 2026-07-17-legacy-discovery-analyzer-framework-363 (issue #363)
- PR: https://github.com/drmoisan/drm-copilot/pull/378
- Base branch: epic/legacy-discovery-and-parity-integration
- Head branch: feature/legacy-discovery-analyzer-framework-363 (head 3d2544ec)
- Trigger: Failed required CI check (S9 step 6 CI-failure handling). This is remediation pass 3 of the shared cap of 3.

## Synthetic Blocking Finding (from failed required check)

- Severity: Blocking
- Failing checks:
  - Extension Tests (ubuntu-latest) — https://github.com/drmoisan/drm-copilot/actions/runs/29652993218/job/88102402132
  - Extension Tests (windows-latest) — https://github.com/drmoisan/drm-copilot/actions/runs/29652993218/job/88102402141
- Failing test: extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts ("lists every bundled .claude agent, skill, and hook file in some pack manifest"), assertion `expect(missing).toEqual([])` at line 137.
- CI result: Tests 1 failed, 1885 passed.

### Root cause

The cycle-2 fix mirrored four #365 agent persona files into the bundle on disk (extensions/drm-copilot/resources/claude-customizations/.claude/agents/), but did not register them in any pack manifest. The completeness test enumerates on-disk bundled .claude agent/skill/hook files and requires each to appear in some pack-manifests/*.json `paths` array. The four files are on disk but absent from every manifest, so `missing` is non-empty.

This TypeScript/vitest test runs only in CI (Extension Tests), not in the local Python pytest suite, so cycle-2 local QC could not have caught it. It is the completing half of the same #365 bundle-drift defect: the bundle contract requires BOTH the byte-identical mirror (Python test, fixed in cycle 2) AND manifest registration (this TS test).

### Files on disk in the bundle but missing from every manifest

- `.claude/agents/legacy-parity-analyst.md`
- `.claude/agents/migration-coverage-reviewer.md`
- `.claude/agents/requirements-reconciler.md`
- `.claude/agents/runtime-characterization-analyst.md`

### Required resolution

Register the four agent paths in the core pack manifest `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (the manifest that already lists the domain-neutral base agents such as `.claude/agents/orchestrator.md`). Insert them into the existing agents section of the `paths` array preserving the existing alphabetical ordering:
- `.claude/agents/legacy-parity-analyst.md` and `.claude/agents/migration-coverage-reviewer.md` between `human-exception-runbook.md` and `orchestrator.md`
- `.claude/agents/requirements-reconciler.md` and `.claude/agents/runtime-characterization-analyst.md` between `prd-feature.md` and `staged-review.md`
Keep valid JSON (formatting/trailing-comma rules per the file). Do not modify the repo `.claude/agents/*.md` source files or the mirrored bundle files.

### Verification (must all pass locally before push)

- The full extension test suite (the runner used by CI's "Extension Tests" job in extensions/drm-copilot) passes, including claude-pack-manifest-completeness.test.ts. Run it locally and record evidence.
- The full Python QC loop (Black -> Ruff -> Pyright -> Pytest with coverage) remains green with coverage thresholds intact (line >= 85%, branch >= 75%, no regression).
- Scope-boundary: if any OTHER bundled file is missing from every manifest, or any parallel manifest-completeness contract (e.g. codex-and-agents-customizations) fails, register those too and record each. If a non-manifest, non-bundle blocking issue appears, STOP and report it as a further finding.

### Exit condition

- claude-pack-manifest-completeness.test.ts passes; the full extension test suite passes locally.
- Full Python QC loop green with coverage intact.
- Branch pushed; PR #378 required CI checks (Extension Tests ubuntu-latest and windows-latest) conclude success against the live head SHA.
- Reaudit (code-review, feature-audit, policy-audit) reports zero blocking findings.
