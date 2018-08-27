close all
clear all
N=2^3;
bin=1;
n=0:N-1;
sig=1.0*sin(2*pi*(bin/N)*n);
plot(n,sig,'b*')
np=n(1:end-1)+0.5;
y = lagrangeinterp(n,sig,np);
%y = interp1(n,sig,np,'spline');
plot(n,sig,'b*')
hold on
plot(np,y,'r*')
nfine=linspace(n(1),n(end),10000);
sigfine=1.0*sin(2*pi*(bin/N)*nfine);
plot(nfine,sigfine,'k-')
error=y-1.0*sin(2*pi*(bin/N)*np);
figure
plot(error)./y
