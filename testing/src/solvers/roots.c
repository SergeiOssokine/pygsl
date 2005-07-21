#include <gsl/gsl_roots.h>
const struct _GSLMethods 
root_f   = { (void_m_t) gsl_root_fsolver_free,   
	    /* gsl_multimin_fminimizer_restart */  (void_m_t) NULL,
	    (name_m_t) gsl_root_fsolver_name,   
	      (int_m_t) gsl_root_fsolver_iterate},
root_fdf   = { (void_m_t) gsl_root_fdfsolver_free,   
	    /* gsl_multimin_fminimizer_restart */  (void_m_t) NULL,
	    (name_m_t) gsl_root_fdfsolver_name,   
	    (int_m_t) gsl_root_fdfsolver_iterate};


static PyObject* 
PyGSL_root_f_root(PyGSL_solver *self, PyObject *args) 
{
     return PyGSL_solver_ret_double(self, args, (double_m_t) gsl_root_fsolver_root);
}

static PyObject* 
PyGSL_root_fdf_root(PyGSL_solver *self, PyObject *args) 
{
     return PyGSL_solver_ret_double(self, args, (double_m_t) gsl_root_fdfsolver_root);
}

static PyObject* 
PyGSL_root_x_lower(PyGSL_solver *self, PyObject *args) 
{
     return PyGSL_solver_ret_double(self, args, (double_m_t) gsl_root_fsolver_x_lower);
}

static PyObject* 
PyGSL_root_x_upper(PyGSL_solver *self, PyObject *args) 
{
     return PyGSL_solver_ret_double(self, args, (double_m_t) gsl_root_fsolver_x_upper);
}

static PyObject*
PyGSL_root_solver_test_interval(PyGSL_solver * self, PyObject *args)
{
     double epsabs, epsrel;
     gsl_root_fsolver *s = (gsl_root_fsolver *) self->solver;
     if(!PyArg_ParseTuple(args, "dd", &epsabs, &epsrel))
	  return NULL;
     return PyInt_FromLong(gsl_root_test_interval(s->x_lower, s->x_upper, epsabs, epsrel));
}

static PyObject* 
PyGSL_root_set_f(PyGSL_solver *self, PyObject *args, PyObject *kw) 
{
     return _PyGSL_solver_set_f(self, args, kw, (void *)gsl_root_fsolver_set, 0); 
}

static PyObject* 
PyGSL_root_set_fdf(PyGSL_solver *self, PyObject *args, PyObject *kw) 
{
     return _PyGSL_solver_set_f(self, args, kw,  (void *)gsl_root_fdfsolver_set, 1); 
}

static PyMethodDef PyGSL_root_fmethods[] = {     
     {"root",      (PyCFunction)PyGSL_root_f_root,     METH_NOARGS, (char *)root_f_root_doc}, 
     {"x_lower",   (PyCFunction)PyGSL_root_x_lower,    METH_NOARGS, (char *)root_x_lower_doc}, 
     {"x_upper",   (PyCFunction)PyGSL_root_x_upper,    METH_NOARGS, (char *)root_x_upper_doc}, 
     {"set",       (PyCFunction)PyGSL_root_set_f,      METH_VARARGS|METH_KEYWORDS, (char *)root_set_f_doc}, 
     {"test_interval",(PyCFunction)PyGSL_root_solver_test_interval, METH_VARARGS, NULL},      
     {NULL, NULL, 0, NULL}           /* sentinel */
};
static PyMethodDef PyGSL_root_fdfmethods[] = {     
     {"root",      (PyCFunction)PyGSL_root_fdf_root,     METH_NOARGS, (char *)root_fdf_root_doc}, 
     {"set",       (PyCFunction)PyGSL_root_set_fdf,      METH_VARARGS|METH_KEYWORDS, (char *)root_set_fdf_doc}, 
     {NULL, NULL, 0, NULL}           /* sentinel */
};

const struct _SolverMethods root_solver_f = {1, PyGSL_root_fmethods},
root_solver_fdf = {3, PyGSL_root_fdfmethods};

static PyObject* 
PyGSL_root_f_init(PyObject *self, PyObject *args, 
		 const gsl_root_fsolver_type * type) 
{

     PyObject *tmp=NULL;
     solver_alloc_struct s = {type, (void_an_t) gsl_root_fsolver_alloc,
			      root_f_type_name, &root_solver_f, &root_f};
     FUNC_MESS_BEGIN();     
     tmp = _PyGSL_solver_1_init(self, args, &s);
     FUNC_MESS_END();     
     return tmp;
}

static PyObject* 
PyGSL_root_fdf_init(PyObject *self, PyObject *args, 
		 const gsl_root_fdfsolver_type * type) 
{

     PyObject *tmp=NULL;
     solver_alloc_struct s = {type, (void_an_t) gsl_root_fdfsolver_alloc,
			      root_fdf_type_name, &root_solver_fdf, &root_fdf};
     FUNC_MESS_BEGIN();     
     tmp = _PyGSL_solver_1_init(self, args, &s);
     FUNC_MESS_END();     
     return tmp;
}

#define AROOT_F(name)                                                  \
static PyObject* PyGSL_root_init_ ## name (PyObject *self, PyObject *args)\
{                                                                             \
     PyObject *tmp = NULL;                                                    \
     FUNC_MESS_BEGIN();                                                       \
     tmp = PyGSL_root_f_init(self, args,  gsl_root_fsolver_ ## name); \
     if (tmp == NULL){                                                        \
	  PyGSL_add_traceback(module, __FILE__, __FUNCTION__, __LINE__); \
     }                                                                        \
     FUNC_MESS_END();                                                         \
     return tmp;                                                              \
}
#define AROOT_FDF(name)                                                  \
static PyObject* PyGSL_root_init_ ## name (PyObject *self, PyObject *args)\
{                                                                             \
     PyObject *tmp = NULL;                                                    \
     FUNC_MESS_BEGIN();                                                       \
     tmp = PyGSL_root_fdf_init(self, args,  gsl_root_fdfsolver_ ## name); \
     if (tmp == NULL){                                                        \
	  PyGSL_add_traceback(module, __FILE__, __FUNCTION__, __LINE__); \
     }                                                                        \
     FUNC_MESS_END();                                                         \
     return tmp;                                                              \
}
AROOT_F(bisection)
AROOT_F(falsepos)
AROOT_F(brent)
AROOT_FDF(newton)
AROOT_FDF(secant)
AROOT_FDF(steffenson)


static PyObject*
PyGSL_root_test_delta(PyObject * self, PyObject *args)
{
     double x_lower, x_upper, epsabs, epsrel;
     if(!PyArg_ParseTuple(args, "dddd", &x_lower, &x_upper, &epsabs, &epsrel))
	  return NULL;
     return PyInt_FromLong(gsl_root_test_delta(x_lower, x_upper, epsabs, epsrel));
}

static PyObject*
PyGSL_root_test_interval(PyObject * self, PyObject *args)
{
     double x_lower, x_upper, epsabs, epsrel;
     if(!PyArg_ParseTuple(args, "dddd", &x_lower, &x_upper, &epsabs, &epsrel))
	  return NULL;
     return PyInt_FromLong(gsl_root_test_interval(x_lower, x_upper, epsabs, epsrel));
}
