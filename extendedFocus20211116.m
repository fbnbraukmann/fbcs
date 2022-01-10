clear all
addpath(genpath('D:\userdata\braufabi\Fiji.app\scripts'));
%run
Miji
% close Miji windows
%%
pathinput = '\\tungsten-nas.fmi.ch\tungsten\scratch\gtsiairi\fabian\yokogawaCV7000\220106FB003R03_20220106_133412\220106FB003R03_220106_133457\';
sufix = '**\*Z01C01.tif';
inputfiles = dir([pathinput '\' sufix]);


for i = 1:height(inputfiles)
    if i > 1
        MIJ.run("Close All");
    end
    MIJ.run("Image Sequence...", ['dir=' inputfiles(i).folder ' filter=' inputfiles(i).name(1:end-9) ' sort']);
    MIJ.run("Gaussian-based stack focuser", "radius_of_gaussian_blur=3");
    MIJ.run("8-bit");
    I = MIJ.getCurrentImage;
    I8 = cast(I,'uint8');
    imwrite(I8,[inputfiles(i).folder '\' inputfiles(i).name(1:end-10) '.png']);
end
