# collect-pr-context-fabricates-auto-close-issues (Spec)

- **Issue:** #622
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-09-25T23-55
- **Status:** Draft
- **Version:** 0.2

## Context
- Summary of the bug and its impact (link to repro/playbook entry):
  - The PR-context collector (Python `scripts/dev_tools/pr_context/`, TypeScript `extensions/drm-copilot/src/lib/pr-context/`, exposed as `mcp__drm-copilot__collect_pr_context`) publishes issue numbers under autoclose-labelled output that are not closing targets of the change. The published entries include:
    - non-issue tokens scraped from prose (`#ISO-8601`, `#CR-1`);
    - closed, unrelated issues that are only cited in feature documents (`#468`, `#442`, `#647`);
    - an open, out-of-scope issue (`#584`).
  - The `pr-author` skill takes `Closes #N` bullets from "Issues to autoclose" or "Author-asserted autoclose issues" (`.claude/skills/pr-author/SKILL.md:43, 77-78`). The collector's `Auto-close issues (author asserted):` block has nearly the same name, and a consumer can read it as that source.
  - Requirements source: `docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/issue.md`.
  - Technical source: `research/research.2026-09-25T23-33.md`. Its citations were re-verified against this tree on 2026-09-25; see Root Cause Analysis.
- Observed environment(s):
  - TaskMaster `bugs-638-644-647` parallel run, 2026-09-01/02, on the MCP (TypeScript) path.
  - This repository reproduces it deterministically: this item's own `issue.md` cites `#588`, `#468`, `#584` and the literal strings `#ISO-8601` / `#CR-1`.
- Customer impact and severity (who is affected, how often, how bad):
  - Every consumer of the bundle that follows `pr-author` is affected.
  - A trusted scraped list posts a closing keyword against unrelated issues. In the `#584` case that issue was still open.
  - The item's own issue can be left open silently when the consumer suppresses `Closes` because validation is unavailable.
  - Observed in 5 of 9 items checked in one run (issue comment).
- First observed date and version(s) impacted: 2026-09-01. The defect is present in the current `main` tree in both runtimes.

## Repro & Evidence
- Steps to reproduce (with data/flags/inputs):
  1. Create a feature folder whose `spec.md` prose contains `ISO-8601`, `CR-1` and `#468`, and whose `issue.md` carries `- Issue: #622` with readiness `PASS`.
  2. Change a file inside that folder on a branch.
  3. Run the collector:
     - once with gh unavailable;
     - once with a gh double that classifies `#468` as a closed issue and `#584` (also cited) as an open issue.
- Expected vs actual behavior:
  - Expected:
    - No autoclose-labelled output contains `#ISO-8601`, `#CR-1`, `#468` or `#584`.
    - `#622` appears in `Issues to autoclose (verified or pending)` when it is an open issue, or when gh is unavailable (with the unverified annotation).
    - `Auto-close issues (author asserted):` renders its "not asserted" reason.
  - Actual:
    - `Auto-close issues (author asserted):` lists every referenced issue in code-point order, for example `#468, #622, #ISO-8601`.
    - `Referenced issues (detected):` in the same block always renders `(none)`.
- Logs/screenshots/error snippets:
  - Issue table rows #633, #646 and #648 in `issue.md`.
  - `pr_context.summary.txt` reported `GitHub CLI unavailable: GitHub CLI (gh) is not installed.` in every observed run. That false report is the #588 defect.
- Frequency / determinism (always, intermittent, data-dependent):
  - Deterministic and data-dependent. It occurs whenever changed feature documents or commit subjects contain `#<digits>` citations or uppercase `WORD-<digits>` tokens.

## Scope & Non-Goals
- In scope:
  - Candidate filtering: the extraction pattern accepts only bare `#<digits>` tokens.
  - No harvesting of issues merely cited in `spec.md`, `issue.md`, `plan*.md`, `user-story.md` or commit subjects as closing targets.
  - Verification of surviving closing candidates against GitHub state, and against whether this change closes them.
  - The raw-reference fallback when gh is unavailable.
  - Rendering of `Issues to autoclose (verified or pending)` when validation is unavailable and the list is non-empty.
  - Python and TypeScript runtimes, kept at parity.
- Out of scope / non-goals:
  - The gh-availability false negative (`whichGh` default, executable resolution). Owned by #588.
  - The empty-list gh-unavailable autoclose text `None (GitHub CLI unavailable; closing issues not verified)`. Owned and introduced by #588; #622 consumes it unchanged.
  - Edits to the `pr-author` consumer contract and its mirrors:
    - `.claude/skills/pr-author/SKILL.md`
    - `.agents/skills/pr-author/SKILL.md`
    - `.github/agents/pr-author.agent.md`
    - `.github/prompts/generate-pr.prompt.md`
    - `extensions/drm-copilot/resources/**` copies

    This is a recorded non-goal. The fix is made entirely on the producer side.
  - Any change to `scripts/dev_tools/pr_context/github.py` or `extensions/drm-copilot/src/lib/pr-context/gh-client-*.ts`.
  - Commit-message closing-keyword parsing and branch-name suffix parsing (see D3).
  - The C# coverage-gate mechanism in the first paragraph of the mirrored issue comment. It belongs to a different issue.
  - `scripts/dev_tools/pr_context/render.py,cover`, a coverage-annotation artifact of unverified tracked status.
- Explicitly excluded systems, integrations, or datasets: GitHub API behavior; the TaskMaster repository; the original TaskMaster bundles, which were not available.

## Root Cause Analysis
- Current hypothesis or confirmed root cause: four defects, each sufficient on its own to let a non-closing token reach a list that consumers treat as closing targets. RC1, RC2 and RC4 are confirmed by reading the code. For RC3, the defect is confirmed in code, but the claim that it is the source of the observed lists is an inference (see Signals).
  - **RC1: the reference pattern accepts non-issue tokens.**
    - The pattern `(?<!\w)#\d+|\b[A-Z][A-Z0-9]+-\d+\b` has a JIRA-style second alternative. It matches `ISO-8601`, `CR-1`, `UTF-8`, `SHA-256` and `AC-12` in ordinary prose.
    - The collector then adds a `#` prefix: `collector.py:196, 205, 215, 220`; `render.py:208`; `collector-core.ts:453` (`formatRef`); `render.ts:226`.
    - The pattern is defined in three Python files and three TypeScript files (see the Affected components list). The research record's `## Numeric Derivation Evidence` lists the members and cross-checks them. A re-run of the fragment grep on 2026-09-25 found the same six executable sites, plus the `render.py,cover` artifact and a doc comment at `feature-docs-parsers.ts:73`.
  - **RC2: prose citations are harvested.**
    - `gather_feature_excerpts` extracts references from the combined `spec + issue + plan + user-story` text (`feature_docs.py:335-337`; `feature-docs.ts:171-173`).
    - The collector merges them into `feature_issue_refs` (`collector.py:173-175`; `collector-core.ts:161-163`).
    - With gh available, any ref that GitHub classifies as `issue` enters `referenced_issues`, whatever its state or relevance.
  - **RC3: every referenced issue is published as author-asserted auto-close.**
    - In the collector, `if referenced_issues: author_asserted = sorted(set(author_asserted + referenced_issues))` (`collector.py:239-241`; `collector-core.ts:213-217`).
    - In the builder, `all_auto_close = set(verified + author_asserted + referenced)` is rendered under `Auto-close issues (author asserted):`. `referenced_only` is therefore always empty (`render_pr_helpers.py:209-211`; `render-pr-helpers.ts:322-327`).
  - **RC4: raw-reference fallback.**
    - With gh unavailable, every extracted token is `#`-prefixed and added to `referenced_issues` unchecked (`collector.py:213-221`; `collector-core.ts:421-429`; `render.py:213-217`; `render.ts:231-235`). RC3 then promotes it to author-asserted.
    - On the MCP path, #588's defect forces gh to unavailable on every run, so this fallback always ran there.
- Signals/evidence supporting it:
  - The observed lists (`#468, #633, #ISO-8601`; `#442, #646, #647, #CR-1`) are in code-point order, which matches the `sorted` / `sortedSet` output of the close-candidates block.
  - `Issues to autoclose` cannot produce these lists. Its inputs are `closingIssuesReferences` integers (`github.py:427-437`) and the strict metadata regex `^\s*[-*]?\s*Issue:\s*(#\d+)\s*$` (`feature_docs.py:125`; `feature-docs-parsers.ts:213`).
  - The attribution to RC3 is an inference from ordering and input constraints, not a replay of the original bundles.
  - Existing tests pin the defective behavior: `test_collect_pr_context.py:375-386` (`test_build_close_candidates_section_promotes_referenced_issues_to_auto_close`) and `render-pr-helpers.test.ts:193-203` (`merges author-asserted and referenced into author auto-close`).
  - These tests pin JIRA extraction:
    - `test_render.py:162-167`
    - `test_feature_docs.py:75-83, 186-193`
    - `test_collect_pr_context.py:161-164, 276, 310`
    - `feature-docs.test.ts:83-87, 221-232`
    - `test_collect_pr_context_part2.py:245`, where the `FakeGh.classify_entity` double treats `ABC-10` as an issue.
- Affected components/modules (paths, services, pipelines):
  - Python (`scripts/dev_tools/pr_context/`):
    - `feature_docs.py` (`extract_issue_references`, line 34)
    - `render_pr_helpers.py` (`extract_issue_references` line 100, `build_close_candidates_section` line 200, `build_issues_to_autoclose_section` line 228)
    - `render_feature_excerpts.py` (`_extract_issue_references`, line 25)
    - `collector.py` (lines 173-270)
    - `models.py`
  - TypeScript (`extensions/drm-copilot/src/lib/pr-context/`):
    - `feature-docs-parsers.ts` (`extractIssueReferences`, line 78)
    - `render-pr-helpers.ts` (`extractIssueReferences` line 162, `buildCloseCandidatesSection` line 313, `buildIssuesToAutocloseSection` line 352)
    - `render-feature-excerpts.ts` (`extractIssueReferences`, line 69)
    - `collector-core.ts` (lines 161-254 and `classifyReferences` / `classifyOne` / `formatRef` at 368-454)
    - `models.ts`

## Proposed Fix

### Design summary (what changes where):
- One bare-number reference pattern is defined once per runtime, in `models.py` / `models.ts`, and all six extractors use it (D1, D6).
- Feature-document and commit-subject references stay as mentions only. The collector no longer copies them into author-asserted. The close-candidates builder lists `author_asserted` alone as author auto-close, and lists `referenced - verified - author_asserted` under `Referenced issues (detected):` (D2).
- Closing targets are verified `closingIssuesReferences` plus the `Issue: #N` metadata pending primary.
  - With gh available, a pending primary is kept only when it classifies as an issue and its fetched state is open. Excluded numbers are never printed in the autoclose section (D3, D5).
  - With gh unavailable and a non-empty list, the list is kept and one non-bullet annotation line is appended (D4).
- The reference-classification loop and the pending-primary selection move into new pure modules `scripts/dev_tools/pr_context/autoclose.py` and `extensions/drm-copilot/src/lib/pr-context/autoclose.ts`. This keeps the collectors under the 500-line cap (D7).

### Boundaries and invariants to preserve:
- Public function names and signatures are unchanged: `extract_issue_references`, `extractIssueReferences` (re-exported by `collector.py:86` and `index.ts:51`), `_extract_issue_references`, `build_close_candidates_section` / `buildCloseCandidatesSection`.
- `build_issues_to_autoclose_section` / `buildIssuesToAutocloseSection` gain only keyword-only / optional parameters with defaults that preserve current output.
- `Issues to autoclose (verified or pending)` ordering is unchanged: verified first, then pending, de-duplicated.
- Section headers and existing fallback strings are unchanged. This covers `===== Issues to autoclose (verified or pending) =====`, `Close candidates`, `Auto-close issues (verified from GitHub PR metadata):`, `Auto-close issues (author asserted):`, `Referenced issues (detected):` and `Referenced issues (classified)` with its `NOTE: Unverified (GitHub unavailable)` suffix.
- `verified` entries are trusted as GitHub's own closing references and are not state-checked.
- #588's empty-list unavailable body `None (GitHub CLI unavailable; closing issues not verified)` and its precedence are unchanged.
- The Python and TypeScript runtimes produce identical section text for identical inputs.
- No production or test file exceeds 500 lines.

### Dependencies or blocked work:
- #588 must be merged into the base tree before #622 executes. See Composition with #588.

### Implementation strategy (what changes, not sequencing):

#### Files/modules to change:
- Python:
  - `scripts/dev_tools/pr_context/models.py`: add `ISSUE_REFERENCE_PATTERN` (compiled `re.Pattern[str]` of `(?<!\w)#\d+(?!\w)` with `re.ASCII`), `AUTOCLOSE_UNVERIFIED_ANNOTATION` and `AUTOCLOSE_PENDING_NOT_OPEN_TEXT`.
  - `feature_docs.py`, `render_pr_helpers.py`, `render_feature_excerpts.py`: the extractors use `ISSUE_REFERENCE_PATTERN`, and docstrings describe bare-number extraction only.
  - `render_pr_helpers.py`: `build_close_candidates_section` fix (D2), plus the `build_issues_to_autoclose_section` annotation and not-open fallback (D4, D5).
  - `scripts/dev_tools/pr_context/autoclose.py` (new): the reference-classification function moved from `collector.py:194-221`, and pending-primary selection (D3, D5).
  - `collector.py`: remove the author-asserted promotion; delegate classification and pending selection to `autoclose.py`; build the autoclose section after pending verification.
- TypeScript:
  - `models.ts`: `ISSUE_REFERENCE_PATTERN` regex literal `/(?<!\w)#\d+(?!\w)/u`, `AUTOCLOSE_UNVERIFIED_ANNOTATION` and `AUTOCLOSE_PENDING_NOT_OPEN_TEXT`.
  - `feature-docs-parsers.ts` (including the doc comment at line 73), `render-pr-helpers.ts`, `render-feature-excerpts.ts`: use the shared pattern.
  - `render-pr-helpers.ts`: the same builder changes as Python.
  - `extensions/drm-copilot/src/lib/pr-context/autoclose.ts` (new): `classifyReferences` / `classifyOne` / `formatRef` moved from `collector-core.ts:368-454`, plus pending-primary selection.
  - `collector-core.ts`: the same collector changes as Python.
  - `extensions/drm-copilot/jest.config.cjs`: per-file threshold entries (see AC).
- Not changed: `render.py` / `render.ts`, which inherit the pattern fix; their commit-subject references remain mention-only. Also unchanged: `collector_documents.py`, `collector-output.ts` (except the imports D7 may require), `github.py`, `gh-client-*.ts`, and all `pr-author` consumer documents.

#### Functions/classes/CLI commands impacted:
- `extract_issue_references` / `extractIssueReferences` (all copies) and `_extract_issue_references`.
- `build_close_candidates_section` / `buildCloseCandidatesSection`.
- `build_issues_to_autoclose_section` / `buildIssuesToAutocloseSection`: new keyword-only `pending_primary_excluded: bool = False` / optional `pendingPrimaryExcluded?: boolean` (default `false`), alongside #588's `gh_available` / `ghAvailable`.
- New in `autoclose.py` / `autoclose.ts`:
  - a reference-classification function (the moved loop);
  - a pending-primary selection function returning the kept refs, an excluded flag, and the `IssueDetails` already fetched for kept refs.
  Names are chosen by the planner; each must carry a docstring or TSDoc.
- The collector entry points `collect_and_write` (`collector.py:129`) and `collectPrContext` (`collector-core.ts:115`), whose behavior changes as described. No CLI flag or MCP input change.

#### Data flow and validation changes:
- Extraction: `ISSUE_REFERENCE_PATTERN` accepts only `#` followed by one or more ASCII digits. The `#` must not follow a word character, and the digits must not be followed by one. `#12-3` yields `#12`; `#12abc`, `#12_`, `abc#12`, `ISO-8601`, `#ISO-8601`, `CR-1` and `#CR-1` yield nothing.
- Classification:
  - With gh available, feature, branch and path refs are classified by `classify_entity` exactly as today. Only strict `#<digits>` tokens now reach it, so no `gh api` call is spent on JIRA-shaped tokens.
  - With gh unavailable, the raw-reference fallback adds only strict tokens to `referenced_issues`. That output appears only in mention-only sections.
- Author-asserted: the collector passes an empty `author_asserted` (nothing in the repository parses a real author assertion), so `Auto-close issues (author asserted):` renders `None (author has not asserted autoclose issues)`.
- Pending primary, with gh available: for each pending ref, in order:
  1. Call `classify_entity`. If the result is not `"issue"` (a pull request, not found, or an unresolved repository), exclude the ref.
  2. Otherwise fetch `issue_details` and keep the ref only if `state.lower() == "open"`. `(unknown)` is excluded.
  Each kept ref's details are reused in the issue digests, so no issue number is fetched more than once per run.
- Pending primary, with gh unavailable: all pending refs are kept, and the D4 annotation is appended.
- Autoclose body precedence, when the ordered list is empty:
  1. gh unavailable: #588 text.
  2. `pending_primary_excluded`: `AUTOCLOSE_PENDING_NOT_OPEN_TEXT`.
  3. Readiness PASS: the existing "no deterministic pending issue" text.
  4. Otherwise: the existing "readiness not PASS" text.
- Autoclose body when the ordered list is non-empty: the bulleted list, followed by `AUTOCLOSE_UNVERIFIED_ANNOTATION` on its own line when gh is unavailable.

#### Error handling and logging updates:
- `classify_entity` already returns `None` rather than raising on not-found or error, and that result excludes the ref. `issue_details` is called only after an `"issue"` classification, so its existing error propagation is unchanged.
- No new logging is required. The exclusion is visible in the rendered section text.

#### Rollback/feature-flag considerations (if applicable):
- No feature flag. Rollback is a revert of the #622 merge commit. The #588 behavior is not affected by a revert, because #622 only adds parameters that default to #588's behavior.

### Technical specifications (interfaces/contracts):

#### Inputs/outputs and formats:
- `AUTOCLOSE_UNVERIFIED_ANNOTATION` (exact, identical in both runtimes, no leading `- `):
  `Unverified: the issues listed above come from feature metadata only and were not checked against GitHub (GitHub CLI unavailable).`
- `AUTOCLOSE_PENDING_NOT_OPEN_TEXT` (exact, identical in both runtimes):
  `None (deterministic pending issue is not an open issue)`
- `ISSUE_REFERENCE_PATTERN` source text (identical in both runtimes): `(?<!\w)#\d+(?!\w)`. It is compiled with `re.ASCII` in Python and written as the regex literal `/(?<!\w)#\d+(?!\w)/u` in TypeScript. Extractors must not rely on the `lastIndex` state of a shared global regex.
- Neither new text literal contains `"` or `\`, so the parity test can match them as quoted literals.

#### Required configuration keys and defaults:
- `gh_available: bool = True` / `ghAvailable?: boolean` (default `true`), from #588.
- `pending_primary_excluded: bool = False` / `pendingPrimaryExcluded?: boolean` (default `false`), new.

#### Backward-compatibility expectations:
- Intended output changes (these are the fix):
  - JIRA-style tokens are no longer extracted anywhere, including the appendix `Referenced issues (detected)`.
  - `Auto-close issues (author asserted):` no longer lists referenced issues.
  - `Referenced issues (detected):` in the close-candidates block now lists referenced-only issues.
  - The new annotation and not-open texts.
- All other output is byte-for-byte unchanged for the same inputs.

#### Performance constraints (latency/throughput/memory):
- `gh api` calls do not increase for any input. JIRA-shaped tokens no longer trigger `classify_entity`. The pending primary adds at most one `classify_entity` call and reuses its `issue_details` fetch.

## Decisions

### D1: Candidate filter
- Options considered:
  - (A) Drop the JIRA alternative and anchor the number: `(?<!\w)#\d+(?!\w)`, defined once per runtime in `models.py` / `models.ts`, used by all extractors, with public function names kept.
  - (B) Keep the pattern and filter the output to `^#\d+$` at the collector.
  - (C) Keep JIRA tokens but route them to a separate non-issue list.
- Trade-offs:
  - (A) Fixes the problem at the source for every consumer, including the appendix displays, and removes wasted `gh api` calls. It changes a pinned extraction contract, so the JIRA tests listed in Root Cause Analysis must be inverted.
  - (B) Leaves six drifting copies and still shows `ISO-8601` in the appendix.
  - (C) Adds surface area for a tracker this repository does not use.
- **Adopted: (A).**

### D2: Prose citations are mentions only
- Options considered:
  - (A) Feature-document and commit references stay classified mentions and never reach an autoclose-labelled list. Remove the referenced-to-author-asserted copy in `collector.py` / `collector-core.ts`. The close-candidates builder lists `author_asserted` only as auto-close, and shows `referenced - verified - author_asserted` as `Referenced issues (detected):`. Only the `Issue: #N` metadata primary ref is a pending closing candidate.
  - (B) Stop harvesting feature-document prose entirely (`issue_refs=[]`) and remove the second context pass.
  - (C) Harvest only metadata lines.
- Trade-offs:
  - (A) Is a minimal change. It keeps `test_collect_pr_context_part2.py:353-354` (second pass receives `["#7"]`) valid and keeps the "Related issues / PRs" consumer output.
  - (B) Loses mentions and changes the `FeatureDocExcerpt` and second-pass contract.
  - (C) Duplicates the existing `primary_issue_ref`.
- **Adopted: (A).** The two tests that pin the old behavior are rewritten:
  - `test_collect_pr_context.py:375` becomes `test_build_close_candidates_section_lists_referenced_issues_as_detected_only`.
  - `render-pr-helpers.test.ts:193` becomes `keeps referenced issues out of author auto-close`.

### D3: Verification policy
- Options considered:
  - (A) Closing targets are verified `closingIssuesReferences` plus the pending primary. With gh available, a pending primary is kept only if it is an issue whose fetched state is open. Excluded numbers are never printed inside the autoclose section. No commit-keyword or branch-suffix detection, and no `github.py` / gh-client changes.
  - (B) Also accept explicit closing keywords in commit messages.
  - (C) Also accept a branch-name `-<N>` suffix.
- Trade-offs:
  - (A) Uses data the collector already fetches (`classify_entity`, `issue_details().state`).
  - (B) Reintroduces citation noise; GitHub honors keywords only on merge to the default branch.
  - (C) Adds a heuristic whose failure modes (for example `-r2` worktree suffixes) were not evaluated.
- **Adopted: (A).** State comparison is case-insensitive against `open`, so REST `open` and GraphQL `OPEN` are both accepted. Any other value, including `(unknown)`, excludes the ref.

### D4: Rendering when validation is unavailable and the list is non-empty
- Options considered:
  - (A) Omit the section entirely.
  - (B) Replace the list with #588's `None (GitHub CLI unavailable; closing issues not verified)` whenever gh is unavailable (the researcher's recommendation).
  - (C) Keep the bulleted list unchanged and append one non-bullet annotation line stating that the listed issues came from feature metadata only and were not verified because the GitHub CLI is unavailable.
- Trade-offs:
  - (A) Breaks #588's acceptance criterion, which requires the section with that exact body in the empty case, and breaks the `pr-author` consumer, which looks for the section.
  - (B) Contradicts #588's H3 test and #588's criterion that non-empty rendering is unchanged. The researcher could not read those verbatim. After D1-D3, the only entries that can appear while gh is unavailable are deterministic `Issue: #N` metadata refs. Dropping them recreates issue impact (b): the item's own issue is left open with no record in the bundle.
  - (C) Keeps the deterministic candidate recorded in the bundle and states the unverified condition in the section itself. The annotation contains `GitHub CLI unavailable`, so a consumer applying `SKILL.md:78` ("If GitHub validation is unavailable/unverified, do not emit `Closes`") can detect the condition. The consumer's choice is outside this item.
- **Adopted: (C).** The exact line is `AUTOCLOSE_UNVERIFIED_ANNOTATION` (see Technical specifications). This changes #588's H3 assertion that the output does not contain `GitHub CLI unavailable`; see Composition with #588. The orchestrator made this decision and recorded the rationale above.

### D5: Signalling an excluded pending primary
- Options considered:
  - (A) Add a keyword-only `pending_primary_excluded: bool = False` / `pendingPrimaryExcluded?: boolean` to the autoclose builder. When the ordered list is empty and the flag is set, render `None (deterministic pending issue is not an open issue)`.
  - (B) Pass the excluded numbers to the builder and print them with a reason.
  - (C) Render the existing "no deterministic pending issue" fallback.
- Trade-offs:
  - (A) Is truthful without printing any number.
  - (B) Places numbers in a section that consumers read as closing targets.
  - (C) Misstates the state, because a deterministic pending issue existed.
- **Adopted: (A)**, following the researcher's recommended text.

### D6: Cross-runtime pattern semantics
- Options considered:
  - (A) Identical pattern text in both runtimes, with Python compiled under `re.ASCII`.
  - (B) Identical pattern text with default flags.
  - (C) Explicit character classes (`[0-9]`, `[A-Za-z0-9_]`).
- Trade-offs:
  - Under Python's default Unicode mode, `\w` and `\d` match non-ASCII letters and digits. The TypeScript `u`-flag regex without `i` matches ASCII only. For example, `#12é` and `#١٢` would differ between the runtimes under (B).
  - (A) Gives identical results and keeps the text identical for a literal parity check.
  - (C) Also gives identical results but departs from the adopted D1 text.
- **Adopted: (A).** This decision was not raised in the research. It follows from D1 and the parity requirement.

### D7: Module placement under the 500-line cap
- Options considered:
  - (A) Put classification and pending selection in new modules `autoclose.py` / `autoclose.ts`, and make net-neutral or net-negative edits in the collectors.
  - (B) Edit the collectors in place.
- Trade-offs:
  - (B) Exceeds the cap. On 2026-09-25 the line counts were: `collector.py` 474, `collector-core.ts` 475, `collector-output.ts` 494, `render-pr-helpers.ts` 481 before #588's additions.
- **Adopted: (A)**, the researcher's recommendation.
- If the builder changes push `render-pr-helpers.ts` or `render_pr_helpers.py` past 500 lines, move `buildIssuesToAutocloseSection` / `buildCloseCandidatesSection` (and the Python equivalents) into `autoclose.ts` / `autoclose.py`, and re-export them from their current module so every existing import, including #588's tests, still resolves.

### D8: Defensive `#` prefixing
- Options considered:
  - (A) Keep the `formatRef` / `f"#{ref}"` normalization as a defensive no-op in the moved classification code, and in `render.py:208` / `render.ts:226`.
  - (B) Remove it.
- Trade-offs:
  - After D1 every input already starts with `#`.
  - (A) Changes no behavior and keeps `render.*` untouched.
  - (B) Removes dead code but widens the diff into `render.*`.
- **Adopted: (A).** The researcher listed both options as acceptable.

## Composition with #588
- **Base tree:** #622's implementation is based on a tree that contains #588's merge; the scheduler serializes the two items. If #588 is not merged when #622 executes, the executor must either:
  - rebase onto `origin/main` after #588 merges; or
  - implement #588's parameter exactly as #588 specifies: keyword-only `gh_available: bool = True` on `build_issues_to_autoclose_section`; optional `ghAvailable` (default `true`) on `buildIssuesToAutocloseSection`; the exact body `None (GitHub CLI unavailable; closing issues not verified)` when unavailable and the ordered list is empty, taking precedence over the PASS / non-PASS fallbacks; and call sites that pass availability.

  With the second route, #588 rebases with a trivial conflict.
- **Composed behavior of `Issues to autoclose (verified or pending)`:**

  | gh | Ordered list | Body |
  |---|---|---|
  | available | non-empty | bulleted list (unchanged) |
  | available | empty, pending excluded | `None (deterministic pending issue is not an open issue)` (#622) |
  | available | empty, PASS | existing PASS fallback (unchanged) |
  | available | empty, non-PASS | existing non-PASS fallback (unchanged) |
  | unavailable | empty | `None (GitHub CLI unavailable; closing issues not verified)` (#588, unchanged) |
  | unavailable | non-empty | bulleted list, then `AUTOCLOSE_UNVERIFIED_ANNOTATION` (#622) |

  #588's rule that non-empty rendering is unchanged holds for gh available. For gh unavailable, #622 deliberately extends it by one appended line (D4).
- **File-by-file overlaps:**
  - `scripts/dev_tools/pr_context/render_pr_helpers.py` and `extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts`: both items edit `build_issues_to_autoclose_section` / `buildIssuesToAutocloseSection`. #588 adds `gh_available` / `ghAvailable` and the empty-unavailable branch. #622 adds `pending_primary_excluded` / `pendingPrimaryExcluded`, the annotation branch, and the not-open branch. #622 alone edits the close-candidates builder and the extractor.
  - `scripts/dev_tools/pr_context/collector.py` (#588 edits the call site near lines 260-264) and `extensions/drm-copilot/src/lib/pr-context/collector-core.ts` (#588 edits near lines 238-242): #622 moves the section build after pending verification. The `gh_available` / `ghAvailable` argument #588 added must be preserved.
  - `extensions/drm-copilot/test/lib/pr-context/render-pr-helpers.test.ts`: #588 adds H1-H4. #622 updates H3 (see below) and leaves H1, H2 and H4 unmodified.
  - `tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py` (a new file from #588, four tests): #622 updates `test_build_issues_to_autoclose_section_lists_pending_refs_when_gh_unavailable` and leaves the other three unmodified. #622's new builder tests may be added to this file while it stays at or below 500 lines.
  - `extensions/drm-copilot/jest.config.cjs`: #588 adds a `render-pr-helpers.ts` threshold entry. #622 adds entries for its own changed files without duplicating it.
  - #588's `executable-resolver.ts` and `pr-context-service-call.ts` are not touched by #622.
- **Required update to #588's H3 assertion (both runtimes):**
  - #588's H3 (`pendingPrimary: ["#7"]`, gh unavailable) and `test_build_issues_to_autoclose_section_lists_pending_refs_when_gh_unavailable` currently assert that the output contains `- #7` and does not contain `GitHub CLI unavailable`.
  - After #622 they must assert that the output contains `- #7`, that the line after `- #7` equals `AUTOCLOSE_UNVERIFIED_ANNOTATION`, and that the output does not contain `None (GitHub CLI unavailable; closing issues not verified)`.
  - The last assertion preserves H3's original intent: the #588 empty-list text is not used for a non-empty list.
- **Line cap:** see D7. New logic goes in `scripts/dev_tools/pr_context/autoclose.py` and `extensions/drm-copilot/src/lib/pr-context/autoclose.ts`.

## Assumptions, Constraints, Dependencies
- Assumptions (environment, data, access):
  - #588's parameter names, default and literal are as quoted above. The orchestrator verified them from #588's `plan.2026-09-25T22-06.md` on `origin/bug/pr-context-gh-detection-false-negative-588`. This spec author did not re-read that plan.
  - The collector normally runs before a PR exists, so `verified` is usually empty.
- Constraints (budget, performance, compatibility):
  - Files stay at or below 500 lines.
  - `hypothesis` and `fast-check` are not dependencies, and none are added. Use parametrized boundary matrices instead.
  - The Python and TypeScript runtimes stay at parity.
- External dependencies (services, libraries, releases): the #588 merge. No new libraries.

## Data / API / Config Impact
- User-facing or API changes: the section text changes listed under Backward-compatibility expectations. The MCP tool schema and CLI flags are unchanged.
- Data or migration considerations: none.
- Logging/telemetry updates (if any): none.
- Compatibility notes (CLI flags, config schemas, versioning): the new builder parameters are optional with behavior-preserving defaults. Existing builder callers compile and run unchanged.

## Test Strategy
- Test-design requirements (binding on every new or changed test):
  - Tests are deterministic. They use no wall-clock reads, randomness, sleeps, retries or real timers.
  - No temporary files. Filesystem access goes through the in-memory `mem_fs_path` fixture (`tests/conftest.py`) and `tree-file-system.ts`.
  - No dependence on remote refs (for example `origin/main`; the CI checkout is depth 1), gitignored state, a real `gh`, network access, spawned processes, or Windows-only paths or drive roots. Git and gh are exercised only through in-process doubles, following the patterns in `test_pr_context_integration.py:22-136` and `collector-core.test.ts:76-110`.
  - Boundary cases use `pytest.mark.parametrize` / `it.each` matrices. Property-based libraries are not installed and are not added.
  - Every new shared literal or pattern has a Python-to-TypeScript literal parity check modelled on `test_freshness_header_literals_match_the_typescript_helper` (`tests/scripts/dev_tools/test_pr_context_freshness.py:288-308`). The check reads the tracked TypeScript source text and asserts that each Python value appears verbatim.
  - Regression tests fail on the pre-fix tree and pass after the fix, for:
    - `#ISO-8601`;
    - `#CR-1`;
    - a prose-cited closed issue;
    - a prose-cited open out-of-scope issue;
    - the unavailable-fallback path.
- Regression tests to add or update:
  - Python, new `tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py`:
    - `test_extractors_reject_non_bare_number_tokens`, parametrized over the three Python extractor functions and the inputs `#ISO-8601`, `#CR-1`, `ISO-8601`, `CR-1`, `UTF-8`, `SHA-256`, `AC-12`, `#12abc`, `#12_`, `abc#12`, `#`, `#١٢`, and empty text.
    - `test_extractors_accept_bare_number_tokens`, parametrized over the three extractors and the inputs `#468` → `["#468"]`, `(#660)` → `["#660"]`, `#12-3` → `["#12"]`, `#12é` → `["#12"]`, `#7 and #7` → `["#7"]`, and a start-of-line `#0` → `["#0"]`.
    - `test_issue_reference_pattern_matches_typescript_literal`.
    - `test_autoclose_literals_match_typescript_source`.
  - TypeScript, new `extensions/drm-copilot/test/lib/pr-context/issue-reference-pattern.test.ts`: `it.each` matrices with the same inputs and expected outputs across the three TypeScript `extractIssueReferences` exports (`feature-docs-parsers`, `render-pr-helpers`, `render-feature-excerpts`).
  - Python, new `tests/scripts/dev_tools/pr_context/test_autoclose.py`: unit tests for the classification and pending-selection functions, using gh doubles:
    - open issue kept;
    - `OPEN` kept;
    - closed excluded;
    - `(unknown)` excluded;
    - `classify_entity` returning `"pull"` excluded;
    - `classify_entity` returning `None` excluded;
    - gh unavailable keeps all refs;
    - `issue_details` called at most once per number.
  - TypeScript, new `extensions/drm-copilot/test/lib/pr-context/autoclose.test.ts`: the same matrix.
  - Python, new `tests/scripts/dev_tools/pr_context/test_autoclose_collector.py`: end-to-end collector tests through `mem_fs_path` and in-process git/gh doubles:
    - `test_collector_excludes_scraped_tokens_from_autoclose_when_gh_unavailable`
    - `test_collector_excludes_prose_cited_closed_issue_from_autoclose`
    - `test_collector_excludes_prose_cited_open_out_of_scope_issue_from_autoclose`
    - `test_collector_excludes_closed_pending_primary_without_printing_it`
    - `test_collector_keeps_open_pending_primary`
    - `test_collector_fetches_each_issue_once`
  - TypeScript, new `extensions/drm-copilot/test/lib/pr-context/collector-core-autoclose.test.ts`: the same six scenarios, one `it` each with matching descriptions.
  - Builder tests, added to #588's `tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py` and `extensions/drm-copilot/test/lib/pr-context/render-pr-helpers.test.ts`:
    - `test_build_issues_to_autoclose_section_appends_unverified_annotation_when_gh_unavailable`
    - `test_build_issues_to_autoclose_section_omits_annotation_when_gh_available`
    - `test_build_issues_to_autoclose_section_renders_not_open_text_when_pending_excluded`
    - `test_build_issues_to_autoclose_section_fallback_precedence`, parametrized over the composed-behavior table
    - TypeScript equivalents with matching descriptions
    - the H3 update described in Composition with #588
  - Updated existing tests:
    - `test_collect_pr_context.py:375` becomes `test_build_close_candidates_section_lists_referenced_issues_as_detected_only`.
    - `render-pr-helpers.test.ts:193` becomes `keeps referenced issues out of author auto-close`.
    - The JIRA-extraction assertions in `test_render.py:162-167`, `test_feature_docs.py:75-83, 186-193`, `test_collect_pr_context.py:161-164, 276, 310` and `feature-docs.test.ts:83-87, 221-232` are inverted to assert that JIRA tokens are not extracted.
    - `test_collect_pr_context_part2.py:245` drops the unreachable `ABC-10` entry.
- Unit tests (pytest) for the fixed behavior and boundaries: as listed above. Jest covers the TypeScript runtime.
- Edge cases and negative scenarios (invalid inputs, missing data, boundary values):
  - the token matrices above;
  - several pending primaries with mixed outcomes, where only kept numbers are printed;
  - a pending primary that is also in `verified`, which is printed once;
  - an empty `readiness_signals`.
- Error handling and logging verification:
  - `classify_entity` returning `None` excludes the ref without raising.
  - `issue_details` is never called for a ref that did not classify as `"issue"`.
- Coverage impact and targets for changed lines/modules:
  - At least 85% line and 75% branch on every new or changed production module in both runtimes, with no regression on changed lines.
  - Python evidence: `poetry run pytest tests/scripts/dev_tools --cov=scripts.dev_tools.pr_context --cov-branch --cov-report=term-missing --cov-report=json:<FEATURE>/evidence/qa-gates/python-coverage-final.json`.
  - TypeScript evidence: the per-file thresholds in `jest.config.cjs`, run with `node run-jest.cjs --coverage` from `extensions/drm-copilot` (the extension `package.json` defines no `test:unit:coverage` script).
  - Baseline coverage evidence goes under `docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/evidence/baseline/`; final and delta coverage evidence goes under `docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/evidence/qa-gates/`. These are canonical evidence kinds; `evidence/coverage/` is not canonical and is matched by the `.gitignore` rule `coverage/`, so files written there would never be committed.
- Toolchain commands to run (format → lint → type-check → test):
  - Python: `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, then the pytest command above.
  - TypeScript (in `extensions/drm-copilot`): `npm run format`, `npm run lint`, `npm run typecheck`, the dependency-cruiser architecture check, then `node run-jest.cjs --coverage`.
- Manual validation steps (if required): none required. The end-to-end collector tests replace manual bundle inspection.

## Acceptance Criteria
- [ ] `scripts/dev_tools/pr_context/models.py` defines `ISSUE_REFERENCE_PATTERN` from the source text `(?<!\w)#\d+(?!\w)` compiled with `re.ASCII`. `extensions/drm-copilot/src/lib/pr-context/models.ts` defines `ISSUE_REFERENCE_PATTERN` as the regex literal `/(?<!\w)#\d+(?!\w)/u`. Check: a grep for `\[A-Z\]\[A-Z0-9\]\+-` over `scripts/dev_tools/pr_context/*.py` and `extensions/drm-copilot/src/lib/pr-context/*.ts` returns no matches.
- [ ] Every Python and TypeScript issue-reference extractor (`extract_issue_references` in `feature_docs.py` and `render_pr_helpers.py`, `_extract_issue_references` in `render_feature_excerpts.py`, and `extractIssueReferences` in `feature-docs-parsers.ts`, `render-pr-helpers.ts` and `render-feature-excerpts.ts`) uses the shared `ISSUE_REFERENCE_PATTERN` and keeps its public name and signature. Check: each extractor source references `ISSUE_REFERENCE_PATTERN`, and `collector.py`'s `__all__` and `index.ts` still export `extract_issue_references` / `extractIssueReferences`.
- [ ] `test_extractors_reject_non_bare_number_tokens` in `tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py` passes for all three Python extractors, including the `#ISO-8601` and `#CR-1` cases. The same cases fail on the pre-fix tree.
- [ ] `test_extractors_accept_bare_number_tokens` in `tests/scripts/dev_tools/pr_context/test_issue_reference_pattern.py` passes for all three Python extractors, including `#12-3` → `["#12"]` and `#12é` → `["#12"]`.
- [ ] `extensions/drm-copilot/test/lib/pr-context/issue-reference-pattern.test.ts` passes with the same rejection and acceptance matrices, and the same expected outputs, for all three TypeScript `extractIssueReferences` exports.
- [ ] `test_issue_reference_pattern_matches_typescript_literal` and `test_autoclose_literals_match_typescript_source` pass. They read the tracked `models.ts` source and assert that the Python pattern text appears between `/` delimiters and that `AUTOCLOSE_UNVERIFIED_ANNOTATION` and `AUTOCLOSE_PENDING_NOT_OPEN_TEXT` appear as double-quoted literals.
- [ ] The existing JIRA-extraction assertions (`test_render.py:162-167`, `test_feature_docs.py:75-83, 186-193`, `test_collect_pr_context.py:161-164, 276, 310`, `feature-docs.test.ts:83-87, 221-232`) are inverted to assert that JIRA-style tokens are not extracted, and they pass. Check: no test in `tests/scripts/dev_tools/` or `extensions/drm-copilot/test/lib/pr-context/` asserts that a `WORD-<digits>` token is extracted as a reference.
- [ ] The collectors no longer copy referenced issues into author-asserted. Check: a grep for `Detected issue references (classified)` in `scripts/dev_tools/pr_context/` and `extensions/drm-copilot/src/lib/pr-context/` returns no matches.
- [ ] `test_build_close_candidates_section_lists_referenced_issues_as_detected_only` (replacing `test_build_close_candidates_section_promotes_referenced_issues_to_auto_close`) and the TypeScript `keeps referenced issues out of author auto-close` (replacing `merges author-asserted and referenced into author auto-close`) pass. Each asserts that referenced-only issues appear under `Referenced issues (detected):` and not under `Auto-close issues (author asserted):`.
- [ ] `test_collector_excludes_scraped_tokens_from_autoclose_when_gh_unavailable` and its TypeScript counterpart pass, and both fail on the pre-fix tree. With spec prose containing `#ISO-8601`, `#CR-1` and `#468`, `Issue: #622` metadata and readiness PASS, the output:
  - contains no `ISO-8601`, `CR-1` or `#468` in `Issues to autoclose (verified or pending)` or under either `Auto-close issues` heading;
  - lists `#622` followed by `AUTOCLOSE_UNVERIFIED_ANNOTATION` in the autoclose section;
  - shows `#468` only in the mention sections, with `Referenced issues (classified)` carrying `NOTE: Unverified (GitHub unavailable)`.
- [ ] `test_collector_excludes_prose_cited_closed_issue_from_autoclose` and its TypeScript counterpart pass, and both fail on the pre-fix tree. With gh available and a prose-cited `#468` classified as a closed issue, `#468` appears in no autoclose-labelled output.
- [ ] `test_collector_excludes_prose_cited_open_out_of_scope_issue_from_autoclose` and its TypeScript counterpart pass, and both fail on the pre-fix tree. With gh available and a prose-cited `#584` classified as an open issue that is not the metadata primary, `#584` appears in no autoclose-labelled output and does appear under `Referenced issues (detected):`.
- [ ] `test_collector_keeps_open_pending_primary` and `test_collector_excludes_closed_pending_primary_without_printing_it`, and their TypeScript counterparts, pass. With gh available:
  - an `Issue: #N` primary whose state is `open` or `OPEN` is listed;
  - a primary that is closed, `(unknown)`, classified `"pull"`, or classified `None` is excluded;
  - the section body is `None (deterministic pending issue is not an open issue)` and contains no excluded number.
- [ ] `test_collector_fetches_each_issue_once` and its TypeScript counterpart pass. For one collector run, the gh double records at most one `issue_details` call per issue number, and no `issue_details` call for a ref that did not classify as `"issue"`.
- [ ] The pending-selection and classification unit tests in `tests/scripts/dev_tools/pr_context/test_autoclose.py` and `extensions/drm-copilot/test/lib/pr-context/autoclose.test.ts` pass, covering every row of the matrix listed in the Test Strategy.
- [ ] `test_build_issues_to_autoclose_section_appends_unverified_annotation_when_gh_unavailable` and its TypeScript counterpart pass. With `pending_primary=["#7"]` / `pendingPrimary: ["#7"]` and gh unavailable, the line after `- #7` equals exactly `Unverified: the issues listed above come from feature metadata only and were not checked against GitHub (GitHub CLI unavailable).`, and that line does not start with `- `.
- [ ] `test_build_issues_to_autoclose_section_omits_annotation_when_gh_available` and its TypeScript counterpart pass. A non-empty list with gh available renders byte-for-byte as before #622.
- [ ] `test_build_issues_to_autoclose_section_fallback_precedence` and its TypeScript counterpart pass for every row of the composed-behavior table in Composition with #588. The gh-unavailable empty-list row renders exactly `None (GitHub CLI unavailable; closing issues not verified)`.
- [ ] #588's H3 in `render-pr-helpers.test.ts` and `test_build_issues_to_autoclose_section_lists_pending_refs_when_gh_unavailable` in `tests/scripts/dev_tools/pr_context/test_render_pr_helpers.py` are updated as specified in Composition with #588 and pass. #588's other builder tests (H1, H2, H4 and the other three Python tests) pass unmodified.
- [ ] The implementation base contains #588's changes. Check: `build_issues_to_autoclose_section` has keyword-only `gh_available: bool = True`, `buildIssuesToAutocloseSection` accepts `ghAvailable` defaulting to `true`, and the collector call sites pass availability.
- [ ] No change is made outside the defined scope. Check: the branch diff against its merge base with `main` contains no change to any of the following:
  - `scripts/dev_tools/pr_context/github.py`
  - `extensions/drm-copilot/src/lib/pr-context/gh-client-*.ts`
  - `extensions/drm-copilot/src/lib/pr-context/executable-resolver.ts`
  - `extensions/drm-copilot/src/lib/pr-context/pr-context-service-call.ts`
  - `.claude/skills/pr-author/SKILL.md`
  - `.agents/skills/pr-author/SKILL.md`
  - `.github/agents/pr-author.agent.md`
  - `.github/prompts/generate-pr.prompt.md`
  - any path under `extensions/drm-copilot/resources/`
- [ ] Every new and changed production and test file is at or below 500 lines. This includes `collector.py`, `collector-core.ts`, `collector-output.ts`, `render_pr_helpers.py`, `render-pr-helpers.ts`, `autoclose.py` and `autoclose.ts`. Check: a line count of each changed file.
- [ ] Test code added by #622 uses no temporary files, remote refs, gitignored state, spawned processes or drive-root paths. Check: a grep over the added lines (`+` lines) of the branch diff against its merge base with `main`, restricted to files under `tests/` and `extensions/drm-copilot/test/`, for `tmp_path|tempfile|mkdtemp|mkdtempSync|os\.tmpdir|origin/|child_process|spawnSync|execSync|(?<![A-Za-z])[A-Za-z]:[\\/]` returns no matches. Pre-existing `origin/...` string literals inside in-process fakes in unchanged lines are outside this check.
- [ ] `extensions/drm-copilot/jest.config.cjs` has a per-file `lines: 85, branches: 75` threshold entry for `./src/lib/pr-context/autoclose.ts` and for each other changed pr-context production file that lacks one. Entries already present (for example `collector-core.ts`, and #588's `render-pr-helpers.ts`) are not duplicated.
- [ ] Coverage on every new or changed production module is at least 85% line and 75% branch in both runtimes, with no regression on changed lines. The evidence is the Python coverage JSON and the Jest coverage summary, both stored under `docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/evidence/qa-gates/`.
- [ ] The full toolchain passes in a single pass in both runtimes:
  - Python: `poetry run black .`, `poetry run ruff check .`, `poetry run pyright`, `poetry run pytest`.
  - TypeScript (`extensions/drm-copilot`): `npm run format`, `npm run lint`, `npm run typecheck`, the dependency-cruiser check, `node run-jest.cjs --coverage`.
- [ ] Docstrings and TSDoc for every changed extractor and builder, including the comment at `feature-docs-parsers.ts:73`, describe bare-number-only extraction and the new builder parameters. Check: a grep for `ABC-123` and `[A-Z][A-Z0-9]+-` in those modules' comments returns no matches.

## Risks & Mitigations
- Technical or operational risks:
  - A consumer that relied on JIRA-style extraction loses those references. No such consumer exists in this repository; the tracker is GitHub.
  - Fail-closed exclusion of a pending primary when `classify_entity` returns `None` (for example, an unresolved repository) drops the item's own issue from the list.
  - Merge conflict with #588 in the builder and at the collector call sites.
  - The annotation line changes #588's H3 contract.
- Mitigations and rollbacks:
  - For the fail-closed exclusion, the section renders the distinct not-open text, so the omission is visible rather than silent.
  - For the #588 conflict, serialized scheduling and a rebase on the #588 merge (see Composition with #588).
  - For the H3 contract change, the H3 update is specified here in both runtimes.
  - Rollback is a revert of the #622 merge.

## Rollout & Follow-up
- Release/rollout steps:
  - Merge after #588.
  - The MCP path serves the installed extension payload, so rebuild and reinstall the extension before relying on the TypeScript runtime locally.
- Post-fix monitoring or clean-up tasks:
  - After #622 merges, confirm that `Auto-close issues (author asserted):` renders its "not asserted" reason in the next PR bundles.
  - Separately, consider whether `render.py,cover` should be ignored. It is out of scope here.
- Links:
  - Issue: https://github.com/drmoisan/drm-copilot/issues/622
  - Sibling: #588 (`bug/pr-context-gh-detection-false-negative-588`)
  - Research: `docs/features/active/collect-pr-context-fabricates-auto-close-issues-622/research/research.2026-09-25T23-33.md`
