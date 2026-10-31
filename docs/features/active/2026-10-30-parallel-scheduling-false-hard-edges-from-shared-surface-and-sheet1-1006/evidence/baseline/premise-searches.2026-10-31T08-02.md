# Premise Searches (issue #1006)

Timestamp: 2026-10-31T08-02
Task: P0-T4

## Search (a): inline-code sheet or chart stem tokens

Command: git grep -n -i -E '`(sheet|chart)[0-9]+`' -- . ':!FEATURE' ':!docs/features/potential/promoted'
EXIT_CODE: 1 (git grep exit 1 means no match)
SearchScope: the tracked tree, excluding `FEATURE` and `docs/features/potential/promoted/`
SearchPatterns: case-insensitive extended regex for an inline-code token consisting of `Sheet` or `Chart` followed by one or more digits
SearchResult: none

## Search (b): TypeScript or bash contract extractor

Command: git grep -n -E 'CONTRACT_LETTER_RE|ContractLetterPattern|ContractHeading|CONTRACT_HEADING' -- extensions/drm-copilot/src .claude/lib/bash; git grep -n -i -E '(api|interface).{0,20}contract.{0,20}surface' -- extensions/drm-copilot/src .claude/lib/bash
EXIT_CODE: 1 (both searches; no match)
SearchScope: `extensions/drm-copilot/src`, `.claude/lib/bash`
SearchPatterns: `CONTRACT_LETTER_RE`, `ContractLetterPattern`, `ContractHeading`, `CONTRACT_HEADING`, and a contract-heading keyword list (`API`/`Interface` ... `Contract` ... `Surface`)
SearchResult: none

Output Summary: both premises hold. No existing recorded or citable contract token in the tree is a generic sheet or chart name, and neither TypeScript nor bash extracts contracts. No premise change before Phase 1.
