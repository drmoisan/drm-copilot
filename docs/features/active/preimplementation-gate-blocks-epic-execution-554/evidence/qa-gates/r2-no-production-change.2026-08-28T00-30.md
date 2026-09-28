# Remediation Cycle 2 — Test-Only Scope Invariant

Timestamp: 2026-08-28T02-18
Task: [P3-T10]
Command: `git diff --name-only HEAD`, `git diff --name-only 9fed8b9074354ac91b35dc6756fcf4935cfc1c89`, `git status --porcelain`, and `git ls-files --others --exclude-standard`, unioned and deduplicated in Python with a three-character prefix strip applied to every porcelain line; plus `git rev-parse 1e991b86d78e4f979922b79268f19ca0e5ab19e3:<path>` compared against `git hash-object <path>` for each of the four `-helpers.ps1` copies
EXIT_CODE: 0 (all listings returned 0)

## Union construction

**Listings unioned.** The plan names three: `git diff --name-only HEAD`, `git status --porcelain`,
and `git ls-files --others --exclude-standard`. A fourth,
`git diff --name-only 9fed8b9074354ac91b35dc6756fcf4935cfc1c89`, is added because the calling
directive requires a commit and push at the end of each phase, so the Phase 1 and Phase 2 `.ps1`
edits are already committed and a two-dot diff against `HEAD` can no longer observe them.
`9fed8b9074354ac91b35dc6756fcf4935cfc1c89` is the branch head at the moment this cycle began, recorded
at [P0-T3]. Adding it makes the union observe the **whole cycle** rather than only its uncommitted
residue, which is what the plan's acceptance condition is about. It can only enlarge the union, so it
strictly strengthens every membership test below.

**Prefix stripping.** Each porcelain line's **three-character status-and-separator prefix** — the
two-character `XY` status field at positions 0 and 1 plus the single separator space at position 2,
with the path beginning at position 3 — is stripped before its path enters the union. Implemented as
`line[3:]`.

**Deduplication.** The union is a Python `set`, so a path reported by more than one listing
contributes **exactly one** member. Union size: **27** distinct paths.

**Why the strip width is load-bearing.** Stripping only two characters would leave a leading space on
every porcelain path. Each edited suite would then enter the union twice as two distinct strings
ending in `.ps1` — once unprefixed from a diff and once space-prefixed from the porcelain listing —
and the resulting count of four would falsify an acceptance condition that demands exactly two. On
this particular run the two suites are already committed, so they do not appear in the porcelain
listing and a two-character strip would have produced the same count by accident; the correct
three-character strip is applied regardless, because the invariant must hold whatever the staging
state.

**Why the untracked-visible listings are included.** The two-dot diff against `HEAD` observes
uncommitted working-tree changes to tracked files but **never reports an untracked path**, so a path
this plan creates is invisible to a diff alone. Only the porcelain and untracked listings can observe
it.

---

## Result 1 — exactly two paths ending in `.ps1`

```
tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1
tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1
```

**Count: 2.**

| Path | Role |
| --- | --- |
| `tests/scripts/codex-hooks/enforce-orchestration-preimplementation-gate-mode-resolution.Tests.ps1` | the Codex mode-resolution suite edited in **Phase 1** ([P1-T2], [P1-T3]) |
| `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classifier.Tests.ps1` | the Claude classifier suite edited in **Phase 2** ([P2-T3]) |

Both are test files, both were created by this branch, and no other `.ps1` path of any kind appears
in the union.

## Result 2 — no path under the three prohibited production prefixes

| Prefix | Members in the union |
| --- | --- |
| `.claude/hooks/` | **0** |
| `.codex/hooks/` | **0** |
| `extensions/drm-copilot/resources/` | **0** |

**Zero production `.ps1` files changed.** The four gate-hook copies, the four modes-sibling copies,
and both `extensions/drm-copilot/resources/` mirror trees are untouched by this cycle.

## Result 3 — the four `-helpers.ps1` copies are byte-untouched

Each file's current blob identity is compared against its blob identity at the fixed comparison
anchor `1e991b86d78e4f979922b79268f19ca0e5ab19e3`.

| Copy | Blob at anchor | Blob now | Verdict |
| --- | --- | --- | --- |
| `.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `af23b04cbdb5d46a2538a5b028a996cb3552bdad` | `af23b04cbdb5d46a2538a5b028a996cb3552bdad` | **BYTE-UNTOUCHED** |
| `.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `af23b04cbdb5d46a2538a5b028a996cb3552bdad` | `af23b04cbdb5d46a2538a5b028a996cb3552bdad` | **BYTE-UNTOUCHED** |
| `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `af23b04cbdb5d46a2538a5b028a996cb3552bdad` | `af23b04cbdb5d46a2538a5b028a996cb3552bdad` | **BYTE-UNTOUCHED** |
| `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-orchestration-preimplementation-gate-helpers.ps1` | `af23b04cbdb5d46a2538a5b028a996cb3552bdad` | `af23b04cbdb5d46a2538a5b028a996cb3552bdad` | **BYTE-UNTOUCHED** |

**The four `-helpers.ps1` copies are byte-untouched.** All four share the identical blob
`af23b04cbdb5d46a2538a5b028a996cb3552bdad`, unchanged since the merge base. This is the proof that
the issue #539 orchestration-bookkeeping staging exemption is behaviourally unchanged, per statement
`(a)` of the `## DECLARED BLAST RADIUS` section and acceptance criterion 23.

---

## Full deduplicated union (27 paths)

25 Markdown paths under
`docs/features/active/preimplementation-gate-blocks-epic-execution-554/` — the remediation plan, the
appended cycle-1 `policy-audit` and `r1-acceptance-criterion-reevaluation` artifacts, the eight
Phase 0 `evidence/remediation-baseline/` artifacts, and the `evidence/qa-gates/` artifacts of Phases
1 through 3 — plus the two `.ps1` test suites named above.

Output Summary: The deduplicated four-listing union holds **27** paths and contains **exactly two**
paths ending in `.ps1`, both branch-created test suites. It contains **no** path under
`.claude/hooks/`, `.codex/hooks/`, or `extensions/drm-copilot/resources/`. **Zero production files
changed**, and **the four `-helpers.ps1` copies are byte-untouched** at blob
`af23b04cbdb5d46a2538a5b028a996cb3552bdad`. EXIT_CODE 0.
