function create_D_scripts(selected_path,path_incoming,exec,xstart,xend,ystart,yend,dt,pix_size,del,dist_cutoff,fluo_cutoff,base_str)
    %brief: Creates main scripts for execution of extra analysis steps.
    %param: selected_path:  string, path of parent directory, where the
    %                       main will be written to.
    %       path_incoming:  string, path to movies.
    %       path_processed: string, path to analysis results.
    %       exec:           string, name of executable for which the main is created.
    %returns: nothing.
    fidA=fopen(strcat(selected_path,'/AD_main.m'),'w');

    img_meta=imfinfo(strcat(path_incoming,base_str));
    Ndim=length(img_meta);
    xdim=img_meta(1).Width;
    ydim=img_meta(1).Height;
    
    fprintf(fidA,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
    fprintf(fidA,'clear;\n');
    fprintf(fidA,'\n');
    fprintf(fidA, 'addpath(fullfile(pwd, ''src''));\n');
    fprintf(fidA,strcat('base_str=''',base_str,''';\n'));
    fprintf(fidA,strcat('Ndim=',num2str(Ndim),';\n'));
    fprintf(fidA,strcat('xdim=',num2str(xdim),';\n'));
    fprintf(fidA,strcat('ydim=',num2str(ydim),';\n'));
    fprintf(fidA,strcat('xstart=',num2str(xstart),';\n'));
    fprintf(fidA,strcat('xend=',num2str(xend),';\n'));
    fprintf(fidA,strcat('ystart=',num2str(ystart),';\n'));
    fprintf(fidA,strcat('yend=',num2str(yend),';\n'));
    fprintf(fidA,strcat('dt=',num2str(dt),';\n'));
    fprintf(fidA,strcat('pix_size=',num2str(pix_size),';\n'));
    fprintf(fidA,strcat('del=',num2str(del),';\n'));
    fprintf(fidA,strcat('dist_cutoff=',num2str(dist_cutoff),';\n'));
    fprintf(fidA,strcat('fluo_cutoff=',num2str(fluo_cutoff),';\n'));
    fprintf(fidA,'\n');
    fprintf(fidA,'display(strcat(''tracking: '',base_str))\n');
    %executable
    fprintf(fidA,strcat(exec,';\n'));
    fprintf(fidA,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
    fprintf(fidA,'\n');

    fclose(fidA);
end