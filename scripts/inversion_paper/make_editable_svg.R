library(here)
library(dplyr)
library(ggplot2)
library(scales)
library(cowplot)

source(here("scripts", "utils", "setup_paths.R"))
paths <- setup_project_paths("inversion_paper")

# --- Data loading ---
blastcols <- c("qseqid", "sseqid", "pident", "length", "mismatch",
               "gapopen", "qstart", "qend", "sstart", "send",
               "evalue", "bitscore")
genomes_all <- c("TIL18", "PT", "Mi21", "B73")

knob_files <- setNames(
  file.path(paths$intermediate, paste0("knob180_", genomes_all, ".blast")),
  genomes_all)
tr1_files <- setNames(
  file.path(paths$intermediate, paste0("TR-1_", genomes_all, ".blast")),
  genomes_all)

read_blast <- function(files, genomes, rep_label) {
  lapply(genomes, function(g) {
    blast <- read.table(files[g], sep = "\t", header = FALSE,
      col.names = blastcols,
      colClasses = c(qseqid = "character", sseqid = "character"))
    blast$genome <- g
    blast
  }) %>% bind_rows() %>%
    mutate(bitscaled = rescale(bitscore, to = c(0, 100)), rep = rep_label)
}

knob <- read_blast(knob_files, genomes_all, "knob180")
tr1  <- read_blast(tr1_files, genomes_all, "TR-1")
to_plot <- bind_rows(knob, tr1) %>%
  mutate(genome = factor(genome, levels = genomes_all), rep = factor(rep))

# --- Breakpoints & alignment ---
bp_all <- data.frame(
  genome = c("TIL18","TIL18","PT","PT","B73","B73","Mi21","Mi21"),
  side = rep(c("upstream","downstream"), 4),
  xpos = c(180365316,193570651, 173486186,186925483,
           172882309,188131461, 156752504,167621035),
  stringsAsFactors = FALSE)

b73_upstream <- bp_all$xpos[bp_all$genome == "B73" & bp_all$side == "upstream"]
offsets <- bp_all %>% filter(side == "upstream") %>%
  mutate(offset = b73_upstream - xpos) %>% select(genome, offset)
bp_aligned <- bp_all %>% left_join(offsets, by = "genome") %>%
  mutate(xpos_aligned = xpos + offset)
to_plot <- to_plot %>% left_join(offsets, by = "genome") %>%
  mutate(sstart_aligned = sstart + offset)

padding <- 1e6
midlines <- lapply(unique(bp_all$genome), function(g) {
  bps <- bp_all$xpos[bp_all$genome == g]
  bp_lo <- min(bps) + padding; bp_hi <- max(bps) - padding
  hits <- to_plot %>% filter(genome == g, sstart >= bp_lo, sstart <= bp_hi)
  if (nrow(hits) == 0) return(NULL)
  off <- offsets$offset[offsets$genome == g]
  data.frame(genome = g, xmid_aligned = mean(hits$sstart) + off)
}) %>% bind_rows()

# --- Colors & config ---
col_inv4m <- "purple4"
col_knob  <- "#1d7f7a"
col_gold  <- "gold"
col_gray  <- "gray50"

aligned_xlim    <- c(163e6, 250e6)
aligned_xbreaks <- seq(175e6, 250e6, by = 25e6)

cfg <- list(
  genomes = c("TIL18", "PT", "B73"),
  labels  = c(TIL18 = "TIL18", PT = "PT", B73 = "B73"),
  species = c(TIL18 = "teosinte mexicana", PT = "highland maize", B73 = ""),
  xlim = aligned_xlim, xbreaks = aligned_xbreaks)

# --- Pentagon arrow ---
arrow_point <- 1.5e6
make_arrow_df <- function(x_left, x_right, y_center, height, point_size,
                          direction = "right") {
  hh <- height / 2
  if (direction == "right") {
    data.frame(
      x = c(x_left, x_right - point_size, x_right,
            x_right - point_size, x_left),
      y = c(y_center - hh, y_center - hh, y_center,
            y_center + hh, y_center + hh))
  } else {
    data.frame(
      x = c(x_left, x_left + point_size, x_right,
            x_right, x_left + point_size),
      y = c(y_center, y_center - hh, y_center - hh,
            y_center + hh, y_center + hh))
  }
}

# --- Panel function ---
make_panel <- function(genome_id, show_points = FALSE, bot_margin = 15) {
  gbp  <- bp_aligned %>% filter(genome == genome_id)
  gmid <- midlines %>% filter(genome == genome_id)
  gdat <- to_plot %>% filter(genome == genome_id)

  p <- ggplot() +
    geom_hline(yintercept = 0, color = "gray70", linewidth = 0.4) +
    { if (nrow(gmid) > 0)
        geom_vline(xintercept = gmid$xmid_aligned,
                   color = "gray55", linewidth = 1.2) } +
    geom_vline(data = gbp, aes(xintercept = xpos_aligned),
               color = col_inv4m, linewidth = 1.2) +
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


# --- Arrow polygons as overlay grobs (flush against vline endpoints) ---
# SVG coordinates (648x432 canvas): NPC x = svg_x/648, y = 1 - svg_y/432
# TIL18 vlines: x=172.07 (up), x=241.30 (dn); top at svg_y=57.75
# B73   vlines: x=172.07 (up), x=252.01 (dn); bot at svg_y=354.59
a_h   <- 4    # arrow half-height in svg units
a_gap <- 1    # gap from vline endpoint
a_pt  <- 8    # pentagon point size in svg units

# Top arrow (left-pointing): just above TIL18 vline tops + 1 linewidth up
lw_svg <- 2.56  # linewidth 1.2 in svg units
top_cy <- 57.75 - a_gap - a_h - lw_svg
arrow_top_grob <- draw_grob(grid::polygonGrob(
  x = unit(c(172.07, 172.07 + a_pt, 241.30, 241.30, 172.07 + a_pt) / 648, "npc"),
  y = unit(1 - c(top_cy, top_cy + a_h, top_cy + a_h, top_cy - a_h, top_cy - a_h) / 432, "npc"),
  gp = grid::gpar(fill = col_inv4m, col = col_inv4m)
))

# Bottom arrow (right-pointing): just below B73 vline bottoms + 1 linewidth down
bot_cy <- 354.59 + a_gap + a_h + lw_svg
arrow_bot_grob <- draw_grob(grid::polygonGrob(
  x = unit(c(172.07, 252.01 - a_pt, 252.01, 252.01 - a_pt, 172.07) / 648, "npc"),
  y = unit(1 - c(bot_cy + a_h, bot_cy + a_h, bot_cy, bot_cy - a_h, bot_cy - a_h) / 432, "npc"),
  gp = grid::gpar(fill = col_inv4m, col = col_inv4m)
))

# --- Overlay text configuration ---

sz_name    <- 20   # genome names, Inv4m, legend — match base_size=20
sz_species <- 16   # species descriptions — match axis text (base_size * 0.8)

# NPC positions derived from user SVG edits (canvas 648x432, y_npc = 1 - svg_y/432)
# Single header row: Inv4m (left) + legend (right), above top arrow
y_header   <- 0.955

# Genome names: centered on x-axis span; species: right-aligned, same y
# x_center: midpoint of xlim (163-250 Mb) → x_npc(206.5e6) ≈ 0.537
x_gname    <- 0.54   # genome name, centered
x_species  <- 0.90   # species description, right-aligned

# y positions: half a major gridline spacing above 100-line (~0.02 NPC)
# gridline spacing = 17.08 svg units → half = 8.54 → 8.54/432 ≈ 0.02 NPC
y_bump     <- 0.02
y_name1    <- 0.875  + y_bump  # TIL18
y_sp1      <- 0.875  + y_bump  # teosinte mexicana
y_name2    <- 0.6144 + y_bump  # PT
y_sp2      <- 0.6144 + y_bump  # highland maize
y_name3    <- 0.3539 + y_bump  # B73

# x-axis npc positions: derived from tick mark SVG coordinates (ground truth)
# In a 648pt canvas, ticks render at: 175Mb=163.28, 250Mb=575.26
# npc = svg_x / 648
# slope: (575.26 - 163.28) / (250e6 - 175e6) = 411.98 / 75e6 = 5.4931e-6 svg_pt per data unit
# intercept: 163.28 - 5.4931e-6 * 175e6 = 163.28 - 961.29 = -798.01
x_npc <- function(val) (-734.25 + 5.2424e-6 * val) / 648

# --- Overlay annotations (reusable, added after draw_plot) ---
overlay_annotations <- list(
  draw_label("Normalized Repeat Match Score", x = 0.02, y = 0.5,
             angle = 90, size = 20),
  draw_label("Chromosome 4 Position [Mb]", x = 0.50, y = 0.055, size = 20),
  draw_label("A", x = 0.02, y = 0.98, size = 24, fontface = "bold"),
  draw_label("Inv4m", x = 0.32, y = 0.917, size = sz_name,
             fontface = "bold.italic", color = col_inv4m),
  draw_plot(
    ggplot() + annotate("point", x = 0, y = 0, color = col_knob, size = 4) + theme_void(),
    x = 0.55, y = y_header - 0.012, width = 0.02, height = 0.02),
  draw_label("knob 180", x = 0.58, y = y_header, size = sz_name,
             fontface = "bold.italic", color = col_knob, hjust = 0),
  draw_plot(
    ggplot() + annotate("point", x = 0, y = 0, color = col_gold, size = 4) + theme_void(),
    x = 0.73, y = y_header - 0.012, width = 0.02, height = 0.02),
  # TR-1 text: dark shadow layer then gold on top for outline effect
  draw_label("TR-1", x = 0.761, y = y_header - 0.002, size = sz_name,
             fontface = "bold.italic", color = "gray30", hjust = 0),
  draw_label("TR-1", x = 0.76, y = y_header, size = sz_name,
             fontface = "bold.italic", color = col_gold, hjust = 0),
  draw_label("TIL18", x = x_gname, y = y_name1, size = sz_name, fontface = "bold"),
  draw_grob(gridtext::richtext_grob(
    "teosinte *mexicana*",
    x = unit(x_species, "npc"), y = unit(y_sp1, "npc"),
    hjust = 1, gp = grid::gpar(fontsize = sz_species, col = col_gray),
    box_gp = grid::gpar(col = NA, fill = NA))),
  draw_label("PT", x = x_gname, y = y_name2, size = sz_name, fontface = "bold"),
  draw_label("highland maize", x = x_species, y = y_sp2,
             size = sz_species, fontface = "plain", color = col_gray, hjust = 1),
  draw_label("B73", x = x_gname, y = y_name3, size = sz_name, fontface = "bold"),
  # X-axis tick labels: one linewidth below bottom arrow
  # Bottom arrow bottom edge svg_y = 363.59, +2.56 linewidth → svg_y ≈ 366
  # Tick x positions from SVG: 183.17, 314.23, 445.29, 576.35
  draw_label("175", x = 183.17/648, y = 1 - 375/432, size = 16, color = "#4D4D4D"),
  draw_label("200", x = 314.23/648, y = 1 - 375/432, size = 16, color = "#4D4D4D"),
  draw_label("225", x = 445.29/648, y = 1 - 375/432, size = 16, color = "#4D4D4D"),
  draw_label("250", x = 576.35/648, y = 1 - 375/432, size = 16, color = "#4D4D4D")
)

# --- Crossing lines between PT and B73 (inversion indicator) ---
# Coordinates extracted from SVG (648x432 canvas).  NPC: x = svg_x/648, y = 1 - svg_y/432
# PT  purple vlines: x=172.07 (up), x=242.52 (dn); bottom at svg_y=253.03
# B73 purple vlines: x=172.07 (up), x=252.01 (dn); top    at svg_y=282.91
x_pt_up_svg  <- 172.07 / 648
x_pt_dn_svg  <- 242.52 / 648
x_b73_up_svg <- 172.07 / 648
x_b73_dn_svg <- 252.01 / 648
y_pt_bot     <- 1 - 253.03 / 432
y_b73_top    <- 1 - 282.91 / 432

# Gray midlines: x=192.58 (PT), x=231.98 (B73)
x_pt_mid_svg  <- 192.58 / 648
x_b73_mid_svg <- 231.98 / 648

# Sigmoid curve between two NPC points: x shifts with sigmoid, y is linear
sigmoid_path <- function(x1, y1, x2, y2, n = 50) {
  t <- seq(-6, 6, length.out = n)
  s <- 1 / (1 + exp(-t))  # 0→1 smooth transition
  data.frame(
    x = x1 + (x2 - x1) * s,
    y = y1 + (y2 - y1) * seq(0, 1, length.out = n)
  )
}

# Helper: draw a sigmoid as a geom_path on a [0,1]x[0,1] ggdraw canvas
draw_sigmoid <- function(x1, y1, x2, y2, color, lwd = 1.2) {
  pts <- sigmoid_path(x1, y1, x2, y2)
  draw_plot(
    ggplot(pts, aes(x, y)) +
      geom_path(color = color, linewidth = lwd) +
      scale_x_continuous(limits = c(0, 1), expand = c(0, 0)) +
      scale_y_continuous(limits = c(0, 1), expand = c(0, 0)) +
      theme_void(),
    x = 0, y = 0, width = 1, height = 1
  )
}

# --- TIL18 to PT connection ---
# TIL18 vlines: x=172.07 (up), x=241.30 (dn); bottom at svg_y=140.45
# PT    vlines: x=172.07 (up), x=242.52 (dn); top    at svg_y=170.33
x_til_up_svg  <- 172.07 / 648
x_til_dn_svg  <- 241.30 / 648
y_til_bot     <- 1 - 140.45 / 432
y_pt_top      <- 1 - 170.33 / 432

# TIL18 midline: x=190.90, PT midline: x=192.58
x_til_mid_svg <- 190.90 / 648

crossing_lines <- list(
  # Gray lines first (drawn behind purple)
  draw_line(x = c(x_til_mid_svg, x_pt_mid_svg), y = c(y_til_bot, y_pt_top),
            color = "gray55", size = 1.2),
  draw_sigmoid(x_pt_mid_svg, y_pt_bot, x_b73_mid_svg, y_b73_top,
               color = "gray55", lwd = 1.2),
  # TIL18 → PT: straight lines (both inverted karyotype, no crossing)
  draw_line(x = c(x_til_up_svg, x_pt_up_svg), y = c(y_til_bot, y_pt_top),
            color = col_inv4m, size = 1.2),
  draw_line(x = c(x_til_dn_svg, x_pt_dn_svg), y = c(y_til_bot, y_pt_top),
            color = col_inv4m, size = 1.2),
  # PT → B73: purple sigmoid X
  draw_sigmoid(x_pt_up_svg, y_pt_bot, x_b73_dn_svg, y_b73_top,
               color = col_inv4m),
  draw_sigmoid(x_pt_dn_svg, y_pt_bot, x_b73_up_svg, y_b73_top,
               color = col_inv4m)
)

# Invisible spacer strips (preserve layout from original arrow strips)
spacer <- ggplot() + theme_void() + theme(plot.margin = margin(0, 10, 0, 10))

make_final <- function(show_points) {
  stk <- plot_grid(
    spacer,
    make_panel("TIL18", show_points = show_points),
    make_panel("PT",    show_points = show_points),
    make_panel("B73",   show_points = show_points, bot_margin = 2),
    spacer,
    ncol = 1, align = "v", axis = "lr",
    rel_heights = c(0.15, 1, 1, 1, 0.15))
  p <- ggdraw() + draw_plot(stk, x = 0.08, y = 0.08, width = 0.86, height = 0.86)
  for (a in overlay_annotations) p <- p + a
  for (a in crossing_lines) p <- p + a
  p <- p + arrow_top_grob + arrow_bot_grob
  p
}

# --- Save skeleton SVG (no points) + PNG (with points) ---
outpath_svg <- file.path(paths$figures, "fig1_panel_A_skeleton.svg")
ggsave(outpath_svg, plot = make_final(FALSE), width = 9, height = 6, device = "svg")

outpath_png <- file.path(paths$figures, "fig1_panel_A_skeleton.png")
ggsave(outpath_png, plot = make_final(TRUE), width = 9, height = 6, dpi = 300, bg = "white")

cat("Saved SVG:", outpath_svg, "\n")
cat("Saved PNG:", outpath_png, "\n")
