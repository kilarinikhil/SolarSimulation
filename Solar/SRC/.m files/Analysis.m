%Change the value of j for change in Rs
%i is the variable for changing the variabe of 72 cells, change 72 to...
%number of cells present
for j= 0:0.001:0.013
for i = 1:1:72
set_param(strcat('sample/Sol',num2str(k)),'Rs',num2str(j));
end
sim('sample');%Enter the file name here
figure
plot(Voltage,Current);
end

%For changing the value of RSh
for j= 1000:1000:10000
for i = 1:1:72
set_param(strcat('sample/Sol',num2str(k)),'Rp',num2str(j));
end
sim('sample');%Enter the file name here
figure
plot(Voltage,Current);
end

%For Changing the Temperature of a cell
for j= 0:20:200

set_param('sample/Sol1','TFIXED',num2str(j));
set_param('sample/Sol1','Tmeas',num2str(j));

sim('sample');%Enter the file name here
hold on
plot(Voltage,Current);
end