# full model with individual tubes.
# Fit fails with error "downdated VtV is not positive definite"
full.2010 = lmer(log(rootvol.mm3.mm2+1e-6) ~ Species*Session*Depth*I(Depth^2) + (Species*Session*Depth*I(Depth^2)|Block) + (Session*Depth*I(Depth^2)|Tube), noeasy.2010)

# try removing log. Same error.
full.2010.nolog = lmer(rootvol.mm3.mm2 ~ Species*Session*Depth*I(Depth^2) + (Species*Session*Depth*I(Depth^2)|Block) + (Session*Depth*I(Depth^2)|Tube), noeasy.2010)

full.2010 = lmer(
	log(rootvol.mm3.mm2+1e-6) ~ Species*Session*Depth + I(Depth^2) 
	+ (Species*Session*Depth + I(Depth^2)|Block) 
	+ (Session*Depth + I(Depth^2)|Tube), 
	noeasy.2010)

m1.2010 = lmer( #converges
	log(rootvol.mm3.mm2+1e-6) ~ Species * poly(Depth,2) * poly(Date,2) 
		+ (Species | Block)
		+ (poly(Depth,2) | Tube), 
	noeasy.2010)

m2.2010 = lmer( #does not converge
	log(rootvol.mm3.mm2+1e-6) ~ Species * poly(Depth,2) * poly(Session,2) 
		+ (Species | Block)
		+ (poly(Depth,2) | Tube), 
	noeasy.2010)

m3.2010 = lmer( #does not converge
	log(rootvol.mm3.mm2+1e-6) ~ Species * poly(Depth,2) * poly(Session,2) 
		+ (Species + poly(Depth,2) | Block)
		+ (poly(Depth,2) | Tube), 
	noeasy.2010)

m4.2010 = lmer( # does not converge
	log(rootvol.mm3.mm2+1e-6) ~ Species * poly(Depth,2) * poly(Session,2) 
		+ (Species | Block)
		+ (1 | Tube), 
	noeasy.2010)

m5.2010 = lmer(
	log(rootvol.mm3.mm2+1e-6) ~ Species * poly(Depth,2) * poly(Session,2) 
		+ (1 | Block)
		+ (1 | Tube), 
	noeasy.2010)

m6.2010 = lmer( #does not converge
	log(rootvol.mm3.mm2+1e-6) ~ Species * poly(Depth,2) 
		+ poly(Session,2) 
		+ Species:poly(Session,2) 
		+ poly(Depth,2):poly(Session, 2) 
		+ (Species | Block)
		+ (poly(Depth,2) | Tube), 
	noeasy.2010)

m7.2010 = lmer( #converges
	log(rootvol.mm3.mm2+1e-6) ~ Species * poly(Depth,2) * poly(Date,2) 
		+ (1 | Block)
		+ (poly(Depth,2) | Tube), 
	noeasy.2010)

# blocks as fixed effect
m8.2010 = lmer( 
	log(rootvol.mm3.mm2+1e-6) ~ Species * poly(Depth,2) * poly(Date,2) 
		+ Block
		+ (poly(Depth,2) | Tube), 
	noeasy.2010)
