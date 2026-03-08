# SVG Layout Iteration — Generalizations from Code Simplification

Patterns learned from refactoring `make_editable_svg.R` (Figure 1 Panel A) from ~320 lines of scattered variables to ~320 lines of data-driven code with the same output.

## 1. Everything derives from the coordinate table

The SVG coordinate table is not just a reference — it is the **single source of truth** for all overlay positioning. Every overlay element (arrows, labels, connections) should compute its position from the table, never from hardcoded NPC values.

**Before (scattered):**
```r
arrow_x1 <- 0.265; arrow_x2 <- 0.372; arrow_y <- 0.87
label_x <- 0.32; label_y <- 0.917
```

**After (derived):**
```r
v <- vlines[["TIL18"]]
cy <- v$top_y - a_gap - a_h - svg$lw
xs <- c(v$up_x, v$up_x + a_pt, v$dn_x, ...) / svg$W  # NPC from table
```

**Why it matters:** When the layout changes (margins, inset size, canvas dimensions), you re-extract SVG coordinates into the table once. All downstream code adjusts automatically.

## 2. Parameterized panel functions with table lookup

Instead of writing separate code per panel, write one panel function that takes a panel ID and looks up everything from the coordinate table.

```r
make_panel <- function(panel_id, show_points = FALSE, bot_margin = 15) {
  gbp  <- bp_aligned %>% filter(genome == panel_id)
  gmid <- midlines %>% filter(genome == panel_id)
  gdat <- to_plot %>% filter(genome == panel_id)
  # ... build plot using looked-up data
}
```

All panel-specific behavior (different margins, axis visibility) is controlled by parameters, not by duplicating the function.

## 3. Data-driven annotation generation

Define annotations as a list-of-lists, then iterate with `lapply` to generate all overlay elements. This eliminates duplicated `draw_label()` / `draw_grob()` calls.

```r
labels <- list(
  list(name = "Panel1", y = 0.875, species = "description *italic*"),
  list(name = "Panel2", y = 0.614, species = "description plain"),
  list(name = "Panel3", y = 0.354, species = NULL))

annots <- unlist(lapply(labels, function(g) {
  out <- list(draw_label(g$name, x = x_pos, y = g$y, ...))
  if (!is.null(g$species))
    out <- c(out, list(draw_label(g$species, ...)))
  out
}), recursive = FALSE)
```

**Key benefit:** Adding/removing/reordering panels means editing the data list, not restructuring code.

## 4. Relationship-driven inter-panel elements

Define panel-pair relationships as data, then iterate to generate all connecting elements (lines, curves, etc.) between panels.

```r
pairs <- list(
  list(top = "Panel1", bot = "Panel2", type = "parallel"),
  list(top = "Panel2", bot = "Panel3", type = "crossing"))

connections <- unlist(lapply(pairs, function(pr) {
  tv <- vlines[[pr$top]]; bv <- vlines[[pr$bot]]
  y1 <- 1 - tv$bot_y / svg$H   # top panel bottom edge
  y2 <- 1 - bv$top_y / svg$H   # bottom panel top edge
  # ... generate connection elements based on pr$type
}), recursive = FALSE)
```

The specific rendering (straight lines, curves, ribbons) varies per figure, but the **pattern** of iterating over pair definitions and looking up endpoints from the coordinate table is universal.

## 5. Shape vertex computation from the coordinate table

For arbitrary overlay shapes (arrows, brackets, polygons), compute vertex coordinates from the SVG coordinate table rather than hardcoding NPC positions. Define shape geometry in terms of offsets from known reference points.

```r
make_shape_grob <- function(panel, direction) {
  v <- vlines[[panel]]
  # Compute center from panel edge + offset
  cy <- v$top_y - gap - half_height - svg$lw
  # Define vertices relative to vline positions
  xs <- c(v$up_x, v$up_x + point_size, v$dn_x, ...)
  ys <- c(cy, cy + half_height, cy + half_height, ...)
  draw_grob(grid::polygonGrob(
    x = unit(xs / svg$W, "npc"),
    y = unit(1 - ys / svg$H, "npc"), ...))
}
```

## 6. Assembly as composition

The final figure is assembled by composing independent layers:

```r
p <- ggdraw() + draw_plot(stack, ...)
for (a in overlay_annotations) p <- p + a   # text labels
for (a in connections) p <- p + a            # inter-panel lines
p + shape_grob_1 + shape_grob_2             # overlay shapes
```

Each layer (annotations, connections, shapes) is generated independently from the coordinate table. Adding or removing a layer doesn't affect the others.

## 7. Recalibration cycle

When you change something that affects panel geometry (margins, rel_heights, inset position):

1. Save SVG with new layout
2. Re-extract all coordinates into the table (grep by color/element type)
3. All derived positions update automatically
4. Verify with SVG read, not PNG

This is fast because only step 2 requires manual coordinate extraction. Steps 3-4 are automatic if the code follows patterns 1-6.
