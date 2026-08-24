# Resume Defect Remediation (issue #491)

Timestamp: 2026-08-20T09-57

Context: execution of `plan.2026-08-19T08-50.md` was interrupted mid-Phase-2 by an
organization spend-limit API error. Two defects were present in the work already on disk at
resume. Both were corrected before continuing at [P2-T1]. Neither correction changes the plan.

## Defect 1 — missing export broke one test

- Symptom: `tests/scripts/claude-lib/mermaid/MermaidGrammar.Tests.ps1` case
  "records the documentation source URL in the accessor" failed with
  `CommandNotFoundException` for `Get-MermaidGrammarSourceUrl`.
- Cause: the accessor did not exist in `.claude/lib/mermaid/MermaidGrammar.psm1`; only the
  header comment carried the source URL.
- Correction: added `$script:MermaidGrammarSourceUrl` and the exported accessor
  `Get-MermaidGrammarSourceUrl`, returning
  `https://mermaid.js.org/intro/syntax-reference.html`.

Command: `pwsh -NoProfile -Command "Invoke-Pester -Path tests/scripts/claude-lib/mermaid/ -Output Normal"`
EXIT_CODE: 0
Output Summary: Tests Passed: 206, Failed: 0, Skipped: 0. Before the fix the same command
reported 205 passed, 1 failed, 206 total.

## Defect 2 — 500-line limit violation

- Symptom: `.claude/lib/mermaid/MermaidGrammar.psm1` was 563 lines, over the 500-line hard
  limit in `.claude/rules/general-code-change.md`. A `.psm1` data module is not one of that
  rule's exemptions (throwaway scripts, raw text fixtures, Markdown docs).
- Correction chosen: COMPACT THE DATA REPRESENTATION; the module was not split.
  - The 27 keyword-accept diagram types were moved out of the hand-written per-entry form into
    two compact name-to-keywords maps (verified and unverified tiers) expanded by one loop into
    the same table shape, because every one of them shares a single fixed shape (keyword-checked
    only, brackets never structural, no arrow grammar).
  - The three keyword-accept types whose documentation lists edge tokens keep those tokens as
    reference data in an explicit three-line block after the loop, so no grammar data was lost.
  - The five deep entries were reflowed from eight lines to five each; the export list was
    reflowed from a 17-line backtick continuation to a 7-line array.
  - Header prose and two guard-block families were tightened. Single-line
    `if (...) { return ... }` guards follow the existing repo convention
    (`.claude/hooks/validate-feature-review-coverage.ps1`).
- Result: 491 lines. No module was added, so the five-production-file count the plan computes
  (P3-T6 coverage registration, the P5 mirror batches, the `core.json` entries, and P7-T5's
  acceptance) is unchanged and no dependent plan arithmetic required amendment.
- Rationale for compaction over splitting: the module is keyword tables and arrow-token sets,
  which compact without loss of readability, and splitting would have required coherent edits to
  the coverage registration, both mirror batches and their budget arithmetic, the manifest
  entries, and four separate "five files" statements in the plan.

## Defect 3 (found during remediation) — three PSScriptAnalyzer findings

- Symptom: `mcp__drm-copilot__run_poshqc_analyze` reported 3 issues, all
  `PSUseShouldProcessForStateChangingFunctions`, against Phase-2 files written by the
  interrupted run: `Get-MermaidQuotePrefix`-era names `Remove-MermaidQuotePrefix`
  (MermaidMarkdownFences.psm1), `New-MermaidFinding` and `New-MermaidResult`
  (MermaidValidation.psm1).
- Correction: renamed to non-state-changing verbs rather than adding `SupportsShouldProcess` to
  pure functions or suppressing the rule. `Remove-MermaidQuotePrefix` became
  `Get-MermaidUnquotedLine`; `New-MermaidFinding` became `Get-MermaidFinding`;
  `New-MermaidResult` became `Get-MermaidResult`. The precedent for a `Get-` prefixed pure
  factory is `Get-PowerShellBatchBudgetState` in
  `.claude/hooks/enforce-powershell-batch-budget.ps1`.
- All call sites and the one affected test file were updated in the same pass.

Command: `mcp__drm-copilot__run_poshqc_analyze`
EXIT_CODE: 0
Output Summary: ok:true — zero PSScriptAnalyzer findings. Before the rename the same call
returned ok:false with "PSScriptAnalyzer reported 3 issue(s)."

Command: `mcp__drm-copilot__run_poshqc_format`
EXIT_CODE: 0
Output Summary: ok:true; no file was modified by the formatter (line counts unchanged
before and after).
