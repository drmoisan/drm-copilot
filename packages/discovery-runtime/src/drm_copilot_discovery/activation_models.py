"""Typed activation locator values, deliberately separate from protected authority."""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING, Literal, cast

from drm_copilot_discovery.profile_v2 import ProfileError
from drm_copilot_discovery.schema_validation import validate_document

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.models import JsonObject


@dataclass(frozen=True, init=False)
class ActivationLocator:
    """Represent the exact four-key locator without granting execution permission.

    Construction validates JSON text/bytes against the trusted activation schema.
    The protected registry and host attribution are outside this inert value.
    """

    document: JsonObject

    def __init__(
        self, content: bytes | str, *, catalog: SchemaCatalog | None = None
    ) -> None:
        """Reject disabled, malformed or augmented locators without partial values."""
        result = validate_document(
            content,
            expected_kind="activation",
            expected_version="2.0.0",
            catalog=catalog,
        )
        if not result.ok or result.document is None:
            raise ProfileError(result.findings)
        object.__setattr__(self, "document", result.document)

    @property
    def schema_version(self) -> Literal["2.0.0"]:
        """Return the exact locator wire version."""
        return "2.0.0"

    @property
    def enabled(self) -> Literal[True]:
        """Report intent to activate, never proof of protected activation."""
        return True

    @property
    def profile_path(self) -> str:
        """Return the lexical workspace-relative profile location."""
        return cast("str", self.document["profile_path"])

    @property
    def required_runtime_major(self) -> Literal[2]:
        """Return the supported major without accepting another wire version."""
        return 2

    def require_profile_path(self, path: str) -> None:
        """Reject locator disagreement without resolving filesystem authority."""
        if path != self.profile_path:
            raise ValueError("Explicit profile path disagrees with activation locator")
