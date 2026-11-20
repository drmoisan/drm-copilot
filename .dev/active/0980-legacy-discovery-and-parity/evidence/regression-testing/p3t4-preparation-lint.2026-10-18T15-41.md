# p3t4-preparation-lint

Timestamp: 2026-10-18T15-41
Command: python -m ruff check packages/discovery-runtime/src/drm_copilot_discovery/draft_contracts.py packages/discovery-runtime/src/drm_copilot_discovery/draft_scenarios.py tests/discovery_runtime/test_draft_contracts.py tests/discovery_runtime/test_draft_scenarios.py
EXIT_CODE: 1
Output Summary:     [1m[94m|[0m; ; Found 20 errors.; [[36m*[0m] 2 fixable with the `--fix` option.

Working directory: .
Started: 2026-10-18T15:41:36.525048+00:00
Duration seconds: 0.448
Phase: P3-T4 contract and scenario drafting; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\draft_contracts.py:266:89
    [1m[94m|[0m
[1m[94m264 |[0m         features=(request.feature_id,),
[1m[94m265 |[0m         dimensions=tuple(unresolved),
[1m[94m266 |[0m         question="What is the observed legacy behavior for the unresolved dimensions of "
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m267 |[0m         + request.feature_id
[1m[94m268 |[0m         + "?",
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\draft_contracts.py:290:89
    [1m[94m|[0m
[1m[94m288 |[0m     invocation: InvocationContext | None = None,
[1m[94m289 |[0m ) -> MutationPlan:
[1m[94m290 |[0m     """Validate the complete prospective graph under caller-authenticated exact grants."""
    [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m291 |[0m     return plan_mutation(
[1m[94m292 |[0m         baseline,
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\draft_contracts.py:308:89
    [1m[94m|[0m
[1m[94m306 |[0m     invocation: InvocationContext | None = None,
[1m[94m307 |[0m ) -> MutationResult:
[1m[94m308 |[0m     """Use the shared fresh-input commit/dry-run path without new publication semantics."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m309 |[0m     return commit_mutation(
[1m[94m310 |[0m         plan_contract(baseline, request, grants=grants, invocation=invocation),
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\draft_scenarios.py:33:89
   [1m[94m|[0m
[1m[94m31 |[0m @dataclass(frozen=True, kw_only=True)
[1m[94m32 |[0m class ScenarioDraft:
[1m[94m33 |[0m     """Require explicit feature links and caller-supplied environment/observation plans."""
   [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m34 |[0m
[1m[94m35 |[0m     scenario_id: str
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\draft_scenarios.py:40:89
   [1m[94m|[0m
[1m[94m39 |[0m     def __post_init__(self) -> None:
[1m[94m40 |[0m         """Detach selected IDs and reject empty/duplicate or unsafe request identities."""
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m41 |[0m         object.__setattr__(self, "feature_ids", tuple(self.feature_ids))
[1m[94m42 |[0m         WriteGrant(
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\draft_scenarios.py:66:89
   [1m[94m|[0m
[1m[94m64 |[0m     baseline: CapturedWorkspace, request: ScenarioDraft
[1m[94m65 |[0m ) -> tuple[MutationChange, ...]:
[1m[94m66 |[0m     """Preserve supplied plans, generate no run, and link unknown planned expectations."""
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m67 |[0m     identifier = "unknown-scenario-" + request.scenario_id
[1m[94m68 |[0m     features = tuple(sorted(request.feature_ids))
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_draft_contracts.py:39:5
   [1m[94m|[0m
[1m[94m38 |[0m   if TYPE_CHECKING:
[1m[94m39 |[0m [1m[91m/[0m     from drm_copilot_discovery.catalog import SchemaCatalog
[1m[94m40 |[0m [1m[91m|[0m     from drm_copilot_discovery.mutation_plan import CapturedWorkspace
[1m[94m41 |[0m [1m[91m|[0m     from tests.discovery_runtime.test_snapshot_io import MemoryStore
   [1m[94m|[0m [1m[91m|____________________________________________________________________^[0m
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (97 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_draft_contracts.py:139:89
    [1m[94m|[0m
[1m[94m137 |[0m     mutation_catalog: SchemaCatalog, dry_run: bool
[1m[94m138 |[0m ) -> None:
[1m[94m139 |[0m     """Actual shared commit writes only the contract/question collection; dry-run writes none."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^[0m
[1m[94m140 |[0m     store, baseline = draft_case(mutation_catalog)
[1m[94m141 |[0m     request = ContractDraft(feature_id="create-feature", name="Create feature")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_draft_contracts.py:161:89
    [1m[94m|[0m
[1m[94m159 |[0m     mutation_catalog: SchemaCatalog,
[1m[94m160 |[0m ) -> None:
[1m[94m161 |[0m     """Appending selected unknowns preserves another feature's exact structured records."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m162 |[0m     store, _ = draft_case(mutation_catalog)
[1m[94m163 |[0m     baseline = add_feature(store, mutation_catalog, "existing")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (97 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_draft_contracts.py:200:89
    [1m[94m|[0m
[1m[94m198 |[0m     mutation_catalog: SchemaCatalog, field: str
[1m[94m199 |[0m ) -> None:
[1m[94m200 |[0m     """Caller fields cannot turn creation into verification, approval or identity replacement."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^[0m
[1m[94m201 |[0m     _, baseline = draft_case(mutation_catalog)
[1m[94m202 |[0m     request = ContractDraft(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_draft_contracts.py:213:89
    [1m[94m|[0m
[1m[94m211 |[0m     mutation_catalog: SchemaCatalog, state: str
[1m[94m212 |[0m ) -> None:
[1m[94m213 |[0m     """Even a supplied dimension cannot claim a completed observation or approved decision."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m214 |[0m     _, baseline = draft_case(mutation_catalog)
[1m[94m215 |[0m     request = ContractDraft(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (96 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_draft_contracts.py:227:89
    [1m[94m|[0m
[1m[94m225 |[0m     mutation_catalog: SchemaCatalog,
[1m[94m226 |[0m ) -> None:
[1m[94m227 |[0m     """Supplied inference stays inference; unknown transition links receive an open question."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^[0m
[1m[94m228 |[0m     _, baseline = draft_case(mutation_catalog)
[1m[94m229 |[0m     request = ContractDraft(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_draft_contracts.py:275:89
    [1m[94m|[0m
[1m[94m273 |[0m     mutation_catalog: SchemaCatalog, case: str
[1m[94m274 |[0m ) -> None:
[1m[94m275 |[0m     """Selected creation never overwrites files or bypasses exact kind/ID/path grants."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m276 |[0m     store, baseline = draft_case(mutation_catalog)
[1m[94m277 |[0m     request = ContractDraft(feature_id="feature", name="Feature")
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_draft_contracts.py:409:89
    [1m[94m|[0m
[1m[94m408 |[0m def test_shared_json_values_do_not_mint_native_authority() -> None:
[1m[94m409 |[0m     """Generated references are immutable structural values, not authorization contexts."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m410 |[0m     value = draft_object(reference=draft_reference("feature-contract", "feature"))
[1m[94m411 |[0m     assert (
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_draft_scenarios.py:30:5
   [1m[94m|[0m
[1m[94m29 |[0m   if TYPE_CHECKING:
[1m[94m30 |[0m [1m[91m/[0m     from drm_copilot_discovery.catalog import SchemaCatalog
[1m[94m31 |[0m [1m[91m|[0m     from drm_copilot_discovery.mutation_plan import CapturedWorkspace
[1m[94m32 |[0m [1m[91m|[0m     from tests.discovery_runtime.test_snapshot_io import MemoryStore
   [1m[94m|[0m [1m[91m|____________________________________________________________________^[0m
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_draft_scenarios.py:126:89
    [1m[94m|[0m
[1m[94m124 |[0m     mutation_catalog: SchemaCatalog, dry_run: bool
[1m[94m125 |[0m ) -> None:
[1m[94m126 |[0m     """The real shared writer publishes planned bytes only; preview retains all state."""
    [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m127 |[0m     store, baseline = scenario_case(mutation_catalog)
[1m[94m128 |[0m     request = ScenarioDraft(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (91 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_draft_scenarios.py:173:89
    [1m[94m|[0m
[1m[94m171 |[0m     mutation_catalog: SchemaCatalog, case: str
[1m[94m172 |[0m ) -> None:
[1m[94m173 |[0m     """Invalid selection and colliding stable IDs fail before changing any memory bytes."""
    [1m[94m|[0m                                                                                         [1m[91m^^^[0m
[1m[94m174 |[0m     store, baseline = scenario_case(mutation_catalog)
[1m[94m175 |[0m     features = (
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_draft_scenarios.py:216:89
    [1m[94m|[0m
[1m[94m214 |[0m     mutation_catalog: SchemaCatalog, field: str, value: object
[1m[94m215 |[0m ) -> None:
[1m[94m216 |[0m     """A create request cannot claim successful execution, repetition or fabricated proof."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m217 |[0m     _, baseline = draft_case(mutation_catalog)
[1m[94m218 |[0m     request = ScenarioDraft(
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (97 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_draft_scenarios.py:293:89
    [1m[94m|[0m
[1m[94m291 |[0m     mutation_catalog: SchemaCatalog, case: str
[1m[94m292 |[0m ) -> None:
[1m[94m293 |[0m     """Invalid selected IDs and missing caller context are rejected without invented defaults."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^[0m
[1m[94m294 |[0m     _, baseline = draft_case(mutation_catalog)
[1m[94m295 |[0m     with pytest.raises(ValueError):
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (94 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_draft_scenarios.py:370:89
    [1m[94m|[0m
[1m[94m368 |[0m     mutation_catalog: SchemaCatalog,
[1m[94m369 |[0m ) -> None:
[1m[94m370 |[0m     """Equivalent selected feature sets produce identical projected bytes and question IDs."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^[0m
[1m[94m371 |[0m     _, baseline = scenario_case(mutation_catalog)
[1m[94m372 |[0m     request = ScenarioDraft(
    [1m[94m|[0m

Found 20 errors.
[[36m*[0m] 2 fixable with the `--fix` option.
```
