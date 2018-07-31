function [PCP R] = PROX_eval_pck(proxes,test,proxnum)

globals;

% -------------------
% generate candidate stick
cnt = 0;
for n = 1:length(test)
  if test(n).label == 1
    if isempty(proxes(n).xy)
      continue;
    end
    cnt = cnt + 1;
    point = [proxes(n).xy(:,1)+proxes(n).xy(:,3) proxes(n).xy(:,2)+proxes(n).xy(:,4)]/2;
    ca(cnt).point = PROXopts(proxnum).transback * point;
  end
end

% -------------------
% generate ground truth stick
cnt = 0;
for n = 1:length(test)
  if test(n).label == 1
    if isempty(proxes(n).xy)
      continue;
    end
    cnt = cnt + 1;
    gt(cnt).point = PROXopts(proxnum).transback * test(n).point;
    gt(cnt).scale = test(n).scale;
  end
end

[PCP R] = eval_pck(ca,gt);