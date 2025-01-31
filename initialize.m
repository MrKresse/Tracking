clear;

selected_path = uigetdir;

xstart='1';
xend='xdim';
ystart='1';
yend='ydim';
dt='1';
pix_size='1';
del='2';
dist_cutoff='30000';
fluo_cutoff='130';

%create standard directory layout and copy current src for reproducibility
fullScriptPath = matlab.desktop.editor.getActiveFilename;
[scriptDir, ~, ~] = fileparts(fullScriptPath);
% Change directory to the script's directory
addpath("./src/")
% Define the names of the subdirectories
subdirs = {'incoming', 'raw', 'processed', 'src'};
initialize_directories(subdirs,selected_path,scriptDir);

A_create_initial_scripts(selected_path, xstart,xend,ystart,yend,dt,pix_size,del,dist_cutoff,fluo_cutoff);