# P6-T1 native report diagnosis

The failure is a stale generated parity view after activation. The authorized single comparison completed in 6.633 seconds, with exit 0 and no timeout.

- The memory-backed loader reproduced all 14 archived manifest entries exactly and retained both inventory-pinned files.
- Exactly one field differs: `/input_sha256`, from `2c9ef1794d6cfabbf527eabe7a1e175b7d3a30767f7088e42eaf94256fec7075` to `0247c8253e090ee06d0ff70e4fcf3fcbeb374069ccf597e1f3c39347fee3a568`. Every other parity-report field is equal.
- Restoring only the previous activation absence reproduces the stored digest. `configure-real` added `config/discovery.json`; strict recomputation correctly rejects the older view during completion-report planning.
- The proposed correction is one authoritative `parity-report` request with `mode=parity-complete`, `write=true`, `dry_run=false`, and `format=both`, on the same retained workspace/profile. Expected exit remains 1 because parity is incomplete. Only the parity JSON/Markdown pair may change. This correction has not run.
- After a separately released refresh, resume the existing completion tail at `report-dry`, using the new semantic digest and a separately recorded post-refresh footprint baseline. Preserve the original stale-view refusal and all prior operands; do not weaken validation or directly edit/delete report files.
- The six successful steps remain reusable: installed identity, configure dry/real, profile, validate-profile, and inventory.

Source, tests, package, and fixture bytes were unchanged by this diagnosis. No tests, static gates, service/native operations, Git commands, or publication ran. Final 294 cases plus four contracts remain disabled.

The JSON receipt contains exact evidence references, comparison operands, source bindings, and the provisional metadata diagnostic qualification. The originals archive preserves the script, raw streams, both JSON operands, and all 14 input byte streams.

- Receipt: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-native-report-diagnosis.2026-10-21T05-36.json`
- Originals: `docs/features/active/2026-10-17-legacy-discovery-and-parity-980/evidence/other/p6t1-native-report-diagnosis-originals.2026-10-21T05-36.json`
