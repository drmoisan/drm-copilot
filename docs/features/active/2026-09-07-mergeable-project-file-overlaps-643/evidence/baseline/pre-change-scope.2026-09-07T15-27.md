# Baseline — pre-change scope (issue #643, task [P0-T15])

- Timestamp: 2026-09-07T15:27Z
- Command: `git merge-base c3ffb080 HEAD`, `git diff c3ffb080 --name-only`, and `git status --porcelain --untracked-files=all` (all run from the worktree root)
- EXIT_CODE: 0

`c3ffb080` is the merge base of `feature/mergeable-project-file-overlaps-643` with `origin/main`
(the branch was rebased onto it), so the anchored diff is stable if `origin/main` advances.

## `git merge-base c3ffb080 HEAD` (verbatim)

```text
c3ffb0800386124b10fe8c0e287f510d302a5728
```

The printed value is `c3ffb080` followed by its remaining hexadecimal digits.

## `git diff c3ffb080 --name-only` (verbatim)

```text
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/other/preflight-round-1.2026-09-07T13-38.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/other/preflight-round-2.2026-09-07T14-20.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/other/preflight-round-3.2026-09-07T14-45.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/other/preflight-round-4.2026-09-07T15-05.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/issue.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/plan.2026-09-07T08-13.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/research/2026-09-07T09-45-mergeable-project-file-overlaps-research.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/spec.md
docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/user-story.md
docs/features/potential/promoted/2026-09-07-mergeable-project-file-overlaps.md
```

## `git status --porcelain --untracked-files=all` (verbatim)

```text
 M docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/plan.2026-09-07T08-13.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/edit-target-line-counts.2026-09-07T15-10.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/npm-ci-extension.2026-09-07T15-09.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/phase0-instructions-read.2026-09-07T15-07.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/powershell-poshqc-analyze.2026-09-07T15-22.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/powershell-poshqc-format.2026-09-07T15-21.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/powershell-poshqc-test.2026-09-07T15-25.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/python-black.2026-09-07T15-11.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/python-pyright.2026-09-07T15-13.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/python-pytest-coverage.2026-09-07T15-15.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/python-ruff.2026-09-07T15-12.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/typescript-eslint.2026-09-07T15-17.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/typescript-jest-coverage.2026-09-07T15-20.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/typescript-prettier.2026-09-07T15-16.md
?? docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/baseline/typescript-typecheck.2026-09-07T15-18.md
```

## Output Summary

The anchored diff lists ten tracked paths. Six of them are the enumerated feature documents and the
promotion record:

- `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/issue.md`
- `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/plan.2026-09-07T08-13.md`
- `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/spec.md`
- `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/user-story.md`
- `docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/research/2026-09-07T09-45-mergeable-project-file-overlaps-research.md`
- `docs/features/potential/promoted/2026-09-07-mergeable-project-file-overlaps.md`

All six are present in the listing. The remaining four are the preflight reports of rounds 1
through 4, each under
`docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/other/`, and are
admitted by the evidence-folder clause of the acceptance condition. The plan text anticipated nine
tracked paths (rounds 1 through 3) because it was revised before the round-4 report was committed;
the tenth path is the round-4 report, which the same clause admits. This artifact records the
listing verbatim and does not restate it as exactly the six enumerated paths.

The porcelain listing carries one modified path (the plan file, which this execution checks tasks
off in) and fourteen untracked paths, all of which lie under
`docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/`.

No path in either listing lies outside the admitted set: every path is one of the six enumerated
above or lies under
`docs/features/active/2026-09-07-mergeable-project-file-overlaps-643/evidence/`.
