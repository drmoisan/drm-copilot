# Feature Audit — legacy-discovery-documentation (#371), Remediation Cycle 1 Reaudit

- Reviewed branch: `feature/legacy-discovery-documentation-371` @ `0f32c6d8`
- Base: `epic/legacy-discovery-and-parity-integration` @ `b7be1a85`
- Work mode: `full-feature` — AC sources are `spec.md` (11 criteria) and `user-story.md`
  (5 criteria), per `issue.md` line 10 and the `acceptance-criteria-tracking` skill's
  mode-resolution table.
- Timestamp: 2026-07-19T10-05
- Prior audit (`feature-audit.2026-07-19T09-20.md`) independently verified 8/11 spec.md ACs
  and 4/5 user-story.md ACs as PASS, with a single Blocking defect chain: spec.md AC6 (FAIL),
  AC9 (PARTIAL), AC10 (FAIL); user-story.md AC4 (FAIL) — all traced to the same root cause
  (an unsubstantiated schema/init-template distribution claim in `consumer-onboarding.md`).
  This reaudit re-verifies only the four affected criteria against the remediated branch
  (`0f32c6d8`) and re-confirms the remaining 8 spec.md / 4 user-story.md criteria are
  unaffected because their underlying pages (`README.md`, `workflow.md`, `domain-profile.md`,
  `artifacts-and-schemas.md`, `running-the-workflow.md`) are byte-identical to the
  previously-audited commit `de2cc7f9` (confirmed via `git diff de2cc7f9 0f32c6d8 --
  docs/engineering/legacy-discovery-and-parity/{README,workflow,domain-profile,
  artifacts-and-schemas,running-the-workflow}.md`, zero output for all five).

## spec.md Acceptance Criteria (11) — Reaudit

**AC1 — README-indexed directory, kebab-case, domain-neutrality stated, relative links**
PASS (unchanged; page not touched by remediation).

**AC2 — Workflow page, end to end, no duplication**
PASS (unchanged; page not touched by remediation).

**AC3 — Domain-profile page, contract fields, defers parser internals**
PASS (unchanged; page not touched by remediation).

**AC4 — Artifacts-and-schemas page: seven schemas by name, versioning, validation, gates**
PASS (unchanged; page not touched by remediation).

**AC5 — Running-the-workflow page: CLI/MCP/VS Code in that order**
PASS (unchanged; page not touched by remediation).

**AC6 — Consumer-onboarding page: push-down tooling, TaskMaster/TMW as examples**
**PASS (re-verified, previously FAIL).** `consumer-onboarding.md` item 2 now states plainly:
"no consumer-facing distribution mechanism currently exists for the schemas and
initialization templates," and explains why with independently re-corroborated facts —
`packages/mcp-server/package.json`'s `files` field is `["out/mcp-server.js", "resources"]`
(read directly, does not list either asset tree); `packages/mcp-server/prepack.cjs`'s
`shouldCopy()` excludes `.py` files and `scripts/`-segment paths only, with no carve-out for
either asset tree (read directly); `extensions/drm-copilot/resources/**` contains zero
occurrences of `schemas/discovery` or `docs/discovery/templates` content (independent
`find`/`grep`). The page correctly cross-references `legacy-discovery-publishing-372`'s
spec.md `## Schema/Init-Template Placement — Resolved` section (confirmed present at that
path) as the source of the `scripts-non-mirrored` classification decision, while explicitly
stating that decision "does not itself deliver a distribution mechanism." The push-down flow
for agent personas/skills/hooks (item 1) remains accurately documented, unchanged from the
prior cycle's PASS finding on that half of the page.

**AC7 — Domain-neutrality invariant holds across the doc set**
PASS (re-confirmed on the corrected file: all `TaskMaster`/`TMW` matches confined to the
intro-scoping sentence and the labeled Worked Example section; unchanged on the other five
pages).

**AC8 — No per-feature reference documentation duplicated**
PASS (unchanged; the correction cites `legacy-discovery-publishing-372`'s spec.md section by
name rather than restating its content).

**AC9 — Provisional content handled per upstream-presence constraint**
**PASS (re-verified, previously PARTIAL).** The corrected item 2 now explicitly marks the
schema/init-template distribution gap as "an open, planned item, not delivered behavior,"
satisfying the same provisional-content discipline the doc set already applied to its other
12 upstream dependencies. This is a genuine change in kind, not merely a rewording: the
prior version asserted a mechanism as landed fact: the corrected version affirmatively
states no mechanism exists yet and frames the gap as open, which is exactly what AC9
requires ("forward references to not-yet-delivered files are explicitly marked as
planned" — here, an entire delivery mechanism, not just a file reference, is marked
planned).

**AC10 — Reconciliation pass against the integration branch completed**
**PASS (re-verified, previously FAIL).** This reaudit independently re-verified the
corrected claim directly against `packages/mcp-server/package.json`,
`packages/mcp-server/prepack.cjs`, and `extensions/drm-copilot/resources/**` — not against
`legacy-discovery-publishing-372`'s spec.md prose, which is exactly the gap the prior cycle's
FAIL identified in the reconciliation pass's methodology. The corrected page's claim is now
consistent with what this independent verification found on the live branch. The other ten
reconciliation items from the prior cycle (CLI table, schema paths, MCP tool names, VS Code
command IDs, agent/skill/hook counts, pack-manifest placement, parser decision, contract
fields, governed-glob behavior, push-down CLI script names) were unaffected by the
remediation commit (their pages are unchanged) and remain independently verified accurate
from the prior cycle plus this cycle's spot re-checks (MCP tool names, push-down script
names, `core`-pack membership, four-agent-persona count all re-confirmed in this reaudit's
policy-audit and code-review artifacts).

**AC11 — No naming collision with `code-modernization` plugin**
PASS (re-confirmed on the corrected file; unchanged on the other five pages).

### spec.md AC summary: 11 PASS, 0 PARTIAL, 0 FAIL

## user-story.md Acceptance Criteria (5) — Reaudit

**AC1 — Consumer-repository engineer can author a domain profile from the doc set**
PASS (unchanged; `domain-profile.md` not touched by remediation).

**AC2 — Consumer-repository engineer can run the workflow via any of the three surfaces, documented as lockstep equivalents**
PASS (unchanged; `running-the-workflow.md` not touched by remediation).

**AC3 — Reader can identify the seven artifacts by name, validation, and completion gates**
PASS (unchanged; `artifacts-and-schemas.md` not touched by remediation).

**AC4 — Consumer-onboarding path documented; TaskMaster/TMW strictly as examples**
**PASS (re-verified, previously FAIL).** A maintainer following the corrected
`consumer-onboarding.md` is now told accurately that (a) the push-down tooling delivers
agent personas, skills, and hooks today, and (b) no automated path exists yet for the
discovery schemas and initialization templates, with an interim manual-retrieval path
described and the gap's status cross-referenced. This is now an accurate description of the
onboarding path as it actually behaves on the reviewed branch — the criterion requires the
doc set to document "the consumer-onboarding path," and an accurate description of a partial
capability (including its gap) satisfies that requirement; a doc set that hides or
misrepresents the gap would not. TaskMaster/TMW framing remains correctly confined to the
Worked Example section (unchanged from the prior PASS finding on that dimension).

**AC5 — Capability presented as domain-neutral throughout**
PASS (unchanged; re-confirmed on the corrected file).

### user-story.md AC summary: 5 PASS, 0 FAIL

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: spec.md
- Total AC items: 11
- Checked off (delivered, independently verified PASS): 11
- Remaining (unchecked): 0
- Items remaining: none

- Source: user-story.md
- Total AC items: 5
- Checked off (delivered, independently verified PASS): 5
- Remaining (unchecked): 0
- Items remaining: none
```

Both `spec.md` and `user-story.md` already show every AC as `[x]` (checked by the remediation
executor per the remediation plan's Phase 2 re-check tasks P2-T8–P2-T11). This reaudit
confirms the check-off is now warranted for AC6, AC9, AC10 (spec.md) and AC4 (user-story.md)
— the four items the prior cycle found improperly checked — on the strength of the
independent re-verification recorded above (not on the strength of the executor's own
evidence). No checkbox required modification; no criterion text was altered.

## GO / NO-GO

**GO.** All 11 spec.md acceptance criteria and all 5 user-story.md acceptance criteria are
independently verified PASS against the remediated branch (`0f32c6d8`). The single prior
Blocking finding (spec.md AC6/AC9/AC10; user-story.md AC4 — the schema/init-template
distribution claim) is corrected and independently corroborated against live packaging code
rather than against another feature's spec prose. No new defect was introduced by the
remediation edit, no other doc page required correction, and no previously-verified finding
regressed. This closes remediation cycle 1 with `blocking_count: 0`.
