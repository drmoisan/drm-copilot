# Final QA — Scope Boundary — P7-T10

Timestamp: 2026-08-26T02-05

Note on filename stamp: the plan fixes every evidence filename at `.2026-08-24T13-10.md`. This
execution ran on 2026-08-26, so the executor substituted its own `yyyy-MM-ddTHH-mm` stamp
(`2026-08-26T02-05`) in that same position. The path prefix and base name are unchanged.

Command:

```
git status --porcelain
git diff --name-only main...HEAD
```

EXIT_CODE: 0 (both commands)

## Why both commands are required

A tracked-file diff cannot see a newly added, untracked file. `git diff --name-only main...HEAD`
reports only what is committed on the branch; the evidence artifacts and the runbook this execution
authored are untracked at the time of measurement and appear only in the porcelain status. The union
of the two result sets is the complete set of paths this change touches.

## Result-set sizes

| Set | Command | Entries |
|---|---|---|
| Tracked branch diff | `git diff --name-only main...HEAD` | 37 |
| Working-tree status | `git status --porcelain` | 14 |
| **Union (deduplicated)** | — | **49** |

Two paths appear in both sets (`plan.2026-08-24T08-39.md` and `spec.md`, modified this execution and
already committed earlier in the plan), which accounts for the difference between 37 + 14 = 51 and
the deduplicated union of 49.

The union is non-empty.

## Union — all 49 paths

### Production and test code (8)

```
scripts/dev-tools/Invoke-ReleaseVerification.ps1
scripts/dev-tools/Invoke-ReleaseTagPush.ps1
scripts/dev-tools/Invoke-ReleaseReconciliation.ps1
tests/scripts/dev-tools/Invoke-ReleaseVerification.Tests.ps1
tests/scripts/dev-tools/Invoke-ReleaseTagPush.Tests.ps1
tests/scripts/dev-tools/Invoke-ReleaseReconciliation.Tests.ps1
tests/scripts/workflows/PublishMcpNpmWorkflow.Tests.ps1
tests/scripts/workflows/VerifyPublishedReleasesWorkflow.Tests.ps1
```

### Workflow YAML (2)

```
.github/workflows/publish-mcp-npm.yml
.github/workflows/verify-published-releases.yml
```

### Coverage settings — both in-repo copies (2)

```
scripts/powershell/PoshQC/settings/pester.runsettings.psd1
extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1
```

### Operator documentation (1)

```
docs/engineering/missed-npm-publish.runbook.md
```

### Feature documents (5)

```
docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/issue.md
docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/spec.md
docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/plan.2026-08-24T08-39.md
docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/research/research.2026-08-24T12-45.md
docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/runbooks/burned-version-disposition.runbook.md
```

### Evidence artifacts (31)

Six under `evidence/baseline/`, six under `evidence/other/`, four under
`evidence/regression-testing/` plus the fail-before dossier (five in total), and fifteen under
`evidence/qa-gates/`. All resolve under
`docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/`, the canonical
location this plan fixes. No `artifacts/`-rooted evidence path appears anywhere in the union.

Component totals: 8 + 2 + 2 + 1 + 5 + 31 = **49**, matching the measured union size.

## Out-of-scope assertions

| Path | Owner | Present in union | Verdict |
|---|---|---|---|
| `README.md` | issue #528 | **no** — 0 matches for `README` anywhere in the 49-path union | **PASS — untouched** |
| `quality-tiers.yml` | pre-existing environment defect, unfiled | **no** — 0 matches for `quality-tiers` anywhere in the 49-path union | **PASS — not created** |

Both assertions were evaluated as substring searches across the whole union, not as exact-path
comparisons, so a variant path such as `docs/README.md` or a nested `quality-tiers.yml` would also
have been caught. Neither returned any match.

`README.md:401-402` misstates the npm publish credential as `NPM_TOKEN` and omits `--provenance`.
Spec section 2.2 assigns that correction to issue #528 and states it must not be fixed here. It was
not.

`quality-tiers.yml` is absent from the repository root although `.claude/rules/quality-tiers.md`
declares it authoritative. Spec section 2.2 records this as a known pre-existing environment defect
with no fix proposed and no criterion depending on it. No such file was created.

## Measurement time

The two commands ran during P7-T10, before the three artifacts written by P7-T10, P7-T11, and P7-T12
existed on disk. The union recorded above is therefore the state at that moment. Re-running the same
two commands after those three artifacts were written yields a union of 52 paths rather than 49; the
three additional paths are `evidence/qa-gates/scope-boundary.2026-08-26T02-05.md` (this file),
`evidence/qa-gates/ac-traceability.2026-08-26T02-05.md`, and
`evidence/qa-gates/green-branch-head-run.2026-08-26T02-05.md`, all of which resolve under the
canonical feature `evidence/` tree.

Neither assertion is affected. All five required paths remain present, and the searches for `README`
and `quality-tiers` return zero matches against the larger union as well, since all three added paths
are evidence artifacts under the feature folder.

## Note on excluded paths

`.claude/state/powershell-batch-budget.default.json` is gitignored transient hook bookkeeping and
appears in neither result set, so it is correctly absent from the union.
`artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` are the Pester
runner's own configured output paths, also gitignored, and are likewise absent. Both are tool
outputs, not part of the change.

Output Summary: The union of `git status --porcelain` and `git diff --name-only main...HEAD` contains
49 distinct paths and is non-empty. All five required paths are present:
`scripts/dev-tools/Invoke-ReleaseVerification.ps1`, `scripts/dev-tools/Invoke-ReleaseTagPush.ps1`,
`.github/workflows/publish-mcp-npm.yml`, `.github/workflows/verify-published-releases.yml`, and
`docs/engineering/missed-npm-publish.runbook.md`. Neither `README.md` nor `quality-tiers.yml` appears
anywhere in the union — both searches returned zero matches. The scope boundary holds and AC28 is
satisfied.
