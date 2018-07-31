function idx = clusterparts(deffeat,K,co)

R = 100;

idx = cell(1,length(deffeat));
for p = 1:length(deffeat)
	% create clustering feature
	X = deffeat{co(p)} - deffeat{p};
  % try multiple times kmeans
  gInd = cell(1,R);
  cen  = cell(1,R);
  sumdist = zeros(1,R);
  for trial = 1:R
    [gInd{trial} cen{trial} sumdist(trial)] = k_means(X,K(p));
  end
  [dummy ind] = min(sumdist);
	idx{p} = zeros(size(deffeat{p},1),1);
  idx{p} = gInd{ind(1)};
end

PLOT = 0;
if PLOT
	color = {'b','r','g','m','c','y','b','r','g','m','c','y'};
	figure(1); clf;
	P = length(deffeat);
	for p = 1:P
		subplot(ceil(P/ceil(sqrt(P))),ceil(sqrt(P)),p); hold on;
		for k = 1:K(p)
			X = deffeat{p}(idx{p}==k,:) - deffeat{co(p)}(idx{p}==k,:);
			plot(X(:,1),-X(:,2),'.','color',color{k});
			plot(mean(X(:,1)),-mean(X(:,2)),'o','markerfacecolor',color{k},'markersize',10);
      axis equal;
		end
  end
end
