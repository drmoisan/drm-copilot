# Coverage Delta — Baseline Run 34186767775 Against Final Run 34205298954

Timestamp: 2026-09-08T08-44

Task: [P8-T6]

Command:
`python -c "import xml.etree.ElementTree as ET; ..."` reading the report-level and per-`sourcefile`
`counter type="LINE"` elements of both downloaded `powershell-coverage.koverage.xml` files

EXIT_CODE: 0

## The two input files

Both sides are the per-file `sourcefile` `counter type="LINE"` entries of
`powershell-coverage.koverage.xml` inside a downloaded `poshqc-test-results` artifact, so both come
from the same CI route and are directly comparable. The two absolute paths read are:

| Side | Absolute path | Run id |
| --- | --- | --- |
| Baseline | `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a5a6952a0a1e65c6e/artifacts/poshqc-ci/baseline-34186767775/powershell-coverage.koverage.xml` | `34186767775` |
| Post-change | `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a5a6952a0a1e65c6e/artifacts/poshqc-ci/final/powershell-coverage.koverage.xml` | `34205298954` |

**The two paths differ.** They sit in sibling directories — `baseline-34186767775/` and `final/` —
under `artifacts/poshqc-ci/`. The separation is load-bearing rather than cosmetic: the three member
filenames are byte-identical across runs, so a shared download directory would have overwritten the
[P0-T7] baseline with the [P8-T5] download and destroyed the comparison this task performs.

The two files are also distinct in content, verified by hash rather than asserted from the paths:

```
19149a3e700ae986a0a00d4e1f6a2451f1fe539d32209e8fd01655402a4883fd  baseline-34186767775/powershell-coverage.koverage.xml
797b1bcdd626862f0feee39a3d80b2f1ce098b145383bc3d8017b19046bc7721  final/powershell-coverage.koverage.xml
```

Command: `sha256sum <both paths>`, exit status 0.

The baseline side was re-derived directly from its XML in this task rather than copied from
[P0-T7]'s `Output Summary:`. The re-derived values reproduce that artifact's figures exactly, so the
baseline transcription is independently confirmed rather than trusted.

## Group 1 — overall line coverage

| Run id | Head SHA | LINE covered | LINE missed | Denominator files | Overall line coverage |
| --- | --- | --- | --- | --- | --- |
| `34186767775` (baseline) | `d250cf72ee24139735e7f08b07d002ae0e4f1d00` | 8452 | 400 | 96 | **95.4812%** |
| `34205298954` (post-change) | `05bbc4e1c1a2aa014dea5aaa4c5b7fce68b2d24f` | 8563 | 408 | 97 | **95.4520%** |

Delta: **-0.0292 percentage points**.

The denominator grew by one file and by 119 lines (8852 to 8971). The single added file is
`.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1`, confirmed absent from the baseline XML
and present in the post-change XML by the same `package`+`sourcefile` join rule used throughout.
Its own line coverage of 92.5926% sits below the repository's 95.4812% baseline average, so adding
it lowers the weighted overall figure arithmetically. Covered lines rose by 111 and missed lines
rose by 8; all 8 additional missed lines are inside the new file, which carries exactly 8 missed
lines.

This overall movement is a composition effect of adding a new file to the denominator, not a loss of
coverage on any pre-existing file. The post-change overall figure of 95.4520% remains well above the
repository's 85% line-coverage threshold.

## Group 2 — per-file line coverage for the two gate hooks

| Repo-relative path | Baseline (run `34186767775`) | Post-change (run `34205298954`) | Delta | Regressed |
| --- | --- | --- | --- | --- |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 94 / 99 = **94.9495%** | 100 / 105 = **95.2381%** | **+0.2886 pp** | **no** |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | 69 / 74 = **93.2432%** | 74 / 79 = **93.6709%** | **+0.4276 pp** | **no** |

**Coverage did not regress on either gate hook.** Both improved. This is the explicit statement this
task's acceptance requires, and because neither value fell, the blocking-finding branch of this task
was not taken and the phase continues.

Both hooks gained measured lines — the epic gate from 99 to 105 and the parallel gate from 74 to 79
— while each held its missed-line count at exactly 5. The added lines in each hook are the
manifest-gate wiring this feature introduced, and every one of them is covered.

Both post-change values remain at or above 85.

## Group 3 — new-file coverage

| Repo-relative path | Baseline | Post-change | At least 85 |
| --- | --- | --- | --- |
| `.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1` | absent from the coverage XML — the file did not exist at `d250cf72` | 100 / 108 = **92.5926%** | **yes** |

No delta is computable for this file because it has no baseline value: it is new in this feature.
Its baseline state is recorded as absence rather than as zero, because a zero would misdescribe an
unmeasured file as a fully-missed one. Its presence in the post-change XML is what demonstrates that
the `CodeCoverage.Path` entry [P6-T3] added is honoured on the CI route, which is the property AC-25
secures.

## Summary of regression assessment

| Gate | Regressed relative to the [P0-T7] baseline |
| --- | --- |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | **no** — improved by 0.2886 pp |
| `.claude/hooks/enforce-parallel-worktree-removal-gate.ps1` | **no** — improved by 0.4276 pp |
| Overall repository line coverage | moved -0.0292 pp, attributable to the new file entering the denominator; no pre-existing file lost coverage |

Output Summary: Coverage delta computed between run **34186767775** (baseline, head `d250cf72`) and
run **34205298954** (post-change, head `05bbc4e1`), read from two distinct absolute paths with
distinct SHA-256 hashes. Overall line coverage moved **95.4812% to 95.4520%** (-0.0292 pp) as the
denominator grew from **96 to 97** files; the movement is a composition effect of adding the new
module at 92.5926%, and no pre-existing file lost coverage. Per-gate-hook:
`enforce-epic-worktree-removal-gate.ps1` **94.9495% to 95.2381%** (+0.2886 pp) and
`enforce-parallel-worktree-removal-gate.ps1` **93.2432% to 93.6709%** (+0.4276 pp). **Neither gate
hook regressed**, so no blocking finding is raised. New-file coverage for
`CleanupWorktreeManifest.psm1` is **92.5926%** (100 / 108), with no baseline value because the file
did not exist at `d250cf72`. All measured values are at or above 85.
