# Policy Audit — legacy-discovery-documentation (#371), Remediation Cycle 1 Reaudit

- Reviewed branch: `feature/legacy-discovery-documentation-371` @ `0f32c6d8`
- Base: `epic/legacy-discovery-and-parity-integration` @ `b7be1a85` (resolved merge base, per
  `artifacts/pr_context.summary.txt`)
- Work mode: `full-feature` (verified from `issue.md` line 10: `- Work Mode: full-feature`)
- Scope verified: full branch diff (`git diff --stat b7be1a85..0f32c6d8`), 42 files changed
  (26 files changed by the remediation commit `0f32c6d8` alone, per `git show --stat`). All
  changed files across the full range are Markdown: six capability doc pages under
  `docs/engineering/legacy-discovery-and-parity/`, and feature-folder/evidence Markdown under
  `docs/features/active/2026-07-17-legacy-discovery-documentation-371/`. Zero TypeScript,
  Python, PowerShell, or C# files changed anywhere in the range (confirmed via
  `git diff --name-only b7be1a85 0f32c6d8 -- '*.py' '*.ts' '*.tsx' '*.ps1' '*.cs'`, zero
  output).
- Prior review: `policy-audit.2026-07-19T09-20.md` found exactly one Blocking finding
  (reconciliation-accuracy defect in `consumer-onboarding.md` item 2). This reaudit
  independently re-verifies the remediation commit `0f32c6d8` against live repo state; it
  does not accept the executor's own evidence artifacts as proof.
- Timestamp: 2026-07-19T10-05
- Note: this artifact is written into this agent's own sandboxed worktree copy per tooling
  constraints (`...\agent-a325b0d6ea3a6e287`), using the feature-relative path; all
  verification commands were run against the actual reviewed worktree
  (`...\agent-ae68d14e27bb8727e`, HEAD `0f32c6d8`).

## Rejected Scope Narrowing

None. No caller instruction in this task attempted to narrow scope to a plan/task/phase
subset, a single file, or a "remediation only" boundary that would exclude re-verifying the
rest of the doc set. The task instructions explicitly required (a) re-verification of the
fix against live repo state independent of the executor's own evidence, (b) confirmation
that no other doc page needed touching, and (c) confirmation that the full spec.md/
user-story.md AC sets remain satisfied — all consistent with the Scope Invariant and
followed as given.

## Policy Reading Order

Read in the required order: `CLAUDE.md`, `.claude/rules/general-code-change.md`,
`.claude/rules/general-unit-test.md`, `.claude/rules/tonality.md`. Confirmed no
language-specific rule file applies: the full branch diff (base to head) contains zero
TypeScript, Python, PowerShell, or C# files, so `.claude/rules/{python,powershell,
typescript,csharp}.md` are not in scope for this review.

## Coverage Verification

**N/A for all four tracked languages — zero changed files on this branch for each,
confirmed independently for the full branch diff (not just the remediation commit).**

| Language | Changed files in branch diff | Coverage artifact required? | Verdict |
|---|---|---|---|
| TypeScript | 0 | No | N/A (no changed files) |
| Python | 0 | No | N/A (no changed files) |
| PowerShell | 0 | No | N/A (no changed files) |
| C# | 0 | No | N/A (no changed files) |

This is a direct, verified consequence of the branch diff containing only Markdown files
(`git diff --name-only b7be1a85 0f32c6d8` above; every changed path ends in `.md`). Per the
Coverage Verification section's own text, coverage artifacts are mandatory only for
languages "that has changed files in the feature branch"; none do here. `N/A` is the
correct, policy-compliant verdict because it reflects zero changed files, not an exemption
for a language with changed files.

## Evidence Location Compliance

Scanned the full branch diff for files under `artifacts/baselines/**`, `artifacts/qa/**`,
`artifacts/evidence/**`, `artifacts/coverage/**`:

```
git diff --stat b7be1a85..0f32c6d8 -- 'artifacts/baselines/**' 'artifacts/qa/**' 'artifacts/evidence/**' 'artifacts/coverage/**'
(no output — zero matches)
```

Ran `scripts/dev_tools/validate_evidence_locations.py --root .` against the checked-out
reviewed worktree: exit code `0`, zero output, zero violations reported.

All evidence produced by this feature's execution and remediation lives under the canonical
`docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/{baseline,
remediation-baseline,qa-gates,other}/` tree. No non-canonical evidence path violation found.
`EVIDENCE_LOCATION_OVERRIDE_REJECTED` was not triggered — no delegation prompt in this
review specified a non-canonical evidence path.

**Verdict: PASS.**

## Reconciliation Accuracy — Independently Re-Verified (Prior Blocking Finding)

The prior cycle's single Blocking finding concerned `consumer-onboarding.md` item 2's claim
that the `@danmoisan/drm-copilot-mcp` npm package ships the seven discovery schemas and the
initialization templates. This reaudit independently re-derived every fact underlying that
claim directly from live repo state — not from the executor's remediation evidence, and not
from `legacy-discovery-publishing-372`'s spec.md prose:

1. **`packages/mcp-server/package.json` `files` field** — read directly: `["out/mcp-server.js",
   "resources"]`. Neither `schemas/discovery` nor `docs/discovery/templates` is listed.
2. **`packages/mcp-server/prepack.cjs` exclusion logic** — read directly: `shouldCopy()`
   copies from `extensions/drm-copilot/resources/` into `packages/mcp-server/resources`,
   excluding every path ending in `.py` and every path containing a `scripts/`-segment. No
   allow-list entry or special case copies `schemas/discovery/v1/` or
   `docs/discovery/templates/`.
3. **`extensions/drm-copilot/resources/**` tree scan** — `find extensions/drm-copilot/
   resources -ipath "*discovery*"` returns only discovery hooks (`.claude/hooks/
   {enforce,validate}-discovery-artifact-gate.ps1`) and discovery skills
   (`.claude/skills/discovery-*/SKILL.md`); zero hits for `schemas/discovery` or
   `docs/discovery/templates` content.
4. **`packages/mcp-server/**` scan** — `find packages/mcp-server -ipath "*discovery*"`
   returns zero hits.
5. **Corrected claim's own cross-reference verified** — `docs/features/active/
   2026-07-17-legacy-discovery-publishing-372/spec.md` contains a
   `## Schema/Init-Template Placement — Resolved` heading (confirmed by direct grep) that
   documents `Decision: scripts-non-mirrored`, matching the corrected page's citation.

**Verdict: PASS.** The corrected claim ("no consumer-facing distribution mechanism
currently exists for the schemas and initialization templates") is independently
corroborated against live packaging code, not merely against the executor's own evidence
trail.

## Corrected-File Deep Re-Check (Item 2 and Onboarding Sequence Step 2)

Read `docs/engineering/legacy-discovery-and-parity/consumer-onboarding.md` in full on the
reviewed worktree. Confirmed:

- Item 2 of "What Is Delivered, and How" states plainly: "no consumer-facing distribution
  mechanism currently exists for the schemas and initialization templates" and explains why
  (`@danmoisan/drm-copilot-mcp` does not ship them; neither push-down CLI mirrors them
  either), citing `legacy-discovery-publishing-372`'s spec.md "Resolved" section by name as
  the classification-decision source, and explicitly states the decision "does not itself
  deliver a distribution mechanism."
- Onboarding Sequence step 2 states "There is currently no automated step by which the
  consumer repository receives the discovery schemas and initialization templates," cross-
  references item 2, and describes the interim manual-retrieval path.
- No remaining sentence in the file asserts or implies the gap is closed (`git diff de2cc7f9
  0f32c6d8 -- .../consumer-onboarding.md` shows both passages replaced consistently; no
  contradicting text remains, confirmed by re-reading the full corrected file end to end).

**Verdict: PASS.**

## No-New-Defect Re-Checks on the Corrected File (Independent Reruns)

| Check | Command (independently rerun by this review) | Result |
|---|---|---|
| Naming collision | `grep -ni -E "modernize-\|legacy-analyst\|business-rules-extractor" consumer-onboarding.md` | Zero matches (exit 1) — PASS |
| Domain neutrality | `grep -n "TaskMaster\|TMW" consumer-onboarding.md` | All matches confined to the intro-scoping sentence (line 5) and the labeled "Worked Example" section (lines 85–96); none presented as framework behavior — PASS |
| Broken relative links | `grep -on "\[[^]]*\]([^)]*)" consumer-onboarding.md` | 5 links: `README.md#domain-neutrality-invariant` (anchor confirmed present — `## Domain-Neutrality Invariant` heading in README.md), `running-the-workflow.md` (×2), `domain-profile.md`, `workflow.md` — all five targets exist in the same directory — PASS |
| New inaccuracy scan | Full-file read plus fact-checks in "Reconciliation Accuracy" section above (MCP tool names, push-down CLI script names, `core` pack-manifest membership, four-agent-persona count, seven-skill count, two-hook count) | All facts independently corroborated against `extensions/drm-copilot/src/**`, `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, and `.claude/agents/*.md` — PASS |

**Verdict: PASS.** No new inaccuracy, domain-neutrality violation, naming collision, or
broken link was introduced by the remediation edit.

## Full Six-Page Doc Set — No Regression Re-Check

Reran the domain-neutrality, naming-collision, and link-resolution checks across all six
pages (not just the corrected file), to confirm the fix did not regress anything verified in
the prior cycle:

- Domain neutrality (`grep -n -i -E "TaskMaster|TMW|Outlook|VSTO|email|task-management"` on
  `README.md`, `workflow.md`, `domain-profile.md`, `artifacts-and-schemas.md`,
  `running-the-workflow.md`): all matches are the same ones catalogued in the prior cycle's
  `evidence/qa-gates/domain-neutrality.2026-07-19T07-18.md` (the domain-neutrality-invariant
  statement itself, the TaskMaster/TMW scoping sentence in `domain-profile.md`, and the
  `dev.discovery.vsto` stack-analyzer command name) — no new match, no new file touched.
- Naming collision (`grep -rni -E "modernize-|legacy-analyst|business-rules-extractor"
  *.md`): zero matches across all six pages.
- Link resolution: enumerated all `](...)` targets across all six pages (29 links); every
  target resolves to a same-directory file or a `#domain-neutrality-invariant` /
  `#domain-neutrality-invariant` anchor in `README.md` that exists.

**Verdict: PASS — no regression.**

## Scope of the Fix — Confirmed Single-File

`git show --stat 0f32c6d8` and `git diff de2cc7f9 0f32c6d8 -- docs/engineering/
legacy-discovery-and-parity/` confirm the remediation commit touched exactly one production
documentation file (`consumer-onboarding.md`); `README.md`, `workflow.md`,
`domain-profile.md`, `artifacts-and-schemas.md`, and `running-the-workflow.md` are
byte-identical to the pre-remediation commit `de2cc7f9`. This matches the remediation plan's
own scope statement and the remediation-inputs finding's precise bounding to a single file.

**Verdict: PASS.**

## Docs-Lint / Toolchain-Applicability (Carried Forward, Unaffected)

No docs-lint, markdownlint, or Markdown structural-check tooling exists in this repository
(re-confirmed: no `.markdownlint*` config, no `tests/docs/` directory). This determination
is unchanged from the prior cycle and unaffected by the remediation edit (Markdown-only
change).

**Verdict: PASS (N/A toolchain, correctly documented).**

## Tone Policy Spot-Check

Spot-checked the corrected `consumer-onboarding.md` and reran the check across all six
pages against `.claude/rules/tonality.md`. Grep for hype/hyperbole markers (`!|amazing|
incredible|awesome|revolutionary|perfect|flawless`) returned zero matches. Language is
factual and evidence-first throughout, including in the corrected passage (e.g., "This
absence reflects a classification decision, not an oversight," "Closing this gap is an
open, planned item, not delivered behavior").

**Verdict: PASS.**

## Overall Policy-Audit Verdict

**PASS.** The single prior Blocking finding is independently confirmed remediated: the
corrected claim in `consumer-onboarding.md` is corroborated against live packaging code
(`package.json`, `prepack.cjs`, `extensions/drm-copilot/resources/**`) rather than against
another feature's spec prose. No new inaccuracy, domain-neutrality violation, naming
collision, or broken link was introduced. No other page in the six-page doc set was touched
or needed touching. No regression was found in any previously-verified check. See
`feature-audit.2026-07-19T10-05.md` for the full AC-by-AC disposition.
