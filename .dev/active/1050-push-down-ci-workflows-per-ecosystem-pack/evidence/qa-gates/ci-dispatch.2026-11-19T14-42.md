# CI Dispatch Evidence — Issue #1050 ([P3-T5], AC S17)

Timestamp: 2026-11-19T14-42
Command: gh workflow run ci.yml --repo drmoisan/drm-copilot --ref scratch/ci-1050-<pack> (once per pack; facts read with gh run view <run> --json databaseId,headBranch,headSha,event,conclusion,createdAt,jobs)
EXIT_CODE: 0
Output Summary: five reference-mode callers, one per language pack, each dispatched once in a scratch destination; all five completed with conclusion success, and each check list shows the pack's check and `CI Required Gate`.

## Method

- Scratch destination: one orphan branch `scratch/ci-1050-<pack>` of the source repository per pack, holding a minimal fixture for that ecosystem (a small library and its tests) and the caller rendered from `extensions/drm-copilot/resources/ci-workflows/caller/drm-copilot-ci.template.yml` and the pack's job fragment by the rules of `renderCiCaller` in reference mode. The caller sits at `.github/workflows/ci.yml` because `workflow_dispatch` runs a workflow whose path exists on the default branch; its content is identical to the rendered `drm-copilot-ci.yml` (orchestrator decision AD-13). No repository setting was changed and no new repository was created.
- Pin: per the plan, the `uses:` ref and the PowerShell job's `harness_ref` input point at a pushed head of this branch instead of `v<payload_version>`, because the release tag does not yet carry the harness workflows.
- Python: the first dispatch (run 44541154665, harness ref `9d75fe2be5ee21f4a04af4dc9bb6b0fa4b76b8eb`) failed in `Check coverage thresholds` (`ConvertFrom-Json` rejected an empty-string key in the coverage.py JSON report). Remediation cycle 1 fixed the step (commit `6db29402288ad71d99f815cf79280e0194d218fc`), and the Python caller was re-rendered at that commit and dispatched again (run 44545593464).
- The other four packs ran against harness ref `9d75fe2be5ee21f4a04af4dc9bb6b0fa4b76b8eb`. Between that commit and `6db29402288ad71d99f815cf79280e0194d218fc` the only change under `.github/workflows` and `scripts/powershell/PoshQC` is `.github/workflows/harness-python.yml` (git diff --stat), so their harness workflows are unchanged at the fixed head.

## Runs

| Pack | Run id | Scratch head | Event | Conclusion | Checks |
| --- | --- | --- | --- | --- | --- |
| python | 44545593464 | 2f011ea8ee55cfc6a42e1966106b2d11db5daa9f | workflow_dispatch | success | `Python / Python QC` success; `CI Required Gate` success |
| powershell | 44541165447 | f0b91d6ea4b572e2415b28aa202987b73dc7bf6b | workflow_dispatch | success | `PowerShell / PowerShell QC` success; `CI Required Gate` success |
| typescript | 44541160197 | 5c019da33b95f92813da08804f2f98adf80804ee | workflow_dispatch | success | `TypeScript / TypeScript QC` success; `CI Required Gate` success |
| csharp-modern | 44541170750 | 115f0a295ea58a82c0afd7da01d3da952029875c | workflow_dispatch | success | `.NET / .NET QC (modern)` success; `.NET / .NET QC (legacy)` skipped; `CI Required Gate` success |
| csharp-legacy | 44541175317 | e276469018f0833e16401daa7fc5cf8af8739720 | workflow_dispatch | success | `.NET / .NET QC (legacy)` success; `.NET / .NET QC (modern)` skipped; `CI Required Gate` success |

Superseded run (kept for the record): python 44541154665, conclusion failure, remediated in cycle 1.
