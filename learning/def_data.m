function deffeat = def_data(pos,model)
% get relative deformation with respect to HOG cell

width  = zeros(1,length(pos));
height = zeros(1,length(pos));
labels = zeros(size(pos(1).point,1),size(pos(1).point,2),length(pos));
for n = 1:length(pos)
  width(n)  = pos(n).x2(1) - pos(n).x1(1) + 1;
  height(n) = pos(n).y2(1) - pos(n).y1(1) + 1;
  labels(:,:,n) = pos(n).point;
end
scale = sqrt(width.*height)/sqrt(model.maxsize(1)*model.maxsize(2));
scale = [scale; scale];

deffeat = cell(1,size(labels,1));
for p = 1:size(labels,1)
  def = squeeze(labels(p,1:2,:));
  deffeat{p} = (def ./ scale)';
end
