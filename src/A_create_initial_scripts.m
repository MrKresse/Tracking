% comment

function A_create_initial_scripts(selected_path, xstart,xend,ystart,yend,dt,pix_size,del,dist_cutoff,fluo_cutoff)
    dir_cont=dir(strcat(selected_path,"/incoming/*.tif"));

    if ~isempty(dir_cont)
        fidA=fopen(strcat(selected_path,'/AA_main.m'),'w');
        for iF=1:length(dir_cont)
            base_str=dir_cont(iF).name;
                if base_str ~= "." && base_str ~= ".."
                    img_meta=imfinfo(strcat(dir_cont(iF).folder,"/",base_str));
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
                    fprintf(fidA,strcat('xstart=',xstart,';\n'));
                    fprintf(fidA,strcat('xend=',xend,';\n'));
                    fprintf(fidA,strcat('ystart=',ystart,';\n'));
                    fprintf(fidA,strcat('yend=',yend,';\n'));
                    fprintf(fidA,strcat('dt=',dt,';\n'));
                    fprintf(fidA,strcat('pix_size=',pix_size,';\n'));
                    fprintf(fidA,strcat('del=',del,';\n'));
                    fprintf(fidA,strcat('dist_cutoff=',dist_cutoff,';\n'));
                    fprintf(fidA,strcat('fluo_cutoff=',fluo_cutoff,';\n'));
                    fprintf(fidA,'\n');
                    fprintf(fidA,'display(strcat(''tracking: '',base_str))\n');
                    fprintf(fidA,'exec_A_detect_local_max_v2(xstart, xend, ystart, yend, fluo_cutoff, del, base_str, "./incoming/", "./processed/", Ndim, xdim, ydim);\n');
                    fprintf(fidA,'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
                    fprintf(fidA,'\n');
                end
        end
        fprintf(fidA, 'A_create_B_C_scripts("./AB_main.m","exec_B_link_events_NN_v4(dist_cutoff,del,base_str,""./processed/"")")\n');
        fprintf(fidA, 'A_create_B_C_scripts("./AC_main.m", "exec_C_subpix_det_Gauss_v2(xstart, xend, ystart, yend, del, base_str, ""./incoming/"", ""./processed/"", xdim, ydim)")');

        
        fclose(fidA);
    end
end
