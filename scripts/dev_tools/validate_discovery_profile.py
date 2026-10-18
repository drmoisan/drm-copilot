"""Thin compatibility adapter for the authoritative versioned profile parsers."""

from __future__ import annotations

from typing import TYPE_CHECKING

from drm_copilot_discovery.catalog import CatalogError
from drm_copilot_discovery.domain_profile import parse_domain_profile_text
from drm_copilot_discovery.domain_profile_models import DomainProfileError
from drm_copilot_discovery.profile_v2 import parse_profile_v2

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog


def validate_profile_text(
    text: str, *, schema_version: str = "2.0.0", catalog: SchemaCatalog | None = None
) -> list[str]:
    """Return authoritative profile errors without selecting a version from input.

    The finalized v2 contract replaces the former placeholder field check.
    Explicit v1 reads preserve their established typed parser. Supplying a
    catalog binds declared extension bytes; no consumer files are read here.
    """
    try:
        # Keep compatibility explicit; unsupported versions never fall back.
        if schema_version == "2.0.0":
            parse_profile_v2(text, catalog=catalog)
        elif schema_version == "1.0.0":
            if catalog is not None:
                raise DomainProfileError("v1 profiles do not accept extension catalogs")
            parse_domain_profile_text(text)
        else:
            raise DomainProfileError(
                f"Unsupported profile schema version: {schema_version}"
            )
    except (DomainProfileError, CatalogError) as error:
        return [str(error)]
    return []
