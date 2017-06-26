library("csvy")
library("ggplot2")
library("dplyr")
library("tidyr")
library("scales")
library("viridis")
library("DeLuciatoR")

# Sum of squares for logistic curve fit. 
# Used as error function by optim()
logit_sumsq = function(par, y, x){
	sum((y - plogis(x, par[1], par[2]))^2)
}

# Find best-fitting scale and location parameters
# for a logistic curve through x and y
fit_logit = function(x, y, start_vals = c(loc = 16, scale = 6)){
	fit = optim(par = start_vals, fn = logit_sumsq, x = x, y = y)
	setNames(as.list(fit$par), c("location", "scale"))
}

# fit logistic curve and return predicted values for the whole range of x
fit_surface_effect = function(depth, ratio){
	f = fit_logit(x = depth, y = ratio)
	d_out = min(depth):max(depth)
	data.frame(depth = d_out, predicted = plogis(d_out, f$location, f$scale))
}

bragg = read_csvy("rawdata/bragg1983.csvy")

print("estimated logistic parameters:")
print(
	bragg
	%>% group_by(date)
	%>% do(x=list(data.frame(fit_logit(.$depth, .$am/.$cb))))
	%>% tidyr::unnest())

fitted = (bragg 
	%>% group_by(date)
	%>% do(x=list(fit_surface_effect(depth = .$depth, ratio = .$am / .$cb)))
	%>% tidyr::unnest())

plt = (ggplot(bragg, aes(x = depth, y = am / cb, color = date))
	+ geom_point()
	+ geom_line(data=fitted, aes(x=depth, y = predicted))
	+ labs(
		x = "Depth (cm)",
		y = "(minirhizotron root count) / (core break root count)")
	+ coord_flip()
	+ scale_x_reverse(
		sec.axis=sec_axis(~., labels=NULL, breaks = pretty_breaks(n=5)),
		breaks=pretty_breaks(n=5))
	+ scale_y_continuous(
		sec.axis=sec_axis(~., labels=NULL, breaks=pretty_breaks(n=5)),
		breaks=pretty_breaks(n=5))
	+ scale_color_viridis(discrete=TRUE, begin=0.1, end=0.8)
	+ theme_ggEHD(14)
	+ theme(
		aspect.ratio=1.3,
		legend.title=element_blank(),
		legend.position = c(0.8,0.9))
)

ggsave_fitmax(
	filename="figures/bragg_surface_effect.png",
	plot=plt,
	maxheight=9,
	maxwidth=6.5,
	units="in",
	dpi=300)
