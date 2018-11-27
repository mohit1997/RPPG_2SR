function [ ] = ssr( video_path, stride_length, frame_rate, window_size )
    if ~exist('video_path','var')
        video_path = 'test.avi';
    end
    if ~exist('stride_length','var')
        stride_length = 10;
    end
    if ~exist('frame_rate','var')
        frame_rate = 25;
    end
    if ~exist('window_size','var')
        window_size = 200;
    end

    vid_obj = VideoReader(video_path);
    est_frames = ceil(vid_obj.FrameRate*vid_obj.Duration);
    L = stride_length;
    frame = 1;
    HeartRate = zeros(est_frames,1);
    U = zeros(3,3,est_frames);
    E = zeros(est_frames,3);
    
    % Note: The last frame entries for R, S, SR, ProjectedSR shall always
    % be 0
    
    R = zeros(est_frames,2);
    S = zeros(est_frames,2);
    SR = zeros(est_frames,2);
    ProjectedSR = zeros(est_frames,3);
    
    cur_frame = readFrame(vid_obj);
    
    [U(:,:,frame), E(frame,:), ~] = generate_subspace(cur_frame);
    
    while hasFrame(vid_obj)
        frame = frame + 1;
        ref = floor((frame-1)/L);
        ref_frame = ref*L + 1;
        cur_frame = readFrame(vid_obj);
        [U(:,:,frame), E(frame,:), ~] = generate_subspace(cur_frame);
        R(frame-1,:) = [U(:,1,frame)' * U(:,2,ref_frame), U(:,1,frame)' * U(:,3,ref_frame)];
        S(frame-1,:) = [sqrt(E(frame,1)/E(ref_frame,2)), sqrt(E(frame,1)/E(ref_frame,3))];
        SR(frame-1,:) = S(frame-1,:) .* R(frame-1,:);
        ProjectedSR(frame-1,:) = SR(frame-1,:) * [U(:,2,ref_frame)'; U(:,3,ref_frame)'];
        
        % Window Characteristics, Can be Vectorized outside the loop, or in
        % a MultiThreaded/MultiProcess case, evaluated in a different
        % thread/process for faster computation.
        
        if (frame > window_size +1)
           window_start = frame - window_size - 1;
           window_end = frame - 1;
           WindowedSR = ProjectedSR(window_start:window_end,:);
           WindowedBoostFactor = std(WindowedSR(:,1))/std(WindowedSR(:,2));
           WindowedPP = WindowedSR(:,1) - WindowedBoostFactor * WindowedSR(:,2);
           WindowedPP = WindowedPP - mean(WindowedPP);
           
           [~, pkloc] = getfftpeak(WindowedPP, frame_rate);
           BPM = pkloc * 60;
           HeartRate(frame - 1,1) = BPM;
        end
        
    end
    numFrames = frame - 1;
    
    % Complete Signal Characteristics
    boost_factor = std(ProjectedSR(1:numFrames,1))/std(ProjectedSR(1:numFrames,2));
    pp = ProjectedSR(:,1) - boost_factor * ProjectedSR(:,2);
    pp = pp - mean(pp);
    
    % plotfft(pp, frame_rate);
    frame_sequence = window_size:numFrames;
    frame_sequence = double(frame_sequence)/25;
    plot(frame_sequence, HeartRate(window_size:numFrames));
    

end

