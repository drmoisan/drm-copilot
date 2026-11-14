# Remediation Inputs - issue #1019 (cycle 2, related review rows)

Remediation-Mode: proportionate

Source: `code-review.2026-11-06T21-29.md`, `## Findings Table`. That review's verdict is PASS with zero findings that stop the item. This cycle exists under the owner's standing instruction that related non-gating review rows are fixed inside the item before merge. It adds no acceptance criterion and re-opens none; AC-8 stays unchecked and pending-CI.

Branch: `bug/docs-tokenizer-scaling-1019`. Base: `origin/epic/documentation-estate-tooling-integration`. MERGE_BASE is the output of `git merge-base origin/epic/documentation-estate-tooling-integration HEAD`.

## Rows In Scope

### R1 - Guard does not pin the window size value

- Severity: Minor
- File: `tests/scripts/claude-lib/docs/DocsPythonTokens.Tests.ps1`, `Describe 'Get-DocsPythonToken structural scaling guard'`
- Evidence: mutant `size-constant-huge` (constant at 1073741824) passes 57 of 57.
- Required change: add an AST assertion in the guard describe that `$script:DocsPythonTokenWindowSize` is assigned exactly once at module scope from an integer literal no greater than 65536. Keep the new lines outside the candidate suite hunks, with at least one unchanged base line between.

### R2 - Window predicate does not select a typed left side

- Severity: Info
- File: same describe, `It 'assigns the lexing window only from a Substring of the source text'`
- Evidence: mutant `typed-evasion` (`[string] $source = $sourceText.Substring($windowStart)`) passes 57 of 57.
- Required change: unwrap `ConvertExpressionAst` on the left side so a typed `$source` assignment is selected and judged by the same predicate.

### R3 - Plan status header is stale

- Severity: Info
- File: `docs/features/active/2026-11-06-docs-tokenizer-scaling-1019/remediation-plan.2026-11-06T18-47.md`
- Required change: set the header `Status` to reflect completed execution.

## Verification

- Guard run against the unfixed, candidate, fixed, and mutant trees plus one mutant per row R1 and R2, recorded in a new `evidence/regression-testing/guard-fail-before.<timestamp>.md`: each R1 and R2 mutant fails its case, and the fixed tree fails none.
- Candidate hunk identity, format, analyzer, `SUITE`, the shuffled isolation run, and the docs folder coverage run pass, with new evidence artifacts.
- `MODULE` and `BUNDLE` are not edited and keep SHA-256 `015c38363874b798b35ea2afae62c276f346199047337890e661d84927d77702`.

## Rows Out of Scope

- `DocsCSharpTokens.psm1` Minor row: outside this item per `issue.md` and the delegation scope; held in the checkpoint `follow_ups`.
- Info rows requiring no action: `no-string-reset`, `margin-3`, the self-review merge base record, and the closing-keyword note.

## Do Not Do

- Do not weaken a guard or boundary case, or lower a threshold.
- Do not edit `MODULE`, `BUNDLE`, candidate lines in `SUITE`, or any policy document.
- Do not add a Python file. New helpers are PowerShell under `SCRATCH`.
