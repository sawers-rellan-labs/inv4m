---
name: svg-layout
description: SVG-first figure layout iteration. Use when aligning ggplot/cowplot labels, margins, font sizes, or multi-panel elements.
argument-hint: [figure-name]
---

# SVG-First Figure Layout Iteration

When iterating on ggplot/cowplot figure layout (label positions, margins, font sizes, element alignment):

## Core workflow

1. **Check data size for choosing the SVG to be saved**: If `nrow(ggplot_input_df) > 500`, work on a skeleton version — exclude `geom_point()` layers. If ≤ 500, iterate on the full plot directly.
2. **Save SVGs from R code.** Read the SVG as text to extract exact element coordinates — this is cheap (text grep, no image tokens). Save PNG only for final visual verification or when the user needs to review. Avoid reading PNGs as images during alignment iteration.
3. **Read SVG programmatically** — grep for element positions (`x`, `y` attributes on `<text>`, `<polyline>`, `<polygon>`, `<line>` elements). Compare coordinates numerically against target positions or reference elements (grid lines, tick marks, clip regions).
4. **Derive coordinate mappings** using the spike-in calibration technique (see below). For simple cases where you only need to locate existing elements (colors, gridlines), grep is sufficient.
5. **Adjust R code** using SVG coordinate math (e.g., `y_npc = 1 - svg_y / canvas_height`). Make targeted edits — change one set of related positions at a time.
6. **Repeat steps 2-5** until SVG element positions match the design reference numerically.
7. **Only after skeleton alignment is confirmed**, save the full figure with data points as PNG to verify legibility and check for text/data overlap.

## Spike-in SVG Calibration

The primary technique for mapping data coordinates to NPC positions in `ggdraw()` overlays. Works for both single-panel and multi-panel composites.

### Problem

`ggdraw()` NPC (0–1) ≠ SVG pixels / canvas_width. Subplots undergo viewport transforms from margins, `draw_plot()` offsets, and `plot_grid()` layout. Manually computing these transforms is unreliable.

### Solution: Invisible spike labels

Inject two invisible text labels at known data coordinates inside the plot. The SVG renderer writes their final pixel positions, which encode the full viewport transform. A linear fit gives exact data→NPC mapping functions.

#### Step 1: Inject spikes on a diagonal

Place two `annotate("text")` calls at known data coordinates **on a diagonal** (different x AND y) inside the target subplot:

```r
set.seed(42)
spike_id_a <- paste0("XK", paste0(sample(c(0:9, letters[1:6]), 12, replace = TRUE), collapse = ""))
spike_id_b <- paste0("XK", paste0(sample(c(0:9, letters[1:6]), 12, replace = TRUE), collapse = ""))

p <- ggplot(df, aes(x, y)) +
  geom_point() +
  annotate("text", x = 10, y = 2,  label = spike_id_a, alpha = 0, size = 1) +
  annotate("text", x = 90, y = 18, label = spike_id_b, alpha = 0, size = 1)
```

- `alpha = 0` makes them invisible but svglite still writes them to the SVG
- Random hex IDs prevent collisions with real SVG content
- `set.seed()` makes IDs reproducible across knits
- Choose spike coordinates well inside the data range to avoid clipping

#### Step 2: Save a skeleton SVG

```r
ggsave("skeleton.svg", plot = p, width = 9, height = 6,
       device = "svg", fix_text_size = TRUE)
```

For composites, save the full `ggdraw()` assembly (without overlay annotations):

```r
plot_base <- ggdraw() +
  draw_plot(main_plot, ...) +
  draw_plot(inset_with_spikes, ...)

ggsave("skeleton.svg", plot = plot_base, width = 18, height = 8,
       device = "svg", fix_text_size = TRUE)
```

#### Step 3: Parse spike positions from SVG

```r
svg_lines <- readLines("skeleton.svg")

extract_spike <- function(lines, label) {
  idx <- grep(label, lines, fixed = TRUE)
  stopifnot(length(idx) == 1)
  line <- lines[idx]
  sx <- as.numeric(sub(".*x='([^']+)'.*", "\\1", line))
  sy <- as.numeric(sub(".*y='([^']+)'.*", "\\1", line))
  c(x = sx, y = sy)
}

spike_a <- extract_spike(svg_lines, spike_id_a)
spike_b <- extract_spike(svg_lines, spike_id_b)

# Get canvas dimensions from viewBox
svg_header <- svg_lines[grep("viewBox", svg_lines)[1]]
svg_W <- as.numeric(sub(".*viewBox='0 0 ([0-9.]+) ([0-9.]+)'.*", "\\1", svg_header))
svg_H <- as.numeric(sub(".*viewBox='0 0 ([0-9.]+) ([0-9.]+)'.*", "\\2", svg_header))
```

#### Step 4: Derive linear mapping (data → NPC)

```r
# Known data coordinates of the two spikes
data_a_x <- 10;  data_a_y <- 2
data_b_x <- 90;  data_b_y <- 18

# x: data units → NPC
a_x <- (spike_b["x"] - spike_a["x"]) / (data_b_x - data_a_x)
b_x <- spike_a["x"] - a_x * data_a_x
data_to_npc_x <- function(val) unname(a_x * val + b_x) / svg_W

# y: data units → NPC (SVG y is top-down, NPC is bottom-up)
a_y <- (spike_b["y"] - spike_a["y"]) / (data_b_y - data_a_y)
b_y <- spike_a["y"] - a_y * data_a_y
data_to_npc_y <- function(val) 1 - unname(a_y * val + b_y) / svg_H
```

#### Step 5: Use NPC coordinates in overlay

```r
p_final <- ggdraw() +
  draw_plot(plot_base) +
  draw_line(x = c(data_to_npc_x(25), data_to_npc_x(75)),
            y = c(data_to_npc_y(10), data_to_npc_y(10)), color = "red") +
  draw_label("Region of interest",
             x = data_to_npc_x(50), y = data_to_npc_y(15))
```

### Why it works

The spike labels are rendered **inside the subplot's viewport transform** (margins, `draw_plot()` offsets, `plot_grid()` layout). Their SVG pixel positions reflect the true final position of those data coordinates on the canvas. Dividing by `svg_W`/`svg_H` gives correct NPC because `ggdraw()` maps NPC 0–1 to the full SVG canvas.

### Single-panel case

For a single `ggdraw()` wrapping one plot (no `draw_plot()` offsets, no `plot_grid()`), the technique works identically. The spikes still account for margins, axis label space, and any `coord_*()` transforms that shift the data area within the canvas.

```r
p <- ggplot(df, aes(x, y)) + geom_tile() +
  annotate("text", x = 10, y = 2,  label = spike_id_a, alpha = 0, size = 1) +
  annotate("text", x = 90, y = 18, label = spike_id_b, alpha = 0, size = 1)

# Save, parse, derive mapping — same steps as above
# Then annotate:
ggdraw(p) +
  draw_label("Annotation", x = data_to_npc_x(50), y = data_to_npc_y(10))
```

Use this as a **verification step** even when you think you know the NPC positions — if the spike-derived NPC disagrees with your manual calculation, the spike is right.

### Accuracy

Sub-pixel (< 0.05 px) across all tested boundaries. Fully automatic — recalibrates on every knit. No manual clip-path extraction, no viewport offset arithmetic.

### Recalibration

When layout changes (margins, `rel_heights`, `draw_plot()` position, canvas size):

1. Re-knit the skeleton SVG
2. The `extract_spike` → linear fit code re-derives the mapping automatically
3. All `data_to_npc_x()`/`data_to_npc_y()` calls update with zero manual intervention

No need to re-grep for clip paths, gridlines, or colored elements — the spikes encode the full transform.

## SVG coordinate table — supplementary technique

For elements **not tied to data coordinates** (panel boundaries, colored features, gridlines), grep the SVG directly. Store positions in a centralized table so overlay code derives from the table, not from hardcoded NPC.

```r
svg <- list(W = 648, H = 432, lw = 2.56)  # canvas dims + linewidth in svg units

# Per-panel positions extracted from SVG (keyed by panel ID)
panels <- list(
  Panel1 = list(feat_x = 172.07, feat2_x = 241.30, top_y = 57.75, bot_y = 140.45),
  Panel2 = list(feat_x = 172.07, feat2_x = 242.52, top_y = 170.33, bot_y = 253.03))

# NPC conversion helper
to_npc <- function(sx, sy) list(x = sx / svg$W, y = 1 - sy / svg$H)
```

**Key grep patterns:**
- Colored elements: `grep "#HEX_COLOR" svg_file`
- Gridlines: `grep "EBEBEB" svg_file`
- Text elements: `grep "<text" svg_file`
- Shapes: `grep "polygon\\|polyline" svg_file`

**When to use grep vs spike-in:**
- **Spike-in** — when you need to place annotations at specific data coordinates, or when the plot is inside a composite with viewport transforms
- **Grep** — when you need to locate existing rendered elements (breakpoint lines, panel boundaries) whose data coordinates you don't control

## Data-driven code patterns

### Parameterized panel functions

One function per panel type, taking a panel ID and looking up everything from the coordinate table. Panel-specific behavior (margins, axis visibility) is controlled by parameters, not by duplicating code.

```r
make_panel <- function(panel_id, show_points = FALSE, bot_margin = 15) {
  panel_data <- all_data %>% filter(panel == panel_id)
  # ... build plot using looked-up data
}
```

### Annotation generation by iteration

Define annotations as a list-of-lists, iterate with `lapply`. Adding/removing/reordering panels means editing the data list, not restructuring code.

```r
labels <- list(
  list(name = "A", y = 0.875, extra = "description"),
  list(name = "B", y = 0.614, extra = NULL))

annots <- unlist(lapply(labels, function(g) {
  out <- list(draw_label(g$name, x = x_pos, y = g$y, ...))
  if (!is.null(g$extra)) out <- c(out, list(draw_label(g$extra, ...)))
  out
}), recursive = FALSE)
```

### Relationship-driven inter-panel elements

Define panel-pair relationships as data, iterate to generate connecting elements. Endpoints are looked up from the coordinate table.

```r
pairs <- list(
  list(top = "Panel1", bot = "Panel2", type = "parallel"),
  list(top = "Panel2", bot = "Panel3", type = "crossing"))

connections <- unlist(lapply(pairs, function(pr) {
  tv <- panels[[pr$top]]; bv <- panels[[pr$bot]]
  y1 <- 1 - tv$bot_y / svg$H
  y2 <- 1 - bv$top_y / svg$H
  # ... generate elements based on pr$type
}), recursive = FALSE)
```

### Shape vertex computation from the table

For overlay shapes (arrows, brackets, polygons), compute vertices from reference points in the coordinate table, not from hardcoded NPC.

```r
make_shape <- function(panel_id, direction) {
  v <- panels[[panel_id]]
  cy <- v$top_y - gap - half_height - svg$lw
  xs <- c(v$feat_x, v$feat_x + offset, v$feat2_x, ...) / svg$W
  ys <- 1 - c(cy, cy + half_height, ...) / svg$H
  draw_grob(grid::polygonGrob(
    x = unit(xs, "npc"), y = unit(ys, "npc"), ...))
}
```

## Overlay element placement

Use `grid::polygonGrob` on the `ggdraw` overlay for elements that need precise positioning independent of the panel stack. This avoids layout coupling.

**Critical rule:** If you remove elements from the `plot_grid` stack, use invisible spacers with the same `rel_heights` to preserve panel geometry. Otherwise all SVG-calibrated coordinates become invalid.

```r
spacer <- ggplot() + theme_void() + theme(plot.margin = margin(0, 10, 0, 10))
plot_grid(spacer, panel1, panel2, spacer,
          ncol = 1, rel_heights = c(0.15, 1, 1, 0.15))
```

## Assembly as composition

The final figure is assembled by composing independent layers. Each layer is generated from the coordinate table independently.

```r
p <- ggdraw() + draw_plot(stack, ...)
for (a in annotations) p <- p + a
for (a in connections) p <- p + a
p + shape_1 + shape_2
```

## Useful ggplot/cowplot techniques

**Hiding native axis text for overlay replacement:**
Set native text to white (`element_text(color = "white")`) to keep spacing intact, then add overlay labels at SVG-derived positions with `draw_label()`. Match the original color (e.g., `#4D4D4D` for ggplot default axis gray).

**Mixed-format text in a single label:**
Use `gridtext::richtext_grob` with markdown: `"plain *italic*"`. Set `box_gp = grid::gpar(col = NA, fill = NA)` to hide the text box border. Note: CSS properties like `-webkit-text-stroke` do NOT render in R graphics devices.

**Linewidth conversion:**
ggplot `linewidth = 1.2` renders as `stroke-width ≈ 2.56` in SVG (at 648×432 canvas). Convert to NPC for consistent spacing: `lw_npc = stroke_width / canvas_height`.

**Always use `fix_text_size = TRUE` when saving SVGs:**
Without this, `ggsave` writes `textLength` and `lengthAdjust='spacingAndGlyphs'` attributes that distort text when the SVG is scaled or edited in Inkscape. Always pass `fix_text_size = TRUE` to `ggsave()` for SVG output.

```r
ggsave("figure.svg", plot = p, width = 9, height = 6,
       device = "svg", fix_text_size = TRUE)
```
