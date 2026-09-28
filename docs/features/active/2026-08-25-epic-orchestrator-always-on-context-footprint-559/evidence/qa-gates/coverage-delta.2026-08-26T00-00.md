# Coverage Delta — Baseline against Post-Change (Issue #559)

Timestamp: 2026-08-26T00-52
Task: [P6-T6]

## Evidence Schema Classification (Remediation R3, Issue #559)

This artifact is a derived comparison record: it compares two prior command-step artifacts
(`evidence/baseline/baseline-pytest-coverage.2026-08-26T00-00.md` and
`evidence/qa-gates/final-pytest-coverage.2026-08-26T00-00.md`) and runs no command of its own.
It therefore carries no `Command:` or `EXIT_CODE:` field; the underlying command those two
artifacts record is `poetry run pytest --cov=scripts.dev_tools --cov-report=term-missing`.

## Sources compared

| Side | Task | Artifact |
|---|---|---|
| Baseline | `[P0-T6]` | `evidence/baseline/baseline-pytest-coverage.2026-08-26T00-00.md` |
| Post-change | `[P6-T4]` | `evidence/qa-gates/final-pytest-coverage.2026-08-26T00-00.md` |

Both figures come from the byte-identical command
`poetry run pytest --cov=scripts.dev_tools --cov-report=term-missing`, so they compare like against
like. Neither run passed `--cov-branch`, so both are line-coverage figures and no branch-coverage
comparison is claimed.

## The two numeric percentages and the signed delta

| Metric | Baseline (`[P0-T6]`) | Post-change (`[P6-T4]`) | Signed delta |
|---|---|---|---|
| Total line coverage (as pytest reports it) | **93%** | **93%** | **0** |
| Total line coverage (exact, covered / statements) | **92.65%** | **92.65%** | **+0.00 pp** |
| Statements (denominator) | 15014 | 15014 | 0 |
| Missed statements | 1104 | 1104 | 0 |
| Covered statements (numerator) | 13910 | 13910 | 0 |
| Measured modules | 181 | 181 | 0 |

Reported TOTAL row, identical on both sides:

```
TOTAL                                                               15014   1104    93%
```

**The signed delta is +0.00 percentage points — exactly zero.** Because the delta is zero, the
`[P6-T6]` acceptance branch requiring each responsible file to be named does not apply: there is no
file responsible for a change, because there is no change. The numerator, the denominator, and the
measured-module count are each identical to the statement.

| Policy check | Value |
|---|---|
| Uniform line-coverage floor (all tiers T1-T4) | 85% |
| Post-change line coverage | 92.65% |
| Margin above floor | +7.65 pp |
| No-regression-on-changed-lines requirement | Satisfied vacuously — no measured line changed |

## Changed-code coverage statement

The zero delta is not a coincidence to be explained after the fact; it is the structurally
guaranteed result, for the reason `[P6-T6]` states.

**The coverage source is exactly two roots.** `pyproject.toml` lines 118-119:

```toml
[tool.coverage.run]
source = ["src", "scripts/dev_tools"]
```

with `omit` covering `tests/*` and `*/tests/*` (lines 121-126).

**No file under either root is written by this change.** Verified by enumerating every file the
branch changes against its merge base with `origin/main` (`b36179b2`). The branch changes 44
committed files. Grouped by root:

| Root | Files changed by this branch | In coverage source? |
|---|---|---|
| `src/` | **0** | Yes — but nothing changed |
| `scripts/dev_tools/` | **0** | Yes — but nothing changed |
| `.claude/` | 8 | No |
| `CLAUDE.md` | 1 | No |
| `extensions/drm-copilot/resources/claude-customizations/.claude/` | 8 | No |
| `tests/scripts/dev_tools/` | 3 | No — omitted by `omit = ["tests/*", "*/tests/*"]` |
| `docs/features/` | 24 | No |

The only three Python files this change touches are all under `tests/`:

1. `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` (modified — the digest
   re-baseline of Decision 1)
2. `tests/scripts/dev_tools/test_claude_rules_frontmatter.py` (added)
3. `tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py` (added)

None is in the coverage source and all three fall under the `omit` patterns, so none enters either
the numerator or the denominator.

**Therefore the denominator is unchanged and the metric cannot regress.** Every other file this
change writes is Markdown — runtime policy, skill, and agent prose, plus feature documents and
evidence artifacts — which coverage does not measure at all.

The 15 new tests added by this change do execute, and they raise the passed count from 4136 to 4150
(see `[P6-T4]`), but they exercise Markdown and YAML content under `.claude/` rather than any module
in the coverage source, so they add no covered statement to `scripts.dev_tools`. That is why the
test count moves while the coverage figure does not.

## Interaction with the tolerated `[P6-T4]` failure

The post-change run exited 1 because of the single tolerated, out-of-scope environmental failure
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` (see `[P6-T4]` and the operative
`PRESENT` verdict of `[P0-T11]`). That failure does not perturb this comparison: coverage is
collected across the whole session regardless of individual test outcomes, and the failing test
asserts filesystem parity rather than exercising a `scripts.dev_tools` module whose coverage would
otherwise be lost. The identical statement counts on both sides confirm no collection was dropped.

Output Summary: PASS. Baseline line coverage for `scripts.dev_tools` is 92.65% exact (93% as
reported); post-change is 92.65% exact (93% as reported); the signed delta is **+0.00 percentage
points**. No file responsible for a delta is named because the delta is zero. The result is
structural: `pyproject.toml` sets `source = ["src", "scripts/dev_tools"]`, and this change writes
zero files under either root — its only three Python files are under `tests/`, which `omit`
excludes — so the denominator (15014 statements) and numerator (13910 covered) are unchanged and the
metric cannot regress. Post-change coverage sits 7.65 pp above the uniform 85% line floor.
