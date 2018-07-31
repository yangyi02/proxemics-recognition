function showboxes(im, boxes, partcolor,linestyle)

imagesc(im); axis image; axis off;
if ~isempty(boxes)
	xy = permute(cat(3,boxes.xy),[3 1 2]);
	x1 = xy(:,:,1);
	y1 = xy(:,:,2);
	x2 = xy(:,:,3);
	y2 = xy(:,:,4);
	for p = 1:size(xy,2)
		line([x1(:,p) x1(:,p) x2(:,p) x2(:,p) x1(:,p)]',[y1(:,p) y2(:,p) y2(:,p) y1(:,p) y1(:,p)]',...
		'color',partcolor{p},'linestyle',linestyle{p},'linewidth',2);
	end
end
drawnow;
