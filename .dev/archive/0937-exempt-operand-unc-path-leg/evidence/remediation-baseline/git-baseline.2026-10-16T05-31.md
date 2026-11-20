# Git Baseline, Remediation Cycle 1 (issue #937)

Timestamp: 2026-10-16T05-31
Task: P0-T7 (remediation-plan.2026-10-16T03-39.md)
Command: git fetch origin main; git rev-parse --abbrev-ref HEAD; git rev-parse HEAD; git rev-parse origin/main; git merge-base HEAD origin/main; git merge-base --is-ancestor origin/main HEAD; git status --porcelain
EXIT_CODE: 0
Output Summary: Branch bug/exempt-operand-unc-path-leg-937 at aa733fcc3. origin/main (5bc97774b) is not an ancestor of HEAD (is-ancestor exit 1); merge base ba53ff569. Porcelain lists only FEATURE paths (this plan file and the new remediation-baseline folder).

| Command | Output |
|---|---|
| `git fetch origin main` | exit 0 (`* branch main -> FETCH_HEAD`) |
| `git rev-parse --abbrev-ref HEAD` | `bug/exempt-operand-unc-path-leg-937` |
| `git rev-parse HEAD` | `aa733fcc3bd386e73909f4e2333a08e8f86cb1db` |
| `git rev-parse origin/main` | `5bc97774b8322e57abb94dfac3cd0a000a136c5b` |
| `git merge-base HEAD origin/main` | `ba53ff5694a42e975d5d1db99b2b6ef505143e66` |
| `git merge-base --is-ancestor origin/main HEAD` | exit 1 (origin/main has advanced past the merge commit `316857900`; the rebase before the PR is the orchestrator's step) |

`git status --porcelain`:

```text
 M docs/features/active/exempt-operand-unc-path-leg-937/remediation-plan.2026-10-16T03-39.md
?? docs/features/active/exempt-operand-unc-path-leg-937/evidence/remediation-baseline/
```
