%Inputs
% input_path = path to images
% nMax = max number of images to be loaded
% nWells = total number of wells
% worm_lengths = table with previous worm_lengths, size(reg_img,3)
% n = well position
% worm_img_path is the output directory
function [score] = scoreCS(img,id)

close all
n = id{:,1};
img = img;

i = 1;
figure(1)

imageHandle = imshow(img{i});

colormap gray
t = title(['well_' id{i,1}]);
axesHandle = get(imageHandle,'parent');
figHandle = get(axesHandle,'parent');
set(figHandle,'WindowKeyPressFcn',@nextImage);
set(imageHandle,'ButtonDownFcn',@butn_fcn)

uiwait

    function changeImage
        imageHandle(1).CData=img{i,1};
        colormap gray
        t = title(['well_' id{i,1}]);
    end

    function nextImage(~, eventdata, ~)
        switch eventdata.Key
            case 'leftarrow'
                i = max(1,i-1);
                imageHandle(1).CData=img{n,1}{i,1};
                set(t,'String',['well_' num2str(n) ' img_' num2str(i)])
            case 'rightarrow'
                i = min(i+1,size(img{n,1},1));
                if i+1>size(img{n,1},1)
                    if ~isempty(lengths)
                    worm_lengths{n} = lengths;
                    end
                    i = size(img{n,1},1);              
%                     n = min(n+1,nWells);
%                     if n > length(nWells)
%                         n = length(nWells)
%                     end
%                     lengths = worm_lengths{n};
                end
                changeImage
                set(t,'String',['well_' num2str(n) ' img_' num2str(i)])
            case 'downarrow'
                if ~isempty(lengths)
                    worm_lengths{n} = lengths
                end
                i = 1;
                n = min(n+1,nWells);
                lengths = worm_lengths{n};
                changeImage
            case 'uparrow'
                n = max(n-1,1);
                changeImage               
                
            case 'w'
                if length(lengths)>1
                    lengths = lengths(1:end-1);
                else
                    lengths = [];
                end
                               
                clc
                disp(lengths)
            case 'x'
                worm_lengths{n} = lengths;
                uiresume
                delete(figHandle(1))
                close all
        end
    end

    function butn_fcn(hObj,~)
        if strcmp(get(figHandle(1),'SelectionType'),'normal')
            axesHandle = get(hObj,'Parent');
            hChildren = findobj(axesHandle,'Type','Rectangle');
            delete(hChildren);
            coordinates = get(axesHandle,'CurrentPoint');
            coordinates = coordinates(1,1:2);
            s = 50;
            sub_img = uint8(zeros(2*s,2*s));
            bounding_box = [coordinates-s 2*s 2*s];
            rectangle('pos',bounding_box,'edgecolor','r');
            tmp_img = imcrop(hObj.CData,bounding_box);
            sub_img(1:size(tmp_img,1),1:size(tmp_img,2)) = tmp_img;
            figHandle(2) = figure(2);
            I = imcomplement(sub_img);
            I2 = imtophat(I,strel('disk',20));
            I3 = imadjust(I2,[0.05 0.95]);
            bw = imbinarize(I3);
            bw = imfill(bw,'holes');
            bw = bwareaopen(bw,250);
            cc = bwconncomp(bw,8);
            imageHandle(2) = imshow(bw);
            axesHandle(2) = get(imageHandle(2),'Parent');
            length_tmp = worm_length(regionprops(cc,'Centroid','Area','Image','BoundingBox'))*3.25;
            set(figHandle(2),'WindowKeyPressFcn',{@acceptImage});
       end

%         if strcmp(get(figHandle(1),'SelectionType'),'alt')
%             axesHandle = get(hObj,'Parent');
%             hChildren = findobj(axesHandle,'Type','Rectangle');
%             delete(hChildren);
%             coordinates = get(axesHandle,'CurrentPoint');
%             coordinates = coordinates(1,1:2);
%             
%             s = 12;
%             bounding_box = [coordinates-2*s 2*s 2*s];
%             rectangle(fgr3.CurrentAxes,'pos',bounding_box,'edgecolor','r');
%         end
    end

    function acceptImage(~, eventdata, ~)
        switch eventdata.Key
            case 'return'
                imwrite(sub_img,[worm_img_path, '\' datestr(now, 'ddmmyyHHMMss'), '.png']);
                lengths = cat(1,lengths,sort(length_tmp,'descend'));
                clc
                disp(lengths)
                close(figHandle(2))
                
                if ~isempty(lengths)
                    worm_lengths{n} = lengths;
                end
                
                n = min(n+1,nWells);
                if n > nWells
                    n = nWells
                end             
                lengths = worm_lengths{n};
                
                i = 1;
                changeImage
                set(t,'String',['well_' num2str(n) ' img_' num2str(i)])
            case 'w'
                close(figHandle(2))
        end
    end

end
