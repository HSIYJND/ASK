function simage  = Tsmoothimg(img)

% bands=size(img,3);
% if floor(bands)==0
%     simage =artv(img,0.03,2);
% else
% for i=1:floor(bands)
% simage(:,:,(i-1)+1:i)=artv(img(:,:,(i-1)+1:i),0.03,2);
% end
% if floor(bands)<bands
%    simage(:,:,i+1:bands)=artv(img(:,:,i+1:bands),0.03,2);
% end
% end
ss = 4;
sr = 0.12;
se = 0.07;
niter = 2;
% [res, scale] = safiltering(img, ss, sr, niter, se);
bands=size(img,3);
if floor(bands)==0
    simage =safiltering(img,ss, sr, niter, se);
else
for i=1:floor(bands)
% simage(:,:,(i-1)+1:i)=artv(img(:,:,(i-1)+1:i),0.03,2);
simage(:,:,(i-1)+1:i) = safiltering(img(:,:,(i-1)+1:i), ss, sr, niter, se);
end
if floor(bands)<bands
    simage(:,:,i+1:bands) = safiltering(img(:,:,i+1:bands), ss, sr, niter, se);
%    simage(:,:,i+1:bands)=artv(img(:,:,i+1:bands),0.03,2);
end
end