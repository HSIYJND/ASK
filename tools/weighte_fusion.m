function F = weighte_fusion( img,n )
    se_radius=1;
    [hei, wid, no_bands] = size(img);
    r = 71;
    N = boxfilter(ones(hei, wid), r);
    sigma_s = 1;
    grad_type = 'gaussian';
    for i=1:no_bands     
         [gx] = rescale_gradient(img(:,:,i), sigma_s, grad_type, false,img(:,:,i));
         [gy] = rescale_gradient(permute(img(:,:,i), [2 1 3]), sigma_s, grad_type, false, permute(img(:,:,i), [2 1 3]));
         gy = gy';
         g = abs(gx) + abs(gy);             
         g= boxfilter(g, se_radius) ./ N;
         S(:,:,i) = 1 -  boxfilter(1-g, se_radius) ./ N;
         P(:,:,i) = IWconstruct(S(:,:,i));
         B(:,:,i) = P(:,:,i).*img(:,:,i);
    end
    for j=1:n
        F(:,:,j)= mean(B(:,:,1+floor(no_bands/n)*(j-1):floor(no_bands/n)*j),3);
        if (floor(no_bands/n)*j~=no_bands)&&(j==n)
            F(:,:,j+1)= mean(B(:,:,1+floor(no_bands/n)*(j-1):floor(no_bands/n)*j),3);
        end
    end
end