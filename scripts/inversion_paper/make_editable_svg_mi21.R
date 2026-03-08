library(here)
library(dplyr)
library(ggplot2)
library(scales)
library(cowplot)

source(here("scripts", "utils", "setup_paths.R"))
paths <- setup_project_paths("inversion_paper")

# =============================================================================
# Data loading
# =============================================================================
blastcols <- c("qseqid", "sseqid", "pident", "length", "mismatch",
               "gapopen", "qstart", "qend", "sstart", "send",
               "evalue", "bitscore")
genomes_all <- c("TIL18", "PT", "Mi21", "B73")

read_blast <- function(rep_label, prefix) {
  files <- setNames(
    file.path(paths$intermediate, paste0(prefix, "_", genomes_all, ".blast")),
    genomes_all)
  lapply(genomes_all, function(g) {
    blast <- read.table(files[g], sep = "\t", header = FALSE,
      col.names = blastcols,
      colClasses = c(qseqid = "character", sseqid = "character"))
    blast$genome <- g
    blast
  }) %>% bind_rows() %>%
    mutate(bitscaled = rescale(bitscore, to = c(0, 100)), rep = rep_label)
}

to_plot <- bind_rows(
  read_blast("knob180", "knob180"),
  read_blast("TR-1", "TR-1")
) %>% mutate(genome = factor(genome, levels = genomes_all), rep = factor(rep))

# =============================================================================
# Breakpoints & alignment (all genomes aligned to B73 upstream)
# =============================================================================
bp_all <- data.frame(
  genome = c("TIL18","TIL18","PT","PT","B73","B73","Mi21","Mi21"),
  side   = rep(c("upstream","downstream"), 4),
  xpos   = c(180365316, 193570651, 173486186, 186925483,
             172882309, 188131461, 156752504, 167621035),
  stringsAsFactors = FALSE)

b73_upstream <- 172882309
offsets <- bp_all %>% filter(side == "upstream") %>%
  mutate(offset = b73_upstream - xpos) %>% select(genome, offset)
bp_aligned <- bp_all %>% left_join(offsets, by = "genome") %>%
  mutate(xpos_aligned = xpos + offset)
to_plot <- to_plot %>% left_join(offsets, by = "genome") %>%
  mutate(sstart_aligned = sstart + offset)

# Midlines: mean repeat position between breakpoints per genome
midlines <- lapply(unique(bp_all$genome), function(g) {
  bps <- bp_all$xpos[bp_all$genome == g]
  hits <- to_plot %>% filter(genome == g,
    sstart >= min(bps) + 1e6, sstart <= max(bps) - 1e6)
  if (nrow(hits) == 0) return(NULL)
  data.frame(genome = g,
    xmid_aligned = mean(hits$sstart) + offsets$offset[offsets$genome == g])
}) %>% bind_rows()

# =============================================================================
# Colors, sizes, axis config
# =============================================================================
col_inv4m <- "purple4"
col_knob  <- "#1d7f7a"
col_gold  <- "gold"
col_gray  <- "gray50"
lw        <- 1.2          # universal linewidth for vlines + connections

cfg <- list(
  genomes = c("TIL18", "Mi21", "B73"),
  xlim    = c(163e6, 250e6),
  xbreaks = seq(175e6, 250e6, by = 25e6))

# =============================================================================
# SVG coordinate table (648x432 canvas, ground truth from rendered output)
# NPC conversions: x_npc = svg_x / 648,  y_npc = 1 - svg_y / 432
# =============================================================================
svg <- list(W = 648, H = 432, lw = 2.56)  # canvas dims + linewidth in svg units

# Purple breakpoint vlines per panel: svg_x for upstream/downstream, svg_y range
# Y coordinates are identical to PT version (same cowplot layout)
# Mi21 x-coords calibrated from first-pass SVG render
vlines <- list(
  TIL18 = list(up_x = 172.07, dn_x = 241.30, top_y = 57.75,  bot_y = 140.45),
  Mi21  = list(up_x = 172.07, dn_x = 229.05, top_y = 170.33, bot_y = 253.03),
  B73   = list(up_x = 172.07, dn_x = 252.01, top_y = 282.91, bot_y = 354.59))

# Gray midlines per panel: svg_x
mid_x <- list(TIL18 = 190.90, Mi21 = 192.47, B73 = 231.98)

# X-axis tick positions: svg_x for each break value
xtick_x <- c("175" = 183.17, "200" = 314.23, "225" = 445.29, "250" = 576.35)

# NPC helper
to_npc <- function(sx, sy) list(x = sx / svg$W, y = 1 - sy / svg$H)

# =============================================================================
# Panel function
# =============================================================================
make_panel <- function(genome_id, show_points = FALSE, bot_margin = 15) {
  gbp  <- bp_aligned %>% filter(genome == genome_id)
  gmid <- midlines %>% filter(genome == genome_id)
  gdat <- to_plot %>% filter(genome == genome_id)

  p <- ggplot() +
    geom_hline(yintercept = 0, color = "gray70", linewidth = 0.4) +
    { if (nrow(gmid) > 0)
        geom_vline(xintercept = gmid$xmid_aligned,
                   color = "gray55", linewidth = lw) } +
    geom_vline(data = gbp, aes(xintercept = xpos_aligned),
               color = col_inv4m, linewidth = lw) +
    { if (show_points)
        geom_point(data = gdat, aes(x = sstart_aligned, y = bitscaled, color = rep),
                   size = 1.2, alpha = 0.7) } +
    { if (show_points)
        scale_color_manual(values = c("knob180" = col_knob, "TR-1" = col_gold),
                           guide = "none") } +
    scale_x_continuous(labels = unit_format(unit = "", scale = 1e-6),
                       breaks = cfg$xbreaks) +
    scale_y_continuous(breaks = c(0, 25, 50, 75, 100), limits = c(-5, 105)) +
    coord_cartesian(xlim = cfg$xlim) +
    theme_minimal(base_size = 20) +
    theme(panel.grid.minor = element_blank(),
          plot.margin = margin(t = 15, r = 10, b = bot_margin, l = 10),
          axis.title = element_blank(),
          axis.ticks.x = element_blank(),
          axis.text.x = element_text(color = "white"))

  if (genome_id != "B73")
    p <- p + theme(axis.text.x = element_blank())
  p
}

# =============================================================================
# Arrow polygons (polygonGrob overlays, freely positionable)
# =============================================================================
a_h <- 4; a_gap <- 1; a_pt <- 8  # half-height, gap, point size in svg units

make_arrow_grob <- function(panel, direction) {
  v <- vlines[[panel]]
  if (direction == "left") {
    cy <- v$top_y - a_gap - a_h - svg$lw
    # Left-pointing: point at left, body right
    xs <- c(v$up_x,        v$up_x + a_pt, v$dn_x, v$dn_x, v$up_x + a_pt)
    ys <- c(cy,            cy + a_h,       cy + a_h, cy - a_h, cy - a_h)
  } else {
    cy <- v$bot_y + a_gap + a_h + svg$lw
    # Right-pointing: mirror of left — point at right, body left
    xs <- c(v$up_x, v$dn_x - a_pt, v$dn_x,  v$dn_x - a_pt, v$up_x)
    ys <- c(cy + a_h, cy + a_h,     cy,      cy - a_h,       cy - a_h)
  }
  draw_grob(grid::polygonGrob(
    x = unit(xs / svg$W, "npc"), y = unit(1 - ys / svg$H, "npc"),
    gp = grid::gpar(fill = col_inv4m, col = col_inv4m)))
}

arrow_top_grob <- make_arrow_grob("TIL18", "left")
arrow_bot_grob <- make_arrow_grob("B73", "right")

# =============================================================================
# Sigmoid + connection line helpers
# =============================================================================
sigmoid_path <- function(x1, y1, x2, y2, n = 50) {
  t <- seq(-6, 6, length.out = n)
  s <- 1 / (1 + exp(-t))
  data.frame(x = x1 + (x2 - x1) * s,
             y = y1 + (y2 - y1) * seq(0, 1, length.out = n))
}

draw_sigmoid <- function(x1, y1, x2, y2, color, lwd = lw) {
  pts <- sigmoid_path(x1, y1, x2, y2)
  draw_plot(
    ggplot(pts, aes(x, y)) +
      geom_path(color = color, linewidth = lwd) +
      scale_x_continuous(limits = c(0, 1), expand = c(0, 0)) +
      scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +
      theme_void(),
    x = 0, y = 0, width = 1, height = 1)
}

# =============================================================================
# Inter-panel connection lines (built from SVG coordinate table)
# =============================================================================
# Panel pairs: top → bottom
pairs <- list(
  list(top = "TIL18", bot = "Mi21", inverted = FALSE),  # both inverted, no crossing
  list(top = "Mi21",  bot = "B73",  inverted = TRUE))    # Mi21 inverted vs B73 standard

crossing_lines <- unlist(lapply(pairs, function(pr) {
  tv <- vlines[[pr$top]]; bv <- vlines[[pr$bot]]
  tm <- mid_x[[pr$top]]; bm <- mid_x[[pr$bot]]

  # NPC endpoints
  y1 <- 1 - tv$bot_y / svg$H  # top panel bottom
  y2 <- 1 - bv$top_y / svg$H  # bottom panel top

  t_up <- tv$up_x / svg$W; t_dn <- tv$dn_x / svg$W
  b_up <- bv$up_x / svg$W; b_dn <- bv$dn_x / svg$W

  if (pr$inverted) {
    # Sigmoid crossing: upstream↔downstream
    list(
      draw_sigmoid(tm / svg$W, y1, bm / svg$W, y2, color = "gray55"),
      draw_sigmoid(t_up, y1, b_dn, y2, color = col_inv4m),
      draw_sigmoid(t_dn, y1, b_up, y2, color = col_inv4m))
  } else {
    # Straight parallel lines
    list(
      draw_line(x = c(tm / svg$W, bm / svg$W), y = c(y1, y2),
                color = "gray55", size = lw),
      draw_line(x = c(t_up, b_up), y = c(y1, y2),
                color = col_inv4m, size = lw),
      draw_line(x = c(t_dn, b_dn), y = c(y1, y2),
                color = col_inv4m, size = lw))
  }
}), recursive = FALSE)

# =============================================================================
# Overlay text annotations
# =============================================================================
sz_name    <- 20
sz_species <- 16
y_header   <- 0.955
y_bump     <- 0.02
x_gname    <- 0.54
x_species  <- 0.90

# Genome names + species (data-driven)
genome_labels <- list(
  list(name = "TIL18", y = 0.875 + y_bump,
       species_html = "teosinte *mexicana*"),
  list(name = "Mi21",  y = 0.6144 + y_bump,
       species_html = "BC<sub>2</sub>S<sub>4</sub> NIL"),
  list(name = "B73",   y = 0.3539 + y_bump,
       species_text = NULL))

genome_annots <- unlist(lapply(genome_labels, function(g) {
  out <- list(draw_label(g$name, x = x_gname, y = g$y,
                         size = sz_name, fontface = "bold"))
  if (!is.null(g$species_html))
    out <- c(out, list(draw_grob(gridtext::richtext_grob(
      g$species_html,
      x = unit(x_species, "npc"), y = unit(g$y, "npc"),
      hjust = 1, gp = grid::gpar(fontsize = sz_species, col = col_gray),
      box_gp = grid::gpar(col = NA, fill = NA)))))
  if (!is.null(g$species_text))
    out <- c(out, list(draw_label(g$species_text, x = x_species, y = g$y,
      size = sz_species, fontface = "plain", color = col_gray, hjust = 1)))
  out
}), recursive = FALSE)

# X-axis tick labels (below bottom arrow, gray)
y_xtick <- 1 - 375 / svg$H
xtick_annots <- lapply(names(xtick_x), function(lab) {
  draw_label(lab, x = xtick_x[lab] / svg$W, y = y_xtick,
             size = 16, color = "#4D4D4D")
})

# Legend dot helper
legend_dot <- function(col, x, y) {
  draw_plot(
    ggplot() + annotate("point", x = 0, y = 0, color = col, size = 4) + theme_void(),
    x = x, y = y, width = 0.02, height = 0.02)
}

overlay_annotations <- c(
  list(
    draw_label("Normalized Repeat Match Score", x = 0.02, y = 0.5,
               angle = 90, size = 20),
    draw_label("Chromosome 4 Position [Mb]", x = 0.50, y = 0.055, size = 20),
    draw_label("A", x = 0.02, y = 0.98, size = 24, fontface = "bold"),
    # Inv4m label flush above top arrow
    draw_label("Inv4m", x = 0.32, y = 0.917, size = sz_name,
               fontface = "bold.italic", color = col_inv4m),
    # Legend: knob 180
    legend_dot(col_knob, 0.55, y_header - 0.012),
    draw_label("knob 180", x = 0.58, y = y_header, size = sz_name,
               fontface = "bold.italic", color = col_knob, hjust = 0),
    # Legend: TR-1 (shadow + gold)
    legend_dot(col_gold, 0.73, y_header - 0.012),
    draw_label("TR-1", x = 0.761, y = y_header - 0.002, size = sz_name,
               fontface = "bold.italic", color = "gray30", hjust = 0),
    draw_label("TR-1", x = 0.76, y = y_header, size = sz_name,
               fontface = "bold.italic", color = col_gold, hjust = 0)),
  genome_annots,
  xtick_annots)

# =============================================================================
# Assembly
# =============================================================================
spacer <- ggplot() + theme_void() + theme(plot.margin = margin(0, 10, 0, 10))

make_final <- function(show_points) {
  stk <- plot_grid(
    spacer,
    make_panel("TIL18", show_points = show_points),
    make_panel("Mi21",  show_points = show_points),
    make_panel("B73",   show_points = show_points, bot_margin = 2),
    spacer,
    ncol = 1, align = "v", axis = "lr",
    rel_heights = c(0.15, 1, 1, 1, 0.15))
  p <- ggdraw() + draw_plot(stk, x = 0.08, y = 0.08, width = 0.86, height = 0.86)
  for (a in overlay_annotations) p <- p + a
  for (a in crossing_lines) p <- p + a
  p + arrow_top_grob + arrow_bot_grob
}

# =============================================================================
# Save
# =============================================================================
outpath_svg <- file.path(paths$figures, "fig1_panel_A_mi21_skeleton.svg")
ggsave(outpath_svg, plot = make_final(FALSE), width = 9, height = 6, device = "svg")

outpath_png <- file.path(paths$figures, "fig1_panel_A_mi21_skeleton.png")
ggsave(outpath_png, plot = make_final(TRUE), width = 9, height = 6, dpi = 300, bg = "white")

cat("Saved SVG:", outpath_svg, "\n")
cat("Saved PNG:", outpath_png, "\n")
