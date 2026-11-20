# Preflight Round 3 — atomic-executor report (issue #643)

- Timestamp: 2026-09-07T14:45Z
- Plan: `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/plan.2026-09-07T08-13.md` (118 tasks, Phases 0-8), reviewed at branch head `903151ff`, merge base `c3ffb080`.
- Signal: `PREFLIGHT: REVISIONS REQUIRED`
- Convergence: `CONVERGENCE: NO FURTHER ROUNDS EXPECTED` (one blocking defect with a mechanical delta: one new constraint block and three clauses prepended to existing tasks; four single-sentence advisories; no task added or renumbered).

## 1. Round-2 finding verification — all seven resolved

- N1: 28 `grep -c -F -e` occurrences; no unfixed instance; C6 sentence present. Executed: `grep -c -F -e "- [ ] " spec.md` prints `51`; `grep -c -F -e "- [x] " spec.md` prints `0` (exit 1); `grep -c -F -e "- [ ] " user-story.md` prints `11`.
- N2: `git ls-tree c3ffb080 -- .gitattributes` reports a tracked blob; `.gitattributes` holds the single line `* text=auto eol=lf`; `git grep -c -F "crlf-*.csproj -text" -- .gitattributes` currently exits 1 with no output; `git check-attr text` on both CRLF fixture paths reports `text: auto`. P5-T6 and P8-T15 carry the deltas. No tracked test asserts `.gitattributes` content.
- N3: P5-T3 carries the pre-guard byte-assembly sentence; P5-T10 scopes the three mocks into the first Describe's `BeforeAll` and adds `Describe 'Byte-level seams'` with the fixed `-WhatIf` target; 6 + 3 = 9 names; P5-T21 carries the 320 bound.
- A9, A10, A11 (extended to P0-T2 and P8-T16 with explicit ordered path lists), A12: resolved.

## 2. Re-derived change set

`git diff c3ffb080 --name-only` at `903151ff` lists eight tracked paths (the two preflight reports, issue.md, the plan, the research artifact, spec.md, user-story.md, and the promoted record). `git status --porcelain --untracked-files=all` is empty. P0-T15's enumeration matches and its admission clause covers the evidence folder while failing on any path outside the set. After this round is committed the set will be nine paths (this report); the same clause covers it.

## 3. Blocking defect

### B1 — [P3-T8], [P5-T1], [P5-T10], [P5-T12], [P7-T2] The per-batch file-budget hooks will deny four writes the plan requires, and the plan carries no reset

`.claude/settings.json` lines 126-145 register `enforce-python-batch-budget.ps1` and `enforce-powershell-batch-budget.ps1` on the `Write|Edit` PreToolUse matcher. Both cap a session at 3 production and 3 test files (`enforce-powershell-batch-budget.ps1:426-427`; `enforce-python-batch-budget.ps1` header lines 8-10), count distinct paths, classify `tests/**` and `*.Tests.ps1` as test files and `.psd1` as production (`enforce-python-batch-budget.ps1:281`), and deny the fourth distinct file of a kind (`enforce-powershell-batch-budget.ps1:293`). The cap is stated normatively in `.claude/rules/powershell.md` `## Change Budget` line 40. State resets only on deletion of `.claude/state/powershell-batch-budget.<session_id>.json` / `.claude/state/python-batch-budget.<session_id>.json`; `.claude/state/current-session-id` exists in this worktree.

Counting Write/Edit targets in task order (mirror copies excluded on the assumption they use `Copy-Item`):

- PowerShell: P1-T4 (test 1), P1-T5 (2), P3-T1 (prod 1), P3-T2 (2), P3-T3 (3), P3-T7 (test 3), P3-T8 → test 4, denied. After a reset: P5-T1 (prod 1), P5-T2 (2), P5-T3 (3), P5-T8 (test 2), P5-T9 (3), P5-T10 → test 4, denied. After a second reset: P5-T11 (test 2), P5-T12 (prod 1).
- Python: P1-T3 (test 1), P1-T6 (prod 1), P1-T7 (2), P1-T8 (test 2), P2-T1 (prod 3), P2-T4 (test 3), P7-T2 → test 4, denied. After a reset: P7-T3 (test 2).

Totals: 6 production and 8 test PowerShell files; 3 production and 5 test Python files. Precedent: `docs/features/active/2026-08-07-parallel-enforcement-hooks-440/plan.2026-08-07T11-10.md` binding constraint 5 and task [P2-T3], with evidence at `.../evidence/other/powershell-batch-reset.2026-08-08T21-46.md`. `.claude/state/` is gitignored (`.gitignore:68`), so a reset appears in no porcelain listing and [P8-T15] needs no change.

Delta (no task added, no identifier renumbered):

(a) New constraint after C8:

> ### C9 — Per-batch file budgets
>
> `.claude/rules/powershell.md` `## Change Budget` caps a batch at 3 production and 3 test PowerShell files. `.claude/hooks/enforce-powershell-batch-budget.ps1` and `.claude/hooks/enforce-python-batch-budget.ps1` are registered on the `Write|Edit` PreToolUse matcher in `.claude/settings.json` and enforce the same 3/3 caps for `.ps1`, `.psm1`, `.psd1` and for `.py`. Both count distinct paths for the whole session, classify a path under `tests/` (and any `*.Tests.ps1`) as a test file and everything else as production, deny the fourth distinct file of a kind (`enforce-powershell-batch-budget.ps1:293`), and clear only when `.claude/state/powershell-batch-budget.<session_id>.json` or `.claude/state/python-batch-budget.<session_id>.json` is deleted. `.claude/state/` is gitignored, so a reset changes no listing in P0-T15, P7-T7, P8-T1, or P8-T15.
>
> This plan writes 6 distinct production and 8 distinct test PowerShell files and 3 distinct production and 5 distinct test Python files, so both caps are reached during execution. Every mirror copy in this plan (P3-T5, P5-T14) is performed with `pwsh -NoProfile -Command "Copy-Item -LiteralPath <source> -Destination <mirror> -Force"` rather than the Write or Edit tool, so a mirror consumes no budget slot; using Write for a mirror invalidates the reset points below.
>
> Reset command for either runtime, with `<kind>` replaced by `powershell` or `python`:
>
> `pwsh -NoProfile -Command 'Get-ChildItem -Path .claude/state -Filter "<kind>-batch-budget.*.json" -ErrorAction SilentlyContinue | ForEach-Object { Write-Output ("PRE-RESET " + $_.FullName + " " + (Get-Content -Raw $_.FullName)); Remove-Item -LiteralPath $_.FullName -Force }'`
>
> Every reset appends a section to the single artifact `<FEATURE>/evidence/other/batch-budget-resets.<ISO8601>.md` carrying `Timestamp:`, `Command:`, `EXIT_CODE:`, and an `Output Summary:` that lists each `PRE-RESET` line with the file's pre-reset `prodFiles` and `testFiles` arrays, or records explicitly that zero state files were enumerated. The post-reset observation is `pwsh -NoProfile -Command "(Get-ChildItem -Path .claude/state -Filter '<kind>-batch-budget.*.json' -ErrorAction SilentlyContinue | Measure-Object).Count"` printing `0`; the exit code is recorded but carries no acceptance condition, because `Get-ChildItem` on a missing directory returns exit 1 through `pwsh -Command` even when the enumeration is empty.
>
> Contingency, applying to every task in this plan: if a Write or Edit is denied by either batch-budget hook, run the reset for that runtime, append the section to the same artifact naming the denied path and the state file quoted in the deny reason, and retry the write once.

(b) Prepend to [P3-T8]: "Before editing the suite, run the C9 PowerShell reset (this is the fourth distinct PowerShell test file of the session: `BlastRadius.KeyPartition.Tests.ps1`, `BlastRadius.TruthTable.Tests.ps1`, and `BlastRadiusConflict.Tests.ps1` already hold the three slots) and append its section to `<FEATURE>/evidence/other/batch-budget-resets.<ISO8601>.md`." Add to its acceptance: "the reset artifact records the pre-reset `testFiles` array containing those three paths and a post-reset state-file count of `0`."

(c) Prepend to [P5-T10]: "Before creating the suite, run the C9 PowerShell reset (the reset before P3-T8 cleared both lists; `Resolve-MergeableConflict.Tests.ps1` is the fourth test file since then, after `BlastRadius.Conflict.Tests.ps1`, `ProjectFileMergeGrammar.Tests.ps1`, and `ProjectFileMerge.Tests.ps1`) and append its section to the same artifact. This reset also clears the production list, which is what allows P5-T12 to edit `pester.runsettings.psd1` after P5-T1, P5-T2, and P5-T3 filled it." Add to its acceptance: "the reset artifact records the pre-reset `prodFiles` and `testFiles` arrays and a post-reset state-file count of `0`."

(d) Prepend to [P7-T2]: "Before creating the module, run the C9 Python reset (this is the fourth distinct Python test file of the session, after `blast_radius_parity_test_support.py`, `test_blast_radius_mergeable_paths.py`, and `test_parallel_drift_detection_conflicts.py`) and append its section to the same artifact." Add to its acceptance: "the reset artifact records the pre-reset `testFiles` array containing those three paths and a post-reset state-file count of `0`."

(e) Add to the C1 evidence enumeration: the artifact `<FEATURE>/evidence/other/batch-budget-resets.<ISO8601>.md`.

## 4. Advisory findings (fold into the same revision)

- A13 — plan header, C2, and [P0-T15] name a stale branch head `04347a84`; the head is `903151ff` (after this round's commit it will advance again; use the head at revision time and note that the eight-path enumeration becomes nine with this report). All C2 `wc -l` values re-verified unchanged; `jest.config.cjs` is 267.
- A14 — [P5-T10] third byte-seams case: Pester `It` blocks do not share locals. Reword to "with `-Line` set to the lines returned by a real `Read-ConflictedFile` call on `tests/fixtures/project_file_merge/bom-compile.conflicted.csproj` made in this `Describe`'s `BeforeAll`".
- A15 — C6 under-enumerates the printed-`0` assertions ([P5-T3], [P5-T2]/[P5-T19], [P7-T7] also expect a printed `0` from a `grep` that exits 1). Generalize to "every assertion in this plan that expects a printed `0` from `grep -c` is satisfied by the printed value and not by the exit code."
- A16 — non-blocking: C3 should not be read as asserting that every command it does not wrap is allowlisted (`wc`, `grep`, and `poetry run python -c` execute in practice in this runtime).

## 5. Whole-plan checks that passed

AC inventory and check-off arithmetic; fixture-corpus floors (30+2, 20+1) and `discovered == on_disk` self-consistency; parametrized node IDs reachable in both runtimes; all P3-T2 anchors reproduce; relocation safe (`Export-ModuleMember` at 489-495 does not export the relocated functions; no test calls them); convention suite discovers `*.psm1` only; neither purity hook tripped; `validate-bash.ps1` denylist not matched; test-count deltas reconcile; no evidence path outside `<FEATURE>/evidence/<kind>/`.
