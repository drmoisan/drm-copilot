# Code Review: pr-author hook docs-only exemption (#901)

- Branch: `bug/pr-author-hook-docs-only-exemption-901` at `bdbf8851e`
- Base: `origin/main` at `7d9a5c33526d7a98d5577ab4a9ad6f465f3dff3c`
- Review timestamp: 2026-10-12T19-05
- Files reviewed: the four canonical hook files, their four bundled mirrors (byte-identical, so they were reviewed once through the canonical copy), `core.json`, and the four new Pester suites.

## Summary

The exemption is implemented as a narrow, ordered predicate (E1 to E7). It is consulted only after the non-epic orchestrator-state preflight has already failed, and it returns a deny reason at the first unmet condition. Every failure path the issue lists (AC-2) denies, and each has a dedicated test. The exemption does not bypass the receipt checks. The #850 L19 fix is correct and minimal. No blocking code defect was found. Two evasion shapes outside the AC-2 list are recorded below as non-blocking findings with recommended follow-ups.

## Focus Area 1: Fail-closed correctness of the exemption

Reviewed: `.claude/hooks/enforce-pr-author-skill.docs-only.ps1` and the call site at `.claude/hooks/enforce-pr-author-skill-helpers.ps1:418-428`.

| Condition | Mechanism | Denies? | Test |
|---|---|---|---|
| Non-create command (`gh pr edit`) | E1, `Test-CommandLineInvocation` on `pr create` | Yes, `NOT_CREATE` | Exemption "denies gh pr edit"; Decision "denies gh pr edit --body-file" |
| Checkpoint file present (including invalid) | E2, `Test-Path -PathType Leaf`; a blank path reports present | Yes, `CHECKPOINT_PRESENT` | Exemption and Decision rows; helper rows for existing, missing, blank |
| Missing `--base`, `-B` form, repeated `--base`, dash-leading or `..` value, trailing `--base` | E3, `Get-PrAuthorDocsOnlyBaseName` (token count, `-B` ordinal prefix, regex `^[A-Za-z0-9][A-Za-z0-9._/-]*$`) | Yes, `BASE_UNRESOLVED` | Six "rejects" rows plus Exemption/Decision "without --base" |
| Base does not resolve | E4, `rev-parse --verify --quiet refs/remotes/origin/<base>^{commit}`; exit code and 40/64-hex output both required | Yes, `BASE_UNRESOLVED` | non-zero exit, non-OID output, throw |
| Diff fails or throws | E5, exit code check plus `try/catch` around the seam | Yes, `DIFF_FAILED` | exit 128, throw |
| Empty diff | E6, empty array after NUL split | Yes, `EMPTY_DIFF` | Exemption "denies an empty diff"; helper "empty set" |
| Path outside `docs/` | E7, ordinal `StartsWith('docs/')` and `Length -gt 5` | Yes, `NON_DOCS_PATH` | `.claude/`, `.github/`, `README.md`, `docsx/`, `doc/`, `Docs/`, bare `docs`, mixed set |
| Rename from outside into `docs/` | `--no-renames` reports the old path as a deletion | Yes, `NON_DOCS_PATH` naming the old path | Exemption "rename ... delete plus add"; argument row asserts `--no-renames` |
| Unresolvable or nonexistent worktree root | Seam returns `ExitCode -1` | Yes, at E4 | Helper "nonexistent root" |
| `git` not on PATH | `& git` raises `CommandNotFoundException`, caught, returns -1. If it were not caught, the output would be empty and E4's OID regex or E6 would still deny | Yes | Not directly tested (by design: no process start in tests) |

Additional observations:

- Prefix matching is exact: ordinal and case-sensitive, with a trailing slash, plus the `Length -le 5` guard against a bare `docs/` entry. `--no-relative`, `--no-color`, and `--no-ext-diff` neutralize repository configuration that could otherwise change the listing. `-z` removes quoting, so `core.quotePath` cannot add a leading `"`.
- The three-dot range uses the resolved commit OID, not the user-supplied name, so the value passed to `git diff` is always a validated hex string. Branch-name injection into the diff call is not possible.
- The epic branch is untouched (`helpers.ps1:407-413`). The exemption never applies under epic scope, as the header states.
- The deny message keeps the original `ORCHESTRATOR_STATE_PREFLIGHT_FAILED:` prefix and appends `(docs-only exemption not applied: <sub-code>)`, so existing assertions that match the prefix still hold.

## Focus Area 2: The exemption replaces only the checkpoint preflight

- After a successful exemption, control falls through to `Test-PrAuthorReceiptVerification` (`helpers.ps1:432`) with no flag or short-circuit. Checks 1 to 5 (canonical body path, receipt presence, number, SHA-256, freshness) do not read the checkpoint, so they run with full strength.
- Check 6 (`Test-EpicBaseBranchOverride`) reads the checkpoint and is a no-op when it is absent. That is pre-existing behavior. E2 guarantees the checkpoint is absent on the exempt path, so a per-feature `epic_mode` checkpoint cannot be present and silently skipped.
- Test evidence: Decision "still runs the receipt checks on an exempt branch" asserts `PR_AUTHOR_RECEIPT_HASH_MISMATCH` on an otherwise exempt branch. Decision "never consults the exemption when the preflight passes" asserts zero seam calls on the passing-checkpoint path (AC-3).
- Result: the body-file and receipt checks are not relaxed.

## Focus Area 3: #850 L19 fix (`enforce-pr-author-skill.artifact-root.ps1`)

- `ConvertTo-PrAuthorBodyNumber` uses `[int]::TryParse(..., NumberStyles::None, InvariantCulture, ...)` and then requires `$number.ToString(InvariantCulture) -cne $Digits` to be false. This rejects values above Int32.MaxValue (TryParse returns false), leading zeros (round-trip mismatch), and non-ASCII `\d` digits (`NumberStyles::None` with invariant culture accepts only ASCII digits, and the round-trip check would reject them anyway).
- Both former `[int]$Matches[1]` casts (relative and absolute branches) are replaced. The relative branch returns the generic `PR_BODY_PATH_NONCANONICAL` reason. The absolute branch falls through to the same generic reason. Neither path can throw.
- Tests: `BodyNumber.Tests.ps1` covers overflow (relative and absolute), leading zero (relative and absolute), non-ASCII digits, the canonical number 7 (both forms), and an end-to-end deny through `Invoke-PrAuthorSkillDecision` with `Should -Not -Throw`.
- Result: correct and deterministic.

## Focus Area 4: Test quality, mirrors, manifest, size

- No temporary files, no `TestDrive`, no process start, no clock or sleep APIs (reviewer grep, matching `evidence/qa-gates/p2-test-purity`).
- AAA sections are explicit in every `It`. Each `It` asserts one behavior. Data-driven rows use `-ForEach` with descriptive `<Name>` / `<Path>` titles.
- Each suite copies the repository's baseline mock block and runs `Invoke-EpicStateInterceptionProbe`, following the established isolation pattern for this hook family.
- The mocks target the wrapper seam (`Invoke-PrAuthorDocsOnlyGitExe`) with `-ParameterFilter` on `$GitArgs`, never `git` directly, per `.claude/rules/powershell.md`.
- Argument-shape rows assert `-z`, `--no-renames`, `--no-relative`, the three-dot range on the OID, and `refs/remotes/origin/main^{commit}` against the resolved root. This guards the flags that carry the safety properties.
- Mirrors: `cmp` reports all four canonical/mirror pairs identical. `core.json` registers the new sibling in sorted order.
- Sizes: the largest file is helpers at 438 lines. All files are under 500.

## Findings

| ID | Severity | Location | Finding | Recommendation |
|---|---|---|---|---|
| CR-1 | Medium (non-blocking) | `enforce-pr-author-skill.docs-only.ps1:122-130` | The `-B` exclusion checks only tokens that begin with `-B`. gh uses pflag, which accepts clustered shorthand flags. A command such as `gh pr create --base main -dB other --body-file ...` contains exactly one `--base` token and no token beginning with `-B`, so E3 resolves `main`. gh itself would apply `-B other` (draft plus base `other`, last value wins). The PR's effective base would then differ from the base the diff was computed against, and the PR diff could include non-docs commits that `other` lacks. Exploiting this requires deliberately constructing the command. The hook's own `.NOTES` describes it as a policy-level control, not a security boundary. A similar effective-target change is possible with `-R/--repo`. | Deny when any single-dash token (not `--`) contains `B` in its shorthand cluster, or when `-R`/`--repo` is present. Add a test row for `-dB`. Track as a follow-up; it is not one of the AC-2 conditions. |
| CR-2 | Low (non-blocking) | `enforce-pr-author-skill.docs-only.ps1:64,70` and `:162` | Correct path separation in production depends on PowerShell preserving NUL characters when it captures native `git` stdout. All tests supply NUL-separated text through the mocked seam, so this property is not exercised against a real process. If NULs were dropped, `docs/a.md` followed by `.claude/x.ps1` would join into one string beginning with `docs/`, and E7 would pass (fail-open). PowerShell 7 is expected to preserve NUL in captured strings, and `-z` splitting in pwsh is common practice. However, neither this review nor the branch evidence verified it: the reviewer's `pwsh` probe was blocked by the worktree isolation guard. | Add a cheap fail-closed guard: when the diff output is non-empty, require it to end with `[char]0` (git `-z` always terminates each entry), else return `DIFF_FAILED`. Optionally, record one read-only empirical check of `git diff --name-only -z` capture in pwsh as evidence. |
| CR-3 | Low (non-blocking, recorded) | design | The diff uses the local `HEAD` of the resolved worktree. gh creates the PR from the pushed head branch, which can differ if local and remote have diverged. This is recorded as decision D5 in `evidence/other/follow-up-and-decisions`. | No action in this item. Revisit if the exemption is broadened. |
| CR-4 | Informational | `enforce-pr-author-skill.docs-only.ps1:90-93` | `Test-Path -PathType Leaf` reports a directory at the checkpoint path as absent. The preflight has already failed in that case, and the remaining conditions still apply, so the effect is limited to an unusual repository layout. | None required. |
| CR-5 | Informational | `Invoke-PrAuthorDocsOnlyGitExe` lines 63-70 | The success path of the seam (the actual `git` call) is not unit-tested, by design (no process start in tests). Its uncovered lines will appear in CI coverage. | None required. Confirm the per-file figure stays at or above 85% in CI (AC-9). |

## Code Quality Notes

- Naming follows approved verbs and descriptive nouns (`Get-`, `Test-`, `ConvertFrom-`, `ConvertTo-`, `Invoke-...Exe`).
- Comment-based help is present on every new function. The file header enumerates E1 to E7 with their sub-codes. The main hook's `.DESCRIPTION` duplicates the list for operator readability (AC-10).
- The `.NOTES` corrections (AC-8) accurately state in-repo dependencies and the runtime use of `git`.
- No script-scoped mutable state is introduced by the new sibling.

## Verdict

- Code verdict: PASS WITH NOTES. There are no blocking code defects. CR-1 and CR-2 are recommended follow-ups.
- Blocking count from this artifact: 0.
