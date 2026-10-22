import {
  normalizeOptionalText,
  normalizeRequiredText,
  normalizeWorkspaceRoot,
  validateChoice,
} from "./workflow-command-arguments";
import type { DiscoveryWorkspaceInput } from "./repo-automation-execute-discovery";

/**
 * Argument helpers shared by the discovery input resolvers.
 *
 * Each helper validates one raw MCP field shape (boolean, string list, positive
 * integer, closed enum) or compacts a resolved input so that omitted fields stay
 * absent under `exactOptionalPropertyTypes`. No helper applies a default the
 * service does not own.
 */

/** Validate an optional boolean field. */
export function normalizeOptionalBoolean(
  value: unknown,
  fieldName: string,
): boolean | undefined {
  if (value === undefined) {
    return undefined;
  }
  if (typeof value !== "boolean") {
    throw new Error(`Field '${fieldName}' must be a boolean when provided.`);
  }
  return value;
}

/** Validate an optional array of non-empty strings. */
export function normalizeOptionalStringList(
  value: unknown,
  fieldName: string,
): ReadonlyArray<string> | undefined {
  if (value === undefined) {
    return undefined;
  }
  if (
    !Array.isArray(value) ||
    value.some((item) => typeof item !== "string" || item.trim() === "")
  ) {
    throw new Error(
      `Field '${fieldName}' must be an array of non-empty strings when provided.`,
    );
  }
  return value.map((item: string) => item.trim());
}

/** Validate a required array of non-empty strings. */
export function normalizeRequiredStringList(
  value: unknown,
  fieldName: string,
): ReadonlyArray<string> {
  const list = normalizeOptionalStringList(value, fieldName);
  if (list === undefined) {
    throw new Error(`Field '${fieldName}' is required.`);
  }
  return list;
}

/** Validate an optional positive integer field. */
export function normalizeOptionalInteger(
  value: unknown,
  fieldName: string,
): number | undefined {
  if (value === undefined) {
    return undefined;
  }
  if (typeof value !== "number" || !Number.isInteger(value) || value < 1) {
    throw new Error(
      `Field '${fieldName}' must be a positive integer when provided.`,
    );
  }
  return value;
}

/** Validate an optional closed-enum field. */
export function normalizeOptionalChoice<TChoice extends string>(
  value: unknown,
  fieldName: string,
  choices: ReadonlyArray<TChoice>,
): TChoice | undefined {
  if (value === undefined) {
    return undefined;
  }
  return validateChoice(
    normalizeRequiredText(value, fieldName),
    fieldName,
    choices,
  );
}

/** `T` with every member that may be undefined made optional and narrowed. */
export type Compacted<T> = {
  readonly [K in keyof T as undefined extends T[K] ? never : K]: T[K];
} & {
  readonly [K in keyof T as undefined extends T[K] ? K : never]?: Exclude<
    T[K],
    undefined
  >;
};

/** Omit undefined members so inputs stay minimal and deterministic. */
export function compact<T extends object>(value: T): Compacted<T> {
  return Object.fromEntries(
    Object.entries(value).filter(([, member]) => member !== undefined),
  ) as unknown as Compacted<T>;
}

/** Resolve the fields every discovery tool shares. */
export function resolveDiscoveryWorkspaceInput(
  args: Readonly<Record<string, unknown>>,
  fallbackWorkspaceRoot?: string,
): DiscoveryWorkspaceInput {
  return compact({
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    profilePath: normalizeOptionalText(args["profile_path"], "profile_path"),
  });
}
