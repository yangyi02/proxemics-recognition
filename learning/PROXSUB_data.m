function [pos, neg1, neg2, test] = PROXSUB_data(name,proxnum,subnum)

globals;

cls = [name '_data'];
try
	load([cachedir cls]);
catch
	trainfrs_pos = [1:300 590:889]; % training frames for positive
	testfrs = [301:589 890:1178]; % testing frames for positive
  trainfrs_neg = [1:300 590:889]; % training frames for negative 
  
  load data/PROXEMICS/labels.mat;
  touchnum = PROXopts(proxnum).submix(subnum).touchnum;  
	
  % -------------------
	% grab positive annotation and image information
  % -------------------
	pos = [];
	numpos = 0;
	for fr = trainfrs_pos
    ind = find(proxemic(fr).touchlabel(:,:,touchnum)==1);
    [I, J] = ind2sub([numel(proxemic(fr).persons) numel(proxemic(fr).persons)],ind);
    for i = 1:length(I)
      person1 = proxemic(fr).persons(I(i));
      person2 = proxemic(fr).persons(J(i));
			numpos = numpos + 1;
			pos(numpos).im = ['data/PROXEMICS/' proxemic(fr).ims];
			pos(numpos).point = [person1.coor(PROXopts(proxnum).submix(subnum).pts1,:); ...
        person2.coor(PROXopts(proxnum).submix(subnum).pts2,:)];
			pos(numpos).scale = (person1.scale + person2.scale)/2;
    end
  end
	
	% -------------------
	% create ground truth keypoints and boxes for model training
	for n = 1:length(pos)
		pos(n).point = PROXopts(proxnum).trans * pos(n).point; % linear combination
    pos(n).force = ones(1,size(pos(n).point,1));

    pos(n).x1 = pos(n).point(:,1) - pos(n).scale/2;
    pos(n).y1 = pos(n).point(:,2) - pos(n).scale/2;
    pos(n).x2 = pos(n).point(:,1) + pos(n).scale/2;
    pos(n).y2 = pos(n).point(:,2) + pos(n).scale/2;
  end
  
	% -------------------
	% grab neagtive image information
  % -------------------
	neg = [];
	numneg = 0;
	for fr = 615:1832 
    numneg = numneg + 1;
    neg(numneg).im = sprintf('data/INRIA/%.5d.jpg',fr);
  end
  neg1 = neg;
  
	neg = [];
	numneg = 0;
	for fr = trainfrs_neg
    ind = find(proxemic(fr).touchlabel(:,:,touchnum)==0);
    [I, J] = ind2sub([numel(proxemic(fr).persons) numel(proxemic(fr).persons)],ind);
    for i = 1:length(I)
      if I(i) == J(i), continue, end
      person1 = proxemic(fr).persons(I(i));
			facecenter1 = mean(person1.coor(1:2,:));
      person2 = proxemic(fr).persons(J(i));
			facecenter2 = mean(person2.coor(1:2,:));
      numneg = numneg + 1;
      neg(numneg).im = ['data/PROXEMICS/' proxemic(fr).ims];
      neg(numneg).facecenter = [facecenter1; facecenter2];
      neg(numneg).scale = (person1.scale + person2.scale)/2;
    end
  end
  
	for n = 1:length(neg)
		neg(n).point = NaN(length(PROXopts(proxnum).pa),2);
		neg(n).point(PROXopts(proxnum).faceid,:) = neg(n).facecenter;
		neg(n).force = zeros(1,size(neg(n).point,1));
		neg(n).force(PROXopts(proxnum).faceid) = 1;
  
		neg(n).x1 = neg(n).point(:,1) - neg(n).scale/2;
		neg(n).y1 = neg(n).point(:,2) - neg(n).scale/2;
		neg(n).x2 = neg(n).point(:,1) + neg(n).scale/2;
		neg(n).y2 = neg(n).point(:,2) + neg(n).scale/2;
  end
  neg2 = neg;
  
  % -------------------
	% grab testing annotation and image information
  % -------------------
  for fr = testfrs
    % load detected face
    I = textread(sprintf('data/PROXEMICS/face_detection/%.4d.txt',fr));
    facebox = zeros(I(1),4);
    for i = 1:I(1)
      x1 = I(i+1,1); y1 = I(i+1,2); x2 = I(i+1,3); y2 = I(i+1,4);
      w = x2-x1+1; h = y2-y1+1;
      facebox(i,1) = (x1+x2)/2 - w*1.2/2;
      facebox(i,2) = (y1+y2)/2 - h*1.2/2;
      facebox(i,3) = (x1+x2)/2 + w*1.2/2;
      facebox(i,4) = (y1+y2)/2 + h*1.2/2;
    end
    % find true positive face detections
    for i = 1:length(proxemic(fr).persons)
      % load ground truth face
      person = proxemic(fr).persons(i);
      gtface = (person.coor(1,:) + person.coor(2,:))/2;
      x1 = gtface(1) - person.scale/2;
      y1 = gtface(2) - person.scale/2;
      x2 = gtface(1) + person.scale/2;
      y2 = gtface(2) + person.scale/2;
      area = (x2-x1)*(y2-y1);
      
      % find overlap
      xx1 = bsxfun(@max,x1,facebox(:,1));
      yy1 = bsxfun(@max,y1,facebox(:,2));
      xx2 = bsxfun(@min,x2,facebox(:,3));
      yy2 = bsxfun(@min,y2,facebox(:,4));
      
      w = xx2 - xx1 + 1; w(w<0) = 0;
      h = yy2 - yy1 + 1; h(h<0) = 0;
      overlap = w.*h./repmat(area,size(facebox,1),1);
      [o,ind] = max(overlap);
      if o > 0.3
        proxemic(fr).persons(i).detect = 1;
        proxemic(fr).persons(i).facebox = facebox(ind,:);
      else
        proxemic(fr).persons(i).detect = 0;
        proxemic(fr).persons(i).facebox = [];
      end
    end
  end
	
	test = [];
	numtest = 0;
	for fr = testfrs
    for i = 1:numel(proxemic(fr).persons)
      for j = 1:numel(proxemic(fr).persons)
        if i == j, continue, end
        person1 = proxemic(fr).persons(i);
        person2 = proxemic(fr).persons(j);
        numtest = numtest + 1;
        test(numtest).im = ['data/PROXEMICS/' proxemic(fr).ims];
        test(numtest).point = [person1.coor(PROXopts(proxnum).submix(subnum).pts1,:); ...
          person2.coor(PROXopts(proxnum).submix(subnum).pts2,:)];
        test(numtest).scale = (person1.scale + person2.scale)/2;
        test(numtest).label = proxemic(fr).touchlabel(i,j,touchnum);
        if person1.detect && person2.detect
          test(numtest).facebox = NaN(length(PROXopts(proxnum).pa),4);
          test(numtest).facebox(PROXopts(proxnum).faceid(1),:) = person1.facebox;
          test(numtest).facebox(PROXopts(proxnum).faceid(2),:) = person2.facebox;
        else
          test(numtest).facebox = [];
        end
      end
    end
	end

	for n = 1:length(test)
		test(n).point = PROXopts(proxnum).trans * test(n).point; % linear combination
    test(n).force = zeros(1,size(test(n).point,1));
    test(n).force(PROXopts(proxnum).faceid) = 1;

		test(n).x1 = test(n).point(:,1) - test(n).scale/2;
		test(n).y1 = test(n).point(:,2) - test(n).scale/2;
		test(n).x2 = test(n).point(:,1) + test(n).scale/2;
		test(n).y2 = test(n).point(:,2) + test(n).scale/2;
  end
  
	save([cachedir cls],'pos','neg1','neg2','test');
end
