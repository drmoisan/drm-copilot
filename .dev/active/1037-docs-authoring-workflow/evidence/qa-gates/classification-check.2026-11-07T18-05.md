# Classification Check at the Merged Head (remediation [P3-T2])

Timestamp: 2026-11-07T18-05
Command: sh SCRATCH/issue-1037-classification-r2.sh (runs SCRATCH/issue-1037-classification-r2.ps1, the script of main plan [P7-T7]: derives the branch file list as `git diff --name-only --no-renames` from the merge base of `origin/epic/documentation-estate-tooling-integration` and `HEAD`, united with every path in `git status --porcelain --untracked-files=all`; expands each `## Artifact Classification` row of the main plan over the Named Sets; compares the two)
EXIT_CODE: 0
Output Summary: Acceptance met. The merge base now resolves to the fetched integration tip. 203 branch paths (202 from the anchored diff, 2 from porcelain status, de-duplicated: the modified remediation plan and the new scope-check artifact). 12 file-bearing rows expand to 145 paths with 0 paths in two rows; 0 row paths absent from the tree; 0 row paths missing from the branch list; 0 branch paths covered by no row. The `<FEATURE>/**` row covers the remaining 58 paths (145 + 58 = 203).

## Row expansion

| Row | Paths |
|---|---|
| Copilot agents and bundle copies | 8 |
| Claude agents and bundle copies | 8 |
| Codex agents and bundle copies | 8 |
| Skills, six roots | 48 |
| Templates, six roots | 48 |
| Hooks and bundle copies | 6 |
| Settings copies | 2 |
| Routing copies | 3 |
| Pack manifests | 2 |
| Hook suites | 3 |
| Structural suites and helper (includes the edited `docs-authoring-roles.Skills.Tests.ps1`) | 6 |
| Edited guard suites | 3 |
| `<FEATURE>/**` | 58 |

Compared with `classification-check.2026-11-07T17-19.md` (183 paths, 38 under `<FEATURE>/`), the 145 row paths are unchanged and the 20 added paths are the review artifacts, remediation inputs and plan, and the remediation evidence under `<FEATURE>/`.
