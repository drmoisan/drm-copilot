# Git Baseline and Diff Anchor (P0-T3)

Timestamp: 2026-10-09T02-51
Command: git rev-parse --abbrev-ref HEAD; git rev-parse HEAD; git status --porcelain; git rev-parse HEAD > docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt; head -1 docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/baseline/base-sha.txt | tr -d '\r\n' | wc -c; git ls-files --error-unmatch -- docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/spec.md
EXIT_CODE: 0
Output Summary: branch bug/blast-radius-path-extractor-misses-real-plan-writes-797; HEAD is a 40-character SHA; base-sha.txt content length 40; porcelain lists only the feature evidence folder (created by P0-T1/P0-T2); spec.md is tracked and not listed in porcelain.
BaseSha: 3d5a8446d6e39f66dd593a53280e47aedd83ba1c

## Deviation (PowerShell route denied)

The plan writes the base-SHA file with `Set-Content -Encoding ascii` in the PowerShell tool. Inline `pwsh` is denied by the worktree-isolation hook (denial text recorded in requirements-source.2026-10-09T02-51.md). The file was written with a shell redirect of `git rev-parse HEAD`, which produces the SHA alone on one line (LF terminator). Every later anchored diff uses `$(cat <base-sha.txt>)` in place of `(Get-Content -LiteralPath <base-sha.txt>)`; both yield the same 40-character operand.

## Output

```text
bug/blast-radius-path-extractor-misses-real-plan-writes-797
3d5a8446d6e39f66dd593a53280e47aedd83ba1c
?? docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/evidence/
40
docs/features/active/2026-09-30-blast-radius-path-extractor-misses-real-plan-writes-797/spec.md
```
