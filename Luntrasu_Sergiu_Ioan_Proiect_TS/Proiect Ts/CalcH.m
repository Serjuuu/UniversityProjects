R1=33 * 10e3;
R2=33 * 10e3;
R3=1.5 * 10e3;
C1=2.2 * 10e-6;
C2=2.2 * 10e-6;
C3=4.7 * 10e-6;


A=[-1/(R3*C1),  0, -1/(R2*C1);
   0,0,-1/(R2*C2);
   1/(R1*C3), 1/(R1*C3), (-1/C3)*(1/R1+1/R2)];

B=[1/(R3*C1);0;0];
C=[-1,-1,0];
D=[1];
sys=ss(A,B,C,D);
[num,den]=ss2tf(A,B,C,D);
H=tf(num,den)
min = zpk(minreal(H));