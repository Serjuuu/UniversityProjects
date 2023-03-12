R1=10 * 10e3;
R2=10 * 10e3;
R3=4.7 * 10e3;
C1=2.2 * 10e-6;
C2=2.2 * 10e-6;
C3=4.7 * 10e-6;
A=[-1/(R3*C1), 0, -1/(R2*C1); 0,0,-1/(R2*C2);1/(R1*C3), 1/(R1*C3), (-1/C3)*(1/R1+1/R2)];
B=[1/(R3*C1);0;0];
C=[-1,-1,0];
D=[1];
sys=ss(A,B,C,D);
[num,den]=ss2tf(A,B,C,D);
H=tf(num,den)
pole(H)
zero(H);

%%
H2 = zpk([-0.4536, 0.0141 + 0.4539i, 0.0141 - 0.4539i], [-0.7562, -0.3182 + 0.1497i, -0.3182 - 0.1497i],1)
%%
p1=plot(-0.4356,0,'ro','MarkerSize',8);grid
hold on
plot(0.0141,-0.4539i,'ro','MarkerSize',8)
plot(0.0141,0.4539i,'ro','MarkerSize',8);
xlim([-35 10])
ylim([-10 10])
plot(-100:100,1,'k')
xline(0,'LineWidth',2)
yline(0,'LineWidth',2)
p2=plot(-0.7562,0,'mx','MarkerSize',15);
plot(-0.3182,0.1497i,'mx','MarkerSize',15)
plot(-0.3182,-0.1497i,'mx','MarkerSize',15)
legend([p1 p2],'poli','zerouri')
title("Reprezentarea singularităților în planul complex")
xlabel('X');
ylabel('jY');
%%
num_ext = [num zeros(1,5)];
gamma = deconv(num_ext,den);
min = zpk(minreal(H));
%%
[num,den] = tfdata(min, 'v');
[A_FCC, B_FCC, C_FCC, D] = tf2ss(num,den);
A_FCO = A_FCC';
B_FCO = C_FCC';
C_FCO = B_FCC';

sys_fco = ss(A_FCO, B_FCO, C_FCO, D)
%%
Q = eye(length(A));
P = lyap(A' ,Q)
eig(P)
sys = ss(A, B, C, D);
t = 0:0.1:0.4;
step_f = @(t)(t>=0);
st = step_f(t);
[~, time, x] = lsim(sys, st, t);

Vx = zeros(length(t), 1);
for i = 1:length(t)
    Vx(i) = x(i,:) * P * x(i, :)';
end
figure
plot(t, Vx);
grid;
 
 
