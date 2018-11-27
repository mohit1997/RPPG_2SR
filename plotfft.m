function []=plotfft(pp,fs)

    N=2^nextpow2(length(pp));
    num_zeros=N-length(pp);
    z=padarray(pp',[0,num_zeros],'post');

    z=fftshift(fft(z));

    freqs=[-N/2:N/2-1]*(fs/N);


    plot(freqs,abs(z))
end