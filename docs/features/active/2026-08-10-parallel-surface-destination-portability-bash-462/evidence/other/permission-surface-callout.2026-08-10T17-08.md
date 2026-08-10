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

**Scope of the pattern, stated precisely.** The entry does not grant `bash` generally: an
invocation must begin `bash .claude/lib/bash/`. It is, however, a **prefix wildcard**, not a
single-directory glob. The trailing `*` matches across `/`, so it also matches a nested
subdirectory (`.claude/lib/bash/sub/x.sh`) and a relative-traversal path that begins with the
prefix (`.claude/lib/bash/../../../x.sh`). Neither case exists in the repository today — the
directory contains exactly the nine files listed below and no subdirectory — but a reviewer
should read the grant as "any `bash` invocation whose first argument starts with
`.claude/lib/bash/`", not as "only the nine files below".

An earlier revision of this callout claimed the pattern "does not match a nested subdirectory,
and does not match any path outside that one directory". That claim was wrong and is corrected
here.

**Available narrowing (recommended follow-up, not applied here).** Only three of the nine files
are command-line entry points; the other six are sourceable libraries never invoked directly.
The grant could therefore be replaced by three entry-point-specific entries
(`Bash(bash .claude/lib/bash/compute-cohorts.sh*)` and the two siblings) with no loss of
function. That change is deliberately not made in this pull request: the single-entry pattern is
referenced in four reviewed files, and narrowing it after the review pass would change a
verified surface. It is recorded here so the decision is explicit rather than overlooked.

The nine files, all authored in this change and all covered by shellcheck, shfmt, bats, and
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
