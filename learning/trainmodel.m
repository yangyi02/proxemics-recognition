function model = trainmodel(name,pos,neg1,neg2,K,pa,co)

globals;

cls = [name '_cluster_' num2str(K')'];
try
  load([cachedir cls]);
catch
	model = initmodel(pos);
  def = def_data(pos,model);
  idx = clusterparts(def,K,co);
  save([cachedir cls],'def','idx');
end

% ---------------------
% train individual template
for p = 1:length(pa)
  cls = [name '_part_' num2str(p) '_mix_' num2str(K(p))];
  try
    load([cachedir cls]);
  catch
    sneg = neg1(1:min(length(neg1),100));
    model0 = initmodel(pos);
    models = cell(1,K(p));
    for k = 1:K(p)
      spos = pos(idx{p} == k);
      for n = 1:length(spos) 
        spos(n).x1 = spos(n).x1(p);
        spos(n).y1 = spos(n).y1(p);
        spos(n).x2 = spos(n).x2(p);
        spos(n).y2 = spos(n).y2(p);
      end
      models{k} = train(cls,model0,spos,sneg,1,1);
    end
    model = mergemodels(models);
    save([cachedir cls],'model','models');
  end
end

 % ---------------------                                                                               
 % traing templates and spatial constraints jointly
 cls = [name '_final_' num2str(K')'];                                                                  
 try                    
   load([cachedir cls]);
 catch     
   model = buildmodel(name,model,def,idx,K,pa);
   model = train(cls,model,pos,neg2,0,1); % train twice to converge
   model = train(cls,model,pos,neg2,0,1);                                                              
   save([cachedir cls],'model');                                                                       
 end   