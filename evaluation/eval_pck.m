function [PCP Rate] = eval_pcp(ca,gt,thresh)

if nargin < 4
  thresh  = 0.5;
end

assert(numel(ca) == numel(gt));

for n = 1:length(gt)
  dist(:,n) = sqrt(sum((ca(n).point-gt(n).point).^2,2));
end

Rate = mean(dist < thresh * gt(n).scale,2);
PCP = mean(Rate);
Rate = Rate';