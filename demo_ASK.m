clc,clear
% close all
path='./Dataset/';
addpath('./LDM/')
addpath('./tools/')
data='IndiaP';
% data='Salinas';
% data='KSC';
location = [path,data]; 
load (location);
percent = 8;
numPixels = length(GroundT);
numTrains = numPixels * percent / 100;
switch data
    case{'IndiaP'}
        no_classes = 16;
        no_train= numTrains;
    case{'Salinas'}
        no_classes = 16;
        no_train= numTrains;
    case{'KSC'}
        no_classes = 13;
        no_train= numTrains;
    otherwise
        error('not data set');
end
GroundT = GroundT';
indexes = train_test_random_new(GroundT(2,:),fix(no_train/no_classes),no_train);
train_SL = GroundT(:,indexes);
test_SL = GroundT;
test_SL(:,indexes) = [];
[no_lines, no_rows, ~] = size(img);
img2 = weighte_fusion(img,20);
no_bands = size(img2,3);
Smoothimg = reshape(img2,[no_lines*no_rows no_bands]); 
[Smoothimg] = scale_new(Smoothimg);
Smoothimg = reshape(Smoothimg,[no_lines no_rows no_bands]);
%% 
SmoothFimg = Tsmoothimg(Smoothimg);
SmoothFimg_2 = ToVector(SmoothFimg);
SmoothFimg_2 = SmoothFimg_2';
SmoothFimg_2 = double(SmoothFimg_2);

%%
% get the training-test samples and labels
train_samples = SmoothFimg_2(:,train_SL(1,:))';
train_labels= train_SL(2,:)';
test_samples = SmoothFimg_2(:,test_SL(1,:))';
test_labels = test_SL(2,:)';
[train_samples,M,m] = scale_func(train_samples);
[SmoothFimg_2] = scale_func(SmoothFimg_2',M,m);
s = 0;
for i = 1:16
%    for i =1:9
     disp(['class ',num2str(i),':',...
         num2str(length(find(train_labels == i))),':',...
         num2str(length(find(test_labels == i)))]);
    s = s + length(find(train_labels == i));
end
%============================================   ==================================
testInstance = SmoothFimg_2;
vote = zeros(no_classes,size(testInstance,1));
C = 1e6;
lambda1 = 125000;             
lambda2 = 50000;
for i = 1:no_classes-1
    for  j = i+1:no_classes 
          if i>=j
              error('i must be smaller than j');
          end
          trainInstance = [train_samples(train_labels==i,:);...
              train_samples(train_labels==j,:)];
          label = [-1*ones(length(find(train_labels==i)),1);...
              ones(length(find(train_labels==j)),1)];
          [prediction,accuracy,value] = ...
              LDM(label,trainInstance,ones(size(testInstance,1),1),...
              testInstance,C,lambda1,lambda2,'-s 0 -k 2 -g 1');%-s 0 -g 0.1
          for k = 1:size(testInstance,1)
              if prediction(k) == -1
                  vote(i,k) = vote(i,k)+1;
              else
                  vote(j,k) = vote(j,k)+1;
              end
          end
    end
end
[grade, LDMresult] = max(vote,[],1);

GroundTest = double(test_labels(:,1));
LDMResultTest = LDMresult(test_SL(1,:));   % just select the test point
[LDMOA,LDMAA,LDMkappa,LDMCA] = confusion(GroundTest,LDMResultTest);

%% Result
LDMresult = reshape(LDMresult,no_lines,no_rows);
switch data 
    case {'IndiaP'}
        LDMmap = label2color_new(LDMresult,'indianpines');
    case {'Salinas'}
        LDMmap = label2color_new(LDMresult,'salinas');
    case{'KSC'}
        LDMmap=label2color_new(LDMresult,'ksc');
    otherwise
        error('error input data set !');
end
%% 
temp = ToVector(LDMmap);
for i = 1:size(temp,1)
    if ~any(GroundT(1,:)==i)
        temp(i,:)=[0 0 0];
    end
end
LDMmap = reshape(temp,no_lines, no_rows, 3);  
imshow(LDMmap,'border','tight','initialmagnification','fit');    
set (gcf,'Position',[0,0,614,512]); 