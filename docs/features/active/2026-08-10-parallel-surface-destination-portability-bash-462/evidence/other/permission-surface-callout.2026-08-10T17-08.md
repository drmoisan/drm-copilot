# Permission-Surface Callout for the Pull Request — Issue #462

Timestamp: 2026-08-10T17-08

Task: [P6-T9]
Purpose: supply the exact PR-description text that identifies this feature's deliberate
permission-surface change, satisfying acceptance criterion AC15. The PR author includes the
block below verbatim.

---

## Permission-surface change (deliberate)

This change adds one new Bash allowlist pattern in three places:

```
Bash(bash .claude/lib/bash/*)
```

| File | Where |
| --- | --- |
| `.claude/agents/parallel-planner.md` | `tools:` frontmatter list |
| `.claude/agents/parallel-orchestrator.md` | `tools:` frontmatter list |
| `.claude/settings.json` | `permissions.allow` list |

Each is mirrored byte-identically into
`extensions/drm-copilot/resources/claude-customizations/`, so the destination payload carries
the same grant.

**Why the grant is needed.** The parallel surface's cohort computation, concurrency batching,
and manifest validation previously ran only as `poetry run` Python invocations. A workspace
that received the Claude customization payload has no repository checkout and no Python
interpreter, so those steps were unreachable. This change publishes bash ports of all three as
executable entry points under `.claude/lib/bash/`, and the two parallel agents need permission
to run them.

**Why the pattern is narrow.** The glob matches only `bash` invoked against a file directly
under `.claude/lib/bash/`. It does not grant `bash` generally, does not match a nested
subdirectory, and does not match any path outside that one directory. The directory contains
exactly nine files, all authored in this change and all covered by shellcheck, shfmt, bats, and
kcov in CI:

- `compute-cohorts.sh`, `compute-concurrency-batches.sh`, `validate-parallel-manifest.sh`
  (the three command-line entry points)
- `parallel-common.sh`, `parallel-cohorts.sh`, `parallel-items-validate.sh`,
  `parallel-manifest-validate.sh`, `parallel-yaml-scan.sh`, `parallel-yaml-emit.sh`
  (sourceable libraries, not invoked directly)

**What was not widened.** No existing allowlist entry was broadened. The
`Bash(poetry run *)` entry on `parallel-planner.md` and the two narrower
`Bash(poetry run python -c *)` / `Bash(poetry run python -m *)` entries on
`parallel-orchestrator.md` are unchanged; they remain for the repository-local paths that still
need an interpreter (the checkpoint-validator CLI fallback, the drift-detection CLI, and the
mutation-abandon CLI), which are explicit non-goals of this change.
