% transfer from nd2 or tif to background corrected and 3x3 smoothed tif

clear;

%%%%%%%%%%%%%%%%%%
tmp=dir;
input_dir=strcat(tmp(1).folder,'/_raw/');
dir_cont=dir(strcat(input_dir,'*.nd2'));
% dir_cont=dir(strcat(input_dir,'*.tif'));
bit_depth=16;
% dir_cont=dir(strcat(input_dir,'*.tif'));
% bit_depth=8;
%%%%%%%%%%%%%%%%%%

for iF=1:length(dir_cont)
    base_str=dir_cont(iF).name;
    tmp=imreadBFmeta(strcat(input_dir,base_str));
    xdim=tmp.width;
    ydim=tmp.height;
    Ndim=tmp.zsize;
    if Ndim>1
        use_zsize=1;
    else
        Ndim=tmp.nframes;
        use_zsize=0;
    end
    max_frame=floor(4.2e9/xdim/ydim/2/100)*100; % calculate max frames for tif
       
    for iN=1:Ndim
        display(strcat('detecting: ',num2str(iN),', file: ',base_str));
        
        if mod(iN,max_frame)==1
            clear tmp;
            if iN+max_frame-1<Ndim
                if use_zsize==1
                    tmp=imreadBF(strcat(input_dir,base_str),(iN:iN+max_frame-1),1,1);
                else
                    tmp=imreadBF(strcat(input_dir,base_str),1,(iN:iN+max_frame-1),1);
                end
            else
                if use_zsize==1
                    tmp=imreadBF(strcat(input_dir,base_str),(iN:Ndim),1,1);
                else
                    tmp=imreadBF(strcat(input_dir,base_str),1,(iN:Ndim),1);
                end
            end
            tmp_back=mean(tmp,3);
            file_ext=iN;
            tmp_back=reshape(tmp_back,prod(size(tmp_back)),1);
            tmp_back(tmp_back<0)=power(2,bit_depth)+tmp_back(tmp_back<0);
            tmp_back=reshape(tmp_back,ydim,xdim);
        end
               
        if mod(iN,max_frame)==0
            tmp_slice=tmp(:,:,max_frame);
        else
            tmp_slice=tmp(:,:,mod(iN,max_frame));
        end
        
        tmp_slice=reshape(tmp_slice,prod(size(tmp_slice)),1);
        tmp_slice(tmp_slice<0)=power(2,bit_depth)+tmp_slice(tmp_slice<0);
        tmp_slice=reshape(tmp_slice,ydim,xdim);       
        tmp_slice=tmp_slice-tmp_back+100;
        tmp_slice=conv2(tmp_slice,ones(3,3))/9;
        tmp_slice=tmp_slice(2:end-1,2:end-1);
               
        if iN==1
            imwrite(uint16(tmp_slice),strcat('./incoming/',base_str,'.',num2str(file_ext),'.tif'),'WriteMode','overwrite');
        else
            imwrite(uint16(tmp_slice),strcat('./incoming/',base_str,'.',num2str(file_ext),'.tif'),'WriteMode','append');
        end
    end
end
