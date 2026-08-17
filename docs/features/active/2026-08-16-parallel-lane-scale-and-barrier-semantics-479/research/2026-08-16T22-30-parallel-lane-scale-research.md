# Research: Parallel Lane Scale and Barrier Semantics (issue #479)

Date: 2026-08-16. Scope: three questions delegated for the approved defect set on the `parallel`
orchestration surface. Authoritative contract: `.claude/rules/parallel-orchestration.md`. Two facts
are taken as established and were not re-verified here: both cohort-barrier layers implement a
per-edge predicate (`.claude/hooks/enforce-parallel-cohort-barrier.ps1:372-393`,
`scripts/dev_tools/_parallel_orchestrator_state_cohort_barrier.py:282-328`), and a
mutually-conflicting lane is naturally colored across cohorts, so the model can already express
lane-parallel work.

---

## Q1 — The `max_concurrency` ceiling and its binding constraint

**RECOMMENDATION: raise the ceiling to 16, justified explicitly as a sanity limit, not a capacity
limit. Keep the default at 4.** Confidence: high that no repository constraint binds at or below
16; medium on the workstation-resource estimates, which are unmeasured.

### Honest finding

No verified constraint binds at or below 13, and none binds at 8. The current `8` is not derived
from any capacity; `.claude/rules/parallel-orchestration.md` (Concurrency Bound, A7) records it as
symmetry with the epic surface. The recommendation of 16 is a nonsense-rejection bound sized to
cover the concrete 13-lane organization with headroom; it is not backed by a measured capacity,
and this section deliberately does not manufacture one.

### Constraint inventory, ranked by which binds first

1. **Local toolchain concurrency (first practical constraint, soft, unmeasured).** Each in-flight
   item is a child `orchestrator` Claude Code session running the seven-stage toolchain (Pytest
   with numpy/pandas/scipy/sklearn/pyarrow imports per `pyproject.toml:16-29`; Jest per
   `extensions/drm-copilot/package.json:210`; Pester). Estimated 1-4 GB peak memory per child.
   On a Windows 11 workstation with 32-64 GB RAM this plausibly binds in the low-to-mid teens of
   simultaneously in-flight items. **Undetermined precisely**: this research session has no shell
   access and the machine's RAM/core count is unknown; a measured figure would require running one
   representative child under load and reading its working set. The estimate supports 16 as
   compatible with the first soft constraint; it does not prove it.

2. **GitHub Actions concurrency (binds second; throughput only, never correctness).** No workflow
   carries a `concurrency:` group — the only grep match is prose in `.github/workflows/README.md:69`
   — so nothing serializes runs repo-side. `ci.yml` fans each push/PR into 9 parallel jobs
   (`.github/workflows/ci.yml:10-41`). Documented personal-account limits (verified against
   docs.github.com/en/actions/reference/limits on 2026-08-16): 20 concurrent standard-runner jobs
   on Free, 40 on Pro; REST API 5,000 requests/hour authenticated. Thirteen concurrent items × 9
   jobs = 117 jobs, so beyond ~2 (Free) or ~4 (Pro) fully concurrent CI runs, jobs queue. Queuing
   delays merge-on-green; it fails nothing. API polling by 13 children plus the parent is far
   below 5,000/hour.

3. **Worktree disk footprint (binds last).** The tracked tree is text-only: Markdown, Python,
   TypeScript, PowerShell; the only binaries found live under gitignored paths (`.venv/**`,
   `artifacts/vsix/**`). Worktrees share the `.git` object store. The observed existing agent
   worktree (`.claude/worktrees/agent-afc9f4fd25ec235a5`) carries **no** `.venv` and **no**
   `node_modules` (verified by glob), so an idle worktree costs approximately one text checkout —
   estimated tens of MB (**exact size undetermined**; no shell access this session, so `du` was
   not run). The expensive case is a child that installs toolchains: `poetry.toml:1-2` sets
   `virtualenvs.in-project = true`, so `poetry install` creates a per-worktree `.venv` of roughly
   1 GB (numpy/pandas/scipy/sklearn/pyarrow are mandatory deps; tensorflow is optional,
   `pyproject.toml:30`), and `npm ci` under `extensions/drm-copilot` adds several hundred MB
   (jest, esbuild, typescript). Worst case ~1.5 GB per in-flight worktree → ~24 GB at N=16.
   Tolerable on a workstation SSD; painful somewhere in the dozens.

4. **No other repository constraint exists.** `.claude/settings.json` configures no hook timeouts
   (grep: zero matches for `timeout`) and no fan-out cap. The batching library enforces only a
   lower bound: `scripts/dev_tools/parallel_cohort_computation.py:455` (`max_concurrency < 1`
   raises) and `.claude/lib/bash/parallel-cohorts.sh:293`; neither has an upper bound, so raising
   the schema ceiling requires no library change.

### Runner-up and rejection

Runner-up ceiling: **20**, derived from the GitHub Free-plan concurrent-job limit. Rejected for
two reasons: exceeding the limit queues jobs rather than failing anything, so it is not a
correctness constraint; and the unit does not map — 20 is a count of *jobs*, and each item consumes
9, so "20" as an item ceiling would be a manufactured capacity justification of exactly the kind
this research was instructed to avoid.

Also considered and rejected: **13/14** (the exact lane count) — encoding one work organization's
shape into the schema bound repeats the A7 mistake of an incidental justification; and **32** — no
use case, and it exceeds the estimated local-resource comfort range with no offsetting benefit.

### Edit sites for the ceiling change (enumerated for the planner)

Six code constants plus prose:

- `scripts/dev_tools/validate_parallel_orchestrator_state.py:71` (`MAX_CONCURRENCY = 8`)
- `scripts/dev_tools/validate_parallel_planner_state.py:64`
- `scripts/dev_tools/parallel_manifest_contract.py:65`
- `.claude/lib/bash/parallel-manifest-validate.sh:46` (`PM_MAX_CONCURRENCY=8`)
- `extensions/drm-copilot/src/lib/validate/parallel-planner-state-core.ts:66`
- `extensions/drm-copilot/src/lib/validate/parallel-orchestrator-state-core.ts:70`
- Prose: `.claude/rules/parallel-orchestration.md` (invariant 4, P2, M4, and the A7 section, which
  should be rewritten to state the sanity-limit justification); `.claude/skills/parallel-plan/SKILL.md:256,288`;
  `.claude/skills/parallel-orchestrate/SKILL.md:67-68`; docstring at
  `scripts/dev_tools/_parallel_state_common.py:197`.

Error-message parity: the Python/bash/TS validators emit the bound inside their error strings
(e.g. `validate_parallel_orchestrator_state.py:148`, `parallel-manifest-validate.sh:119`,
`parallel-orchestrator-state-core.ts:147`), so all six must change in one commit to preserve the
byte-parity the TS port asserts.

---

## Q2 — The lane-assertion field name (Defect 3)

**RECOMMENDATION: adopt `expected_conflict_components`, valued as a list of lists of `issue_num`
integers, manifest-only, with the comparison result surfaced in the planner completion report
(stdout); no checkpoint field.** Confidence: high.

### Why the name cannot be read as a `depends_on` synonym

- The grammatical head is *components* — a derived output of the conflict graph, a graph-theoretic
  noun — not a relation between items. A dependency field names an asymmetric edge (A depends on
  B); a partition into components is symmetric and unordered, and the plural-of-sets shape makes
  that visible in the value itself.
- The modifier *expected* marks epistemic status: a prediction to be checked against a computation.
  A scheduler has no use for an "expected" value; an ordering input would never carry that word.
- The word *conflict* ties the field to the contention relation the surface already derives
  (`conflicts()` / `compute_cohorts`), so a reader traces it to the derivation machinery, not to
  scheduling input.
- It avoids every excluded token (`depends_on`, `lanes`, `groups`, `ordering`) and every
  prohibited key: the deep scan rejects exactly `depends_on`
  (`scripts/dev_tools/parallel_manifest_contract.py:69`) and the top-level scan exactly
  `integration_branch` (`parallel_manifest_contract.py:74`); the new key matches neither, and its
  value contains no mapping keys at all, so it cannot smuggle a prohibited key at a nested level.

### Value shape: nested lists of `issue_num`, each inner list sorted ascending

```yaml
expected_conflict_components:
  - [469, 470, 471]
  - [472]
  - [475, 476]
```

Justification against named lanes (`{name, members}` objects): `issue_num` is the primary key for
every item reference on this surface (`.claude/rules/parallel-orchestration.md`, opening
paragraph), and the comparison is set-of-sets equality against derived components, for which names
contribute nothing. A `name` key would make lanes look like first-class scheduling entities —
precisely the misreading the field must avoid — and would add shape validation for a field with no
validator semantics. Diagnostics can reference an assertion by its ordinal position. Sorted-
ascending inner lists follow the existing canonical-form precedent (`cohorts[].item_keys` sorted
ascending, `.claude/skills/parallel-plan/SKILL.md:253`).

### Where the comparison surfaces, and checkpoint recording

Minimal surface, in line with the delegation's instruction:

- **Manifest-only field.** Verified feasible with zero schema-machinery change: the manifest
  validator rejects prohibited keys and validates known fields but does not reject unknown keys
  (`parallel_manifest_contract.py:295-312` — identity, prohibited-key scan, items; no
  `additionalProperties`-style rejection). A shape check for the field when present is a small
  addition to the manifest contract (one new M-invariant), and that is the only validator touch.
- **Result surfaces in the planner completion report** (stdout), alongside where V3 Advisory
  findings already surface (`.claude/skills/parallel-plan/SKILL.md:206-207`). A mismatch report
  lists each asserted component and the derived component(s) its members actually landed in.
- **No checkpoint field.** Rejected alternative: persisting a `component_assertion` block in the
  planner checkpoint. That would touch F3's five parity implementations (Python, bash, two TS
  cores, prose) for a value that is cheaply re-derivable — re-run the comparison from the manifest
  and the recorded `conflict_edges[]` — and the Cache Doctrine already forbids treating the
  checkpoint as truth. Ephemerality is acceptable for an assertion read once at plan time.
- Mismatch severity: report as a difference (Advisory-style), per the approved defect wording
  ("reporting differences"); it never blocks, never overrides a derived edge, never feeds
  `compute_cohorts`, and never influences scheduling.

---

## Q3 — Defect 4, staged intake

**RECOMMENDATION: option (b) — a preparation-concurrency cap named `preparation_concurrency`,
implemented as a batching rule in the `parallel-plan` skill that reuses the landed
`compute-concurrency-batches` library. No new orchestration primitive is needed, and option (a)
is not viable as the primary intake path at 69 items.** Confidence: high on current behavior;
medium-high on the recommendation.

### Current behavior: the preparation fan-out is genuinely unbounded

Governing text, `.claude/skills/parallel-plan/SKILL.md:64-67`:

> "One preparation-mode `Agent(orchestrator)` run per item. Preparation produces documents and
> plans rather than code, and items carry no ordering constraint, so launch ALL item preparations
> concurrently: one message, N `Agent` calls, each `isolation: \"worktree\"` and
> `run_in_background: true`."

Corroborating: `.claude/agents/parallel-planner.md:92` ("one delegation per item");
`.claude/skills/parallel-plan/SKILL.md:255-258` records `max_concurrency` at seeding "without
enforcing it — Enforcement is F5's", i.e. execution-side only. No cap of any kind applies to
preparation. For 69 items the skill as written instructs 69 concurrent worktree-isolated child
orchestrators.

### Why (a) alone is rejected

`/parallel-add` admits exactly one item per invocation, by design
(`.claude/skills/parallel-add/SKILL.md:30-32`: "An argument naming more than one item is rejected;
admit one item per invocation"). A staged-intake procedure built on open mode + `/parallel-add`
therefore costs one manual operator invocation per item beyond the first tranche (~56 for the
13-lane/69-item organization), each forking `parallel-orchestrator`, each performing the mandatory
durable-state re-derivation (`parallel-add/SKILL.md:31-45`), and each potentially incrementing
`recolor_generation`. It also moves preparation into execution time, where every admission
interacts with the in-flight set. `/parallel-add` remains the right primitive for its designed
purpose — genuine mid-run additions — but it is not an intake mechanism at this scale.

### Why (c) is rejected

Once (b) exists, (a) adds no necessary capability, and documenting it as an intake path would
institutionalize a per-item manual loop. Single-session-length risk for a 69-item plan run is
covered by existing machinery, not by staging: the planner checkpoints after every completed step
and resumes from `next_step` (`.claude/agents/parallel-planner.md:82-88`,
`parallel-planner.md:104-109`), so a multi-batch preparation phase survives session boundaries
without any new mechanism.

### The cap

- **Name:** `preparation_concurrency`.
- **Mechanism (no new primitive):** the planner partitions the intake item list into batches with
  the already-landed, already-allowlisted pure function —
  `bash .claude/lib/bash/compute-concurrency-batches.sh --keys "<k1> ..." --max-concurrency <cap>`
  (allowlist grant at `.claude/agents/parallel-planner.md:18`; authority
  `compute_concurrency_batches`, `scripts/dev_tools/parallel_cohort_computation.py:421-467`) — and
  launches one batch of preparation children at a time, checkpointing between batches. Note
  the intake batching keys on intake order/issue number, not cohorts; the function is reused purely
  as a deterministic chunker.
- **Where validated:** procedurally, in the `parallel-plan` skill text, with the value recorded in
  the planner checkpoint as a permitted additional field for resume determinism (precedent:
  `plan_home_branch` is recorded as "a permitted additional field" beyond P1's strict-subset
  required-key set, `.claude/skills/parallel-plan/SKILL.md:333-334`). It is **not** an F3 schema
  field and not a manifest field — it cannot be: at fan-out time the manifest does not yet exist
  (the planner authors it after preparation), so a manifest-carried cap could not govern intake.
  The library's own `>= 1` check (`parallel_cohort_computation.py:455`) rejects nonsense values at
  invocation.
- **Default:** 8. **Bound:** 1 through 16 (the Q1 ceiling), stated as the same sanity limit.
- **Why distinct from `max_concurrency`:** different phase (planning vs execution), different
  enforcer (planner batching vs F5 slot filling plus F7 hooks), different semantics
  (`max_concurrency` interacts with the cohort barrier and is a persisted, F3-validated schema
  field consumed at execution; preparation has no cohort structure — all preparations are mutually
  independent, so its cap is a pure resource throttle). Overloading `max_concurrency` would force
  one number to tune two unrelated workloads.

---

## Summary of recommendations

1. **Q1:** Raise the `max_concurrency` ceiling from 8 to 16 in the six validator constants and the
   prose, keeping default 4. No verified constraint binds at or below 16; 16 is a sanity limit —
   stated as such — with the first soft constraint (local workstation memory/CPU) estimated, not
   measured, in the low-to-mid teens. Runner-up 20 (GitHub Free-plan job limit) rejected: over-limit
   behavior is queuing, not failure, and jobs do not map 1:1 to items (9 CI jobs per item).
2. **Q2:** Adopt `expected_conflict_components`, a manifest-only optional field valued as nested
   ascending-sorted lists of `issue_num`; the planner compares it to derived components and reports
   differences in its completion report; no checkpoint field. Verified: the manifest validator
   tolerates unknown keys today, so the only validator touch is an optional shape check.
3. **Q3:** Option (b): a `preparation_concurrency` cap (default 8, bound 1..16), implemented as a
   skill-level batching rule reusing `compute-concurrency-batches.sh`, recorded in the planner
   checkpoint as a permitted additional field. The current fan-out is genuinely unbounded
   (`parallel-plan/SKILL.md:64-67` "launch ALL item preparations concurrently"). No new
   orchestration primitive is required; `/parallel-add` (one item per invocation) is not viable as
   a 69-item intake path.
