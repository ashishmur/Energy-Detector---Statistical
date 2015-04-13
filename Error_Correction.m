% Building a code to calculate the fiicient k by plotting the indexes based on bandwidth
%NOTE: please load the effi_k array before executing this code.
%step 1 is to generate a signal
L=2000000;                                                                  %MAXIMUM bandwidth of the transmitted signal.
fc1=input('enter lower bandwidth of transmitted signal \n');
fc2=input('enter upper bandwidth of transmitted signal \n');
fs_temp=4000000;                                                            %SAMPLING RATE of transmitted signal. 2*L.
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
    fs=1024;                                                                %SAMPLING RATE of the cognitive radio / Energy Detector.
    snr=10;                                                                 %Desired Signal to Noise Ratio
    
    y=awgn(tx,snr,'measured');                                              %Adding AWGN to the signal and assuming y to be received signal.
    
    % step 2 finding fft
    
    nfft=2048;                                                              %number of fft points
    Y=fft(y,nfft);                                                          %Frequency domain representation of y represented as Y.
    Y=Y(1:nfft/2);                                                          %taking only first half of the output FFT.
    mx=abs(Y);
    f=(0:nfft/2-1)*fs/nfft;                                                 %frequency axis
    figure(1),plot(f,mx);                                                   %Frequency Spectrum of Received Signal.
    
    %step 3 threshold detection
     for i=1:(nfft/2)
     mx(i)=power(mx(i),2);                                                  %Finding energy of FFT bins
     end   
     k=0;
    estimated_ratio=zeros(1,100);
    final_k=0;
    for index=1:100
        k=effi_k(index);                                                    %Choosing a K value from the effi_K reference array
        sum=0;
        for i=1:(nfft/2)
            sum=sum+mx(i);                                                  %Finding sum of energies of all FFT bins.
        end
        mean=sum/(nfft/2);                                                  %Finding mean energy of the signal
        var=0;
        sigma=0;
        for i=1:(nfft/2)
            temp=mx(i)-mean;
            temp=power(temp,2);
            var=var+temp;                                                   %Finding variance of each bin.
        end
        var=var/(nfft/2);
        sigma=sqrt(var);                                                    %Finding standard Deviation of the singal.
        const=zeros(1,(nfft/2));
        th=mean+(k*sigma);                                                  %Computing threshold using image binarization formula.
        for i=1:(nfft/2)
            if (mx(i)<th)
                const(i)=0;                                                 %Computing the Decision metric.
            else const(i)=1;
            end
        end

%step 4 calculating efficient K
        
        count_estimated_flag_1=0;
        for i=1:(nfft/2)
            if const(i)==1
                count_estimated_flag_1=count_estimated_flag_1+1;            %Counting number of bins that have been detected as a primary user
            end
        end
        
        estimated_ratio(index)=(count_estimated_flag_1/(nfft/2))*100;       %Estimating the ratio of frequency identified to belong to a primary user.
        estimated_ratio(index)=int32(estimated_ratio(index));

    end
    axis=zeros(1,100);
    for index=1:100
    axis(index)=index;
    end
   
  figure(3), plot(estimated_ratio);
   hold on;
  figure(3), plot(axis);
   final_i=0;
   error=100;
   for i=1:50                                                               %Estimating the actual K Value which should be used based on error correction
       if abs(estimated_ratio(i)-i) < error
           error=abs(estimated_ratio(i)-i);                                 %Note: The error correction works only when the ratio is less than 50%
           final_i=i;
       end
   end
  final_k=effi_k(final_i)                                                   %Final K to be used
  final_i                                                                   %Final occupancy ratio of the detected singal.
