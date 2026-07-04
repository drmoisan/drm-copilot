# Phase 6 — Exclusion Invariants

- Timestamp: 2026-06-16T11-00
- Issue: #187
- Task: [P6-T3]

## Commands

```
git status --porcelain | grep -iE "settings.local|agent-memory"
find extensions packages -name "validate_orchestrator_state.py"
ls .claude/schemas/orchestrator-state.schema.json
git status --porcelain | grep -i "schema"
```

## EXIT_CODE

0 (all confirmations passed)

## Output Summary

- `settings.local.json`: present in the SOURCE tree
  (`artifacts/tocompare/.claude/settings.local.json`) but NOT added to the
  repository. `git status` shows no `settings.local.json` addition under
  `.claude/` or either bundle mirror.
- `agent-memory/**`: present in the SOURCE tree
  (`artifacts/tocompare/.claude/agent-memory/`) but NOT propagated. `git status`
  shows no `agent-memory` addition.
- No `validate_orchestrator_state.py` mirror exists under either bundle
  (`find extensions packages -name validate_orchestrator_state.py` returns
  nothing). The Python validator is correctly unmirrored.
- No verbatim `orchestrator-state.schema.json` was added to `.claude/schemas/`
  or either bundle; `ls .claude/schemas/orchestrator-state.schema.json` returns
  no file and `git status` shows no schema file addition. The
  `human_interaction` invariants are enforced by Python validator logic, not a
  copied schema.

## Note on the packages/mcp-server mirror

The `packages/mcp-server/resources/` directory is gitignored
(`packages/mcp-server/.gitignore:3:resources/`); it is a build-time synced copy
rather than committed source. The eight changed/created canonical files were
copied into that mirror and verified byte-identical on disk in [P6-T2]. This
satisfies the on-disk parity invariant required by the spec.
