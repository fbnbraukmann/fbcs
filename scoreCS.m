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
i = 1;
figure(1)

imageHandle = imshow(img{i});
xlabel('1 = empty, 2 = wt, 3 = hit, 4 = dead, 5 = other, x = save, left & right = back & fwd');
colormap gray
t = title(['well ' id{i,1}]);
axesHandle = get(imageHandle,'parent');
figHandle = get(axesHandle,'parent');
set(figHandle,'WindowKeyPressFcn',@nextImage);
set(imageHandle,'ButtonDownFcn',@butn_fcn)

uiwait

    function changeImage
        imageHandle(1).CData=img{i,1};
        colormap gray
        t = title(['well ' id{i,1}]);
    end

    function nextImage(~, eventdata, ~)
        switch eventdata.Key
            case 'leftarrow'
                i = max(1,i-1);
                changeImage
%                 imageHandle(1).CData=img{i,1};
%                 set(t,'String',['well ' num2str(n)])
            case 'rightarrow'
                i = min(i+1,size(img,1));
                if i+1>size(img,1)
                    i = size(img,1);
                    %n = min(n+1,nWells);
                    %if n > length(nWells)
                    %    n = length(nWells)
                    %end
                    %lengths = worm_lengths{n};
                end
                changeImage
%                 set(t,'String',['well ' num2str(n)])     
                
            case '1' % empty
                id{i,2} = 1;
                score = id;
                disp([id{i,1} ' = empty (' num2str(id{i,2}) ')'])
                i = min(i+1,size(img,1));
                changeImage
            case '2'
                id{i,2} = 2;
                score = id;
                disp([id{i,1} ' = wt (' num2str(id{i,2}) ')'])
                i = min(i+1,size(img,1));
                changeImage
            case '3'
                id{i,2} = 3;
                score = id;
                disp([id{i,1} ' = hit (' num2str(id{i,2}) ')'])
                i = min(i+1,size(img,1));
                changeImage
            case '4'
                id{i,2} = 4;
                score = id;
                disp([id{i,1} ' = dead (' num2str(id{i,2}) ')'])
                i = min(i+1,size(img,1));
                changeImage
            case '5'
                id{i,2} = 5;
                score = id;
                disp([id{i,1} ' = other (' num2str(id{i,2}) ')'])
                i = min(i+1,size(img,1));
                changeImage
            case 'x'
                score = id;
                tscore = cell2table(score);
                tscore.Properties.VariableNames{2} = '1 = empty, 2 = wt, 3 = hit, 4 = dead, 5 = other';
                outputfolder = uigetdir();
                if outputfolder ~= 0
                    outputname = char(datetime('now'), 'yyyyMMddHHmm');
                    writetable(tscore,[outputfolder '\' outputname '.xlsx']);
                end
                uiresume
                delete(figHandle(1))
                close all
        end
    end
end
