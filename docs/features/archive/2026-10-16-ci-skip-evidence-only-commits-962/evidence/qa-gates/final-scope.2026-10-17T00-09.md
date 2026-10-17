# Final QA pass 1: scope and dependency re-check (P6-T10) — re-integration required

Timestamp: 2026-10-17T00-09
Command: git fetch origin
EXIT_CODE: 0
Output Summary: The dependency re-check found that origin/main advanced from 475bb06d5 to b8fcd7790 (merge of PR #965, issue #952), which adds the `merge_group` trigger to ci.yml. RECHECK-DEP-952: present differs from DEP-952: absent in dependency-state.2026-10-16T23-21.md, so DEPENDENCY-RECHECK: CHANGED. Per P6-T10 the task is not checked off and this is not a loop failure; rule 17 applies. CR-SCOPE and CR-ONBLOCK were not run in this pass because the task hands off to rule 17 at this point; they run in the post-re-integration loop. A read-only `git merge-tree --write-tree --name-only HEAD origin/main` printed only a tree id (no conflicted path).

## Commands and exit codes

- `git fetch origin` EXIT_CODE: 0 (no output)
- `git rev-parse origin/main` EXIT_CODE: 0 -> `b8fcd77905a51284cfbca54226a2da2a7916a836`
- `git rev-parse origin/bug/ci-merge-queue-for-main-952` EXIT_CODE: 0 -> `5c8fff171a45ef042f878170de8765ef49c02db9`
- `git rev-parse origin/bug/pester-profiler-coverage-953` EXIT_CODE: 0 -> `9285674cfc95b01ba1a5c8eca2216e58d61c2b2d`
- `git grep -c -E -e '^  merge_group:[[:space:]]*$' origin/main -- .github/workflows/ci.yml` EXIT_CODE: 0 -> `origin/main:.github/workflows/ci.yml:1`
- `git grep -c -E -e '^  poshqc-shard:[[:space:]]*$' origin/main -- .github/workflows/_poshqc.yml` EXIT_CODE: 0 -> `origin/main:.github/workflows/_poshqc.yml:1`
- `git grep -c -E -e '^  poshqc-static:[[:space:]]*$' origin/main -- .github/workflows/_poshqc.yml` EXIT_CODE: 0 -> `origin/main:.github/workflows/_poshqc.yml:1`
- `git grep -c -E -e '^    name: PowerShell QC[[:space:]]*$' origin/main -- .github/workflows/_poshqc.yml` EXIT_CODE: 0 -> `origin/main:.github/workflows/_poshqc.yml:1`

## Derived lines

TOKEN-merge_group: present (1)
TOKEN-poshqc-shard: present (1)
TOKEN-poshqc-static: present (1)
TOKEN-PowerShell QC: present (1)
RECHECK-DEP-952: present
RECHECK-DEP-953: present
DEPENDENCY-RECHECK: CHANGED
REINTEGRATION-REQUIRED: rule 17

## Supplementary read-only observations

- `git log --oneline 475bb06d5..origin/main` lists `b8fcd7790 Merge pull request #965 from drmoisan/bug/ci-merge-queue-for-main-952` at the tip.
- `git diff 475bb06d5 origin/main -- .github/workflows/README.md .github/workflows/ci.yml`: the README Triggers section gains the merge_group bullet ("three" -> "four" triggers); ci.yml gains `  merge_group:` / `    types: [checks_requested]` in the on: block. Neither region is edited by this plan.
- `git merge-tree --write-tree --name-only HEAD origin/main` EXIT_CODE: 0 -> `451ada4166ed9473d2d05d4bfde47985c6d54b5c` (no conflicted paths).
