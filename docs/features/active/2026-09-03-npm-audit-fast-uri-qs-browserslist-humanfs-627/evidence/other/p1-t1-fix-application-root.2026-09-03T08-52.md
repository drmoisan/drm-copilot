# P1-T1 — Fix Application (Repo Root)

- Timestamp: 2026-09-03T08-52

## Commands Run (in order)

1. `git status --porcelain -- package-lock.json` — EXIT_CODE: 0 — output: empty (pre-check, matches P0-T4 baseline)
2. `npm audit fix` (no `--force`) — EXIT_CODE: 0 — output: "found 0 vulnerabilities" (536 packages added/audited)
3. `git status --porcelain -- package-lock.json` — EXIT_CODE: 0 — output: ` M package-lock.json` (post-check: file was rewritten)
4. `npm audit --audit-level=moderate` — EXIT_CODE: 0 — output: "found 0 vulnerabilities"
5. `git status --porcelain -- package.json` — EXIT_CODE: 0 — output: empty (package.json unchanged)

## Output Summary

`npm audit fix` (non-force) resolved all 4 baseline advisories (`@humanfs/node`, `browserslist`, `fast-uri`, `qs`) in the repo root workspace. `package-lock.json` was rewritten (confirmed via `git status --porcelain`, not inferred from the exit code alone); `package.json` was not modified. The post-fix `npm audit --audit-level=moderate` run reports 0 vulnerabilities and exits 0 — zero residual advisories. No `--force` probe was necessary or run, since no residual advisory remained.
