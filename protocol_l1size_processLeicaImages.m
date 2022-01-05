clear all
[file,input_path] = uigetfile('*.lif');
image_range = [101 str2num(file(end-6:end-4))]; %[start end]

output_pathL1 = [input_path '\output\L1\'];
output_pathEgg = [input_path '\output\Egg\'];
mkdir(output_pathL1);
mkdir(output_pathEgg);


tiles  = [1:36];
[data,strains]= loadleicaImages([input_path file],image_range,tiles);
% save([output_path file(1:end-4) '_' num2str(image_range(1)) '_' num2str(image_range(2)) '.mat'],'data','-v7.3');
% input_path_structur = dir(input_path);
% input_path_structur = input_path_structur(3:end,:);

regiondata_egg = cell(1,36);
cc_egg = cell(1,36);

image_stack_storage = cell(length(data),1);
for i = 1:36
    tmp_img = data{i,1};
    img = uint8(nan([1024,1024,size(tmp_img,1)]));
    for j = 1:size(tmp_img,1)
        img(:,:,j) = tmp_img{j,1};
    end
    [regiondata_egg{i}, cc_egg{i}] = egg_finder(img);
%     imshowpair(img(:,:,1),img(:,:,145),'montage')
%     find regions
    cc = cell(1,size(img,3));
    regiondata = cell(1,size(img,3));
    for j = 1:size(img,3)
        [regiondata{j}, cc{j}] = region_finder(img(:,:,j));
    end
    %assign object
    objects_assigned = object_assigner_eggdata(regiondata);
    % identify timepoint of egg hatching
    object_changed = extract_timeofchange(objects_assigned);
    % extract images around egg hatching
    if ~isempty(object_changed)
    img_stack = cell(size(object_changed,1),1);
    for j = 1:size(object_changed,1)
        img_stack{j} = extract_imgstack(object_changed(j,1),object_changed(j,2),img,objects_assigned);
    end
    image_stack_storage{i} = img_stack;
    else
    image_stack_storage{i} = [];
    end
end

%reformat 
sample_matrix = [1:9;10:18;19:27;28:36];
egg_area = cell(4,1);
for j = 1:4
    for i = 1:9
        egg_area{j} = [egg_area{j},[regiondata_egg{sample_matrix(j,i)}.Area]];
    end
end

egg_area_matrix = nan(max(cellfun(@(x) length(x),egg_area)),4);
for i = 1:4
    tmp = egg_area{i};
    egg_area_matrix(1:length(tmp),i) = tmp;
end
save([output_pathEgg file(1:end-4) '_egg_matrix' '.mat'],'egg_area_matrix','-v7.3')
%%
a = 1;
Values = nan(size(egg_area_matrix,1)*4,1);
Identifiers = cell(size(egg_area_matrix,1)*4,1);
for i = 1:size(egg_area_matrix,2)
    tmp = egg_area_matrix(:,i);
    Values(a:length(tmp)+a-1,1) = tmp;
    Identifiers(a:length(tmp)+a-1,1) = repmat(strains(i),length(tmp+a-1),1);
    a = a + length(tmp+a-1);
end
index = isnan(Values) |  Values > 450;
Values(index) = [];
Identifiers(index) = [];

x = table(Identifiers,Values);
writetable(x,[output_pathEgg file(1:end-4) '_' num2str(image_range(1)) '_' num2str(image_range(2)) '_eggarea_bysample' '.csv']);
close all
ss = dabest([output_pathEgg file(1:end-4) '_' num2str(image_range(1)) '_' num2str(image_range(2)) '_eggarea_bysample' '.csv']);
writetable(ss,[output_pathEgg file(1:end-4) '_' num2str(image_range(1)) '_' num2str(image_range(2)) '_eggarea_bysample_stats' '.csv']);

fgrs = findobj('Type', 'figure');
for i = 1:length(fgrs)
    saveas(fgrs(i),[output_pathEgg file(1:end-4) '_' num2str(image_range(1)) '_' num2str(image_range(2)) '_eggarea_bysample_Gardner_Altman_' num2str(i) '.pdf']);
end

%%


image_stack_storage_reshape = cell(4,1);

for j = 1:4
    for i = 1:9
        image_stack_storage_reshape{j} = [image_stack_storage_reshape{j};image_stack_storage{sample_matrix(j,i)}];
    end
end

save([output_pathL1 file(1:end-4) '_' num2str(image_range(1)) '_' num2str(image_range(2)) '_image_stack_storage_reshaped.mat'],'image_stack_storage_reshape','-v7.3')

%% clickMeasureL1
% input_path = path to images
% nMax = max number of images to be loaded
% nWells = total number of objects
% worm_lengths = table with previous worm_lengths, size(reg_img,3)
% n = starting well position


worm_lengths_cell = cell(4,1);
for j = 1:4    
    img_stack = image_stack_storage_reshape{j};
    worm_lengths_array = nan(size(img_stack,1));

    nWells = size(img_stack,1);
    worm_lengths = [];
    worm_img_path = [output_pathL1 '\' strains{j}];
    mkdir(worm_img_path);
    worm_lengths = clickMeasureL1_FB20191015_v01(img_stack,50,nWells,worm_lengths,1,worm_img_path);
    save([output_pathL1 file(1:end-4) '_' num2str(image_range(1)) '_' num2str(image_range(2)) '_wormlength_' num2str(j) '.mat'],'worm_lengths','-v7.3','-nocompression')
    
    
    for i = 1:size(worm_lengths,2)
        if isempty(worm_lengths{1,i})
            tmp = nan;
        else
            tmp = worm_lengths{1,i};
        end
        tmp = max(tmp);
        worm_lengths_array(i) = tmp;
    end
    
    worm_lengths_array(isnan(worm_lengths_array)) = [];
    worm_lengths_cell{j} = worm_lengths_array;
    
    save([output_pathL1 file(1:end-4) '_' num2str(image_range(1)) '_' num2str(image_range(2)) '_wormlength_cell_' num2str(j) '.mat'],'worm_lengths_cell','-v7.3','-nocompression')
end

% reformat length to matrix
worm_length_matrix = nan(max(cellfun(@(x) length(x),worm_lengths_cell)),4);
for i = 1:4
    tmp = worm_lengths_cell{i};
    worm_length_matrix(1:length(tmp),i) = tmp;
end
save([output_pathL1 file(1:end-4) '_' num2str(image_range(1)) '_' num2str(image_range(2)) '_wormlength_matrix' '.mat'],'worm_length_matrix','-v7.3','-nocompression')

%%


%% plot length and egg
close all
fgr = figure('Position',[400 600 800 400]);
subplot(1,2,1)
worm_length_matrix(worm_length_matrix > 310) = nan;
%errorbar(nanmean(worm_length_matrix),nanstd(worm_length_matrix)./sqrt(sum(~isnan(worm_length_matrix))),'o')
ch1 = notBoxPlot(worm_length_matrix);
ch1 = get(gca,'Children');
set(gcf,'renderer','Painters')

for j = [1:4:4*4]
    ch1(j).MarkerSize = 0.5;
    ch1(j).MarkerFaceColor = [1 1 1];
    %ch(j).Color = [1 1 1];
end
    
ylabel('Length µm')
%[h,p] = ttest2(worm_length_matrix(worm_length_matrix(:,1)<120,1),worm_length_matrix(worm_length_matrix(:,2)<120,2),'Tail','left')
ylim([180 280])
xlim([0.5 4.5])
xticks(1:4)
xticklabels(strains)
xtickangle(45)

subplot(1,2,2)
ch2 = notBoxPlot(egg_area_matrix*10.5625)
ch2 = get(gca,'Children');
set(gcf,'renderer','Painters')

for j = [1:4:4*4]
    ch2(j).MarkerSize = 0.5;
    ch2(j).MarkerFaceColor = [1 1 1];
    %ch(j).Color = [1 1 1];
end
    
%[h,p] = ttest2(egg_area_matrix(egg_area_matrix(:,1)<450,1),worm_length_matrix(egg_area_matrix(:,2)<450,2),'Tail','left')
xlim([0.5 4.5])
xticks(1:4)
xticklabels(strains)
ylabel('Area µm^2')
ylim([2000 4400])
xtickangle(45)
saveas(fgr,[output_pathL1 file(1:end-4) '_length_egg' '.pdf']);

%%
load([output_pathL1 file(1:end-4) '_' num2str(image_range(1)) '_' num2str(image_range(2)) '_wormlength_matrix' '.mat']);
a = 1;
Values = nan(size(worm_length_matrix,1)*4,1);
Identifiers = cell(size(worm_length_matrix,1)*4,1);
for i = 1:size(worm_length_matrix,2)
    tmp = worm_length_matrix(:,i);
    Values(a:length(tmp)+a-1,1) = tmp;
    Identifiers(a:length(tmp)+a-1,1) = repmat(strains(i),length(tmp+a-1),1);
    a = a + length(tmp+a-1);
end
index = isnan(Values) |  Values > 300;
Values(index) = [];
Identifiers(index) = [];

x = table(Identifiers,Values);
writetable(x,[output_pathL1 file(1:end-4) '_' num2str(image_range(1)) '_' num2str(image_range(2)) '_wormlength_bysample' '.csv']);
close all
ss = dabest([output_pathL1 file(1:end-4) '_' num2str(image_range(1)) '_' num2str(image_range(2)) '_wormlength_bysample' '.csv'])
writetable(ss,[output_pathL1 file(1:end-4) '_' num2str(image_range(1)) '_' num2str(image_range(2)) '_wormlength_bysample_stats' '.csv']);

fgrs = findobj('Type', 'figure');
for i = 1:length(fgrs)
    saveas(fgrs(i),[output_pathL1 file(1:end-4) '_' num2str(image_range(1)) '_' num2str(image_range(2)) '_wormlength_bysample_Gardner_Altman_' num2str(i) '.pdf']);
end