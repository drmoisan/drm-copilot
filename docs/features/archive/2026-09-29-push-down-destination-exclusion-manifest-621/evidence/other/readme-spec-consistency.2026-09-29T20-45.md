# README / spec consistency — [P8-T2]

Timestamp: 2026-09-29T20-45
Command: side-by-side read of `README.md` subsection `### Destination exclusion manifest` (lines 255-279) and `spec.md` sections "Manifest location", "Manifest grammar", "Malformed manifest", "Skip, conflict, and unmatched entries", "Inputs / Outputs", "Non-Goals"; line numbers located with `grep -n`
EXIT_CODE: 0
Output Summary: all twelve documented items of [P8-T1] have a README line number and a spec line number; no contradiction found.

| # | Documented item | README line | spec.md line |
|---|---|---|---|
| 1 | Path `.push-down-exclusions` at the destination root | 257 | 32 |
| 2 | Comment and blank-line rules | 262 | 41 |
| 3 | Entry normalization | 263 | 42 |
| 4 | Exact and directory-prefix semantics, optional trailing `/` | 264 | 43 |
| 5 | `**`, `*`, `?` semantics | 265 | 44 |
| 6 | Ordinal case-sensitive comparison | 266 | 45 |
| 7 | First-match precedence | 267 | 46 |
| 8 | Eight malformed-manifest conditions and the fail-fast error | 269 | 50, 54-59 |
| 9 | Skip, conflict, and unmatched reporting lines and where they appear (artifact `exclusions`, MCP `warnings`, output channel, conflict notification, CLI stdout) | 273-275, 277 | 130-132, 108, 123-126 |
| 10 | Push-down never writes, merges, or deletes the manifest | 257 | 35 |
| 11 | Absent-manifest behavior unchanged | 277 | 134 |
| 12 | Dangling-reference limitation as a documented non-goal | 279 | 192 |

Supporting observations:
- `grep -c -e '^### Destination exclusion manifest' README.md` -> 1
- `grep -c -F -e '.push-down-exclusions' README.md` -> 2
- `grep -c -F -e 'dangling' README.md` -> 1
- `grep -c -F -e 'push-down exclusion conflict: destination file present, not overwritten:' README.md` -> 1
- README Prettier warning is pre-existing: `prettier --check` on `git show HEAD:README.md` also reports style issues; README.md is not in the plan's Prettier globs.
