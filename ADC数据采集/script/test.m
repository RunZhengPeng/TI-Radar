
close all;clc;clear
fileName = 'adc_data.bin';
[retVal] = read_adc_data_xwr16(fileName);
% 256samples, 128chirps, 8frame
Ns=256;
Nc=128;
Nframe=8;
ch1data = reshape(retVal(1,:),Ns,Nc,Nframe);

frame = ch1data(:,:,1);
figure;mesh(abs(frame));title('ADC Data')
xlabel('chirps');ylabel('samples')

chirp = frame(:,1);
figure;plot(real(chirp),'b','DisplayName','real');hold on;plot(imag(chirp),'r','DisplayName','imag')
legend show;grid on

rangefft = fft(frame.*hanning(Ns),Ns,1);
figure;mesh(db(abs(rangefft)))

dopplerfft = fftshift(fft(rangefft.*hanning(Nc)',Nc,2),2);
figure;mesh(db(abs(dopplerfft)));title('RD Map')
xlabel('samples');ylabel('chirps')
