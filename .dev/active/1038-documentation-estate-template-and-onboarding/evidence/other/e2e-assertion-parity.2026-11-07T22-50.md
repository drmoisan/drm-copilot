# End-to-end suite assertion parity after D-3a ([P3-T2])

Timestamp: 2026-11-07T22-50
Command: sh SCRATCH/issue-1038-parity.sh (git show REVIEW-HEAD:tests/scripts/claude-lib/docs/EndToEndDocumentationEstate.Tests.ps1 to a scratch copy; for the REVIEW-HEAD copy and the working file: grep -F "Should " | sed strip leading whitespace | sort; diff of the two sorted lists)
EXIT_CODE: 0
Output Summary: the sorted multiset of `Should` lines is identical before and after the restructuring (25 lines each, diff exit 0, no differing line).

REVIEW-HEAD derivation: `git log --grep="^docs(features): record the #1038 feature review" -n 1` on the branch, subject `docs(features): record the #1038 feature review and cycle 1 inputs`.

ASSERTIONS-BEFORE: 25
ASSERTIONS-AFTER: 25
DIFFERENCES: 0

Structural checks on the working file:

- `It` blocks: 10, with names unchanged.
- `Context` blocks: 4 (`baseline at revision R1`, `defects at revision R2`, `fixes at revision R2`, `inventory without a revision`).
- `Invoke-EstateScenario -Through` calls: 4, one in each `Context` `BeforeAll`.
- `SuppressMessageAttribute`: 1, for `PSUseDeclaredVarsMoreThanAssignments`, on the file-level `param()` block after the comment-based help.
- `$script:` assignments in a `Context` `BeforeAll`: 0.
- `Invoke-ScriptAnalyzer` with `scripts/powershell/PoshQC/settings/pssa.settings.psd1`: Error 0, Warning 0, Information 0, ParseError 0; `Invoke-Formatter`: no difference.
