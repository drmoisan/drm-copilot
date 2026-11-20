# Remediation Inputs — legacy-discovery-documentation (#371)

- Reviewed branch: `feature/legacy-discovery-documentation-371` @ `de2cc7f9`
- Timestamp: 2026-07-19T09-20
- Verdict: **NO-GO**
- Source artifacts: `policy-audit.2026-07-19T09-20.md`, `code-review.2026-07-19T09-20.md`,
  `feature-audit.2026-07-19T09-20.md`

## Blocking Finding 1 — Unsubstantiated schema/init-template distribution claim

**File:** `docs/engineering/legacy-discovery-and-parity/consumer-onboarding.md`
**Section:** "What Is Delivered, and How", item 2 (lines 24–35 as authored)
**Also affected:** `docs/engineering/legacy-discovery-and-parity/README.md` is not directly
affected (it does not repeat this claim), but the following AC checkboxes are affected:
`spec.md` AC6, AC9, AC10; `user-story.md` AC4.

**Claim as written:**

> **Schemas and initialization templates — distributed as Python package data via the
> MCP-server npm package, not pushed down.** The seven discovery JSON schemas
> (`schemas/discovery/v1/*.schema.json`) and the initialization templates
> (`docs/discovery/templates/`) live under repository-root trees that are outside the
> byte-identical `.claude`/`.codex` mirror contract. They reach a consumer repository as
> Python source/data through the `@danmoisan/drm-copilot-mcp` npm package (the same package
> that exposes the MCP tools in [`running-the-workflow.md`](running-the-workflow.md)), not
> through `push_down_claude_customizations.py` or
> `push_down_codex_and_agents_customizations.py`. This is a deliberate scope boundary, not
> an omission...

**Why this is inaccurate against the reviewed branch's landed code:**

1. `packages/mcp-server/package.json`'s `files` field is
   `["out/mcp-server.js", "resources"]`. The `resources` entry is populated by
   `packages/mcp-server/prepack.cjs`, which copies from
   `extensions/drm-copilot/resources/` with an explicit exclusion filter:
   - `shouldCopy()` returns `false` for any path ending in `.py`.
   - `shouldCopy()` returns `false` for any path containing a `scripts/`, `/scripts/`, or
     `scripts` path segment (regex: `/(^|\/)scripts(\/|$)/`).
   - The file's own header comment states the rationale explicitly: "the standalone MCP
     server must not ship any `.py` file or the (removed) bundled `scripts/` subtree."
2. Independently confirmed that neither `schemas/discovery/v1/` nor
   `docs/discovery/templates/` appears anywhere under `extensions/drm-copilot/resources/`
   (`find extensions/drm-copilot/resources -iname "*schema*"` and
   `find extensions/drm-copilot/resources -path "*templates*"` both return zero hits for
   these two trees — the only `templates` hits are unrelated `feature-templates/` and
   `templates/` directories used for scaffolding feature docs and PowerShell snippets, not
   discovery init templates).
3. No reference to `schemas/discovery` or `docs/discovery/templates` exists anywhere in
   `extensions/drm-copilot/src/**` (grep, zero matches) or in `packages/mcp-server/**`
   (grep, zero matches) — there is no alternate code path (e.g., an esbuild embed or a
   separate copy step) that ships these assets either.
4. `pyproject.toml`'s `[tool.poetry] packages` entry is `[{ include = "scripts" }]` only —
   `schemas/` and `docs/discovery/templates/` are not declared as Python package data
   anywhere, and there is no evidence the `drm-copilot` Python package is published to PyPI
   or any other Python package index at all.
5. Traced the claim's origin to
   `docs/features/active/2026-07-17-legacy-discovery-publishing-372/spec.md`, section
   "Schema/Init-Template Placement — Resolved" (lines 132–161). That spec documents a
   *design decision* ("Decision: scripts-non-mirrored") and states the schemas/templates
   "are Python source/data distributed to consumers through the MCP-server npm package,"
   but #372's own Acceptance Criteria (line 305–309) scope its delivered work only to
   "explicitly documented as out of mirror-contract scope: no mirror copy into `resources/`
   and no `core.json` manifest entry is made for these assets by this feature." In other
   words, #372 explicitly declined to build any distribution mechanism, and no other
   feature in the merged epic builds one either. #371's `consumer-onboarding.md` converted
   #372's aspirational design language into a present-tense factual claim about consumer
   experience without verifying that the mechanism was actually implemented.

**Impact:** A maintainer or consumer-repository engineer following
`consumer-onboarding.md` as written would believe that installing
`@danmoisan/drm-copilot-mcp` (via `npx` or `npm install -g`) delivers the seven discovery
JSON schemas and the initialization templates to their workspace. It does not. There is
currently no documented or undocumented mechanism by which a consumer repository receives
these two asset kinds at all — this is a real capability gap in the delivered epic, not
merely a documentation wording issue, and the documentation should say so rather than
asserting a working delivery path.

**Required remediation (either branch is acceptable):**

- **Branch A (preferred — accurate as of today):** Rewrite `consumer-onboarding.md` item 2
  to state plainly that the seven discovery schemas and initialization templates currently
  have **no consumer-facing distribution mechanism** — they exist only in the
  `drm-copilot` repository itself at `schemas/discovery/v1/` and
  `docs/discovery/templates/` — and mark this as an open gap/planned item rather than
  landed behavior. Cross-reference `legacy-discovery-publishing-372`'s spec.md "Resolved"
  section as the source of the "scripts-non-mirrored" classification decision, but do not
  claim the npm package ships them until code exists that does so.
- **Branch B (only if a maintainer confirms out-of-band that a distribution mechanism is
  about to land):** If there is a genuinely planned follow-up (e.g., extending
  `packages/mcp-server/prepack.cjs` to also copy `schemas/discovery/v1/` and
  `docs/discovery/templates/`, or publishing `drm-copilot` as a proper Python package with
  these as package data), mark the claim explicitly as "planned" per the doc set's own
  provisional-content convention (used elsewhere in this same doc set for genuinely
  forward-looking references), naming the tracking issue/feature if one exists.
- After either branch, re-run the reconciliation-pass discipline specifically for this
  claim: verify directly against `packages/mcp-server/package.json`,
  `packages/mcp-server/prepack.cjs`, and `extensions/drm-copilot/resources/**` (not against
  another feature's spec.md prose) before re-marking spec.md AC6/AC9/AC10 and
  user-story.md AC4 as satisfied.

**AC items to leave unchecked until remediated:** `spec.md` AC6, AC9 (partial), AC10;
`user-story.md` AC4. Do not re-check these until the corrected page is independently
re-verified against the packaging code described above.

## Non-Blocking Observations (informational only, no remediation required)

- The reconciliation-pass evidence artifact
  (`evidence/other/integration-reconciliation.2026-07-19T07-30.md`) is otherwise thorough
  and its other 10 reconciliation items all independently re-verified as accurate. The
  single-item gap above is narrow and precisely bounded — no other page or claim in the doc
  set requires correction.
- No coverage, toolchain, evidence-location, domain-neutrality, naming-collision, or
  tone-policy remediation is required; all of those checks passed independent
  re-verification.

## Summary for Remediation Planning

One file (`consumer-onboarding.md`), one section (~12 lines), requires a factual correction
or an explicit "planned" re-marking. No other file in the six-page doc set requires a
change. This is a small, well-scoped remediation.
