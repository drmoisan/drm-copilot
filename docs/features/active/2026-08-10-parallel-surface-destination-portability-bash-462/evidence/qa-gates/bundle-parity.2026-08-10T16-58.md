# Dual-Home Bundle Parity — Issue #462 (AC5)

Timestamp: 2026-08-10T16-58

Task: [P7-T13]
Command:
```
git diff --name-only origin/main...HEAD -- '.claude/**'
# then, for each path P:
cmp -s "$P" "extensions/drm-copilot/resources/claude-customizations/$P"
```
EXIT_CODE: 0

Production push-down reads the bundled tree, not the repository root
(`extensions/drm-copilot/src/lib/push-down/push-down-service-call.ts:169-172`), so every changed
or new `.claude/**` path must have a byte-identical bundled counterpart or the destination
workspace receives stale content. The path set below is derived from the diff against `main`
rather than from memory, so a file changed and forgotten cannot escape the check.

## Output Summary

**16 of 16 pairs byte-identical. Zero mismatches, zero missing counterparts.**

| # | Repository path | Bundled counterpart | Result |
| --- | --- | --- | --- |
| 1 | `.claude/agents/parallel-orchestrator.md` | present | identical |
| 2 | `.claude/agents/parallel-planner.md` | present | identical |
| 3 | `.claude/lib/bash/compute-cohorts.sh` | present | identical |
| 4 | `.claude/lib/bash/compute-concurrency-batches.sh` | present | identical |
| 5 | `.claude/lib/bash/parallel-cohorts.sh` | present | identical |
| 6 | `.claude/lib/bash/parallel-common.sh` | present | identical |
| 7 | `.claude/lib/bash/parallel-items-validate.sh` | present | identical |
| 8 | `.claude/lib/bash/parallel-manifest-validate.sh` | present | identical |
| 9 | `.claude/lib/bash/parallel-yaml-emit.sh` | present | identical |
| 10 | `.claude/lib/bash/parallel-yaml-scan.sh` | present | identical |
| 11 | `.claude/lib/bash/validate-parallel-manifest.sh` | present | identical |
| 12 | `.claude/rules/shell.md` | present | identical |
| 13 | `.claude/settings.json` | present | identical |
| 14 | `.claude/skills/parallel-add/SKILL.md` | present | identical |
| 15 | `.claude/skills/parallel-orchestrate/SKILL.md` | present | identical |
| 16 | `.claude/skills/parallel-plan/SKILL.md` | present | identical |

All bundled counterparts live under
`extensions/drm-copilot/resources/claude-customizations/`.

## Standing Enforcement

This one-time check is backed by a permanent regression guard:
`tests/shell/parallel_bash_manifest_membership.bats` discovers the repository
`.claude/lib/bash/*.sh` set on every CI run and asserts, per file, both a `core.json` entry and a
byte-identical bundled counterpart via `cmp`, behind a nine-file discovery floor so a broken glob
cannot pass vacuously. It also asserts the reverse direction — no bundled-only file without a
repository counterpart. That suite ran green in the [P7-T10] dispatch as part of the 245-test bats
run.
