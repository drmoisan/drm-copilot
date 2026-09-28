# collect-pr-context-fabricates-auto-close-issues (Issue #622)

- Date captured: 2026-09-25
- Author: Dan Moisan
- Status: Active (issue pre-existed on GitHub; no potential entry was created or promoted)

> Provenance note: `new_active_feature_folder` created this folder without a potential source and did not emit an `issue.md`. This file mirrors the GitHub issue body and its comment verbatim as of 2026-09-25 so downstream agents have a local requirements source.

- Issue: #622
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/622
- Last Updated: 2026-09-25
- Work Mode: full-bug

## Summary

The PR-context collector (backing `mcp__drm-copilot__collect_pr_context` and consumed by the `pr-author` skill) has produced a wrong, garbage-laden auto-close issue list on multiple consecutive invocations in the same session, while simultaneously reporting `gh` as unavailable — even though `gh` is installed and answers every direct query. The two defects compound dangerously: one invents issue numbers, and the other disables the live-verification step that would otherwise catch it.

## Observed instances (TaskMaster, `bugs-638-644-647` parallel run, 2026-09-01/02)

| Item | Bundle's scraped auto-close list | Reality |
|---|---|---|
| #633 | `#468`, `#633`, `#ISO-8601` | `#468` is a different, already-closed issue merely *cited* in the spec text; `#ISO-8601` is a parse artifact scraped out of timestamp prose, not an issue reference at all |
| #646 | `#442`, `#646`, `#647`, `#CR-1` | `#442` and `#647` are unrelated, already-closed issues; `#CR-1` is a code-review finding ID, not a GitHub issue |
| #648 | 18 entries total | 9 not issue numbers at all; 7 closed and unrelated; and **`#584`, which is OPEN and explicitly out of scope for the item** — emitting this would have posted a closing keyword against live, unrelated work |

In every one of these runs, `pr_context.summary.txt` reported `"GitHub CLI unavailable: GitHub CLI (gh) is not installed."` while `gh` (v2.87.3 in this environment) answered `gh issue view`, `gh pr view`, etc. without issue when invoked directly in the same session.

## Impact

- **Correctness:** a consumer of this bundle that trusts the scraped list either (a) closes an unrelated, sometimes still-open issue via a fabricated closing keyword, or (b) — if it follows the documented `pr-author` fallback for unavailable GitHub validation — suppresses the `Closes` bullet entirely and silently leaves its own, actually-verified issue open.
- **Silent failure mode:** because the `gh`-unavailable report is itself false, there is no signal to a consumer that the auto-close list is unverified; it looks like a normal, if empty-validation, run.
- Each instance above was only caught because the consuming agent independently ran `gh pr view --json closingIssuesReferences` / `gh issue view` against the actual PR/issue rather than trusting the bundle, and treated the false-unavailable report itself as suspicious given a known-working `gh` install.

## Suggested direction

1. Fix (or re-verify) the `gh` availability probe used by the collector — it is producing a false negative in an environment where `gh` demonstrably works.
2. Whatever is scraping candidate issue numbers into the auto-close list needs a sanity filter: reject tokens that aren't parseable as a bare issue number, and verify each surviving candidate against GitHub (open/closed state, and whether it is *actually* closed by this diff) before including it — rather than emitting an unverified scrape.
3. Consider: when GitHub validation is unavailable, the collector should say so unambiguously and omit the auto-close section entirely, rather than including a scraped list that a downstream consumer might mistake for verified data.

## Evidence

- Found independently by execution children on three consecutive items (633, 646, 648) in the same parallel-orchestration run, each verifying against GitHub directly rather than trusting the bundle.
- `gh --version` in the same environment: 2.87.3.

## Issue comment (mirrored)

> Corroborating instance from item #670's feature review in TaskMaster's `bugs-638-644-647` parallel run (2026-09-02), adding a nuance worth folding into the fix: the "docs-misclassification silently disables the C# coverage gate" mechanism described above has **two independently sufficient causes**, not one. [...]
>
> Also reconfirmed independently on items #646, #648, #656, #662, and #663 (each hit the fabricated-auto-close-list defect separately, verifying and excluding the bad entries every time) — this is now 5 of 9 items checked in that run showing the defect, not an isolated occurrence.

The first paragraph of the comment concerns a C# coverage-gate classification mechanism that is not described in this issue; it appears to belong to a different issue and is out of scope here. The second paragraph corroborates this issue.

## Scope boundary with issue #588

- Issue #588 (`pr-context-gh-detection-false-negative`, branch `bug/pr-context-gh-detection-false-negative-588`) owns suggested direction item 1: the gh-availability false negative, plus the distinct "None (GitHub CLI unavailable; closing issues not verified)" autoclose text when gh is unavailable and the list is empty.
- This issue owns suggested direction items 2 and 3: candidate scraping and filtering, verification of surviving candidates against GitHub state and against whether this change closes them, the raw-reference fallback, and how the autoclose section renders when validation is unavailable.
