# Advisory local coverage read (remediation cycle 1, P4-T4; not gating)

Timestamp: 2026-10-13T15-32
Command: Grep tool pattern `sessioninfo` over <worktree>/artifacts/pester/powershell-coverage.xml (before and after P4-T3); poetry -C <worktree> run python -I <worktree>/artifacts/scratch-903/ps_line_dump_903.py <worktree>/artifacts/pester/powershell-coverage.xml <file> <first> <last> for (1) .codex/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 353 372, (2) .claude/hooks/enforce-orchestration-preimplementation-gate-targets.ps1 353 372, (3) .codex/hooks/enforce-orchestration-preimplementation-gate-epic-scope.ps1 182 210; Grep tool pattern `package name=|sourcefile name="enforce-orchestration-preimplementation-gate` over the same XML.
EXIT_CODE: 0
Output Summary: `sessioninfo` start changed (1791885058164 before, 1791890705479 after), so the local XML is from the P4-T3 run. Codex epic-scope: 183 1, 190 1, 191 1, 206 1, 207 1, 209 1 (no RI-2-LOCAL-UNATTRIBUTED). Both targets dumps printed no rows (exit 0) because the local XML contains no `enforce-orchestration-preimplementation-gate-targets.ps1` sourcefile in either the `.claude/hooks` or the `.codex/hooks` package: the MCP runner's coverage population omits the targets files. No local reading exists for Codex targets 356 and 370, so RI-1-LOCAL-RISK is not recorded and RI-1 is decided by CI (P5-T4) only.

## sessioninfo

- Before P4-T3: `<sessioninfo id="this" start="1791885058164" dump="1791885568958" />`
- After P4-T3: `<sessioninfo id="this" start="1791890705479" dump="1791891064298" />`

## (1) Codex targets 353-372 (exit 0)

No rows (file absent from the local XML).

## (2) Claude targets 353-372 (exit 0)

No rows (file absent from the local XML).

## (3) Codex epic-scope 182-210 (exit 0)

```
182 1
183 1
185 2
186 1
187 2
188 2
189 1
190 1
191 1
193 1
194 1
196 1
198 1
199 1
201 1
203 1
204 1
206 1
207 1
209 1
```

## Sourcefiles under the gate prefix in the local XML

`.claude/hooks`: epic-scope, helpers, modes, gate. `.codex/hooks`: epic-resolution, epic-scope, helpers, modes, gate. No targets file in either package.

## Observation (advisory)

In the earlier local XML (start 1791885058164, identical to the CI XML of run 38410234897), Codex epic-scope lines 183, 190, 191, 206, 207, and 209 had `ci` 0. In this run, scoped to `tests/scripts/claude-hooks` and `tests/scripts/codex-hooks` and including the new Decision suite, all six have `ci` 1. Lines 183, 190, and 191 are reachable only from the existing epic-scope suite (the Decision suite passes a path leg with no command), so the existing suite's calls were attributed in this run. The attribution difference therefore depends on the run configuration or population, not only on the new suite. This does not change the P1-T5 `Cause:` line.
