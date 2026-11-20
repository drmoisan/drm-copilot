# Feature Audit — legacy-discovery-documentation (#371)

- Reviewed branch: `feature/legacy-discovery-documentation-371` @ `de2cc7f9`
- Base: `epic/legacy-discovery-and-parity-integration` @ `b7be1a85`
- Work mode: `full-feature` — AC sources are `spec.md` (11 criteria) and `user-story.md`
  (5 criteria), per `issue.md` line 10 and the `acceptance-criteria-tracking` skill's
  mode-resolution table.
- Timestamp: 2026-07-19T09-20

Each criterion below was independently re-verified against live repository content on the
reviewed branch, not against the executor's own evidence artifacts or self-checked boxes.
Both `spec.md` and `user-story.md` currently show every AC pre-checked `[x]` by the
executor; this audit found that three of those checks (spec.md AC 6, AC 9, AC 10; and
user-story.md AC 4) do not hold up under independent verification. Per the
acceptance-criteria-tracking protocol, this review does not modify the AC source files
(no de-checking); the discrepancy between the self-certified `[x]` state and this audit's
independently verified PASS/PARTIAL/FAIL disposition is recorded here and in
`remediation-inputs.2026-07-19T09-20.md` for correction during remediation.

## spec.md Acceptance Criteria (11)

**AC1 — README-indexed directory, kebab-case, domain-neutrality stated, relative links**
PASS. `docs/engineering/legacy-discovery-and-parity/` exists with six kebab-case files.
`README.md` contains an explicit "Domain-Neutrality Invariant" section and a topic-page
table with five relative links, all resolving.

**AC2 — Workflow page, end to end, no duplication**
PASS. `workflow.md` documents a seven-stage sequence (init/profile load → inventory →
coverage ledger → runtime characterization → parity matrix → behavior reconciliation →
validation gate) plus a "Terminal Outputs" section (reports, acceptance scenarios) and an
explicit "What This Page Does Not Cover" section naming what is deferred and to whom.

**AC3 — Domain-profile page, contract fields, defers parser internals**
PASS. `domain-profile.md` documents the four contract fields (`legacy_source.root`,
`target.root`, `technology_stack.legacy`, `artifacts.root`) — independently verified
against `scripts/dev_tools/discovery/domain_profile_models.py`'s dataclass fields, exact
match — and an explicit "Parser Internals (Deferred)" section naming PyYAML/`yaml.safe_load`
without restating the parser implementation (verified accurate against
`scripts/dev_tools/discovery/domain_profile.py`).

**AC4 — Artifacts-and-schemas page: seven schemas by name, versioning, validation, gates**
PASS. `artifacts-and-schemas.md` names all seven schemas by their spec.md names and file
paths — independently verified against `schemas/discovery/v1/*.schema.json` on disk, exact
match — states the versioning convention (`v1/` directory, `$id` echo), documents both
validation paths (the primary `dev.discovery.validate-*` CLI family and the secondary
`dev.validate-json` governed-glob checker, with the correct non-obvious detail that
`schemas/**` falls outside `dev.validate-json`'s default scan — verified against
`scripts/dev_tools/json_config.py`'s `GOVERNED_GLOBS` tuple), and names both completion-gate
hooks with their registration file — verified against `.claude/settings.json` and the hook
files' existence on disk.

**AC5 — Running-the-workflow page: CLI/MCP/VS Code in that order**
PASS. `running-the-workflow.md` documents CLI first (18-row command table, independently
verified byte-for-byte against `pyproject.toml`'s `[tool.poetry.scripts]`), MCP tools second
(7-row table, independently verified against
`extensions/drm-copilot/src/mcp-discovery-tool-definitions.ts`, exact match), and VS Code
commands third (7-row table, independently verified against
`extensions/drm-copilot/src/discovery-command-registration.ts` and
`extensions/drm-copilot/package.json`'s `contributes.commands`, exact match).

**AC6 — Consumer-onboarding page: push-down tooling, TaskMaster/TMW as examples**
**FAIL.** `consumer-onboarding.md` correctly documents the push-down flow for agent
personas, skills, and completion-gate hooks — the CLI script names
(`push_down_copilot_customizations.py`, `push_down_codex_and_agents_customizations.py`,
`push_down_claude_customizations.py`), the MCP `push_down_*` tool names, and the `core`
pack-manifest placement are all independently verified accurate (confirmed against
`scripts/dev_tools/push_down_*_customizations.py` on disk and
`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`'s
contents). However, the same page also asserts, as landed present-tense fact, that the
seven discovery schemas and the initialization templates "reach a consumer repository as
Python source/data through the `@danmoisan/drm-copilot-mcp` npm package." This claim is
**not corroborated by any code in the reviewed branch**:
`packages/mcp-server/prepack.cjs` explicitly excludes every `.py` file and any
`scripts/`-segment path when copying `extensions/drm-copilot/resources/` into the packaged
`resources/` directory, and neither `schemas/discovery/v1/` nor `docs/discovery/templates/`
appears anywhere under `extensions/drm-copilot/resources/` for that copy step to pick up in
the first place. A consumer installing `@danmoisan/drm-copilot-mcp` today receives no
discovery schemas and no init templates. This is a materially inaccurate claim about a
"how consumer repositories receive the capability" criterion — TaskMaster/TMW framing is
correctly scoped, but the delivery-mechanism claim itself is false for two of the five
asset kinds the page covers.

**AC7 — Domain-neutrality invariant holds across the doc set**
PASS. Independently verified via grep (see policy-audit); all TaskMaster/TMW/VSTO mentions
are confined to explicit examples or scoping statements.

**AC8 — No per-feature reference documentation duplicated**
PASS. Every page contains an explicit "does not restate X, owned by Y" statement and links
out rather than restating owned content (parser internals, hook I/O contracts, schema field
tables, command flag references all explicitly deferred).

**AC9 — Provisional content handled per upstream-presence constraint**
**PARTIAL.** The doc set correctly contains zero `#9NNN`-style placeholder issue numbers and
zero links requiring a "planned" marker, because — per the reconciliation evidence — all 13
upstream epic children have in fact merged into the integration branch this feature branches
from (independently spot-checked against `epic-status.md`: `legacy-discovery-publishing-372`
shows `merge_status: worktree_removed` with merged PR #385). This structural claim (nothing
needs a "planned" marker because everything landed) is accurate. However, the specific
schema/template distribution claim in AC6 above should have been treated as unresolved
rather than asserted as settled fact: `legacy-discovery-publishing-372`'s own spec.md
resolves the schema/init-template question only to "explicitly documented as out of
mirror-contract scope" — it does not claim to have built a distribution mechanism, and no
such mechanism exists elsewhere in the codebase either. Content that has no corroborating
implementation should not have been authored as a confident present-tense claim; at minimum
it required the same "planned" / not-yet-substantiated treatment the constraint calls for
elsewhere in the doc set. Marked PARTIAL rather than FAIL because the doc set's general
"planned" discipline for the other 12 dependencies is sound.

**AC10 — Reconciliation pass against the integration branch completed**
**FAIL.** A reconciliation pass was performed and is documented
(`evidence/other/integration-reconciliation.2026-07-19T07-30.md`), and the large majority of
its findings hold up under independent re-verification (CLI table, schema paths, MCP tool
names, VS Code command IDs, agent/skill/hook counts, pack-manifest placement, parser
decision, contract fields, governed-glob behavior — all independently confirmed accurate).
However, the reconciliation's "Pack-manifest placement decision" entry verifies the
schema/init-template distribution claim only against `legacy-discovery-publishing-372`'s
spec.md prose ("Neither `schemas/` nor `docs/discovery/templates/` is a mirrored root...
they are Python source/data distributed to consumers through the MCP-server npm package")
and does not independently verify that claim against the actual packaging code
(`packages/mcp-server/package.json`, `packages/mcp-server/prepack.cjs`,
`extensions/drm-copilot/resources/**`). Independent verification in this audit found the
claim false against landed code (see AC6). The reconciliation pass therefore did not fully
satisfy its own stated purpose — "every documented command name, path, schema name, and
pack decision is verified against the integration branch or corrected/re-marked as
planned" — for this one item. This is the Blocking finding for this feature.

**AC11 — No naming collision with `code-modernization` plugin**
PASS. Independently verified via grep; zero matches.

### spec.md AC summary: 8 PASS, 1 PARTIAL (AC9), 2 FAIL (AC6, AC10)

## user-story.md Acceptance Criteria (5)

**AC1 — Consumer-repository engineer can author a domain profile from the doc set**
PASS. `domain-profile.md` explains all four contract fields and domain-neutral authoring
guidance; independently verified accurate against the domain-profile dataclass model.

**AC2 — Consumer-repository engineer can run the workflow via any of the three surfaces, documented as lockstep equivalents**
PASS. `running-the-workflow.md` states the lockstep-equivalence claim explicitly and
correctly documents (rather than glosses over) the CLI-to-MCP granularity asymmetry.
Independently verified accurate against the three surfaces' source.

**AC3 — Reader can identify the seven artifacts by name, validation, and completion gates**
PASS. `artifacts-and-schemas.md` names all seven, documents both validation paths, and
documents both completion-gate hooks. Independently verified accurate.

**AC4 — Consumer-onboarding path documented; TaskMaster/TMW strictly as examples**
**FAIL.** The push-down delivery mechanism for agent personas, skills, and hooks is
accurately documented and TaskMaster/TMW framing is correctly scoped to the example
section. However, a maintainer following `consumer-onboarding.md` as written would be told
that installing `@danmoisan/drm-copilot-mcp` delivers the discovery schemas and init
templates to the consumer repository — this is not true of the current landed code (see
spec.md AC6/AC10 above), so the onboarding path as documented does not actually work for
two of the five listed capability-delivery items.

**AC5 — Capability presented as domain-neutral throughout**
PASS. Independently verified via grep; no domain-specific behavior presented as framework
behavior.

### user-story.md AC summary: 4 PASS, 1 FAIL (AC4)

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: spec.md
- Total AC items: 11
- Checked off (delivered, independently verified PASS): 8
- Remaining (independently verified PARTIAL or FAIL): 3 (AC6 FAIL, AC9 PARTIAL, AC10 FAIL)
- Items remaining:
  - AC6: consumer-onboarding.md's schema/init-template npm-package distribution claim is not corroborated by landed code
  - AC9: the same claim was authored as settled fact rather than treated per the provisional-content discipline
  - AC10: reconciliation pass did not independently verify this claim against packaging code, relying on another feature's spec prose instead

- Source: user-story.md
- Total AC items: 5
- Checked off (delivered, independently verified PASS): 4
- Remaining (independently verified FAIL): 1 (AC4)
- Items remaining:
  - AC4: consumer-onboarding path is not fully workable as documented for schema/template delivery
```

Note: both source files currently show all items pre-checked `[x]` by the executor. This
audit does not alter those checkboxes (per the acceptance-criteria-tracking protocol, this
review artifact records the independently verified disposition rather than editing AC
source files); the discrepancy is the primary content of `remediation-inputs.2026-07-19T09-20.md`.

## GO / NO-GO

**NO-GO.** One Blocking finding (spec.md AC10, AC6; user-story.md AC4) — a documentation
page asserts a capability-delivery mechanism (schema/init-template distribution via the
`@danmoisan/drm-copilot-mcp` npm package) that does not exist in the landed code on the
reviewed branch. This is exactly the class of defect the task's own directive designates as
blocking rather than minor: "If ANY of the reconciliation claims ... turn out to be
inaccurate ... that is a Blocking finding ... per this feature's own acceptance criteria
(spec.md AC 10) and the CLAUDE.md/plan directive that documentation contradicting landed
behavior is a blocking defect, not a minor note." All other checks (domain neutrality,
naming collision, link resolution, evidence location, tone, coverage/toolchain
non-applicability, and 9 of 11 spec.md ACs / 4 of 5 user-story.md ACs) are PASS. See
`remediation-inputs.2026-07-19T09-20.md` for the precise remediation target.
