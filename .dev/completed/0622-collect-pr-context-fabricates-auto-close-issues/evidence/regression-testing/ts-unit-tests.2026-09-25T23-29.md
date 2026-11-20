# TypeScript Unit and Updated Tests — [P7-T6]

Timestamp: 2026-09-26T20-21
Branch: N588
Command: node run-jest.cjs test/lib/pr-context/autoclose.test.ts test/lib/pr-context/render-pr-helpers.test.ts test/lib/pr-context/feature-docs.test.ts test/lib/pr-context/collector-core.test.ts test/lib/pr-context/collector-core-autoclose.test.ts test/lib/pr-context/issue-reference-pattern.test.ts test/lib/pr-context/collector-integration.test.ts test/lib/pr-context/render.test.ts test/lib/pr-context/render-feature-excerpts.test.ts --verbose (from extensions/drm-copilot)
EXIT_CODE: 0
Output Summary:
- `Test Suites: 9 passed, 9 total`
- `Tests:       197 passed, 197 total` (no failed count)
- [P7-T5] pre-edit locator commands (recorded as text): the awk command `awk '/^function ghHandler\(/{f=1} /^function gitHandler\(/{f=0} f && index($0, "return okResult(JSON.stringify({ number: Number(number) }));") {print NR}' extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts` printed `106` (exit 0); the count command `grep -c -F -e "return okResult(JSON.stringify({ number: Number(number) }));" extensions/drm-copilot/test/lib/pr-context/collector-core.test.ts` printed `2`.
- In this non-interactive shell the `--verbose` run printed only the summary block. Per-test status was read from a supplementary run of the same nine files with `--json --outputFile=<session scratch file>` (exit 0; 197 total, 0 not passed), as in [P5-T2]. Passed counts per named title:
  - collector-core-autoclose.test.ts: T1 excludes scraped tokens from autoclose when gh is unavailable 1/1; T2 excludes a prose-cited closed issue from autoclose 1/1; T3 excludes a prose-cited open out-of-scope issue from autoclose 1/1; T4 excludes a closed pending primary without printing it 4/4; T5 keeps an open pending primary 2/2; T6 fetches each issue once 1/1.
  - autoclose.test.ts, selectPendingPrimary: keeps an open issue, keeps an OPEN issue, excludes a closed issue, excludes an (unknown) state, excludes a pull request, excludes an unclassified ref, keeps every ref when gh is unavailable, fetches each issue at most once, reports mixed outcomes: 1/1 each.
  - autoclose.test.ts, classifyReferences: routes issue, pull, and invalid refs; adds raw refs when gh is unavailable; prefixes an unprefixed ref: 1/1 each.
  - autoclose.test.ts, buildIssuesToAutocloseSection: appends the unverified annotation when gh is unavailable 1/1; omits the annotation when gh is available 1/1; renders the not-open text when the pending primary is excluded 1/1; applies the composed fallback precedence 5/5.
  - issue-reference-pattern.test.ts: rejects %s from %s 39/39; accepts %s from %s 18/18.
  - render-pr-helpers.test.ts: keeps referenced issues out of author auto-close 1/1.
  - feature-docs.test.ts: ignores JIRA-style references 1/1; extracts issue references from the combined doc text 1/1.
- N588: no #588 test exists in render-pr-helpers.test.ts or collector-core.test.ts; the [P7-T3] update set is empty by construction.
