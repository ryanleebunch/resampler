function y = lagrangeinterp(x1,y1,x);

L=length(x);
Lx1=length(x1);
ytemp=0*x;
for ii=1:L   
    ii;
    jj=find(x1 >= x(ii),1);
    if (jj<3)
        ytemp(ii)=mylagrange_function(x1(1:4),y1(1:4),x(ii));
    elseif (jj>(Lx1-1))
        ytemp(ii)=mylagrange_function(x1(Lx1-3:Lx1),y1(Lx1-3:Lx1),x(ii));
    else
        ytemp(ii)=mylagrange_function(x1(jj-2:jj+1),y1(jj-2:jj+1),x(ii));
    end
end   

y=ytemp;
