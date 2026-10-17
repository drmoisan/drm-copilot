---
description: Run feature review and, if needed, remediation planning with executor preflight
---

$feature-review
Use pr_context as authoritative if present and valid. Only fall back to an explicit base branch if pr_context is missing, stale, or ambiguous.
If remediation is required, write exactly one mode line into the remediation inputs: `Remediation-Mode: proportionate` when every autonomous finding can be fixed without changing a spec acceptance criterion, a public interface, or the file inventory beyond the branch diff plus tests and mirrors, otherwise `Remediation-Mode: design`. CI-failure findings are normally proportionate.
Then explicitly spawn atomic-planner to create or revise the remediation plan.
Before atomic-planner finalizes the plan, it must explicitly spawn atomic-executor in preflight-validation-only mode against that same file, with the preflight directive in the delegation prompt and never in the plan file. Preflight is single-pass: trivial defects are fixed in place.
If atomic-executor returns PREFLIGHT: REVISIONS REQUIRED, atomic-planner must revise the same file once with the full PREFLIGHT-DEFECT list, and one confirming preflight runs; a second substantive result halts the cycle with `blocked_preflight_iteration_limit`.
For `Remediation-Mode: proportionate`, preflight and execution may run as one atomic-executor delegation that stops with `BLOCKED at preflight (before [P0-T1])` on a substantive defect, which converts the cycle to `Remediation-Mode: design`.
Only after PREFLIGHT: ALL CLEAR finalize the remediation plan and report all generated artifacts.