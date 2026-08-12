/**
 * Validate additive per-item PR, CI, merge, and worktree-removal receipts.
 */

type JsonRecord = Record<string, unknown>;

const COMPLETION_RECEIPT_FIELDS = [
  "pr_number",
  "pr_url",
  "pr_base_branch",
  "pr_head_branch",
  "pr_head_sha",
  "pr_state",
  "checks_head_sha",
  "checks_conclusion",
  "merged_at",
  "merge_commit_sha",
  "merge_receipt_path",
  "worktree_removed_at",
  "worktree_removal_receipt_path",
  "completion_receipt_path",
] as const;

const SHA_PATTERN = /^[0-9a-fA-F]{40}$/u;
const WINDOWS_DRIVE_PATTERN = /^[A-Za-z]:\//u;

function isRecord(value: unknown): value is JsonRecord {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function mappingItems(state: JsonRecord): JsonRecord[] {
  const value = state["items"];
  if (!Array.isArray(value)) {
    return [];
  }
  return value.filter(isRecord);
}

function receiptMode(items: JsonRecord[]): boolean {
  return items.some((item) =>
    COMPLETION_RECEIPT_FIELDS.some((field) => field in item),
  );
}

function nonEmptyText(value: unknown): value is string {
  return typeof value === "string" && value.trim().length > 0;
}

function isSha(value: unknown): value is string {
  return typeof value === "string" && SHA_PATTERN.test(value);
}

function isRepositoryRelativePath(value: unknown): value is string {
  if (
    !nonEmptyText(value) ||
    value.includes("\\") ||
    value.startsWith("/") ||
    WINDOWS_DRIVE_PATTERN.test(value)
  ) {
    return false;
  }
  return !value.split("/").includes("..");
}

function itemError(context: string, index: number, detail: string): string {
  return `${context} items[${index}] completion receipt ${detail}.`;
}

function validatePrBinding(
  item: JsonRecord,
  context: string,
  index: number,
): string[] {
  const errors: string[] = [];
  const prNumber = item["pr_number"];
  if (
    typeof prNumber !== "number" ||
    !Number.isInteger(prNumber) ||
    prNumber <= 0
  ) {
    errors.push(itemError(context, index, "pr_number must be positive"));
  }
  if (!nonEmptyText(item["pr_url"])) {
    errors.push(itemError(context, index, "pr_url must be a non-empty string"));
  }
  if (item["pr_base_branch"] !== "main") {
    errors.push(itemError(context, index, "PR base branch must be 'main'"));
  }

  const branchName = item["branch_name"];
  if (!nonEmptyText(branchName)) {
    errors.push(
      itemError(context, index, "branch_name must be a non-empty string"),
    );
  }
  if (item["pr_head_branch"] !== branchName) {
    errors.push(
      itemError(context, index, "PR head branch must match branch_name"),
    );
  }

  const checkedHead = item["checked_head"];
  const prHead = item["pr_head_sha"];
  if (!isSha(checkedHead)) {
    errors.push(
      itemError(context, index, "checked_head must be a 40-character SHA"),
    );
  }
  if (!isSha(prHead)) {
    errors.push(
      itemError(context, index, "pr_head_sha must be a 40-character SHA"),
    );
  } else if (prHead !== checkedHead) {
    errors.push(
      itemError(context, index, "PR head SHA must match checked_head"),
    );
  }
  return errors;
}

function validateCheckBinding(
  item: JsonRecord,
  context: string,
  index: number,
): string[] {
  const errors: string[] = [];
  const checksHead = item["checks_head_sha"];
  const prHead = item["pr_head_sha"];
  if (!isSha(checksHead)) {
    errors.push(
      itemError(context, index, "checks_head_sha must be a 40-character SHA"),
    );
  } else if (checksHead !== prHead) {
    errors.push(
      itemError(context, index, "checks head SHA must match pr_head_sha"),
    );
  }
  if (item["checks_conclusion"] !== "success") {
    errors.push(
      itemError(context, index, "required checks conclusion must be 'success'"),
    );
  }
  return errors;
}

function validateMergeAndRemoval(
  item: JsonRecord,
  context: string,
  index: number,
): string[] {
  const errors: string[] = [];
  if (item["pr_state"] !== "MERGED") {
    errors.push(itemError(context, index, "PR state must be 'MERGED'"));
  }
  if (!nonEmptyText(item["merged_at"])) {
    errors.push(
      itemError(context, index, "merged_at must be a non-empty string"),
    );
  }
  if (!isSha(item["merge_commit_sha"])) {
    errors.push(
      itemError(context, index, "merge_commit_sha must be a 40-character SHA"),
    );
  }
  if (!isRepositoryRelativePath(item["merge_receipt_path"])) {
    errors.push(
      itemError(
        context,
        index,
        "merge_receipt_path must be repository-relative",
      ),
    );
  }
  if (item["merge_status"] !== "worktree_removed") {
    errors.push(
      itemError(context, index, "merge_status must be 'worktree_removed'"),
    );
  }
  if (!nonEmptyText(item["worktree_removed_at"])) {
    errors.push(
      itemError(
        context,
        index,
        "worktree_removed_at must be a non-empty string",
      ),
    );
  }
  if (!isRepositoryRelativePath(item["worktree_removal_receipt_path"])) {
    errors.push(
      itemError(
        context,
        index,
        "worktree_removal_receipt_path must be repository-relative",
      ),
    );
  }
  if (!isRepositoryRelativePath(item["completion_receipt_path"])) {
    errors.push(
      itemError(
        context,
        index,
        "completion_receipt_path must be repository-relative",
      ),
    );
  }
  return errors;
}

/**
 * Validate terminal per-item receipts when any completion receipt field exists.
 *
 * @param state Parsed parallel-orchestrator checkpoint.
 * @param context Stable diagnostic prefix.
 * @returns Ordered receipt validation diagnostics.
 */
export function validateCompletionReceipts(
  state: JsonRecord,
  context: string,
): string[] {
  const items = mappingItems(state);
  if (!receiptMode(items)) {
    return [];
  }

  const errors: string[] = [];
  const prOwners = new Map<number, number>();
  const duplicatePrNumbers = new Set<number>();
  items.forEach((item, index) => {
    if (item["state"] === "withdrawn") {
      return;
    }
    errors.push(...validatePrBinding(item, context, index));
    errors.push(...validateCheckBinding(item, context, index));
    errors.push(...validateMergeAndRemoval(item, context, index));

    const prNumber = item["pr_number"];
    if (
      typeof prNumber === "number" &&
      Number.isInteger(prNumber) &&
      prNumber > 0
    ) {
      if (prOwners.has(prNumber)) {
        duplicatePrNumbers.add(prNumber);
      } else {
        prOwners.set(prNumber, index);
      }
    }
  });

  for (const prNumber of [...duplicatePrNumbers].sort(
    (left, right) => left - right,
  )) {
    errors.push(
      `${context} completion receipts assign PR ${prNumber} to multiple items.`,
    );
  }
  return errors;
}
