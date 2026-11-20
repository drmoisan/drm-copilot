# Permission-Surface Callout for the Pull Request — Issue #462

Timestamp: 2026-08-10T17-08
Amended: 2026-08-10T21-47 (remediation cycle 1, RI-2)

Task: [P6-T9]; amended by [P3-T5] of `remediation-plan.2026-08-10T21-03.md`
Purpose: supply the exact PR-description text that identifies this feature's deliberate
permission-surface change, satisfying acceptance criterion AC15. The PR author includes the
block below verbatim.

---

## Permission-surface change (deliberate)

This change adds three new Bash allowlist patterns — one per command-line entry point — in three
places:

```
Bash(bash .claude/lib/bash/compute-cohorts.sh*)
Bash(bash .claude/lib/bash/compute-concurrency-batches.sh*)
Bash(bash .claude/lib/bash/validate-parallel-manifest.sh*)
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

**Scope of the pattern, stated precisely.** Each of the three entries is a **prefix wildcard on a
specific filename**, not a directory glob. An invocation must begin with `bash` followed by the
exact path of one of the three entry-point scripts. The trailing `*` therefore permits **trailing
arguments** — `bash .claude/lib/bash/validate-parallel-manifest.sh --print-mode <path>` matches, and
that is the intent, because every entry point takes arguments. What the trailing `*` no longer
permits is a different file: it does not match a nested subdirectory
(`.claude/lib/bash/sub/x.sh`), and it does not match a relative-traversal path
(`.claude/lib/bash/../../../x.sh`), because both diverge from the fixed filename before the wildcard
is reached. The six sourceable libraries in the same directory are not directly invocable under the
grant; they are reachable only by being sourced from inside one of the three granted entry points.

The residual surface a reviewer should read is: "a `bash` invocation of exactly one of these three
named scripts, with any arguments" — not "any `bash` invocation under `.claude/lib/bash/`".

An earlier revision of this callout described a single grant `Bash(bash .claude/lib/bash/*)` and
claimed the pattern "does not match a nested subdirectory, and does not match any path outside that
one directory". That claim was wrong for the single-entry form — the trailing `*` matched across
`/`, admitting nested subdirectories and relative-traversal paths — and it was corrected in a prior
revision of this artifact. Both the original claim and its correction are retained here as the
historical record. The three-entry grant delivered in remediation cycle 1 makes the original
statement true as a property of the pattern itself rather than as an accident of the directory's
current contents.

**Narrowing applied (remediation cycle 1).** Only three of the nine files are command-line entry
points; the other six are sourceable libraries never invoked directly. The single grant has now been
replaced by the three entry-point-specific entries shown above, in all six locations, with no loss
of function. This narrowing was applied in remediation cycle 1 per RI-2 of
`remediation-inputs.2026-08-10T21-03.md`, at the user's direction, after the feature-review pass. It
is no longer a recommended follow-up; it is delivered. The earlier decision to defer it — on the
grounds that narrowing a reviewed surface after the review pass would change a verified surface —
was superseded by that direction, and the change is re-verified by a re-audit of this cycle.

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
