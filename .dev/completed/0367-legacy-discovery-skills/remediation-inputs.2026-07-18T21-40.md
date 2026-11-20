# Remediation Inputs — Cycle 1 (Issue #367)

- Timestamp: 2026-07-18T21-40
- Entry trigger: failed required CI check on PR #381
- Failing check name: Extension Tests (ubuntu-latest)
- Failing job URL: https://github.com/drmoisan/drm-copilot/actions/runs/29668775639/job/88143911467
- PR head SHA at failure: bff412d1b91864662fcbd142ca743b2ff5a58ba3

## Finding (Blocking)

The jest suite `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts`
asserts that every bundled `.claude` skill/agent/hook file is listed in at least one
`pack-manifests/*.json` `paths` array. The seven new bundled discovery skills are absent
from every pack manifest, so `missing` is non-empty and the test fails:

```
FAIL test/lib/push-down/claude-pack-manifest-completeness.test.ts
  expect(missing).toEqual([])
  + ".claude/skills/discovery-behavior-reconciliation/SKILL.md"
  + ".claude/skills/discovery-coverage-ledger/SKILL.md"
  + ".claude/skills/discovery-parity-matrix/SKILL.md"
  + ".claude/skills/discovery-repo-inventory/SKILL.md"
  + ".claude/skills/discovery-runtime-characterization/SKILL.md"
  + ".claude/skills/discovery-validate-artifacts/SKILL.md"
  + ".claude/skills/discovery-workflow/SKILL.md"
Tests: 1 failed, 1885 passed, 1886 total
```

Why the local toolchain missed it: the completeness check is a TypeScript/jest extension
test executed only in CI (`Extension Tests` workflow). The feature plan scoped the Python
toolchain and the Python push-down parity gate
(`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py`), which verifies
`.claude/**` -> `resources/.../.claude/**` byte-parity but does NOT verify pack-manifest
registration. Both checks are required; only the Python one was in local scope.

## Required Remediation

Register the seven new bundled discovery skills in the domain-neutral foundational pack
manifest `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`,
inserted in the existing alphabetical order of the `paths` array (after
`.claude/skills/commit-message/SKILL.md`, before `.claude/skills/epic-orchestrate/SKILL.md`):

- `.claude/skills/discovery-behavior-reconciliation/SKILL.md`
- `.claude/skills/discovery-coverage-ledger/SKILL.md`
- `.claude/skills/discovery-parity-matrix/SKILL.md`
- `.claude/skills/discovery-repo-inventory/SKILL.md`
- `.claude/skills/discovery-runtime-characterization/SKILL.md`
- `.claude/skills/discovery-validate-artifacts/SKILL.md`
- `.claude/skills/discovery-workflow/SKILL.md`

No `.claude`-side source changes are required; the skills and their byte-identical bundle
copies already exist. Only pack-manifest registration is missing.

## Exit Gate

Cycle 1 exit requires: the pack-manifest completeness jest suite passes, the Python
push-down parity gate remains green, and the three reaudit artifacts report
blocking_count == 0.
