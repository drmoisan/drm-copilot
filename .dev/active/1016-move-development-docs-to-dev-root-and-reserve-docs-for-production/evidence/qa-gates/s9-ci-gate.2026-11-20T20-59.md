# S9 CI Gate — issue 1016

Timestamp: 2026-11-20T20-59
Command: gh run view 44813228698 --repo drmoisan/drm-copilot --json status,conclusion,jobs
EXIT_CODE: 0
Output Summary: CI run 44813228698 (event pull_request, workflow CI) on PR #1213 head f24937f64e2796829b7d2d6a5fe599cbfa51c219 completed with conclusion success; Change scope success; CI full run success (full run, stage 7 integration lanes included). Earlier workflow_dispatch run 44810698464 on code head 7322bc6251aca5e9d2beb11e528f847da44b6764 also completed success. First dispatch run 44791702384 on f744ce9e0 failed (poshqc shard 1, Get-StageTimingReport clean-checkout test) and was remediated in cycle 1 as F3.

CI-dependent acceptance criteria checked off at S9 on the basis of run 44813228698:
- spec.md: The seven-stage toolchain passes in a single pass for the changed TypeScript, and no changed production file exceeds 800 lines.
- spec.md: The seven-stage toolchain passes in a single pass for TypeScript, Python and PowerShell with the key at .dev, recorded under <FEATURE>/evidence/qa-gates/, and no changed production file exceeds 800 lines.
- spec.md: With development_docs_root set to .dev, the full toolchain passes.
- user-story.md (d): The full seven-stage toolchain passes for TypeScript, Python and PowerShell with the key at .dev, recorded under <FEATURE>/evidence/qa-gates/.

The check-off commit moves the PR head; the CI gate is re-verified on the final head before merge.
