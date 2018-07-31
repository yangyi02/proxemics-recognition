function proxes = testmodel_face(name,model,test,suffix)

globals;

try
  load([cachedir name '_proxes_face_' suffix]);
catch
  for n = 1:length(test)
    fprintf([name ': testing: %d/%d\n'],n,length(test));
    im = imread(test(n).im);
    if ~isempty(test(n).facebox)
      bbox.xy = test(n).facebox;
      bbox.force = test(n).force;
      box = detect(im,model,model.thresh,bbox,0.3);
    else
      box = [];
    end
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
  save([cachedir name '_proxes_face_' suffix],'proxes','model');
end
