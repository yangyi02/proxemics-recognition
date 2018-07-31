function showskeleton(im, boxes, parent, partmark, partcolor, linestyle)

imagesc(im); axis image; axis off; hold on;
if ~isempty(boxes)
	for n = 1:numel(boxes)
		xy = boxes(n).xy;
		x1 = xy(:,1); y1 = xy(:,2); x2 = xy(:,3); y2 = xy(:,4);
		x = (x1+x2)/2; y = (y1+y2)/2;
		plot(x(1),y(1),partmark{1},'color',partcolor{1});
%     text(x(1),y(1),num2str(boxes(n).m(1)),'backgroundcolor',partcolor{1});
		for child = 2:length(parent)
			x1 = x(parent(child));
			y1 = y(parent(child));
			x2 = x(child);
			y2 = y(child);
      plot(x2,y2,partmark{child},'color',partcolor{child});
      line([x1 x2],[y1 y2],'color',partcolor{child},'linestyle',linestyle{child},'linewidth',4);
%       text(x2,y2,num2str(boxes(n).m(child)),'backgroundcolor',partcolor{child});
		end
	end
end
drawnow;
