# PoshQC bundled mirror hashes (#1048, P6-T1)

Timestamp: 2026-10-31T19-19
Command: cp scripts/powershell/PoshQC/<file> extensions/drm-copilot/resources/powershell/PoshQC/<file> for each file below; sha256sum of each pair
EXIT_CODE: 0
Output Summary:
All five pairs have equal SHA-256 hashes.

| File | scripts/powershell/PoshQC | extensions/drm-copilot/resources/powershell/PoshQC | Result |
| --- | --- | --- | --- |
| PoshQC.Parallel.psm1 | 9d6ae3406148ab075a0aad0b95bb637f4340644d5e368180e20cbead13a6480c | 9d6ae3406148ab075a0aad0b95bb637f4340644d5e368180e20cbead13a6480c | EQUAL |
| PoshQC.Shard.psm1 | 719620617efc1d0be02a829c58b3f5966259a09b0402051c7042c4708ed4fbed | 719620617efc1d0be02a829c58b3f5966259a09b0402051c7042c4708ed4fbed | EQUAL |
| PoshQC.Testing.psm1 | 75aaa4351cc659b453391eca0836c472cd35d3b7ed0f7dc2e5c1368a0221e6c3 | 75aaa4351cc659b453391eca0836c472cd35d3b7ed0f7dc2e5c1368a0221e6c3 | EQUAL |
| PoshQC.psm1 | c4103bf5dcb11c0d6cd0b02d94a19bf9adc9fe778344869cad664d837c85b35c | c4103bf5dcb11c0d6cd0b02d94a19bf9adc9fe778344869cad664d837c85b35c | EQUAL |
| PoshQC.psd1 | e3a126f56960d2eec3e9ca429c5c8a95c3758d036501ba06b046893d7309bca6 | e3a126f56960d2eec3e9ca429c5c8a95c3758d036501ba06b046893d7309bca6 | EQUAL |

Update (P7-T3, deviation D5): after the `WaitShardProcess` fix, `PoshQC.Parallel.psm1` was copied again; both copies now hash to d7d67d31659bc820dbd34d725535afa9712420eb0a814018bccaca7e78f3afa6 (EQUAL).
