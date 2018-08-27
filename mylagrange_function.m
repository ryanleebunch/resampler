function y = mylagrange_function(xin,yin,t);
t0=xin(1);
t1=xin(2);
t2=xin(3);
t3=xin(4);
y0=yin(1);
y1=yin(2);
y2=yin(3);
y3=yin(4);
L0=((t-t1)/(t0-t1))*((t-t2)/(t0-t2))*((t-t3)/(t0-t3));
L1=((t-t0)/(t1-t0))*((t-t2)/(t1-t2))*((t-t3)/(t1-t3));
L2=((t-t0)/(t2-t0))*((t-t1)/(t2-t1))*((t-t3)/(t2-t3));
L3=((t-t0)/(t3-t0))*((t-t1)/(t3-t1))*((t-t2)/(t3-t2));
y=L0*y0+L1*y1+L2*y2+L3*y3;