library(ggplot2)
library(ggpubr)
"{dirs$scripts}/plot/ggplot_formatting.R" |> glue() |> source()

volcano_plot <- function(data, file = NULL, title = NULL, subtitle = NULL,
  padj.lim = NULL, lfc.lim = NULL, padj.thresh = 0.01, lfc.threshold = 0.585,
  width=unit(4, "inch"), height=unit(4, "inch"), scale_dot_size = TRUE
) {

  data$y_axis <- -log10(data$BH)
  # Generate PFC scores
  # data$PFC <- -log10(data$BH) * abs(data$avg_log2FC)
  data$color <- "grey40"

  if (is.null(padj.lim)) {
    padj.lim <- data[data$y_axis != Inf, ]$y_axis %>% max
  }
  max_y <- padj.lim
  overflow_y <- FALSE
  if (dim(data[data$y_axis > padj.lim, ])[1] > 0) {
    data[data$y_axis >= padj.lim, ]$color <- "purple"
    data[data$y_axis > padj.lim, ]$y_axis <- padj.lim * 1.05
    max_y <- max_y  * 1.05
    overflow_y <- TRUE
  }
  data$PFC <- data$y_axis * abs(data$avg_log2FC)

  data[which(data$BH <= padj.thresh & data$avg_log2FC > lfc.threshold), 'color'] <- "red"
  data[which(data$BH <= padj.thresh & data$avg_log2FC < -lfc.threshold), 'color'] <- "blue"

  if (is.null(lfc.lim)) {
    lfc.lim <- max(abs(data$avg_log2FC))
    if (lfc.lim < 1) {
      lfc.lim <- 1
    }
  }

  colors <- data$color %>% unique
  names(colors) <- colors

  p <- ggplot(
    data,
    aes(
      x = avg_log2FC,
      y = y_axis,
      # y = -log10(BH),
      # color = color,
      label = gene,
      # size = PFC,
      # fill = color
    )
  )
  if (scale_dot_size == TRUE) {
    p <- p + aes(size = PFC)
  }

  if (overflow_y == TRUE) {
    p <- p + geom_hline(
      yintercept = padj.lim,
      linetype = "solid",
      color = "grey90"
    )
  }

  p <- p + geom_hline(
    yintercept = -log10(padj.thresh),
    linetype = 2,
    color = "gray"
  )
  p <- p + geom_vline(
    xintercept = lfc.threshold,
    linetype = 2,
    color = "gray"
  )
  p <- p + geom_vline(
    xintercept = -lfc.threshold,
    linetype = 2,
    color = "gray"
  )
  p <- p + geom_point(
    aes(
      # size = PFC,
      color = color
    ),
    alpha = 0.6
  )
  p <- p + scale_color_manual(
    values = colors,
    aesthetics = c("color", "fill")
  )
  # scale_shape_manual(
  #
  # ) +
  p <- p + theme_Publication_blank()
  p <- p + geom_text_repel(
    data = data[which(data$color != 'grey40'), ],
    # data = data,
    inherit.aes = T,
    color = 'black',
    size = 2,
    force = 3,
    max.overlaps = 15
  )
  p <- p + theme(legend.position = "none")
  # theme(legend.margin=margin(1, 1, 1, 1, 'cm'))
  p <- p + theme(axis.text.x = element_text(size = 12))
  p <- p + theme(axis.text.y = element_text(size = 12))
  p <- p + scale_x_continuous(limits = c(-lfc.lim, lfc.lim))
  p <- p + scale_y_continuous(limits = c(0, max_y))
  p <- p + labs(y = "-log10(BH)")

    # if (!is.null(padj.lim)) {
    #   p <- p + scale_y_continuous(limits = c(0, padj.lim))
    # }
  if (!is.null(title) && !is.na(title)) {
    p <- p + labs(title = title)
    p <- p + theme(plot.title = element_text(hjust = 0.5))
  }
  if (!is.null(subtitle) && !is.na(subtitle)) {
    p <- p + labs(subtitle = subtitle)
    p <- p + theme(plot.subtitle = element_text(hjust = 0.5))
  }

  if (!is.null(file)) {
    print(glue("Savings volcano plot to {file}"))
    set_panel_size(
      p,
      file = file,
      width = width,
      height = height
    )
  }

  return(p)
}
