function pyra = featpyramid(im, model)
% Compute feature pyramid.
%
% pyra.feat{i} is the i-th level of the feature pyramid.
% pyra.scales{i} is the scaling factor used for the i-th level.
% pyra.feat{i+interval} is computed at exactly half the resolution of feat{i}.
% first octave halucinates higher resolution data.

sbin = model.sbin;
interval = model.interval;
% padx = max(model.maxsize(2)-1-1,0);
% pady = max(model.maxsize(1)-1-1,0);
if isempty(model.defs) % unary template do not have anchor
  padx = max(model.maxsize(2)-1-1,0);
  pady = max(model.maxsize(1)-1-1,0);
else % joint templates need to consider more
  anchor = cat(1,model.defs.anchor) - 1; % -1 because anchor starts with 1,1 not 0,0
  padx = max(model.maxsize(2)-1-1,0) + max(abs(anchor(:,1))) + 1;
  pady = max(model.maxsize(1)-1-1,0) + max(abs(anchor(:,2))) + 1;
end
sc = 2 ^(1/interval);
imsize = [size(im, 1) size(im, 2)];
max_scale = 1 + floor(log(min(imsize)/(5*sbin))/log(sc));
pyra.feat = cell(max_scale,1);
pyra.scale = zeros(max_scale,1);

if size(im, 3) == 1
  im = repmat(im,[1 1 3]); % HOG uses color images
end
im = double(im); % our resize function wants floating point values

for i = 1:interval
  scaled = resize(im, 1/sc^(i-1));
  pyra.feat{i} = features(scaled,sbin);
  pyra.scale(i) = 1/sc^(i-1);
  % remaining interals
  for j = i+interval:interval:max_scale
    scaled = reduce(scaled);
    pyra.feat{j} = features(scaled,sbin);
    pyra.scale(j) = 0.5 * pyra.scale(j-interval);
  end
end

for i = 1:length(pyra.feat)
  % add 1 to padding because feature generation deletes a 1-cell
  % wide border around the feature map
  pyra.feat{i} = padarray(pyra.feat{i}, [pady+1 padx+1 0], 0);
  % write boundary occlusion feature
  pyra.feat{i}(1:pady+1, :, end) = 1;
  pyra.feat{i}(end-pady:end, :, end) = 1;
  pyra.feat{i}(:, 1:padx+1, end) = 1;
  pyra.feat{i}(:, end-padx:end, end) = 1;
end

pyra.scale = model.sbin./pyra.scale;
pyra.interval = interval;
pyra.imy = imsize(1);
pyra.imx = imsize(2);
pyra.pady = pady;
pyra.padx = padx;
