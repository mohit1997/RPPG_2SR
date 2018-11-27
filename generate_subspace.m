function [eigenvectors, eigenvalues, covariance] = generate_subspace(cur_frame)
    [~, skmap] = skinmap(cur_frame);
    red = cur_frame(:,:,1);
    red = red(skmap==1);
    green = cur_frame(:,:,2);
    green = green(skmap==1);
    blue = cur_frame(:,:,3);
    blue = blue(skmap==1);
    
    linear_image = double([red, green, blue]);
    
    covariance = (linear_image' * linear_image)/numel(cur_frame);
    [V,D] = eig(covariance);
    [D,I] = sort(diag(D),'descend');
    eigenvectors = V(:, I);
    eigenvalues = D;
end
