// pinout-resizer.js
/**
 * Synchronizes the width of the left and right "outer" columns of pinout tables.
 * This ensures the table is centered and looks balanced.
 */
function equalizeOuterColumns() {
    const pinTables = document.querySelectorAll('.pin-table');

    pinTables.forEach(table => {
        // Skip legend tables
        if (table.closest('.pinout-legend')) return;

        let maxOuterWidth = 0;

        // Reset any previously set widths to get natural width
        const outerCells = table.querySelectorAll('td.outer');
        outerCells.forEach(cell => {
            cell.style.width = '';
            cell.style.minWidth = '';
        });

        // Find the maximum width among all "outer" cells in this table
        outerCells.forEach(cell => {
            const width = cell.getBoundingClientRect().width;
            if (width > maxOuterWidth) {
                maxOuterWidth = width;
            }
        });

        // Apply the max width to all "outer" cells
        if (maxOuterWidth > 0) {
            outerCells.forEach(cell => {
                cell.style.width = `${maxOuterWidth}px`;
            });
        }
    });
}

function initEqualizer() {
    // Initial equalize
    equalizeOuterColumns();

    // Listen to md-switch input events to re-equalize when columns toggle
    const switches = document.querySelectorAll("md-switch[data-optional-group]");
    switches.forEach(sw => {
        sw.addEventListener('input', () => {
            // Delay slightly to allow the toggle to complete
            setTimeout(equalizeOuterColumns, 10);
        });
    });
}

// Run on initial load
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initEqualizer);
} else {
    initEqualizer();
}

// Run on window resize to re-calculate if needed
window.addEventListener('resize', equalizeOuterColumns);
