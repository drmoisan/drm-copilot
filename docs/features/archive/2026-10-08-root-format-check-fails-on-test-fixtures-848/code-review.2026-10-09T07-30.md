# Code Review: root-format-check-fails-on-test-fixtures (Issue #848)

- Timestamp: 2026-10-09T07-30
- Branch: bug/root-format-check-fails-on-test-fixtures-848
- Base: origin/main
- Reviewed change: new root `.prettierignore`

## Executive Summary

Verdict: APPROVE. Blocking findings: 0. The change is a new root `.prettierignore` (comment line plus `tests/fixtures/`) that makes root `format:check` exit 0. Three non-blocking observations are listed below.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Informational | `evidence/baseline` format-check artifact | Output Summary | Baseline records 216 `[warn]` lines versus the plan estimate of 214. | No action required. | All failing paths start with `tests/fixtures/`; no acceptance criterion depends on the count. | Reviewer grep of the baseline artifact: 216. |
| Advisory | `issue.md`, plan | `issue.md` line 5 Status; plan Status | `issue.md` Status names a folder that does not match the actual feature folder; plan Status is still "Draft". | Update both status fields in a later documentation pass. | Metadata accuracy; does not affect the delivered behavior. | Read of both files during review. |
| Advisory | `changed-files` evidence artifact | Path list | The artifact abbreviates its path list. | List paths verbatim in future evidence. | Evidence precision; the union was confirmed independently. | `git diff --stat` during review. |

## Change Reviewed

```
# Fixtures keep exact bytes (CRLF, intentionally invalid JSON); see issue #848.
tests/fixtures/
```

## Correctness

- Prettier reads `.prettierignore` from the working directory by default. The root `format` and `format:check` scripts both run from the repository root, so one file covers both. Evidence: the branch-head `format:check` exits 0, and a read-only `--list-different` over the six write-script globs prints nothing.
- The pattern `tests/fixtures/` is directory-anchored by the trailing slash and covers the nested invalid-JSON fixture, which no longer produces a parse error.
- Files are excluded at expansion, so the check does not parse or rewrite them. Because the failure set was wholly under `tests/fixtures/` (216 warn lines and 1 error at baseline, all with that prefix), the ignore leaves no other failing path, as the exit 0 confirms.
- The pattern is rooted in practice: a `tests/fixtures/` pattern without a leading slash also matches nested directories of that name (for example `src/**/tests/fixtures/`). Prettier follows gitignore semantics here. No such directory is reported in the evidence, so no unintended exclusion was observed. Informational.

## Design and Maintainability

- Simplicity: the smallest change that resolves the defect. It avoids narrowing the `tests/**` glob in `package.json`, which would also stop formatting non-fixture JSON under `tests`.
- The comment explains why fixtures are excluded and references the issue.
- Line endings are LF with a final newline (CR count 0).

## Risks

- Real formatting defects in future fixtures are not detected. This is the intended trade-off, because fixtures include CRLF and intentionally invalid bytes.
- CI does not run root `format:check`, so the green state is not enforced. Out of scope per the issue scope note; a follow-up issue could be considered.

## Non-Blocking Observations

1. Baseline warn count 216 vs plan estimate 214. Not blocking: all paths are under `tests/fixtures/`, and no acceptance criterion depends on the count. The estimate came from an earlier main baseline (#830).
2. `issue.md` Status line points to a folder name that does not match the actual feature folder; plan Status is still "Draft".
3. `changed-files` evidence abbreviates its path list.

## Evidence Integrity

All required artifacts carry `Timestamp:`, `Command:`, `EXIT_CODE:` and `Output Summary:`. Expected-nonzero artifacts declare `ExpectedExitCode`. Pester counts match the baseline (20 and 18). Reviewer re-checked: fixtures, `package.json` and `package-lock.json` have no diff against origin/main; the working tree is clean; the final check artifact contains zero `tests/fixtures` tokens.
