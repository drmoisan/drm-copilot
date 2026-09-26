# Research: collect-pr-context fabricates auto-close issues (Issue #622)

- Date: 2026-09-25
- Branch: `bug/collect-pr-context-fabricates-auto-close-issues-622`
- Requirements source: `docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/issue.md`
- Sibling: #588 (`bug/pr-context-gh-detection-false-negative-588`), which owns the gh-availability false negative and the empty-list gh-unavailable autoclose text.

## Method and Evidence Limits

- All Python and TypeScript findings below were verified by reading the files in this worktree; line numbers refer to the current tree.
- This session's tool set has no shell, so `git fetch` / `git show` could not be run. The #588 `spec.md` and `plan.2026-09-25T22-06.md` were read from `raw.githubusercontent.com` on the #588 branch. The spec's Acceptance Criteria and Proposed Fix were returned verbatim. The plan came back only as a summary. Before planning, re-read both files with `git show` and confirm the #588 parameter names quoted in the Composition with #588 section.

## Root Causes

There are four defects. Each one alone lets a non-closing token reach a list that consumers treat as closing targets.

### RC1: The reference regex accepts non-issue tokens, and the collector then adds a `#` prefix

The same regex is defined six times, three per runtime:

| Runtime | File:line | Definition |
|---|---|---|
| Python | `scripts/dev_tools/pr_context/feature_docs.py:37` | `extract_issue_references` (line 34) |
| Python | `scripts/dev_tools/pr_context/render_pr_helpers.py:104` | `extract_issue_references` (line 100) |
| Python | `scripts/dev_tools/pr_context/render_feature_excerpts.py:29` | `_extract_issue_references` (line 25) |
| TS | `extensions/drm-copilot/src/lib/pr-context/feature-docs-parsers.ts:82` | `extractIssueReferences` (line 78) |
| TS | `extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts:166` | `extractIssueReferences` (line 162) |
| TS | `extensions/drm-copilot/src/lib/pr-context/render-feature-excerpts.ts:73` | `extractIssueReferences` (line 69) |

The pattern is `(?<!\w)#\d+|\b[A-Z][A-Z0-9]+-\d+\b`. It has two alternatives. The first accepts `#<digits>`. The second is a JIRA-style alternative that matches `ISO-8601`, `CR-1`, `UTF-8`, `SHA-256`, `RFC-3339` and `AC-12` in ordinary prose. A literal `#ISO-8601` in text does not match the first alternative; the second alternative matches the `ISO-8601` substring.

The `#` prefix is added afterwards, in four places. Each one turns a JIRA-shaped token into a string that looks like a GitHub issue:
- `collector.py:196, 205, 215, 220`
- `render.py:208`
- `collector-core.ts:453` (`formatRef`, called at 424, 427, 440)
- `render.ts:226`

A separate regex is not involved. `_parse_primary_issue_from_metadata` (`feature_docs.py:125`, TS `feature-docs-parsers.ts:213`) uses the strict `^\s*[-*]?\s*Issue:\s*(#\d+)\s*$` and is not a source of the defect.

The existing tests treat JIRA extraction as intended behavior:
- `tests/scripts/dev_tools/test_render.py:162-167`
- `tests/scripts/dev_tools/test_feature_docs.py:75-83, 186-193`
- `tests/scripts/dev_tools/test_collect_pr_context.py:161-164, 276/310`
- `extensions/drm-copilot/test/lib/pr-context/feature-docs.test.ts:84-87, 226-232`
- `tests/scripts/dev_tools/test_collect_pr_context_part2.py:245`, whose fake `classify_entity` treats `ABC-10` as an issue.

### RC2: Issues cited in feature-doc prose are harvested as candidates

`gather_feature_excerpts` sets `issue_refs = extract_issue_references(spec + issue + plan + user-story)` (`feature_docs.py:335-337`; TS `feature-docs.ts:171-173`). The collector merges these into `feature_issue_refs` (`collector.py:173-175`; `collector-core.ts:161-163`).

- With gh available, refs that GitHub classifies as `issue` go into `referenced_issues_set` (`collector.py:195-203`; `collector-core.ts:401-411`). A closed or open unrelated issue that is only cited in prose (`#468`, `#584`) therefore survives classification.
- With gh unavailable, the raw-reference fallback (RC4) adds every token.

Commit subjects follow the same path: `render.py:195-219` and `render.ts:216-236` extract refs from `oneline + subjects`, for example the `(#660)` suffix on merged commits.

`research/` files are not read. Only `spec.md`, `issue.md`, the latest `plan*.md` and `user-story.md` are read (`feature_docs.py:218-253`).

### RC3: Every referenced issue is published as "author asserted" auto-close

This happens at two layers, and each is sufficient on its own:
- **Collector:** `if referenced_issues: author_asserted = sorted(set(author_asserted + referenced_issues))` with the reason `"Detected issue references (classified)"` (`collector.py:239-241`; `collector-core.ts:213-217`). Nothing in the repo parses a real author assertion. The PR Intent field `Author-asserted autoclose issues:` is an empty template line (`collector_documents.py:205`; `collector-output.ts:165`; `render.py:295`).
- **Builder:** `build_close_candidates_section` computes `all_auto_close = set(verified + author_asserted + referenced)` and renders all of it under `Auto-close issues (author asserted):` (`render_pr_helpers.py:209-220`; `render-pr-helpers.ts:322-335`). `referenced_only = set(referenced) - all_auto_close` is always empty because `referenced` is a subset of `all_auto_close`, so `Referenced issues (detected):` in this block always renders `(none)`.

Two tests pin the builder defect: `test_collect_pr_context.py:375-386` (`..._promotes_referenced_issues_to_auto_close`) and `render-pr-helpers.test.ts:193-203`.

The issue's observed lists match the output of this block, not the "Issues to autoclose" section:
- `#468, #633, #ISO-8601` and `#442, #646, #647, #CR-1` are in code-point order (`sortedSet` / `sorted`).
- `build_issues_to_autoclose_section` emits verified-then-pending order, and its inputs can only contain strict `#\d+` values: `verified` comes from `closingIssuesReferences` integers (`github.py:427-437`) and `pending_primary` comes from the strict metadata regex.

This attribution is an inference from ordering and from the input constraints; the original TaskMaster bundles were not available.

### RC4: The raw-reference fallback when gh is unavailable

When gh is unavailable, every extracted token (including JIRA-shaped ones) is `#`-prefixed and added to referenced issues without any check:
- `collector.py:213-221`, `render.py:213-217`
- `collector-core.ts:421-429` (`classifyReferences` else-branch), `render.ts:231-235`

It then flows into author-asserted through RC3. The only signal is `NOTE: Unverified (GitHub unavailable)` on the separate `Referenced issues (classified)` section (`collector_documents.py:250-251`; `collector-output.ts:204-206`).

With gh available, non-numeric tokens get a `gh api repos/<repo>/issues/ISO-8601` call. That returns 404, and the token is placed in the invalid set (`github.py:124-146`; `gh-client-core.ts:263-288`). This is correct in outcome but spends a network call per false positive.

### Interaction with #588

In the TS runtime (the MCP tool path), the `whichGh` default `() => undefined` (`gh-client-core.ts:85`), combined with `pr-context-service-call.ts:133-144` passing no `whichGh`, forces `ghAvailable=false` on every run. The raw-reference fallback (RC4) therefore always ran on the MCP path.

Fixing #588 alone removes the `#ISO-8601` / `#CR-1` artifacts when gh works, because they become invalid via 404. It does **not** remove cited real issues such as `#468` or the open `#584`: those classify as `issue` and still reach the author-asserted list through RC2 and RC3.

This branch reproduces the defect deterministically. Its own `issue.md` cites `#588`, `#468`, `#633`, `#646`, `#647`, `#648`, `#584`, `#442`, `#656`, `#662`, `#663`, `#670` and the literal strings `#ISO-8601` / `#CR-1`.

## Q1: Paths from token to output

| Stage | Python | TypeScript |
|---|---|---|
| Feature-doc harvest | `feature_docs.py:335-337`, then `collector.py:173-175` | `feature-docs.ts:171-173`, then `collector-core.ts:161-163` |
| Second context pass with feature refs | `collector.py:177-187`; shown raw in the appendix `Referenced issues (detected)` via `render.py:221` | `collector-core.ts:166-177`; `render.ts:240-243` |
| Commit-subject refs | `render.py:195-219` (merge PRs excluded, 193) | `render.ts:214-238` |
| Branch/path refs | `collector.py:192-193` | `collector-core.ts:182-183` |
| Classification / raw fallback | `collector.py:194-221` | `collector-core.ts:184-193, 389-454` |
| Verified | `render.py:139-141` (`current_pr.closing_issues`), then `collector.py:229` | `collector-core.ts:201` |
| Author asserted | `collector.py:227-241` | `collector-core.ts:199-217` |
| Pending primary | `collector.py:245-252` (readiness `PASS` plus `Issue: #N` metadata) | `collector-core.ts:221-232` |
| Autoclose section | `render_pr_helpers.py:228-272` | `render-pr-helpers.ts:352-379` |
| Close candidates | `render_pr_helpers.py:200-225`, called from `collector.py:361-367` | `render-pr-helpers.ts:313-340`, called from `collector-output.ts:475-487` |
| Summary assembly | `collector_documents.py:236-251` | `collector-output.ts:192-206` |

Branch-name suffixes such as `...-622` and feature-folder paths yield no refs under either regex alternative, because the first requires `#` and the second requires uppercase.

## Q2: What is emitted and what consumers treat as closing targets

Emitted sections:
- `===== Issues to autoclose (verified or pending) =====`: `verified` then `pending_primary`, or a fallback text. It cannot contain non-numeric tokens, but it does not check the pending primary's state.
- `Close candidates` → `Auto-close issues (verified from GitHub PR metadata)`: `verified`.
- `Close candidates` → `Auto-close issues (author asserted)`: `verified ∪ referenced_issues` (the defect).
- `Close candidates` → `Referenced issues (detected)`: always `(none)` (RC3).
- `Referenced issues (classified)`: `referenced_issues`, labelled as mentions.

Consumer rules:
- `.claude/skills/pr-author/SKILL.md:43, 77-78`: `Closes` lines come only from "Issues to autoclose" or "Author-asserted autoclose issues". If validation is unavailable or unverified, no `Closes` is emitted and the `None` bullet is used.
- `.github/prompts/generate-pr.prompt.md:42, 54-58, 134-139` and `.github/agents/pr-author.agent.md:39-43, 104-108` use the same ordering.

The collector's populated `Auto-close issues (author asserted):` block has nearly the same name as the consumer's second source. A consumer can reasonably read it as that source, which is how the scraped list reached PR bodies.

Mirror copies of the skill exist in `.agents/skills/pr-author/SKILL.md`, `extensions/drm-copilot/resources/claude-customizations/.claude/skills/pr-author/SKILL.md`, `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/pr-author/SKILL.md` and `extensions/drm-copilot/resources/customizations/.github/{agents,prompts}`. Changing the consumer contract would require synchronizing all of them.

## Q3: Available GitHub verification and determining "closed by this change"

| Data | Source | gh available | gh unavailable |
|---|---|---|---|
| Entity kind (issue/pull/not found) | `classify_entity` (`github.py:124-146`; `gh-client-core.ts:263-288`) | yes | no |
| Issue state (`open`/`closed`) | `issue_details(...).state` (`github.py:185-295`; `gh-client-details.ts:164-210`); already fetched for `verified + author_asserted + referenced` at `collector.py:266-270` / `collector-core.ts:244-254`; `pending_primary` is not in that fetch set | yes | no |
| `closingIssuesReferences` | `current_pr()` (`github.py:399-495`; `gh-client-details.ts` `currentPrImpl`) | only when a PR exists for the branch | no |

The collector runs before PR creation, so `closingIssuesReferences` is usually empty ("None (no PR exists yet for this branch)", `collector.py:232-233`).

Before a PR exists, the evidence that this change closes an issue is:
- (a) the `Issue: #N` metadata line of a feature folder whose files are in the diff, since `gather_feature_excerpts` only loads features with changed paths (`feature_docs.py:194-203`), with readiness `PASS`. This is the existing `pending_primary`.
- (b) explicit closing keywords in commit messages.
- (c) a branch-name suffix.

Option (a) is already implemented and deterministic. Option (b) is noisy: commit subjects routinely cite other issues, and GitHub only honours keywords on merge to the default branch. Option (c) is not parsed today and would add a new heuristic.

## Q4: Raw-reference fallback

Location and current behavior are described under RC4.

Target behavior:
1. Only strict bare `#<digits>` tokens reach it (RC1 fix).
2. Its output stays in the mention-only `Referenced issues (classified)` list with the existing `NOTE: Unverified` suffix.
3. It never reaches any autoclose-labelled list (RC3 fix).

After the RC1 fix, `formatRef` / `f"#{ref}"` prefixing is dead for non-`#` input and can be simplified or kept as a defensive no-op.

## Q5: Parity and tests

- **Parity:** there is no cross-runtime golden or parity harness for this area. Searches for `parity|golden|snapshot` returned nothing under `extensions/drm-copilot/test/lib/pr-context/`. Among the Python `*pr_context*` tests, only `test_pr_context_freshness.py:288-308` matched: it reads the TS source text and asserts that shared literals appear. That is a usable precedent for pinning new literals across runtimes.
- **Python tests (pytest):**
  - `tests/scripts/dev_tools/test_collect_pr_context.py`
  - `test_collect_pr_context_part2.py`, `_part3.py`, `_part4.py`
  - `test_collect_pr_context_expected_exit.py`
  - `test_render.py`, `test_render_helpers.py`
  - `test_feature_docs.py`, `test_github.py`, `test_github_part2.py`, `test_github_part3.py`
  - `test_pr_context_integration.py`, `test_pr_context_freshness.py`
  - `tests/scripts/dev_tools/pr_context/test_verification_evidence.py`
  - Filesystem access uses the in-memory `mem_fs_path` fixture (`tests/conftest.py:146`).
- **TS tests (jest, `extensions/drm-copilot/test/lib/pr-context/`):**
  - `collector-core`, `collector-integration`, `collector-output`, `collector-output-freshness`, `collector-output-head-source`
  - `feature-docs`, `render-pr-helpers`, `render`, `render-feature-excerpts`
  - `gh-client-core`, `gh-client-details`
  - `pr-context-service-call`, `pr-context-service-call-target`
  - `summary-helpers`, `models`, `git-client`, `diff-emptiness`, `verification-evidence` (`*.test.ts`)
  - Filesystem access uses the in-memory `tree-file-system.ts`.
- **Coverage gates:**
  - Uniform ≥85% line / ≥75% branch.
  - `extensions/drm-copilot/jest.config.cjs:25-44` has per-file thresholds for `pr-context-service-call.ts`, `collector-core.ts`, `collector-output.ts` and `summary-helpers.ts`. #588 adds `render-pr-helpers.ts`. Any new TS module needs its own entry.
  - Python has no `fail_under` in `pyproject.toml`; the gate is measured per run, and the #588 spec uses `--cov=scripts.dev_tools.pr_context`.
- **Property tests:** neither `hypothesis` nor `fast-check` is a dependency (checked in `pyproject.toml` and `extensions/drm-copilot/package.json`), and `quality-tiers.yml` is absent at the repo root. Use parametrized boundary matrices; adding either library needs explicit approval.

## Q6: Composition with #588

#588's spec lists these files and changes:
- `render-pr-helpers.ts` / `render_pr_helpers.py`: adds an optional `ghAvailable = true` / `gh_available: bool = True` to `buildIssuesToAutocloseSection` / `build_issues_to_autoclose_section`. With gh unavailable and an empty list, the body is exactly `None (GitHub CLI unavailable; closing issues not verified)`, taking precedence over the PASS/non-PASS fallbacks.
- `collector-core.ts` and `collector.py`: call-site changes only.
- The new `executable-resolver.ts` and `pr-context-service-call.ts`, which #622 does not touch.

#588's AC states that "the non-empty autoclose rendering, and the #622-owned derivation code are unchanged" and that `gh-client-core.ts` and `github.py` have no diff.

Overlapping functions:
- `buildIssuesToAutocloseSection` / `build_issues_to_autoclose_section`, touched by both.
- The `collector-core.ts` / `collector.py` call sites, adjacent lines.

Composition:
- #622 reuses #588's parameter and literal unchanged.
- It widens the gh-unavailable branch from "empty list" to "any list", so the list is never rendered while unverified.
- All other derivation changes (RC1-RC4) are outside the lines #588 edits.

Sequencing: #622's implementation should start from a base that contains #588's merge. If #622 must land first, it has to introduce the identical parameter name, default and literal so that #588 rebases with a trivial conflict.

Line-cap pressure, measured from reads in this session:

| File | Lines |
|---|---|
| `collector.py` | 475 |
| `collector-core.ts` | 476 |
| `collector-output.ts` | 495 |
| `render-pr-helpers.ts` | 482, before #588's additions |

New logic must therefore go in new modules, and the call sites must be net-negative or neutral.

## Q7: Decisions

### D1: Candidate filter

- **Options:**
  - (A) Drop the JIRA alternative and anchor the number: `(?<!\w)#\d+(?!\w)`, defined once per runtime (a constant in `models.py` / `models.ts`) and used by all three extractor copies.
  - (B) Keep the regex and filter the output to `^#\d+$` at the collector.
  - (C) Keep JIRA tokens but route them to a separate non-issue list.
- **Trade-offs:**
  - (A) Fixes the problem at the source for every consumer, including the appendix displays, and removes wasted `gh api` calls. It changes a pinned extraction contract; six tests need updating.
  - (B) Leaves three regex copies drifting and still shows `ISO-8601` in the appendix `Referenced issues (detected)`.
  - (C) Adds surface area for a tracker this repo does not use.
- **Recommendation: (A).** Keep the public function names (`extract_issue_references`, `extractIssueReferences`, re-exported by `collector.py:86` and `index.ts:51`). The `(?!\w)` lookahead rejects `#12abc`.

### D2: Exclusion of prose citations

- **Options:**
  - (A) Keep feature-doc and commit refs as classified mentions only, and never let them reach any autoclose-labelled list. The only feature-doc closing candidate is `primary_issue_ref`.
  - (B) Stop harvesting feature-doc prose entirely (`issue_refs=[]`) and remove the second context pass.
  - (C) Harvest only metadata lines.
- **Trade-offs:**
  - (A) Is a minimal change. It keeps `test_collect_pr_context_part2.py:353-354` (second pass receives `["#7"]`) valid, and keeps the "Related issues / PRs" consumer output working.
  - (B) Loses mentions and changes the `FeatureDocExcerpt` and second-pass contract.
  - (C) Duplicates the existing `primary_issue_ref`.
- **Recommendation: (A).** Implement it through the RC3 fix:
  - Remove the `author_asserted = referenced_issues` promotion (`collector.py:239-241`, `collector-core.ts:213-217`).
  - Change `build_close_candidates_section` so the author list is `author_asserted` only and `referenced_only = referenced − verified − author_asserted`.

### D3: Verification policy

- **Options:**
  - (A) Closing targets are `verified` (`closingIssuesReferences`) ∪ `pending_primary`. When gh is available, a pending primary is kept only if its fetched `state` is `open` and it is an issue, not a pull request.
  - (B) Also accept explicit closing keywords in commit messages.
  - (C) Also accept the branch-name `-<N>` suffix.
- **Trade-offs:**
  - (A) Uses data the collector already fetches (add `pending_primary` to the `issue_details` fetch set at `collector.py:266` / `collector-core.ts:244-248`, and build the section after the fetch). It needs no `github.py` / `gh-client-*` change.
  - (B) Reintroduces citation noise.
  - (C) Adds a new heuristic whose failure modes (for example `-r2` suffixes) were not evaluated.
- **Recommendation: (A).**
  - `verified` entries are trusted as GitHub's own closing references and are not state-checked.
  - An excluded pending primary produces the distinct body `None (deterministic pending issue is not an open issue)`, so the fallback does not claim "no deterministic pending issue".
  - Excluded numbers must not be printed inside the autoclose section, because consumers take any number there as a closing target.
- **Placement:** put the selection in a new pure module (`scripts/dev_tools/pr_context/autoclose.py`, `extensions/drm-copilot/src/lib/pr-context/autoclose.ts`). Move the reference-classification loop into it as well (`collector.py:194-221`; `collector-core.ts:368-454`) to free lines in the near-cap collectors.

### D4: Rendering when validation is unavailable

- **Options:**
  - (A) Omit the section entirely.
  - (B) Keep the section header and render #588's `None (GitHub CLI unavailable; closing issues not verified)` whenever gh is unavailable, regardless of list contents.
  - (C) Render the list annotated "(unverified)".
- **Trade-offs:**
  - (A) Conflicts with #588's AC, which requires that exact body inside the section for the empty case, and with consumers that look for the section.
  - (C) Still places numbers in a section that consumers read as authoritative.
  - (B) Matches the consumer rule (unavailable means no `Closes`, `SKILL.md:78`) and the issue's request to state the condition unambiguously. It needs no consumer-document or mirror edits, because the text contains "unavailable".
- **Recommendation: (B).** When gh is unavailable, `verified` is already `[]` (`collector.py:229`), so the only suppressed content is the metadata-derived pending primary. It remains visible in the feature excerpts.

**Rejected alternatives, in brief:**
- Editing the pr-author consumer contract: requires a multi-mirror sync and is not needed once RC3 is fixed.
- Adding a new `github.py` state API: `issue_details` already carries the state.
- Branch-suffix parsing: deferred.

## Numeric Derivation Evidence

Claim: the reference regex has exactly 6 executable definitions, 3 in Python and 3 in TypeScript.

- **Complete Family:** executable definitions of the issue-reference extraction regex in production code.
- **Exhaustive Search Scope:** the whole worktree excluding `docs/**`.
- **Inclusion Rules:** executable source lines (`.py`, `.ts`) that define or apply the pattern.
- **Exclusion Rules:** documentation comments (`feature-docs-parsers.ts:73`) and the coverage-annotation artifact `scripts/dev_tools/pr_context/render.py,cover`, which is not executable source. Its tracked status was not verified.
- **Primary Search Strategy or Query Expression:** Grep of the regex-literal fragment `\[A-Z\]\[A-Z0-9\]\+-\\d\+`, glob `!docs/**`.
- **Primary Member Set:** `render_pr_helpers.py:104`, `render_feature_excerpts.py:29`, `feature_docs.py:37`, `render-pr-helpers.ts:166`, `render-feature-excerpts.ts:73`, `feature-docs-parsers.ts:82`.
- **Primary Count:** 6.
- **Cross-check Search Strategy or Query Expression:** Grep of the function definitions `(def _?extract_issue_references|function extractIssueReferences)`, glob `!docs/**`.
- **Cross-check Member Set:** `render_pr_helpers.py:100`, `render_feature_excerpts.py:25`, `feature_docs.py:34`, `render-pr-helpers.ts:162`, `render-feature-excerpts.ts:69`, `feature-docs-parsers.ts:78`.
- **Cross-check Count:** 6.
- **Member-set Comparison:** the file sets are identical (the same six files). In each file the definition line directly precedes the regex line. The counts agree.

## Proposed File Changes

Production files (a follow-up planner must confirm line budgets after #588 lands):

- Python:
  - `scripts/dev_tools/pr_context/models.py`: shared pattern constant.
  - `scripts/dev_tools/pr_context/feature_docs.py`, `render_pr_helpers.py`, `render_feature_excerpts.py`: use the constant.
  - `render_pr_helpers.py`: fix `build_close_candidates_section`; widen the gh-unavailable branch of `build_issues_to_autoclose_section`; add the not-open fallback.
  - `scripts/dev_tools/pr_context/autoclose.py` (new): classification loop and target selection.
  - `scripts/dev_tools/pr_context/collector.py`: remove the author-asserted promotion; delegate classification; add `pending_primary` to the fetch set; build the section after the fetch.
- TypeScript:
  - `models.ts`: shared pattern.
  - `feature-docs-parsers.ts`, `render-pr-helpers.ts`, `render-feature-excerpts.ts`: use the pattern.
  - `render-pr-helpers.ts`: the same builder changes as Python.
  - `autoclose.ts` (new).
  - `collector-core.ts`: the same collector changes as Python.
  - `extensions/drm-copilot/jest.config.cjs`: threshold entry for `autoclose.ts`.
- `render.py` / `render.ts` need no change beyond inheriting the regex fix. The fallback branch stays mention-only.

Test files:

- Python:
  - Update `test_render.py`, `test_feature_docs.py` and `test_collect_pr_context.py` (JIRA cases, and invert `..._promotes_referenced_issues_to_auto_close`).
  - Update `test_collect_pr_context_part2.py:245` if its `ABC-10` fake becomes unreachable.
  - Add `tests/scripts/dev_tools/pr_context/test_autoclose.py`.
  - Extend `test_pr_context_integration.py` (offline and online scenarios asserting no scraped refs under autoclose labels).
  - Add a literal-parity assertion following the pattern in `test_pr_context_freshness.py:288`.
- TS:
  - Update `feature-docs.test.ts` and `render-pr-helpers.test.ts`.
  - Add `autoclose.test.ts`.
  - Extend `collector-core.test.ts`.

## Q8: Test-design constraints

- Use `mem_fs_path` (Python) and `tree-file-system.ts` (TS). Use stub git and gh doubles as in `test_pr_context_integration.py:22-136` and `collector-core.test.ts:76-110`. Inject `whichGh` with a string path; the path is never resolved on disk.
- Required fail-first scenarios:
  - Prose containing `ISO-8601`, `CR-1`, `UTF-8`, `#12abc` and `#468` yields no autoclose-labelled entry, both online and offline.
  - With gh available, a closed pending primary is excluded and the not-open text is rendered.
  - With gh unavailable and a non-empty pending primary, the section renders the #588 text and no number.
  - `Referenced issues (detected)` lists referenced-only issues.
- Do not depend on remote refs, gitignored state, a real `gh`, network access, temporary files, or Windows drive roots.
- Existing tests reviewed in this area mention `origin/main` only as string literals inside fakes (for example `test_collect_pr_context_part4.py:222`, `render.test.ts:174`). Searches for `tmp_path|tempfile|mkdtemp` and `[A-Z]:[\\/]` drive-root literals found no violations in `test_{render*,collect_pr_context*,feature_docs,pr_context*,github*}.py`. Searches for `spawnSync|execSync|child_process|process.platform` and temp-directory APIs found no violations in the TS pr-context tests.
- Tests that read tracked repo files (`test_pr_context_integration.py:300-336` reads `.github/prompts/generate-pr.prompt.md`; `test_pr_context_freshness.py:299-301` reads a TS source) are acceptable because those files are tracked.
- Unrelated observation: `scripts/dev_tools/pr_context/render.py,cover` is a coverage-annotation artifact and is not matched by `.gitignore` (`.gitignore:49` covers `.coverage` only). Whether it is tracked was not verified. It is outside #622's scope.
