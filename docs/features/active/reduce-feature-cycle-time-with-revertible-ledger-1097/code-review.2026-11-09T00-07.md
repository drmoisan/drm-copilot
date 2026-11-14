# Code Review: Stage J Re-audit after Remediation Cycle 1, review/verdict Commit Status (Issue #1097)

- **Branch:** `feature/reduce-feature-cycle-time` @ `9bec11172a644360fc8599627cdf3b2dd63afd0e`
- **Base:** `main`, merge base `0a4ba82b7080cce751fdc6e17f35d7b6b6b05a5e` (equal to `origin/main`)
- **Scope:** full branch diff, 47 files; the cycle 1 commits `54d5d0dc4`, `269dc9918`, `9414a1530`, `8ec84ad68`, `78decbbda`, `b6d899de1`, `e89ee7b7a`, `9bec11172` reviewed in detail, the stage J delivery re-checked for regressions
- **Reviewer:** feature-review agent, 2026-11-09

## Executive Summary

- **F1 is resolved.** `quality-tiers.yml` adds `path: ".claude/lib/review-verdict"`, `tier: T3`, and a `rationale` in the form of the `.claude/lib/ci-gate` entry, directly after it (3 added lines, 0 deleted). The reviewer's module-form run of `check_quality_tiers` from the worktree root with the main checkout venv exits 0 (`33 entries, 33 discovered projects`), and CI run 42538030434 passed `tier-classification` on this head.
- **CR1 is addressed.** `Get-ReviewVerdictReviewDecision` requests `AuditListing` after `ArtifactCommitted` and before the live-head shortcut, maps a non-zero exit to `REVIEW_VERDICT_GIT_FAILED` (entry point exit 1, no POST), and refuses with `REVIEW_VERDICT_ARTIFACT_NOT_LATEST` when any listed name matching the anchored artifact pattern sorts ordinally after the named audit. Real-git probes on `9bec11172` refuse the stage I audit `policy-audit.2026-11-08T20-30.md` and the oldest audit `policy-audit.2026-11-07T04-19.md`, and accept `policy-audit.2026-11-08T23-33.md`. Fixed-width `yyyy-MM-ddTHH-mm` stamps under one folder prefix sort chronologically, including across the day boundary present in this folder.
- **CR3 is addressed.** Only the `.SYNOPSIS` line of `Get-ReviewVerdictFactOutput` changed; the body is unchanged and returns the Output untrimmed.
- **Tests discriminate.** Removing the rule would make `refuses when a newer audit exists` and `exits 3 without a POST when a newer audit exists` post; reversing the comparison would make `posts when the listing holds only the named audit and older audits` refuse; dropping the exit-code check would make `reports a failed audit listing` proceed. Both new branches and the request are covered (module 201 of 201 lines).
- **Mirrors hold.** `git ls-files -s` shows equal blob ids for both library pairs (`4219cd8bd`, `084a6d6fe`), and both orchestrate pairs have equal sha256.
- **No blocking finding.** New non-blocking items: CR7 (the rule compares committed audits only), CR8 (listing read without `-z`), CR9 (skill text does not name the new code), CR10 (long help line). CR2 is carried.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/lib/review-verdict/ReviewVerdictEligibility.psm1` | `Get-ReviewVerdictReviewDecision`, newest-audit rule | CR7. The rule compares the named audit with the audits committed in the live head. Before the PASS review's own audit is committed, the newest committed audit is the previous review's, so that older audit is accepted. Probe: on `60e92a837` with reviewed head equal to live, `policy-audit.2026-11-08T20-30.md` (stage I) returned `REVIEW_VERDICT_ELIGIBLE`. The skill's records-first rule (item 3) prevents this in the documented flow, because the PASS audit is committed before posting and then sorts newest. | Optionally also require the named audit to be absent from the reviewed head (`git cat-file -e <reviewed>:<artifact>` must fail). The review writes its audit after the head it reviewed, so the PASS audit passes and any audit that existed at the reviewed head is refused; the live-head shortcut then never applies, which matches item 3. | The risk is unchanged in kind from CR1: a misleading description, not a post without a PASS. The status records a passing review and does not prove one (skill item 9). | Real-process probe output (policy audit, reviewer checks table) |
| Nit | `.claude/lib/review-verdict/ReviewVerdictEligibility.psm1` | `AuditListing` request arguments | CR8. `git ls-tree --name-only` is run without `-z`. Under the default `core.quotePath`, git quotes a path with non-ASCII bytes (scratch repository probe: `"docs/features/active/caf\303\251/policy-audit.2026-01-01T00-00.md"`), so no listed name would match the pattern and the rule would pass silently. The `Listing` fact already uses `-z`. | Add `-z` and parse with `ConvertFrom-ReviewVerdictNulList`, or restrict `Test-ReviewVerdictFeatureFolder` to ASCII segments. | No current feature folder has a non-ASCII name (0 of the folders under `docs/features/active/` and `archive/`), and promotion uses lowercase hyphenated slugs. Theoretical gap only. | Scratch probe; `git ls-tree -d` scan |
| Nit | `.claude/skills/orchestrate/SKILL.md` and its three copies | `## Review Verdict Status (review/verdict)` item 3 | CR9. Item 3 lists `REVIEW_VERDICT_ARTIFACT_NOT_COMMITTED`, `REVIEW_VERDICT_HEAD_NOT_CURRENT`, and `REVIEW_VERDICT_NOT_RECORDS_ONLY`, but not `REVIEW_VERDICT_ARTIFACT_NOT_LATEST`, and does not state that `-ReviewArtifact` must be the newest policy audit. The entry-point `.PARAMETER ReviewArtifact` help states it. | Add one sentence to item 3 in all four copies in a later change, outside recorded ledger regions. | The plan left the skill text unedited to keep pinned tokens and ledger regions untouched. An orchestrator that follows item 3 names the PASS audit, which is newest, so behavior is unaffected; a refusal prints the code on stderr. | Skill section text; plan Design Summary |
| Nit | `.claude/lib/review-verdict/ReviewVerdictEligibility.psm1` | `Get-ReviewVerdictReviewDecision` `.DESCRIPTION`, line 213 | CR10. The edited help line runs to 141 characters while the surrounding help wraps near 100. | Re-wrap the paragraph. | Formatting only; the formatter and analyzer report nothing. | File text |
| Nit | `.claude/rules/orchestrator-state.md`; `.claude/skills/orchestrate/SKILL.md` `## Post-Review Outcome Evaluation` step 6 | `head_sha` wording | CR2 (carried). The rule bullet still scopes `head_sha` to concurrent runs; step 6 lists `verdict` and `findings[]` only. | Align in a later change, with mirrors. | Declared out of scope in the cycle 1 plan. A sequential run that omits `head_sha` gets `REVIEW_VERDICT_HEAD_ABSENT` and no post, which fails closed. | Prior review |

No covered file reaches the 700-line advisory tier, so no `Warning` row applies. The largest covered file is `.claude/lib/review-verdict/ReviewVerdictEligibility.psm1` at 507 logical lines; the entry point has 204; the largest test file has 303. `config/file-size-baseline.json` is not in the branch diff.

## Detailed Review

### F1, tier entry

- The entry carries the same three keys as the neighbouring `.claude/lib/*` entries, with a longer rationale naming the library's content. Placement between `.claude/lib/ci-gate` and `.claude/lib/cleanup-manifest` follows the plan.
- No stored ledger patch or revert block targets `quality-tiers.yml`; the chain stays valid with 0 errors.

### CR1, newest-audit rule

- The listing is non-recursive with a trailing slash, so it returns the folder's direct children as full repository paths (reviewer probe), which the anchored `$artifactPattern` matches exactly. A version subfolder is listed as a tree name and does not match.
- Fact Output is the stdout lines joined with LF by `Invoke-ReviewVerdictNativeCommand`, so splitting on LF yields one name per element; no CR is present.
- Equality (`CompareOrdinal` of 0) is not a refusal, so the named audit's own entry passes.
- The request precedes the `$live -ceq $reviewed` shortcut, so both the same-head and descendant-head paths apply the rule (probe: reviewed `e89ee7b7a`, live `9bec11172`, requests `ArtifactCommitted,AuditListing,Ancestry,Listing`, ELIGIBLE).
- Fail-safe on git failure: an invalid tree makes `git ls-tree` exit 128 (probe), the decision returns `REVIEW_VERDICT_GIT_FAILED`, and `Invoke-ReviewVerdictCli` throws on that code and exits 1 with no POST.

### CR3

Synopsis only. Callers depend on untrimmed Output: JSON parsing tolerates whitespace and the NUL listing keeps its terminator.

### Tests

- `ReviewVerdictEligibility.Review.Tests.ps1`: `Get-DescendantFact` and the three posting cases carry `AuditListing`; the new `Context 'Latest audit rule'` has four cases (request order and arguments, only-older listing with a newer non-audit file, newer audit with `Detail` and null `Request`, exit 128).
- `Invoke-ReviewVerdictStatus.Tests.ps1`: two Mode Review cases key the git mock on the exact `ls-tree` argument string; the refusal case asserts exit 3, the stderr prefix, and zero POST calls.
- All six cases are present and passing in `artifacts/pester/pester-junit.xml`.

### Owner requirements re-checked

- No path under `.github/`, `.claude/hooks/`, or `.codex/hooks/` in the diff; no workflow, CI job, ruleset, or required check changed.
- The POST is still built only by `Get-ReviewVerdictStatusArgument` (`gh api --method POST repos/{owner}/{repo}/statuses/<head>`, `state=success`, `context=review/verdict`, description `feature-review PASS: <policy-audit file name>`).
- Records-only re-post, new-push, non-feature modes, and the limit statement are unchanged from the reviewed stage J delivery; their tests still pass.

### Security and correctness

The `ls-tree` path is the validated feature folder (no backslash, blank, `.`, or `..` segment) passed in an argument array. No new file write.

## Verification Performed

- Diff of each cycle 1 commit; blob-id comparison of the library pairs; sha256 comparison of the orchestrate pairs.
- `check_quality_tiers` in module form from the worktree root with the main checkout venv; CI job step list for run 42538030434.
- Real-process probes of the decision with real git facts on `9bec11172` and `60e92a837`; `git ls-tree` probes for the trailing-slash form, an absent folder, and an invalid tree; scratch-repository probe of path quoting.
- Coverage XML and JUnit parsing; logical line counts.
- In-memory `Test-ProcessReductionLedger` and `Invoke-ProcessReductionChain` (both valid, 0 errors).

## Verdict

PASS. No blocking finding. F1 resolved; CR1 and CR3 addressed. CR7 to CR10 and CR2 are non-blocking.
