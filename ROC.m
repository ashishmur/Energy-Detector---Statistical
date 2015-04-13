clear all;
close all;
clc;

%step 1 is to generate a signal
L=2000000;                                                                  %Maximum frequency to scan.
fs_temp=4000000;                                                            %Sampling rate of the transmitted singal. Ensure atleast 2*L
snr=-5;                                                                     %DO NOT EDIT | Signal to noise ratio of AWGN Channel.
fs=1024;                                                                    %Sampling rate at cognitive radio / Energy Detector.
nfft=2048;                                                                  %Number of FFT points. Ensure it is atleast 2*fs
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
	tx=filter(b,a,x);                                                       %Transmitted singal Represented by Tx.
    
    
    for index=1:3                                                           % Plotting thrice for three different SNR: 5 dB, 10dB, 15dB
    %step 2 adding awgn noise
    snr=snr+5
    y=awgn(tx,snr,'measured');                                              %Received signal y with noise
    
    % step 3 finding fft
    Y=fft(y,nfft);                                                          %Frequency domain representation of received singal as Y.
    Y=Y(1:nfft/2);
    mx=abs(Y);                                                              %Magnitude of the fft of the received singal
    f=(0:nfft/2-1)*fs/nfft;                                                 %Calculating the frequency axis
    figure(1),plot(f,mx);
    
    
    %step 4 threshold detection
 for i=1:(nfft/2)
    mx(i)=power(mx(i),2);
end   
sum=0;
for i=1:(nfft/2)
    sum=sum+mx(i);                                                          %Calculating the sum of all frequency bands
end
mean=sum/(nfft/2);                                                          %Estimating the mean of the received singal.
var=0;
sigma=0;
for i=1:(nfft/2)
    temp=mx(i)-mean;
    temp=power(temp,2);
    var=var+temp;                                                           %Calculating the variance of the energy of different bands
end
var=var/(nfft/2);
sigma=sqrt(var);                                                            %Calculating the standard deviation from the variance
const=zeros(1,(nfft/2));                                                    %Creating output array to hold the final decision


k=-1;
    for iter=1:200
        k=k+0.01;                                                           %Varying k from -1 to 1.

th=mean+(k*sigma);                                                          %Calculating the threshold using image binarization technique.
for i=1:(nfft/2)
if (mx(i)<th)
    const(i)=0;                                                             %Generating the decision for each band.
else const(i)=1;
end
end
figure(2),plot(f,const);

%step 5 calculating efficiency
flag_1=0;
test=zeros(1,(nfft/2));                                                     
res=(L/(nfft/2));                                                           %Frequency resolutiuon of the detetctor.
beg=int32(fc1/res);                                                         %Band where the lower frequency of transmitted signal exists.
last=int32(fc2/res);                                                        %Band where the upper frequency of transmitted singal exists.
for i=beg:last
    test(i)=1;                                                              %Generating the actual decision array based on known transmotted signal.
    flag_1=flag_1 +1;
end
flag_0=(nfft/2)-flag_1;

count_D=0;
count_F=0;
for i=1:(nfft/2)
    if const(i)==1 && test(i)==1
        count_D=count_D+1;                                                  %Calculating the number of bands correctly detected as primary user.
    else if test(i)==0 && const(i)==1
            count_F=count_F+1;                                              %Number of bands that have been incorrectly detected as primary user.
        end
    end
end

% Performance metrics
Pd(iter)=(count_D/flag_1)                                                   %Probability of Detection
Pf(iter)=(count_F/flag_0)                                                   %Probability of false alarm
    end   
    figure(3), plot(Pf,Pd);
hold on
    end


    


