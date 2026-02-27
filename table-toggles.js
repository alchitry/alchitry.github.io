// table-toggles.js
function setOptionalVisibility(tableEl, show) {
    tableEl.dataset.showOptional = show ? "1" : "0";
}

async function initOptionalColumnToggles() {
    // Wait for DOM
    if (document.readyState === "loading") {
        await new Promise((resolve) =>
            document.addEventListener("DOMContentLoaded", resolve, { once: true })
        );
    }

    // Wait until md-switch is defined (prevents timing issues)
    if (window.customElements?.whenDefined) {
        await customElements.whenDefined("md-switch");
    }

    const switches = document.querySelectorAll("md-switch[data-optional-group]");

    switches.forEach((sw) => {
        const group = sw.getAttribute("data-optional-group");
        if (!group) return;

        const tables = Array.from(
            document.querySelectorAll(`table[data-optional-group="${CSS.escape(group)}"]`)
        );

        if (tables.length === 0) return;

        // Initial sync: if ANY table has an explicit state, use that; otherwise use the switch.
        const existing = tables
            .map((t) => t.dataset.showOptional)
            .find((v) => v === "0" || v === "1");

        if (existing) {
            sw.selected = existing === "1";
        }

        // Apply state to all tables
        const apply = () => {
            tables.forEach((t) => setOptionalVisibility(t, sw.selected));
        };

        apply();

        sw.addEventListener("input", apply);
    });
}

initOptionalColumnToggles();