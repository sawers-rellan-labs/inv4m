
genomes <- c("TIL18","PT","B73")
blastcols <- c("qseqid", "sseqid", "pident", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send", "evalue", "bitscore")

blast_file <- c(
  TIL18 ="~/Desktop/knob_til18.blast",
  PT = "~/Desktop/knob_pt.blast",
  B73 = "~/Desktop/knob_b73.blast"
)

knob <- lapply(genomes, FUN=function(x){
   blast <- read.table(
    blast_file[x], sep= "\t", header = FALSE,
    col.names = blastcols,
    colClasses = c(qseqid ="character", sseqid ="character")
  )
  blast$queryg <- x
  return(blast)
}) %>% dplyr::bind_rows()  %>%
  mutate(bitscaled = scales::rescale(bitscore, to=c(0,100)),
         rep = "knob180")
knob$rep


blast_file <- c(
  TIL18 ="~/Desktop/TR-1_til18.blast",
  PT = "~/Desktop/TR-1_pt.blast",
  B73 = "~/Desktop/TR-1_b73.blast"
)


tr1 <- lapply(genomes, FUN=function(x){
  blast <- read.table(
    blast_file[x], sep= "\t", header = FALSE,
    col.names = blastcols,
    colClasses = c(qseqid ="character", sseqid ="character")
  )
  blast$queryg <- x
  return(blast)
}) %>% dplyr::bind_rows()  %>%
  mutate(bitscaled = scales::rescale(bitscore, to=c(0,100)),
         rep = "TL-R1")

to_plot <- rbind(knob,tr1)
to_plot$queryg <- factor(to_plot$queryg, levels = genomes)
to_plot$rep <- factor(to_plot$rep)

# "#3232a0"

df2 <- df1 %>%
  group_by(Species, Big.Petal) %>%
  summarise(Mean.SL = mean(Sepal.Length))

annotations <- data.frame(
  queryg=c("TIL18","TIL18","PT","PT","B73","B73"),
  qstart=c(180365316,193570651,173486186,186925483,172882309,188131461)
)

quartz(height=5)
to_plot %>%
  ggplot(aes(x=qstart, y=bitscaled, color = rep)) +
  ylab("Normalized Repeat Match Score")+
  geom_vline(data = annotations, 
             mapping = aes(xintercept = qstart),
             color= "#3232a0",
             linewidth=1.2) +
  geom_point() +
  facet_wrap(. ~factor(queryg, levels = genomes) , nrow = 3, 
             #strip.position="right",
             ncol=1) +
  scale_color_manual(values =  c("#1d7f7a","gold")) +
  scale_x_continuous(labels = unit_format(unit = "", scale = 1e-6), breaks = c(175e6, 200e6,225e6, 250e6)) +
  coord_cartesian(xlim=c(170000000,250000000))+
  annotate("segment", x=-Inf, xend=Inf, y=-Inf, yend=-Inf)+
  annotate("segment", x=-Inf, xend=-Inf, y=-Inf, yend=Inf)+
  theme_minimal(base_size = 20)  +
  theme(axis.title.x = element_blank(),
        axis.text.x = element_text(hjust=0.8),
        plot.title = element_text(hjust=0.5),
        #strip.text.y.right = element_text( angle =0),
        strip.background = element_blank(),
        legend.position = "none"
          )

