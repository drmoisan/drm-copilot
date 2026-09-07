# Preflight Round 4 — atomic-executor report (issue #643)

- Timestamp: 2026-09-07T15:05Z
- Plan: `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/plan.2026-09-07T08-13.md` (118 tasks, Phases 0-8), reviewed at branch head `c97101af`, merge base `c3ffb080`.
- Signal: `PREFLIGHT: ALL CLEAR`
- Convergence: `CONVERGENCE: NO FURTHER ROUNDS EXPECTED`

## Round-3 findings — all resolved

- B1: constraint C9 present after C8 (plan lines 95-107) with reproducing citations (`powershell.md:40`, `settings.json:128-145`, `enforce-powershell-batch-budget.ps1:293`, `.gitignore:68`); reset clauses and acceptance additions on P3-T8, P5-T10, P7-T2; C1 enumerates the `batch-budget-resets` artifact; P3-T5 and P5-T14 use `pwsh -NoProfile -Command "Copy-Item ..."` (P5-T14 also `New-Item -ItemType Directory -Force`).
- A13: header, C2, P0-T15 cite `903151ff` with the nine-path enumeration.
- A14: `-Line` sourced from a real `Read-ConflictedFile` call in the Describe's `BeforeAll`.
- A15: C6 generalized to every printed-`0` `grep -c` assertion; no seventh instance found.
- A16: C3 disclaimer present.

## Re-derived batch-budget counts

PowerShell production 6, PowerShell test 8, Python production 3, Python test 5; denial points fall at exactly P3-T8, P5-T10, and P7-T2. The C9 reset command was executed in dry form (`.claude/state/` holds only `current-session-id`; nothing matched); quoting survived the Bash tool and the post-reset observation printed `0` for both kinds. The reset, `Copy-Item`, and `New-Item` wrappers are not matched by the `validate-bash.ps1` denylist; the P5-T10 constructs pass `check-powershell-test-purity.ps1`.

## Whole-plan re-review

All C2 `wc -l` values, all PowerShell/TypeScript/rule/skill/agent anchors, and the config anchors reproduce at `c97101af`. Absolute Phase-8 coverage thresholds are reachable (extension 96.72% lines / 90.17% branches; Python TOTAL 91% with about 90% branch; PoshQC `Covered 94.19%`). `run-jest.cjs` forwards extra argv; prettier `^3.9.6` emits the `(unchanged)` marker. Contract-test interactions hold (no new `##` headings; six header fields and three projection references retained; frozen digest pins epic files only; `core.json` completeness satisfied by P3-T4 and P5-T13).

## Change set and header hash

`git diff c3ffb080 --name-only` lists nine tracked paths (six enumerated plus three preflight reports); porcelain is empty; `903151ff..c97101af` changed only the plan and the round-3 report. The header hash need not be updated: no acceptance condition reads a branch-head hash, and P0-T15's count-agnostic admission clause covers this report as a tenth path once committed.

## Non-blocking observations (no revision required)

1. C9's exit-code rationale is factually wrong: `Get-ChildItem` with `-ErrorAction SilentlyContinue` on a missing directory prints `0` and exits 0. The instruction it supports (record the exit code, attach no acceptance condition) remains valid.
2. P1-T3 leaves the docstring at `test_blast_radius_config_parity.py:186-187` enumerating three keys after the parametrization carries four; no test asserts that text.
3. P3-T2 says "header line 9 list"; the list spans lines 9-10; no acceptance condition reads the line number.
4. C9's classification sentence omits that the Python hook also treats `test_*.py` anywhere as a test file; no path in this plan is affected.
5. P3-T8 and P7-T2 acceptance name bare filenames for the `testFiles` array; the hook persists normalized full paths, so the check is a suffix match.
