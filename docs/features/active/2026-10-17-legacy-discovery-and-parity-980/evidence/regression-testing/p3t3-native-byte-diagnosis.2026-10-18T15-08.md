# p3t3-native-byte-diagnosis

Timestamp: 2026-10-18T15-08
Command: poetry run python SCRATCH/issue-980-p3t3-byte-diagnosis.py
EXIT_CODE: 1
Output Summary:   "physical_matches_proposal": false,;   "physical_is_crlf_translation": true,;   "effects": "Read-only comparison of an existing session-owned smoke workspace; no files or directories created by this diagnostic."; }

Working directory: .
Started: 2026-10-18T15:08:51.747454+00:00
Duration seconds: 1.476
Phase: P3-T3 configuration and activation; focused task verification.

## Captured output

```text
{
  "written_at_utc": "2026-10-18T15:08:53.169458+00:00",
  "source_sha256": "db2aca8bf68f64333b509ca12cbe8445d1a0dadc0532064d93581acb1afb422c",
  "expected_length": 2121,
  "physical_length": 2122,
  "provider_length": 2121,
  "expected_sha256": "b1d8b0863a515db46dfa381c29c6855e41ee135c783ccf2df1d6b0599d25c23f",
  "physical_sha256": "73220a9a3ba26dac125641ab21a912c2fdad3a21a4583f4017fdc087beee178f",
  "provider_sha256": "b1d8b0863a515db46dfa381c29c6855e41ee135c783ccf2df1d6b0599d25c23f",
  "provider_matches_proposal": true,
  "physical_matches_proposal": false,
  "physical_is_crlf_translation": true,
  "effects": "Read-only comparison of an existing session-owned smoke workspace; no files or directories created by this diagnostic."
}
```
