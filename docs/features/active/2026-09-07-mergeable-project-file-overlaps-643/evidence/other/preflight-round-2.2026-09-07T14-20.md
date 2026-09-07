# Preflight Round 2 — atomic-executor report (issue #643)

- Timestamp: 2026-09-07T14:20Z
- Plan: `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/plan.2026-09-07T08-13.md` (118 tasks, Phases 0-8), reviewed at branch commit `04347a84`, merge base `c3ffb080`.
- Signal: `PREFLIGHT: REVISIONS REQUIRED`
- Convergence: `CONVERGENCE: NO FURTHER ROUNDS EXPECTED` (all three blocking findings have mechanical deltas that fit inside existing task text; no task is added and no identifier is renumbered).

## 1. Round-1 finding verification — all 25 resolved

Every round-1 finding (B1-B9, O1-O3, C-1 to C-5, A1-A8) was re-derived against the current tree and is resolved. Confirmed corrections: B7 counts (exactly 2 agent / at least 4 skill) reconcile with P5-T15 (1), P5-T16 (1), P5-T17 (2), P6-T6 (1); O2 skill sentence spans 447-448; C-1 `observe` 54-66, `deriveModules` 68-81; C-2 `MINIMUM_FIXTURE_COUNT=20` at bats line 46; A4 wrapper executed (`npm --version` exit 0; failing script exit 1; `run-jest.cjs` forwards args so `-- --coverageReporters=text` reaches Jest); A7 assertion at line 133; P5-T6 `pwsh` form prints `True` on CRLF and `False` on LF.

Whole-plan checks that passed: AC inventory (51 + 11), work-mode marker, all check-off arithmetic, every named test node ID and Pester `It` name, all Phase 1-7 line anchors, `git grep` only on tracked paths and plain `grep` only on plan-created paths, no collision with `validate-bash.ps1` or `check-powershell-test-purity.ps1`.

Directive item 3: `git diff c3ffb080 --name-only` now lists seven tracked paths; the seventh is `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/other/preflight-round-1.2026-09-07T13-38.md`. P0-T15's evidence-folder admission clause covers it; explicit enumeration is not required (see A12 for the prose note).

## 2. New blocking defects

### N1 — [P1-T12, P2-T8, P3-T13, P4-T13, P5-T22, P6-T9, P7-T8, P8-T17] The check-off commands are not executable

GNU grep 3.0 parses the leading `-` of the pattern `- [x] ` as an option cluster:

```
$ grep -c -F "- [ ] " .../spec.md
grep: unknown option --
exit=2
```

All sixteen check-off assertions exit 2 regardless of content. Delta: insert `-e` before every checkbox pattern in all eight tasks. Worked example for [P1-T12]:

> Acceptance: `grep -c -F -e "- [x] " docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/spec.md` prints `3`, `grep -c -F -e "- [ ] " docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/spec.md` prints `48`, and `git diff c3ffb080 --numstat -- docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/spec.md` reports a removed count of `0` and an added count of `253`.

C6 addition:

> Every checkbox count supplies the pattern through `-e`, because the patterns `- [x] ` and `- [ ] ` begin with a hyphen and GNU grep otherwise reads them as an option cluster and exits 2 without searching. `grep -c` prints `0` and exits 1 when there is no match, so the two assertions that expect `0` ([P7-T8] on `user-story.md`, [P8-T17] on both files) are satisfied by the printed value and not by the exit code.

Verified after the delta: `grep -c -F -e "- [ ] " spec.md` prints `51`; `grep -c -F -e "- [x] " spec.md` prints `0` (exit 1); `grep -c -F -e "- [ ] " user-story.md` prints `11`.

### N2 — [P5-T6, P5-T9, P8-T15] The CRLF fixture is normalized away by `.gitattributes`

The repository-root `.gitattributes` contains exactly one line, `* text=auto eol=lf`; `git check-attr text eol -- tests/fixtures/project_file_merge/crlf-compile.conflicted.csproj` reports `text: auto`, `eol: lf`; `git grep -Il $'\r' -- 'tests/fixtures/**'` returns nothing. On commit the CRLF fixture is normalized to LF, so the `preserves CRLF terminators` case of P5-T9 passes on the executor's uncommitted worktree and fails on every fresh checkout including CI. The BOM fixture is unaffected.

Delta. Extend [P5-T6] (no new task):

> Before creating the CRLF pair, append the line `tests/fixtures/project_file_merge/crlf-*.csproj -text` to the repository-root `.gitattributes`, preceded by a comment naming issue #643 and stating that the single existing rule `* text=auto eol=lf` would otherwise rewrite the fixture's CRLF terminators to LF on commit, which makes the `preserves CRLF terminators` case of P5-T9 pass on an uncommitted worktree and fail on every fresh checkout. Acceptance: `git check-attr text -- tests/fixtures/project_file_merge/crlf-compile.conflicted.csproj` reports `text: unset`; `pwsh -NoProfile -Command "[System.IO.File]::ReadAllBytes('tests/fixtures/project_file_merge/bom-compile.conflicted.csproj')[0..2] -join ','"` prints `239,187,191`; and `pwsh -NoProfile -Command 'Set-Variable t ([System.IO.File]::ReadAllText("tests/fixtures/project_file_merge/crlf-compile.conflicted.csproj")); ([regex]::Matches($t, "\r\n")).Count -eq ([regex]::Matches($t, "\n")).Count'` prints `True`.

Add `.gitattributes` to the [P8-T15] allowed-path enumeration immediately after the `extensions/drm-copilot/jest.config.cjs` (P4-T3) entry: `.gitattributes` (P5-T6, the CRLF-fixture normalization exemption).

### N3 — [P5-T3, P5-T10, P5-T12, P8-T12] The per-file coverage floor for the entry script cannot be met under the stated mocking design

[P5-T10] is the only suite that reaches `Resolve-MergeableConflict.ps1`, and it registers blanket mocks for `Invoke-GitExe`, `Write-MergedFile`, and `Read-ConflictedFile` and skips the guarded entry point. Three of the script's five functions plus the entry-point body are never executed, so the per-file 85% line floor asserted in [P8-T12] cannot be met. Mocking `Invoke-GitExe` and skipping the guarded entry point are unavoidable; mocking the other two is not.

Delta (two additions inside existing tasks).

[P5-T3], after the `Write-MergedFile` description:

> `Write-MergedFile` assembles the byte array before the `ShouldProcess` guard and places only the `[System.IO.File]::WriteAllBytes` call inside it, so a `-WhatIf` invocation executes every line but that one. This keeps the file's per-file line coverage above the [P8-T12] floor, which the blanket mocks of [P5-T10] would otherwise put it below.

[P5-T10], replacing "Acceptance: ... lists the six names as passed":

> Add a second `Describe 'Byte-level seams'` that registers none of the three mocks, with `reads the byte-order mark and the retained terminators from a BOM fixture` (call the real `Read-ConflictedFile` on `tests/fixtures/project_file_merge/bom-compile.conflicted.csproj`; `HasBom` is `$true` and every returned line retains its own terminator), `reads a CRLF fixture with its terminators retained` (the real `Read-ConflictedFile` on `crlf-compile.conflicted.csproj`; every line ends with CRLF and `HasBom` is `$false`), and `assembles the merged bytes without writing under -WhatIf` (call the real `Write-MergedFile -WhatIf` and assert with `Test-Path` that no file was created). All three read committed fixtures only and create no file. Acceptance: `wc -l tests/scripts/claude-lib/project-file-merge/Resolve-MergeableConflict.Tests.ps1` reports at most 320, and P5-T19 lists the nine names as passed.

Update [P5-T21]'s line-count bound for that suite accordingly. [P5-T19] already quantifies over the enumeration.

## 3. Advisory findings (address in the same revision)

- A9 — [P8-T1] the extension filter omits `.cjs`; `extensions/drm-copilot/jest.config.cjs` is edited by [P4-T3]. Add `.cjs`.
- A10 — [P1-T7] `scripts.dev_tools._blast_radius_mergeable` sorts between `_blast_radius_glob` (line 48) and `_blast_radius_normalization` (line 49) under isort; reword as "immediately before the `_blast_radius_normalization` import at line 49".
- A11 — [P0-T12], [P3-T5], [P5-T4], [P5-T14], [P8-T10] state PowerShell cmdlets (`Get-FileHash -Algorithm SHA256`, `Get-ChildItem ... | Measure-Object`, `Test-Path`) without the `pwsh -NoProfile -Command "..."` wrapper that constraint C3 fixes. Wrap them.
- A12 — [P0-T15] the artifact prose should record that the anchored diff lists seven tracked paths, the seventh being the round-1 preflight report under `evidence/other/` (and, after this round, an eighth: `evidence/other/preflight-round-2.2026-09-07T14-20.md`), rather than implying the listing is exactly the six enumerated paths. The evidence-folder admission clause already covers both.

## 4. Delta self-check

N1's replacement commands were executed against the current tree and return `51`, `0`, and `11`; N2's `git check-attr` form currently reports `text: auto`, so the post-change assertion `text: unset` is falsifiable; N3's added assertions name concrete committed fixture paths and a `Test-Path` observation. No delta introduces a placeholder token, an unanchored `git diff`, a filesystem-path coverage argument, or a name-listing diff without a porcelain companion.
