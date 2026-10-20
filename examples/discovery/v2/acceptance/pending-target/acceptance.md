# Acceptance

## Summary

```json
{"candidates":2,"pending":1,"ready":1,"withheld":0}
```

## Findings

```json
[]
```

## Ready

```json
{"identity":{"client_id":"client-alpha","criterion_id":"criterion-alpha","feature_id":"feature-alpha","kind":"target-acceptance","linked_scenario":null,"mode_id":"online","platform_id":"generic","source_repository_id":"workspace-example"},"repository":{"id":"workspace-example","revision":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},"specification":{"$schema":"urn:drm-copilot:discovery:2.0.0:acceptance-specification","artifact_kind":"acceptance-specification","client_id":"client-alpha","criterion_id":"criterion-alpha","evidence_refs":[{"artifact_kind":"evidence-reference","id":"source-alpha","path":"docs/migration/discovery/source-alpha.json","repository":"workspace-example","revision":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","sha256":"4799bc1bb4a75a9b7c285c9f00cf1fd19559a8187aff9c714491915e1d0aec5c"}],"expectation_basis":"verified-source","extensions":{"drm-copilot.generation":{"scenario":null}},"feature_id":"feature-alpha","given":["The processor is idle."],"id":"scn-1b765bd218f981e7dac57f9fe90916ade9605a67b8e760eb56dacd2dde7f483a","kind":"target-acceptance","mode_id":"online","pending_reasons":[],"platform_id":"generic","product_decision_refs":[],"readiness":"ready","scenario_id":"scn-1b765bd218f981e7dac57f9fe90916ade9605a67b8e760eb56dacd2dde7f483a","schema_version":"2.0.0","source_content_sha256":"630f2e0074d8dac3c19af957ab05a2fc46038e862ddb584cefc6f205cab4f238","source_contract_refs":[{"artifact_kind":"feature-contract","artifact_path":"docs/migration/discovery/feature-alpha.json","artifact_sha256":"fd26fb72ecb57322e1ed2f8c89ac3d38c0717a6e9d0b1957f0563ff2e3abb119","feature_id":"feature-alpha","repository_id":"workspace-example","revision":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","schema_version":"2.0.0"}],"tags":["@client_client-alpha","@feature_feature-alpha","@mode_online","@platform_generic","@scenario_scn-1b765bd218f981e7dac57f9fe90916ade9605a67b8e760eb56dacd2dde7f483a"],"then":["The processor state is active after acknowledgement."],"when":"An operator requests activation."},"status":"ready"}
```

## Non-executable

```json
{"identity":{"client_id":"client-alpha","criterion_id":"target-criterion","feature_id":"feature-alpha","kind":"target-acceptance","linked_scenario":null,"mode_id":"online","platform_id":"generic","source_repository_id":"workspace-example"},"repository":{"id":"workspace-example","revision":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"},"specification":{"$schema":"urn:drm-copilot:discovery:2.0.0:acceptance-specification","artifact_kind":"acceptance-specification","client_id":"client-alpha","criterion_id":"target-criterion","evidence_refs":[{"artifact_kind":"evidence-reference","id":"decision-evidence-alpha","path":"docs/migration/discovery/decision-evidence-alpha.json","repository":"workspace-example","revision":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","sha256":"7666385623e6280d3fe1da43b1fc5066b06694e0a53e70322339afa9aa8fccf5"}],"expectation_basis":"unresolved","extensions":{"drm-copilot.generation":{"scenario":null}},"feature_id":"feature-alpha","given":["The processor is idle."],"id":"scn-38848f66d18952dfe72d4ee067b5503c0956e62677349253806702d4e11261d2","kind":"target-acceptance","mode_id":"online","pending_reasons":["Policy remains unresolved."],"platform_id":"generic","product_decision_refs":[{"artifact_kind":"product-decision","id":"decision-alpha","path":"docs/migration/discovery/decision-alpha.json","repository":"workspace-example","revision":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","sha256":"80314cbea842ffb03dc75796a2e92fde828c4425eca5b0b6b31f2e197339f2ac"}],"readiness":"pending","scenario_id":"scn-38848f66d18952dfe72d4ee067b5503c0956e62677349253806702d4e11261d2","schema_version":"2.0.0","source_content_sha256":"09d7381a4c5ec8d775763d86caa1cac3ed6b5d802a20a1cd807bd3fb0c98fb16","source_contract_refs":[{"artifact_kind":"feature-contract","artifact_path":"docs/migration/discovery/feature-alpha.json","artifact_sha256":"fd26fb72ecb57322e1ed2f8c89ac3d38c0717a6e9d0b1957f0563ff2e3abb119","feature_id":"feature-alpha","repository_id":"workspace-example","revision":"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","schema_version":"2.0.0"}],"tags":["@client_client-alpha","@feature_feature-alpha","@mode_online","@platform_generic","@scenario_scn-38848f66d18952dfe72d4ee067b5503c0956e62677349253806702d4e11261d2"],"then":null,"when":"An operator requests activation."},"status":"pending"}
```

