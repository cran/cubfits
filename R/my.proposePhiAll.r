### Propose new Phi conditioning on all orhter parameters.
###
### These functions are for all genes.

### Get the specific function according to the options.
get.my.proposePhiAll <- function(type){
  if(!any(type[1] %in% .CF.CT$type.Phi)){
    stop("type is not found.")
  }
  ret <- eval(parse(text = paste("my.proposePhiAll.",
                                 type[1], sep = "")))
  assign("my.proposePhiAll", ret, envir = .cubfitsEnv)
  ret
} # End of get.my.proposePhiAll().


### Assumes phi.Curr1, are vectors of length # of genes;
### b, y, n are lists of lenght number of aas.
###
### Currently using random walk.
###
### Returns list with elements:
###   * phi.Prop :   proposal for phi
###   * lir      :   log importance ratio for given draw = 0

### Draw random walk given current status for new E[Phi].
my.proposePhiAll.RW_Norm <- function(phi.Curr1, phi.DrawScale = 1,
    phi.DrawScale.prev = 1){
  propScale <- phi.DrawScale
  log.phi.Curr1 <- log(phi.Curr1)
  propScale1 <- phi.DrawScale.prev

  # phi.Prop <- exp(log.phi.Curr1 + rnorm(length(phi.Curr1)) * propScale)
  # lir <- dlnorm(phi.Prop, log.phi.Curr1, propScale1, log = TRUE) -
  #        dlnorm(phi.Curr1, log(phi.Prop), propScale, log = TRUE)
  logphi.Prop <- log.phi.Curr1 + rnorm(length(phi.Curr1)) * propScale
  phi.Prop <- exp(logphi.Prop)
  ### Too slow
  # lir <- lapply(1:length(phi.Curr1),
  #          function(i.orf){
  #            dlnorm(phi.Prop[i.orf], log.phi.Curr1[i.orf], propScale1[i.orf],
  #                   log = TRUE) -
  #            dlnorm(phi.Curr1[i.orf], logphi.Prop[i.orf], propScale[i.orf],
  #                   log = TRUE)
  #          })
  # lir <- do.call("c", lir)

  ### Faster since the next relations of normal and log normal
  ### x <- 1.5; m <- 2; s <- 3
  ### dnorm(log(phi), m, s, log = TRUE) - log(phi)
  ### dlnorm(phi, m, s, log = TRUE)
  lir <- -logphi.Prop + log.phi.Curr1
  id <- which(propScale1 != propScale)
  if(length(id) > 0){
    tmp <- lapply(id,
             function(i.orf){
               dnorm(logphi.Prop[i.orf], log.phi.Curr1[i.orf], propScale1[i.orf],
                     log = TRUE) -
               dnorm(log.phi.Curr1[i.orf], logphi.Prop[i.orf], propScale[i.orf],
                     log = TRUE)
             })
    lir[id] <- lir[id] + do.call("c", tmp)
  }

  ret <- list(phi.Prop = phi.Prop, lir = lir)
  ret
} # End of my.proposePhiAll.RW_Norm().
