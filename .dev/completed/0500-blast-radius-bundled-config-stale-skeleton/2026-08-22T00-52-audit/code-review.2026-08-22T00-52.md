# Code Review: blast-radius bundled truth-table correction (#500)

**Review Date:** 2026-08-22
**Reviewer:** feature-review
**Feature Folder:** `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500`
**Feature Folder Selection Rule:** the only active folder whose suffix matches the issue number in the branch name `bug/blast-radius-bundled-config-stale-skeleton-500`, and the only active folder with scoping-document changes in this diff.
**Base Branch:** `main` @ `fb30a9a58b8422e610a09b07361421e97367807a`
**Head Branch:** `bug/blast-radius-bundled-config-stale-skeleton-500` @ `59425465`
**Review Type:** Initial review

---

## Executive Summary

The branch fixes a two-directional contention defect in the blast-radius truth table that the Claude push-down publishes into destination workspaces, and closes the parity-gate scope gap that allowed the defect to persist. The production delta is one key removed from one exported TypeScript constant. Everything else is configuration data, one rule amendment mirrored into the bundled payload, and test code that holds the corrected state in place across three languages.

The change is unusually well evidenced for its size. The root-cause analysis is correct on the point that matters most: `claude-runtime` never reached a destination through the bundled JSON at all, because `assembleModules` never reads the source document's `modules` key. It reached destinations through the hardcoded `PAYLOAD_MODULES` constant. The reviewer verified this independently and confirms that a repository-wide search for a `.claude` umbrella glob outside hermetic fixtures and documentation now returns zero matches, so `PAYLOAD_MODULES` was and is the sole publisher.

The reviewer independently reproduced the fail-before state in two languages, reproduced the headline conflict-graph measurement to the exact edge count, and reran every toolchain stage. One documentary defect prevents an unconditional pass: two acceptance criteria assert delivery in a file that does not carry the delivered gate and cite a verification command that collects none of it.

**What changed:**

- `PAYLOAD_MODULES` in `extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive-core.ts` loses `claude-runtime`, leaving `{ config: ["config/**"] }`, with a rewritten doc comment carrying a `@remarks` block that states the granularity criterion and the non-vacuity argument for retaining `config`.
- The bundled `config/blast-radius.json` gains a six-entry destination-portable `shared_surfaces` set including three separator-free entries, gains four `mandate_reads` entries, and loses the `claude-runtime` module.
- The self-hosted `config/blast-radius.json` gains the same four `mandate_reads` entries and nothing else.
- `.claude/rules/parallel-orchestration.md` gains a 44-line section recording the relation between the two copies, mirrored byte-identically into the bundled rules file in the same commit.
- A three-class key-partition drift gate lands in two new Python test modules, is mirrored in four Pester cases, and is complemented by two new Jest cases.

**Top 3 risks:**

1. The Class 2 relation is a pin against unilateral bundle edits, not a drift detector against self-hosted evolution. A portable shared surface added to the self-hosted copy alone will silently never reach the bundle. This is the same failure shape as the defect being fixed, one level up, though its catastrophic form is independently blocked.
2. Two acceptance criteria name a source file that does not carry the gate and cite a verification command that exercises none of it, so the acceptance record is not truthful as written.
3. The change is destination-visible. A workspace that receives a subsequent push-down gains three separator-free shared surfaces and four mandate-read exclusions and loses a module. The obligation to state this in the pull-request body is carried forward and cannot yet be verified.

**PR readiness recommendation:** **Conditional Go** — the implementation, evidence, and toolchain are sound; correct the AC9 and AC10 criterion text in `spec.md` so the acceptance record names the file that actually carries the gate, then proceed.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md` | `## Acceptance Criteria`, AC9 and AC10 | Both criteria assert that `tests/scripts/dev_tools/test_blast_radius_config.py` carries the three-class gate and both name `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py` as the verification. That file is untouched at 499 lines and that invocation collects 32 cases, none of which is a gate case. The gate landed in the sibling `test_blast_radius_config_parity.py` under recorded deviation PD-1. Both criteria are nonetheless checked. | Amend the AC9 and AC10 criterion text to name `tests/scripts/dev_tools/test_blast_radius_config_parity.py` together with its support module `tests/scripts/dev_tools/blast_radius_parity_test_support.py`, and to cite `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py`. Then re-check both boxes. | A checked acceptance criterion whose stated verification command cannot fail with respect to the property it asserts is exactly the defect class `.claude/rules/plan-acceptance-gates.md` exists to prevent. The substance is delivered; only the record is wrong, and the correction is documentation-only. | `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config.py` exit 0, `32 passed`; `--collect-only` matched zero of `class_one`, `class_two`, `class_three`, `umbrella`. Contrast `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py` exit 0, `14 passed`. |
| Major | `tests/scripts/dev_tools/test_blast_radius_config_parity.py` | `test_class_two_bundled_shared_surfaces_are_the_portable_set`, lines 197-224 | Class 2 compares the bundled `shared_surfaces` against the hand-declared `PORTABLE_SHARED_SURFACES` constant and against `bundled <= self_hosted`. Neither condition is violated when the self-hosted copy gains a portable entry that the bundle does not, so the gate does not detect drift in the direction that produced Cause B. | Add a directional invariant asserting that every separator-free self-hosted `shared_surfaces` entry appears in the bundled set. Mirror it in the Pester file. This is machine-decidable, holds today, and would have failed loudly against the pre-fix bundle. Optionally record the rejected alternative in `.claude/rules/parallel-orchestration.md` so the choice is not re-litigated. | `PORTABLE_SHARED_SURFACES` is a declared constant whose own staleness is unguarded, which is the property research `## 4.4` used to reject Option B, the checked-in expected-delta manifest. The chosen design inherits that property for Class 2 while avoiding it for Class 1. | Reviewer probe: appending `Directory.Build.props` to the self-hosted `shared_surfaces` left `poetry run pytest tests/scripts/dev_tools/test_blast_radius_config_parity.py tests/scripts/dev_tools/test_blast_radius_config.py` at exit 0 with `48 passed`. Historical check: at `a45a993b` the self-hosted separator-free set was exactly `poetry.lock`, `package-lock.json`, `quality-tiers.yml` while the bundle carried none, so the proposed invariant would have fired. |
| Minor | `docs/features/active/2026-08-21-blast-radius-bundled-config-stale-skeleton-500/spec.md` | `## Risks & Mitigations`, mitigations list | The sentence "Class 1 byte-equality and Class 2 portable-set equality both fail loudly when a future self-hosted change does not reach the bundle" is accurate for Class 1 and inaccurate for Class 2. | Restate the Class 2 mitigation as what it is: equality against a declared constant that fails on any unilateral change to the bundled set or to the constant, and that does not observe self-hosted growth. | The sentence is the stated mitigation for the recurrence risk of the bug being fixed, so its accuracy is load-bearing for a future reader deciding whether the risk is closed. | Same probe as the Major finding above. |
| Minor | `docs/features/.../evidence/other/post-fix-conflict-graph.2026-08-22T00-20.md` | `## Commands` block | The recorded command description states the script derives over every folder carrying a `plan*.md` but omits that each folder's `spec.md` was supplied as the `spec_text` argument. Without that argument the same procedure yields 979 and 954 edges, not 1199 and 1182. | Amend the command description to state that `spec.md` was passed as `spec_text`, or record the script's argument list. | An evidence artifact whose recorded command does not reproduce its recorded numbers cannot be audited from the artifact alone. | Reviewer reproduction: without `spec_text`, pre 979 and post 954; with `spec_text`, pre 1199 and post 1182 over 56 items and 1540 pairs, matching the artifact exactly. |
| Minor | `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` | `declares equal values for the runtime-describing keys in both copies`, lines 249-266 | The Class 1 mirror compares `$config[$key] \| ConvertTo-Json -Depth 10 -Compress`. The pipeline form unrolls a collection, so a single-element list and a bare scalar serialize identically, and an empty list serializes as `$null` exactly as an absent key does. | Use `ConvertTo-Json -InputObject $config[$key] -Depth 10 -Compress` on both sides. | The PowerShell file is the second line of defence for the same invariant. A comparison that conflates a list with a scalar weakens that defence, even though the authoritative Python gate compares parsed values and would catch the same divergence. | `pwsh` probe: `@('x') \| ConvertTo-Json -Compress` and `'x' \| ConvertTo-Json -Compress` both yield `"x"` and compare equal; the `-InputObject` form yields `["x"]` and `"x"` and compares unequal. |
| Info | `docs/features/.../evidence/qa-gates/*.md` | filenames and `Timestamp:` fields | Five artifacts carry timestamps between `2026-08-22T00-30` and `2026-08-22T00-40` yet are contained in commit `59425465`, whose commit date is `2026-08-22T00:13:18Z`. The timestamps are ahead of the commit that introduced them. | Derive artifact timestamps from a clock read at write time. | Timestamps that cannot be reconciled with commit order reduce the audit value of the evidence set, though none of the recorded figures was found to be wrong. | `git log -1 --format=%cd --date=iso-local 59425465` gives `2026-08-21 20:13:18 -0400`, that is `00:13:18Z`; the artifacts named `00-30` through `00-40` are in that commit's tree. |
| Info | `tests/scripts/dev_tools/blast_radius_parity_test_support.py` | `PAYLOAD_MODULE_NAMES`, lines 96-100 | The Python constant hand-mirrors the TypeScript `PAYLOAD_MODULES` key set with no cross-language check binding them. | No change required. Record the coupling if a future feature makes the payload set non-trivial. | The failure direction is safe: if the TypeScript set grows and the bundled file follows, Class 3 fails until the Python constant is updated. If the TypeScript set grows and the bundle does not follow, nothing fails, but the bundled `modules` key is never read so nothing is affected. | The constant's own comment names the TypeScript source and the Jest case that pins it; the reviewer confirmed both exist. |

No further Blocker or Major findings. Five findings are Minor or Info.

---

## Implementation Audit

### Python implementation audit

#### What changed well

- The split into `blast_radius_parity_test_support.py` and `test_blast_radius_config_parity.py` is clean and the boundary is stated and honoured: the support module holds constants, the two parsed configurations, and four total accessors, and contains no assertion. The assertion module holds nothing else.
- Reuse over duplication. `load_config_file`, `load_module_globs`, `COMMITTED_CONFIGS`, `CONFIG_PATH`, `BUNDLED_CONFIG_PATH`, and `BUNDLED_CONFIG_LABEL` are imported from the existing module rather than copied, so the two-copy labelling stays consistent and a change to the paths propagates.
- The non-vacuity floor is real work rather than ceremony. Every accessor returns an empty collection for an absent or malformed key, which would silently convert a subset or equality assertion into one that holds trivially. `test_the_gate_compares_non_empty_collections` names six collections, asserts each is non-empty, pins `len(COMMITTED_CONFIGS) == 2`, and separately checks `mandate_reads` is a non-empty list because that key is compared by equality where two empty lists would agree. The reviewer confirmed the floor is discriminating rather than decorative.
- The fail-open regression asserts presence of a specific `(kind, detail)` pair over the reason collection rather than tuple equality, with a comment explaining that a corrected table also reports `path_overlap` for the same token so tuple equality would fail against the fixed state. That is the right assertion shape and the reason for it is written down.
- Every assertion message renders the offending value and names the offending copy by repo-relative label, so a future failure is actionable without reading the test.

#### Typing and API notes

- No new public Python API surface was added; both modules are test-scoped. Pyright runs in strict mode and reports zero diagnostics.
- The two `cast("list[object]", value)` calls in the accessors follow the pattern already established by `require_string_list` in the sibling module. They narrow a `json.loads` result after an `isinstance` check rather than asserting an unchecked shape, so the cast is a narrowing aid rather than a suppression.
- `TYPE_CHECKING`-guarded imports keep `Mapping`, `Path`, `BlastRadius`, and `ConflictResult` out of the runtime import graph.

#### Error handling and logging

- No new failure path is introduced, matching the spec. `module_names` documents in its `Raises:` section that `TypeError` propagates from `load_module_globs`, and the parse-and-version case relies on a successful `load_config_file` call as its parse assertion, which the docstring states explicitly.
- Both modules perform module-level file reads at import time. A malformed committed file therefore surfaces as a collection error rather than a test failure. This matches the existing `test_blast_radius_config.py` behaviour and is documented in both module docstrings, so it is a deliberate continuation rather than an oversight.

### TypeScript implementation audit

#### What changed well

- The production edit is minimal and the doc comment does the explanatory work. The `@remarks` block states why the `.claude` tree is not a module, what removing it does not weaken (`path_overlap` and `shared_surface_overlap` are untouched), and why `config` must stay: it keeps the assembled map non-empty so `assertNoForbiddenGlob` has a non-vacuous input. The reviewer verified that argument by reading `assembleModules`, which merges `PAYLOAD_MODULES` unconditionally after the derived paths.
- The added negative assertion in `blast-radius-derive-core.test.ts` is well reasoned. Its comment states that the pre-existing equality pin would still pass if a maintainer edited the constant and the pin together, whereas the negative property states what must hold for any future payload set. That distinction is correct and is the difference between a pin and an invariant.
- The added `claude-config-carriage.test.ts` case isolates the assertion by publishing into a destination whose lister reports nothing, so the assembled map is exactly the payload set. That is the right isolation for the property being asserted.
- `SOURCE_BLAST_RADIUS` in `config-carriage.test-helpers.ts` now mirrors the corrected bundled copy key for key and in the same key order, including `mandate_reads`, which it previously omitted entirely. The reviewer confirmed the mirror by comparing the constant against the committed file. This restores the helper's stated purpose of asserting against the shape a destination actually receives.

#### Type safety and maintainability

- `PAYLOAD_MODULES` keeps its `Readonly<Record<string, ReadonlyArray<string>>>` annotation. No `any` was introduced and no suppression was added anywhere in the diff.
- The single new type assertion narrows a `JSON.parse` result to `{ modules: Record<string, ReadonlyArray<string>> }`. This is the established pattern in the same file for reading a published document and is bounded to the property being asserted.
- `FORBIDDEN_GLOBS` was already exported; the test file adds it to an existing import list rather than duplicating the values, so the negative glob assertion tracks the production constant.

#### Error handling and logging

- No boundary behaviour changed. `assembleModules` is unmodified, `assertNoForbiddenGlob` is unmodified, and `CARRIED_KEYS` is unmodified. The published document's `shared_surfaces` and `mandate_reads` change only because the source data changed.
- The forbidden-glob guard remains reachable and non-vacuous. Two Jest cases pin the no-signal floor at `{ config: ["config/**"] }`, which establishes that the guard is always handed at least one glob.

### PowerShell implementation audit

#### What changed well

- The corrected comment at the umbrella-denylist case is the most valuable non-code change in the diff. The prior comment asserted a factual claim that was untrue, that the bundled module map "describes the DESTINATION repository's subsystems", and that claim was the sole justification for exempting the bundled copy from the prohibition. The replacement states the mechanism, names `assembleModules` and `PAYLOAD_MODULES` with their file path, and records that the exemption let the umbrella survive.
- Widening the denylist from one copy to both, and adding the payload-subset, separator-free, and Class 1 cases, gives the PowerShell surface an independent second line of defence. The reviewer confirmed independence by reverting the bundled JSON alone: the Pester file reported 13 passed and 4 failed, naming all four assertions.
- Offender accumulation over both copies before asserting, rather than stopping at the first, means a failure lists every disagreeing key or module rather than one.
- The new `Cross-copy key partition` `Context` gives the cross-file relation its own grouping rather than overloading the shape `Context`.

#### API and safety notes

- No production PowerShell file was changed, so no advanced-function, `ShouldProcess`, or parameter-validation surface is affected. The change budget in `.claude/rules/powershell.md` is respected with room to spare.
- Ordinal comparison via `-ccontains` and `-cne` matches the case-sensitive semantics of the Python reference, and the comments say so.
- The one weakness is the pipeline `ConvertTo-Json` form recorded as a Minor finding above.

#### Error handling and logging

- The additions perform no I/O beyond the `BeforeAll` reads and start no process, so no failure path is introduced. Assertions surface through Pester's own reporting.

---

## Test Quality Audit

The verification evidence for this change is stronger than typical. Fifty-one evidence artifacts cover a Phase 0 baseline for every stage in every language, a per-phase gate record, a final single-pass record, a coverage delta comparison, and a matched fail-before and pass-after pair for each of the two failure directions in each of two languages. The reviewer did not rely on those artifacts alone: every headline claim was re-executed.

### Reviewed test and QA artifacts

- `tests/scripts/dev_tools/test_blast_radius_config_parity.py` — 14 cases covering both regression directions and the whole key partition. Executed: exit 0, `14 passed in 0.06s`. Executed against a reverted bundled file: exit 1 with both regression cases failing and the exact assertion text recorded in the fail-before artifact.
- `tests/scripts/dev_tools/blast_radius_parity_test_support.py` — constants and accessors only. Exercised in full by the 14 cases that import it; every constant and all four accessors are reached.
- `tests/scripts/claude-lib/blast-radius/BlastRadius.TruthTable.Tests.ps1` — 17 cases, all passing. Executed against a reverted bundled file: 13 passed and 4 failed, confirming the mirror is discriminating and not merely present.
- `extensions/drm-copilot/test/lib/push-down/blast-radius-derive-core.test.ts` and `claude-config-carriage.test.ts` — the two new cases plus the updated pins. The whole Jest suite is 195 suites and 2656 tests, exit 0.
- `evidence/regression-testing/python-regression-fail-before.2026-08-21T23-08.md` — declares `ExpectedExitCode: 1` alongside `EXIT_CODE: 1` and quotes both assertion messages verbatim. Independently reproduced by the reviewer.
- `evidence/qa-gates/python-regression-pass-after.2026-08-22T00-14.md` — pairs by byte-identical node ID with the fail-before artifact and states explicitly that the `[P6-T13]` module split moved only constants and accessors, so the identifiers still pair. Verified: the node IDs are identical.
- `evidence/qa-gates/powershell-fail-open-pass-after.2026-08-22T00-10.md` — the strongest artifact in the set. It reports `conflict : False` for the research `5.3` pair and then explains that this is the correct post-fix outcome rather than a residual defect, because the tokens that pair cites are not members of the portable set, and it adds a second run with a configured token to demonstrate the restored branch. Reporting an unexpected-looking result and explaining it is better practice than quietly substituting a passing case.
- `evidence/other/post-fix-conflict-graph.2026-08-22T00-20.md` — refuses to attribute the 16-item to 56-item difference to the fix and instead runs a controlled comparison over an identical item set. Reproduced exactly by the reviewer once `spec_text` was supplied.
- `evidence/other/divergence-commit-walk.2026-08-21T21-47.md` — establishes with per-commit key shapes that the bundled copy was authored narrow at `944d58d3` rather than drifting later, which is the finding that justifies rejecting byte-equality for the surface keys.
- `evidence/qa-gates/coverage-delta-verification.2026-08-22T00-33.md` — separates statement from branch coverage and states explicitly why the combined `Cover` cell is not used for either. The reviewer confirmed all six figures against a fresh run.

### Quality assessment prompts

- **Determinism:** the derivation tests pass a fixed `COMPUTED_AT` rather than reading a clock; the blast-radius library performs no filesystem, subprocess, network, or wall-clock access; the reviewer obtained byte-identical coverage counters across two independent Python runs.
- **Isolation:** each new case asserts one relation. The layout-free Jest case deliberately isolates the assertion to `PAYLOAD_MODULES` by supplying a lister that reports nothing.
- **Speed:** 0.06s for the 14 new Python cases; the whole Python suite is 28.49s and Jest is 8.427s. Pester at 156.71s is dominated by pre-existing suites.
- **Diagnostics:** every new assertion message names the offending file by repo-relative label and renders the offending value or the observed reason tuple. Two real messages were captured by the reviewer during the fail-before reproduction and both identify the responsible level immediately.

### Gaps

- Class 2 has no test that would fail on self-hosted-side growth. This is the Major finding.
- The Pester mirror does not carry a Class 2 equivalent. `spec.md` AC11 does not require one, so this is a scope observation rather than a defect, but it means the surface keys have a single-language gate while the runtime-describing keys and the module keys have two.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | No credential, token, or key literal appears in the diff. The one Ruff `S105` hit encountered during execution was a hardcoded-password false positive on a constant name and was resolved by renaming to `ROOT_SURFACE_FILENAME` rather than by suppression. `poetry run ruff check .` exit 0. |
| No unsafe subprocess or command construction | PASS | The diff introduces no subprocess invocation in any language. Both new Python module docstrings state that no external process is started, and inspection confirms it. |
| Input validation at boundaries | PASS | `load_config_file` rejects a non-object root with `TypeError`; `load_module_globs` rejects an absent or malformed module map; the four new accessors check `isinstance(value, list)` before iterating and filter to `str` members. The added Jest case narrows its `JSON.parse` result rather than indexing an untyped value. |
| Error handling remains explicit | PASS | No broad `except`, no catch-all `catch`, no silent fallback was added. `module_names` documents the propagated `TypeError`. |
| Configuration and path handling is safe | PASS | All paths are repo-relative constants resolved from existing module-level values or, in Pester, from `Resolve-Path` against `$PSScriptRoot`. No user input reaches a path. No file is written by any test. |
| No production file excluded from coverage | PASS | `pyproject.toml`, `extensions/drm-copilot/jest.config.cjs`, and the Pester runsettings are unchanged on the branch. The Python `omit` list contains only test and vendor paths. |
| Destination-visible behaviour change is disclosed | PASS with a carried obligation | The commit message, `spec.md` `## Data / API / Config Impact`, and the amended rule all state the change is destination-visible. The pull-request body obligation cannot be verified because the pull request is not yet open. |

---

## Research Log

No external research was required. Every claim in this review was settled against the repository: the branch diff, the merge-base versions of the two truth tables recovered with `git show`, the policy rule files, the orchestration checkpoint, the 51 committed evidence artifacts, and direct execution of the toolchain and four mutation probes.

Two historical lookups were performed inside the repository and are worth recording because they bear on findings above. First, `git show a45a993b:config/blast-radius.json` shows the self-hosted separator-free shared-surface set has been exactly `poetry.lock`, `package-lock.json`, `quality-tiers.yml` since before the defect, which is precisely the set now shipped in the bundle and is what makes the recommended directional invariant concrete rather than speculative. Second, `git ls-files | grep -i quality-tiers` confirms that `quality-tiers.yml` does not exist at the repository root, which `spec.md` `## Out of Scope` item 3 discloses and argues around; the reviewer accepts that reasoning, since under the surfaces-versus-modules asymmetry an entry the workspace lacks costs nothing.

---

## Verdict

This is a correct and well-argued fix. The root-cause analysis reaches past the reported symptom to the actual publisher, the surfaces-versus-modules asymmetry is stated as a mechanism rather than asserted as a conclusion, the measurement reporting is honest to the point of declining to claim credit for an improvement it could not isolate, and the reviewer reproduced the headline number to the exact edge count. Answering the specific questions posed: `PAYLOAD_MODULES` is confirmed as the sole publisher of a `.claude` umbrella and the forbidden-glob guard retains a non-vacuous input; retaining the bundled `modules` key is the right call given that `load_module_globs` raises on its absence and the rule now records in prose that the key is never read; DD-1 is justified by its stated criterion and was in fact mechanically required once `SOURCE_BLAST_RADIUS` was corrected to mirror the bundle; and PD-1 is sound engineering forced by a hard policy ceiling.

Two things should change. The acceptance record must be corrected so that AC9 and AC10 name the file that carries the gate and a command that exercises it; this is the only condition on merge readiness and it is documentation-only. Separately, and not as a merge condition, the Class 2 relation should be understood for what it is. It pins the bundled surface set against unilateral edits, and it does not observe the self-hosted set growing away from it. The specific catastrophic recurrence, a published table with no separator-free surface, is independently blocked by the non-empty assertion in `test_every_separator_free_bundled_shared_surface_is_wildcard_free`, which is why this is Major rather than Blocking. A directional invariant over separator-free self-hosted surfaces would close the remaining gap at low cost, and the `## Risks & Mitigations` sentence claiming Class 2 already closes it should be corrected either way.

The change is ready for normal pull-request flow once the AC9 and AC10 text is amended.
