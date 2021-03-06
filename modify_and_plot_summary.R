#!/usr/bin/env Rscript

###arguments
Args=commandArgs()
sense_lendis=read.table(paste(Args[6],".sense.lendis",sep=""),header=T,row.names=NULL,check.names=F)
anti_lendis=read.table(paste(Args[6],".antisense.lendis",sep=""),header=T,row.names=NULL,check.names=F)
pp=read.table(paste(Args[6],".pp",sep=""),header=T,row.names=NULL,check.names=F)
summary=read.table(paste(Args[6],".summary",sep=""),header=T,row.names=1)
rn=row.names(summary)

###function
fun_zscore=function(x){
	x_HkGene=x[c(1:9,11:30)]
	x_treat=x[10]
	z=(x_treat-mean(x_HkGene))/sd(x_HkGene)
	return(z)
}
fun_plot_lendis=function(x1, x2){
	par(mar=c(1,3,1,2))
	barplot(x1,space=0,border="white",col="#e41a1c",ylim=c(0,max(x1,x2)))
	axis(1,1:21-0.5,label=15:35,lwd=0,padj=-0.3)
	text(0,max(x1,x2)*8/10,pos=4,font=2,label=paste("peak:\n",prettyNum(max(x1,x2),big.mark=","),sep=""))
	barplot(-x2,space=0,border="white",col="#377eb8",ylim=c(-max(x1,x2),0))
}
fun_plot_pp=function(x){
	par(mar=c(4,3,4,1),cex=0.65)
	barplot(x,space=0,border="white",col="black")
	axis(1,c(1,10,20,30)-0.5,label=c(1,10,20,30),lwd=0)
	zs=round((x[10]-mean(x[c(1:9,11:30)]))/sd(x[c(1:9,11:30)]),2)
	text(10,max(x)*9/10,label=paste("z-score=",zs,sep=""),col="#e41a1c",font=2,pos=4)
}

###modify tables
summary=transform(summary, zscore=as.vector(apply(pp[,rn],2,fun_zscore)), pp_score=as.vector(t(pp[10,rn])))
summary[which(is.na(summary[,"zscore"])),"zscore"]=-1
write.table(summary, paste(Args[6],".summary",sep=""), sep="\t", quote=F)
row.names(pp)=1:30
write.table(pp, paste(Args[6],".pp",sep=""), sep="\t", quote=F)
row.names(sense_lendis)=15:35
write.table(sense_lendis, paste(Args[6],".sense.lendis",sep=""), sep="\t", quote=F)
row.names(anti_lendis)=15:35
write.table(anti_lendis, paste(Args[6],".antisense.lendis",sep=""), sep="\t", quote=F)

###plot
pdf(paste(Args[6], ".pdf", sep=""), width=7, height=4, useDingbats=F)
laymat=matrix(1,7,2)
laymat[2:4,1]=2
laymat[5:7,1]=2
laymat[2:4,2]=3
laymat[5:7,2]=4
layout(laymat)
par(cex=0.65)
for(i in rn){
	par(mar=c(0,0,0,0),cex=1)
	plot.new()
	text(0.5,0.5,label=i,font=2,cex=1)
	fun_plot_pp(pp[,i])
	fun_plot_lendis(sense_lendis[,i],anti_lendis[,i])
}
dev.off()
