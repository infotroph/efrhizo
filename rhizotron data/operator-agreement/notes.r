    
  I have:
  	variance from 	crop,
  					image in crop,
  					subject,
  					tracing in subject
  	
  	y = 	µ + 	Ci +  	I(i)j + 	Sk +  	CSik + 	IS(i)jk	 + T(k)l
  	620 	1		3		96			4		12		384	        120
  	
  	620 observations of 25 images from each of 4 crops, 
  		traced by 5 subjects
  		12 images are tested 3 times each
  	where
  	Ci is the fixed effect of the ith crop
  	I(i)j is the random variation attributable to the jth image within the ith crop
  	Sk is the random variation attributable to analysis by the kth subject
  	CSik is the random interaction between the ith crop and kth subject
  	T(k)l is the random variation attributable to the lth- time the kth subject traces an image.
  	
Throwing out the 44 images where all five subjects agreed that they contained no roots, we get:
	y = 	µ + 	Ci +  	I(i)j + 	Sk +  	CSik + 	IS(i)jk	 + T(k)l
  	390 	1		3		52			4		12		208	        110
  
  
  
  
  	
  	
  	Just the repeated frames:
  	
  	Yijkl = 	µ + 	Ci + 	I(i)j + 	Sk	+ 	CSik +	CI(i)jk + 	eijk
  	180			1		3		8			4		12		32			120
  
  
  
  y		=	µ 	Ci + I(i)j +	Sk + CSik + 	eijk
  60		1	3	8			4	 12			32
 
 
 
 ------ 
  
  Variance function:
 Structure: Different standard deviations per stratum
 Formula: ~1 | Subject 
 Parameter estimates:
       AP       CKB       WAM        LF       MPD 
1.0000000 1.3274014 1.3609295 0.7127168 1.3618717 

these are multipliers of the estimated residual stddev, which is 2.169471 

c(1.0000000, 1.3274014, 1.3609295, 0.7127168, 1.3618717 ) * 2.169471 = 
 2.169471 2.879759 2.952497 1.546218 2.954541
 
--------- 
 
  AP: px
 CKB: mm
  LF: mm
 WAM: px
 MPD: px

To convert areas back to pixels (compensate for differences in calibration): (TotProjArea.mm2/(PxSizeH*PxSizeV))
  
  
  
  
  
  
  
  Copying near-blindly from http://www.mail-archive.com/r-help@stat.math.ethz.ch/msg12228.html:
  (see also Panheiro and Bates p. 164)
  
  oa.cxlme = lme(TotProjArea.mm2 ~ Crop,random=list(fakeBlock = pdBlocked(list(pdIdent(~ImgID-1), pdIdent(~Subject-1)))),data=oaall)
  oa.cxlme.var = sqrt(diag(as.matrix(oa.cxlme$modelStruct$reStruct$fakeBlock))[c(1,101)])
  oa.cxlme.var = oa.cxlme$sigma * c(oa.cxlme.var,1)
  names(oa.cxlme.var)= c("Sigma.ImgID", "Sigma.Subj","Resid")
  oa.cxlme.var
Sigma.ImgID  Sigma.Subj       Resid 
  5.6474934   0.9067254   2.3034338    
  
  
  
  
  
  
Transferring ImgID (assigned in oaall) to other dataframes:
idKey = data.frame(oaall$Img, oaall$ImgID)
oa.noallempty$ImgID = factor(idKey[match(oa.noallempty$Img, idKey[,1]),2])


dotplot(
	reorder(ImgID, TotVolume.mm3)  ~ TotVolume.mm3, 
	groups=Subject, 
	jitter.y=T, 
	type=c("p","a"),
	auto.key=TRUE, #FIXME: put legend inside panel. will need deeper thought.
	data=oa.noallempty) 





# never did decide what form the model should take, these are just some I was trying.

> oa1@call
lmer(formula = TotProjArea.mm2 ~ Crop + (1 | Subject) + (1 | 
    ImgID), data = oaall)
> oa2@call
lmer(formula = TotProjArea.mm2 ~ Crop + (1 | Subject) + (1 | 
    ImgID), data = oaall[oaall$Subject != "LF", ])
> oa3@call
lmer(formula = TotProjArea.mm2 ~ Crop + (1 | Subject) + (1 | 
    ImgID) + (1 | Subject:Crop), data = oaall)
> oa4@call
lmer(formula = TotProjArea.mm2 ~ Crop + (1 | Subject) + (1 | 
    ImgID) + (1 | Subject:Crop) + (1 | ImgID:Crop), data = oaall)
> oa5@call
lmer(formula = TotProjArea.mm2 ~ Crop + (1 | Subject) + (1 | 
    ImgID) + (1 | Subject:Crop) + (1 | ImgID:Crop) + (1 | Subject:ImgID), 
    data = oaall)

> oa.lmerfull@call
lmer(formula = TotProjArea.mm2 ~ Crop + (1 | Subject) + (1 | 
    ImgID) + (1 + Crop | Subject) + (1 + Crop | ImgID), data = oaall)

