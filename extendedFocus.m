%make sure that java heap memory is large enough 16gb
% https://ch.mathworks.com/help/matlab/matlab_external/java-heap-memory-preferences.html

clear all
close all
addpath(genpath('D:\userdata\braufabi\Fiji.app-2021-05-27\scripts'));
%run
Miji
% close Miji windows
%%
pathinput = 'W:\scratch\gtsiairi\fabian\yokogawaCV7000\20220310JF032*\';
sufix = '**\*Z01C01.tif';
inputfiles = dir([pathinput '\' sufix]);


for i = 1:height(inputfiles)
    if i > 1
        MIJ.run("Close All");
    end
    %MIJ.run("Image Sequence...", ['dir=' inputfiles(i).folder ' + filter=' inputfiles(i).name(1:end-9) '+ sort']);
    MIJ.run("Image Sequence...", ['open=' inputfiles(i).folder  ' file=' inputfiles(i).name(1:end-9) ' sort']);
    MIJ.run("Gaussian-based stack focuser", "radius_of_gaussian_blur=3");
    MIJ.run("8-bit");
    I = MIJ.getCurrentImage;
    I8 = cast(I,'uint8');
    outputpath = [inputfiles(i).folder '\' inputfiles(i).name(1:end-10) '.png'];
    [tmpbase, tmpfilestemp, tmpext] = fileparts(outputpath);
    mkdir(fullfile(tmpbase,'png'));
    outputpath = fullfile(tmpbase,'png', [tmpfilestemp tmpext]);
    imwrite(I8,outputpath);
end
