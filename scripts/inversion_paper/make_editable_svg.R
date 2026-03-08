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
                   color = "gray55", linewidth = 1.0) } +
    geom_vline(data = gbp, aes(xintercept = xpos_aligned),
               color = col_inv4m, linewidth = 1.0) +
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
          axis.ticks.x = element_blank())

  if (genome_id != "B73")
    p <- p + theme(axis.text.x = element_blank())

  p
}


# --- Arrow strip: flush against panels ---
make_arrow_strip <- function(bp_left, bp_right, direction) {
  adf <- make_arrow_df(bp_left, bp_right, 0, 0.8, arrow_point, direction)

  p <- ggplot() +
    annotate("polygon", x = adf$x, y = adf$y,
             fill = col_inv4m, color = col_inv4m) +
    scale_x_continuous(labels = unit_format(unit = "", scale = 1e-6),
                       breaks = cfg$xbreaks) +
    coord_cartesian(xlim = cfg$xlim, ylim = c(-1, 1)) +
    theme_void() +
    theme(plot.margin = margin(t = 0, r = 10, b = 0, l = 10))

  p
}

# --- Assemble: arrow_top, TIL18, PT, B73 (ticks only), arrow_bot ---
bp_top <- bp_aligned %>% filter(genome == "TIL18")
bp_bot <- bp_aligned %>% filter(genome == "B73")

arrow_top <- make_arrow_strip(min(bp_top$xpos_aligned), max(bp_top$xpos_aligned),
                              "left")
arrow_bot <- make_arrow_strip(min(bp_bot$xpos_aligned), max(bp_bot$xpos_aligned),
                              "right")

# --- Overlay text configuration ---

sz_name    <- 20   # genome names, Inv4m, legend — match base_size=20
sz_species <- 14   # species descriptions

# NPC positions derived from user SVG edits (canvas 648x432, y_npc = 1 - svg_y/432)
# Single header row: Inv4m (left) + legend (right), above top arrow
y_header   <- 0.955

# Genome names: centered on x-axis span; species: right-aligned, same y
# x_center: midpoint of xlim (163-250 Mb) → x_npc(206.5e6) ≈ 0.537
x_gname    <- 0.54   # genome name, centered
x_species  <- 0.90   # species description, right-aligned

# y positions: genome name 3.77pt above 100-line in each panel
# species text: same baseline (bottom-aligned with genome name)
y_name1    <- 0.875  # TIL18 (3.77pt above 100-line, confirmed)
y_sp1      <- 0.875  # teosinte mexicana — middle-aligned with TIL18
y_name2    <- 0.6144 # PT (3.77pt above 100-line at svg y=177.51)
y_sp2      <- 0.6144 # highland maize — middle-aligned with PT
y_name3    <- 0.3539 # B73 (3.77pt above 100-line at svg y=290.09)

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
  draw_label("Chromosome 4 Position [Mb]", x = 0.50, y = 0.03, size = 20),
  draw_label("A", x = 0.02, y = 0.98, size = 24, fontface = "bold"),
  draw_label("Inv4m", x = 0.32, y = y_header, size = sz_name,
             fontface = "bold.italic", color = col_inv4m),
  draw_plot(
    ggplot() + annotate("point", x = 0, y = 0, color = col_knob, size = 4) + theme_void(),
    x = 0.55, y = y_header - 0.012, width = 0.02, height = 0.02),
  draw_label("knob 180", x = 0.58, y = y_header, size = sz_name,
             fontface = "italic", color = col_knob, hjust = 0),
  draw_plot(
    ggplot() + annotate("point", x = 0, y = 0, color = col_gold, size = 4) + theme_void(),
    x = 0.73, y = y_header - 0.012, width = 0.02, height = 0.02),
  draw_label("TR-1", x = 0.76, y = y_header, size = sz_name,
             fontface = "italic", color = col_gold, hjust = 0),
  draw_label("TIL18", x = x_gname, y = y_name1, size = sz_name, fontface = "bold"),
  draw_label("teosinte mexicana", x = x_species, y = y_sp1,
             size = sz_species, fontface = "italic", color = col_gray, hjust = 1),
  draw_label("PT", x = x_gname, y = y_name2, size = sz_name, fontface = "bold"),
  draw_label("highland maize", x = x_species, y = y_sp2,
             size = sz_species, fontface = "italic", color = col_gray, hjust = 1),
  draw_label("B73", x = x_gname, y = y_name3, size = sz_name, fontface = "bold")
)

make_final <- function(show_points) {
  stk <- plot_grid(
    arrow_top,
    make_panel("TIL18", show_points = show_points),
    make_panel("PT",    show_points = show_points),
    make_panel("B73",   show_points = show_points, bot_margin = 2),
    arrow_bot,
    ncol = 1, align = "v", axis = "lr",
    rel_heights = c(0.15, 1, 1, 1, 0.15))
  p <- ggdraw() + draw_plot(stk, x = 0.08, y = 0.08, width = 0.86, height = 0.86)
  for (a in overlay_annotations) p <- p + a
  p
}

# --- Save skeleton SVG (no points) + PNG (with points) ---
outpath_svg <- file.path(paths$figures, "fig1_panel_A_skeleton.svg")
ggsave(outpath_svg, plot = make_final(FALSE), width = 9, height = 6, device = "svg")

outpath_png <- file.path(paths$figures, "fig1_panel_A_skeleton.png")
ggsave(outpath_png, plot = make_final(TRUE), width = 9, height = 6, dpi = 300)

cat("Saved SVG:", outpath_svg, "\n")
cat("Saved PNG:", outpath_png, "\n")
