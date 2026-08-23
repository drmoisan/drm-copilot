"use strict";
/** Validate additive receipt bindings for in-flight mutation confirmations. */
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateMutationReceiptBindings = validateMutationReceiptBindings;
const parallel_state_shared_1 = require("./parallel-state-shared");
const RECEIPTS_KEY = "mutation_receipts";
const RECEIPT_FIELDS = [
    "mutation_index",
    "receipt_path",
    "operation",
    "item_key",
    "worktree_identity",
    "confirmation_token",
];
const CONFIRMED_DISPOSITIONS = new Set(["detach", "abandon"]);
/** Return object-shaped entries in their persisted order. */
function objectEntries(value) {
    return Array.isArray(value) ? value.filter(parallel_state_shared_1.isObject) : [];
}
/** Index structurally readable checkpoint items by positive issue number. */
function itemRecords(state) {
    const records = new Map();
    for (const item of objectEntries(state["items"])) {
        const key = item["issue_num"];
        if (typeof key === "number" &&
            (0, parallel_state_shared_1.isPositiveInteger)(key) &&
            !records.has(key)) {
            records.set(key, item);
        }
    }
    return records;
}
/** Render one stable receipt-scoped diagnostic. */
function receiptError(context, position, detail) {
    return `${context} mutation_receipts[${position}] ${detail}`;
}
/** Require the complete additive receipt-reference field set. */
function validateReceiptShape(receipt, position, context) {
    const errors = [];
    for (const field of RECEIPT_FIELDS) {
        if (!(field in receipt)) {
            errors.push(receiptError(context, position, `is missing field: ${field}.`));
        }
    }
    const path = receipt["receipt_path"];
    if ("receipt_path" in receipt &&
        (typeof path !== "string" || path.trim().length === 0)) {
        errors.push(receiptError(context, position, "receipt_path must be a non-empty string."));
    }
    return errors;
}
/** Index the first structurally usable receipt for each mutation position. */
function receiptsByMutationIndex(receipts) {
    const indexed = new Map();
    receipts.forEach((receipt, position) => {
        const index = receipt["mutation_index"];
        if (typeof index === "number" &&
            Number.isInteger(index) &&
            index >= 0 &&
            !indexed.has(index)) {
            indexed.set(index, [position, receipt]);
        }
    });
    return indexed;
}
/** Validate one exact detach/abandon confirmation tuple. */
function validateBinding(receipt, receiptPosition, item, itemKey, disposition, context) {
    const errors = [];
    if (receipt["operation"] !== disposition) {
        errors.push(receiptError(context, receiptPosition, `operation must match disposition ${(0, parallel_state_shared_1.pythonRepr)(disposition)}; found: ${(0, parallel_state_shared_1.pythonRepr)(receipt["operation"])}.`));
    }
    if (receipt["item_key"] !== itemKey) {
        errors.push(receiptError(context, receiptPosition, `item_key must match mutation item ${itemKey}; found: ${(0, parallel_state_shared_1.pythonRepr)(receipt["item_key"])}.`));
    }
    const expectedWorktree = item?.["worktree_identity"];
    if (receipt["worktree_identity"] !== expectedWorktree) {
        errors.push(receiptError(context, receiptPosition, `worktree_identity must match item ${itemKey}; found: ${(0, parallel_state_shared_1.pythonRepr)(receipt["worktree_identity"])}.`));
    }
    const expectedToken = `confirm:${disposition}:${itemKey}:${String(expectedWorktree)}`;
    if (receipt["confirmation_token"] !== expectedToken) {
        errors.push(receiptError(context, receiptPosition, `token must equal ${(0, parallel_state_shared_1.pythonRepr)(expectedToken)}; found: ${(0, parallel_state_shared_1.pythonRepr)(receipt["confirmation_token"])}.`));
    }
    return errors;
}
/** Return ordered diagnostics for the optional receipt-bound mutation mode. */
function validateMutationReceiptBindings(state, context) {
    if (!(RECEIPTS_KEY in state)) {
        return [];
    }
    const receiptValue = state[RECEIPTS_KEY];
    if (!Array.isArray(receiptValue)) {
        return [`${context} mutation_receipts must be a list.`];
    }
    const receipts = objectEntries(receiptValue);
    const mutations = objectEntries(state["mutations"]);
    const errors = receipts.flatMap((receipt, position) => validateReceiptShape(receipt, position, context));
    const indexedReceipts = receiptsByMutationIndex(receipts);
    const items = itemRecords(state);
    mutations.forEach((mutation, mutationIndex) => {
        const disposition = mutation["disposition"];
        const itemKey = mutation["item_key"];
        if (mutation["op"] !== "remove" ||
            mutation["prior_state"] !== "in_flight" ||
            typeof disposition !== "string" ||
            !CONFIRMED_DISPOSITIONS.has(disposition) ||
            typeof itemKey !== "number" ||
            !(0, parallel_state_shared_1.isPositiveInteger)(itemKey)) {
            return;
        }
        const binding = indexedReceipts.get(mutationIndex);
        if (binding === undefined) {
            errors.push(`${context} mutations[${mutationIndex}] ${disposition} removal of item ${itemKey} requires one matching mutation_receipts[] entry.`);
            return;
        }
        const [receiptPosition, receipt] = binding;
        errors.push(...validateBinding(receipt, receiptPosition, items.get(itemKey), itemKey, disposition, context));
    });
    return errors;
}
