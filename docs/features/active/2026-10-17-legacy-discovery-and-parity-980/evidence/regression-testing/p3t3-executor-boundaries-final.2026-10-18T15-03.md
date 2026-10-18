# P3-T3 final boundary rebinding

Timestamp: 2026-10-18 15:03:31 UTC
Command: `poetry run python SCRATCH/issue-980-p3t3-initial-probes.py 'final source verification'`
EXIT_CODE: 0
Output Summary: All eight retained behavioral cases pass in 4.26 seconds. Before/after hashes match for all three production modules, including corrected activation_store.py SHA-256 `dff3a775e99185523bfcae2de63d5eae70a1f397d221899944f28f87789c2bfa`.

The same cases cover root lifecycle, explicit activation, active configuration deletion, denied authority, concurrent reactivation, candidate appearance before guarded publication, parent identity freshness, and protected activation after partial failure. No behavioral case was added, removed or weakened. This final binding follows the specialist's separate postpublication-candidate regression correction; that additional regression is verified through the task's final specialist evidence.

The 14:55 proof remains historical because activation_store.py subsequently changed. This receipt binds the original cases to the corrected frozen source. Final task acceptance still requires the complete ordered gate, coverage, native-provider results and staged-byte audit. P3-T3 remains unchecked.
