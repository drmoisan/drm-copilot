# Remediation inputs (cycle 1) - issue #884

Source review: policy-audit, code-review and feature-audit stamped 2026-10-16T00-46 in this folder. All three are PASS with zero blocking findings. The four items below are non-blocking findings in the same files and the same feature, fixed inside this item per the run rules. Finding 5 of the review (closing comment not yet posted) is handled by the PR body keyword `Closes #884` and is not a file change.

Scope: documentation files inside `docs/features/active/untouched-files-coverage-verification-884/` only. No production, test, config or bundled file changes.

## Findings

1. final-diff-scope and branch-diff-scope record a pre-commit snapshot (diff N=4). The pushed head differs from origin/main in 14 committed paths. Append a post-commit section to `evidence/qa-gates/final-diff-scope.2026-10-16T00-39.md` stating the post-commit `git diff --name-only origin/main...HEAD` count and that every path is under the feature folder. Evidence artifacts are append-only here; do not rewrite earlier recorded values.
2. The plan header `plan.2026-10-15T07-41.md` still says `Status: Draft` and `Last Updated: 2026-10-15T07-41` although all 23 tasks are checked. Set Status to Complete and update Last Updated to the edit time.
3. `evidence/baseline/phase0-instructions-read.2026-10-16T00-26.md` and `evidence/issue-updates/issue-884.2026-10-16T00-37.md` lack the `Command:`, `EXIT_CODE:` and `Output Summary:` fields that the plan rule says every evidence artifact carries. Add those three fields to each file with truthful values (the Command is the read or write action performed; EXIT_CODE 0 only where an action was observed to succeed).
4. `research/research.2026-10-15T07-50.md` proposes AC1 to AC6 and describes issue.md and the plan as unfilled templates, while `issue.md` carries five different criteria. Add a short note at the top of the research file stating that the acceptance criteria in issue.md AC1 to AC5 supersede the proposal in this document and that the template statements are historical.

## Constraints

- Do not alter the CI figures, the cited file:line records, or any checked AC box.
- Keep the plan task checkboxes as they are.
