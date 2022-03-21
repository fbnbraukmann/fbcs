clear all
% add scripts to MATLAB path
addpath 'D:\userdata\braufabi\fbcs'
%input_path = uigetdir;
input_path = '\\tungsten-nas.fmi.ch\tungsten\scratch\gtsiairi\fabian\yokogawaCV7000\220106FB003R03_20220106_133412\220106FB003R03_220106_133457\extendedFocus';
inputfiles = dir([input_path '\*.png']);
output_path = [input_path '\output\'];
mkdir(output_path);

img = cell(height(inputfiles),1);
id = cell(height(inputfiles),2);
parfor j = 1:height(inputfiles)
    img{j} = imread([input_path '\' inputfiles(j).name]);
    tmp = strsplit(inputfiles(j).name,'_');
    id{j,1} = tmp{4};
end

score = scoreCS(img,id);
