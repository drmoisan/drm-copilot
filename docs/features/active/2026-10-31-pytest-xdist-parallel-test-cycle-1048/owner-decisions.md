# Owner decisions for research open questions (#1048)

Decided by the coordinator under the owner's standing instruction of 2026-10-31 ("I will follow your recommendations. Operate autonomously").

1. No new `psutil` dependency. Measure `-n auto` against a fixed `-n 4` on the CI runner and keep the faster; record both timings.
2. Local Pester worker default: half of the logical core count, capped at 8, overridable by parameter.
3. Merged JUnit is one `artifacts/pester/pester-junit.xml` with summed counts; the root `time` is the longest shard wall-clock, documented in the PoshQC README.
4. The Linux hook-suite job stays as is. Its non-required status is recorded as an observation, not changed here.
5. No fourth shard at first: change weights only. Add a fourth shard only if the measured balance requires it, and then update the matrix, the brief and `PoshQcWorkflow.Tests.ps1` together.
6. The slow-file profile (the eleven files over 10 s) is in this item as diagnosis. Product or test fixes beyond trivial ones are recorded as follow-ups.
7. The 436 versus 482 file difference is explained in the plan from the Pester discovery count; it is not a blocker.
