# Wave-4 Confinement and Mirror-Parity Verification — Remediation Cycle 1, F8 (issue #446)

Timestamp: 2026-08-09T00-01
Task: [P7-T8]
Purpose: record the outcome of [P7-T1] through [P7-T7], so the wave-4 concurrency constraints are
verified against the reference state recorded in
`evidence/remediation-baseline/shared-file-reference.2026-08-09T00-01.md` rather than against memory.

Repository state note that applies to every range-based check below: `HEAD` is `bcf2de15`, the
implementation commit under remediation, and this cycle's Phase 1 through Phase 7 work is present in
the working tree rather than committed. `git diff c939b5b8..HEAD` therefore lists the implementation
commit's changes only. Every path-based check below was consequently run **twice** — once over
`git diff --name-only c939b5b8..HEAD` and once over `git status --porcelain` (this cycle's own changes,
including untracked additions) — so no cycle change escapes the check by being uncommitted. Both runs
are reported.

---

## [P7-T1] — Re-mirror every `.claude/**` file modified this cycle

Command:
`cp` of `.claude/skills/parallel-orchestrate/SKILL.md`,
`.claude/hooks/enforce-parallel-drift-gate.ps1`, and
`.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` to their counterparts under
`extensions/drm-copilot/resources/claude-customizations/.claude/`, followed by
`Get-FileHash -Algorithm SHA256` on each source and mirror, then
`poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py`

EXIT_CODE: 0

Output Summary: all five source/mirror pairs are byte-identical by SHA-256, and both mirror suites
pass with **9 of 9** tests green.

| Source | SHA-256 | Mirror equal |
| --- | --- | --- |
| `.claude/skills/parallel-orchestrate/SKILL.md` | `BC3D2FC87D907972D742840AB37424E16803679D3CFD87514A3BB57C4F7370CD` | yes |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | `D2F49BCF45AB35DE99D4B433284EF9EB7660738C1978153748F3F9E2691D0C93` | yes |
| `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` | `5E3FF3162DA2C49A5E51B6636AA0D5DC4E207016B1E58FB5E9B691016AE19BF2` | yes |
| `.claude/settings.json` | `322FC04EF92A56DB9615D2766DE4483F3480C0DBCF04D33D6CD29CA5FEC20677` | yes |
| `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` | `DE810C2842CC4BEC51067F190721A9C5DBBFBC6CCC084198CBB1FF279C609948` | yes |

The re-mirror was necessary, not redundant: before it,
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` was failing because [P4-T3] edited
the helpers module and [P5-T2] and [P5-T3] edited the hook after [P1-T7]'s Phase 1 mirror, and no
earlier task ever mirrored SKILL.md although Phases 1, 2, 3, 5, and 6 all edit it. That anticipated
intermediate failure is recorded in `evidence/remediation-baseline/f8-n4-verification.2026-08-09T00-01.md`
and is cleared by this task.

---

## [P7-T2] — Every SKILL.md edit lies inside `## Radius Drift Detection (F8)`

Command: `git diff --unified=0 -- .claude/skills/parallel-orchestrate/SKILL.md | grep "^@@"`, plus
`sed -n '434,443p' ... | cat -A` against the [P0-T11] verbatim reference, plus
`grep -c "^## "`, plus
`poetry run pytest tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`

EXIT_CODE: 0

Output Summary: all eight diff hunks begin at or after line 455, and
`## Radius Drift Detection (F8)` begins at line 443, so every edit made in Phases 1 through 6 lies
inside the F8 region. Hunk starts: 455, 466, 534, 546, 569, 669, 705, 733.

The two sibling reserved sections are byte-identical to the text recorded in [P0-T11], at the same
line numbers and with the same blank-line framing, verified with `cat -A` so a trailing-whitespace or
line-ending change would have shown:

- line 434 blank, line 435 `## Mutation Protocol (F6)`, line 436 blank, line 437
  `Reserved for F6; content is appended by that feature and must not be relocated.`, line 438 blank.
- line 439 `## Enforcement Hooks (F7)`, line 440 blank, line 441
  `Reserved for F7; content is appended by that feature and must not be relocated.`, line 442 blank.
- line 443 `## Radius Drift Detection (F8)`, still closing the file.

Relative order is unchanged: F6 (435), then F7 (439), then F8 (443). The file contains exactly
**sixteen** `##` headings, matching the [P0-T11] structural reference; no `##` heading was added. Total
lines grew from 684 at cycle entry to 739, and all 55 added lines are inside the F8 region.

`test_parallel_orchestrator_surface_contracts.py` passes with **36 of 36** tests green, and that file
is unmodified by this cycle, so the `RESERVED_HEADINGS`, `FILLED_RESERVED_HEADINGS`, sixteen-`##`
layout, and reserved-section-ordering assertions all hold against the amended SKILL.md.

---

## [P7-T3] — `validate_parallel_orchestrator_state.py` unchanged; F7 seam intact and empty

Command: `git status --porcelain scripts/dev_tools/validate_parallel_orchestrator_state.py`,
`git diff --numstat c939b5b8..HEAD -- scripts/dev_tools/validate_parallel_orchestrator_state.py`,
`sed -n '327,334p'`, and `Get-FileHash -Algorithm SHA256`

EXIT_CODE: 0

Output Summary: the file is **unmodified by this cycle** (`git status --porcelain` returns nothing for
it) and its SHA-256 is `b412940d73e4e4cc04f2cb6b762f5897d4ba4d3244df02fea721addd37e9a2ad`, exactly the
value recorded in [P0-T11].

Its diff against `c939b5b8` is still **exactly two added lines and zero removed lines** (`numstat`
reports `2 0`):

```diff
+from scripts.dev_tools._parallel_orchestrator_state_drift import validate_drift_gate
+    errors.extend(validate_drift_gate(state_map, CONTEXT))
```

The F8 dispatch call sits at line 325, immediately after `_validate_collections` and **above** the
`# BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION` comment at line 327, so it is outside
the seam. The seam block at lines 327-334 is byte-identical to the [P0-T11] verbatim text, contains no
helper invocation, and is therefore **still empty**. No comment line in it was touched.

---

## [P7-T4] — `.claude/settings.json` unchanged; runsettings additions only

Command: `Get-FileHash -Algorithm SHA256 .claude/settings.json`,
`git status --porcelain .claude/settings.json`,
`git diff --numstat bcf2de15 -- scripts/powershell/PoshQC/settings/pester.runsettings.psd1`,
`git diff bcf2de15 -- scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and
`Import-PowerShellDataFile`

EXIT_CODE: 0

Output Summary: `.claude/settings.json` SHA-256 is
`322fc04ef92a56db9615d2766de4483f3480c0dbcf04d33d6cd29ca5fec20677`, matching the [P0-T11] recorded
value exactly, and the file is unmodified by this cycle. This cycle required no change to it: the
extracted PowerShell sibling module is dot-sourced by the registered hook rather than registered as a
hook of its own, exactly as the plan anticipated.

`scripts/powershell/PoshQC/settings/pester.runsettings.psd1` differs from `bcf2de15` by **4 added
lines and 0 removed lines**. All four are appended at the end of the existing `CodeCoverage.Path`
list — a two-line comment citing issue #446 remediation cycle 1 and the Coverage Exclusion Policy,
followed by the single `'.claude/hooks/enforce-parallel-drift-gate-helpers.ps1'` entry. No existing
entry was moved, reflowed, or removed; the diff hunk shows only `+` lines. The file still parses as a
PowerShell data file, reporting 49 `CodeCoverage.Path` entries.

---

## [P7-T5] — Bundled-mirror parity for every mirrored file this cycle touched

Command: `Get-FileHash -Algorithm SHA256` over each of the five source/mirror pairs (the table under
[P7-T1] above), plus `grep -n "enforce-parallel-drift-gate"` and a `json.load` parse of
`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`

EXIT_CODE: 0

Output Summary: all five source/mirror pairs have equal SHA-256, as recorded in the [P7-T1] table.
`core.json` lists **both** hook paths, at lines 36 and 37:

```json
    ".claude/hooks/enforce-parallel-drift-gate.ps1",
    ".claude/hooks/enforce-parallel-drift-gate-helpers.ps1",
```

The manifest parses as valid JSON.

---

## [P7-T6] — No out-of-scope file was modified

Command: `git diff --name-only c939b5b8..HEAD` and `git status --porcelain | cut -c4-`, each piped
through a six-class path predicate check; plus `git diff --name-only bcf2de15..HEAD` and
`git status --porcelain` for the two F5-owned artifacts

EXIT_CODE: 0

Output Summary: the requirement sentence enumerates **six** path classes while the acceptance clause
says "none of the first five paths". It is read here as **all six**, which is the stricter reading, and
all six are confirmed absent from both lists.

| Path class | `c939b5b8..HEAD` (48 paths) | This cycle's changes (31 paths) |
| --- | --- | --- |
| 1. any path under `.claude/rules/` | absent | absent |
| 2. any path under `.github/instructions/` | absent | absent |
| 3. `.claude/skills/orchestrate/SKILL.md` | absent | absent |
| 4. any `.ts` or `.tsx` path | absent | absent |
| 5. `tests/scripts/claude-hooks/enforce-pr-author-skill.Tests.ps1` | absent | absent |
| 6. `tests/scripts/codex-hooks/codex-pretooluse-integration.Tests.ps1` | absent | absent |

Total violations: **0** in each run.

For the two F5-owned test artifacts the auditable range is `bcf2de15..HEAD`, because `bcf2de15`
modified both and a `c939b5b8`-based criterion could never pass. `git diff --name-only bcf2de15..HEAD`
is **empty** (`HEAD` is `bcf2de15`), and `git status --porcelain` returns nothing for either
`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` or
`tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py`. **Neither F5 test artifact
appears**, so neither was modified by this cycle. This is corroborated independently by [P7-T2], where
`test_parallel_orchestrator_surface_contracts.py` passes 36 of 36 while unmodified.

---

## [P7-T7] — Every created or modified code file is under 500 lines

Command: a line count over every `.py`, `.ps1`, and `.psd1` path in the union of
`git diff --name-only c939b5b8..HEAD` and `git status --porcelain`

EXIT_CODE: 0

Output Summary: **28** code files inspected, **0** over the 500-line cap. The two files that stood at
exactly 500 lines with zero headroom at cycle entry now carry real headroom, which is what Phase 1's
split existed to produce:

| File | Cycle entry | Now | Headroom |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-parallel-drift-gate.ps1` | 500 | **359** | 141 |
| `tests/scripts/claude-hooks/enforce-parallel-drift-gate.Tests.ps1` | 500 | **386** | 114 |
| `.claude/hooks/enforce-parallel-drift-gate-helpers.ps1` | absent | 302 | 198 |
| `tests/scripts/claude-hooks/enforce-parallel-drift-gate-helpers.Tests.ps1` | absent | 268 | 232 |

The tightest remaining file is `scripts/dev_tools/parallel_drift_detection.py` at **499** lines, one
line of headroom. That is within the cap and no further task in this plan edits it: [P2-T3] left it at
490 as its own acceptance required, and [P4-T2] consumed nine of the ten available lines. The next
change to that module should expect to split it.

Other notable figures: `scripts/dev_tools/parallel_drift_detection_cli.py` 473 (27 spare),
`tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` 479 (21 spare, and
unmodified by this cycle), `scripts/dev_tools/_parallel_drift_shape.py` 286,
`tests/scripts/dev_tools/test_parallel_drift_timestamps.py` 120,
`scripts/dev_tools/parallel_drift_resolution.py` 180.

---

Verdict: **every wave-4 concurrency constraint held.** The three reserved SKILL.md sections are
byte-identical and in their original relative order with F8 closing the file and sixteen `##` headings
intact; `.claude/settings.json` is untouched; the runsettings change is append-only inside
`CodeCoverage.Path`; nothing was added inside the F7 extension seam, which remains byte-identical and
empty; `scripts/dev_tools/validate_parallel_orchestrator_state.py` still carries exactly its two-line
`bcf2de15` diff; neither F5-owned test artifact was modified; no path under `.claude/rules/` or
`.github/instructions/`, no `.claude/skills/orchestrate/SKILL.md`, no TypeScript file, and neither
named pre-existing-failure test file was touched; every mirrored file is byte-identical to its bundled
counterpart; and no file exceeds 500 lines.
