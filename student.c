/*
 *  student.c
 *  
 *
 *  Created by Peter Appel on 12/11/2008.
 *  Copyright 2008 __MyCompanyName__. All rights reserved.
 *
 */
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "student.h"


float Norm_z(float p) {
// Returns z given a half-middle tail type p.

    float a0= 2.5066282,  a1=-18.6150006,  a2= 41.3911977,   a3=-25.4410605,
        b1=-8.4735109,  b2= 23.0833674,  b3=-21.0622410,   b4=  3.1308291,
        c0=-2.7871893,  c1= -2.2979648,  c2=  4.8501413,   c3=  2.3212128,
        d1= 3.5438892,  d2=  1.6370678, r, z;
 
    if (p>0.42) {
        r=sqrt(-log(0.5-p));
        z=(((c3*r+c2)*r+c1)*r+c0)/((d2*r+d1)*r+1);
    }
    else {
        r=p*p;
        z=p*(((a3*r+a2)*r+a1)*r+a0)/((((b4*r+b3)*r+b2)*r+b1)*r+1);
    }
    return z;
}



float Hills_inv_t(p, df) {
// Hill's approx. inverse t-dist.: Comm. of A.C.M Vol.13 No.10 1970 pg 620.
// Calculates t given df and two-tail probability.
    float a, b, c, d, t, x, y;
        if      (df == 1) 
		t = cos(p*PI/2)/sin(p*PI/2);
	else if (df == 2) t = sqrt(2/(p*(2 - p)) - 2);
        else {
	    a = 1/(df - 0.5);
	    b = 48/(a*a);
	    c = ((20700*a/b - 98)*a - 16)*a + 96.36;
	    d = ((94.5/(b + c) - 3)/b + 1)*sqrt(a*PI*0.5)*df;
	    x = d*p;
	    y = pow(x, 2/df);
	    if (y > 0.05 + a) {
	        x = Norm_z(0.5*(1 - p)); 
		y = x*x;
		if (df < 5) c = c + 0.3*(df - 4.5)*(x + 0.6);
		c = (((0.05*d*x - 5)*x - 7)*x - 2)*x + b + c;
		y = (((((0.4*y + 6.3)*y + 36)*y + 94.5)/c - y - 3)/b + 1)*x;
		y = a*y*y;
		if (y > 0.002) y = exp(y) - 1;
	  	else y = 0.5*y*y + y;
	        t = sqrt(df*y);
	    }            
	    else {
		y = ((1/(((df + 6)/(df*y) - 0.089*d - 0.822)*(df + 2)*3) 
		    + 0.5/(df + 4))*y - 1)*(df + 1)/(df + 2) + 1/y;
	        t = sqrt(df*y);
            }
    }
    return t;
}
