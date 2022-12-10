sigmas =[0.4 0.7 1.1 1.4 1.7 2 2.3 2.6 2.9];
filter_sizes =[3 5 7 9 11 13 15 17 19 20];

params=cell(length(sigmas)*length(filter_sizes),2);
     
k=0;
for i=0:length(params)-1
    if(mod(i,length(sigmas))==0)
        k=k+1;
    end
    params{i+1,1}=sigmas(mod(i,length(sigmas))+1);
    params{i+1,2}=filter_sizes(k);
end