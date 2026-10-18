# p3t2-correction-lint

Timestamp: 2026-10-18T13-21
Command: poetry run ruff check packages/discovery-runtime/src/drm_copilot_discovery/init_flow.py packages/discovery-runtime/src/drm_copilot_discovery/init_io.py packages/discovery-runtime/src/drm_copilot_discovery/init_projection.py scripts/dev_tools/discovery/init_flow.py tests/discovery_runtime/test_initialization.py tests/discovery_runtime/test_initialization_conflicts.py tests/discovery_runtime/initialization_test_support.py tests/scripts/dev_tools/discovery/test_init_flow.py tests/scripts/dev_tools/discovery/test_init_cli.py tests/scripts/dev_tools/discovery/test_init_models.py tests/scripts/dev_tools/discovery/test_domain_neutrality.py
EXIT_CODE: 1
Output Summary:    [1m[94m|[0m; ; Found 15 errors.; [[36m*[0m] 7 fixable with the `--fix` option.

Working directory: .
Started: 2026-10-18T13:21:36.070083+00:00
Duration seconds: 0.784
Phase: P3-T2 safe draft initialization; focused task verification.

## Captured output

```text
[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_flow.py:3:1
   [1m[94m|[0m
[1m[94m 1 |[0m   """Plan and initialize honest v2 drafts through a root-bound trusted I/O adapter."""
[1m[94m 2 |[0m
[1m[94m 3 |[0m [1m[91m/[0m from __future__ import annotations
[1m[94m 4 |[0m [1m[91m|[0m
[1m[94m 5 |[0m [1m[91m|[0m from dataclasses import dataclass
[1m[94m 6 |[0m [1m[91m|[0m from hashlib import sha256
[1m[94m 7 |[0m [1m[91m|[0m from typing import TYPE_CHECKING
[1m[94m 8 |[0m [1m[91m|[0m
[1m[94m 9 |[0m [1m[91m|[0m from drm_copilot_discovery.init_models import EXPECTED_TEMPLATE_RELATIVE_PATHS
[1m[94m10 |[0m [1m[91m|[0m from drm_copilot_discovery.init_projection import (
[1m[94m11 |[0m [1m[91m|[0m     ARTIFACT_TEMPLATES,
[1m[94m12 |[0m [1m[91m|[0m     InitializationConflict,
[1m[94m13 |[0m [1m[91m|[0m     InitializationOutput,
[1m[94m14 |[0m [1m[91m|[0m     InitializationResult,
[1m[94m15 |[0m [1m[91m|[0m     InitializationRequest,
[1m[94m16 |[0m [1m[91m|[0m     InitializationTemplates,
[1m[94m17 |[0m [1m[91m|[0m     artifact_values,
[1m[94m18 |[0m [1m[91m|[0m     profile_proposal,
[1m[94m19 |[0m [1m[91m|[0m     require_compatible,
[1m[94m20 |[0m [1m[91m|[0m )
[1m[94m21 |[0m [1m[91m|[0m from drm_copilot_discovery.mutation_io import GuardedMutationWriter, commit_mutation
[1m[94m22 |[0m [1m[91m|[0m from drm_copilot_discovery.mutation_plan import (
[1m[94m23 |[0m [1m[91m|[0m     MutationChange,
[1m[94m24 |[0m [1m[91m|[0m     MutationError,
[1m[94m25 |[0m [1m[91m|[0m     plan_mutation,
[1m[94m26 |[0m [1m[91m|[0m )
[1m[94m27 |[0m [1m[91m|[0m from drm_copilot_discovery.path_models import PathPolicyError, WriteGrant
[1m[94m28 |[0m [1m[91m|[0m from drm_copilot_discovery.profile_v2 import ProfileError
[1m[94m29 |[0m [1m[91m|[0m from drm_copilot_discovery.path_policy import FILE_KEYS
   [1m[94m|[0m [1m[91m|_______________________________________________________^[0m
[1m[94m30 |[0m
[1m[94m31 |[0m   if TYPE_CHECKING:
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_projection.py:23:5
   [1m[94m|[0m
[1m[94m22 |[0m   if TYPE_CHECKING:
[1m[94m23 |[0m [1m[91m/[0m     from collections.abc import Callable, Mapping
[1m[94m24 |[0m [1m[91m|[0m
[1m[94m25 |[0m [1m[91m|[0m     from drm_copilot_discovery.catalog import SchemaCatalog
[1m[94m26 |[0m [1m[91m|[0m     from drm_copilot_discovery.init_io import InitializationIO
[1m[94m27 |[0m [1m[91m|[0m     from drm_copilot_discovery.mutation_plan import CapturedWorkspace
[1m[94m28 |[0m [1m[91m|[0m     from drm_copilot_discovery.validation import SnapshotValidation
[1m[94m29 |[0m [1m[91m|[0m     from drm_copilot_discovery.profile_models import ArtifactKey
   [1m[94m|[0m [1m[91m|________________________________________________________________^[0m
[1m[94m30 |[0m
[1m[94m31 |[0m   TEMPLATE_ROOT = "docs/discovery/templates/v2"
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (98 > 88)[0m
   [1m[94m-->[0m packages\discovery-runtime\src\drm_copilot_discovery\init_projection.py:448:89
    [1m[94m|[0m
[1m[94m446 |[0m                 artifact_path=path,
[1m[94m447 |[0m                 message=message,
[1m[94m448 |[0m                 next_action="Correct the conflicting existing content and reload initialization.",
    [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^[0m
[1m[94m449 |[0m             ),
[1m[94m450 |[0m         )
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\initialization_test_support.py:3:1
   [1m[94m|[0m
[1m[94m 1 |[0m   """Share immutable templates/catalogs and fresh in-memory initialization boundaries."""
[1m[94m 2 |[0m
[1m[94m 3 |[0m [1m[91m/[0m from __future__ import annotations
[1m[94m 4 |[0m [1m[91m|[0m
[1m[94m 5 |[0m [1m[91m|[0m from pathlib import Path
[1m[94m 6 |[0m [1m[91m|[0m from dataclasses import replace
[1m[94m 7 |[0m [1m[91m|[0m from typing import TYPE_CHECKING
[1m[94m 8 |[0m [1m[91m|[0m
[1m[94m 9 |[0m [1m[91m|[0m import pytest
[1m[94m10 |[0m [1m[91m|[0m from drm_copilot_discovery.catalog import load_catalog
[1m[94m11 |[0m [1m[91m|[0m from drm_copilot_discovery.init_io import InitializationIO
[1m[94m12 |[0m [1m[91m|[0m from drm_copilot_discovery.init_flow import plan_initialization
[1m[94m13 |[0m [1m[91m|[0m from drm_copilot_discovery.init_projection import (
[1m[94m14 |[0m [1m[91m|[0m     InitializationCapture,
[1m[94m15 |[0m [1m[91m|[0m     InitializationRequest,
[1m[94m16 |[0m [1m[91m|[0m     InitializationTemplates,
[1m[94m17 |[0m [1m[91m|[0m )
[1m[94m18 |[0m [1m[91m|[0m from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
[1m[94m19 |[0m [1m[91m|[0m
[1m[94m20 |[0m [1m[91m|[0m from tests.discovery_runtime.mutation_test_support import MemoryDisk
   [1m[94m|[0m [1m[91m|____________________________________________________________________^[0m
[1m[94m21 |[0m
[1m[94m22 |[0m   if TYPE_CHECKING:
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\initialization_test_support.py:23:5
   [1m[94m|[0m
[1m[94m22 |[0m   if TYPE_CHECKING:
[1m[94m23 |[0m [1m[91m/[0m     from drm_copilot_discovery.catalog import SchemaCatalog
[1m[94m24 |[0m [1m[91m|[0m     from drm_copilot_discovery.profile_models import SystemRole
[1m[94m25 |[0m [1m[91m|[0m     from drm_copilot_discovery.init_flow import InitializationPlan
   [1m[94m|[0m [1m[91m|__________________________________________________________________^[0m
[1m[94m26 |[0m
[1m[94m27 |[0m   ROOT = Path(__file__).resolve().parents[2]
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_initialization.py:209:89
    [1m[94m|[0m
[1m[94m207 |[0m     initialization_templates: InitializationTemplates,
[1m[94m208 |[0m ) -> None:
[1m[94m209 |[0m     """Even schema-valid configured profile templates cannot bypass draft initialization."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m210 |[0m     documents = dict(initialization_templates.documents)
[1m[94m211 |[0m     value = dict(documents["domain-profile.yaml"])
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\discovery_runtime\test_initialization_conflicts.py:3:1
   [1m[94m|[0m
[1m[94m 1 |[0m   """Exercise prewrite conflicts, bootstrap races and bounded failures with memory I/O."""
[1m[94m 2 |[0m
[1m[94m 3 |[0m [1m[91m/[0m from __future__ import annotations
[1m[94m 4 |[0m [1m[91m|[0m
[1m[94m 5 |[0m [1m[91m|[0m from contextlib import ExitStack
[1m[94m 6 |[0m [1m[91m|[0m from dataclasses import replace
[1m[94m 7 |[0m [1m[91m|[0m from typing import TYPE_CHECKING
[1m[94m 8 |[0m [1m[91m|[0m
[1m[94m 9 |[0m [1m[91m|[0m import pytest
[1m[94m10 |[0m [1m[91m|[0m from drm_copilot_discovery.init_flow import (
[1m[94m11 |[0m [1m[91m|[0m     commit_initialization,
[1m[94m12 |[0m [1m[91m|[0m     initialize_workspace,
[1m[94m13 |[0m [1m[91m|[0m     plan_initialization,
[1m[94m14 |[0m [1m[91m|[0m )
[1m[94m15 |[0m [1m[91m|[0m from drm_copilot_discovery.init_projection import (
[1m[94m16 |[0m [1m[91m|[0m     InitializationConflict,
[1m[94m17 |[0m [1m[91m|[0m     _ProposalInputs,
[1m[94m18 |[0m [1m[91m|[0m )
[1m[94m19 |[0m [1m[91m|[0m from drm_copilot_discovery.init_io import BootstrapResult
[1m[94m20 |[0m [1m[91m|[0m from drm_copilot_discovery.path_policy import PathPolicy
[1m[94m21 |[0m [1m[91m|[0m
[1m[94m22 |[0m [1m[91m|[0m from tests.discovery_runtime.initialization_test_support import (
[1m[94m23 |[0m [1m[91m|[0m     InitializationCase,
[1m[94m24 |[0m [1m[91m|[0m     bootstrap_capture,
[1m[94m25 |[0m [1m[91m|[0m     request_for,
[1m[94m26 |[0m [1m[91m|[0m     seed_proposal,
[1m[94m27 |[0m [1m[91m|[0m )
[1m[94m28 |[0m [1m[91m|[0m from tests.discovery_runtime.initialization_test_support import (
[1m[94m29 |[0m [1m[91m|[0m     initialization_catalog as initialization_catalog,
[1m[94m30 |[0m [1m[91m|[0m )
[1m[94m31 |[0m [1m[91m|[0m from tests.discovery_runtime.initialization_test_support import (
[1m[94m32 |[0m [1m[91m|[0m     initialization_plan as initialization_plan,
[1m[94m33 |[0m [1m[91m|[0m )
[1m[94m34 |[0m [1m[91m|[0m from tests.discovery_runtime.initialization_test_support import (
[1m[94m35 |[0m [1m[91m|[0m     initialization_templates as initialization_templates,
[1m[94m36 |[0m [1m[91m|[0m )
[1m[94m37 |[0m [1m[91m|[0m from tests.discovery_runtime.mutation_test_support import constant
   [1m[94m|[0m [1m[91m|__________________________________________________________________^[0m
[1m[94m38 |[0m
[1m[94m39 |[0m   if TYPE_CHECKING:
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1m`drm_copilot_discovery.init_flow.plan_initialization` imported but unused[0m
  [1m[94m-->[0m tests\discovery_runtime\test_initialization_conflicts.py:13:5
   [1m[94m|[0m
[1m[94m11 |[0m     commit_initialization,
[1m[94m12 |[0m     initialize_workspace,
[1m[94m13 |[0m     plan_initialization,
   [1m[94m|[0m     [1m[91m^^^^^^^^^^^^^^^^^^^[0m
[1m[94m14 |[0m )
[1m[94m15 |[0m from drm_copilot_discovery.init_projection import (
   [1m[94m|[0m
[1m[96mhelp[0m: [1mRemove unused import: `drm_copilot_discovery.init_flow.plan_initialization`[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (89 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_initialization_conflicts.py:54:89
   [1m[94m|[0m
[1m[94m52 |[0m     conflict: str,
[1m[94m53 |[0m ) -> None:
[1m[94m54 |[0m     """Existing bad bytes remain visible; no profile/directory is created around them."""
   [1m[94m|[0m                                                                                         [1m[91m^[0m
[1m[94m55 |[0m     case, plan = InitializationCase(initialization_catalog), initialization_plan
[1m[94m56 |[0m     profile = plan.capture.proposal_base.snapshot.profile
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (99 > 88)[0m
  [1m[94m-->[0m tests\discovery_runtime\test_initialization_conflicts.py:89:89
   [1m[94m|[0m
[1m[94m87 |[0m     initialization_templates: InitializationTemplates,
[1m[94m88 |[0m ) -> None:
[1m[94m89 |[0m     """Rerun fills missing outputs, retaining compatible IDs, raw whitespace and unrelated docs."""
   [1m[94m|[0m                                                                                         [1m[91m^^^^^^^^^^^[0m
[1m[94m90 |[0m     case, plan = InitializationCase(initialization_catalog), initialization_plan
[1m[94m91 |[0m     profile = plan.capture.proposal_base.snapshot.profile
   [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (93 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_initialization_conflicts.py:122:89
    [1m[94m|[0m
[1m[94m120 |[0m     change: str,
[1m[94m121 |[0m ) -> None:
[1m[94m122 |[0m     """Virtual profile bytes never waive a real absence, identity or complete-input check."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^^[0m
[1m[94m123 |[0m     case, plan = InitializationCase(initialization_catalog), initialization_plan
[1m[94m124 |[0m     path = plan.capture.proposal_base.snapshot.profile.artifacts["profile"]
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_initialization_conflicts.py:207:89
    [1m[94m|[0m
[1m[94m205 |[0m     path: str,
[1m[94m206 |[0m ) -> None:
[1m[94m207 |[0m     """A parent swap between inspection and open is rejected before creating descendants."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m208 |[0m     case, plan = InitializationCase(initialization_catalog), initialization_plan
[1m[94m209 |[0m     profile = plan.capture.proposal_base.snapshot.profile
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (92 > 88)[0m
   [1m[94m-->[0m tests\discovery_runtime\test_initialization_conflicts.py:246:89
    [1m[94m|[0m
[1m[94m244 |[0m     initialization_plan: InitializationPlan,
[1m[94m245 |[0m ) -> None:
[1m[94m246 |[0m     """Synthetic bytes honor limits and existing input bytes retain their original value."""
    [1m[94m|[0m                                                                                         [1m[91m^^^^[0m
[1m[94m247 |[0m     case, plan = InitializationCase(initialization_catalog), initialization_plan
[1m[94m248 |[0m     path = plan.capture.proposal_base.snapshot.profile.artifacts["profile"]
    [1m[94m|[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[[1m[96m*[0m] [1mImport block is un-sorted or un-formatted[0m
  [1m[94m-->[0m tests\scripts\dev_tools\discovery\test_domain_neutrality.py:3:1
   [1m[94m|[0m
[1m[94m 1 |[0m   """Keep v1 fixtures neutral and verify caller-owned v2 draft projection."""
[1m[94m 2 |[0m
[1m[94m 3 |[0m [1m[91m/[0m from __future__ import annotations
[1m[94m 4 |[0m [1m[91m|[0m
[1m[94m 5 |[0m [1m[91m|[0m import re
[1m[94m 6 |[0m [1m[91m|[0m from pathlib import Path
[1m[94m 7 |[0m [1m[91m|[0m from typing import TYPE_CHECKING
[1m[94m 8 |[0m [1m[91m|[0m
[1m[94m 9 |[0m [1m[91m|[0m from drm_copilot_discovery.init_projection import (
[1m[94m10 |[0m [1m[91m|[0m     ARTIFACT_TEMPLATES,
[1m[94m11 |[0m [1m[91m|[0m     TEMPLATE_NAMES,
[1m[94m12 |[0m [1m[91m|[0m     artifact_values,
[1m[94m13 |[0m [1m[91m|[0m     profile_proposal,
[1m[94m14 |[0m [1m[91m|[0m )
[1m[94m15 |[0m [1m[91m|[0m from drm_copilot_discovery.profile_v2 import ProfileV2
[1m[94m16 |[0m [1m[91m|[0m
[1m[94m17 |[0m [1m[91m|[0m from scripts.dev_tools.discovery.init_models import EXPECTED_TEMPLATE_RELATIVE_PATHS
[1m[94m18 |[0m [1m[91m|[0m from tests.discovery_runtime.initialization_test_support import request_for
[1m[94m19 |[0m [1m[91m|[0m from tests.discovery_runtime.initialization_test_support import (
[1m[94m20 |[0m [1m[91m|[0m     initialization_catalog as initialization_catalog,
[1m[94m21 |[0m [1m[91m|[0m )
[1m[94m22 |[0m [1m[91m|[0m from tests.discovery_runtime.initialization_test_support import (
[1m[94m23 |[0m [1m[91m|[0m     initialization_templates as initialization_templates,
[1m[94m24 |[0m [1m[91m|[0m )
   [1m[94m|[0m [1m[91m|_^[0m
[1m[94m25 |[0m
[1m[94m26 |[0m   if TYPE_CHECKING:
   [1m[94m|[0m
[1m[96mhelp[0m: [1mOrganize imports[0m

[1m[91m]8;;httpEXTERNAL_PATH [0m[1mLine too long (90 > 88)[0m
  [1m[94m-->[0m tests\scripts\dev_tools\discovery\test_domain_neutrality.py:50:89
   [1m[94m|[0m
[1m[94m48 |[0m     initialization_templates: InitializationTemplates,
[1m[94m49 |[0m ) -> None:
[1m[94m50 |[0m     """Production projection contains no example-domain facts or generated feature IDs."""
   [1m[94m|[0m                                                                                         [1m[91m^^[0m
[1m[94m51 |[0m     request = request_for("combined")
[1m[94m52 |[0m     content = profile_proposal(
   [1m[94m|[0m

Found 15 errors.
[[36m*[0m] 7 fixable with the `--fix` option.
```
