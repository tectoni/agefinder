/***********/
/* Defines */
/***********/
#define kMaxLineLength		200
#define kZeroByte			0
#define  eps  1e-10
#define pi 3.14159265
#define lamb232		4.9475e-11
#define lamb235		9.8485e-10
#define lamb238		1.55125e-10

/***********************/
/* Global Definitions */
/***********************/

double  wtx[300], wty[300], w[300],  b, xbar, ybar; 
//double x[100], y[100], errx[100], erry[100];
//size_t N;

/***********************/
/* Struct Declarations */
/***********************/
typedef struct 
{
	float mswd;
	float inclination;
	float inclErr;
	float intersect;
	float interErr;
	float age;
	float ageErr;
} Fitdata;

/********************************/
/* Function Prototypes - main.c */
/********************************/
double			ApaAge( double, double, double);
double			CalcThStar( double, double, double);
void			Flush( void );
double			setThStarErr(double age, float thContent, float thErr, float uContent, float uErr, float thStar);
float			setApaAgeError(float age, float pbErr, float thStarErr);

Fitdata			DoYorkRegression( float *x, float *y, float *errx, float *erry , size_t N);
float CalcNewSlope(float lastSlope, float *x, float *y, size_t N);
float	InitialSlope(float *x, float *y, float *errx, float *erry, size_t numberOfData);		// Linear regression with least square minimation
//void			W_Mean( void );