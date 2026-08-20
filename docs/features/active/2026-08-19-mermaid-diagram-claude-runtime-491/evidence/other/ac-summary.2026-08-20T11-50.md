# Acceptance Criteria Status Summary (issue #491, [P7-T14])

Timestamp: 2026-08-20T11-50

Work Mode: `full-feature` (per the `issue.md` marker), so both `spec.md` and `user-story.md` are AC
sources and were tracked independently.

### Acceptance Criteria Status

- Source: `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/spec.md`
- Total AC items: 36 (25 numbered AC-1..AC-25, 7 Definition of Done, 4 Seeded Test Conditions)
- Checked off (delivered): 36
- Remaining (unchecked): 0
- Items remaining: none

- Source: `docs/features/active/2026-08-19-mermaid-diagram-claude-runtime-491/user-story.md`
- Total AC items: 8
- Checked off (delivered): 8
- Remaining (unchecked): 0
- Items remaining: none

## Per-criterion evidence (spec.md AC-1 through AC-25)

| AC | Evidence |
| --- | --- |
| AC-1 | `.claude/rules/mermaid.md`, 142 lines, frontmatter `paths: ["**/*.mmd", "**/*.mermaid"]` plus `description`; body carries the file conventions, the validation mandate, the managed-diagram constraint, and the opt-out marker rules |
| AC-2 | `.claude/skills/mermaid-diagram/SKILL.md`, 184 lines (under the 500-line body ceiling), `name: mermaid-diagram` plus keyword-rich description; workflow, eight recipes, D6 rendering paths, opt-out documentation, the "what validated means" delta, and nine `references/*.md` pinned to 11.17.0 with the `WebFetch` fallback |
| AC-3 | `.claude/hooks/enforce-mermaid-validation.ps1`, 390 lines; registered in the `Write|Edit` matcher (11 hooks in that block now); `$PSScriptRoot`-relative import with a `Test-Path` guard that fails open; read-only-gate header and dot-sourcing guard present |
| AC-4 | Four modules under `.claude/lib/mermaid/`, 491/488/298/496 lines; `Test-MermaidDiagram` returns `Verdict`/`DiagramType`/`Findings`(Class,Line,Message)/`Warnings`; the 11.17.0 pin and the mermaid.js.org source URL are in the grammar module header and returned by `Get-MermaidGrammarSourceUrl` |
| AC-5 | `MermaidValidation.Tests.ps1` context "first-line keyword defects": missing first line, arrow-leading line, bracket-leading line, and `flowchar TD` rejected as `MisspelledDiagramType` naming `flowchart` |
| AC-6 | Same suite, context "bracket balance and quote termination": one case per bracket class plus the unterminated-quote case, each asserting the finding line |
| AC-7 | Same suite, context "per-type invalid arrow tokens": five cases, one per deep-checked type, each asserting `InvalidArrowToken` at the expected line |
| AC-8 | `MermaidValidationAcceptMatrix.Tests.ps1`, 22 passing accept-cases; row-by-row cross-check in `evidence/other/accept-matrix-crosscheck.2026-08-20T10-07.md` shows all eighteen research section 4 rows covered, none missing |
| AC-9 | Items 1, 2, 3, 7 in the lib suite context "fail-open policy"; items 4, 5, 6 in the hook suite contexts "fail-open policy" and "Markdown fence gate" (Edit payload, unparseable input, nested fence) |
| AC-10 | Lib suite context "line endings and frontmatter": CRLF/LF verdict and line-number equality for a valid and an invalid diagram, empty and whitespace rejection, and `title`/`config`/`id` frontmatter validated past |
| AC-11 | Hook suite context "diagram-file syntax gate": deny naming `InvalidArrowToken`, line 3, and the SKILL.md pointer; allow for the valid write |
| AC-12 | Hook suite context "Markdown fence gate": invalid denied with a file-relative line, valid allowed, non-Mermaid Markdown allowed, out-of-scope path untouched, nested fence allowed |
| AC-13 | Hook suite context "opt-out marker scope": marked block allowed, second unmarked block still denied, marker separated by a blank line not honoured |
| AC-14 | Hook suite context "managed-diagram gate": deny for Edit and for Write with `MERMAID_MANAGED_DIAGRAM_BLOCKED:`, via `Mock -CommandName Get-MermaidOnDiskContent`, plus a case asserting the seam is called exactly once |
| AC-15 | Hook suite context "fail-open policy": empty, absent, unparseable, missing `file_path`, empty `file_path`, Edit payload, and out-of-scope path all allow; the DELIBERATE DIVERGENCE comment in the hook header records why this differs from `enforce-evidence-locations.ps1` |
| AC-16 | Hook suite context "script entrypoint (end-to-end)": compact single-line JSON and exit 0 on deny, on allow, and on silent allow; the new `It` in `PreToolUseSchema.Contract.Tests.ps1` asserts the round-tripped deny shape and all three hardcoded counts read 15 |
| AC-17 | Named case "negative control: the gate rejects a deliberately invalid diagram through the decision path", plus the live end-to-end run in `evidence/regression-testing/hook-negative-control.2026-08-20T11-30.md` |
| AC-18 | `evidence/other/capability-completeness.2026-08-20T11-08.md` (written 11-05): 42 named mechanisms, 42 dispositions, 0 silent drops; the out-of-scope record is in both the rule and the skill |
| AC-19 | 16 byte-identical mirrors verified by `cmp`; `test_push_down_claude_resource_contracts.py` green (10 passed) at [P5-T11] and [P7-T7], failing before the mirrors at [P5-T1] |
| AC-20 | 16 `core.json` entries including one per `references/*.md`, each confirmed by search in `evidence/other/core-json-references-verification.2026-08-20T11-22.md`; both completeness suites green |
| AC-21 | Before/after pairing recorded in `evidence/regression-testing/distribution-negative-control-parity.*`, `distribution-negative-control-manifest.*`, and `distribution-after.*`: each of the three gates observed failing for this change, then passing |
| AC-22 | Five `CodeCoverage.Path` entries with the issue-#491 comment in `pester.runsettings.psd1`; per-file line coverage 99.30 / 100.00 / 100.00 / 98.66 / 89.04 percent, all above 85; `evidence/qa-gates/coverage-delta.2026-08-20T11-40.md` |
| AC-23 | `enforcement-hooks-no-python-invocation.Tests.ps1` green (27 passed) with the new hook and all four modules inside the guarded tree; no allowlist entry added |
| AC-24 | `git diff main --name-only` over the three dependency manifests produced empty output |
| AC-25 | `evidence/qa-gates/test-purity-check.2026-08-20T11-45.md`: the purity hook's decision function replayed over all seven test files returns allow for each; `PURITY_VIOLATIONS: 0` |

## Definition of Done (7 items)

All seven checked. Notes on two of them:

- "Behavior matches acceptance criteria in all documented environments" — the exercised environment
  is PowerShell 7 on Windows in this worktree, which is the only environment the spec documents for
  this surface. No other environment was exercised, and none is claimed.
- "Toolchain pass completed in a single pass" — the Phase 7 loop passed format, analyze, and test
  clean in one pass. Earlier loops restarted (Phase 2 once for BOM findings, Phase 3 once for verb
  findings); each restart is recorded in that phase's toolchain artifact.

## Seeded Test Conditions (4 items)

All four checked: validator unit coverage, hook unit coverage, parity, and the negative control.
Each maps to the evidence listed for AC-5..AC-10, AC-11..AC-15, AC-19..AC-21, and AC-17
respectively.

## user-story.md (8 story-level criteria)

All eight checked. They aggregate the spec ranges as written in the story text: surfaces
(AC-1..AC-4), validator detection and false-positive safety (AC-5..AC-10), hook behavior
(AC-11..AC-15), block protocol (AC-16), negative control (AC-17), capability completeness (AC-18),
distribution (AC-19..AC-21), and coverage and policy (AC-22..AC-25). The evidence is the same as the
per-criterion rows above.
