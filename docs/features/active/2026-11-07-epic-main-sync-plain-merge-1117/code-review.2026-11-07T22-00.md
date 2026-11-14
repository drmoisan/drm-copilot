# Code Review: epic-main-sync-plain-merge (Issue #1117)

**Review Date:** 2026-11-07
**Scope:** full branch diff against the merge base of origin/main and HEAD

## Executive Summary

The change replaces the dedicated sync child item wording with a plain merge in four skill copies, re-pins one digest, updates the contract test, and adds a ledger entry. The replacement text matches issue.md `## Proposed Behavior`. The Codex copy uses the equivalent wording the issue instructs for the section without numbered steps. No blocking finding.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `.agents/skills/epic-orchestrate/SKILL.md` | main-sync paragraph | Uses "re-fetches the integration tip" and omits "in step 6" because the Codex section has no numbered steps | None | Matches the issue's instruction to apply the same change to the equivalent text and the owner scope note | Diff of the paragraph; pre-change text also ended with "re-fetch the integration tip" |
| Info | `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py` | `contains_phrase` | Comparison made case-insensitive | None | Needed so the kept fragments match at a sentence start in the new text; limited to the test helper and covered by the parametrized tests | Diff; ledger entry lists it among changed items with a revert step |
| Info | `docs/engineering/process-reductions/0007-epic-main-sync-plain-merge.md` | Summary | `Merge commit: pending (PR #1117)` is a stand-in | None | Known pending item replaced by the orchestrator after PR creation | Caller note |

## Review Dimensions

- Correctness: the replacement text in all four copies matches the issue; canonical and bundled copies are byte-identical (shared blob ids). The pinned digest equals the SHA-256 of the file.
- Scope: nothing beyond the named replacement, test updates, and ledger entry. No sync rule, gate, route, or conflict handling was added.
- Tests: the six retired phrases removed, five kept, two pins added, matching the issue. A retired-phrase guard runs over all four surfaces, and a negative test shows it fails when the wording returns. Execution in this review: 56 passed across the contract and surface-contract modules.
- Maintainability: helper is small, documented, and names the offending phrase on failure.
- Security and error handling: no executable production code added.
- File size: the largest changed covered file is 362 logical lines; no Warning rows apply.

## Verdict

PASS. No blocking finding.
