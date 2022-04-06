alpha = 18.2/180*pi;

% dir = [-tan(alpha) ; 1];
g = [1; tan(alpha)]; % g = dir^{\perp}
g = g/norm(g,2);
G = g*g';

GTfield = ones(180,300,3);
GTfield(:,:,1) = G(1,1);
GTfield(:,:,2) = G(1,2);
GTfield(:,:,3) = G(2,2);

experiment('synth',[6 99 1 1],GTfield);
clear