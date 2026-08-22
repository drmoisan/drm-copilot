# orchestrate-blocking-count-rule-cannot-fire (Potential Bug)

- Date captured: 2026-08-22
- Author: Dan Moisan
- Status: Draft
- Found during: #501 orchestration, at the post-review outcome evaluation

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

## Summary

The `orchestrate` skill decides whether to enter the remediation loop by counting lines in `remediation-inputs.<timestamp>.md` that match `BLOCKING` or `Severity: Blocking`, case-sensitive. The `feature-review` agent writes its findings as `Blocking` in mixed case. The count is therefore zero for an artifact that documents genuine blocking findings, and the rule advances straight to the PR creation gate. The gate cannot fire for the casing this repository's own review agent actually produces.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: n/a - the rule is prose in a skill document, applied by the orchestrating agent
- Command/flags used: `grep -c "BLOCKING\|Severity: Blocking" <remediation-inputs path>`
- Data source or fixture: `.claude/skills/orchestrate/SKILL.md` `## Post-Review Outcome Evaluation`, and `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501/remediation-inputs.2026-08-21T22-23.md` at commit `6a8d59f3`

## Steps to Reproduce

1. Run a `feature-review` delegation that produces at least one blocking finding, so a `remediation-inputs.<timestamp>.md` is written to the active feature folder.
2. Apply the skill's rule verbatim: count lines matching `BLOCKING` or `Severity: Blocking`, case-sensitive.
3. Compare that count against the number of blocking findings the review actually reported.
4. Search the same artifact case-insensitively for `blocking` to see where the findings are recorded.

## Expected Behavior

The count equals the number of blocking findings the review reported, so a review with one blocking finding enters the remediation loop.

## Actual Behavior

Observed on the #501 artifact: the case-sensitive count is **0** while the review reported **1** blocking finding, a coverage regression on two modified hooks. The artifact records the finding as:

- `- **Cycle trigger:** one Blocking finding in policy-audit...`
- `## Blocking finding to remediate`
- `### Fix 1 - restore tail coverage in the two batch-budget hooks (Blocking)`

Every occurrence is mixed-case `Blocking`. Neither `BLOCKING` nor the literal `Severity: Blocking` appears anywhere in the file.

Applied mechanically, the rule concludes zero blocking findings and advances to the PR creation gate, shipping an unremediated coverage regression that violates the no-regression-on-changed-lines rule. In the #501 run the orchestrator entered the remediation loop on the substance of the review's stated verdict instead, so nothing was shipped - but that depended on reading the review's prose, not on the rule.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: a case-sensitive count over the #501 remediation-inputs artifact returns `0`. A case-insensitive search over the same file returns four lines, at lines 3, 6, 11, and 13, each recording the same single blocking finding.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

High. The rule is the sole documented mechanism deciding whether blocking review findings are remediated before a PR is opened. While it cannot fire, that decision rests entirely on the orchestrating agent reading the review's prose verdict, which is not a gate. The failure direction is permissive: findings are silently treated as absent.

Not marked Blocker because no unremediated finding is known to have shipped through it; the defect is a gate that does not gate, not an observed escape.

## Suspected Cause / Notes

- The rule's two literals look like they were written against an artifact convention (`BLOCKING`, or a `Severity: Blocking` field) that the current `feature-review` templates do not use.
- This is the same defect class as issue #501 and as the AC-13 finding that preflight caught inside #501's own plan: a verification step that reads as enforcement but cannot detect the condition it exists to detect. Three independent instances in one workstream suggests the class is worth a deliberate sweep rather than case-by-case fixes.
- A count-based rule over free prose is fragile in general. A structured severity field in the review artifacts, asserted by the review-output validator, would be checkable rather than greppable.

## Proposed Fix / Validation Ideas

- [ ] Decide the canonical representation of a blocking finding in review artifacts, then make the templates, the skill rule, and any validator agree on it. Prefer a structured field over a prose literal.
- [ ] Make the matching case-insensitive at minimum, as the immediate low-risk correction.
- [ ] Unit coverage areas: the count applied to real artifacts produced by `feature-review`, including one with zero findings, one with a single blocking finding, and one with mixed severities.
- [ ] Add a falsifiability check: a test that fails if the rule returns zero against an artifact that records a blocking finding, so the gate cannot silently stop working again.
- [ ] Consider whether the same literal-matching fragility affects other prose-counting rules in `.claude/skills/`, and sweep if so.
- [ ] Consider having the review-output validator hook reject a review artifact whose findings cannot be parsed into the canonical severity representation, so an unparseable artifact fails loudly rather than counting as clean.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
