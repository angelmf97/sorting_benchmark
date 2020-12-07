library(magrittr)
library(ggplot2)

setwd(dirname(rstudioapi::getSourceEditorContext()$path))
args = commandArgs(trailingOnly = TRUE)
print(args)
df <- read.table("./results.txt")

n <- args[1] %>% as.numeric()

opts <- args[2]
opts <- strsplit(opts, " ") %>% unlist()
opts[opts=="i"] <- "Insertion"
opts[opts=="s"] <- "Selection"
opts[opts=="q"] <- "Quicksort"

sizes <- args[3]
sizes <-  strsplit(sizes, " ") %>%  unlist() %>% as.numeric()

#Compute the mean and sd of the replicates and merge the results
means <- aggregate(df[,5],list(rep(1:(nrow(df)%/%n+1),each=n,len=nrow(df))),mean)[-1] %>% c() %>% unlist()
sds <- aggregate(df[,5],list(rep(1:(nrow(df)%/%n+1),each=n,len=nrow(df))),sd)[-1] %>% c() %>% unlist()
num <- rep(sizes,6*length(opts))
group <- rep(opts, each = 6*length(sizes))
type <- rep(c("Random","Ordered","Inv. ordered","Constant","Pattern","Ord. pattern"), each = length(sizes)) %>% 
  rep(length(opts))

X <- data.frame(Type= factor(type),
                Algorithm = factor(group),
                Size = num,
                Time = means,
                sds = sds)
                

f <- 3
pdf("byalgorithm.pdf", height = 2.80*f, width = 2.97*f)
ggplot(data=X,aes(x=Size, y=Time, group=Algorithm, colour=Algorithm)) + geom_point(size = 0) + 
  geom_line(size=0.75) +
  geom_errorbar(aes(ymin=Time-sds, ymax=Time+sds), width=2000,
                position=position_dodge(0.05)) + 
  theme_classic() + theme(axis.text.x = element_text(angle = 90)) + facet_wrap(X$Type) +
  #scale_color_manual(values=c('#E69F00','#999999','blue'))
  scale_color_manual(values=c('forestgreen', 'red', 'darkblue'))
dev.off()

pdf("bytypes.pdf", height = 2*f, width = 2.97*f)
ggplot(data=X,aes(x=Size, y=Time, group=Type, colour=Type)) + geom_point(size = 0.2) + geom_line() +
  geom_errorbar(aes(ymin=Time-sds, ymax=Time+sds), width=2000,
                position=position_dodge(0.05)) + 
  theme_classic() + theme(axis.text.x = element_text(angle = 90)) + facet_wrap(X$Algorithm) +
  scale_color_viridis_d()
dev.off()
