#' Two-Sample Test for High-Dimensional Means by Bai and Saranadasa (1996)
#' 
#' Given two multivariate data \eqn{X} and \eqn{Y} of same dimension, it tests
#' \deqn{H_0 : \mu_x = \mu_y\quad vs\quad H_1 : \mu_x \neq \mu_y}
#' using the procedure by Bai and Saranadasa (1996).
#' 
#' @param X an \eqn{(n_x \times p)} data matrix of 1st sample.
#' @param Y an \eqn{(n_y \times p)} data matrix of 2nd sample.
#' @param alpha significance level.
#' 
#' @return a (list) object of \code{S3} class \code{htest} containing: \describe{
#' \item{statistic}{a test statistic.}
#' \item{p.value}{\eqn{p}-value \eqn{P(H_0|H_1)} under current setting.}
#' \item{alternative}{alternative hypothesis.}
#' \item{method}{name of the test.}
#' \item{data.name}{name(s) of provided sample data.}
#' }
#' 
#' @examples 
#' \donttest{
#' ## empirical Type 1 error 
#' niter   = 1000
#' counter = rep(0,niter)  # record p-values
#' for (i in 1:niter){
#'   X = matrix(rnorm(50*5), ncol=10)
#'   Y = matrix(rnorm(50*5), ncol=10)
#'   
#'   counter[i] = ifelse(mean2.1996BS(X,Y)$p.value < 0.05, 1, 0)
#' }
#' 
#' ## print the result
#' cat(paste("\n* Example for 'mean2.1996BS'\n\n",
#' sprintf("* number of rejections   : %d\n",sum(counter)),
#' sprintf("* total number of trials : %d\n",niter),
#' sprintf("* empirical Type 1 error : %.4f\n", sum(counter/niter)),sep=""))
#' }
#' 
#' @references 
#' \insertRef{bai_high_1996}{SHT}
#' 
#' @author Kisung You
#' @export
mean2.1996BS <- function(X, Y, alpha=0.05){
  ##############################################################
  # PREPROCESSING
  check_nd(X)
  check_nd(Y)
  check_alpha(alpha)
  if (ncol(X)!=ncol(Y)){
    stop("* mean2.1996BS : two samples X and Y should be of same dimension.")
  }
  
  ##############################################################
  # COMPUTATION : PRELIMINARY
  n1 = nrow(X)
  n2 = nrow(Y)
  n  = (n1+n2-2) # from highmean package
  
  x1    = colMeans(X)
  x2    = colMeans(Y)
  S     = (((n1-1)*cov(X) + (n2-1)*cov(Y))/n)
  trS   = aux_trace(S)
  xdiff = as.vector(x1-x2)

  term1 = ((n1*n2)/(n1+n2))*sum(xdiff*xdiff) - trS
  term2 = sqrt((2*n*(n+1)/((n-1)*(n+2)))*(aux_trace(S%*%S) - (trS^2)/n))
  
  ##############################################################
  # COMPUTATION : DETERMINATION
  
  thestat = (term1/term2)
  pvalue  = pnorm(thestat,lower.tail=FALSE) # reject if (Z > thr_alpha)
  
  hname   = "Two-Sample Test for High-Dimensional Means by Bai and Saranadasa (1996)."
  Ha      = "true means are different."
  if (pvalue < alpha){
    conclusion = "Reject Null Hypothesis."
  } else {
    conclusion = "Not Reject Null Hypothesis."
  }
  
  DNAME = paste(deparse(substitute(X))," and ",deparse(substitute(Y)),sep="") # borrowed from HDtest
  names(thestat) = "statistic"
  res   = list(statistic=thestat, p.value=pvalue, alternative = Ha, method=hname, data.name = DNAME)
  class(res) = "htest"
  return(res)
}