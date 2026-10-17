# pushed-tier-rule-not-gated-on-adoption (Issue #823)

- Date captured: 2026-10-03
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/pushed-tier-rule-not-gated-on-adoption/ (Issue #823)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #823
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/823
- Last Updated: 2026-10-03
- Work Mode: full-bug

## Summary

The push-down sends the module rigor tier rule to consuming repositories that never adopted the tier system. Their agents are then bound to a `quality-tiers.yml` file and a `tier-classification` CI stage that do not exist, and they see two competing coverage-threshold authorities. This supersedes FU-734-4 in `docs/features/potential/2026-09-29-issue-734-quality-tiers-follow-ups.md`. It differs from #621, whose destination exclusion manifest lets a repository opt out of a path but does not make the pushed rule text conditional.

## Environment

- OS/version: Windows 11 Pro 10.0.26200
- Python version: repository Poetry environment
- Command/flags used: `push_down_claude_customizations` into a consuming repository that has its own `CLAUDE.md` coverage thresholds and no `quality-tiers.yml`
- Data source or fixture: main at 93725814; pushed copies under `extensions/drm-copilot/resources/claude-customizations/.claude/rules/`

## Steps to Reproduce

1. Run the Claude push-down into a consuming repository that has no `quality-tiers.yml` and states its own coverage thresholds in its root `CLAUDE.md`.
2. Inspect `.claude/rules/quality-tiers.md`, `.claude/rules/general-code-change.md` ("Module Rigor Tiers") and `.claude/rules/general-unit-test.md` in that repository.
3. Run a feature review on any unrelated change in that repository.

## Expected Behavior

- A repository without `quality-tiers.yml` receives rule files that impose no tier classification, no tier-classification CI stage and no tier-dependent gates (mutation score, property-test density, golden tests).
- A repository with `quality-tiers.yml` keeps the current tier behavior unchanged.
- The pushed coverage rules state that the consuming repository's own root `CLAUDE.md` thresholds govern when present. The pushed 85/75 figures are the default only when the repository states none.
- Feature review flags a missing `quality-tiers.yml` only when the repository has adopted tiers.

## Actual Behavior

- `quality-tiers.md` states as fact that `quality-tiers.yml` maps every project to a tier and that an unclassified project fails CI.
- `general-code-change.md` states without condition: "Every project must be classified in `quality-tiers.yml` at repo root."
- `general-unit-test.md` and `quality-tiers.md` set uniform 85% line / 75% branch thresholds that contradict the consuming repository's `CLAUDE.md`, and no precedence is defined between them.
- Feature-review agents report the missing file as a finding on unrelated reviews.
- The consuming repository cannot fix any of this locally, because these files are push-down owned and are overwritten on the next push-down.

## Logs / Screenshots

- [ ] Attached minimal logs or screenshot
- Snippet: `Module rigor tiers (T1–T4) ... Every project must be classified in quality-tiers.yml at repo root.` (general-code-change.md line 29)

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

- The rule text was written for this repository, which has adopted tiers, and is pushed down verbatim.
- Pushed `quality-tiers.md` also carries TaskMaster-specific tier examples. Requirement 5 below forbids naming a consuming repository in pushed files, so the spec must decide whether those examples are in scope.
- Mirror surfaces (`.github/instructions/*`, `.agents/skills/*`, the bundled codex-and-agents and copilot customizations) carry the same wording. Assess them for parity.

## Proposed Fix / Validation Ideas

Required change:

1. Gate the tier rule on adoption. Preferred: state at the top of `quality-tiers.md` that it applies only when `quality-tiers.yml` exists at the repository root. Alternative: exclude `quality-tiers.md` from push-down unless the target repository is configured to receive it, using the existing push-down configuration surface (for example the #621 exclusion manifest), not a hard-coded repository list.
2. Make the "Module Rigor Tiers" section of `general-code-change.md` conditional in the same way.
3. Define threshold precedence in `general-unit-test.md` and `quality-tiers.md`: the consuming repository's root `CLAUDE.md` thresholds govern when present.
4. Update the feature-review guidance (agent or skill) so a missing `quality-tiers.yml` is a finding only when tiers have been adopted.
5. Do not add repository-specific templating or name any consuming repository in pushed files.

Validation:

- [ ] Unit coverage areas: add a test over the push-down output or the pushed rule text that fails if the unconditional "must be classified in `quality-tiers.yml`" wording reappears.
- [ ] Integration scenario to retest: bundled-payload parity tests stay green.
- [ ] Manual verification notes: the repository's full toolchain passes, and this repository's tier behavior is unchanged.

## Next Step

- [ ] Promote to GitHub issue (bug-report template)
- [ ] Move to active fix folder / branch
