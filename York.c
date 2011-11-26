//
//  York.m
//  DataLister
//
//  Created by Peter Appel on 28/10/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#import "York.h"


Fitdata DoYorkRegression(float *x, float *y, float *errx, float *erry , size_t N)
{
int  iter;
size_t i;
Fitdata fitresult;
double lastSlope, newSlope, u, v, xin ;
float s = 0.0;
float si = 0.0;
float sigma = 0.0;
float sigmai = 0.0;
double diff = 1.0;
float res = 0.0;
iter = 0;

for (i=0; i < N; i++) {
	printf("***********x  %lf y %lf\n", x[i], y[i]);
}

lastSlope = InitialSlope( x, y, errx, erry, N);
printf("InitialSlope: %lf  %d\n", lastSlope, N);

while ( diff > eps ) {
		iter++;
		newSlope = CalcNewSlope(lastSlope, x, y, N);
		diff = fabs(newSlope - lastSlope);
		lastSlope = newSlope;
		printf("Inclination: %lf %lf %d\n", newSlope, diff,  iter);

		}
	xin = ybar - newSlope * xbar;
		
		
		// equations page 1084 + 1085
	for (i=0; i < N; i++) {
	   u = x[i] - xbar;
	   v = y[i] - ybar;
	   sigma = sigma + w[i] * pow((newSlope*u-v), 2);
	   s = s + w[i]*u*u;
	   sigmai = sigmai + w[i] * pow(x[i], 2);
	   si = si + w[i];
	   
	   // Asami et al., 2002 Prec Res 114: p. 256
	   res = res + pow((y[i] - newSlope*x[i] - xin), 2) / ( pow(erry[i], 2) + pow(newSlope, 2) * pow(errx[i], 2)) ;
		}
		
	float mswd = res / (float)(N-2.0) ;
	
	sigma = sigma / (float)(N-2.0) / s;
	sigmai = sigma * sigmai / si;
	sigma = sqrt(sigma);			// still 1-sigma
	sigmai = sqrt(sigmai);			// still 1-sigma
	double a = 1.0/0.000049475 * log(1+newSlope*264.0/224.0);
	float sigmaAge =  2*  (1.0/0.000049475 * log(1+( newSlope + sigma) *264.0/224.0) - a);   // here: 2-sigma
printf("Inclination: %lf intercept %lf age %lf sigAge %lf sigma %lf sigmai %lf s %lf si %lf mswd %lf iter %d\n", newSlope, xin, a, sigmaAge, sigma, sigmai, s, si, mswd, iter);
fitresult.inclination = newSlope;
fitresult.intersect = xin;
fitresult.mswd = mswd;
fitresult.inclErr = sigma;
fitresult.interErr = sigmai;
fitresult.age = a;
fitresult.ageErr = sigmaAge;


return fitresult;
}


/*******************************************> Regrwt <*/

float CalcNewSlope(float lastSlope, float *x, float *y, size_t N)
{
int errIndi, i;
double alpha, beta, u, v, rphi, phi;
double xin, newSlope;
		
	for (i=0; i < N; i++) {
			w[i] = wtx[i] * wty[i] / (wtx[i] + pow(lastSlope, 2) * wty[i]);
			}

xbar = 0.0;
ybar = 0.0;
float sum = 0.0;

	for (i=0; i < N; i++) {
			xbar = xbar + w[i] * x[i];
			ybar = ybar + w[i] * y[i];
			sum = sum + w[i];
			}

xbar = xbar / sum;
ybar = ybar / sum;

double alphaNum = 0.0;
double denominator = 0.0;
double betaNum1 = 0.0;
double betaNum2 = 0.0;
double gamma = 0.0;

	for (i=0; i < N; i++) {
			u = x[i] - xbar;
			v = y[i] - ybar;
			alphaNum = alphaNum + pow(w[i], 2) * u * v / wtx[i];
			denominator = denominator + pow(w[i], 2) * pow(u, 2) / wtx[i];
			betaNum1 = betaNum1 + pow(w[i], 2) * pow(v, 2) / wtx[i];
			betaNum2 = betaNum2 + w[i] * pow(u, 2);
			gamma = gamma + w[i] * u * v;
			}

alpha = 2.0 / 3.0 * alphaNum / denominator;
beta = (betaNum1-betaNum2) / 3.0 / denominator;
gamma = - gamma/denominator;

if ( (pow(alpha, 2) - b) <= eps) {
	errIndi = 2;
	}
	
phi = (pow(alpha, 3) - 1.5 * alpha * beta + 0.5 * gamma) / pow((pow(alpha, 2) - beta), 1.5);
rphi = acos(phi);
rphi = rphi/3.0 + 4.0 * pi / 3.0;
newSlope = alpha + 2.0 * sqrt((pow(alpha, 2)-beta)) * cos(rphi);
return (newSlope);
}






/*******************************************> Solve <*/


float InitialSlope(float *x, float *y, float *errx, float *erry, size_t numberOfData)		// Linear regression with least square minimation
{
int i;
float   slope;	
float sxx = 0.0;
float syy = 0.0;
float sxy = 0.0;
float avex = 0.0;
float avey = 0.0;
float wavx = 0.0;
float wavy = 0.0;
float wx = 0.0;
float	wy = 0.0;
float	su = 0.0;
float	sv = 0.0;
	
	for ( i=0; i < numberOfData; i++) {
	   wtx[i] = 1.0 / pow(errx[i], 2);
	   wty[i] = 1.0 / pow(erry[i], 2);
	   wx = wx + wtx[i];
	   wy = wy + wty[i];
	   wavx = wavx + x[i] * wtx[i];
	   wavy = wavy + y[i] * wty[i];
	   avex = avex + x[i];
	   avey = avey + y[i];
	   su = su + pow(errx[i], 2);
	   sv = sv + pow(erry[i], 2);
	}
	
	su = su / (float)(numberOfData-1);
	sv = sv / (float)(numberOfData-1);
	
	avex = avex / numberOfData;
	avey = avey / numberOfData;
	
	wavx = wavx  /wx;
	wavy = wavy / wy;
	
	printf("avex avey %fl %fl  %d\n", avex, avey, numberOfData);
	for ( i=0; i < numberOfData; i++) {
	sxy = sxy + (x[i] - avex) * (y[i] - avey);
	sxx = sxx + pow((x[i] - avex), 2);
	syy = syy + pow((y[i] - avey), 2);
	printf("x y %fl %fl\n", x[i], y[i]);
	}

/*		
	ave(1) = avex;
	ave(2) = avey;
	ave(3) = wavx;
	ave(4) = wavy;
	sigma(1) = sxx;
	sigma(2) = syy;
	sigma(3) = sxy;
	sigma(4) = su/(n-1.);
	sigma(5) = sv/(n-1.);
*/

	slope = sxy / sxx;
//	intercept = meanY - slope * meanX;
	return  (slope);	
}

