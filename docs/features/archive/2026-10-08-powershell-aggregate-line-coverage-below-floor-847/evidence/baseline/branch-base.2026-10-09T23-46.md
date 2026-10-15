# Branch Base (Issue #847)

Timestamp: 2026-10-09T23-46
Task: [P0-T2]
Command: `git rev-parse HEAD`; `git rev-parse --verify origin/main`; `git merge-base HEAD origin/main`; `git diff --name-only 460cd755de560b733be0c471d1d144e553fbe0e5 HEAD`; `git status --porcelain=v1 --untracked-files=all` (each run as a separate `git -C <worktree>` command because the worktree isolation guard refuses chained git commands)
EXIT_CODE: 0
Output Summary:
- HEAD: c04940465584cedb9df7f85efd17b64dfc56870d
- origin/main: 460cd755de560b733be0c471d1d144e553fbe0e5 (resolves)
- BASE_SHA (merge-base HEAD origin/main): 460cd755de560b733be0c471d1d144e553fbe0e5
- Diff paths: 5 (all under `docs/features/`); Status paths: 1 (feature evidence file)
- Disqualifying paths (`.ps1`/`.psm1`/`.psd1`, `config/poshqc-coverage.json`, `scripts/powershell/PoshQC/`): none
- Result: PASS. No PowerShell file and no coverage configuration differs from BASE_SHA.

HEAD: c04940465584cedb9df7f85efd17b64dfc56870d
BASE_SHA: 460cd755de560b733be0c471d1d144e553fbe0e5

## Diff path list (`git diff --name-only BASE_SHA HEAD`)

```
docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/issue.md
docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/plan.2026-10-08T23-43.md
docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/research/research.2026-10-08T23-50.md
docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/spec.md
docs/features/potential/promoted/2026-10-08-powershell-aggregate-line-coverage-below-floor.md
```

## Status path list (`git status --porcelain=v1 --untracked-files=all`, path = `$line.Substring(3)`)

```
docs/features/active/2026-10-08-powershell-aggregate-line-coverage-below-floor-847/evidence/other/execution-amendment.2026-10-09T23-50.md
```

## Checks over the union

- Paths ending `.ps1`, `.psm1`, or `.psd1`: 0
- Path equal to `config/poshqc-coverage.json`: 0
- Paths starting `scripts/powershell/PoshQC/`: 0
