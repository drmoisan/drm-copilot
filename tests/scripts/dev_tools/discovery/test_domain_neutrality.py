"""Keep v1 fixtures neutral and verify caller-owned v2 draft projection."""

from __future__ import annotations

import re
from pathlib import Path
from typing import TYPE_CHECKING

from drm_copilot_discovery.init_projection import (
    ARTIFACT_TEMPLATES,
    TEMPLATE_NAMES,
    artifact_values,
    profile_proposal,
)
from drm_copilot_discovery.profile_v2 import ProfileV2

from scripts.dev_tools.discovery.init_models import EXPECTED_TEMPLATE_RELATIVE_PATHS
from tests.discovery_runtime.initialization_test_support import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.initialization_test_support import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.initialization_test_support import request_for

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.init_projection import InitializationTemplates

DISALLOWED_TOKEN_PATTERN = re.compile(r"TaskMaster|TMW|Outlook|VSTO", re.IGNORECASE)
_TEMPLATE_ROOT = Path(__file__).resolve().parents[4] / "docs/discovery/templates"


def test_domain_neutrality_templates_contain_no_disallowed_tokens() -> None:
    """Preserve the frozen v1 check and cover all six production v2 templates."""
    paths = (
        *EXPECTED_TEMPLATE_RELATIVE_PATHS,
        *(Path("v2") / name for name in TEMPLATE_NAMES),
    )
    # Apply the same frozen domain-neutrality contract to every declared template.
    for path in paths:
        assert not DISALLOWED_TOKEN_PATTERN.search(
            (_TEMPLATE_ROOT / path).read_text(encoding="utf-8")
        ), path


def test_rendered_v2_drafts_use_only_caller_identity_and_empty_knowledge(
    initialization_catalog: SchemaCatalog,
    initialization_templates: InitializationTemplates,
) -> None:
    """
    Production projection contains no example-domain facts or generated feature IDs.
    """
    request = request_for("combined")
    content = profile_proposal(
        request,
        templates=initialization_templates,
        catalog=initialization_catalog,
        revision=None,
    )
    profile = ProfileV2(content, catalog=initialization_catalog)
    values = artifact_values(profile, scope_id="scope-" + request.system_id)
    # Render each role-capable artifact from the same explicit consumer identity.
    outputs = (
        content,
        *(
            initialization_templates.render(name, values)
            for _, _, name in ARTIFACT_TEMPLATES
        ),
    )

    assert profile.system.id == request.system_id
    assert profile.repository.id == request.repository_id
    assert profile.required_modes == ("online",)
    assert profile.clients == () and profile.repositories == ()
    # Caller-owned identity must remain independent of every example domain.
    for output in outputs:
        assert not DISALLOWED_TOKEN_PATTERN.search(output.decode())
        assert "example" not in output.decode().lower()
