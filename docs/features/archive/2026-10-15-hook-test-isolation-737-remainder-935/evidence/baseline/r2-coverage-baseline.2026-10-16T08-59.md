# R2 Coverage Baseline and Mode Check (issue #935, remediation cycle 2)

Timestamp: 2026-10-16T08-59
Task: [P0-T5]
Command: (a) `grep -c -F -e 'UseBreakpoints' scripts/powershell/PoshQC/settings/pester.runsettings.psd1`; (b) Glob `*/resources/powershell/PoshQC/settings/pester.runsettings.psd1` under `~/.vscode/extensions`, then the same `grep -c` on the match; (c) D-COV-FRESH (`stat -c %y artifacts/pester/powershell-coverage.xml`; `grep -n -F -e 'report name="Pester (' artifacts/pester/powershell-coverage.xml`), D-COV-READ (`grep -c -E -e '^  .counter type="LINE" missed=' ...` and the `awk -F'"'` root read), and D-FILE-READ (the inline `awk` program of the plan, verbatim, over `artifacts/pester/powershell-coverage.xml`).
EXIT_CODE: 0

Output Summary:

CI figures (quoted from `FEATURE/remediation-inputs.2026-10-16T07-55.md`; not local measurements):
- PR head `da4ccf4f0`: covered 16395, missed 1767, total 18162, 90.27%
- Baseline `adb9aa5f0`: covered 16381, missed 1735, total 18116, 90.42%
- main at `b6be46b5e`: covered 16425, missed 1737, total 18162, 90.44%
- `.claude/lib/worktree-resolution/WorktreeResolution.psm1`: 142 covered / 2 missed on main; 112 covered / 32 missed on the PR head

UseBreakpoints counts:
- Repository `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`: 0 (grep exit 1, no match)
- Installed extension copy (one Glob match, extension folder `undefined_publisher.drm-copilot-0.0.1`): 0 -> breakpoint mode (no `INSTALLED-SETTINGS-NOT-BREAKPOINT`)

Local values (on-disk `artifacts/pester/powershell-coverage.xml`, written before this cycle):
- D-COV-FRESH: last-write `2026-10-16 03:23:19.098735300 -0400`; `report name` line `3:<report name="Pester (10/16/2026 03:22:55)">` (unchanged since planning; no `LOCAL-FILE-CHANGED-SINCE-PLANNING`)
- D-COV-READ: root LINE counter match count 1; `covered=8110 missed=4170 total=12280 pct=66.04` (local population; not comparable with CI)
- D-FILE-READ (exit 0):
  - `sourcefiles=1 covered=127 missed=17 listed=30 credited=18`
  - `credited-lines: 79 254 255 318 321 322 325 326 327 328 331 376 377 378 379 382 383 384`
  - `uncredited-lines: 144 150 247 284 319 323 329 363 446 453 454 460`

Acceptance: numeric CI figures and local values recorded; repository `UseBreakpoints` count is 0; the `report name` line is unchanged and the D-FILE-READ output equals the planning observation. PASS.
