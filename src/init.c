#include <R.h>
#include <Rinternals.h>
#include <stdlib.h> // for NULL
#include <R_ext/Rdynload.h>

/* .Call calls */
extern SEXP r_floatraw2numeric(SEXP);

static const R_CallMethodDef CallEntries[] = {
    {"r_floatraw2numeric", (DL_FUNC) &r_floatraw2numeric, 1},
    {NULL, NULL, 0}
};

void R_init_swatches(DllInfo *dll)
{
    R_registerRoutines(dll, NULL, CallEntries, NULL, NULL);
    R_useDynamicSymbols(dll, FALSE);
}
