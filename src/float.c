/** ===========================================================================
 ** R-Package: rdyncall
 ** File: src/rutils_float.c
 ** Description: Utility functions for handling C float data types.
 **/

#define USE_RINTERNALS
#include <R.h>
#include <Rinternals.h>

/* Float utils */

/*SEXP r_as_floatraw(SEXP x) {

  SEXP ans;
  int i, n;
  double *dp;
  float  *fp;

  dp = (double*) REAL(x);

  n = LENGTH(x);
  if (n < 1) {
    error("length of x should be >= 1");
    return R_NilValue;
  }

  ans = PROTECT(Rf_allocVector(RAWSXP, sizeof(float)*n));

  fp = (float*) RAW(ans);

  for(i = 0 ; i < n ; ++i ) fp[i] = (float) dp[i];

  UNPROTECT(1);
  return ans;

} */

SEXP r_floatraw2numeric(SEXP x) {

  SEXP ans;
  int i, n;
  float  *fp;
  double *dp;

  fp = (float*) RAW(x);

  n = LENGTH(x) / sizeof(float);
  ans = PROTECT( Rf_allocVector(REALSXP, n) );

  dp = (double*) REAL(ans);

  for(i = 0 ; i < n ; ++i ) dp[i] = (double) fp[i];

  UNPROTECT(1);
  return ans;

}


