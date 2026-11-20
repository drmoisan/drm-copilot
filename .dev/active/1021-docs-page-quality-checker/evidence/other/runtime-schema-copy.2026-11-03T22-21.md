# Runtime Schema Copy - Issue #1021

Timestamp: 2026-11-03T22-21
Task: [P1-T2]
Command: `sh SCRATCH/issue-1021-copy-runtime-schema.sh` (one `cp` of `schemas/docs/v1/page-metadata.schema.json` to `.claude/lib/docs/schemas/v1/page-metadata.schema.json`, then `git status --porcelain --untracked-files=all -- .claude/lib/docs/schemas` and `sha256sum` of both files)
EXIT_CODE: 0
Output Summary: the listing shows the new runtime file; both SHA-256 digests are equal.

## `git status --porcelain --untracked-files=all -- .claude/lib/docs/schemas`

```text
?? .claude/lib/docs/schemas/v1/page-metadata.schema.json
```

## SHA-256

| File | SHA-256 |
|---|---|
| `schemas/docs/v1/page-metadata.schema.json` | `0212c2a141dfdc8c11f864ee48e60df1079e3e9ff2ca3e6a370e518ccdeb2690` |
| `.claude/lib/docs/schemas/v1/page-metadata.schema.json` | `0212c2a141dfdc8c11f864ee48e60df1079e3e9ff2ca3e6a370e518ccdeb2690` |
