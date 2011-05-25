function show_gridder(grid,betas)
%% Show the segmentation masks
bg = cat(1,get_pascal_bg('trainval'),get_pascal_bg('test'));
curids = cell(length(bg),1);
for i = 1:length(bg)
  [tmp,curids{i},tmp] = fileparts(bg{i});
end

ht = get_pascal_bg('test','train');
for i = 1:length(ht)
  [tmp,curid,tmp] = fileparts(ht{i});
  hit = find(ismember(curids,curid));
  I = convert_to_I(bg{hit});
  g = grid{hit};
  goods = find(g.bboxes(:,end)>=-1);
  b = g.bboxes(goods,:);
  b = calibrate_boxes(b,betas);
  [aa,bb] = sort(b(:,end),'descend');
  b = b(bb(1:min(length(bb),30)),:);
  
  b = clip_to_image(b,[1 1 size(I,2) size(I,1)]);
  b(:,1:4) = round(b(:,1:4));
  b = clip_to_image(b,[1 1 size(I,2) size(I,1)]);
  summer = zeros(size(I,1),size(I,2));
  counter = zeros(size(I,1),size(I,2));
  weights = b(:,end);
  %weights = weights / max(weights(:));
  %weights = weights.^2;

  %weights = weights / sum(weights(:));
  for q = 1:size(b,1)
    m = 0*ones(size(I,1),size(I,2));
    m(b(q,2):b(q,4),b(q,1):b(q,3)) = 1;
    summer = summer + weights(q)*m;
    counter = counter + m;
  end
  %summer = summer ./ (counter+eps);
  %summer = summer / size(b,1);

  %summer = summer / max(summer(:));
  %summer = summer.^2;
  figure(1)
  clf
  subplot(1,2,1)
  imagesc(I.*repmat(summer/max(summer(:)),[1 1 3]))
  %plot_bbox(mean(b,1))
  subplot(1,2,2)
  imagesc(summer)
  colorbar
  pause
  
end