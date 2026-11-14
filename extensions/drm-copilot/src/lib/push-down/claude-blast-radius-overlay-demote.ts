/**
 * Shared-surface demotion directive for the blast-radius overlay (issue #1006).
 *
 * Purpose:
 *     A destination cannot remove a shipped shared surface through the union
 *     composition of `composeBlastRadiusOverlay`, so a destination whose
 *     registry file (such as `quality-tiers.yml`) produced false hard edges
 *     could not fix it durably. The overlay directive key
 *     {@link SHARED_SURFACES_DEMOTE_KEY} names shared surfaces to demote to
 *     append-only paths.
 *
 * Rules (identical in `push_down_claude_blast_radius_overlay.py`):
 *     - Demotion runs after every other key has been composed.
 *     - Checks, in order: the value is a list of strings; the composed document
 *       carries a `conflict_tolerance` object with an `append_only_paths` list;
 *       every entry is a composed shared surface or append-only path.
 *     - Each entry is removed from `shared_surfaces` (remaining order kept) and
 *       unioned into `conflict_tolerance.append_only_paths`, base entries first.
 *     - An entry that is already append-only and not shared is a no-op.
 *     - No partial `conflict_tolerance` is created and the input is not mutated.
 *
 * The module also hosts {@link unionStrings}, the single order-preserving
 * union used by both overlay modules; `claude-blast-radius-overlay.ts`
 * imports it from here.
 *
 * This module imports nothing from `claude-blast-radius-overlay.ts`, so no
 * import cycle exists; the caller turns a failure detail into its own error.
 */

/** Overlay directive key naming shared surfaces to demote. */
export const SHARED_SURFACES_DEMOTE_KEY = "shared_surfaces_demote";

/** Composed-document key holding the shared-surface list. */
const SHARED_SURFACES_KEY = "shared_surfaces";

/** Composed-document key holding the scheduling policy block. */
const CONFLICT_TOLERANCE_KEY = "conflict_tolerance";

/** Policy-block key holding the append-only path list. */
const APPEND_ONLY_PATHS_KEY = "append_only_paths";

/** Result of a demotion: the demoted document, or the failure detail. */
export type SharedSurfaceDemotionResult =
  | { readonly ok: true; readonly document: Record<string, unknown> }
  | { readonly ok: false; readonly detail: string };

/**
 * Return whether a value is a plain object.
 *
 * @param value Candidate value.
 * @returns True for a non-null, non-array object.
 */
function isPlainObject(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

/**
 * Return whether a value is a list of strings.
 *
 * @param value Candidate value.
 * @returns True for an array whose members are all strings.
 */
function isStringList(value: unknown): value is string[] {
  return (
    Array.isArray(value) && value.every((item) => typeof item === "string")
  );
}

/**
 * Return the ordered union of a base list and overlay strings.
 *
 * This is the single order-preserving union used by both overlay modules
 * (`claude-blast-radius-overlay.ts` for string-list and nested-list keys, and
 * this module for the demotion target list).
 *
 * @param base Base entries of any element type, kept in base order.
 * @param overlay Overlay strings, each appended in overlay order unless it
 *   equals a string member of the base or an earlier overlay string.
 * @returns The composed list; neither input is mutated.
 */
export function unionStrings<T>(
  base: ReadonlyArray<T>,
  overlay: ReadonlyArray<string>,
): (T | string)[] {
  const composed: (T | string)[] = [...base];
  const seen = new Set<string>();
  for (const item of base) {
    if (typeof item === "string") {
      seen.add(item);
    }
  }
  for (const item of overlay) {
    if (!seen.has(item)) {
      seen.add(item);
      composed.push(item);
    }
  }
  return composed;
}

/**
 * Demote shared surfaces named by the overlay to append-only paths.
 *
 * @param composed The document composed from the base and every other overlay
 *   key. It is not mutated.
 * @param overlayValue The overlay value of {@link SHARED_SURFACES_DEMOTE_KEY}.
 * @returns The demoted document, or the detail of the first failed check.
 */
export function applySharedSurfaceDemotion(
  composed: Readonly<Record<string, unknown>>,
  overlayValue: unknown,
): SharedSurfaceDemotionResult {
  if (!isStringList(overlayValue)) {
    return {
      ok: false,
      detail: `key "${SHARED_SURFACES_DEMOTE_KEY}" must be a list of strings`,
    };
  }
  const tolerance = composed[CONFLICT_TOLERANCE_KEY];
  const appendOnly = isPlainObject(tolerance)
    ? tolerance[APPEND_ONLY_PATHS_KEY]
    : undefined;
  if (!isPlainObject(tolerance) || !Array.isArray(appendOnly)) {
    return {
      ok: false,
      detail:
        `key "${SHARED_SURFACES_DEMOTE_KEY}" requires ` +
        `${CONFLICT_TOLERANCE_KEY}.${APPEND_ONLY_PATHS_KEY} in the composed document`,
    };
  }
  const sharedValue = composed[SHARED_SURFACES_KEY];
  const shared: unknown[] = Array.isArray(sharedValue) ? sharedValue : [];
  for (const entry of overlayValue) {
    if (!shared.includes(entry) && !appendOnly.includes(entry)) {
      return {
        ok: false,
        detail:
          `key "${SHARED_SURFACES_DEMOTE_KEY}" names "${entry}", which is ` +
          "neither a shared surface nor an append-only path",
      };
    }
  }

  const demoted = new Set(overlayValue);
  const unioned = unionStrings<unknown>(appendOnly, overlayValue);
  const document: Record<string, unknown> = { ...composed };
  if (Array.isArray(sharedValue)) {
    document[SHARED_SURFACES_KEY] = shared.filter(
      (item) => typeof item !== "string" || !demoted.has(item),
    );
  }
  document[CONFLICT_TOLERANCE_KEY] = {
    ...tolerance,
    [APPEND_ONLY_PATHS_KEY]: unioned,
  };
  return { ok: true, document };
}
