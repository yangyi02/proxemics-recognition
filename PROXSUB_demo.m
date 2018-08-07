clc; close all; clear;
globals;

proxnum = 1; subnum = 4; visualize = true;
name = PROXopts(proxnum).submix(subnum).name;

[pos, neg1, neg2, test] = PROXSUB_data(name,proxnum,subnum);
model = trainmodel(name,pos,neg1,neg2,PROXopts(proxnum).K,PROXopts(proxnum).pa,PROXopts(proxnum).co);

% Testing on one image for illustration
fprintf([name ': testing: %d/%d\n'],1,length(test));
im = imread(test(1).im);
bbox.xy = [test(1).x1 test(1).y1 test(1).x2 test(1).y2];
bbox.force = test(1).force;
box = detect(im,model,model.thresh,bbox,0.5);
if isempty(box)
  prox.xy = [];
  prox.score = NaN;
else
  prox.xy = reshape(box(1:end-2),4,floor(length(box)/4))';
  prox.score = box(end);
end
figure(1);
showboxes(im, prox, PROXopts(proxnum).color);
figure(2);
showskeletons(im, prox, PROXopts(proxnum).pa, PROXopts(proxnum).color);

fprintf('press any key to continue ...\n');
keyboard;

% Testing on all images with ground truth face location as the face anchor
suffix = ['test_' num2str(PROXopts(proxnum).K')'];
proxes_test = testmodel(name,model,test,suffix);
%PCK = PROX_eval_pck(proxes_test,test,proxnum);
%fprintf('PCK=%.1f\n',PCK*100); fprintf('R = '); fprintf('& %.1f ',R*100); fprintf('\n');
[ap, prec, rec] = PROX_eval_ap(proxes_test,test);
fprintf('ap=%.1f\n',ap*100);

% Testing on all images with face detection as the face results
suffix = ['test_face_' num2str(PROXopts(proxnum).K')'];
proxes_test_face = testmodel_face(name,model,test,suffix);
%PCK = PROX_eval_pck(proxes_test_face,test,proxnum);
%fprintf('PCK=%.1f\n',PCK*100); fprintf('R = '); fprintf('& %.1f ',R*100); fprintf('\n');
[ap, prec, rec] = PROX_eval_ap(proxes_test_face,test);
fprintf('ap=%.1f\n',ap*100);
