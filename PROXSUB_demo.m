clc; close all; clear;
globals;

proxnum = 1; subnum = 4;
name = PROXopts(proxnum).submix(subnum).name;

[pos neg1 neg2 test] = PROXSUB_data(name,proxnum,subnum);
model = trainmodel(name,pos,neg1,neg2,PROXopts(proxnum).K,PROXopts(proxnum).pa,PROXopts(proxnum).co);

suffix = ['test_' num2str(PROXopts(proxnum).K')'];
proxes_test = testmodel(name,model,test,suffix);
%PCK = PROX_eval_pck(proxes_test,test,proxnum);
%fprintf('PCK=%.1f\n',PCK*100); fprintf('R = '); fprintf('& %.1f ',R*100); fprintf('\n');
[ap prec rec] = PROX_eval_ap(proxes_test,test);
fprintf('ap=%.1f\n',ap*100);

suffix = ['test_face_' num2str(PROXopts(proxnum).K')'];
proxes_test_face = testmodel_face(name,model,test,suffix);
%PCK = PROX_eval_pck(proxes_test_face,test,proxnum);
%fprintf('PCK=%.1f\n',PCK*100); fprintf('R = '); fprintf('& %.1f ',R*100); fprintf('\n');
[ap prec rec] = PROX_eval_ap(proxes_test_face,test);
fprintf('ap=%.1f\n',ap*100);
