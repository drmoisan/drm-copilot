# repair-invalid-codex-skill-frontmatter (Issue #549)

- Date captured: 2026-08-25
- Author: Dan Moisan
- Status: Promoted -> docs/features/active/repair-invalid-codex-skill-frontmatter/ (Issue #549)

> Automation note: Keep the section headings below unchanged; the promotion tooling maps each of them into the GitHub bug issue template.

- Issue: #549
- Issue URL: https://github.com/drmoisan/drm-copilot/issues/549
- Last Updated: 2026-08-25
- Work Mode: full-bug

## Summary

Codex-native skill definitions contain invalid YAML frontmatter in both the
canonical `.agents/skills/*/SKILL.md` tree and its bundled mirror. Consumers
report frontmatter validation errors, including duplicate `description` keys;
the current audit identifies invalid `paths` fields and unquoted descriptions
as the remaining active defects.

## Environment

- OS/version: Windows development worktree
- Python version: Not applicable to the validation target
- Command/flags used: Repository skill-frontmatter validation over canonical and bundled trees
- Data source or fixture: 27 unique canonical skill definitions and 27 matched bundled mirrors (54 `SKILL.md` files)

## Steps to Reproduce

1. Discover all 27 `.agents/skills/*/SKILL.md` definitions in the canonical skill tree and their matched bundled mirrors.
2. Parse each file's YAML frontmatter using the repository skill validator.
3. Observe validation failures for unsupported `paths` fields, descriptions containing an unquoted `: ` sequence, descriptions containing angle brackets, or the five identified body-level guidance/reference defects.

## Expected Behavior

Every skill frontmatter document parses successfully under the repository validator, uses only supported schema fields, and is byte-identical to its matched bundled mirror. The four evidence-location guidance corrections and one translation body-reference correction also satisfy live validation.

## Actual Behavior

The root audit identifies 23 invalid frontmatter definitions in each tree: 12 unsupported `paths` fields, two descriptions containing `: ` that require YAML quotes, and nine descriptions containing angle brackets. No duplicate keys currently remain, although prior validator failures have reported duplicate `description` keys. The live hook additionally requires five narrow body corrections: evidence-location content in `research-issue`, `orchestrate`, `evidence-and-timestamp-conventions`, and `epic-plan`, plus a Codex-runtime body reference correction in `translate-claude-to-codex`.

## Logs / Screenshots

- [x] Attached minimal logs or screenshot
- Snippet: Root audit count: 23 invalid frontmatter definitions per tree; live hook scope: 27 canonical/bundled skill pairs (54 files), including five required body guidance/reference corrections.

## Impact / Severity

- [ ] Blocker
- [x] High
- [ ] Medium
- [ ] Low

## Suspected Cause / Notes

The canonical and bundled skill documents appear to have diverged from the
frontmatter schema and YAML quoting requirements. The original 23 repairs are
frontmatter-only. Five narrowly scoped body changes are also required by the
live hook: canonical evidence-location guidance in `research-issue`,
`orchestrate`, `evidence-and-timestamp-conventions`, and `epic-plan`, and a
Codex-runtime body reference in `translate-claude-to-codex`. Do not otherwise
alter skill body behavior, workflow sequencing, artifacts, validation gates,
remediation triggers, or completion requirements.

## Proposed Fix / Validation Ideas

- [ ] Unit coverage areas: Add or update only the repository validation coverage required for frontmatter parsing and mirror parity, if existing validation tests require changes.
- [ ] Integration scenario to retest: Run the repository skill-frontmatter validator across both complete trees after the repair.
- [ ] Manual verification notes: Confirm all 27 matched canonical/bundled pairs (54 files) parse and have byte parity, and live validation accepts the five body guidance/reference corrections.

## Next Step

- [x] Promote to GitHub issue (bug-report template)
- [x] Move to active fix folder / branch
