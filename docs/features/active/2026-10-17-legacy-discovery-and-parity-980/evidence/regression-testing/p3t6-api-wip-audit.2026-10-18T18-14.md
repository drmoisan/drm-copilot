# p3t6-api-wip-audit

Timestamp: 2026-10-18T18-14
Command: poetry run python SCRATCH/issue-980-p3t6-api-wip.py
EXIT_CODE: 0
Output Summary:       "changed_from_head": true;     };   ]; }

Working directory: .
Started: 2026-10-18T18:14:20.100374+00:00
Duration seconds: 2.620
Phase: P3-T6 immutable source snapshot transport; focused task verification.

## Captured output

```text
{
  "inventory": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t6-api-wip.2026-10-18T18-14.json",
  "summary": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t6-api-wip.2026-10-18T18-14.md",
  "patch": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p3t6-api-scoped-patch.2026-10-18T18-14.md",
  "coverage": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-api-preparation-coverage.2026-10-18T18-14.json",
  "proof": "docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/regression-testing/p3t6-api-composed-readiness.2026-10-18T18-14.json",
  "changed_paths": [
    "packages/discovery-runtime/src/drm_copilot_discovery/source_snapshots.py",
    "tests/discovery_runtime/test_snapshot_export.py",
    "tests/discovery_runtime/test_snapshot_import.py",
    "tests/discovery_runtime/source_snapshot_test_support.py"
  ],
  "prior_unchanged": 251,
  "frozen_unchanged": 24,
  "paths": [
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/path_policy.py",
      "sha256": "adcbf4a65bc444aa9794ff447c660ef9950f2a513a6c8d8c24ef76d3171156b2",
      "size": 19543,
      "physical_lines": 483,
      "working_git_blob": "3fe1584d43f14dbda600c5c3d7efbfbd9080bc0f",
      "head_git_blob": "3fe1584d43f14dbda600c5c3d7efbfbd9080bc0f",
      "changed_from_head": false
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/mutation_plan.py",
      "sha256": "1d0b1970f8ca3d4e139060f322e3d82c9989b515cb62b2f881f1b7abc968dace",
      "size": 18384,
      "physical_lines": 426,
      "working_git_blob": "5baa5aeaa9ed58a8cb5bf1f6cfee624e3b1267a7",
      "head_git_blob": "5baa5aeaa9ed58a8cb5bf1f6cfee624e3b1267a7",
      "changed_from_head": false
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/mutation_io.py",
      "sha256": "d88262205076138fb8a6f7f5bd115d9d2c79a492be82ce1c6920bec0866a82eb",
      "size": 17292,
      "physical_lines": 437,
      "working_git_blob": "d7221711d92cb187ed69b02fc930744c4aaa1549",
      "head_git_blob": "d7221711d92cb187ed69b02fc930744c4aaa1549",
      "changed_from_head": false
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/references.py",
      "sha256": "6222b7135dce93869b02e9e00276d31b4f648dc3c9b42e4b5c8fdb8f8d904ed2",
      "size": 17890,
      "physical_lines": 430,
      "working_git_blob": "9f257a2564ecef3f76e117ce470f36e67c18390a",
      "head_git_blob": "9f257a2564ecef3f76e117ce470f36e67c18390a",
      "changed_from_head": false
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/transport_manifest.py",
      "sha256": "f70fba9b394490881f2e6c0e8d05fd9011b810ae15339dfe18a84c2ffef19f0f",
      "size": 11313,
      "physical_lines": 271,
      "working_git_blob": "f691f3d768c5ebe6753e2d8c2c687cc70080d466",
      "head_git_blob": "f691f3d768c5ebe6753e2d8c2c687cc70080d466",
      "changed_from_head": false
    },
    {
      "path": "packages/discovery-runtime/src/drm_copilot_discovery/source_snapshots.py",
      "sha256": "d5ba8ec85f7e1937aa38d687cfe506a7001c814513257140cee8bfb280e181e5",
      "size": 16601,
      "physical_lines": 437,
      "working_git_blob": "a314f4df5e2b0e93f84f923cebc73330e73c38e0",
      "head_git_blob": null,
      "changed_from_head": true
    },
    {
      "path": "tests/discovery_runtime/test_snapshot_export.py",
      "sha256": "cc1b079ebf51af27e0bfccd032c5b668eadd295d024caafcf79dca82ba8ce261",
      "size": 18652,
      "physical_lines": 475,
      "working_git_blob": "688d040225949506757c5e26c9de835b06500be4",
      "head_git_blob": "688e2e6ce36e62abfe77bb90e82d7fb73c5f9680",
      "changed_from_head": true
    },
    {
      "path": "tests/discovery_runtime/test_snapshot_import.py",
      "sha256": "e983600a0df7477dd3618a41db96b62539dc17904c8ef6f6c8f7a99ee424b077",
      "size": 17317,
      "physical_lines": 449,
      "working_git_blob": "1f7cb7fefefd38991463193452966fc9b4b23037",
      "head_git_blob": "7f39e4d24b8112dc03991f0b502f544202aef313",
      "changed_from_head": true
    },
    {
      "path": "tests/discovery_runtime/source_snapshot_test_support.py",
      "sha256": "34215fb4d2499575ad59857d302dfdddd8f59c050e3cae7e1e809b0c8aef6aa9",
      "size": 13923,
      "physical_lines": 373,
      "working_git_blob": "ae01f0596c1a631644aa1979a82374b758f0a8e6",
      "head_git_blob": null,
      "changed_from_head": true
    }
  ]
}
```
