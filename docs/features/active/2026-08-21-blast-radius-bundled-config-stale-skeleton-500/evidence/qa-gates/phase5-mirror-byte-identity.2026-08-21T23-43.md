# Phase 5 mirror byte-identity verification (Issue #500)

Timestamp: 2026-08-21T23:43:00Z
Issue: #500
Task: [P5-T3]

Command:

```
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
sha256sum .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
cmp .claude/rules/parallel-orchestration.md extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md
```

(working directory: worktree root)

EXIT_CODE: 0

Output Summary:

## Pytest

```
collected 10 items
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py .... [ 40%]
......                                                                   [100%]

10 passed in 0.12s
```

- passed: **10**
- failed: **0**

`test_bundled_claude_payload_contains_all_repo_runtime_contracts`
(`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:101-126`) enforces byte
identity for every `.claude/**` file between the repository tree and the bundled payload. Its pass
is the byte-identity proof required by spec AC8.

## Independent digest comparison

Both copies of `.claude/rules/parallel-orchestration.md` after the [P5-T1] amendment and the
[P5-T2] mirror:

| Path | sha256 |
| --- | --- |
| `.claude/rules/parallel-orchestration.md` | `222de3c8c84c74f642f7ef909e5293818b4bbbbaa6d71d9f8d92271591ec6578` |
| `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` | `222de3c8c84c74f642f7ef909e5293818b4bbbbaa6d71d9f8d92271591ec6578` |

The digests are equal and `cmp` reported no difference. File size is 34831 bytes, up from the
pre-change 31560 bytes; the pre-change digest of both copies was
`3e37daabc40604237d4946362073a87b9316e5ff34e63902ea21ade151428ac0`, so both copies moved together
within this change set.

## Amendment recorded

The new subsection `### The published truth table is not a copy of this one (issue #500)` sits under
`## Blast-Radius Contention Doctrine (issue #489)`, immediately after the module-map granularity
criterion, and records the three points spec AC7 requires: the derived destination module map and
the unconsumed bundled `modules` key; `PAYLOAD_MODULES` carrying `config` only with `claude-runtime`
disqualified by the same granularity criterion; and the portable-subset relation for
`shared_surfaces` and `shared_surface_globs` with the surfaces-versus-modules asymmetry as the
stated reason. The file is Markdown documentation and is exempt from the 500-line limit under
`.claude/rules/general-code-change.md`.
