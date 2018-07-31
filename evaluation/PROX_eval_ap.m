function [ap prec rec randap] = PROX_eval_ap(proxes,test)

globals;

% -------------------
% generate candidate stick
score = [proxes.score];
score(isnan(score)) = min(score);

% -------------------
% generate ground truth stick
label = [test.label];

[prec tpr fpr thresh] = prec_rec(score,label,'plotPR',1,'plotBaseline',1);
prec = [1; prec];
rec = [0; tpr];
ap = VOCap(rec,prec);

randap = sum(label)/length(label);