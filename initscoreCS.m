clear all
%input_path = uigetdir;
input_path = '\\tungsten-nas.fmi.ch\tungsten\scratch\gtsiairi\fabian\yokogawaCV7000\211014-jf28-8600075508_20211014_151253\211014FB001R01_211014_151425\extendedFocus';
inputfiles = dir([input_path '\*.png']);
output_path = [input_path '\output\'];
mkdir(output_path);

img = cell(height(inputfiles),1);
id = cell(height(inputfiles),2);
parfor j = 1:height(inputfiles)
    %img{j} = imread([input_path '\' inputfiles(j).name]);
    tmp = strsplit(inputfiles(j).name,'_');
    id{j,1} = tmp{4};
end

score = scoreCS(img,id);
