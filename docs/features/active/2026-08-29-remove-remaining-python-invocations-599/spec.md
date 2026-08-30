# 2026-08-29-remove-remaining-python-invocations — Spec

- **Issue:** #599
- **Parent (optional):** `docs/features/epics/claude-runtime-portability/epic.md` (Feature D, wave 2, complexity C3)
- **Owner:** drmoisan
- **Last Updated:** 2026-08-29T17-40
- **Status:** Draft
- **Version:** 0.2

All file:line citations in this document use the corrected spans recorded in the
`## Citation Corrections` table of
`docs/features/active/2026-08-29-remove-remaining-python-invocations-599/research/2026-08-29T17-10-remove-remaining-python-invocations-research.md`.
Where that table disagrees with `issue.md` or with the epic manifest, the research artifact governs.

## Overview

The `.claude/**` payload is published into consumer repositories by the push-down mechanism. Those
destinations guarantee no Python interpreter, no Poetry, and no `scripts/dev_tools` tree. Issue #475
already removed the Python dependency from the two discovery-gate hooks on the same reasoning. An
executable Python invocation that remains in the published payload makes the procedure step that
depends on it silently unavailable at its destination.

### The defect, stated precisely

There is **no contradiction** between `.claude/rules/parallel-orchestration.md` (invariant M8) and
`.claude/skills/parallel-plan/SKILL.md`. Both documents agree that the lane-assertion diagnostic's
FINDINGS are advisory-only and never block: the advisory paragraph is at
`.claude/skills/parallel-plan/SKILL.md:322-329`, and M8 states the same property. Any framing of this
feature as resolving a rule conflict is incorrect.

The genuine defect is narrower and concerns the diagnostic's INVOCATION rather than its findings:

- The invocation is a **mandatory procedure step**. `.claude/skills/parallel-plan/SKILL.md:313-315`
  states "Immediately after the conflict-edge set is derived and before anything consumes it, run the
  lane-assertion diagnostic"; the invocation literal itself is line **315**.
- The invocation's result is a **required planner completion-report line item**, spanning
  `.claude/skills/parallel-plan/SKILL.md:569-573`; line 569 opens it.
- Its only implementation is `scripts/dev_tools/parallel_lane_assertion.py`, which the destination
  runtime does not guarantee.

A mandatory step with a required report line item, whose only implementation is unavailable at the
destination, is the defect. The port must therefore make the step executable while preserving the
advisory-only semantics of its output exactly.

`docs/features/completed/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/spec.md:51` records
that this port was explicitly deferred when the diagnostic landed, and line 266 lists it as a deferred
follow-up. That deferral's stated rationale — the diagnostic "degrades gracefully on the no-Python
path" — is what this feature corrects: degrading gracefully means the mandatory step silently does
nothing at the destination.

### A live payload inconsistency this feature resolves

`.claude/skills/parallel-plan/SKILL.md:316` states that the lane-assertion call is "covered by the
planner's existing `Bash(poetry run *)` grant", while `.claude/agents/parallel-planner.md:185-186`
states that the same grant "is not required by any step above". Both statements ship in the payload
and contradict each other. Removing the Python invocation resolves the contradiction in the correct
direction.

## Behavior

### Site disposition

| # | site | disposition |
| --- | --- | --- |
| 1 | `.claude/skills/epic-orchestrate/SKILL.md:296` | **In scope, trivial.** Delete the CLI spelling. The MCP form `mcp__drm-copilot__validate_orchestration_artifacts` is already offered alongside it at lines 297-299. |
| 2 | `.claude/skills/parallel-orchestrate/SKILL.md:482` | **In scope, trivial.** Introduced as "or the equivalent CLI invocation"; delete the alternative and keep the MCP form at lines 480-481. |
| 3 | `.claude/skills/parallel-orchestrate/SKILL.md:817` | **Non-goal.** `parallel_drift_detection_cli`. See Non-Goals. |
| 4 | `.claude/skills/parallel-plan/SKILL.md:315` | **In scope, substantive.** `parallel_lane_assertion`; requires the new port. |
| 5 | `.claude/skills/parallel-remove/SKILL.md:112` | **Non-goal.** `parallel_mutation_abandon_cli.py`. See Non-Goals. |

The count of five executable Python or Poetry invocation sites under `.claude/**` is derived twice by
structurally different queries in the research artifact's `## Numeric Derivation Evidence`, with equal
member sets. The epic manifest's "exactly four" at manifest line 169 is superseded.

Site 4 loses no capability from the MCP form's retention on sites 1 and 2: `require_complete` is a
supported MCP argument (`extensions/drm-copilot/src/mcp-tool-definitions.ts:423`,
`mcp-repo-automation-tool-definitions.ts:356`).

### Target runtime — bash only

The port ships as **two** new bash files under `.claude/lib/bash/`, split on the pure-versus-I/O seam
that the Python reference declares for itself at `scripts/dev_tools/parallel_lane_assertion.py:34-38`
("Every function and method below EXCEPT `main` is pure … only `main`, the module's single I/O
boundary") and that both existing sibling ports already use (`parallel-cohorts.sh` pure /
`compute-cohorts.sh` I/O; `parallel-manifest-validate.sh` pure / `validate-parallel-manifest.sh` I/O):

- **`.claude/lib/bash/parallel-lane-assertion.sh`** — sourceable pure library, function prefix `pla_`.
  Holds component derivation, comparison, report formatting, manifest-input reading, and edge parsing,
  plus the four class-token constants. Sources `.claude/lib/bash/parallel-manifest-validate.sh` and
  reuses `pm_parse_manifest` and the four M1 message strings byte-for-byte rather than restating them.
- **`.claude/lib/bash/report-lane-assertion.sh`** — CLI entry point, function prefix `rla_`. Holds
  usage text, flag parsing, the manifest read, dispatch to the library, the `printf` of the report,
  and the exit-code contract, guarded by `[[ ${BASH_SOURCE[0]} == "${0}" ]]` as
  `compute-cohorts.sh:139-143` and `validate-parallel-manifest.sh:130-134` do.

PowerShell is rejected as a target: no module under `.claude/lib/**` parses YAML at all, so a
PowerShell port would need a net-new YAML subset parser or an unbounded `ConvertFrom-Yaml` dependency
that a bare destination does not provide. A dual-runtime port would add a third parity axis with no
consumer. Every artifact the diagnostic needs already exists on the bash side.

**Entry-point name.** `report-lane-assertion.sh`, not `assert-parallel-lanes.sh`. "assert" implies a
blocking verdict, which misdescribes an advisory-only diagnostic that always exits 0.

### Preserved semantics (non-negotiable)

The port inherits the design intent recorded in
`docs/features/completed/2026-08-16-parallel-lane-scale-and-barrier-semantics-479/spec.md:62` and
AC30 at line 260:

1. **Assertion, never declaration.** The port must never override a derived edge, never feed
   `compute_cohorts`, and never influence scheduling.
2. **No production consumer.** No file under `.claude/lib/bash/` may source
   `parallel-lane-assertion.sh` or `report-lane-assertion.sh`. The dependency arrow points outward
   only (diagnostic → manifest contract), mirroring `parallel_lane_assertion.py:50`.
3. **Advisory rendering, not an exit code.** A disagreement must not be expressible as a non-zero
   exit status. Every path except a usage error exits 0.
4. **Graceful degradation on partial input.** Malformed edges and malformed manifest entries are
   skipped, never raised.
5. **No state.** The port writes no file and no checkpoint field.
   `.claude/skills/parallel-plan/SKILL.md:328-329` already declares the planner-checkpoint record of
   the diagnostic's result "a tolerated extra field, not a validated one; no validator changes for
   it". No validator field is added.

## Inputs / Outputs

**Inputs**

- `--manifest <path>` — required. Path to `docs/features/parallel/<slug>/parallel.md`. The manifest is
  read through `pm_parse_manifest`; the port consumes `expected_conflict_components` (optional) and
  `items[].issue_num`.
- `--edges "<a>:<b> <c>:<d>"` — optional, default empty string. Derived conflict edges; empty means no
  edges.
- No environment input beyond `LC_ALL`, which the port sets itself via `pc_enforce_c_locale`.
- No clock read, no randomness, no network, no temporary file.

**Outputs**

- stdout only. One report, terminated by a single trailing newline.
- No artifact, no checkpoint mutation, no log file.

**External-utility budget.** `tests/shell/parallel_payload_only.bats:14-18, 41-42` runs the payload
under `PATH` set to a single shim directory holding exactly four binaries
(`tests/fixtures/parallel_payload_path/{cat,cut,dirname,sort}`). The port may use only those four plus
bash builtins, or the checked-in shim set must be extended. `cat` for the manifest read and `sort -n`
for numeric ordering stay inside the budget.

**Versioning / compatibility.** The Python reference module is unchanged by this feature and remains
the repository authority. The port adds a new command-line surface; it removes none.

## API / CLI Surface

```bash
bash .claude/lib/bash/report-lane-assertion.sh --manifest <path> [--edges "<a>:<b> <c>:<d>"]
```

The CLI surface is exactly `--manifest` and `--edges`. **There is no `--keys` flag**, because the
Python reference has none: item keys come from the manifest's `items[].issue_num`, not from the
command line. This is the largest surface difference from `compute-cohorts.sh`, which does take
`--keys`. Adding a `--keys` flag would create a surface the Python lane cannot mirror and is
prohibited.

### Exact output text

Header line:

```
Lane assertion: {N} derived conflict component(s); {D} disagreement(s).
```

Zero or more finding lines, each:

```
ADVISORY [{kind}] {detail}.
```

Closing line:

```
Advisory only: this diagnostic never blocks, never modifies a derived edge, never feeds compute_cohorts, and never influences scheduling.
```

Lines are joined with `\n` and the whole report is emitted with one trailing newline. `N` is the
derived-component count; `D` counts findings of the first three classes only, because
`INFORMATIONAL_KINDS` holds exactly `item_covered_by_no_component`.

### The four finding classes

| `kind` token | detail template |
| --- | --- |
| `expected_together_derived_apart` | `expected component {label} was derived apart: its members occupy {n} distinct conflict components` |
| `expected_apart_derived_together` | `derived conflict component {list} spans {n} expected components that were asserted apart` |
| `member_names_no_item` | `expected member {key} names no manifest item` |
| `item_covered_by_no_component` (informational) | `manifest item {key} is covered by no expected component` |

`{label}` is `'{name}'` when the component carries a string `name`, otherwise `component[{position}]`
with a zero-based manifest index. An empty-string name is a string and renders as `''`. `{list}`
renders the Python list form of a tuple of integers — square brackets, comma-and-space separator, no
trailing comma, for example `[101, 102]`.

### Exit-code contract

| Path | Exit | Output |
| --- | --- | --- |
| Usage error (unknown flag, missing `--manifest`) | **2** | usage text on stderr |
| `--help` | 0 | usage text on stdout |
| Manifest unreadable | 0 | `Lane assertion: manifest unreadable ({detail}); no comparison made.` |
| Manifest frontmatter does not parse to a mapping | 0 | `Lane assertion: manifest unparseable ({first M1 error}).` |
| Manifest out of the bash YAML subset | 0 | distinct refusal line (bash-only; see Divergence class 5) |
| Normal path, no findings | 0 | header + closing line |
| Normal path, with findings | 0 | header + N `ADVISORY` lines + closing line |

Exit 2 on a usage error is the only non-zero exit and matches `argparse`.

## Data & State

The port introduces no persisted state, no cache, and no migration. It is a pure read of one manifest
plus one command-line string, followed by one write to stdout.

### Ordering rules (load-bearing for parity)

1. Findings are grouped by class in the fixed order split → merged → unknown-member → uncovered-item.
2. Within the split class, expected components are visited in **manifest** order.
3. Within the merged class, derived components are visited in **derived** order (lowest member
   ascending).
4. Within the last two classes, keys are visited **ascending**.
5. Derived component members are ascending; components are ordered by lowest member.
6. Every finding's own member list is ascending.
7. Every sort runs under `LC_ALL=C` via `pc_enforce_c_locale`, and every numeric sort uses `sort -n`.

### Derivation and comparison details the port must reproduce

- Adjacency is seeded from every declared key, so an isolated vertex survives as its own component.
- An edge is skipped when both endpoints are equal, or when either endpoint is not a declared key. No
  error is raised.
- Adjacency is symmetric and set-valued, so direction and duplicate edges collapse.
- BFS runs from each unvisited root in ascending key order; the visited set is marked at enqueue time.
- `expected_index` is built in manifest order, so when one key appears in two asserted components the
  **last** occurrence wins. The port reproduces that and does not report an error; M8 validation is a
  separate concern.
- Manifest reads are defensive: a non-list `expected_conflict_components`, a non-dict entry, a non-list
  `members`, or a non-string `name` is skipped rather than raised. A component whose members are all
  filtered out still survives with an empty member list.
- A member is kept only if it is a positive integer and not a boolean. Members are kept in manifest
  order and are **not** de-duplicated. Item keys are de-duplicated and sorted ascending.

### The YAML-subset constraint is already satisfied

`issue.md:126-127` lists the bash YAML subset parser as a constraint on how
`expected_conflict_components` can be read. Verification shows the constraint is **already
discharged**, not open:

- `.claude/lib/bash/parallel-manifest-validate.sh:203-237` (`pm_validate_expected_components`) already
  reads `expected_conflict_components`, its per-entry `.name`, and its `.members` list through the node
  table.
- `.claude/lib/bash/parallel-manifest-validate.sh:159-201` (`pm_validate_component_members`) already
  walks the members and enforces the M8 rules.
- The only unsupported shape is the non-empty flow collection, which is already prohibited by prose in
  two places that name the parser: `.claude/rules/parallel-orchestration.md:132` and
  `.claude/skills/parallel-plan/SKILL.md:374-375`.

The port consumes the existing node table. Nothing inside or outside this feature's scope must change
to make the key readable at the destination.

## Implementation Strategy

### Files added

| Path | Role |
| --- | --- |
| `.claude/lib/bash/parallel-lane-assertion.sh` | pure library, `pla_` prefix |
| `.claude/lib/bash/report-lane-assertion.sh` | CLI entry point, `rla_` prefix |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/parallel-lane-assertion.sh` | bundle mirror |
| `extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash/report-lane-assertion.sh` | bundle mirror |
| `tests/fixtures/parallel_lane_assertion/*.json` | shared parity corpus |
| `tests/shell/parallel_lane_assertion.bats` | bash unit suite (where coverage is earned) |
| `tests/shell/parallel_lane_assertion_parity.bats` | bash parity lane over the shared corpus |
| `tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py` | Python parity lane over the same corpus |

### Files edited

| Path | Edit |
| --- | --- |
| `.claude/skills/parallel-plan/SKILL.md` | Replace the invocation at line 315 with the bash entry point; correct the grant note at line 316. Leave 322-329 and 569-573 semantically unchanged. |
| `.claude/skills/epic-orchestrate/SKILL.md` | Delete the site-1 CLI spelling at line 296; retain the MCP form. |
| `.claude/skills/parallel-orchestrate/SKILL.md` | Delete the site-2 CLI spelling at line 482; retain the MCP form. Do not touch line 817. |
| `.claude/agents/parallel-planner.md` | Add the entry-point grant to `tools:`; document the entry point in `## Upstream Library Invocation`; reconcile the stale sentence at 185-186. |
| `.claude/agents/parallel-orchestrator.md` | Reconcile the grant rationale at lines 92-97 after site 2 is deleted. See below. |
| `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` | Register both new bash paths beside lines 137-145. |
| `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` | Extend the entry-point enumeration at lines 242-244. |
| `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts` | Extend the entry-point enumeration at lines 451-453. |
| `tests/shell/parallel_bash_manifest_membership.bats` | Raise `MINIMUM_LIB_FILE_COUNT` at line 21 from 9 to 11. |
| `tests/shell/parallel_payload_only.bats` | Add cases invoking the new entry point from the bundle root under the four-shim `PATH`. |
| The bundle mirrors of the five edited `.claude/**` files | Re-copy byte-identically. |

### `.claude/agents/parallel-orchestrator.md` is required, not optional

Lines 92-97 justify the two retained `poetry run` grants by naming exactly two consumers: "the
checkpoint-validator CLI fallback the skill names in its `## Parallel-Level Checkpoint` section is
invoked as `poetry run python -m`, and the drift-detection CLI likewise." The **first** of those two
named consumers is site 2 — the CLI form at `.claude/skills/parallel-orchestrate/SKILL.md:482`, inside
the `## Parallel-Level Checkpoint` section whose prose begins at line 470. Deleting site 2 leaves the
rationale citing a consumer that no longer exists.

Neither the epic manifest nor `issue.md` records this coupling. It is a real scope item and this
feature must discharge it in the same change.

### The bundle-mirror constraint

`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
(lines 101-126) enumerates every file under `.claude/`, excluding exactly `settings.local.json` and
the `.claude/agent-memory/**` subtree, and requires each to exist under
`extensions/drm-copilot/resources/claude-customizations/.claude/**` with identical UTF-8 text. The
check is one-way: a bundle-only file with no repository counterpart does not fail it. A second,
independent check in `tests/shell/parallel_bash_manifest_membership.bats:56-71` uses `cmp -s`, a true
byte comparison, over the bash library, and lines 73-82 additionally assert that no bundled-only bash
file exists.

No script mirrors repository `.claude/**` into the bundle.
`scripts/dev_tools/push_down_claude_customizations.py` runs the other direction. The copy is manual and
those two tests are the only guards.

`extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` is **outside** the
`.claude/**` parity scope (`test_pack_manifests_are_outside_the_parity_scope`, lines 129-146) and
therefore exists only in the bundle. Registering both new paths there is a separate obligation: without
it, `tests/shell/parallel_bash_manifest_membership.bats:43-54` fails and a manifest-scoped push-down
silently drops both new files.

### Declared divergences from the Python reference

Five classes, of which two are inherited from the existing parity suites and three are new to this
feature. Each must be stated in the header of every lane that reads the shared corpus.

- **Class 1 (inherited) — M1 YAML-parse-failure text.** The bash `YP_DETAIL` text is not PyYAML's
  exception text. A corpus fixture that exercises `Lane assertion: manifest unparseable (...)` through
  the YAML-error branch pins the prefix only.
- **Class 2 (inherited) — non-printable string-repr escapes.** No corpus fixture may contain a control
  character other than `\n`, `\r`, or `\t`.
- **Class 3 (new) — `--edges` integer lexis.** The port does **not** reproduce Python `int()`'s
  permissiveness. It applies the strict lexis `^-?(0|[1-9][0-9]*)$` already used at
  `.claude/lib/bash/compute-cohorts.sh:59`. The **excluded input class is exactly these four members**:
  an `--edges` endpoint token bearing a leading zero (`007`), a leading `+` (`+5`), an underscore digit
  separator (`1_0`), or a non-ASCII decimal digit. The Python reference accepts each of these four and
  coerces it to an integer; the port drops the whole edge token instead. This divergence is deliberate
  and matches the precedent `tests/shell/parallel_cohorts_parity.bats:25-29` already sets for the cohort
  entry points. It is excluded from the shared corpus and is pinned by a bash-only unit test, so the
  divergence is observable rather than indistinguishable from a porting defect.

  **Whitespace inside an endpoint is not a member of class 3 and must not be added back to it.** It is
  unreachable in both implementations, so no port behavior can diverge on it. The mechanism is recorded
  here rather than the case being deleted, so that a later reader does not restore it:
  `scripts/dev_tools/parallel_lane_assertion.py:425` splits the `--edges` value with `str.split()`
  before `token.partition(":")` at line 426, so no resulting token can carry interior whitespace. The
  input `--edges "101 : 202"` yields the three tokens `101`, `:`, and `202`; the bare `:` reaches
  `int("")` and is discarded by the `ValueError` path at lines 430-431. The port specified here consumes
  the same whitespace-separated token stream, so it cannot observe interior whitespace either. Because
  the two implementations converge on this input, it is covered as a **convergence** fixture in the
  shared corpus — both lanes reproduce the same report the empty `--edges` value produces for the same
  manifest — and not by the bash-only divergence test that pins the four members above.
- **Class 4 (new) — manifest-unreadable detail text.** Python emits the `OSError` string, for example
  `[Errno 2] No such file or directory: 'x'`, which bash cannot reproduce. Pin the prefix
  `Lane assertion: manifest unreadable (` only, or exclude the class from the shared corpus and cover
  it bash-side.
- **Class 5 (new) — out-of-subset manifests.** `pm_parse_manifest` returns status 2 for constructs the
  Python authority parses successfully, so the Python lane has **no counterpart**. The port prints a
  distinct refusal line and **exits 0**, preserving the never-blocks contract. This case is covered by
  the bash unit suite only and is **excluded from the parity corpus**.

### Parity-suite shape

The corpus record shape follows the two existing corpora: `name`, `notes`, `manifest_text` (the raw
document), `edges` (the raw `--edges` string), `expected_stdout` (the full report as one string with
`\n` separators and no trailing newline), `expected_status` (always 0), and an optional `divergence`
marker. Both lanes declare a `MINIMUM_FIXTURE_COUNT` floor and assert it in a dedicated case, and the
bats lane carries the `python3 is available` case that the two existing parity suites use, so neither
lane can pass vacuously. The bats lane invokes the entry point as a subprocess so that it pins the exit
code as well as stdout; the Python lane starts no subprocess and asserts against the same fixture files.

`python3` in the parity suites is a harness dependency for reading checked-in JSON, not a dependency of
the code under test. Destination portability is asserted separately by
`tests/shell/parallel_payload_only.bats`, which removes every interpreter from `PATH`.

### Edge cases the corpus and unit suite must cover

- Manifest with no `expected_conflict_components` key: every item reported uncovered, 0 disagreements.
- Manifest with an empty `items` list and no assertion: header with 0 components and 0 disagreements
  plus the closing line only.
- Component with `name` absent (`component[0]` label) and component with `name: ''` (`''` label).
- Component whose members include a non-positive or boolean value: that member is dropped, the
  component survives.
- Component whose members are all dropped: an empty component that can produce no finding.
- The same `issue_num` in two components: the later position wins; the diagnostic reports no error.
- A duplicate member inside one component: duplicated in the resolved list and in the finding's member
  list.
- Self-loop edge and an edge naming an undeclared key: both silently skipped.
- Reversed and duplicated edges: collapse to one adjacency entry.
- An `--edges` token with no colon, with two colons, or with a non-integer endpoint: dropped.
- Empty and whitespace-only `--edges`: no edges.
- 13 lanes over 69 items (the motivating scale): exactly 13 components, 0 disagreements.

### Rollout

No feature flag, no staged deploy, no migration. The port is additive; the three edited skill sites are
text edits; the fallback path is the unchanged Python module, which remains the repository authority
and is still runnable in the repository.

## Constraints & Risks

### Bash conventions the port follows

- `set -euo pipefail` in the entry point, as `compute-cohorts.sh:26` and
  `validate-parallel-manifest.sh:24` do.
- Self-directory resolution before sourcing, so a library loads regardless of the working directory, as
  `compute-cohorts.sh:29-32` and `parallel-manifest-validate.sh:31-34` do.
- `pc_enforce_c_locale` called before any work, as `compute-cohorts.sh:34` and
  `validate-parallel-manifest.sh:32` do; rationale at `parallel-common.sh:13-16`.
- shellcheck-clean with inline justified suppressions only; shfmt default tab indentation; all
  expansions quoted; intentionally non-zero tools captured with `|| rc=$?`.

### Feature A dependency status — no application surface

Neither sibling feature folder exists on this branch. `docs/features/active/*/spec.md` returns 25
folders, and neither `blast-radius-powershell-calling-convention` (Feature A) nor
`caller-site-invocation-correctness` (Feature C) is among them; globs for `*calling-convention*` and
`*caller-site*` under `docs/features/**` return no files. The manifest's placeholder issue numbers
901-904 are still unresolved.

`issue.md:134-135` states that a new `.claude/lib/**` module must follow the fail-fast import and
date-coercion conventions Feature A establishes. Under the bash-only design, **neither applies**, and
both absences are deliberate rather than omissions:

- **Fail-fast import.** Feature A's convention is `$ErrorActionPreference` plus
  `Import-Module -ErrorAction Stop`. Both are PowerShell constructs with no bash analogue. This feature
  adds no PowerShell file, so the convention has no application surface. The bash equivalents listed
  above express the same intent in the destination runtime and are followed instead.
- **Date coercion.** Feature A retargets this to the three `ConvertFrom-Json` sites under
  `.claude/lib/**`. The port parses no JSON and reads no timestamp; it consumes
  `expected_conflict_components` and `items[].issue_num` only. The convention has no application
  surface.

### Feature C contention — section-level, in one file

| File | Feature C region | Feature D region | Overlap |
| --- | --- | --- | --- |
| `.claude/skills/parallel-plan/SKILL.md` | 182-184 (`Import-Module` fence) | 313-329 and 569-573 | None line-wise; roughly 130 lines apart |
| `.claude/agents/parallel-planner.md` | 151, inside `## Upstream Library Invocation` (140-186) | `tools:` at 5-20 and the same section at 158-186 | **Yes, section-level** |
| `.claude/skills/parallel-add/SKILL.md` | 62 | none | None |
| `.claude/agents/parallel-orchestrator.md` | none | 92-97 | None |

Both features edit `## Upstream Library Invocation` in `.claude/agents/parallel-planner.md`. Feature C
rewrites the PowerShell paragraph at lines **147-156**. This feature must confine its edits in that
section to the `tools:` list and the bash paragraph (158-168 plus the stale sentence at 185-186) and
must leave 147-156 untouched. If Feature C lands first, this feature must not restate or re-edit its
`pwsh`, root-anchored module path, `-ErrorAction Stop`, or `$result['conflict']` changes.

### Toolchain and size

- `.claude/lib/bash/` is one of the three shell discovery roots (`scripts/bash/shell_qc_lib.sh:85`) and
  is inside the kcov include pattern as a **directory** pattern
  (`scripts/bash/shell_qc_lib.sh:335`), so both new files are measured automatically with no
  registration step.
- Toolchain order: `bash scripts/bash/shell-qc.sh format` → `bash scripts/bash/shell-qc.sh check` →
  `bash scripts/bash/shell-qc.sh test [--coverage]`. Restart from step 1 on any failure or rewrite. On
  Windows, run under WSL.
- Line coverage >= 85%. kcov reports line coverage only; there is no bash branch-coverage gate.
- 500-line cap per file. The Python reference's 499 lines are docstring-dominant and are not a size
  proxy; the comparable ports are 330 lines (`parallel-cohorts.sh`) and 299 lines
  (`parallel-manifest-validate.sh`). The expected landing size is roughly 250-320 library lines plus
  110-140 entry-point lines, inside the cap in two files. If the library nonetheless overruns, the
  fallback seam is derivation versus comparison-and-formatting, following the
  `parallel-yaml-scan.sh` / `parallel-yaml-emit.sh` precedent.
- No temporary files anywhere in tests; the corpus and fixture manifests are checked in.
- No production file may be excluded from coverage measurement. Both new bash files are production
  files under a measured root and may not be excluded.
- The PowerShell per-batch cap (3 production, 3 test) does not bind, because no PowerShell file is
  added or modified.

### Risks

- **Manual bundle mirroring.** The repository-to-bundle copy has no automation. The two mirror tests
  are the only guards, and `core.json` is guarded only by the bats membership suite. Registering the
  files in `core.json` is easy to omit and fails loudly only in that one suite.
- **Rebase contention on `parallel-planner.md`.** Wave serialization removes the merge risk in
  principle, but the paragraph boundaries in `## Upstream Library Invocation` can shift.
- **Divergence class 3 is a behavior difference, not a bug.** Without the pinning unit test it would be
  indistinguishable from a porting defect. The test is mandatory for that reason.

## Non-Goals

Four items are explicitly out of scope. Each has a recorded rationale.

### 1. `parallel_drift_detection_cli` — site 3, `.claude/skills/parallel-orchestrate/SKILL.md:817`

The invocation sits under a heading literally named `#### CLI Invocation` (line 809) and is the sole
I/O wrapper over two pure modules (lines 811-814). `.claude/agents/parallel-orchestrator.md:92-96`
deliberately retains `Bash(poetry run python -m *)` for it and scopes the grant "to those two
invocation forms only — not to `poetry run` as a whole". The dependency is a recorded decision, not
accidental drift. Porting it is a second net-new implementation outside this epic's approved scope.

### 2. `parallel_mutation_abandon_cli.py` — site 5, `.claude/skills/parallel-remove/SKILL.md:112`

This site was never identified by the epic intake, which asserted four sites. It is mandatory in the
strongest available terms (lines 105-118): the abandon disposition runs "through the single
deterministic CLI invocation below and through nothing else", and ad hoc `gh pr close` /
`git worktree remove` is prohibited because the abandon gate matches on the invocation's tokens.
`.claude/hooks/enforce-parallel-abandon-gate.ps1` declares those matched token literals in exactly one
place, beginning at line **38** ("These are the ONLY places either token literal appears in this
file"); line 29 is a `.NOTES` comment naming the producer-side module.
`tests/scripts/dev_tools/test_parallel_abandon_token_seam.py` parses both sides at run time so a
one-sided rename fails. Changing the invocation without co-designing the gate would break the
confirmation contract the gate exists to enforce. That is a separate design decision.

### 3. `.claude/rules/parallel-orchestration.md` — no edit

Two independent reasons, either sufficient:

- The `policy-compliance-order` skill prohibits modifying documents under `.claude/rules/`.
- Its M8 passage identifies `scripts/dev_tools/parallel_lane_assertion.py` as the authoritative
  reference implementation. That is exactly the legitimate prose-citation class this feature places out
  of scope: of the 158 `scripts/dev_tools` citations across 46 files under `.claude/**`, all but the
  five executable invocation sites are authority citations and must not be touched.

The research artifact's section 5.3 item 8 records an optional wording addition to that file. This
feature declines it. No edit to `.claude/rules/parallel-orchestration.md` is planned or required.

### 4. The discovery-gate hook rationale comments — no change required

`.claude/hooks/enforce-discovery-artifact-gate.ps1:49-52` and
`.claude/hooks/validate-discovery-artifact-gate.ps1:50-53` carry an identical four-line paragraph
reading "This no longer invokes a Python interpreter (issue #475)" and recording why the payload must
not depend on Python. This is live rationale, not stale drift: the text is accurate today and remains
accurate after this feature, and it names no path this feature alters. Both files are already covered
by `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1`, which asserts at
lines 319-331 that an interpreter name inside a comment produces no finding, so the comments are proven
inert to the guard. Preserve the rationale; a wording refresh is permitted but not required, and **no
change at all is an acceptable outcome**. Editing them would produce two more mirror files to re-sync
for no behavioral benefit.

## Known Residual — the epic's broad leading indicator

The epic manifest's leading indicator at **manifest line 14** reads: "No file under `.claude/**`
contains an executable python or poetry invocation that a mandatory procedure step depends on." Under a
strict reading, that indicator is **not fully satisfied** after this feature lands, because site 3 sits
inside an orchestrator-side detection procedure and site 5 is mandatory in the strongest terms. Both
remain by deliberate decision, for the rationales recorded in Non-Goals items 1 and 2.

The narrower indicator at **manifest line 15** — "The lane-assertion diagnostic runs to completion on a
destination runtime with no Python interpreter present" — **is** fully satisfied by this feature, and
its acceptance evidence is the payload-only suite case.

This residual is a known, deliberate remainder. The corrective action is an epic-owner rewording of
manifest line 14 to scope it to the sites this epic actually closes. It is **not** additional
implementation work here, and no acceptance criterion in this document depends on the broad indicator.

## Acceptance Criteria

- [ ] `.claude/lib/bash/parallel-lane-assertion.sh` and `.claude/lib/bash/report-lane-assertion.sh`
      both exist, and `bash scripts/bash/shell-qc.sh check` exits 0 with the two files present in its
      shfmt and shellcheck scan output.
- [ ] `tests/shell/parallel_lane_assertion.bats` passes, and its case set includes a case asserting the
      entry point resolves its own directory before sourcing, a case asserting `pc_enforce_c_locale` is
      called before any output is produced, and a case asserting the entry point's first executable
      line establishes `set -euo pipefail`.
- [ ] `tests/shell/parallel_lane_assertion.bats` contains a case asserting
      `bash .claude/lib/bash/report-lane-assertion.sh --keys "101 102" --manifest <fixture>` exits **2**
      with usage text on stderr, pinning that no `--keys` flag was added.
- [ ] `tests/shell/parallel_lane_assertion.bats` contains a case pinning divergence class 3: for an
      `--edges` value whose endpoint token bears a leading zero, a leading `+`, an underscore digit
      separator, or a non-ASCII decimal digit — the four reachable members of the class — the port drops
      the edge token, and the resulting report differs from the Python reference's report for the same
      input in the manner the spec's Divergence class 3 states. Interior whitespace inside an endpoint is
      pinned separately and as a **convergence** case, because both implementations drop the token for
      it: a corpus fixture under `tests/fixtures/parallel_lane_assertion/` supplies an `--edges` value
      carrying interior whitespace inside an endpoint, both parity lanes reproduce that fixture's
      `expected_stdout` byte-for-byte, and that `expected_stdout` is identical to the report the same
      manifest produces with an empty `--edges` value.
- [ ] `tests/shell/parallel_lane_assertion.bats` contains a case asserting that an out-of-subset
      manifest (one for which `pm_parse_manifest` returns status 2) produces the distinct refusal line
      and exit status **0**, and that the corresponding input appears in no file under
      `tests/fixtures/parallel_lane_assertion/`.
- [ ] `tests/shell/parallel_lane_assertion_parity.bats` and
      `tests/scripts/dev_tools/test_parallel_lane_assertion_bash_parity.py` both pass over
      `tests/fixtures/parallel_lane_assertion/*.json`; each declares a `MINIMUM_FIXTURE_COUNT` floor and
      asserts it in a dedicated case; and the bats lane carries a case asserting `python3` is available
      so the suite cannot pass vacuously.
- [ ] A parity-lane case asserts that each of the four `kind` tokens
      `expected_together_derived_apart`, `expected_apart_derived_together`, `member_names_no_item`, and
      `item_covered_by_no_component` appears in the `expected_stdout` of at least one corpus fixture.
- [ ] A parity-lane case asserts `expected_status` is 0 for every corpus fixture, and
      `tests/shell/parallel_lane_assertion_parity.bats` compares the subprocess exit status against it,
      including for at least one fixture whose `expected_stdout` contains an `ADVISORY` line.
- [ ] `tests/shell/parallel_lane_assertion.bats` contains a case asserting that no file under
      `.claude/lib/bash/` other than `report-lane-assertion.sh` sources `parallel-lane-assertion.sh`,
      and that no file under `.claude/lib/bash/` sources `report-lane-assertion.sh`, pinning that the
      diagnostic feeds no cohort, validation, or scheduling module.
- [ ] `tests/shell/parallel_payload_only.bats` passes and contains at least one case invoking
      `.claude/lib/bash/report-lane-assertion.sh` from the bundle root under the four-shim `PATH`,
      asserting exit 0 and the expected report text.
- [ ] `git grep -n -F "python -m scripts.dev_tools." -- .claude/skills/` returns exactly **one** match,
      at `.claude/skills/parallel-orchestrate/SKILL.md:817` for the drift-detection CLI. The same
      command returns **four** matches before this feature — sites 1, 2, and 3 plus line 817 — so the
      drop from four to one is the evidence that all three in-scope sites are closed. Separately,
      `git grep -n -F "poetry run python" -- .claude/skills/` returns exactly **two** matches,
      `.claude/skills/parallel-orchestrate/SKILL.md:817` and
      `.claude/skills/parallel-remove/SKILL.md:112`, both of which are declared non-goals of this
      feature. And
      `git grep -c -F "mcp__drm-copilot__validate_orchestration_artifacts" -- .claude/skills/epic-orchestrate/SKILL.md .claude/skills/parallel-orchestrate/SKILL.md`
      reports a non-zero count for both files.
- [ ] `git grep -n -F "parallel_lane_assertion" -- .claude/skills/parallel-plan/SKILL.md` returns no
      executable invocation, and the same file contains the literal
      `bash .claude/lib/bash/report-lane-assertion.sh` inside the seeding-procedure step.
- [ ] `.claude/agents/parallel-planner.md` `tools:` list contains
      `Bash(bash .claude/lib/bash/report-lane-assertion.sh*)`, its `## Upstream Library Invocation`
      section documents the entry point, and
      `git diff --stat origin/main...HEAD -- .claude/agents/parallel-planner.md` shows no changed line
      inside the PowerShell paragraph at lines 147-156.
- [ ] `git grep -n -F "checkpoint-validator CLI fallback" -- .claude/agents/parallel-orchestrator.md`
      returns no match, and the grant-rationale paragraph in that file names only consumers that still
      exist after site 2 is deleted.
- [ ] `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`
      passes.
- [ ] `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists both
      `.claude/lib/bash/parallel-lane-assertion.sh` and `.claude/lib/bash/report-lane-assertion.sh` in
      its `paths` array, and `tests/shell/parallel_bash_manifest_membership.bats` passes with
      `MINIMUM_LIB_FILE_COUNT` raised from 9 to 11.
- [ ] The entry-point enumerations at
      `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts:242-244` and
      `extensions/drm-copilot/test/lib/push-down/claude-config-carriage.test.ts:451-453` each include
      `.claude/lib/bash/report-lane-assertion.sh`, and both suites pass.
- [ ] `bash scripts/bash/shell-qc.sh test --coverage` reports bash line coverage >= 85%, and
      `artifacts/pester/kcov/cov.xml` contains per-file rows for both new bash files with neither file
      appearing in any coverage `exclude` configuration. The coverage run output is recorded under
      `docs/features/active/2026-08-29-remove-remaining-python-invocations-599/evidence/qa-gates/`.
- [ ] `wc -l` reports at most 500 lines for each of `.claude/lib/bash/parallel-lane-assertion.sh` and
      `.claude/lib/bash/report-lane-assertion.sh`.
- [ ] `git diff --stat origin/main...HEAD` shows no changed line in
      `.claude/rules/parallel-orchestration.md`, `.claude/skills/parallel-remove/SKILL.md`, or
      `.claude/skills/parallel-orchestrate/SKILL.md` line 817's drift-detection invocation, and
      `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` passes with its
      allowlist still empty.

## Definition of Done

- [ ] Every acceptance criterion above is checked off with the named test or command as its evidence.
- [ ] The seven-stage toolchain loop completes without error in a single pass for the shell lane
      (format → check → test) and the Python lane (`poetry run black|ruff|pyright|pytest`).
- [ ] Both new bash files and all five edited `.claude/**` files are mirrored into the bundle, and both
      mirror guards pass.
- [ ] The residual recorded in "Known Residual" is reported to the epic owner as a manifest-wording
      action, with no implementation change made for it here.
