function [x, newstate] = pngen(n, oldstate)
% [x, newstate] = pngen(n, oldstate)
%
% PN-Generator, wie er bei WLAN verwendet wird. Er liefert n bits der
% Pseudozufallsfolge. Falls kein oldstate übergeben wird, wird stets im
% all-"1" Zustand begonnen. In diesem Zustand beginnt die Folge mit
% "00001110..."
%
% Um das Steuersignal für die Pilotträger zu erhalten sollte x wie folgt
% umgerechnet werden:
%
%    xpilot = -2*x + 1;

% S(x) = x^7 + x^4 + 1
p = [1 0 0 1 0 0 0]; % 1 ]

lp = length(p);

% Im einfachen Fall
if nargin == 1
    oldstate = ones(1,lp);
end

newstate = oldstate;

x = zeros(1, n);
for j = 1:n
    msb = mod(sum(p .* newstate), 2);
    newstate = [newstate(2:lp) msb];
    x(j) = msb;
end
