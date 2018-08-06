function [trainset, testset] = PROX_data(name,proxnum)

globals;

cls = [name '_data'];
try
	load([cachedir cls]);
catch
	trainfrs = [1:300 590:889]; % training frames for positive
	testfrs = [301:589 890:1178]; % testing frames for positive
  
  load data/PROXEMICS/labels.mat;
  for subnum = 1:length(PROXopts(proxnum).submix)
    touchnum(subnum) = PROXopts(proxnum).submix(subnum).touchnum;
  end
  
  % -------------------
	% grab training annotation and image information
  % -------------------
	trainset = [];
	numtrain = 0;
	for fr = trainfrs
    for i = 1:numel(proxemic(fr).persons)
      for j = 1:numel(proxemic(fr).persons)
        if i == j, continue, end
        person1 = proxemic(fr).persons(i);
				facecenter1 = mean(person1.coor(1:2,:));
        person2 = proxemic(fr).persons(j);
				facecenter2 = mean(person2.coor(1:2,:));
        numtrain = numtrain + 1;
        trainset(numtrain).im = ['data/PROXEMICS/' proxemic(fr).ims];
        trainset(numtrain).label = squeeze(proxemic(fr).touchlabel(i,j,touchnum));
				trainset(numtrain).facecenter = [facecenter1; facecenter2];
        trainset(numtrain).scale = (person1.scale + person2.scale)/2;
      end
    end
  end
	
	for n = 1:length(trainset)
		trainset(n).point = NaN(length(PROXopts(proxnum).pa),2);
		trainset(n).point(PROXopts(proxnum).faceid,:) = trainset(n).facecenter;
    trainset(n).force = zeros(1,size(trainset(n).point,1));
    trainset(n).force(PROXopts(proxnum).faceid) = 1;
  
    trainset(n).x1 = trainset(n).point(:,1) - trainset(n).scale/2;
    trainset(n).y1 = trainset(n).point(:,2) - trainset(n).scale/2;
    trainset(n).x2 = trainset(n).point(:,1) + trainset(n).scale/2;
    trainset(n).y2 = trainset(n).point(:,2) + trainset(n).scale/2;
  end
  
  % -------------------
	% grab testing annotation and image information
  % -------------------
  for fr = testfrs
    % load detected face
    I = textread(sprintf('data/PROXEMICS/faceresults/%.4d.txt',fr));
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
  
	testset = [];
	numtest = 0;
	for fr = testfrs
    for i = 1:numel(proxemic(fr).persons)
      for j = 1:numel(proxemic(fr).persons)
        if i == j, continue, end
        person1 = proxemic(fr).persons(i);
				facecenter1 = mean(person1.coor(1:2,:));
        person2 = proxemic(fr).persons(j);
				facecenter2 = mean(person2.coor(1:2,:));
        numtest = numtest + 1;
        testset(numtest).im = ['data/PROXEMICS/' proxemic(fr).ims];
        testset(numtest).label = max(squeeze(proxemic(fr).touchlabel(i,j,touchnum)));
        testset(numtest).facecenter = [facecenter1; facecenter2];
        testset(numtest).scale = (person1.scale + person2.scale)/2;
        if person1.detect && person2.detect
          testset(numtest).facebox = NaN(length(PROXopts(proxnum).pa),4);
          testset(numtest).facebox(PROXopts(proxnum).faceid(1),:) = person1.facebox;
          testset(numtest).facebox(PROXopts(proxnum).faceid(2),:) = person2.facebox;
        else
          testset(numtest).facebox = [];
        end
      end
    end
	end

	for n = 1:length(testset)
		testset(n).point = NaN(length(PROXopts(proxnum).pa),2);
		testset(n).point(PROXopts(proxnum).faceid,:) = testset(n).facecenter;
    testset(n).force = zeros(1,size(testset(n).point,1));
    testset(n).force(PROXopts(proxnum).faceid) = 1;

		testset(n).x1 = testset(n).point(:,1) - testset(n).scale/2;
		testset(n).y1 = testset(n).point(:,2) - testset(n).scale/2;
		testset(n).x2 = testset(n).point(:,1) + testset(n).scale/2;
		testset(n).y2 = testset(n).point(:,2) + testset(n).scale/2;
  end
  
	save([cachedir cls],'trainset','testset');
end
