# Energy-Detector---Statistical
The following code is the energy detector built for the final year project of Amrita Vishwa Vidyapeetham. Detailed descriptions will be updated soon

Edit 1:
The five codes which cover the entire project are to be exectued in the following order.

1. static detection.m:
  This code is a basic implementation of the threshold estimation based on image binarization. We need to set a            particular K and give the signal as an input to get its output Pd, Pf, Pm and Pr.

2. Dynamic detection.m:
  This code computes the most efficient K and its corresponding Pd for a set Pf and given input signal.

3. ROC.m
  This code computes the ROC curve for different SNR for a given signal.

4. Effi_k
  This code generates the reference K array for an AWGN signal with a set Pf and a set SNR. This code runs a total of 100 times and will need atleast 3hrs and 20 mins on a regular laptop to execute.

5.Error_correction.m:
  This code blindly computes and identifies the required K for any given input signal using the reference array. 
  NOTE: please execute code 4 and save the reference array before executing code 5.
