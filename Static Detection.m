clear all;
close all;
clc;

%step 1 is to generate a signal
L=6000
fc1=2000;
fc2=3000;
fs=12000;
	x=randn(1,L);
	b=1;a=1;
	if fc1==0 & fc2 < .5*fs
		[b,a]=butter(8,(2/fs)*fc2);
	end
	if fc1>0 & fc2<.5*fs
		[b,a]=butter(4,(2/fs)*[fc1,fc2]);
	end
	if fc1>0 & fc2 >.49*fs
		[b,a]=butter(4,(2/fs)*fc1,'high');
	end		
	y=filter(b,a,x);
    
    %step 2 adding awgn noise
    y=awgn(y,35,'measured');
    
    % step 3 finding fft
    
    nfft=12000;
    Y=fft(y,nfft);
    Y=Y(1:nfft/2);
    mx=abs(Y);
    f=(0:nfft/2-1)*fs/nfft;
    figure(1),plot(f,mx);
    
    %step 4 threshold detection
    
sum=0;
for i=1:(nfft/2)
    sum=sum+mx(i);
end
mean=sum/(nfft/2);
var=0;
sigma=0;
for i=1:(nfft/2)
    temp=mx(i)-mean;
    temp=power(temp,2);
    var=var+temp;
end
var=var/(nfft/2);
sigma=sqrt(var);
const=zeros(1,(nfft/2));
k=0;
th=mean+(k*sigma);
for i=1:(nfft/2)
if (mx(i)<th)
    const(i)=0;
else const(i)=1;
end
end
figure(2),plot(f,const);

%step 5 calculating efficiency
flag_1=0;
test=zeros(1,(nfft/2));
for i=fc1:fc2
    test(i)=1;
    flag_1=flag_1+1;
end
flag_0=(nfft/2)-flag_1;

count_D=0;
count_F=0;
for i=1:(nfft/2)
    if const(i)==1 && test(i)==1
        count_D=count_D +1;
    else if test(i)==0 && const(i)==1
            count_F=count_F+1;
        end
    end
end


Pd=(count_D/flag_1)*100;
Pf=(count_F/flag_0)*100;






    


