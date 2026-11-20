# Feature Audit: Mermaid Diagram Claude Runtime Port (#491)

---

**Audit Date:** 2026-08-20
**Feature Folder:** `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491`
**Base Branch:** `main`
**Head Branch:** `drm-copilot-wt-2026-08-19T08-39`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `71aebdb9a1e4752b191b3c9d4e677b807ea6fdec`)
- **Head branch/commit:** `drm-copilot-wt-2026-08-19T08-39` (commit `3338400c0726c58b3b9a4fe40147e84697c87fea`)
- **Merge base:** `71aebdb9a1e4752b191b3c9d4e677b807ea6fdec` (verified by `git merge-base origin/main HEAD`; branch 0 behind, 2 ahead)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` and direct `git diff 71aebdb9..HEAD`
  - Feature evidence: `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/evidence/**` (30 artifacts)
  - Additional evidence: reviewer's own re-runs — full `Invoke-PoshQCTest` at head (3107/0/9, coverage regenerated), `Invoke-PoshQCAnalyze` (0 findings), `Invoke-PoshQCFormat` (no changes), pytest distribution suites (13 passed), Jest completeness (15 passed), 9 live hook probes
- **Feature folder used:** `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491`
- **Requirements source:** `spec.md` (AC-1..AC-25) and `user-story.md` (8 story-level criteria), tracked independently
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are both authoritative AC sources per the acceptance-criteria tracking rules.
- **Scope note:** Full feature-vs-base audit; no version subfolder exists, so artifacts land in the feature root. The branch was rebased onto `origin/main` immediately before review; PR context artifacts were refreshed against that state and match the live diff exactly (92 files).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/spec.md` — primary source (AC-1..AC-25, checkbox-based, all currently checked)
- `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/user-story.md` — secondary source (8 story-level checkboxes, all currently checked; each maps to spec AC ranges)

### From spec.md (abbreviated labels; full wording preserved in the source file)

1. AC-1: `.claude/rules/mermaid.md` exists, frontmatter `paths` scoped to `**/*.mmd`/`**/*.mermaid`, states conventions, validation mandate, managed-diagram constraint, D3 opt-out marker.
2. AC-2: `.claude/skills/mermaid-diagram/SKILL.md` exists (<500 lines), valid frontmatter, workflow, eight recipes, D6 conditional rendering with fallback, D3 marker docs, gate-delta statement, references pinned to 11.17.0 with WebFetch fallback.
3. AC-3: hook exists (<500 lines), registered in `Write|Edit` matcher as `pwsh -NoProfile -File ...`, `$PSScriptRoot` resolution with fail-open missing-module guard, read-only header, dot-sourcing guard.
4. AC-4: `.claude/lib/mermaid/` modules (<500 lines each), structured result entry, 11.17.0 pin + source URL in header.
5. AC-5: rejects missing/non-keyword and misspelled first line, naming the defect.
6. AC-6: rejects unbalanced `[]`/`()`/`{}` and unterminated quotes on structural lines, quote-aware.
7. AC-7: rejects arrows invalid for the declared type (flowchart, sequence, class, state, ER minimum).
8. AC-8: every research §4 false-positive construct accepted, each an explicit test.
9. AC-9: each of the seven D4 fail-open items asserted to allow.
10. AC-10: CRLF/LF byte-equivalent verdicts; empty/whitespace rejected; frontmatter-bearing diagrams validated past frontmatter.
11. AC-11: hook denies invalid `.mmd` Write with `MERMAID_VALIDATION_BLOCKED:` naming defect, line, pointer; allows valid.
12. AC-12: hook validates Markdown fences (deny invalid, allow valid, ignore non-Mermaid, allow nested).
13. AC-13: opt-out marker honored for exactly one block; second unmarked invalid block still denied.
14. AC-14: managed-diagram (`id:` frontmatter) hand-edit denied for Edit and Write via mockable on-disk reader seam, `MERMAID_MANAGED_DIAGRAM_BLOCKED:` pointing at sync workflow.
15. AC-15: fail-open on empty/absent/unparseable input, missing `file_path`, out-of-scope paths, unreconstructable Edits; divergence comment present.
16. AC-16: correct block protocol (deny JSON + exit 0, never nonzero, never `{"decision":"block"}`); new contract-suite `It` block; hook count updated.
17. AC-17: negative control — deliberately invalid here-string fixture rejected end-to-end.
18. AC-18: every capability in the mapping table / instruction pack ported or recorded out of scope with reason; no silent drops.
19. AC-19: byte-identical mirrors for every created/modified `.claude` file; resource-contracts suite green.
20. AC-20: `core.json` entry per new file, explicitly including every `references/*.md`; both completeness suites green.
21. AC-21: distribution suites shown capable of failing (before/after evidence).
22. AC-22: hook + modules registered in `CodeCoverage.Path` with issue-#491 comment; new files >= 85% line coverage; no branch gate.
23. AC-23: no Python invocation in hook or library.
24. AC-24: no new third-party dependency.
25. AC-25: Pester purity rules satisfied (here-strings, mocked seams, no temp files, no Start-Process, no sleeps).

### From user-story.md

26. US-1: all four Claude surfaces exist and carry their assigned content. (spec AC-1..AC-4)
27. US-2: validator detects each named defect class and does not reject the enumerated false-positive constructs. (spec AC-5..AC-10)
28. US-3: hook blocks/allows/fence-validates/honors opt-out/blocks managed hand-edit/fails open. (spec AC-11..AC-15)
29. US-4: correct block protocol + contract-suite `It` block. (spec AC-16)
30. US-5: negative control proves the gate can fail. (spec AC-17)
31. US-6: every mapping-table capability ported or recorded out of scope with reason. (spec AC-18)
32. US-7: distribution complete (mirrors + core.json incl. references; three suites green). (spec AC-19..AC-21)
33. US-8: coverage and policy hold (runsettings registration, >= 85% line, no Python leg, no new dependency). (spec AC-22..AC-25)

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC-1 rule file | PASS | `.claude/rules/mermaid.md` (142 lines): frontmatter `paths: **/*.mmd, **/*.mermaid`; conventions, mandate, managed-diagram section, opt-out section all present (reviewer read in full) | `sed -n 1,142p .claude/rules/mermaid.md` | Mirror byte-identical. |
| 2 | AC-2 skill + references | PASS | SKILL.md 184 lines; valid `name`/`description` frontmatter; workflow; exactly eight recipes matching the eight slash-command intents; D6 three-path rendering with file fallback and VS Code preview route; marker docs; "What \"validated\" means here" gate-delta statement; 9 references each pinned to 11.17.0; WebFetch fallback documented with URLs | `wc -l`; `grep -c 11.17.0 references/*.md` (9/9) | |
| 3 | AC-3 hook + registration | PASS | Hook 390 lines; registered in the `Write|Edit` matcher (11th entry, verified by JSON parse of `.claude/settings.json`); `Join-Path $PSScriptRoot '../lib/...'`; `Import-MermaidValidationModule` returns `$false` on absence; read-only NOTES header; `if ($MyInvocation.InvocationName -eq '.') { return }` guard | Python `json.load` matcher check; file read | Registration identical in mirror settings. |
| 4 | AC-4 modules | PASS | 491/488/298/496 lines; `Test-MermaidDiagram` returns `Verdict`/`DiagramType`/`Findings{Class,Line,Message}`/`Warnings`; `MermaidGrammar.psm1` header records 11.17.0 pin, source URL, fetch date | `wc -l`; header inspection | |
| 5 | AC-5 first-line rejection | PASS | Named cases: missing first line, arrow-first, bracket-first, misspelled keyword naming intended keyword | `Invoke-Pester tests/scripts/claude-lib/mermaid/MermaidValidation.Tests.ps1` (green, reviewer run) | |
| 6 | AC-6 brackets/quotes | PASS | Per-class cases (square/round/curly, unterminated quote) with opening-line assertions; quote-aware accepts in the matrix suite | same as above + accept-matrix suite | |
| 7 | AC-7 per-type arrows | PASS | Five per-type reject cases (sequence-in-flowchart, circle-in-sequence, sequence-in-class, single-dash state, bad ER cardinality) | same | Live probes P1/P3 reproduced two of them end-to-end. |
| 8 | AC-8 false-positive matrix | PASS | 22 accept cases; reviewer cross-checked one-for-one against research §4: all eleven constructs present, all eight statement keywords individually tested | `Invoke-Pester .../MermaidValidationAcceptMatrix.Tests.ps1` (green) | Matrix exceeds the catalogue (generics, ER aliases, mid-arrow text). |
| 9 | AC-9 seven fail-open items | PASS | Item 1 (line 383), 2 (405), 3 (416), 6 keyword-accept variant (395), 7 (429) in the validation suite; items 4 and 5 plus fence-nesting item 6 in the hook suite (lines 258–306, 131) | reviewer suite run + live probes P4/P5/P6 | |
| 10 | AC-10 CRLF/empty/frontmatter | PASS | CRLF/LF equivalence for valid and invalid inputs (same verdict and line number); empty/whitespace rejected; `title`/nested-`config`/`id` frontmatter validated past, with body line numbers preserved | reviewer suite run | |
| 11 | AC-11 `.mmd` deny/allow | PASS | Suite cases + live probe P1: deny reason names `UnbalancedBracket at line 2` and the skill pointer; P2 explicit allow | live probes; suite | |
| 12 | AC-12 Markdown fences | PASS | Deny invalid fence with file-relative line ("fence opening at line 3 ... line 5"), allow valid, no-fence untouched, out-of-scope untouched, nested allowed | live probes P3/P5; suite | |
| 13 | AC-13 opt-out scope | PASS | Marker honored (P4), second unmarked block still denied at its own line (P7), blank-line-separated marker not honored (suite line 179) | live probes; suite | Marker cannot reach the managed guard (disjoint code paths); Info note in code review suggests an optional pinning test. |
| 14 | AC-14 managed diagram | PASS | Suite: Edit denied, Write denied even with valid content, seam called exactly once, no-id allowed, missing-file allowed. Live probe P8 denied a real on-disk managed file; P9 allowed after removing `id:` | live probes P8/P9; suite | |
| 15 | AC-15 fail-open + comment | PASS | Suite cases for each input class; hook header carries the DELIBERATE DIVERGENCE paragraph naming `enforce-evidence-locations.ps1` | suite; file read; live probe P6 (exit 0, empty stdout) | |
| 16 | AC-16 block protocol | PASS | Entry-point cases assert compact JSON + exit 0 on deny and allow; contract suite gained the `enforce-mermaid-validation.ps1 emits a PreToolUse deny shape` case; count 14 -> 15 in three places | `git diff 71aebdb9..HEAD -- tests/scripts/claude-hooks/PreToolUseSchema.Contract.Tests.ps1`; reviewer contract-suite run (green) | Never emits `{"decision":"block"}`; grep of hook source confirms. |
| 17 | AC-17 negative control | PASS | Named case `negative control: the gate rejects a deliberately invalid diagram through the decision path` (here-string fixture, line 316); plus `evidence/regression-testing/hook-negative-control.2026-08-20T11-30.md` recording verbatim deny JSON, independently reproduced by reviewer probe P1 | suite run; probe | Observed failure, not asserted. |
| 18 | AC-18 capability completeness | PASS | Reviewer performed the row-by-row cross-check of `.github/instructions/mermaid.instructions.md` (3 LM tools, 16 command IDs, 8 slash commands, 7 rules, sync cooperation) against the rule's out-of-scope table and the skill: every mechanism is ported by substitution or listed with reason; Rule 6 (credit warning) explicitly dispositioned ("nothing to warn about"); Rule 2 (always preview) deliberately weakened to conditional per D6 and recorded | file reads of pack, rule, skill | No silent drops found. |
| 19 | AC-19 byte-identical mirrors | PASS | Reviewer `cmp` over all 17 mirrored files: 17/17 IDENTICAL; resource-contracts pytest green | `cmp` loop; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` | |
| 20 | AC-20 core.json entries | PASS | 16 entries at `core.json:141–156` including all nine `references/*.md`; both completeness suites green (15 Jest, pytest green) | `grep -c mermaid core.json` = 16; Jest + pytest runs | |
| 21 | AC-21 distribution negative controls | PASS | Before-evidence records real exit-1 failures with named failing tests and verbatim missing-file assertions (parity: 1 failed listing the hook; manifest: TS 7 missing paths, Python 2 missing paths); after-state re-run green by reviewer | evidence files + reviewer re-runs | |
| 22 | AC-22 coverage registration + thresholds | PASS | Five `CodeCoverage.Path` entries with issue-#491 comment in both runsettings copies (diff verified); reviewer regenerated coverage at head: 99.30/100/100/98.66/89.04% — all >= 85%; figures identical to the executor's preserved-baseline delta analysis; sourced from the repo-module run, not the MCP tool | `git diff` runsettings; fresh `Invoke-PoshQCTest`; XML parse | Baseline comparison used the preserved copy `evidence/baseline/powershell-coverage.baseline.2026-08-19T10-23.xml`, not the overwritten live path. |
| 23 | AC-23 no Python invocation | PASS | `enforcement-hooks-no-python-invocation.Tests.ps1` green in reviewer run; hook NOTES states "invokes no Python and starts no subprocess" | reviewer Pester run | |
| 24 | AC-24 no new dependency | PASS | `git diff 71aebdb9..HEAD --name-only -- package.json extensions/drm-copilot/package.json pyproject.toml` empty (no manifest in the 92-file diff) | diff inspection | |
| 25 | AC-25 test purity | PASS | Grep over the new suites for temp files, `Start-Process`, sleeps, filesystem writes: zero hits; all fixtures are here-strings; on-disk reads mocked via `Get-MermaidOnDiskContent`; executor's `test-purity-check.2026-08-20T11-45.md` concurs | grep; evidence file | The 3 subprocess protocol cases spawn `pwsh` per the established hook contract-test precedent. |
| 26 | US-1 four surfaces | PASS | = AC-1..AC-4 | see rows 1–4 | |
| 27 | US-2 defect classes + false positives | PASS | = AC-5..AC-10 | see rows 5–10 | |
| 28 | US-3 hook behaviors | PASS | = AC-11..AC-15 | see rows 11–15 | |
| 29 | US-4 block protocol | PASS | = AC-16 | see row 16 | |
| 30 | US-5 negative control | PASS | = AC-17 | see row 17 | |
| 31 | US-6 capability completeness | PASS | = AC-18 | see row 18 | |
| 32 | US-7 distribution | PASS | = AC-19..AC-21 | see rows 19–21 | |
| 33 | US-8 coverage and policy | PASS | = AC-22..AC-25 | see rows 22–25 | |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 33 criteria (25 spec + 8 user-story)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Optional (non-blocking, from the code review): add one Pester case pinning that the opt-out marker cannot suppress the managed-diagram guard, so the structural property survives future refactors.
2. On merge, the recorded follow-ups remain open by design: emitter retrofit (`mermaid_label`/`mermaidLabel` escaping), optional CI-side `mmdc` deep check, Codex-surface port (spec `## Out of Scope` items 4, 5, 8).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

All 25 spec.md criteria and all 8 user-story.md criteria were already checked (`[x]`) by the executor at delivery time. This audit independently re-verified each and confirms every check-off is supported by evidence; no source-file change was made by the reviewer because no unchecked PASS item and no unsupported checked item exists.

### AC Status Summary

- Source: `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/spec.md`, `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/user-story.md`
- Total AC items: 33 (25 spec + 8 user-story)
- Checked off (delivered): 33
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 25 | 25 | 0 | Checkbox-backed; all verified by this audit |
| `user-story.md` | 8 | 8 | 0 | Checkbox-backed; story-level rollups of the spec set |

No source-file checkbox change was made: every PASS criterion was already checked, and the audit found no checked item lacking evidence.
