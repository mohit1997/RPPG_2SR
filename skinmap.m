function [out bin] = skinmap(img_orig)
%GENERATE_SKINMAP Produce a skinmap of a given image. Highlights patches of
%"skin" like pixels. Can be used in face detection, gesture recognition,
%and other HCI applications.

%   The function reads an image file given by the input parameter string
%   filename, read by the MATLAB function 'imread'.
%   out - contains the skinmap overlayed onto the image with skin pixels
%   marked in blue color.
%   bin - contains the binary skinmap, with skin pixels as '1'.
%
%   Example usage:
%       [out bin] = generate_skinmap('nadal.jpg');
%       generate_skinmap('nadal.jpg');
%
%   Gaurav Jain, 2010.
    
    if nargin > 1 | nargin < 1
        error('usage: generate_skinmap(image)');
    end;
    
    %Read the image, and capture the dimensions
    %img_orig = imread(filename);
    height = size(img_orig,1);
    width = size(img_orig,2);
    
    %Initialize the output images
    out = img_orig;
    bin = zeros(height,width);
    
    %Apply Grayworld Algorithm for illumination compensation
    img = img_orig;%grayworld(img_orig);    
    
    %Convert the image from RGB to YCbCr
    img_ycbcr = rgb2ycbcr(img);
    Cb = img_ycbcr(:,:,2);
    Cr = img_ycbcr(:,:,3);
    
    %Detect Skin
    [r,c,v] = find(Cb>=98 & Cb<=142 & Cr>=133 & Cr<=177);
    numind = size(r,1);
    
    %Mark Skin Pixels
    for i=1:numind
        out(r(i),c(i),:) = [0 0 255];
        bin(r(i),c(i)) = 1;
    end
end