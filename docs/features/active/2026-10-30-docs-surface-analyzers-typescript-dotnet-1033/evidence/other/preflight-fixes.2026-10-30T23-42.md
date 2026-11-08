# Preflight Fixes

Timestamp: 2026-10-30T23-42
Plan: docs/features/active/2026-10-30-docs-surface-analyzers-typescript-dotnet-1033/plan.2026-10-30T18-39.md

## Fix 1 — `## Execution Context` (`MERGE_BASE`)

- Defect class: validator-blind defect (scope-diff anchor state); the correction keeps the assertion's meaning.
- Finding: `MERGE_BASE` was the merge base of `origin/main` and `HEAD`. This item branch targets `epic/documentation-estate-tooling-integration`, so a diff from that base lists every file merged into the integration branch by other children. Child 900011 (Python) and 900007 (TypeScript) can merge into the integration branch before this item executes (epic A1), and [P7-T8] would then find `.py` or `.ts` paths that this feature did not add.
- Change: `MERGE_BASE` is now the merge base of `origin/epic/documentation-estate-tooling-integration` and `HEAD`. The assertions of [P0-T5], [P7-T8] and [P7-T12] are unchanged: they still state that this feature adds no Python, TypeScript or discovery path and that every changed path is classified.

## Fix 2 — [P0-T5]

- Defect class: typo (count).
- Finding: the task referred to "the ten module names" of `## Artifact Classification`, which lists eleven new module names, one of them conditional (`DocsTypeScriptJsx.psm1`).
- Change: the task now says the eleven new module names, including the conditional `DocsTypeScriptJsx.psm1`.

## Fix 3 — `### Phase 3 — TypeScript Analyzers` (common analyzer paragraph)

- Defect class: stale anchor whose intent is unambiguous.
- Finding: the paragraph cited a spec heading `#### Common analyzer rules`. The spec has no such heading; the rules are the `Common analyzer rules:` list under `### Analyzer functions (pure; 1020 analyzer contract)`.
- Change: the citation now names that list under that heading.

## Fix 4 — [P1-T2] and [P6-T1]

- Defect class: citation correction (incomplete heading).
- Finding: both tasks cited spec `### Registry rows`; the heading is `### Registry rows (edit of \`DocsAnalyzerRegistry.psm1\`)`.
- Change: both citations now use the full heading.

## Fix 5 — [P6-T1] (existing-test search)

- Defect class: validator-blind defect (tests asserting changed behavior); the correction keeps the assertion's meaning.
- Finding: adding registry rows changes the output of `Select-DocsAnalyzerRegistration` (element-kind selection now returns the new rows) as well as `Get-DocsAnalyzerRegistration`. The search tokens did not include `Select-DocsAnalyzerRegistration`, so a suite that asserts selection results would not be found and given a disposition.
- Change: `Select-DocsAnalyzerRegistration` is added to the search tokens. The recording requirement (every match with its disposition) is unchanged.
