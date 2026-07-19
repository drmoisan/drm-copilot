# Policy Audit — legacy-discovery-documentation (#371)

- Reviewed branch: `feature/legacy-discovery-documentation-371` @ `de2cc7f9`
- Base: `epic/legacy-discovery-and-parity-integration` @ `b7be1a85` (merge base)
- Work mode: `full-feature` (verified from `issue.md` line 10)
- Scope verified: full branch diff (`git diff --stat b7be1a85..de2cc7f9`), 18 files changed,
  895 insertions / 41 deletions. All changed files are Markdown documentation, evidence
  Markdown, or scoping-doc Markdown under `docs/`. Zero TypeScript, Python, PowerShell, or
  C# files changed on this branch.
- Timestamp: 2026-07-19T09-20
- Note: review evidence was gathered by direct file inspection of the checked-out feature
  branch worktree (`...\agent-ae68d14e27bb8727e`, HEAD `de2cc7f9`); this artifact is written
  into this agent's own sandboxed worktree copy per tooling constraints, using the same
  feature-relative path.

## Rejected Scope Narrowing

None. No caller instruction in this task attempted to narrow scope to a plan/task/phase
subset. The task instructions explicitly required full-branch-diff verification and
independent re-derivation of every reconciliation claim; that instruction is consistent
with the Scope Invariant and was followed as given.

## Policy Reading Order

Read in the required order: `CLAUDE.md`, `.claude/rules/general-code-change.md`,
`.claude/rules/general-unit-test.md`, `.claude/rules/tonality.md`. Confirmed no
language-specific rule file applies: the branch diff contains zero TypeScript, Python,
PowerShell, or C# files (verified by `git diff --stat`), so
`.claude/rules/{python,powershell,typescript,csharp}.md` are not in scope for this review.

## Coverage Verification

**N/A for all four tracked languages — zero changed files on this branch for each.**

| Language | Changed files in branch diff | Coverage artifact required? | Verdict |
|---|---|---|---|
| TypeScript | 0 | No | N/A (no changed files) |
| Python | 0 | No | N/A (no changed files) |
| PowerShell | 0 | No | N/A (no changed files) |
| C# | 0 | No | N/A (no changed files) |

This is not a narrowing of scope — it is a direct, verified consequence of the branch diff
containing only Markdown files (`git diff --stat` above; every changed path ends in `.md`).
Per the Coverage Verification section's own text, coverage artifacts are mandatory only for
languages "that has changed files in the feature branch"; none do. `N/A` is the correct,
policy-compliant verdict here because it reflects zero changed files, not an attempt to
exempt a language that has changed files.

## Evidence Location Compliance

Scanned the branch diff for files under `artifacts/baselines/**`, `artifacts/qa/**`,
`artifacts/evidence/**`, `artifacts/coverage/**`:

```
git diff --stat b7be1a85..de2cc7f9 -- 'artifacts/baselines/**' 'artifacts/qa/**' 'artifacts/evidence/**' 'artifacts/coverage/**'
(no output — zero matches)
```

All evidence produced by this feature's execution lives under the canonical
`docs/features/active/2026-07-17-legacy-discovery-documentation-371/evidence/{baseline,qa-gates,other}/`
tree (9 files, confirmed via directory listing on the reviewed branch worktree). No
non-canonical evidence path violation found. `EVIDENCE_LOCATION_OVERRIDE_REJECTED` was not
triggered — no delegation prompt in this review specified a non-canonical evidence path.

**Verdict: PASS.**

## Docs-Lint / Toolchain-Applicability Claim — Independently Verified

The plan's Scope Statement claims "No language toolchain (format/lint/type-check/test)
gates apply" and that "there is no docs-lint/markdownlint tooling in this repo." This claim
was independently re-verified rather than accepted on faith:

- `grep -rniE "markdownlint|docs-lint|remark|markdown-link-check" package.json .github/workflows/*.yml` — zero matches.
- No `tests/docs/` directory exists.
- No `.markdownlint*` config file exists at repo root.
- `.github/workflows/_docs-validation.yml` exists but only checks for the presence of
  repo-root `README.md` and `LICENSE`, and warns (does not fail) if
  `.github/copilot-instructions.md` or `docs/code-change.instructions.md` is missing. It
  performs no structural/link validation of arbitrary Markdown files and would not exercise
  the six new pages.

**Verdict: PASS.** The claim is accurate. No docs-lint gate exists that would have caught
the reconciliation-accuracy defect documented below; that defect had to be found by manual
cross-reference against the live repository, which is exactly what this review performed.

## Domain-Neutrality Invariant — Independently Verified

Independent grep (not the executor's own evidence file) for
`TaskMaster|TMW|Outlook|VSTO|email|task-management` (case-insensitive) across all six pages:

```
grep -rniE "TaskMaster|TMW|Outlook|VSTO|email|task-management" docs/engineering/legacy-discovery-and-parity/*.md
```

Results: all `TaskMaster`/`TMW` matches are confined to `consumer-onboarding.md`'s worked
example section, `domain-profile.md`'s single sentence framing TaskMaster/TMW as "two
independent instances of the same domain-neutral contract" (an explicit scoping statement,
not framework behavior), and `README.md`'s statement of the domain-neutrality invariant
itself (which names TaskMaster/TMW precisely to say they are *not* framework behavior).

`VSTO` matches appear in `running-the-workflow.md` and `workflow.md` as the literal name of
a real, landed, generically-selectable stack analyzer command (`dev.discovery.vsto`),
analogous to `dev.discovery.dotnet`. This names a supported technology-stack option chosen
generically by the domain profile's `technology_stack.legacy` field — not domain-specific
consumer behavior (TaskMaster/TMW business logic). spec.md's own Inputs/Outputs section
explicitly authors this exact framing ("the VSTO/Office analyzer, `dev.discovery.vsto`"),
so this is spec-sanctioned and not a domain-neutrality violation.

No match is presented as framework behavior anywhere in the doc set.

**Verdict: PASS.**

## Naming-Collision Constraint — Independently Verified

Independent grep for
`modernize-|legacy-analyst|business-rules-extractor|architecture-critic|version-delta-analyst|scaffolder|security-auditor|test-engineer`
(case-insensitive) across all six pages:

```
grep -rniE "modernize-|legacy-analyst|business-rules-extractor|architecture-critic|version-delta-analyst|scaffolder|security-auditor|test-engineer" docs/engineering/legacy-discovery-and-parity/*.md
(no output — zero matches)
```

**Verdict: PASS.** Zero collisions with the reserved `code-modernization` plugin names.

## Relative-Link Resolution — Independently Verified

Enumerated every `](...)` markdown link across the six pages (32 links total). Every link
target is a same-directory relative path (`README.md`, `workflow.md`, `domain-profile.md`,
`artifacts-and-schemas.md`, `running-the-workflow.md`, `consumer-onboarding.md`, two with
`#domain-neutrality-invariant` anchors into `README.md`). All six target files exist on the
branch (confirmed via directory listing). Zero unresolved links; zero links requiring a
"planned" marker.

**Verdict: PASS.**

## Reconciliation Accuracy — Independently Verified (Blocking Finding)

This is the highest-stakes check per the task instructions, and it surfaced a confirmed
defect. Full detail is in `feature-audit.2026-07-19T09-20.md` and
`remediation-inputs.2026-07-19T09-20.md`; summary here:

| Reconciliation item | Verified against | Result |
|---|---|---|
| `dev.discovery.*` CLI command table (18 entries) | `pyproject.toml` `[tool.poetry.scripts]` | PASS — exact match |
| Seven schema file paths | `schemas/discovery/v1/*.schema.json` on disk | PASS — exact match |
| Init-template paths | `docs/discovery/templates/**` on disk | PASS — exact match |
| Seven MCP tool names | `extensions/drm-copilot/src/mcp-discovery-tool-definitions.ts` | PASS — exact match |
| Seven VS Code command IDs + titles | `extensions/drm-copilot/src/discovery-command-registration.ts`, `extensions/drm-copilot/package.json` | PASS — exact match |
| Four discovery agent personas / seven skills / two hooks | `.claude/agents/*.md`, `.claude/skills/discovery-*/SKILL.md`, `.claude/hooks/*discovery*.ps1`, `core.json` pack manifest | PASS — exact match |
| `core` pack-manifest placement | `core.json` manifest contents, `--packs` help text | PASS |
| PyYAML `yaml.safe_load` parser decision | `scripts/dev_tools/discovery/domain_profile.py` | PASS |
| Domain-profile contract fields | `scripts/dev_tools/discovery/domain_profile_models.py` | PASS — exact match |
| `GOVERNED_GLOBS` claim | `scripts/dev_tools/json_config.py` | PASS — exact match |
| Push-down CLI script names | `scripts/dev_tools/push_down_*_customizations.py` on disk | PASS |
| **Schema/init-template distribution via `@danmoisan/drm-copilot-mcp` npm package** | `packages/mcp-server/package.json` (`files`), `packages/mcp-server/prepack.cjs`, `extensions/drm-copilot/resources/**` | **FAIL — not corroborated by landed code** |

The one FAIL is a Blocking finding under the task's own directive (spec.md AC 10;
CLAUDE.md/plan directive that documentation contradicting landed behavior is blocking, not
minor). Detail in the Feature Audit and Remediation Inputs artifacts.

## Tone Policy Spot-Check

Spot-checked all six pages against `.claude/rules/tonality.md`. Grep for hype/hyperbole
markers (`amazing|incredible|awesome|revolutionary|world-class|flawless|perfect\b|seamlessly|simply|just works|magic`)
returned zero matches. Language throughout is factual, evidence-first, and neutral (e.g.,
"Verified via..." patterns, explicit statement of what a page does *not* cover). No jokes,
metaphor, or motivational language observed.

**Verdict: PASS.**

## Overall Policy-Audit Verdict

**PARTIAL — one Blocking finding (reconciliation accuracy).** All other policy checks
(domain neutrality, naming collision, link resolution, evidence location, tone, docs-lint
non-applicability, coverage non-applicability) PASS. See `feature-audit.2026-07-19T09-20.md`
for the full AC-by-AC disposition and `remediation-inputs.2026-07-19T09-20.md` for the
precise remediation target.
