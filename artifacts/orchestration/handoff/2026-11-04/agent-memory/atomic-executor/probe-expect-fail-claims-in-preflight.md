---
name: probe-expect-fail-claims-in-preflight
description: An [expect-fail] task can claim every new case fails before the fix when some already pass; probe the unmodified code during preflight
metadata:
  type: feedback
---

During preflight, run each new case of an `[expect-fail]` task against the unmodified code with a small SCRATCH probe script before accepting the claim that "all N cases fail before the fix".

**Why:** In the #1021 remediation (2026-11-04), the plan stated that both escaped-backslash flow cases fail before the fix. `["a\\\"", b]` already passed, because the old one-character look-back closed the item at the following quote by accident. Both cases were in one `It`, so the test still failed. The preflight fixed the wording in place as a trivial defect, and the fail-before artifact recorded a per-case table. Without the probe, the evidence would have recorded a false claim.

**How to apply:** If the cases share one `It` and the test still fails, correct the per-case wording in place and classify it as trivial. If the only failing assertion is the one that already passes, the expect-fail condition cannot be met, which is a substantive defect. Related: [[pssa-and-array-semantics-gotchas]] (PSSA 1.25 NullReferenceException; analyze per file with a retry).
