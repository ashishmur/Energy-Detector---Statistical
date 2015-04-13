clear all;
close all;
clc;
L=2000000;                                                                  %Maximum frequency to scan.
fs_temp=4000000;                                                            %Sampling rate of the transmitted singal. Ensure atleast 2*L
snr=10;                                                                     %Signal to noise ratio of AWGN Channel.
fs=1024;                                                                    %Sampling rate at cognitive radio / Energy Detector.
nfft=2048;                                                                  %Number of FFT points. Ensure it is atleast 2*fs
k=-0.03;                                                                    % Value of the standard deviation coefficient. Takes values from -1 t0 1.
%step 1 is to generate a signal
fc1=input('enter lower bandwidth of transmitted signal \n');                % lower bandwidth of the signal
fc2=input('enter upper bandwidth of transmitted signal \n');                % Upper Bandwidth of the Signal

	x=randn(1,L);
	b=1;a=1;
	if fc1==0 & fc2 < .5*fs_temp
		[b,a]=butter(8,(2/fs_temp)*fc2);
	end
	if fc1>0 & fc2<.5*fs_temp
		[b,a]=butter(4,(2/fs_temp)*[fc1,fc2]);
	end
	if fc1>0 & fc2 >.49*fs_temp
		[b,a]=butter(4,(2/fs_temp)*fc1,'high');
	end		
	tx=filter(b,a,x);                                                       % tx is the transmitted signal.
    %step 2 adding awgn noise
    y=awgn(tx,snr,'measured');
    
    % step 3 finding fft
    Y=fft(y,nfft);
    Y=Y(1:nfft/2);
    mx=abs(Y);
    f=(0:nfft/2-1)*fs/nfft;
    figure(1),plot(f,mx);
    
    %step 4 threshold detection
 for i=1:(nfft/2)
    mx(i)=power(mx(i),2);
end   
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
res=(L/(nfft/2));
beg=int32(fc1/res)+1;
last=int32(fc2/res)+1;
for i=beg:last
    test(i)=1;
    flag_1=flag_1 +1;
end
flag_0=(nfft/2)-flag_1;

count_D=0;
count_F=0;
count_R=0;
count_M=0;
for i=1:(nfft/2)
    if const(i)==1 && test(i)==1
        count_D=count_D+1;
    else if test(i)==0 && const(i)==1
            count_F=count_F+1;
        end
    end
end

for i=1:(nfft/2)
    if const(i)==0 && test(i)==0
        count_R=count_R+1;
    else if test(i)==1 && const(i)==0
            count_M=count_M+1;
        end
    end
end

Pd=(count_D/flag_1)
Pf=(count_F/flag_0)
Pm=(count_M/flag_1)
Pr=(count_R/flag_0)
