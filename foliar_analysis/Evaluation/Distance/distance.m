function d = distance(X, Y, Distance)

    if strcmp('euclidean', Distance)
        d = euclidean(X,Y);
    elseif strcmp('mahalanobis', Distance)
        d = MahalanobisDistance(X,Y);
    elseif strcmp('manhattan', Distance)
        d = manhattan(X,Y);
    elseif strcmp('chebychev', Distance)
        d = chebychev(X,Y);
    elseif strcmp('cosine', Distance)
        d = cosine(X,Y);
    elseif strcmp('canberra', Distance)
        d = canberra(X,Y);
    elseif strcmp('chiSquare', Distance)
        d = chiSquare(X,Y);
    elseif strcmp('squaredChords', Distance)
        d = squaredChords(X,Y);
    end

end

function d = euclidean(A, B)
    d = sqrt(nansum((A-B).^2));
end

function d = manhattan(A, B)
    d = nansum(abs(A-B));
end

function d = chebychev(A, B)
    d = max(abs(A-B));
end

function d = cosine(A, B)
    d = 1 - ((A*B') / sqrt((A*A').*(B*B')));
end

function d = canberra(A, B)
    d = nansum(abs(A-B) / abs(A+B));
end

function d = chiSquare(A, B)
    d = sqrt(nansum(((A-B).^2) ./ abs(A+B)));
end

function d = squaredChords(A, B)
    d = nansum((sqrt(A) - sqrt(B)).^2);
end


function d = MahalanobisDistance(A, B)
    % Return mahalanobis distance of two data matrices 
    % A and B (row = object, column = feature)
    % @author: Kardi Teknomo
    % http://people.revoledu.com/kardi/index.html
    [n1, k1]=size(A);
    [n2, k2]=size(B);
    n=n1+n2;
    if(k1~=k2)
        disp('number of columns of A and B must be the same')
    else
        xDiff=mean(A)-mean(B);       % mean difference row vector
        cA=Covariance(A);
        cB=Covariance(B);
        pC=n1/n*cA+n2/n*cB;          % pooled covariance matrix
        d=sqrt(xDiff*inv(pC)*xDiff'); % mahalanobis distance
    end
end

function C = Covariance(X)
    % Return covariance given data matrix X (row=object, column=feature)
    [n,~] = size(X);
    Xc = X - repmat(mean(X), n, 1); % centered data
    C = Xc'*Xc/n; % covariance
end
