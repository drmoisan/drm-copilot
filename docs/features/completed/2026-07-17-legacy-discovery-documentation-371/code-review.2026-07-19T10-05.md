# Code Review — legacy-discovery-documentation (#371), Remediation Cycle 1 Reaudit

- Reviewed branch: `feature/legacy-discovery-documentation-371` @ `0f32c6d8`
- Timestamp: 2026-07-19T10-05
- Scope: this feature delivers no production code. All six deliverables remain Markdown
  documentation files under `docs/engineering/legacy-discovery-and-parity/`. This reaudit
  focuses on the one file changed by the remediation commit
  (`consumer-onboarding.md`), re-verified against live repo state independent of the
  executor's own evidence, and confirms the other five pages are unchanged.

## Diff Scope of the Remediation Commit

`git show --stat 0f32c6d8` (26 files) and `git diff de2cc7f9 0f32c6d8 -- docs/engineering/`
confirm the only production-documentation change is to
`docs/engineering/legacy-discovery-and-parity/consumer-onboarding.md` (net +45/-16 lines
inside the file's "What Is Delivered, and How" and "Onboarding Sequence" sections). The
remaining 25 changed files are review/evidence artifacts under
`docs/features/active/2026-07-17-legacy-discovery-documentation-371/` (policy-audit,
code-review, feature-audit, remediation-inputs, remediation-plan, and their supporting
`evidence/{remediation-baseline,qa-gates,other}/` files). `README.md`, `workflow.md`,
`domain-profile.md`, `artifacts-and-schemas.md`, and `running-the-workflow.md` are
byte-identical to `de2cc7f9` (confirmed: `git diff de2cc7f9 0f32c6d8 -- docs/engineering/
legacy-discovery-and-parity/README.md docs/engineering/legacy-discovery-and-parity/
workflow.md docs/engineering/legacy-discovery-and-parity/domain-profile.md
docs/engineering/legacy-discovery-and-parity/artifacts-and-schemas.md docs/engineering/
legacy-discovery-and-parity/running-the-workflow.md` produces no output).

## Accuracy Re-Check of the Corrected Passage

The previously-Blocking claim ("the seven discovery schemas and initialization templates
reach a consumer repository as Python source/data through the `@danmoisan/drm-copilot-mcp`
npm package") is removed. The replacement claim was independently re-derived from source,
not accepted from the executor's evidence trail:

- **`packages/mcp-server/package.json`** — `"files": ["out/mcp-server.js", "resources"]`.
  Read directly; neither asset tree is listed.
- **`packages/mcp-server/prepack.cjs`** — `shouldCopy()` excludes any path ending in `.py`
  and any path containing a `scripts/`-segment when copying `extensions/drm-copilot/
  resources/` into the package's `resources/` directory. Read directly; no allow-list
  carve-out exists for either asset tree.
- **`extensions/drm-copilot/resources/**`** — contains discovery hooks and discovery
  skills only (`enforce-discovery-artifact-gate.ps1`, `validate-discovery-artifact-gate.ps1`,
  `.claude/skills/discovery-*/SKILL.md`); zero occurrences of `schemas/discovery` or
  `docs/discovery/templates` content anywhere in the tree (independent `find`/`grep`, not
  a re-run of the executor's own recorded command).
- **`packages/mcp-server/**`** — zero occurrences of either asset tree.

The corrected sentence — "no consumer-facing distribution mechanism currently exists for the
schemas and initialization templates" — is now the accurate statement given this evidence.
The corrected passage also correctly distinguishes the *design classification* decision
(`legacy-discovery-publishing-372`'s "scripts-non-mirrored" decision, verified present at
that spec's `## Schema/Init-Template Placement — Resolved` heading) from an actual delivery
mechanism, explicitly stating the decision "does not itself deliver a distribution
mechanism." This is a precise, well-hedged correction, not an overcorrection into vague
language.

## Structural and Consistency Re-Check

- **Internal consistency**: the corrected item 2, the corrected introductory sentence
  ("Item 1 below is delivered... Item 2 below is not delivered..."), and the corrected
  Onboarding Sequence step 2 are mutually consistent — none of the three passages
  contradicts another, and step 2 explicitly cross-references item 2 rather than
  re-stating the gap independently (reducing future drift risk if only one location is
  updated).
- **No duplication introduced**: the correction does not restate `legacy-discovery-
  publishing-372`'s spec content; it names the decision and cites the section heading,
  consistent with the doc set's established no-per-feature-duplication pattern.
- **Cross-reference integrity preserved**: the corrected file's five relative links
  (`README.md#domain-neutrality-invariant`, `running-the-workflow.md` ×2,
  `domain-profile.md`, `workflow.md`) are unchanged from the pre-remediation version and all
  resolve to files present in the same directory.
- **No new naming-collision or domain-neutrality issue**: independently reran both greps on
  the corrected file; zero naming-collision matches, and all `TaskMaster`/`TMW` mentions
  remain confined to the intro-scoping sentence and the labeled Worked Example section.

## Regression Check Against Prior Cycle's Verified Findings

The prior code-review's "Strengths" findings (the 18-row CLI table matching
`pyproject.toml`, the MCP-tool-to-CLI consolidation table, the domain-profile contract-field
table matching `domain_profile_models.py`, the `GOVERNED_GLOBS` verbatim match) concern
pages that were not touched by the remediation commit (`running-the-workflow.md`,
`domain-profile.md`, `artifacts-and-schemas.md` are byte-identical to `de2cc7f9`, confirmed
above), so those findings still hold without re-derivation of the underlying source facts.
The "Minor Observations" (agent/skill naming precision, Python-interpreter-resolution
sentence) likewise concern unchanged files.

## Overall Code-Review Verdict

**PASS.** The single prior Blocking accuracy defect in `consumer-onboarding.md` is corrected
and independently re-verified against live packaging code. The correction is internally
consistent, does not introduce new duplication, naming collisions, domain-neutrality
violations, or broken links, and does not touch any of the other five doc pages. No
regression was found in any previously-verified accuracy finding.
