# Final QC — Extension Format (before / format / after)

Timestamp: 2026-07-26T01-21

Task: [P4-T5]
Feature: 2026-07-25-jest-rootdir-testmatch-dot-directory-423
Issue: #423
Spec AC: AC16
QC Loop Pass: 1 (single clean pass; no restart required)

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a08c9cf1932159e8f`

## Invocation 1 — git status BEFORE the formatter

Command: `git status --porcelain --untracked-files=all -- extensions/drm-copilot`
EXIT_CODE: 0

Output:
```
 M extensions/drm-copilot/jest.config.cjs
 M extensions/drm-copilot/run-jest.cjs
?? extensions/drm-copilot/test/jest-config-resolution.test.ts
```

## Invocation 2 — Formatter (write mode)

Command: `npm --prefix extensions/drm-copilot run format`
Resolved script: `prettier --write "src/**/*.ts" "test/**/*.ts" "*.json" "*.cjs"`
EXIT_CODE: 0

Output analysis (full output captured; 362 lines):

| Measure | Value |
|---|---|
| Total output lines | 362 |
| Lines NOT ending in `(unchanged)` | 4 |
| Of those 4, actual file entries | **0** — all four are the npm header (`> drm-copilot@1.0.19 format`, `> prettier --write ...`) and blank lines |
| File entries rewritten by Prettier | **0** |

Every one of the 358 processed file entries reported `(unchanged)`. The three in-scope entries
specifically:

```
test/jest-config-resolution.test.ts   3ms (unchanged)
jest.config.cjs                       (unchanged)
run-jest.cjs                          (unchanged)
```

## Invocation 3 — git status AFTER the formatter

Command: `git status --porcelain --untracked-files=all -- extensions/drm-copilot`
EXIT_CODE: 0

Output:
```
 M extensions/drm-copilot/jest.config.cjs
 M extensions/drm-copilot/run-jest.cjs
?? extensions/drm-copilot/test/jest-config-resolution.test.ts
```

## Verification — Before/After Comparison

The before and after captures are **byte-identical**: same three entries, same order, same status
codes. The formatter modified no file.

| Entry | Status | Expected? | Reason |
|---|---|---|---|
| `extensions/drm-copilot/jest.config.cjs` | ` M` | Yes | testMatch fix, [P1-T2] |
| `extensions/drm-copilot/run-jest.cjs` | ` M` | Yes | inline prohibited-flag guard, [P2-T2] |
| `extensions/drm-copilot/test/jest-config-resolution.test.ts` | `??` | Yes | new regression test, [P3-T2] |

These three entries are the in-scope changes named in the plan; their presence in both captures is
expected and is not a failure. The acceptance condition is that the two captures are identical, which
they are. No fourth entry appeared, so the write-mode formatter introduced no incidental change.

Note the extension package's prettier globs include `*.json`, which covers
`extensions/drm-copilot/tsconfig.json`, `tsconfig.jest.json`, `package.json`, and
`package-lock.json`. All reported `(unchanged)` and none appears in the after capture, so the
write-mode run did not touch any of them.

Output Summary: PASS. `npm --prefix extensions/drm-copilot run format` exits 0 and rewrote **zero**
files — all 358 processed entries reported `(unchanged)`. The `git status --porcelain` captures taken
before and after the formatter are identical, containing exactly the three expected in-scope entries
(2 modified, 1 untracked). No loop restart triggered.
