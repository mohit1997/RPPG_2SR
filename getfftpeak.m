function [peakval, peakloc] = getfftpeak(pp,fs)

    N=2^nextpow2(length(pp));
    num_zeros=N-length(pp);
    z=padarray(pp',[0,num_zeros],'post');

    z=fftshift(fft(z));

    freqs=[-N/2:N/2-1]*(fs/N);
    subfreqs = freqs(freqs>0.7 & freqs < 2.5);
    subz = z(freqs>0.7 & freqs < 2.5);
    [maxval, maxind] = max(medfilt1(abs(subz)));
    peakloc = abs(subfreqs(maxind));
    peakval = maxval;

end
