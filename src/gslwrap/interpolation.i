/* -*- C -*- */
/*
 * Author: Fabian Jakobs
 * Modified by : Pierre Schnizer January 2003
 */		 
%{
#include <gsl/gsl_interp.h>
#include <gsl/gsl_spline.h>
#include <Numeric/arrayobject.h>
#include <stdio.h>
%}

%typemap(arginit) (const double *, const double *, size_t ) %{
     PyArrayObject *_PyVector_1$argnum = NULL;
     PyArrayObject *_PyVector_2$argnum = NULL;
%};

%typemap(in) (const double *, const double *, size_t ) {
     int mysize = 0;
     if(!PySequence_Check($input)){
	  PyErr_SetString(PyExc_TypeError, "Expected a sequence!");
	  goto fail;
     }
     if(PySequence_Fast_GET_SIZE($input) != 2){
	  PyErr_SetString(PyExc_TypeError, "Expected a sequence with length 2!");
	  goto fail;
     }
     _PyVector_1$argnum = PyGSL_PyArray_PREPARE_gsl_vector_view(
	  PySequence_Fast_GET_ITEM($input, 0), PyArray_DOUBLE, 1, -1, $argnum, NULL);
     if (_PyVector_1$argnum == NULL)
	  goto fail;

     mysize = _PyVector_1$argnum->dimensions[0];

     _PyVector_2$argnum = PyGSL_PyArray_PREPARE_gsl_vector_view(
	   PySequence_Fast_GET_ITEM($input, 1), PyArray_DOUBLE, 1, mysize, $argnum+1, NULL);
     if (_PyVector_2$argnum == NULL)
	  goto fail;

     $1 = (double *)(_PyVector_1$argnum->data);
     $2 = (double *)(_PyVector_2$argnum->data);
     $3 = (size_t) mysize;

};
%typemap(check) (const double *, const double *, size_t ) {
     ;
};
%typemap(argfree) (const double *, const double *, size_t ) {
     Py_XDECREF(_PyVector_1$argnum);
     Py_XDECREF(_PyVector_2$argnum);
};
%typemap(arginit) (const double *, size_t ) %{
     PyArrayObject *_PyVector$argnum = NULL;
%};
%typemap(in) (const double *, size_t ) {
     int mysize = 0;
     _PyVector$argnum = PyGSL_PyArray_PREPARE_gsl_vector_view(
	  $input, PyArray_DOUBLE, 1, -1, $argnum, NULL);
     if (_PyVector$argnum == NULL)
	  goto fail;

     mysize = _PyVector$argnum->dimensions[0];
     $1 = (double *)(_PyVector$argnum->data);
     $2 = (size_t) mysize;
};
/* Just to prevent that the check typemap below is applied. */
%typemap(argfree) (const double *, size_t ) {
     Py_XDECREF(_PyVector$argnum);
};
%typemap(arginit) (const double * array) %{
     PyArrayObject *_PyVector$argnum = NULL;
     PyObject * _input$argnum;
%};
/* moved to check as I need the size of the interpolation! */
%typemap(in) (const double * array) {
     _input$argnum = $input;
};
%typemap(check) (const double * array) {
     _PyVector$argnum = PyGSL_PyArray_PREPARE_gsl_vector_view(
	  _input$argnum, PyArray_DOUBLE, 1, _gslinterp_size, $argnum, NULL);
     if (_PyVector$argnum == NULL)
	  goto fail;
     $1 = (double *)(_PyVector$argnum->data);
};
%typemap(argfree) (const double * array) {
     Py_XDECREF(_PyVector$argnum);
};
%typemap(arginit)(gsl_interp * IN) %{
     int _gslinterp_size = 0;
%};
%typemap(in)(gsl_interp * IN) {
     if(SWIG_ConvertPtr($input, (void **) &$1, $1_descriptor, SWIG_POINTER_EXCEPTION | 0 )){
	  PyErr_SetString(PyExc_TypeError, "Could not convert gsl_interp to pointer");
        goto fail;
     }
     _gslinterp_size = (int) $1->size;
};

%apply (const double *, const double *, size_t ) {(const double xa[], const double ya[], size_t size)};
%apply (const double *, size_t ) {(const double x_array[], size_t size)};
%apply (const double * array){(const double xa[]), 
			      (const double ya[])};
gsl_spline *
gsl_spline_alloc(const gsl_interp_type * T, size_t n);
     
int
gsl_spline_init(gsl_spline * spline, const double xa[], const double ya[], size_t size);


int
gsl_spline_eval_e(const gsl_spline * spline, double x,
                  gsl_interp_accel * a, double * y);

double
gsl_spline_eval(const gsl_spline * spline, double x, gsl_interp_accel * a);

int
gsl_spline_eval_deriv_e(const gsl_spline * spline,
                        double x,
			gsl_interp_accel * a,
                        double * OUT);

double
gsl_spline_eval_deriv(const gsl_spline * spline,
                      double x,
		      gsl_interp_accel * a);

int
gsl_spline_eval_deriv2_e(const gsl_spline * spline,
                         double x,
			 gsl_interp_accel * a,
                         double * OUT);

double
gsl_spline_eval_deriv2(const gsl_spline * spline,
                       double x,
		       gsl_interp_accel * a);

int
gsl_spline_eval_integ_e(const gsl_spline * spline,
                        double a, double b,
			gsl_interp_accel * acc,
                        double * OUT);

double
gsl_spline_eval_integ(const gsl_spline * spline,
                      double a, double b,
		      gsl_interp_accel * acc);

void
gsl_spline_free(gsl_spline * spline);



/* available types */
GSL_VAR const gsl_interp_type * gsl_interp_linear;
GSL_VAR const gsl_interp_type * gsl_interp_polynomial;
GSL_VAR const gsl_interp_type * gsl_interp_cspline;
GSL_VAR const gsl_interp_type * gsl_interp_cspline_periodic;
GSL_VAR const gsl_interp_type * gsl_interp_akima;
GSL_VAR const gsl_interp_type * gsl_interp_akima_periodic;    

gsl_interp_accel *
gsl_interp_accel_alloc(void);

size_t
gsl_interp_accel_find(gsl_interp_accel * a, const double x_array[], size_t size, double x);

int
gsl_interp_accel_reset (gsl_interp_accel * a);

void
gsl_interp_accel_free(gsl_interp_accel * a);

gsl_interp *
gsl_interp_alloc(const gsl_interp_type * T, size_t n);
     
int
gsl_interp_init(gsl_interp * obj, const double xa[], const double ya[], size_t size);

const char * gsl_interp_name(const gsl_interp * interp);
unsigned int gsl_interp_min_size(const gsl_interp * interp);


int
gsl_interp_eval_e(const gsl_interp * IN,
                  const double xa[], const double ya[], double x,
                  gsl_interp_accel * a, double * OUTPUT);

double
gsl_interp_eval(const gsl_interp * IN,
                const double xa[], const double ya[], double x,
                gsl_interp_accel * a);

int
gsl_interp_eval_deriv_e(const gsl_interp * IN,
                        const double xa[], const double ya[], double x,
			gsl_interp_accel * a,
                        double * OUTPUT);

double
gsl_interp_eval_deriv(const gsl_interp * IN,
                      const double xa[], const double ya[], double x,
		      gsl_interp_accel * a);

int
gsl_interp_eval_deriv2_e(const gsl_interp * IN,
                         const double xa[], const double ya[], double x,
			 gsl_interp_accel * a,
                         double * OUTPUT);

double
gsl_interp_eval_deriv2(const gsl_interp * IN,
                       const double xa[], const double ya[], double x,
		       gsl_interp_accel * a);

int
gsl_interp_eval_integ_e(const gsl_interp * IN,
                        const double xa[], const double ya[],
                        double a, double b,
			gsl_interp_accel * acc,
                        double * OUTPUT);

double
gsl_interp_eval_integ(const gsl_interp * IN,
                      const double xa[], const double ya[],
                      double a, double b,
		      gsl_interp_accel * acc);

void
gsl_interp_free(gsl_interp * interp);

%typemap(arginit) (const double x_array[]) %{
     PyArrayObject *_PyVector$argnum = NULL;
     int _PyVectorLength = 0;
%};
/* moved to check as I need the size of the interpolation! */
%typemap(in) (const double x_array[]) {
     _PyVector$argnum = PyGSL_PyArray_PREPARE_gsl_vector_view(
	  $input, PyArray_DOUBLE, 1, -1, $argnum, NULL);
     if (_PyVector$argnum == NULL)
	  goto fail;
     $1 = (double *)(_PyVector$argnum->data);
     _PyVectorLength = _PyVector$argnum->dimensions[0];
};
%typemap(check) (const double x_array[]) {
     ;
};
%typemap(argfree) (const double x_array[]) {
     Py_XDECREF(_PyVector$argnum);
};
%typemap(check) size_t index{
     if($1 < 0){
	  PyErr_SetString(PyExc_ValueError, "The array index must be greater or equal to 0!");
	  goto fail;
     }
     if($1 >= _PyVectorLength){
	  PyErr_SetString(PyExc_ValueError, "The array index must not exceed the array length!");
	  goto fail;
     }
}
%apply(size_t index){size_t index_lo, size_t index_hi};
size_t gsl_interp_bsearch(const double x_array[], double x,
                          size_t index_lo, size_t index_hi);

