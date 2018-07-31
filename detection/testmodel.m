function proxes = testmodel(name,model,test,suffix)

globals;

try
  load([cachedir name '_proxes_' suffix]);
catch
  for n = 1:length(test)
    fprintf([name ': testing: %d/%d\n'],n,length(test));
    im = imread(test(n).im);
    bbox.xy = [test(n).x1 test(n).y1 test(n).x2 test(n).y2];
    bbox.force = test(n).force;
    box = detect(im,model,model.thresh,bbox,0.5);
    if isempty(box)
      proxes(n).xy = [];
      proxes(n).score = NaN;
    else
      proxes(n).xy = reshape(box(1:end-2),4,floor(length(box)/4))';
      proxes(n).score = box(end);
    end
  end

  if nargin < 4 
    suffix = [];
  end
  save([cachedir name '_proxes_' suffix],'proxes','model');
end
