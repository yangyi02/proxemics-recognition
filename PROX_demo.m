clc; close all; clear;
globals;

proxnum = 1;
name = PROXopts(proxnum).name;
[trainset testset] = PROX_data(name,proxnum);

% traing the proxemic model
for subnum = 1:length(PROXopts(proxnum).submix)  
  % train every submixture
  subname = PROXopts(proxnum).submix(subnum).name;
  [pos neg1 neg2 test] = PROXSUB_data(subname,proxnum,subnum);
  model{subnum} = trainmodel(subname,pos,neg1,neg2,PROXopts(proxnum).K,PROXopts(proxnum).pa,PROXopts(proxnum).co);
  suffix = ['train_' num2str(PROXopts(proxnum).K')'];
  subproxes_train = testmodel(subname,model{subnum},trainset,suffix);

  % calibrate the model using logistic regression
  X = cat(1,subproxes_train.score)';
  X(isnan(X)) = min(X);
  X = cat(1,X,ones(1,size(X,2)));
  Y = zeros(1,length(trainset));
  for n = 1:length(trainset)
    Y(n) = trainset(n).label(subnum);
  end
  Z = [Y; 1-Y];
  beta{subnum} = logistK(X,Z);
end

% test model on testing set using ground truth face location
for subnum = 1:length(PROXopts(proxnum).submix)  
  subname = PROXopts(proxnum).submix(subnum).name;
  suffix = ['test_' num2str(PROXopts(proxnum).K')'];
  subproxes_test = testmodel(subname,model{subnum},testset,suffix);
  
  Xt = cat(1,subproxes_test.score)';
  Xt(isnan(Xt)) = min(Xt);
  Xt = cat(1,Xt,ones(1,size(Xt,2)));
  Yt = logistK_eval(beta{subnum},Xt);
  Zt(subnum,:) = Yt(1,:);
end

for n = 1:length(testset)
  proxes_test(n).score = max(Zt(:,n));
end

[ap prec rec] = PROX_eval_ap(proxes_test,testset);
fprintf('ap=%.1f\n',ap*100);

% test model on testing set using detected face location
for subnum = 1:length(PROXopts(proxnum).submix)  
  subname = PROXopts(proxnum).submix(subnum).name;
  suffix = ['test_' num2str(PROXopts(proxnum).K')'];
  subproxes_test_face = testmodel_face(subname,model{subnum},testset,suffix);
  
  Xt = cat(1,subproxes_test_face.score)';
  Xt(isnan(Xt)) = min(Xt);
  Xt = cat(1,Xt,ones(1,size(Xt,2)));
  Yt = logistK_eval(beta{subnum},Xt);
  Zt(subnum,:) = Yt(1,:);
end

for n = 1:length(testset)
  proxes_test(n).score = max(Zt(:,n));
end

[ap prec rec] = PROX_eval_ap(proxes_test,testset);
fprintf('ap=%.1f\n',ap*100);
